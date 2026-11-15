`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// ECE6213: Project 8 SPI Interface
// File Name: memory_controller.v
//////////////////////////////////////////////////////////////////////////////////

module memory_controller (
    input  wire       clk_mem,
    input  wire       rst_n_mem,
    input  wire       start,
    input  wire       write_req,
    input  wire [5:0] addr,
    input  wire [7:0] write_data,
    output reg        done,
    output reg  [7:0] read_data
);

localparam IDLE    = 2'd0;
localparam ACCESS  = 2'd1;
localparam CAPTURE = 2'd2;
localparam FINISH  = 2'd3;

reg [1:0] state;
reg       is_write;
reg [5:0] memory_addr;
reg [7:0] memory_write_data;
reg       read_enable;
reg       write_enable;
wire [7:0] memory_read_data;

sram_test memory (
    .clk(clk_mem),
    .rst_n(rst_n_mem),
    .read_enable(read_enable),
    .write_enable(write_enable),
    .addr_in(memory_addr),
    .data_in(memory_write_data),
    .data_out(memory_read_data)
);

// The SRAM inputs are ready before the active rising clock edge.
// Enable is removed on the next falling edge, after the access.
always @(negedge clk_mem or negedge rst_n_mem)
    if (!rst_n_mem)
        begin
            read_enable <= 1'b0;
            write_enable <= 1'b0;
        end
    else
        begin
            read_enable <= (state == ACCESS) && !is_write;
            write_enable <= (state == ACCESS) && is_write;
        end

always @(posedge clk_mem or negedge rst_n_mem)
    if (!rst_n_mem)
        begin
            state <= IDLE;
            is_write <= 1'b0;
            memory_addr <= 6'b0;
            memory_write_data <= 8'b0;
            read_data <= 8'b0;
            done <= 1'b0;
        end
    else
        begin
            done <= 1'b0;
            case (state)
                IDLE:
                    if (start)
                        begin
                            is_write <= write_req;
                            memory_addr <= addr;
                            memory_write_data <= write_data;
                            state <= ACCESS;
                        end
                ACCESS:
                    state <= CAPTURE;
                CAPTURE:
                    begin
                        if (!is_write)
                            read_data <= memory_read_data;
                        done <= 1'b1;
                        state <= FINISH;
                    end
                FINISH:
                    state <= IDLE;
                default:
                    state <= IDLE;
            endcase
        end

endmodule
