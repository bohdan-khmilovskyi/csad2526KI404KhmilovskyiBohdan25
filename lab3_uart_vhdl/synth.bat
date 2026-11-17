@echo off
setlocal EnableExtensions
cd /d "%~dp0"

rem All paths must use ASCII characters because cmd.exe may misread UTF-8 paths.
set "OSS_CAD_HOME=F:\Tools\oss-cad-suite"
set "GHDL_BIN=F:\Tools\ghdl\bin"

if not exist "%OSS_CAD_HOME%\environment.bat" (
    echo [ERROR] OSS CAD Suite environment.bat was not found.
    echo Expected: %OSS_CAD_HOME%\environment.bat
    pause
    exit /b 1
)

if not exist "%GHDL_BIN%\ghdl.exe" (
    echo [ERROR] GHDL was not found.
    echo Expected: %GHDL_BIN%\ghdl.exe
    echo Copy the complete GHDL folder to F:\Tools\ghdl first.
    pause
    exit /b 1
)

call "%OSS_CAD_HOME%\environment.bat"
if errorlevel 1 goto :fail
set "PATH=%GHDL_BIN%;%PATH%"

where ghdl >nul 2>nul
if errorlevel 1 goto :missing_ghdl
where yosys >nul 2>nul
if errorlevel 1 goto :missing_yosys
where nextpnr-ice40 >nul 2>nul
if errorlevel 1 goto :missing_nextpnr

if not exist synth mkdir synth
if exist synth\ghdl_work rmdir /s /q synth\ghdl_work
mkdir synth\ghdl_work
if not exist reports mkdir reports

for /f "delims=" %%V in ('ghdl --version ^| findstr /B /C:"GHDL "') do set "GHDL_VERSION=%%V"
for /f "delims=" %%V in ('yosys -V') do set "YOSYS_VERSION=%%V"
for /f "delims=" %%V in ('nextpnr-ice40 --version') do set "NEXTPNR_VERSION=%%V"
> reports\tool_versions.txt echo GHDL: %GHDL_VERSION%
>> reports\tool_versions.txt echo Yosys: %YOSYS_VERSION%
>> reports\tool_versions.txt echo nextpnr-ice40: %NEXTPNR_VERSION%

echo ==========================================
echo APKS Lab 3 - UART VHDL synthesis
echo Target: Lattice iCE40 HX8K CT256
echo ==========================================

echo [1/3] Analyze VHDL sources...
ghdl -a --std=08 --workdir=synth\ghdl_work src\baud_generator.vhd src\uart_tx.vhd src\uart_rx.vhd src\uart_top.vhd
if errorlevel 1 goto :fail

echo [2/3] Synthesize VHDL to Verilog...
ghdl --synth --std=08 --workdir=synth\ghdl_work --out=verilog --no-formal -gG_CLK_FREQ_HZ=50000000 -gG_BAUD_RATE=9600 uart_top > synth\uart_top.v
if errorlevel 1 goto :fail
if not exist synth\uart_top.v goto :fail
for %%A in (synth\uart_top.v) do if %%~zA LSS 100 goto :fail

echo [3/3] Map design to iCE40 and run place-and-route...
yosys -l reports\yosys.log -p "read_verilog synth/uart_top.v; hierarchy -check -top uart_top; synth_ice40 -top uart_top -json synth/uart_top.json; stat"
if errorlevel 1 goto :fail

nextpnr-ice40 --hx8k --package ct256 --json synth/uart_top.json --asc synth/uart_top.asc --freq 50 --pcf-allow-unconstrained --report reports/nextpnr_report.json --detailed-timing-report --log reports/nextpnr.log
if errorlevel 1 goto :fail

echo.
echo [PASS] Synthesis and place-and-route completed.
echo Reports:
echo   reports\yosys.log
echo   reports\nextpnr.log
echo   reports\nextpnr_report.json
echo   reports\tool_versions.txt
echo.
echo This is a software-target result for iCE40 HX8K CT256.
echo No physical board pinout was supplied; IO pins are unconstrained.
echo Do not describe this as a test on a physical FPGA board.
echo.
pause
exit /b 0

:missing_ghdl
echo [ERROR] GHDL is not available in PATH.
goto :fail

:missing_yosys
echo [ERROR] Yosys is not available in PATH.
goto :fail

:missing_nextpnr
echo [ERROR] nextpnr-ice40 is not available in PATH.
goto :fail

:fail
echo.
echo [FAIL] Synthesis flow stopped. Check the report logs.
echo Do not report resource or timing values until the flow completes successfully.
echo.
pause
exit /b 1
