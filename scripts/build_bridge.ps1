[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$bridgeRoot = Join-Path $projectRoot 'firmware\esp-usb-bridge'
$buildRoot = Join-Path $bridgeRoot '.pio\build\esp32-s3-devkitc-1-swd'
$releaseRoot = Join-Path $projectRoot 'firmware\esp32-s3-swd-bridge'

if (-not (Get-Command pio -ErrorAction SilentlyContinue)) {
    throw 'PlatformIO Core(pio)가 PATH에 없습니다.'
}

if (-not $env:IDF_COMPONENT_CACHE_PATH) {
    $env:IDF_COMPONENT_CACHE_PATH = 'C:\p\ic'
}

Push-Location $bridgeRoot
try {
    pio run
    if ($LASTEXITCODE -ne 0) { throw "Bridge build failed: $LASTEXITCODE" }
} finally {
    Pop-Location
}

New-Item -ItemType Directory -Force -Path $releaseRoot | Out-Null
$artifacts = @{
    'firmware.factory.bin' = 'djy-evengm-swd-bridge.factory.bin'
    'bootloader.bin'       = 'bootloader.bin'
    'partitions.bin'       = 'partitions.bin'
    'firmware.bin'         = 'application.bin'
    'firmware.elf'         = 'djy-evengm-swd-bridge.elf'
}

foreach ($sourceName in $artifacts.Keys) {
    Copy-Item -LiteralPath (Join-Path $buildRoot $sourceName) -Destination (Join-Path $releaseRoot $artifacts[$sourceName]) -Force
}

$hashLines = Get-ChildItem -LiteralPath $releaseRoot -File |
    Where-Object Name -ne 'SHA256SUMS.txt' |
    Sort-Object Name |
    ForEach-Object {
        $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $_.FullName).Hash.ToLowerInvariant()
        "$hash  $($_.Name)"
    }
[System.IO.File]::WriteAllLines((Join-Path $releaseRoot 'SHA256SUMS.txt'), $hashLines)

Write-Host "Bridge artifacts: $releaseRoot"
