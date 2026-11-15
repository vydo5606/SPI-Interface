`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// ECE6213: Project 8 SPI Interface
// File Name: reset_sequencer.v
//////////////////////////////////////////////////////////////////////////////////

module reset_sequencer (
    input  wire rst_n,
    input  wire SCLK,
    input  wire clk_mem,
    output wire rst_n_spi,
    output wire rst_n_mem
);

wire spi_reset_in;

reset_sync mem_reset (
    .clk(clk_mem),
    .rst_n(rst_n),
    .rst_n_sync(rst_n_mem)
);

// The SPI clock domain leaves reset after the memory clock domain.
assign spi_reset_in = rst_n & rst_n_mem;

reset_sync spi_reset (
    .clk(SCLK),
    .rst_n(spi_reset_in),
    .rst_n_sync(rst_n_spi)
);

endmodule
