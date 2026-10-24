param(
  [string]$Target = 'E:\DSH-Portable'
)
$ErrorActionPreference = 'Stop'
$source = Join-Path $PSScriptRoot 'DeepSeek-Herness-0.9.5-pill.exe'
$target = Join-Path $Target 'DeepSeek-Herness.exe'
if (-not (Test-Path -LiteralPath $source)) { throw "Missing $source" }
if (Get-Process -Name 'DeepSeek-Herness' -ErrorAction SilentlyContinue) {
  throw 'Please exit DSH-Portable first (tray -> exit), then run this script again.'
}
if (Test-Path -LiteralPath $target) {
  Copy-Item -LiteralPath $target -Destination ($target + '.stock-backup') -Force
}
Copy-Item -LiteralPath $source -Destination $target -Force
Write-Host 'Patched shell installed. Launch DeepSeek-Herness.exe again.'
