@echo off
chcp 65001 >nul
setlocal
cd /d "%~dp0"

echo ==========================================
echo APKS Lab 3 - UART VHDL simulation
echo ==========================================

where ghdl >nul 2>nul
if errorlevel 1 (
    echo [ERROR] GHDL is not in PATH.
    echo Open PowerShell and run the command from README.md to add GHDL bin to PATH for this session.
    pause
    exit /b 1
)

if not exist sim mkdir sim
if not exist sim\work mkdir sim\work

echo [1/3] Analyze VHDL sources...
ghdl -a --std=08 --workdir=sim\work src\baud_generator.vhd src\uart_tx.vhd src\uart_rx.vhd src\uart_top.vhd tb\uart_tb.vhd
if errorlevel 1 goto :fail

echo [2/3] Elaborate testbench...
ghdl -e --std=08 --workdir=sim\work uart_tb
if errorlevel 1 goto :fail

echo [3/3] Run simulation and write VCD...
ghdl -r --std=08 --workdir=sim\work uart_tb --vcd=sim\waveform.vcd --assert-level=error
if errorlevel 1 goto :fail

echo.
echo [PASS] Simulation finished. Open sim\waveform.vcd in Surfer.
echo.
pause
exit /b 0

:fail
echo.
echo [FAIL] GHDL reported an error. Read the message above.
pause
exit /b 1
