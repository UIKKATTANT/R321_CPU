`timescale 1ns/1ps

module register_file_tb;

    //==================================================
    // Testbench Signals
    //==================================================

    reg         clk;
    reg         reg_write;

    reg  [4:0]  rs1;
    reg  [4:0]  rs2;
    reg  [4:0]  rd;

    reg  [31:0] write_data;

    wire [31:0] read_data1;
    wire [31:0] read_data2;

    //==================================================
    // DUT
    //==================================================

    register_file dut (
        .clk(clk),
        .reg_write(reg_write),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    //==================================================
    // Clock Generation (10ns Period)
    //==================================================

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //==================================================
    // Waveform Dump
    //==================================================

    initial begin
        $dumpfile("register_file_tb.vcd");
        $dumpvars(1, register_file_tb);
    end

    //==================================================
    // Monitor
    //==================================================

    initial begin
        $monitor("T=%0t | WE=%b RD=%0d WD=%h | RS1=%0d RD1=%h | RS2=%0d RD2=%h",
                  $time,
                  reg_write,
                  rd,
                  write_data,
                  rs1,
                  read_data1,
                  rs2,
                  read_data2);
    end

    //==================================================
    // Stimulus
    //==================================================

    initial begin

        //------------------------------------------
        // Initialize
        //------------------------------------------

        reg_write  = 0;
        rs1        = 0;
        rs2        = 0;
        rd         = 0;
        write_data = 0;

        //------------------------------------------------
        // Test 1 : x0 always reads zero
        //------------------------------------------------

        #2;

        rs1 = 0;
        rs2 = 0;

        #1;

        if(read_data1 == 32'b0 && read_data2 == 32'b0)
            $display("PASS : x0 is hardwired to zero");
        else
            $display("FAIL : x0");

        //------------------------------------------------
        // Test 2 : Write x5 = 100
        //------------------------------------------------

        rd         = 5;
        write_data = 32'd100;
        reg_write  = 1;

        @(posedge clk);

        #1;

        reg_write = 0;

        rs1 = 5;

        #1;

        if(read_data1 == 32'd100)
            $display("PASS : Write/Read x5");
        else
            $display("FAIL : Write x5");

        //------------------------------------------------
        // Test 3 : Write x10 = 999
        //------------------------------------------------

        rd         = 10;
        write_data = 32'd999;
        reg_write  = 1;

        @(posedge clk);

        #1;

        reg_write = 0;

        rs1 = 10;

        #1;

        if(read_data1 == 32'd999)
            $display("PASS : Write/Read x10");
        else
            $display("FAIL : Write x10");

        //------------------------------------------------
        // Test 4 : Read two registers together
        //------------------------------------------------

        rs1 = 5;
        rs2 = 10;

        #1;

        if(read_data1 == 32'd100 &&
           read_data2 == 32'd999)
            $display("PASS : Dual Read");
        else
            $display("FAIL : Dual Read");

        //------------------------------------------------
        // Test 5 : reg_write = 0 (no write)
        //------------------------------------------------

        rd         = 5;
        write_data = 32'd555;
        reg_write  = 0;

        @(posedge clk);

        rs1 = 5;

        #1;

        if(read_data1 == 32'd100)
            $display("PASS : Write Disabled");
        else
            $display("FAIL : Write Disabled");

        //------------------------------------------------
        // Test 6 : Attempt to write x0
        //------------------------------------------------

        rd         = 0;
        write_data = 32'hFFFFFFFF;
        reg_write  = 1;

        @(posedge clk);

        #1;

        reg_write = 0;

        rs1 = 0;

        #1;

        if(read_data1 == 32'b0)
            $display("PASS : x0 Protected");
        else
            $display("FAIL : x0 Modified");

        //------------------------------------------------
        // Finish
        //------------------------------------------------

        #10;

        $display("---------------------------------------");
        $display("Register File Test Completed");
        $display("---------------------------------------");

        $finish;

    end

endmodule