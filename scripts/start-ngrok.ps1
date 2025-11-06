# Requires: ngrok CLI installed and authtoken configured
param(
  [int]$Port = 3000,
  [string]$FlutterEnvRelativePath = "..\lib\.env"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Section {
  param([string]$Message)
  Write-Host ""
  Write-Host "=== $Message ===" -ForegroundColor Cyan
}

if (-not (Get-Command ngrok -ErrorAction SilentlyContinue)) {
  throw "Không tìm thấy lệnh 'ngrok'. Hãy cài đặt hoặc thêm vào PATH trước."
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir

$flutterEnvPath = Join-Path $scriptDir $FlutterEnvRelativePath
if (-not (Test-Path $flutterEnvPath)) {
  # thử tính từ repo root
  $flutterEnvPath = Join-Path $repoRoot "lib\.env"
}
if (-not (Test-Path $flutterEnvPath)) {
  # tạo file nếu chưa có
  New-Item -ItemType File -Path $flutterEnvPath -Force | Out-Null
}

$logPath = Join-Path $scriptDir "ngrok-$Port.log"
if (Test-Path $logPath) {
  Remove-Item $logPath -Force
}

$arguments = @("http", $Port, "--log=stdout", "--log-format=json")
Write-Section "Đang khởi động ngrok (port $Port)"
$process = Start-Process -FilePath "ngrok" -ArgumentList $arguments -NoNewWindow -RedirectStandardOutput $logPath -PassThru
Write-Host "PID: $($process.Id)"

$tunnelUrl = $null
for ($i = 0; $i -lt 40; $i++) {
  Start-Sleep -Milliseconds 500
  if (-not (Test-Path $logPath)) {
    continue
  }
  try {
    $lines = Get-Content $logPath | Where-Object { $_ -match '"msg":"started tunnel"' }
    if ($lines -and $lines.Count -gt 0) {
      $last = $lines[-1]
      $json = $last | ConvertFrom-Json
      if ($json.url -like "https://*") {
        $tunnelUrl = $json.url
        break
      }
    }
  } catch {
    # tiếp tục cho tới khi log hợp lệ
  }
}

if (-not $tunnelUrl) {
  try {
    Stop-Process -Id $process.Id -Force
  } catch {}
  throw "Không thể phát hiện URL ngrok. Kiểm tra lại việc cấu hình authtoken hoặc log tại $logPath"
}

Write-Section "Đã tạo tunnel: $tunnelUrl"

# Cập nhật file .env của Flutter
$currentLines = @()
if (Test-Path $flutterEnvPath) {
  $currentLines = Get-Content $flutterEnvPath
  # loại bỏ dòng cũ
  $currentLines = $currentLines | Where-Object { $_ -notmatch '^\s*API_BASE_URL\s*=' }
}
$currentLines += "API_BASE_URL=$tunnelUrl"
Set-Content -Path $flutterEnvPath -Value $currentLines -Encoding UTF8

Write-Host "Đã cập nhật $flutterEnvPath với API_BASE_URL mới." -ForegroundColor Green

Write-Section "Sử dụng"
Write-Host "1. Mở Flutter app, reload để đọc API_BASE_URL trong lib/.env."
Write-Host "2. Khi không dùng nữa, dừng ngrok bằng:"
Write-Host "     Stop-Process -Id $($process.Id)"
Write-Host "   hoặc đóng cửa sổ PowerShell đang chạy tunnel."
Write-Host "3. Log chi tiết: $logPath"

Write-Host ""
Write-Host "Ngrok đang chạy... nhấn Ctrl+C để dừng script (cần dừng tunnel thủ công nếu còn chạy)." -ForegroundColor Yellow
