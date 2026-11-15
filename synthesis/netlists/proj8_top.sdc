# ####################################################################

#  Created by Genus(TM) Synthesis Solution 25.10-p002_1 on Sat Nov 14 12:55:33 EST 2026

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design proj8_top

create_clock -name "spi_clk" -period 10000.0 -waveform {0.0 5000.0} [get_ports SCLK]
create_clock -name "mem_clk" -period 66.667 -waveform {0.0 33.3335} [get_ports clk_mem]
set_clock_transition 0.1 [get_clocks spi_clk]
set_clock_transition 0.1 [get_clocks mem_clk]
set_load -pin_load 0.02 [get_ports MISO]
set_load -pin_load 0.02 [get_ports MISO_enable]
set_false_path -from [list \
  [get_ports rst_n]  \
  [get_ports CSN] ]
set_clock_groups -name "clock_groups_spi_clk_to_mem_clk" -asynchronous -group [get_clocks spi_clk] -group [get_clocks mem_clk]
set_clock_gating_check -setup 0.0 
set_input_delay -clock [get_clocks spi_clk] -add_delay 3.0 [get_ports MOSI]
set_output_delay -clock [get_clocks spi_clk] -add_delay 3.0 [get_ports MISO]
set_output_delay -clock [get_clocks spi_clk] -add_delay 3.0 [get_ports MISO_enable]
set_input_transition 0.1 [get_ports MOSI]
set_wire_load_mode "enclosed"
set_clock_latency  0.5 [get_clocks spi_clk]
set_clock_uncertainty -setup 1.2 [get_clocks spi_clk]
set_clock_uncertainty -hold 1.0 [get_clocks spi_clk]
set_clock_latency  0.5 [get_clocks mem_clk]
set_clock_uncertainty -setup 1.2 [get_clocks mem_clk]
set_clock_uncertainty -hold 1.0 [get_clocks mem_clk]
