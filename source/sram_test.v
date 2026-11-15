`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// ECE6213 Project 8
// Matthew LaRue
// 64 x 8-bit SRAM wrapper
//////////////////////////////////////////////////////////////////////////////////

module sram_test(
    input wire 	      clk,
    input wire 	      rst_n,
    input wire 	      read_enable,
    input wire write_enable,		 
    input wire [5:0]  addr_in,
    input wire [7:0]  data_in,
    output wire [7:0] data_out
    );

   wire 	      chip_en_n;

   assign chip_en_n = ~(read_enable ^ write_enable);
   
   

   gf180mcu_fd_ip_sram__sram64x8m8wm1 i_sram(
					     .CLK(clk),
					     .CEN(chip_en_n), // active-low chip enable
					     .GWEN(~write_enable), // active-low write enable
					     .WEN(8'h00),
					     .A(addr_in),
					     .D(data_in),
					     .Q(data_out)
					     );
       
endmodule
