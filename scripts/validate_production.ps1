param(
  [ValidateSet('All', 'Web', 'Android', 'Ios')]
  [string]$Target = 'All'
)

$ErrorActionPreference = 'Stop'

function Test-EnvValue([string]$Name) {
  $value = [Environment]::GetEnvironmentVariable($Name)
  return -not [string]::IsNullOrWhiteSpace($value)
}

function Require-Env([string]$Name) {
  if (-not (Test-EnvValue $Name)) {
    throw "Missing required production environment variable: $Name"
  }
}

function Require-RealEnv([string]$Name) {
  Require-Env $Name
  $value = [Environment]::GetEnvironmentVariable($Name)
  if ($value.ToLowerInvariant().Contains('placeholder') -or $value.ToLowerInvariant().Contains('test')) {
    throw "Production environment variable $Name must not contain placeholder/test values."
  }
}

function Require-ProductionUrl([string]$Name) {
  Require-RealEnv $Name
  $value = [Environment]::GetEnvironmentVariable($Name).ToLowerInvariant()
  if ($value.Contains('localhost') -or $value.Contains('127.0.0.1') -or $value.Contains('0.0.0.0')) {
    throw "Production environment variable $Name must not point to a local URL."
  }
  if (-not ($value.StartsWith('https://'))) {
    throw "Production environment variable $Name must use https://"
  }
}

function Require-FileOrEnv([string]$Path, [string]$EnvName) {
  if ((Test-Path -LiteralPath $Path) -or (Test-EnvValue $EnvName)) {
    return
  }
  throw "Missing required production file '$Path' or environment variable '$EnvName'"
}

function Require-Text([string]$Path, [string]$Pattern, [string]$Message) {
  if (-not (Test-Path -LiteralPath $Path)) {
    throw "Missing required file: $Path"
  }
  $text = Get-Content -LiteralPath $Path -Raw
  if ($text -notmatch $Pattern) {
    throw $Message
  }
}

$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

if ($Target -in @('All', 'Web')) {
  Require-RealEnv 'FIREBASE_APP_CHECK_WEB_KEY'
  Require-ProductionUrl 'API_BASE_URL'
}

if ($Target -in @('All', 'Android')) {
  Require-RealEnv 'FIREBASE_APP_CHECK_WEB_KEY'
  Require-ProductionUrl 'API_BASE_URL'
  if (-not (Test-Path -LiteralPath 'android/key.properties')) {
    Require-Env 'ANDROID_KEYSTORE_BASE64'
    Require-Env 'ANDROID_KEY_ALIAS'
    Require-Env 'ANDROID_KEY_PASSWORD'
    Require-Env 'ANDROID_STORE_PASSWORD'
  }
}

if ($Target -in @('All', 'Ios')) {
  Require-ProductionUrl 'API_BASE_URL'
  Require-FileOrEnv 'ios/Runner/GoogleService-Info.plist' 'IOS_GOOGLE_SERVICE_INFO_PLIST_BASE64'
  Require-Text 'ios/Runner/Info.plist' 'CFBundleURLTypes' 'iOS Google Sign-In URL scheme is not configured in Info.plist.'
  Require-Text 'ios/Runner/Runner.entitlements' '\$\(APS_ENVIRONMENT\)' 'iOS APNs entitlement must use APS_ENVIRONMENT build setting.'
  Require-Text 'ios/Runner.xcodeproj/project.pbxproj' 'CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;' 'Runner entitlements are not wired into Xcode build settings.'
  Require-Text 'ios/Runner.xcodeproj/project.pbxproj' 'APS_ENVIRONMENT = production;' 'Release/Profile APNs environment is not configured for production.'
}

Write-Host "Production preflight passed for $Target"
