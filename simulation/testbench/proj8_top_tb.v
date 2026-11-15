`timescale 1ns / 1ps

///////////////////////////////////////
// ECE6213 Project 8
// Integrated SPI interface and SRAM testbench
// Based on the course starter testbench from Professor Matthew LaRue
///////////////////////////////////////

module proj8_top_tb();

    // SPI signals
    reg        SCLK    = 1'b0;
    reg        CSN     = 1'b1;
    reg        MOSI    = 1'b0;
    reg        rst_n   = 1'b0;
    wire       MISO;
    wire       MISO_enable;

    // Memory clock, 15 MHz
    reg        clk_mem = 1'b0;

    reg [7:0]  SPI_data_out;
    reg [7:0]  spi_data [63:0];
    reg        tb_clk  = 1'b0;
    reg [8*39:0] testcase;
    integer    i;
    integer    error_count;

    // Instantiate DUT
    proj8_top DUT (
        .SCLK(SCLK),
        .CSN(CSN),
        .MOSI(MOSI),
        .rst_n(rst_n),
        .clk_mem(clk_mem),
        .MISO(MISO),
        .MISO_enable(MISO_enable)
    );

    // 100 kHz SPI clock; SCLK pulses are generated in SPI_CMD.
    always #5000 tb_clk = ~tb_clk;
    always #33.333 clk_mem = ~clk_mem;



    // Stop the simulation if a transaction gets stuck.
    initial begin
        #50000000;
        $display("FAIL: Simulation timeout");
        $finish;
    end

    initial begin
        error_count = 0;
        testcase = "Initializing";

        // Allow the memory reset synchronizer to finish first.
        repeat(10) @(negedge clk_mem);
        rst_n = 1'b1;
        repeat(6) @(posedge clk_mem);

        // SCLK may be idle during reset. Send clocks with CSN high to
        // release the SPI reset synchronizer before the first command.
        repeat(4) begin
            @(negedge tb_clk) SCLK = 1'b0;
            @(posedge tb_clk) SCLK = 1'b1;
        end
        @(negedge tb_clk) SCLK = 1'b0;

        // Generate data for all addresses.
        for (i = 0; i < 64; i = i + 1)
            spi_data[i] = $random;

        repeat(3) @(posedge tb_clk);

        testcase = "SPI_WRITE";
        for (i = 0; i < 64; i = i + 1)
            SPI_CMD(1'b1, i, spi_data[i], SPI_data_out);

        repeat(10) @(posedge tb_clk);

        testcase = "SPI_READ";
        for (i = 0; i < 64; i = i + 1) begin
            SPI_CMD(1'b0, i, spi_data[i], SPI_data_out);
            if (spi_data[i] !== SPI_data_out) begin
                error_count = error_count + 1;
                $display("FAIL addr=%02d expected=%02h actual=%02h", i,
                         spi_data[i], SPI_data_out);
            end
            else begin
                $display("PASS addr=%02d data=%02h", i, SPI_data_out);
            end
        end

        repeat(10) @(posedge tb_clk);

        if (error_count == 0) begin
            $display("----------SIMULATION PASSED----------");
            $display("----------64/64 ADDRESSES  ----------");
            $display("----------RTL SIMULATION----------");
        end
        else begin
            $display("----------SIMULATION FAILED----------");
            $display("---------- %0d ERRORS TOTAL----------", error_count);
            $finish;
        end
        $finish;
    end

    // Keep the same 31-bit SPI command timing as the SPI unit test.
    task SPI_CMD (
        input         SPI_read_write,
        input  [5:0]  SPI_addr,
        input  [7:0]  SPI_data_in,
        output [7:0]  SPI_data_out
    );
        integer bit_i;
        begin
            @(negedge tb_clk)
                CSN = 1'b0;

            MOSI = SPI_read_write;
            @(posedge tb_clk)
                SCLK = 1'b1;

            // Six address bits
            for (bit_i = 5; bit_i >= 0; bit_i = bit_i - 1) begin
                @(negedge tb_clk)
                    SCLK = 1'b0;
                MOSI = SPI_addr[bit_i];
                @(posedge tb_clk)
                    SCLK = 1'b1;
            end

            // Eight waiting bits before the data field
            for (bit_i = 7; bit_i >= 0; bit_i = bit_i - 1) begin
                @(negedge tb_clk)
                    SCLK = 1'b0;
                MOSI = 1'b0;
                @(posedge tb_clk)
                    SCLK = 1'b1;
            end

            // Eight data bits
            for (bit_i = 7; bit_i >= 0; bit_i = bit_i - 1) begin
                @(negedge tb_clk)
                    SCLK = 1'b0;
                if (SPI_read_write == 1'b1)
                    MOSI = SPI_data_in[bit_i];
                else
                    MOSI = 1'b0;

                @(posedge tb_clk)
                    SCLK = 1'b1;

                if (SPI_read_write == 1'b0) begin
                    if (MISO_enable !== 1'b1) begin
                        error_count = error_count + 1;
                        $display("FAIL: MISO_enable low on read bit %0d", bit_i);
                    end
                    SPI_data_out[bit_i] = MISO;
                end
                else begin
                    if (MISO_enable !== 1'b0) begin
                        error_count = error_count + 1;
                        $display("FAIL: MISO_enable high during a write");
                    end
                    SPI_data_out[bit_i] = 1'bz;
                end
            end

            // Eight waiting bits after the data field
            for (bit_i = 7; bit_i >= 0; bit_i = bit_i - 1) begin
                @(negedge tb_clk)
                    SCLK = 1'b0;
                MOSI = 1'b0;
                @(posedge tb_clk)
                    SCLK = 1'b1;
            end

            @(negedge tb_clk);
            SCLK = 1'b0;
            CSN = 1'b1;
        end
    endtask

endmodule
