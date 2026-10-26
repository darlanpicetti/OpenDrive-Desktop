# SPDX-License-Identifier: GPL-2.0-or-later
# Builds the OpenDrive MSI from the tree Craft collected for the portable package.
param(
    [Parameter(Mandatory)][string]$CraftRoot,
    [Parameter(Mandatory)][string]$OutDir
)
$ErrorActionPreference = 'Stop'
function Fail($msg) { Write-Error "make-msi: $msg"; exit 1 }

if (-not $env:WIX) { Fail 'WIX is not set' }

$exe = Get-ChildItem (Join-Path $CraftRoot 'build\nextcloud-client') -Recurse -File -Filter 'opendrive.exe' -ErrorAction SilentlyContinue |
    Where-Object { $_.Directory.Name -eq 'bin' -and $_.Directory.Parent.Name -eq 'archive' }
if (@($exe).Count -ne 1) {
    Get-ChildItem (Join-Path $CraftRoot 'build\nextcloud-client') -Directory -ErrorAction SilentlyContinue | ForEach-Object { Write-Host "dir: $($_.FullName)" }
    Fail "expected one archive\bin\opendrive.exe, found $(@($exe).Count)"
}
$archive = $exe.Directory.Parent.FullName
if (Test-Path (Join-Path $archive 'bin\nextcloud.exe')) { Fail 'nextcloud.exe is in the package' }

$msiSrc = Join-Path $archive 'msi'
foreach ($f in 'make-msi.bat', 'Nextcloud.wxs', 'NCMsiHelper.wxs', 'WinShellExt.wxs', 'OEM.wxi', 'collect-transform.xsl') {
    if (-not (Test-Path (Join-Path $msiSrc $f))) { Fail "msi\$f missing in $archive" }
}

# make-msi.bat harvests the whole app dir; the msi scripts must not end up inside the MSI.
$work = Join-Path $env:RUNNER_TEMP 'opendrive-msi'
Remove-Item $work -Recurse -Force -ErrorAction SilentlyContinue
Move-Item $msiSrc $work

$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$vs = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
$vcvars = Join-Path $vs 'VC\Auxiliary\Build\vcvars64.bat'
if (-not (Test-Path $vcvars)) { Fail "vcvars64.bat not found under $vs" }

# uuidgen (used by make-msi.bat for the ProductCode) comes with the VS developer environment.
& cmd /c "call `"$vcvars`" >nul && cd /d `"$work`" && make-msi.bat `"$archive`""
if ($LASTEXITCODE -ne 0) { Fail "make-msi.bat exited $LASTEXITCODE" }

$msi = Get-ChildItem $work -Filter 'OpenDrive-*.msi'
if (@($msi).Count -ne 1) { Fail "expected one OpenDrive-*.msi, found $(@($msi).Count)" }
New-Item -ItemType Directory -Force $OutDir | Out-Null
Copy-Item $msi.FullName $OutDir
$hash = (Get-FileHash $msi.FullName -Algorithm SHA256).Hash.ToLower()
Set-Content -Path (Join-Path $OutDir "$($msi.Name).sha256") -Value "$hash  $($msi.Name)" -Encoding ascii
Write-Host "make-msi: $($msi.Name) $hash"
