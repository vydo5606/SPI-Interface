`timescale 1ns / 1ps

///////////////////////////////////////
// Professor Matthew LaRue
// ECE6213
// SPI interface implemented
// Reuse proj8_top_tb to test the SPI interface
///////////////////////////////////////

module SPI_interface_tb();

    // SPI interface_signals   
    reg	      SCLK   = 1'b0;
    reg	      CSN    = 1'b1;
    reg	      MOSI   = 1'b0;
    reg	      rst_n  = 1'b0;	    
    wire	      MISO;  
    wire	      MISO_enable;

    // SPI to CDC interface signals
    wire [5:0]      mem_addr;
    wire [7:0]      mem_write_data;
    wire            mem_write_req;
    wire            mem_read_req;
    reg [7:0]       mem_read_data;

    // signal for SPI data output 
    reg [7:0] SPI_data_out;

    // signals for simulation control
    reg             tb_clk = 1'b0; 	      
    reg [8*39:0]    testcase;

    // signal to save generated data in
    reg [7:0]	   spi_data[63:0];

    //loop variables
    integer	   i;
    integer error_count;
    reg [7:0] test_memory [0:63]; // memory to test SPI interface only

   // Instantiate DUT
   SPI_interface DUT
   (
        .SCLK(SCLK),
        .CSN(CSN),
        .MOSI(MOSI),
        .rst_n(rst_n),
        .MISO(MISO),
        .MISO_enable(MISO_enable),

        .mem_addr(mem_addr),
        .mem_write_data(mem_write_data),
        .mem_write_req(mem_write_req),
        .mem_read_req(mem_read_req),
        .mem_read_data(mem_read_data)
   );
   
// Check the write and read to memory of the SPI
    always @(posedge mem_write_req)
        begin
            test_memory[mem_addr] <= mem_write_data;
        end
    
    always @(posedge mem_read_req)
        begin
            mem_read_data <= test_memory[mem_addr];
        end
    // 100 kHz clk = 10,000ns period
    always #5000 tb_clk = ~tb_clk;
 
    
    initial 
    begin
        error_count = 0;
        mem_read_data = 0;
        
       testcase = "Initializing";
       repeat(10)
	    @(posedge tb_clk);
       rst_n = 1'b1;

       // generate spi data to write and read back
       for(i = 0; i <=63; i = i+1) 
        begin
            spi_data[i] = $random;
        end

       repeat(10)
	    @(posedge tb_clk);
       
       // write to all 64 registers
       testcase = "SPI_WRITE";
       for(i = 0; i <=63; i = i+1) 
        begin
            SPI_CMD(1'b1,i,spi_data[i],SPI_data_out);
        end

       repeat(10)
	    @(posedge tb_clk);

       // read all 64 registers
       testcase = "SPI_READ";
       for(i = 0; i <=63; i = i+1) 
        begin
            SPI_CMD(1'b0,i,spi_data[i],SPI_data_out);
            if (spi_data[i] !== SPI_data_out) // Add in code to compare data in and out
                error_count = error_count + 1;
        end

       repeat(20)
	    @(posedge tb_clk);
       
       $finish;
    end


   task SPI_CMD (input	       SPI_read_write, 
                 input  [5:0]  SPI_addr,
		         input  [7:0] SPI_data_in,
                 output [7:0] SPI_data_out); 	 
        
        integer		       i;

        begin       
            // active-low CSN active at clock negative edge, send read/write bit
            @(negedge tb_clk)
                CSN = 1'b0;
            
            MOSI = SPI_read_write;
            @(posedge tb_clk)
            SCLK = 1'b1;
        
        // 6-bit address shifted on clock negedge, send SCLK aligned with tb_clk
            for(i=5; i>=0; i=i-1) 
                begin
                    @(negedge tb_clk)
                    SCLK = 1'b0;
                    MOSI = SPI_addr[i];	
                        @(posedge tb_clk)
                    SCLK = 1'b1; 
                end

        // 8-bit dead time for data retrieval
            for(i=7; i>=0; i=i-1) 
                begin
                    @(negedge tb_clk)
                    SCLK = 1'b0;
                    MOSI = 1'b0;
                        @(posedge tb_clk)
                    SCLK = 1'b1;	 
                end
    
        // 8-bit data shifted on clock negedge, send SCLK aligned with tb_clk
            for(i=7; i>=0; i=i-1) 
                begin
                    @(negedge tb_clk)
                    SCLK = 1'b0;
                    if ( SPI_read_write == 1'b1) begin
                    MOSI = SPI_data_in[i];
                    end else begin
                    MOSI = 1'b0;
                    end
                    
                        @(posedge tb_clk)
                    SCLK = 1'b1;
                    // clock in data on MISO if MISO_enable = 1, else clock in that it is high-z
                    if (MISO_enable == 1'b1) begin
                    SPI_data_out[i] = MISO;
                    end else begin
                    SPI_data_out[i] = 1'bz;
                    end
                end
            
            // 8-bit dead time for data write
            for(i=7; i>=0; i=i-1) 
                begin
                    @(negedge tb_clk)
                    SCLK = 1'b0;
                    MOSI = 1'b0;
                        @(posedge tb_clk)
                    SCLK = 1'b1;	 
                end

            // end message and CSN goes inactive
            @(negedge tb_clk);
            SCLK = 1'b0;
            CSN = 1'b1;
        end     
    endtask // SPI_CMD
   
   
endmodule
