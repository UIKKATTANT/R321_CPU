`timescale 1ns/1ps

module immediate_generator_tb;

    //==================================================
    // Testbench Signals
    //==================================================

    reg  [31:0] instruction;
    wire [31:0] immediate;

    //==================================================
    // DUT
    //==================================================

    immediate_generator dut (
        .instruction(instruction),
        .immediate(immediate)
    );

    //==================================================
    // Waveform Dump
    //==================================================

    initial begin
        $dumpfile("immediate_generator_tb.vcd");
        $dumpvars(0, immediate_generator_tb);
    end

    //==================================================
    // Monitor
    //==================================================

    initial begin
        $monitor("T=%0t Instruction=%h Immediate=%h",
                  $time, instruction, immediate);
    end

    //==================================================
    // Test Sequence
    //==================================================

    initial begin

    //--------------------------------------------------
    // Test 1 : I-Type (addi x1,x2,15)
    //--------------------------------------------------

    instruction = {12'd15,5'd2,3'b000,5'd1,7'b0010011};

    #5;

    if(immediate == 32'd15)
        $display("PASS : I-Type Positive");
    else
        $display("FAIL : I-Type Positive");


    //--------------------------------------------------
    // Test 2 : I-Type Negative (-1)
    //--------------------------------------------------

    instruction = {12'hFFF,5'd2,3'b000,5'd1,7'b0010011};

    #5;

    if(immediate == 32'hFFFFFFFF)
        $display("PASS : I-Type Negative");
    else
        $display("FAIL : I-Type Negative");


    //--------------------------------------------------
    // Test 3 : S-Type (sw x5,-8(x2))
    //--------------------------------------------------

    instruction =
    {
        7'b1111111,      // imm[11:5]
        5'd5,            // rs2
        5'd2,            // rs1
        3'b010,
        5'b11000,        // imm[4:0]
        7'b0100011
    };

    #5;

    if(immediate == 32'hFFFFFFF8)
        $display("PASS : S-Type");
    else
        $display("FAIL : S-Type");


    //--------------------------------------------------
    // Test 4 : B-Type (+16)
    //--------------------------------------------------

    instruction =
    {
        1'b0,            // imm12
        6'b000000,
        5'd2,
        5'd1,
        3'b000,
        4'b1000,
        1'b0,
        7'b1100011
    };

    #5;

    if(immediate == 32'd16)
        $display("PASS : B-Type Positive");
    else
        $display("FAIL : B-Type Positive");


    //--------------------------------------------------
    // Test 5 : J-Type (+32)
    //--------------------------------------------------

    instruction =
    {
        1'b0,
        10'b0000010000,
        1'b0,
        8'b00000000,
        5'd1,
        7'b1101111
    };

    #5;

    if(immediate == 32'd32)
        $display("PASS : J-Type");
    else
        $display("FAIL : J-Type");


    //--------------------------------------------------
    // Test 6 : Invalid Opcode
    //--------------------------------------------------

    instruction = 32'hFFFFFFFF;

    #5;

    if(immediate == 32'b0)
        $display("PASS : Invalid Opcode");
    else
        $display("FAIL : Invalid Opcode");


    //--------------------------------------------------
    // Finish
    //--------------------------------------------------

    #10;

    $display("--------------------------------------");
    $display("Immediate Generator Test Completed");
    $display("--------------------------------------");

    $finish;

    end

endmodule