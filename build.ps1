<#
.SYNOPSIS
    Builds the Linux Distribution Timeline on Windows.
#>
param(
    [string]$ProjName = "ldt",
    [string]$DistDir = "dist",
    [string]$GnucladPath = ".\gnuclad.exe"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $DistDir)) {
    New-Item -ItemType Directory -Path $DistDir | Out-Null
}

if (-not (Test-Path $GnucladPath)) {
    $found = Get-Command "gnuclad.exe" -ErrorAction SilentlyContinue
    if ($found) {
        $GnucladPath = $found.Source
    } else {
        Write-Error "gnuclad.exe not found at $GnucladPath or in PATH."
    }
}

$csvFile = "$ProjName.csv"
$confFile = "$ProjName.conf"
$svgFile = Join-Path $DistDir "$ProjName.svg"
$pngFile = Join-Path $DistDir "$ProjName.png"

Write-Host "==> Generating SVG: $svgFile ..." -ForegroundColor Cyan
& $GnucladPath $csvFile $svgFile $confFile
if ($LASTEXITCODE -ne 0) {
    Write-Error "gnuclad failed to generate $svgFile"
}
Write-Host "==> Successfully generated $svgFile" -ForegroundColor Green

$magick = Get-Command "magick.exe" -ErrorAction SilentlyContinue
if ($magick) {
    Write-Host "==> Generating PNG with ImageMagick: $pngFile ..." -ForegroundColor Cyan
    & $magick.Source $svgFile $pngFile
    Write-Host "==> Successfully generated $pngFile" -ForegroundColor Green
} else {
    Write-Host "==> ImageMagick not found; skipped PNG conversion. SVG is available." -ForegroundColor Yellow
}
