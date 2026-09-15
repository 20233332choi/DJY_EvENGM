[CmdletBinding()]
param(
    [ValidatePattern('^COM\d+$')]
    [string]$Port = 'COM8',
    [int]$Baud = 460800
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$image = Join-Path $projectRoot 'firmware\esp32-s3-swd-bridge\djy-evengm-swd-bridge.factory.bin'
$pioPython = Join-Path $env:USERPROFILE '.platformio\penv\Scripts\python.exe'
$espTool = Join-Path $env:USERPROFILE '.platformio\packages\tool-esptoolpy\esptool.py'

foreach ($required in @($image, $pioPython, $espTool)) {
    if (-not (Test-Path -LiteralPath $required)) { throw "Required file not found: $required" }
}

Write-Warning "This overwrites the existing firmware on the ESP32-S3 connected to $Port."
& $pioPython $espTool --chip esp32s3 --port $Port flash-id
if ($LASTEXITCODE -ne 0) { throw "ESP32-S3 identification failed: $LASTEXITCODE" }

& $pioPython $espTool --chip esp32s3 --port $Port --baud $Baud write-flash 0x0 $image
if ($LASTEXITCODE -ne 0) { throw "ESP32-S3 flashing failed: $LASTEXITCODE" }

Write-Host 'Bridge installed and verified. Connect the ESP32-S3 native USB/OTG port for CMSIS-DAP.'
