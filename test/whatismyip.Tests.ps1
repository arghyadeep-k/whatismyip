#!/usr/bin/env pwsh
# Pester tests for bin/whatismyip.ps1
# Run with: Invoke-Pester test/whatismyip.Tests.ps1

BeforeAll {
    $Script = Join-Path $PSScriptRoot '..' 'bin' 'whatismyip.ps1'
}

Describe 'whatismyip.ps1' {
    It '-h prints usage' {
        $result = & $Script '-h'
        ($result -join "`n") | Should -Match 'Usage: whatismyip'
    }

    It '--help prints usage' {
        $result = & $Script '--help'
        ($result -join "`n") | Should -Match 'Usage: whatismyip'
    }

    It 'unknown option exits 1 with usage' {
        & $Script '--bogus' 2>$null
        $LASTEXITCODE | Should -Be 1
    }

    It '-l prints at least one local IPv4 address' {
        $result = @(& $Script '-l')
        $result.Count | Should -BeGreaterThan 0
        $result[0] | Should -Match '^\d{1,3}(\.\d{1,3}){3}$'
    }
}
