[CmdletBinding()]
param(
    [string]$DeviceId = '',
    [switch]$BuildApk
)
$ErrorActionPreference = 'Stop'
$academyRoot = Split-Path -Parent $PSScriptRoot
$academyFlutter = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $academyFlutter) {
    throw 'Flutter is not on PATH. Install Flutter 3.35.7, add its bin folder to PATH, then reopen PowerShell.'
}
$script:academyFlutterPath = $academyFlutter.Source
function Invoke-AcademyFlutter {
    param([string[]]$FlutterArguments)
    & $script:academyFlutterPath @FlutterArguments
    if ($LASTEXITCODE -ne 0) {
        throw "flutter $($FlutterArguments -join ' ') failed with exit code $LASTEXITCODE."
    }
}
Push-Location (Join-Path $academyRoot 'mobile')
try {
    Invoke-AcademyFlutter -FlutterArguments @('pub', 'get')
    Invoke-AcademyFlutter -FlutterArguments @('gen-l10n')
    Invoke-AcademyFlutter -FlutterArguments @('analyze')
    Invoke-AcademyFlutter -FlutterArguments @('test')
    if ($BuildApk) {
        Invoke-AcademyFlutter -FlutterArguments @('build', 'apk', '--debug')
        Write-Host (Join-Path $academyRoot 'mobile\build\app\outputs\flutter-apk\app-debug.apk')
    } else {
        $academyRunArguments = @('run')
        if ($DeviceId) { $academyRunArguments += @('-d', $DeviceId) }
        Invoke-AcademyFlutter -FlutterArguments $academyRunArguments
    }
} finally {
    Pop-Location
}
