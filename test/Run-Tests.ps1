#!/usr/bin/env pwsh
# Runs the Pester test suite for whatismyip.ps1 and fails the build on test failure.

if (-not (Get-Module -ListAvailable -Name Pester)) {
    Install-Module -Name Pester -Force -Scope CurrentUser -SkipPublisherCheck
}

$result = Invoke-Pester -Path $PSScriptRoot -PassThru
if ($result.FailedCount -gt 0) {
    exit 1
}
