`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// ECE6213: Project 8 SPI Interface
// File Name: proj8_top.v
//////////////////////////////////////////////////////////////////////////////////

module proj8_top (
    input  wire SCLK,
    input  wire MOSI,
    input  wire CSN,
    input  wire rst_n,
    input  wire clk_mem,
    output wire MISO,
    output wire MISO_enable
);

wire rst_n_spi;
wire rst_n_mem;

wire [5:0] spi_addr;
wire [7:0] spi_write_data;
wire       spi_write_req;
wire       spi_read_req;
wire [7:0] spi_read_data;

wire       mem_start;
wire       mem_write;
wire [5:0] mem_addr;
wire [7:0] mem_write_data;
wire       mem_done;
wire [7:0] mem_read_data;

reset_sequencer reset_control (
    .rst_n(rst_n),
    .SCLK(SCLK),
    .clk_mem(clk_mem),
    .rst_n_spi(rst_n_spi),
    .rst_n_mem(rst_n_mem)
);

// Existing SPI interface from the SPI unit test.
SPI_interface spi (
    .SCLK(SCLK),
    .MOSI(MOSI),
    .CSN(CSN),
    .rst_n(rst_n_spi),
    .MISO(MISO),
    .MISO_enable(MISO_enable),
    .mem_addr(spi_addr),
    .mem_write_data(spi_write_data),
    .mem_write_req(spi_write_req),
    .mem_read_req(spi_read_req),
    .mem_read_data(spi_read_data)
);

spi_mem_cdc cdc (
    .SCLK(SCLK),
    .clk_mem(clk_mem),
    .rst_n_spi(rst_n_spi),
    .rst_n_mem(rst_n_mem),
    .spi_addr(spi_addr),
    .spi_write_data(spi_write_data),
    .spi_write_req(spi_write_req),
    .spi_read_req(spi_read_req),
    .spi_read_data(spi_read_data),
    .mem_start(mem_start),
    .mem_write(mem_write),
    .mem_addr(mem_addr),
    .mem_write_data(mem_write_data),
    .mem_done(mem_done),
    .mem_read_data(mem_read_data)
);

memory_controller mem_ctrl (
    .clk_mem(clk_mem),
    .rst_n_mem(rst_n_mem),
    .start(mem_start),
    .write_req(mem_write),
    .addr(mem_addr),
    .write_data(mem_write_data),
    .done(mem_done),
    .read_data(mem_read_data)
);

endmodule
