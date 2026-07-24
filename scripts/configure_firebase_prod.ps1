param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectId,

  [switch]$Deploy
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Command firebase -ErrorAction SilentlyContinue)) {
  throw 'firebase CLI is not installed. Run: npm install -g firebase-tools'
}

if (-not (Get-Command flutterfire -ErrorAction SilentlyContinue)) {
  throw 'FlutterFire CLI is not installed. Run: dart pub global activate flutterfire_cli'
}

$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

firebase use $ProjectId

flutterfire configure `
  --project=$ProjectId `
  --out=lib/firebase_options.dart `
  --platforms=android,ios,web `
  --android-package-name=com.mvptravelandtourism.app `
  --ios-bundle-id=com.mvptravelandtourism.app `
  --android-out=android/app/google-services.json `
  --ios-out=ios/Runner/GoogleService-Info.plist `
  --yes `
  --overwrite-firebase-options

Copy-Item -LiteralPath 'lib/firebase_options.dart' -Destination 'admin_app/lib/firebase_options.dart' -Force

$firebaseRc = @{
  projects = @{
    default = $ProjectId
    production = $ProjectId
  }
  targets = @{
    $ProjectId = @{
      hosting = @{
        admin = @($ProjectId)
      }
    }
  }
}

$firebaseRc | ConvertTo-Json -Depth 10 | Set-Content -Path '.firebaserc' -Encoding UTF8
firebase target:apply hosting admin $ProjectId --project $ProjectId

if ($Deploy) {
  firebase deploy --project $ProjectId --only hosting:admin
}

Write-Host "Production Firebase configured for $ProjectId"
