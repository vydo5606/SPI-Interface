`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// ECE6213: Project 8 SPI Interface
// File Name: spi_mem_cdc.v
//////////////////////////////////////////////////////////////////////////////////

module spi_mem_cdc (
    input  wire       SCLK,
    input  wire       clk_mem,
    input  wire       rst_n_spi,
    input  wire       rst_n_mem,

    // SPI interface
    input  wire [5:0] spi_addr,
    input  wire [7:0] spi_write_data,
    input  wire       spi_write_req,
    input  wire       spi_read_req,
    output reg  [7:0] spi_read_data,

    // Memory controller
    output reg        mem_start,
    output reg        mem_write,
    output reg  [5:0] mem_addr,
    output reg  [7:0] mem_write_data,
    input  wire       mem_done,
    input  wire [7:0] mem_read_data
);

reg        request_toggle_spi;
reg        request_write_spi;
reg [5:0]  request_addr_spi;
reg [7:0]  request_data_spi;
(* async_reg = "true" *) reg acknowledge_meta_spi;
(* async_reg = "true" *) reg acknowledge_sync_spi;
reg        acknowledge_seen_spi;

(* async_reg = "true" *) reg [1:0] request_sync_ff;
wire       request_sync_mem;
reg        request_seen_mem;
reg        acknowledge_toggle_mem;
reg        mem_busy;
reg [7:0]  read_data_hold_mem;

// Request and address/data are held until the memory acknowledges them.
// Only one memory operation is outstanding at a time.
always @(posedge SCLK or negedge rst_n_spi)
    if (!rst_n_spi)
        begin
            request_toggle_spi <= 1'b0;
            request_write_spi <= 1'b0;
            request_addr_spi <= 6'b0;
            request_data_spi <= 8'b0;
            acknowledge_meta_spi <= 1'b0;
            acknowledge_sync_spi <= 1'b0;
            acknowledge_seen_spi <= 1'b0;
            spi_read_data <= 8'b0;
        end
    else
        begin
            acknowledge_meta_spi <= acknowledge_toggle_mem;
            acknowledge_sync_spi <= acknowledge_meta_spi;

            if (acknowledge_sync_spi != acknowledge_seen_spi)
                begin
                    acknowledge_seen_spi <= acknowledge_sync_spi;
                    spi_read_data <= read_data_hold_mem;
                end

            // The pulses from SPI_interface are one SCLK cycle long.
            if ((spi_read_req || spi_write_req) &&
                (request_toggle_spi == acknowledge_sync_spi))
                begin
                    request_write_spi <= spi_write_req;
                    request_addr_spi <= spi_addr;
                    request_data_spi <= spi_write_data;
                    request_toggle_spi <= ~request_toggle_spi;
                end
        end

// Synchronize the request toggle into the memory clock domain.
assign request_sync_mem = request_sync_ff[1];

always @(posedge clk_mem or negedge rst_n_mem)
    if (!rst_n_mem)
        request_sync_ff <= 2'b00;
    else
        request_sync_ff <= {request_sync_ff[0], request_toggle_spi};

// New request: latch the stable address and data, then start the SRAM access.
// Completion: hold read data and return the acknowledgement toggle.
always @(posedge clk_mem or negedge rst_n_mem)
    if (!rst_n_mem)
        begin
            request_seen_mem <= 1'b0;
            acknowledge_toggle_mem <= 1'b0;
            mem_busy <= 1'b0;
            mem_start <= 1'b0;
            mem_write <= 1'b0;
            mem_addr <= 6'b0;
            mem_write_data <= 8'b0;
            read_data_hold_mem <= 8'b0;
        end
    else
        begin
            mem_start <= 1'b0;

            if (!mem_busy && request_sync_mem != request_seen_mem)
                begin
                    request_seen_mem <= request_sync_mem;
                    mem_write <= request_write_spi;
                    mem_addr <= request_addr_spi;
                    mem_write_data <= request_data_spi;
                    mem_start <= 1'b1;
                    mem_busy <= 1'b1;
                end
            else if (mem_busy && mem_done)
                begin
                    if (!mem_write)
                        read_data_hold_mem <= mem_read_data;
                    acknowledge_toggle_mem <= request_seen_mem;
                    mem_busy <= 1'b0;
                end
        end

endmodule
