`timescale 1ns/1ps

module alu_tb;

    //==================================================
    // Testbench Signals
    //==================================================

    reg  [31:0] operand_a;
    reg  [31:0] operand_b;
    reg  [3:0]  alu_control;

    wire [31:0] result;
    wire        zero;

    //==================================================
    // DUT
    //==================================================

    alu dut(
        .operand_a(operand_a),
        .operand_b(operand_b),
        .alu_control(alu_control),
        .result(result),
        .zero(zero)
    );

    //==================================================
    // Dump Waves
    //==================================================

    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);
    end

    //==================================================
    // Monitor
    //==================================================

    initial begin
        $monitor("T=%0t CTRL=%b A=%h B=%h RESULT=%h ZERO=%b",
                 $time,
                 alu_control,
                 operand_a,
                 operand_b,
                 result,
                 zero);
    end

    //==================================================
    // Test Sequence
    //==================================================

    initial begin

    //---------------- ADD ----------------
    operand_a   = 20;
    operand_b   = 30;
    alu_control = 4'b0000;
    #5;

    if(result == 50)
        $display("PASS : ADD");
    else
        $display("FAIL : ADD");

    //---------------- SUB ----------------
    operand_a   = 30;
    operand_b   = 20;
    alu_control = 4'b0001;
    #5;

    if(result == 10)
        $display("PASS : SUB");
    else
        $display("FAIL : SUB");

    //---------------- AND ----------------
    operand_a   = 32'hF0F0F0F0;
    operand_b   = 32'hFFFF0000;
    alu_control = 4'b0010;
    #5;

    if(result == 32'hF0F00000)
        $display("PASS : AND");
    else
        $display("FAIL : AND");

    //---------------- OR ----------------
    operand_a   = 32'hF0F00000;
    operand_b   = 32'h0000FFFF;
    alu_control = 4'b0011;
    #5;

    if(result == 32'hF0F0FFFF)
        $display("PASS : OR");
    else
        $display("FAIL : OR");

    //---------------- XOR ----------------
    operand_a   = 32'hAAAAAAAA;
    operand_b   = 32'h55555555;
    alu_control = 4'b0100;
    #5;

    if(result == 32'hFFFFFFFF)
        $display("PASS : XOR");
    else
        $display("FAIL : XOR");

    //---------------- SLL ----------------
    operand_a   = 32'h00000001;
    operand_b   = 5;
    alu_control = 4'b0101;
    #5;

    if(result == 32'h00000020)
        $display("PASS : SLL");
    else
        $display("FAIL : SLL");

    //---------------- SRL ----------------
    operand_a   = 32'h80000000;
    operand_b   = 4;
    alu_control = 4'b0110;
    #5;

    if(result == 32'h08000000)
        $display("PASS : SRL");
    else
        $display("FAIL : SRL");

    //---------------- SRA ----------------
    operand_a   = 32'h80000000;
    operand_b   = 4;
    alu_control = 4'b0111;
    #5;

    if(result == 32'hF8000000)
        $display("PASS : SRA");
    else
        $display("FAIL : SRA");

    //---------------- SLT ----------------
    operand_a   = -5;
    operand_b   = 10;
    alu_control = 4'b1000;
    #5;

    if(result == 1)
        $display("PASS : SLT");
    else
        $display("FAIL : SLT");

    //---------------- SLTU ----------------
    operand_a   = 32'hFFFFFFFF;
    operand_b   = 32'h00000001;
    alu_control = 4'b1001;
    #5;

    if(result == 0)
        $display("PASS : SLTU");
    else
        $display("FAIL : SLTU");

    //---------------- ZERO FLAG ----------------
    operand_a   = 55;
    operand_b   = 55;
    alu_control = 4'b0001;
    #5;

    if(result == 0 && zero)
        $display("PASS : ZERO FLAG");
    else
        $display("FAIL : ZERO FLAG");

    //---------------- DEFAULT ----------------
    operand_a   = 10;
    operand_b   = 20;
    alu_control = 4'b1111;
    #5;

    if(result == 0)
        $display("PASS : DEFAULT");
    else
        $display("FAIL : DEFAULT");

    //-------------------------------------
    $display("--------------------------------");
    $display("ALU TEST COMPLETED");
    $display("--------------------------------");

    $finish;

    end

endmodule