@echo off
setlocal

set "PROJNAME=ldt"
set "DISTDIR=dist"
set "GC=.\gnuclad.exe"

if not exist "%DISTDIR%" mkdir "%DISTDIR%"

if not exist "%GC%" (
    echo Error: %GC% not found.
    echo Please make sure gnuclad.exe exists in the current directory or is in PATH.
    exit /b 1
)

echo Generating timeline SVG (%DISTDIR%\%PROJNAME%.svg)...
"%GC%" "%PROJNAME%.csv" "%DISTDIR%\%PROJNAME%.svg" "%PROJNAME%.conf"
if errorlevel 1 (
    echo [ERROR] Failed to generate SVG timeline!
    exit /b 1
)
echo [SUCCESS] Generated %DISTDIR%\%PROJNAME%.svg

where magick >nul 2>&1
if %errorlevel% equ 0 (
    echo Converting SVG to PNG with ImageMagick...
    magick "%DISTDIR%\%PROJNAME%.svg" "%DISTDIR%\%PROJNAME%.png"
    if %errorlevel% equ 0 (
        echo [SUCCESS] Generated %DISTDIR%\%PROJNAME%.png
    ) else (
        echo [WARNING] ImageMagick conversion encountered an issue.
    )
) else (
    echo [NOTE] ImageMagick 'magick' not found. Skipping PNG conversion. SVG is ready to view.
)

echo.
echo Build completed successfully!
