# UART synthesis target

The lab handout requires synthesis for a target FPGA but does not specify a device. For a reproducible software-only estimate, this project uses Lattice iCE40 HX8K in package CT256 as an explicitly selected target. No physical board is claimed.

## Assumed configuration

- System clock: 50 MHz (`G_CLK_FREQ_HZ = 50000000`).
- UART baud rate: 9600 (`G_BAUD_RATE = 9600`).
- Frame: 8N1.
- Top module: `uart_top`.
- Simulation-only testbench is not synthesized.
- No board pinout was supplied; `nextpnr-ice40` is run with `--pcf-allow-unconstrained`, so IO pins are automatically placed and the result is not a board-ready bitstream.

These clock and UART settings are project assumptions, not values stated in the handout or confirmed by an instructor.

## Windows paths

The batch script expects:

- OSS CAD Suite: `F:\Tools\oss-cad-suite`
- GHDL: `F:\Tools\ghdl\bin\ghdl.exe`

Copy the complete GHDL distribution folder (including `bin`, `lib`, and `include`) to `F:\Tools\ghdl`. The ASCII-only paths avoid Windows `cmd.exe` misreading a non-ASCII source path.

## Run

Double-click `synth.bat` from the project folder. It analyzes VHDL, asks GHDL to emit Verilog, maps it with Yosys, then runs nextpnr for iCE40 HX8K CT256.

## Reports

- `reports/yosys.log`: synthesis and cell statistics, including iCE40 logic and flip-flop usage.
- `reports/nextpnr.log`: placement, routing and timing summary.
- `reports/nextpnr_report.json`: machine-readable resource and timing report.
- `reports/tool_versions.txt`: exact tool versions.

Only report figures from a successful run. Fmax is a timing estimate for the selected software target and assumed clock constraint, not a measurement on physical hardware.
