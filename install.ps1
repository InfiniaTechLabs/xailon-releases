[CmdletBinding()]
param(
    [ValidateSet('install', 'update')][string]$Action = 'install',
    [ValidateSet('cli', 'desktop', 'all')][string]$Component = 'cli',
    [string]$Version,
    [switch]$DryRun
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Get-VerifiedAsset([string]$Name, [string]$Directory, [string]$Base) {
    $destination = Join-Path $Directory $Name
    Write-Host "Downloading $Name..."
    Invoke-WebRequest -UseBasicParsing -Uri "$Base/$Name" -OutFile $destination
    $checksum = (Invoke-WebRequest -UseBasicParsing -Uri "$Base/$Name.sha256").Content
    if ($checksum -is [byte[]]) { $checksum = [Text.Encoding]::UTF8.GetString($checksum) }
    $expected = ($checksum.Trim() -split '\s+')[0]
    if ($expected -notmatch '^[a-fA-F0-9]{64}$') { throw "Invalid checksum for $Name" }
    $actual = (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash
    if ($actual -ine $expected) { throw "Checksum mismatch for $Name. Nothing from this download was installed." }
    return $destination
}
function Install-Msi([string]$Path, [string]$Log) {
    $arguments = "/i `"$Path`" /passive /norestart /l*v `"$Log`""
    $process = Start-Process msiexec.exe -ArgumentList $arguments -Wait -PassThru
    if ($process.ExitCode -notin @(0, 3010)) {
        throw "Installer failed with code $($process.ExitCode). Log: $Log"
    }
    if ($process.ExitCode -eq 3010) { Write-Host 'Windows requests a restart to finish installation.' }
}
function Install-VisualCppRuntime([string]$Directory) {
    $system = Join-Path $env:WINDIR 'System32'
    if ((Test-Path (Join-Path $system 'vcruntime140.dll')) -and (Test-Path (Join-Path $system 'msvcp140.dll'))) { return }
    $installer = Join-Path $Directory 'vc_redist.x64.exe'
    Write-Host 'Installing the Microsoft Visual C++ runtime prerequisite...'
    Invoke-WebRequest -UseBasicParsing -Uri 'https://aka.ms/vs/17/release/vc_redist.x64.exe' -OutFile $installer
    $signature = Get-AuthenticodeSignature -LiteralPath $installer
    if ($signature.Status -ne 'Valid' -or $signature.SignerCertificate.Subject -notmatch 'Microsoft Corporation') {
        throw 'Microsoft runtime signature verification failed.'
    }
    $process = Start-Process -FilePath $installer -ArgumentList '/install /passive /norestart' -Verb RunAs -Wait -PassThru
    if ($process.ExitCode -notin @(0, 1638, 3010)) { throw "Microsoft runtime installer failed: $($process.ExitCode)" }
}

if ([Environment]::OSVersion.Platform -ne 'Win32NT') { throw 'Use install.sh on macOS or Linux.' }
$architecture = if ($env:PROCESSOR_ARCHITEW6432) { $env:PROCESSOR_ARCHITEW6432 } else { $env:PROCESSOR_ARCHITECTURE }
if ($architecture -ne 'AMD64') { throw "This release supports Windows x86-64. Detected: $architecture" }
if (-not $Version) {
    $response = (Invoke-WebRequest -UseBasicParsing -Uri 'https://xailoncode.infinialabs.ai/latest-version.txt').Content
    if ($response -is [byte[]]) { $response = [Text.Encoding]::UTF8.GetString($response) }
    $Version = ([string]$response).Trim()
}
if ($Version -notmatch '^v[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9][A-Za-z0-9.-]*)?$') { throw 'Invalid release version.' }
$base = "https://github.com/InfiniaTechLabs/xailon-releases/releases/download/$Version"
Write-Host "Xailon $Action`: $Version / Windows x86-64 / $Component"
Write-Host "Download source: $base"
if ($DryRun) { Write-Host 'Plan: checksum-verified MSI installation and missing prerequisites. No changes.'; return }

$temp = Join-Path ([IO.Path]::GetTempPath()) ('xailon-install-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $temp | Out-Null
$logDirectory = Join-Path $env:LOCALAPPDATA 'Xailon\InstallerLogs'
New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
try {
    $packages = @()
    if ($Component -in @('cli', 'all')) { $packages += Get-VerifiedAsset 'xailon-x86_64-pc-windows-msvc.msi' $temp $base }
    if ($Component -in @('desktop', 'all')) { $packages += Get-VerifiedAsset 'xailon-desktop-x86_64-pc-windows-msvc.msi' $temp $base }
    Install-VisualCppRuntime $temp
    foreach ($package in $packages) {
        $log = Join-Path $logDirectory (([IO.Path]::GetFileNameWithoutExtension($package)) + '-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.log')
        Install-Msi $package $log
    }
    Write-Host "Xailon $Action complete ($Version)."
    Write-Host 'Open a new terminal, run xailon configure, then xailon tui or open Xailon Desktop.'
    Write-Host 'The desktop MSI installs WebView2 when required. Windows may ask for administrator approval.'
    Write-Host 'To update, run this script with -Action update and the same -Component value.'
} finally {
    if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force }
}
