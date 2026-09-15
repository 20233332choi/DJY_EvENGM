[CmdletBinding()]
param(
    [switch]$ProbeOnly,
    [ValidateRange(50, 5000)]
    [int]$AdapterKhz = 1000
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$firmware = Join-Path $projectRoot 'firmware\fsk-energymeter-v1.8.2\fsk-energymeter-firmware\release\firmware-release.elf'
$openOcdRoot = Join-Path $env:USERPROFILE '.platformio\packages\tool-openocd'
$openOcd = Join-Path $openOcdRoot 'bin\openocd.exe'
$openOcdScripts = Join-Path $openOcdRoot 'openocd\scripts'

foreach ($required in @($openOcd, $openOcdScripts)) {
    if (-not (Test-Path -LiteralPath $required)) { throw "Required OpenOCD path not found: $required" }
}
if (-not $ProbeOnly -and -not (Test-Path -LiteralPath $firmware)) {
    throw "Energy Meter firmware not found: $firmware"
}

Write-Warning 'Keep vehicle connectors, HV input, and drive cable disconnected. Power the Energy Meter from one isolated 3.3 V source only.'

$commonArgs = @(
    '-s', $openOcdScripts,
    '-f', 'interface/cmsis-dap.cfg',
    '-c', 'transport select swd',
    '-f', 'target/stm32f4x.cfg',
    '-c', 'reset_config none',
    '-c', "adapter speed $AdapterKhz"
)

if ($ProbeOnly) {
    & $openOcd @commonArgs -c 'init; halt; targets; shutdown'
} else {
    & $openOcd @commonArgs -c "program {$firmware} verify reset exit"
}

if ($LASTEXITCODE -ne 0) { throw "OpenOCD failed: $LASTEXITCODE" }
