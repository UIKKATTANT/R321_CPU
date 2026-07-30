`timescale 1ns/1ps

module instruction_memory_tb;

reg  [31:0] pc;
wire [31:0] instruction;

instruction_memory dut(
    .pc(pc),
    .instruction(instruction)
);

//-------------------------------------------------
// Dump Waveform
//-------------------------------------------------

initial begin
    $dumpfile("instruction_memory_tb.vcd");
    $dumpvars(0, instruction_memory_tb);
end

//-------------------------------------------------
// Monitor
//-------------------------------------------------

initial begin
    $monitor("T=%0t PC=%0d INDEX=%0d INSTRUCTION=%h",
             $time,
             pc,
             pc[31:2],
             instruction);
end

//-------------------------------------------------
// Test Sequence
//-------------------------------------------------

initial begin

    // Preload Instruction Memory
    dut.imem[0] = 32'h00500093; // addi x1,x0,5
    dut.imem[1] = 32'h00A00113; // addi x2,x0,10
    dut.imem[2] = 32'h002081B3; // add x3,x1,x2
    dut.imem[3] = 32'h00302023; // sw x3,0(x0)
    dut.imem[4] = 32'h00002203; // lw x4,0(x0)

    //-------------------------------------------------
    // Test 1 : Address 0
    //-------------------------------------------------

    pc = 32'd0;
    #2;

    if(instruction == 32'h00500093)
        $display("PASS : PC = 0");
    else
        $display("FAIL : PC = 0");

    //-------------------------------------------------
    // Test 2 : Address 4
    //-------------------------------------------------

    pc = 32'd4;
    #2;

    if(instruction == 32'h00A00113)
        $display("PASS : PC = 4");
    else
        $display("FAIL : PC = 4");

    //-------------------------------------------------
    // Test 3 : Address 8
    //-------------------------------------------------

    pc = 32'd8;
    #2;

    if(instruction == 32'h002081B3)
        $display("PASS : PC = 8");
    else
        $display("FAIL : PC = 8");

    //-------------------------------------------------
    // Test 4 : Address 12
    //-------------------------------------------------

    pc = 32'd12;
    #2;

    if(instruction == 32'h00302023)
        $display("PASS : PC = 12");
    else
        $display("FAIL : PC = 12");

    //-------------------------------------------------
    // Test 5 : Address Alignment
    //-------------------------------------------------

    pc = 32'd1;
    #2;

    if(instruction == 32'h00500093)
        $display("PASS : Address 1");

    else
        $display("FAIL : Address 1");

    pc = 32'd2;
    #2;

    if(instruction == 32'h00500093)
        $display("PASS : Address 2");

    else
        $display("FAIL : Address 2");

    pc = 32'd3;
    #2;

    if(instruction == 32'h00500093)
        $display("PASS : Address 3");

    else
        $display("FAIL : Address 3");

    //-------------------------------------------------
    // Test 6 : Address 16
    //-------------------------------------------------

    pc = 32'd16;
    #2;

    if(instruction == 32'h00002203)
        $display("PASS : PC = 16");
    else
        $display("FAIL : PC = 16");

    //-------------------------------------------------
    // Test 7 : Uninitialized Memory
    //-------------------------------------------------

    pc = 32'd20;
    #2;

    $display("INFO : Instruction @20 = %h", instruction);

    //-------------------------------------------------

    $display("--------------------------------");
    $display("INSTRUCTION MEMORY TEST COMPLETED");
    $display("--------------------------------");

    $finish;

end

endmodule