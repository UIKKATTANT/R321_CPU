`timescale 1ns/1ps

module alu_mux_tb;

reg  [31:0] rs2_data;
reg  [31:0] immediate;
reg         alu_src;

wire [31:0] operand_b;

alu_mux dut(
    .rs2_data(rs2_data),
    .immediate(immediate),
    .alu_src(alu_src),
    .operand_b(operand_b)
);

initial begin
    $dumpfile("alu_mux_tb.vcd");
    $dumpvars(0, alu_mux_tb);
end

initial begin
    $monitor("T=%0t ALU_SRC=%b RS2=%h IMM=%h OPERAND_B=%h",
             $time,
             alu_src,
             rs2_data,
             immediate,
             operand_b);
end

initial begin

//----------------------------------
// Test 1 : Select RS2
//----------------------------------

rs2_data  = 32'h12345678;
immediate = 32'hABCDEF12;
alu_src   = 1'b0;

#5;

if(operand_b == rs2_data)
    $display("PASS : RS2 Selected");
else
    $display("FAIL : RS2 Selected");

//----------------------------------
// Test 2 : Select Immediate
//----------------------------------

alu_src = 1'b1;

#5;

if(operand_b == immediate)
    $display("PASS : Immediate Selected");
else
    $display("FAIL : Immediate Selected");

//----------------------------------
// Test 3 : Change RS2 while IMM selected
//----------------------------------

rs2_data = 32'hFFFFFFFF;

#5;

if(operand_b == immediate)
    $display("PASS : RS2 Ignored");
else
    $display("FAIL : RS2 Ignored");

//----------------------------------
// Test 4 : Change Immediate while selected
//----------------------------------

immediate = 32'h11112222;

#5;

if(operand_b == 32'h11112222)
    $display("PASS : Immediate Updated");
else
    $display("FAIL : Immediate Updated");

//----------------------------------
// Test 5 : Switch back to RS2
//----------------------------------

alu_src = 1'b0;

#5;

if(operand_b == rs2_data)
    $display("PASS : Switched Back to RS2");
else
    $display("FAIL : Switched Back to RS2");

$display("--------------------------------");
$display("ALU MUX TEST COMPLETED");
$display("--------------------------------");

$finish;

end

endmodule