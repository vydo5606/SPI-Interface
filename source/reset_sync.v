`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// ECE6213: Project 8 SPI Interface
// File Name: reset_sync.v
//////////////////////////////////////////////////////////////////////////////////

module reset_sync (
    input  wire clk,
    input  wire rst_n,
    output wire rst_n_sync
);

(* async_reg = "true" *) reg [1:0] reset_ff;

// Assert reset asynchronously and release it after two clock cycles.
always @(posedge clk or negedge rst_n)
    if (!rst_n)
        reset_ff <= 2'b00;
    else
        reset_ff <= {reset_ff[0], 1'b1};

assign rst_n_sync = reset_ff[1];

endmodule
