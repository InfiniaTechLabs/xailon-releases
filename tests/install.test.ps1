$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/../install.ps1" -Version 'v0.2.13' -Action update -Component all -DryRun
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('xailon-installer-test-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $fixture | Out-Null
$script:payload = [Text.Encoding]::UTF8.GetBytes('verified fixture')
$hasher = [Security.Cryptography.SHA256]::Create()
$script:checksum = ([BitConverter]::ToString($hasher.ComputeHash($script:payload))).Replace('-', '')
function Invoke-WebRequest {
    param([string]$Uri, [string]$OutFile, [switch]$UseBasicParsing)
    if ($OutFile) { [IO.File]::WriteAllBytes($OutFile, $script:payload); return }
    return [pscustomobject]@{ Content = "$script:checksum  fixture.msi" }
}
try {
    $file = Get-VerifiedAsset 'fixture.msi' $fixture 'https://example.invalid'
    if (-not (Test-Path $file)) { throw 'Verified download was not saved.' }
    $script:checksum = '0' * 64
    $rejected = $false
    try { Get-VerifiedAsset 'fixture.msi' $fixture 'https://example.invalid' | Out-Null }
    catch { if ($_.Exception.Message -match 'Checksum mismatch') { $rejected = $true } else { throw } }
    if (-not $rejected) { throw 'Bad checksum was accepted.' }
    $rejected = $false
    try { & "$PSScriptRoot/../install.ps1" -Version 'v1/../../bad' -DryRun }
    catch { if ($_.Exception.Message -match 'Invalid release version') { $rejected = $true } else { throw } }
    if (-not $rejected) { throw 'Invalid version was accepted.' }
    $script:exitCode = 1603
    function Start-Process { param($FilePath, $ArgumentList, [switch]$Wait, [switch]$PassThru) return [pscustomobject]@{ExitCode=$script:exitCode} }
    $rejected = $false
    try { Install-Msi 'fixture.msi' 'retained-installer.log' }
    catch { if ($_.Exception.Message -match '1603.*retained-installer.log') { $rejected=$true } else { throw } }
    if (-not $rejected) { throw 'MSI failure was not reported.' }
    $script:exitCode = 3010
    Install-Msi 'fixture.msi' 'retained-installer.log'
    Write-Host 'PASS: Windows dry run, checksum validation, invalid version, MSI failure, and reboot result.'
} finally { Remove-Item -LiteralPath $fixture -Recurse -Force }
