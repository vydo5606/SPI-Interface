# ECE6213 Project 8 — SPI Interface

SPI read/write access to a 64 × 8-bit SRAM, with separate SPI and memory clock domains.

## Source code

- `source/SPI_interface.v` — SPI command and data handling (teammate's original file, unchanged).
- `source/proj8_top.v` — top-level connection of all modules.
- `source/spi_mem_cdc.v` — transfers requests and data between clock domains.
- `source/memory_controller.v` — controls SRAM reads and writes.
- `source/reset_sync.v`, `source/reset_sequencer.v` — reset synchronization and sequencing.
- `source/sram_test.v` — SRAM wrapper from the course starter files.
- `macros/` — supplied SRAM Verilog model and library files.

## Simulation

- `simulation/testbench/SPI_interface_tb.v` — teammate's original SPI-only testbench (unchanged).
- `simulation/testbench/proj8_top_tb.v` — full-system RTL testbench.
- `simulation/testbench/proj8_top_syn_tb.v` — full-system back-annotated testbench.
- `simulation/run_sim`, `simulation/scripts/` — simulation script and file lists.
- `simulation/rtl_sim_pass.log`, `simulation/gate_sim_pass.log` — passing 64-address read/write test logs.
- `screenshots/` — RTL and back-annotated SPI write/read waveform screenshots.

## Synthesis

- `synthesis/run_syn`, `synthesis/scripts/`, `synthesis/constraints/` — Genus synthesis flow and timing constraints.
- `synthesis/netlists/` — generated gate-level netlist, SDF, and SDC.
- `synthesis/reports/` — timing, area, power, and other synthesis reports.
