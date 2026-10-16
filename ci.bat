@echo off
setlocal enableextensions enabledelayedexpansion

cmake -S . -B build
if errorlevel 1 exit /b %errorlevel%

cmake --build build --config Release
if errorlevel 1 exit /b %errorlevel%

ctest --test-dir build -C Release --output-on-failure
if errorlevel 1 exit /b %errorlevel%

if not exist dist mkdir dist
if exist build\Release\hello.exe (
    copy /Y build\Release\hello.exe dist\hello.exe
) else if exist build\hello.exe (
    copy /Y build\hello.exe dist\hello.exe
) else (
    echo Built executable not found in build\Release\ or build\.
    exit /b 1
)
