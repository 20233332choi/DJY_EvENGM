[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$flashScript = Join-Path $root 'scripts\flash_energy_meter.ps1'
$sumFile = Join-Path $root 'firmware\esp32-s3-swd-bridge\SHA256SUMS.txt'

$form = New-Object System.Windows.Forms.Form
$form.Text = 'DJY Energy Meter Programmer'
$form.Size = New-Object System.Drawing.Size(760, 500)
$form.StartPosition = 'CenterScreen'

$title = New-Object System.Windows.Forms.Label
$title.Text = 'ESP32-S3 → STM32F401 SWD'
$title.Font = New-Object System.Drawing.Font('Segoe UI', 15, [System.Drawing.FontStyle]::Bold)
$title.Location = New-Object System.Drawing.Point(20, 15)
$title.AutoSize = $true
$form.Controls.Add($title)

$note = New-Object System.Windows.Forms.Label
$note.Text = 'ESP native USB/OTG 포트를 연결하세요. 차량/HV/drive cable은 분리 상태여야 합니다.'
$note.Location = New-Object System.Drawing.Point(22, 52)
$note.AutoSize = $true
$form.Controls.Add($note)

$log = New-Object System.Windows.Forms.RichTextBox
$log.Location = New-Object System.Drawing.Point(20, 105)
$log.Size = New-Object System.Drawing.Size(700, 300)
$log.ReadOnly = $true
$log.Font = New-Object System.Drawing.Font('Consolas', 9)
$form.Controls.Add($log)

$probeButton = New-Object System.Windows.Forms.Button
$probeButton.Text = '연결 확인'
$probeButton.Location = New-Object System.Drawing.Point(20, 70)
$probeButton.Size = New-Object System.Drawing.Size(120, 28)
$form.Controls.Add($probeButton)

$flashButton = New-Object System.Windows.Forms.Button
$flashButton.Text = 'release 전송'
$flashButton.Location = New-Object System.Drawing.Point(150, 70)
$flashButton.Size = New-Object System.Drawing.Size(120, 28)
$form.Controls.Add($flashButton)

$verifyButton = New-Object System.Windows.Forms.Button
$verifyButton.Text = '브리지 무결성'
$verifyButton.Location = New-Object System.Drawing.Point(280, 70)
$verifyButton.Size = New-Object System.Drawing.Size(120, 28)
$form.Controls.Add($verifyButton)

$wiringButton = New-Object System.Windows.Forms.Button
$wiringButton.Text = '배선 문서'
$wiringButton.Location = New-Object System.Drawing.Point(410, 70)
$wiringButton.Size = New-Object System.Drawing.Size(120, 28)
$form.Controls.Add($wiringButton)

function Write-Log([string]$message) {
    $log.AppendText("$(Get-Date -Format 'HH:mm:ss') $message`r`n")
    $log.ScrollToCaret()
}

function Set-Busy([bool]$busy) {
    $probeButton.Enabled = -not $busy
    $flashButton.Enabled = -not $busy
    $verifyButton.Enabled = -not $busy
    $wiringButton.Enabled = -not $busy
}

function Invoke-FlashOperation([switch]$ProbeOnly) {
    Set-Busy $true
    try {
        $arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $flashScript + '"'
        if ($ProbeOnly) { $arguments += ' -ProbeOnly' }
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = Join-Path $PSHOME 'powershell.exe'
        $psi.Arguments = $arguments
        $psi.UseShellExecute = $false
        $psi.CreateNoWindow = $true
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $psi
        [void]$process.Start()
        $outTask = $process.StandardOutput.ReadToEndAsync()
        $errTask = $process.StandardError.ReadToEndAsync()
        while (-not $process.HasExited) {
            [System.Windows.Forms.Application]::DoEvents()
            Start-Sleep -Milliseconds 50
        }
        $process.WaitForExit()
        if ($outTask.Result) { Write-Log $outTask.Result.TrimEnd() }
        if ($errTask.Result) { Write-Log $errTask.Result.TrimEnd() }
        if ($process.ExitCode -eq 0) { Write-Log '완료' } else { Write-Log "실패 (exit $($process.ExitCode))" }
    } catch {
        Write-Log "오류: $($_.Exception.Message)"
    } finally {
        Set-Busy $false
    }
}

$probeButton.Add_Click({ Invoke-FlashOperation -ProbeOnly })
$flashButton.Add_Click({
    $answer = [System.Windows.Forms.MessageBox]::Show('STM32F401 플래시를 덮어씁니다. 계속할까요?', '확인', 'YesNo', 'Warning')
    if ($answer -eq 'Yes') { Invoke-FlashOperation }
})
$verifyButton.Add_Click({
    try {
        foreach ($line in Get-Content -LiteralPath $sumFile) {
            $parts = $line -split '  ', 2
            $actual = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path (Split-Path $sumFile) $parts[1])).Hash.ToLowerInvariant()
            if ($actual -ne $parts[0]) { throw "해시 불일치: $($parts[1])" }
        }
        Write-Log '브리지 펌웨어 무결성 PASS'
    } catch { Write-Log "무결성 오류: $($_.Exception.Message)" }
})
$wiringButton.Add_Click({ Start-Process (Join-Path $root 'docs\WIRING.md') })

Write-Log '대기 중: native USB/OTG와 CMSIS-DAP 장치를 연결하세요.'
[void]$form.ShowDialog()
