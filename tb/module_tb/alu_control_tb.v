`timescale 1ns/1ps

module alu_control_tb;

    reg  [6:0] opcode;
    reg  [2:0] funct3;
    reg  [6:0] funct7;

    wire [3:0] alu_control;

    alu_control dut(
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .alu_control(alu_control)
    );

    initial begin
        $dumpfile("alu_control_tb.vcd");
        $dumpvars(0, alu_control_tb);
    end

    initial begin
        $monitor("T=%0t OPCODE=%b FUNCT3=%b FUNCT7=%b ALUCTRL=%b",
                 $time, opcode, funct3, funct7, alu_control);
    end

    initial begin

    //-------------------------
    // R-Type
    //-------------------------

    opcode=7'b0110011;

    // ADD
    funct7=7'b0000000; funct3=3'b000; #5;
    if(alu_control==4'b0000) $display("PASS : ADD");
    else $display("FAIL : ADD");

    // SUB
    funct7=7'b0100000; funct3=3'b000; #5;
    if(alu_control==4'b0001) $display("PASS : SUB");
    else $display("FAIL : SUB");

    // AND
    funct7=7'b0000000; funct3=3'b111; #5;
    if(alu_control==4'b0010) $display("PASS : AND");
    else $display("FAIL : AND");

    // OR
    funct7=7'b0000000; funct3=3'b110; #5;
    if(alu_control==4'b0011) $display("PASS : OR");
    else $display("FAIL : OR");

    // XOR
    funct7=7'b0000000; funct3=3'b100; #5;
    if(alu_control==4'b0100) $display("PASS : XOR");
    else $display("FAIL : XOR");

    // SLL
    funct7=7'b0000000; funct3=3'b001; #5;
    if(alu_control==4'b0101) $display("PASS : SLL");
    else $display("FAIL : SLL");

    // SRL
    funct7=7'b0000000; funct3=3'b101; #5;
    if(alu_control==4'b0110) $display("PASS : SRL");
    else $display("FAIL : SRL");

    // SRA
    funct7=7'b0100000; funct3=3'b101; #5;
    if(alu_control==4'b0111) $display("PASS : SRA");
    else $display("FAIL : SRA");

    // SLT
    funct7=7'b0000000; funct3=3'b010; #5;
    if(alu_control==4'b1000) $display("PASS : SLT");
    else $display("FAIL : SLT");

    // SLTU
    funct7=7'b0000000; funct3=3'b011; #5;
    if(alu_control==4'b1001) $display("PASS : SLTU");
    else $display("FAIL : SLTU");

    //-------------------------
    // I-Type
    //-------------------------

    opcode=7'b0010011;

    funct3=3'b000; funct7=0; #5;
    if(alu_control==4'b0000) $display("PASS : ADDI");

    funct3=3'b111; funct7=0; #5;
    if(alu_control==4'b0010) $display("PASS : ANDI");

    funct3=3'b110; funct7=0; #5;
    if(alu_control==4'b0011) $display("PASS : ORI");

    funct3=3'b100; funct7=0; #5;
    if(alu_control==4'b0100) $display("PASS : XORI");

    funct3=3'b010; funct7=0; #5;
    if(alu_control==4'b1000) $display("PASS : SLTI");

    funct3=3'b011; funct7=0; #5;
    if(alu_control==4'b1001) $display("PASS : SLTIU");

    funct3=3'b001; funct7=7'b0000000; #5;
    if(alu_control==4'b0101) $display("PASS : SLLI");

    funct3=3'b101; funct7=7'b0000000; #5;
    if(alu_control==4'b0110) $display("PASS : SRLI");

    funct3=3'b101; funct7=7'b0100000; #5;
    if(alu_control==4'b0111) $display("PASS : SRAI");

    //-------------------------
    // LW
    //-------------------------

    opcode=7'b0000011;
    #5;
    if(alu_control==4'b0000)
        $display("PASS : LW");

    //-------------------------
    // SW
    //-------------------------

    opcode=7'b0100011;
    #5;
    if(alu_control==4'b0000)
        $display("PASS : SW");

    //-------------------------
    // Branch
    //-------------------------

    opcode=7'b1100011;

    funct3=3'b000; #5;
    if(alu_control==4'b0001)
        $display("PASS : BEQ");

    funct3=3'b001; #5;
    if(alu_control==4'b0001)
        $display("PASS : BNE");

    funct3=3'b100; #5;
    if(alu_control==4'b1000)
        $display("PASS : BLT");

    funct3=3'b101; #5;
    if(alu_control==4'b1000)
        $display("PASS : BGE");

    funct3=3'b110; #5;
    if(alu_control==4'b1001)
        $display("PASS : BLTU");

    funct3=3'b111; #5;
    if(alu_control==4'b1001)
        $display("PASS : BGEU");

    //-------------------------
    // Invalid opcode
    //-------------------------

    opcode=7'b1111111;
    #5;

    if(alu_control==4'b1111)
        $display("PASS : INVALID OPCODE");

    $display("----------------------------");
    $display("ALU CONTROL TEST COMPLETED");
    $display("----------------------------");

    $finish;

    end

endmodule