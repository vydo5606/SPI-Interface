`timescale 1ns / 1ps

module sram_test_tb(
    );

    // string to display section labels on waveforms, change its radix 
    //      to ASCII in the waveform to view correctly
   reg [(20*8)-1:0] testcase;  
   reg [7:0] 	    error_count = 8'h00;
    
   reg 		    clk;
   reg 		    rst_n;
   reg 		    read_enable;
   reg 		    write_enable;
   reg [5:0] 	    addr_in;
   reg [7:0] 	    data_in;
   wire [7:0] 	    data_out;

   // signal to save generated data in
   reg [7:0]	   mem_data[63:0];

   //loop variables
   integer	   i;

   // Instantiate DUT
    sram_test DUT(
		  .clk(clk),
		  .rst_n(rst_n),
		  .read_enable(read_enable),
		  .write_enable(write_enable),
		  .addr_in(addr_in),
		  .data_in(data_in),
		  .data_out(data_out)
    );
    
        
   always #80 clk = ~clk;
    
    initial begin
       $monitor("Testcase %s: Time = %t", testcase, $time);
       
       // initial values
       clk             = 0;
       rst_n           = 1;
       read_enable     = 0;
       write_enable    = 0;
       addr_in         = 6'h00;
       data_in         = 8'h00;

       testcase = "Initializing";
       repeat(10)
	 @(negedge clk);
       rst_n = 1'b1;

       // generate memory data to write and read back
       for(i = 0; i <=63; i = i+1) begin
	  mem_data[i] = $random;
       end

        repeat(10)
	 @(negedge clk);

       // write to all memory addresses
       testcase = "MEM_WRITE";
       for(i = 0; i <=63; i = i+1) begin
	  addr_in      <= i;
	  data_in      <= mem_data[i];
	  write_enable <= 1;
	  @(negedge clk);
	  write_enable <= 0;
	  @(negedge clk);	  
       end

       data_in      <= 8'h00;
       repeat(10)
	 @(negedge clk);

       // read back and check to all memory addresses
       testcase = "MEM_READ";
       for(i = 0; i <=63; i = i+1) begin
	  addr_in      <= i;
	  read_enable  <= 1;
	  @(negedge clk);
	  read_enable <= 0;
	  error_count = compare_outputs(mem_data[i], data_out, "data_out", error_count);
	  @(negedge clk);	  
       end
       
       repeat(3)
	 @(negedge clk);

       if (error_count == 0) begin
	  $display("\n\n----------SIMULATION PASSED----------");
	  $display("----------RTL SIMULATION   ----------\n\n");
       end else begin
	  $display("\n\n----------SIMULATION FAILED----------");
	  $display("----------RTL SIMULATION   ----------");
	  $display("---------- %d ERRORS TOTAL----------\n\n",error_count);
       end

       $finish;         
    end // initial begin

   function [7:0] compare_outputs (
				       input [7:0]    expected_value,
				       input [7:0]    actual_value,
				       input [8*19:0] signal_name,
				       input [7:0]    error_count);
      if (expected_value == actual_value ) begin
	 $display("  PASS  : %s: Expected = %h, Actual = %h, Time = %t", signal_name, 
		  expected_value, actual_value, $time);
	 compare_outputs = error_count;
      end else begin
	 $display("**FAIL**: %s: Expected = %h, Actual = %h, Time = %t", signal_name, 
		  expected_value, actual_value, $time);
	 compare_outputs = error_count + 1;
      end
   endfunction // compare_outputs     
    
endmodule
