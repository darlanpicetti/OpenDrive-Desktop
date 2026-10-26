# SPDX-License-Identifier: GPL-2.0-or-later
# Applies the OpenDrive branding.
#   -Source      on a fresh nextcloud/desktop checkout (once, before the build)
#   -Blueprints  on the Craft blueprints after Craft fetched them
# Fails on any surprise: an upstream bump must be reviewed, not silently patched.
param(
    [Parameter(Mandatory, ParameterSetName = 'Source')][string]$Source,
    [Parameter(Mandatory, ParameterSetName = 'Blueprints')][string]$Blueprints
)
$ErrorActionPreference = 'Stop'

function Fail($msg) { Write-Error "apply-branding: $msg"; exit 1 }

function Get-FileEncoding($path) {
    $b = [IO.File]::ReadAllBytes($path)
    if ($b.Length -ge 2 -and $b[0] -eq 0xFF -and $b[1] -eq 0xFE) { return New-Object Text.UnicodeEncoding($false, $true) }
    if ($b.Length -ge 2 -and $b[0] -eq 0xFE -and $b[1] -eq 0xFF) { return New-Object Text.UnicodeEncoding($true, $true) }
    if ($b.Length -ge 3 -and $b[0] -eq 0xEF -and $b[1] -eq 0xBB -and $b[2] -eq 0xBF) { return New-Object Text.UTF8Encoding($true) }
    return New-Object Text.UTF8Encoding($false)
}

function Write-KeepEncoding($path, $text) {
    [IO.File]::WriteAllText($path, $text, (Get-FileEncoding $path))
}

function Replace-Exact($path, [string[]]$pairs) {
    $text = [IO.File]::ReadAllText($path)
    for ($i = 0; $i -lt $pairs.Count; $i += 2) {
        $count = ([regex]::Matches($text, [regex]::Escape($pairs[$i]))).Count
        if ($count -ne 1) { Fail "$(Split-Path $path -Leaf): '$($pairs[$i])' found $count times, expected 1" }
        $text = $text.Replace($pairs[$i], $pairs[$i + 1])
    }
    Write-KeepEncoding $path $text
}

if ($Blueprints) {
    # Package name, vendor and the executable allow-list of blacklist.txt.
    $bp = Get-ChildItem $Blueprints -Recurse -File -Filter 'nextcloud-client.py' | Where-Object { $_.Directory.Name -eq 'nextcloud-client' }
    if (@($bp).Count -ne 1) { Fail "expected one nextcloud-client.py under $Blueprints, found $(@($bp).Count)" }
    Replace-Exact $bp.FullName @(
        'self.defines["appname"] = "nextcloud"', 'self.defines["appname"] = "opendrive"'
        'self.defines["company"] = "Nextcloud GmbH"', 'self.defines["company"] = "OpenSys"'
        'self.applicationExecutable = "nextcloud"', 'self.applicationExecutable = "opendrive"'
    )
    Replace-Exact (Join-Path $bp.Directory.FullName 'blacklist.txt') @(
        'bin/(?!(nextcloud|nextcloudcmd|QtWebEngineProcess)).*\.exe', 'bin/(?!(opendrive|opendrivecmd|QtWebEngineProcess)).*\.exe'
    )
    Write-Host "apply-branding: blueprint ok ($($bp.FullName))"
    exit 0
}

$overlay = (Resolve-Path (Join-Path $PSScriptRoot '..\branding')).Path
$Source = (Resolve-Path $Source).Path

# 1. Overlay files (NEXTCLOUD.cmake, theme, MSI bitmaps).
Get-ChildItem $overlay -Recurse -File | ForEach-Object {
    $rel = $_.FullName.Substring($overlay.Length + 1)
    $dest = Join-Path $Source $rel
    New-Item -ItemType Directory -Force (Split-Path $dest) | Out-Null
    Copy-Item $_.FullName $dest -Force
    Write-Host "overlay: $rel"
}

