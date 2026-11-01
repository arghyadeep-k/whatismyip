#!/usr/bin/env pwsh
# whatismyip - print your public (and optionally local) IP address(es)
# Works on Windows PowerShell 5.1+ and PowerShell 7+ (Windows/macOS/Linux).

# Deliberately not a [CmdletBinding()] script with a named parameter:
# PowerShell would treat -h, -l, -a, -6 as parameter names and reject them.
# Reading $args keeps the same flags as the bash version.
$Option = if ($args.Count -gt 0) { [string]$args[0] } else { '' }

$ErrorActionPreference = 'Stop'

function Get-PublicV4 {
    foreach ($url in @('https://ifconfig.me', 'https://icanhazip.com', 'https://ipinfo.io/ip')) {
        try {
            return (Invoke-RestMethod -Uri $url -TimeoutSec 10).ToString().Trim()
        } catch {
            continue
        }
    }
    throw "Could not determine public IPv4 address"
}

function Get-PublicV6 {
    # PowerShell has no portable way to force the IPv6 transport for a request,
    # so this relies on the resolver/network preferring IPv6 when available.
    foreach ($url in @('https://ifconfig.me', 'https://icanhazip.com')) {
        try {
            return (Invoke-RestMethod -Uri $url -TimeoutSec 10).ToString().Trim()
        } catch {
            continue
        }
    }
    throw "Could not determine public IPv6 address"
}

function Get-LocalV4 {
    # Uses .NET APIs (not Get-NetIPAddress) so this also works under
    # PowerShell 7+ on macOS/Linux, where the NetTCPIP module isn't available.
    [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
        Where-Object { $_.OperationalStatus -eq 'Up' } |
        ForEach-Object { $_.GetIPProperties().UnicastAddresses } |
        Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' -and -not $_.Address.ToString().StartsWith('127.') } |
        ForEach-Object { $_.Address.ToString() }
}

function Show-Usage {
    @"
Usage: whatismyip [OPTION]

  (no option)   Show public IPv4 address
  -6            Show public IPv6 address
  -l, --local   Show local IPv4 address(es)
  -a, --all     Show public and local IPv4 addresses
  -h, --help    Show this help
"@
}

switch ($Option) {
    '-6' {
        Get-PublicV6
    }
    { $_ -in '-l', '--local' } {
        Get-LocalV4
    }
    { $_ -in '-a', '--all' } {
        Write-Output "Public: $(Get-PublicV4)"
        Write-Output "Local:"
        Get-LocalV4
    }
    { $_ -in '-h', '--help' } {
        Show-Usage
    }
    '' {
        Get-PublicV4
    }
    default {
        # $ErrorActionPreference is 'Stop', so Write-Error would throw before
        # reaching `exit 1`. Write to stderr directly instead.
        [Console]::Error.WriteLine("Unknown option: $Option")
        Show-Usage
        exit 1
    }
}
