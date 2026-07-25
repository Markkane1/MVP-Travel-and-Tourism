param(
  [string]$ApiBaseUrl = "https://flutterapi.duckdns.org"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$adminRoot = Join-Path $repoRoot "admin_app"
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$deployDir = Join-Path $repoRoot "output\deploy"
$slimRoot = Join-Path $deployDir "admin_web_slim_$stamp"
$zipPath = Join-Path $deployDir "admin_web_slim_$stamp.zip"

New-Item -ItemType Directory -Force -Path $deployDir | Out-Null

Push-Location $adminRoot
try {
  flutter build web --release --pwa-strategy=none --web-resources-cdn --no-wasm-dry-run --dart-define=API_BASE_URL=$ApiBaseUrl --dart-define=FLAVOR=prod
} finally {
  Pop-Location
}

$sourceRoot = (Resolve-Path (Join-Path $adminRoot "build\web")).Path
New-Item -ItemType Directory -Force -Path $slimRoot | Out-Null

Get-ChildItem $sourceRoot -Recurse -File |
  Where-Object { $_.FullName -notlike "*\canvaskit\*" } |
  ForEach-Object {
    $relative = $_.FullName.Substring($sourceRoot.Length).TrimStart("\")
    $target = Join-Path $slimRoot $relative
    New-Item -ItemType Directory -Force -Path (Split-Path $target -Parent) | Out-Null
    Copy-Item -LiteralPath $_.FullName -Destination $target
  }

Compress-Archive -Path (Join-Path $slimRoot "*") -DestinationPath $zipPath -CompressionLevel Optimal
Get-Item $zipPath
