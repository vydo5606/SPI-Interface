##################################
# Project 8 clock and IO constraints
##################################

set SPI_CLK_PERIOD 10000.00
set MEM_CLK_PERIOD 66.667
set CLK_LATENCY 0.50
set CLK_SKEW 1.00
set CLK_JITTER 0.20
set SETUP_UNCERTAINTY [expr $CLK_SKEW + $CLK_JITTER]

# 100 kHz SCLK and 15 MHz SRAM clock
create_clock -name spi_clk -period $SPI_CLK_PERIOD -waveform {0 5000} [get_ports SCLK]
create_clock -name mem_clk -period $MEM_CLK_PERIOD -waveform {0 33.3335} [get_ports clk_mem]

set_clock_latency $CLK_LATENCY [get_clocks {spi_clk mem_clk}]
set_clock_uncertainty -setup $SETUP_UNCERTAINTY [get_clocks {spi_clk mem_clk}]
set_clock_uncertainty -hold $CLK_SKEW [get_clocks {spi_clk mem_clk}]
set_clock_transition 0.10 [get_clocks {spi_clk mem_clk}]

# Request/acknowledge toggles cross asynchronous clock domains.
set_clock_groups -asynchronous -group [get_clocks spi_clk] -group [get_clocks mem_clk]

set_input_delay 3.00 -clock spi_clk [get_ports MOSI]
set_output_delay 3.00 -clock spi_clk [get_ports {MISO MISO_enable}]
set_input_transition 0.10 [get_ports MOSI]
set_load 0.02 [get_ports {MISO MISO_enable}]

# Asynchronous resets are not timed as data paths.
set_false_path -from [get_ports {rst_n CSN}]
