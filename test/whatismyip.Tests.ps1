#!/usr/bin/env pwsh
# Pester tests for bin/whatismyip.ps1
# Run with: Invoke-Pester test/whatismyip.Tests.ps1

BeforeAll {
    $Script = Join-Path $PSScriptRoot '..' 'bin' 'whatismyip.ps1'
}

Describe 'whatismyip.ps1' {
    It '-h prints usage' {
        $result = & $Script -Option '-h'
        ($result -join "`n") | Should -Match 'Usage: whatismyip'
    }

    It '--help prints usage' {
        $result = & $Script -Option '--help'
        ($result -join "`n") | Should -Match 'Usage: whatismyip'
    }

    It 'unknown option exits 1 with usage' {
        & $Script -Option '--bogus' -ErrorAction SilentlyContinue 2>$null
        $LASTEXITCODE | Should -Be 1
    }
}