# 2. Nextcloud GUIDs -> OpenDrive GUIDs, everywhere in the tree.
$guids = [ordered]@{
    'BC6988AB-ACE2-4B81-84DC-DC34F9B24401' = 'C2C55A84-63A9-4331-A4EB-709BD8FD61BF'  # context menu
    'E0342B74-7593-4C70-9D61-22F294AAFE05' = 'E9DE80E9-92C3-4E20-A562-74EBE9DDBB51'  # overlay error
    'E1094E94-BE93-4EA2-9639-8475C68F3886' = '1190528C-AE66-4123-BC44-B78C0BD9399E'  # overlay ok
    'E243AD85-F71B-496B-B17E-B8091CBE93D2' = 'F114A50F-B44C-4D65-929D-C24C45B1B6C7'  # overlay ok shared
    'E3D6DB20-1D83-4829-B5C9-941B31C0C35A' = 'D2D32D47-3238-4916-B34C-85818C82FD0A'  # overlay sync
    'E4977F33-F93A-4A0A-9D3C-83DEA0EE8483' = 'E0987F5E-B668-4F06-8189-C1F2F40DD270'  # overlay warning
    'FD2FCCA9-BB8F-4485-8F70-A0621B84A7F4' = '56D0FB96-69C2-43C9-8D02-E2C0DD342767'  # MSI upgrade code
    'E314A650-DCA4-416E-974E-18EA37C213EA' = '532FF80C-C4B6-403E-9E6C-E359273A364D'  # CfApi AppID
    '1E62D59A-6EA4-476C-B707-4A32E88ED822' = 'A4846B7C-2021-4245-9765-D9AEFDA10866'  # CfApi custom state handler
    '6FF9B5B6-389F-444A-9FDD-A286C36EA079' = 'CAC4C3E1-67CF-4B1C-8B9D-17B384C085D3'  # CfApi thumbnail handler
}
$cmakeLists = [IO.File]::ReadAllText((Join-Path $Source 'CMakeLists.txt'))
foreach ($old in 'E314A650-DCA4-416E-974E-18EA37C213EA', '1E62D59A-6EA4-476C-B707-4A32E88ED822', '6FF9B5B6-389F-444A-9FDD-A286C36EA079') {
    if (([regex]::Matches($cmakeLists, $old, 'IgnoreCase')).Count -ne 1) { Fail "CfApi GUID $old not found exactly once in CMakeLists.txt" }
}
$textExt = '.txt', '.cmake', '.in', '.h', '.hpp', '.cpp', '.c', '.idl', '.def', '.rc', '.wxs', '.wxi', '.xml', '.manifest', '.reg', '.json', '.py', '.ps1', '.bat', '.js', '.vbs', '.xsl'
# Symlinks are skipped: on the runner Git creates real links, some pointing to macOS-only paths.
$files = Get-ChildItem $Source -Recurse -File |
    Where-Object { $_.FullName -notmatch '\\\.git\\' -and $textExt -contains $_.Extension.ToLower() -and -not ($_.Attributes -band [IO.FileAttributes]::ReparsePoint) }
foreach ($f in $files) {
    $text = [IO.File]::ReadAllText($f.FullName)
    $new = $text
    foreach ($k in $guids.Keys) { $new = [regex]::Replace($new, [regex]::Escape($k), $guids[$k], 'IgnoreCase') }
    if ($new -ne $text) {
        Write-KeepEncoding $f.FullName $new
        Write-Host "guid: $($f.FullName.Substring($Source.Length + 1))"
    }
}

# 3. Start menu tile manifest is named after APPLICATION_EXECUTABLE.
if (-not (Test-Path (Join-Path $Source 'theme\opendrive.VisualElementsManifest.xml'))) { Fail 'theme\opendrive.VisualElementsManifest.xml missing from overlay' }

# 4. Craft settings: no tests; portable package, whose archive tree feeds make-msi.bat.
Replace-Exact (Join-Path $Source 'craftmaster.ini') @(
    'nextcloud-client.buildTests = True', 'nextcloud-client.buildTests = False'
    'Packager/PackageType = NullsoftInstallerPackager', 'Packager/PackageType = PortablePackager'
)

Write-Host 'apply-branding: source ok'
