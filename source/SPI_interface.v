`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// ECE6213: Project 8 SPI Interface
// File Name: SPI_interface.v
// Author: Vy Do
// Date: November 13th, 2026
//////////////////////////////////////////////////////////////////////////////////

module  SPI_interface 
(
    input wire SCLK,
    input wire  MOSI,
    input wire CSN,
    input wire rst_n,

    output reg  MISO,
    output reg MISO_enable,

    // ports to connect from SPI to CDC circuit
    output reg [5:0] mem_addr,
    output reg [7:0] mem_write_data, // data that the SPI writes to the memory
    output reg       mem_write_req,
    output reg       mem_read_req,
    input wire [7:0] mem_read_data   // data that the memory will send back to the SPI 
);

reg [4:0] bit_count; // to count the order of the incoming bit 2^5 = 32
reg       read_write_reg; // 30: the read/write bit
reg [7:0] write_shift;
reg [7:0] read_shift;
reg       message_done; //complete message is transmitted      

// MOSI: external controller write data to the memory module, through SPI interface
always @(posedge SCLK or negedge rst_n or posedge CSN) // CSN is not active
    begin
        if (rst_n == 0 || CSN == 1)
            begin
                bit_count <= 5'd30; // original bit count is 30
                read_write_reg <= 0;
                write_shift <= 0;
                message_done <= 0;
                mem_write_data <= 0;
                mem_write_req <= 0;
                mem_read_req <= 0;
                mem_addr <= 0;
            end
        else 
            begin               
                if (message_done == 0) // if the SPI have not receive the full message
                begin

                    // set the requests equal 0. Only trigger when bit order is proper
                    mem_write_req <= 0; 
                    mem_read_req <= 0;

                    case (bit_count)  
                        // the order of the bit decides the info it carries 
                        5'd30:
                            begin
                                read_write_reg <= MOSI; // 0: read, 1: write
                            end
                        
                        5'd29, 5'd28, 5'd27, 5'd26, 5'd25, 5'd24:
                            begin
                                mem_addr <= {mem_addr[4:0], MOSI}; // 6 bit shift left, add newest MOSI to the right

                                // read request only need the complete register address
                                if (bit_count == 5'd24 && read_write_reg == 0) 
                                    mem_read_req <= 1;
                            end

                        5'd15, 5'd14, 5'd13, 5'd12, 5'd11, 5'd10, 5'd9, 5'd8:
                            begin 
                                if (read_write_reg == 1) // write 
                                    begin
                                        write_shift <= {write_shift[6:0], MOSI};
                                     // write request when SPI receive complete data 
                                        if (bit_count == 5'd8 && read_write_reg == 1)
                                            begin                                
                                                mem_write_data <= {write_shift[6:0], MOSI}; // 8 bit shift left, newest MOSI to the right
                                                mem_write_req <= 1;
                                            end
                                    end                                                         
                            end
                        
                        default: // no action requires for default
                            begin
                            end
                    endcase
                end
                if (bit_count == 5'd0) // bit_count "counts" the order of incoming bit on each raising clock 
                    message_done <= 1; 
                else 
                    bit_count <= bit_count - 1; 
            end
    end

// MISO: external controller wants to access data from the memory through SPI. 
// Then the memory send back the requested data through SPI interface

always @(negedge SCLK or negedge rst_n or posedge CSN)
    if (rst_n == 0 || CSN == 1)
        begin
            MISO <= 0;
            MISO_enable <= 0;
            read_shift <= 0;
        end
    else
        begin
            MISO <= 0;
            MISO_enable <= 0;

            if (read_write_reg == 0 && message_done == 0)
                begin
                    case(bit_count)
                        5'd16: // start to load the data from memory to the read shift
                            begin
                                read_shift <= mem_read_data;
                            end

                        // gradually shift the data to the MISO bit by bit  
                        // take the lower 7 bits
                        // and insert 0 to the right to create a shift left
                        5'd15, 5'd14, 5'd13, 5'd12, 5'd11, 5'd10, 5'd9, 5'd8:
                            begin
                                MISO <= read_shift[7];
                                read_shift <= {read_shift[6:0], 1'd0}; 
                                MISO_enable <= 1'b1;
                            end

                        default: // no action in default
                            begin
                            end
                    endcase
                end
        end

endmodule