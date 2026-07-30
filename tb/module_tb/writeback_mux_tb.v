`timescale 1ns/1ps

module writeback_mux_tb;

reg [31:0] alu_result;
reg [31:0] memory_data;
reg [31:0] pc_plus_4;

reg mem_to_reg;
reg pc_to_reg;

wire [31:0] write_data;

writeback_mux dut(
    .alu_result(alu_result),
    .memory_data(memory_data),
    .pc_plus_4(pc_plus_4),
    .mem_to_reg(mem_to_reg),
    .pc_to_reg(pc_to_reg),
    .write_data(write_data)
);

initial begin
    $dumpfile("writeback_mux_tb.vcd");
    $dumpvars(0,writeback_mux_tb);
end

initial begin
    $monitor("T=%0t M2R=%b PC2REG=%b ALU=%h MEM=%h PC4=%h WRITE=%h",
        $time,
        mem_to_reg,
        pc_to_reg,
        alu_result,
        memory_data,
        pc_plus_4,
        write_data);
end

initial begin

//------------------------------------
// Test 1 : ALU Result
//------------------------------------

alu_result  = 32'h12345678;
memory_data = 32'hAAAAAAAA;
pc_plus_4   = 32'h00000004;

mem_to_reg = 0;
pc_to_reg  = 0;

#5;

if(write_data == alu_result)
    $display("PASS : ALU Result");
else
    $display("FAIL : ALU Result");

//------------------------------------
// Test 2 : Memory Data
//------------------------------------

mem_to_reg = 1;
pc_to_reg  = 0;

#5;

if(write_data == memory_data)
    $display("PASS : Memory Data");
else
    $display("FAIL : Memory Data");

//------------------------------------
// Test 3 : PC + 4
//------------------------------------

mem_to_reg = 0;
pc_to_reg  = 1;

#5;

if(write_data == pc_plus_4)
    $display("PASS : PC+4");
else
    $display("FAIL : PC+4");

//------------------------------------
// Test 4 : Priority Check
// pc_to_reg should override mem_to_reg
//------------------------------------

mem_to_reg = 1;
pc_to_reg  = 1;

#5;

if(write_data == pc_plus_4)
    $display("PASS : Priority");
else
    $display("FAIL : Priority");

//------------------------------------
// Test 5 : Update PC+4
//------------------------------------

pc_plus_4 = 32'h00000104;

#5;

if(write_data == 32'h00000104)
    $display("PASS : PC+4 Update");
else
    $display("FAIL : PC+4 Update");

//------------------------------------
// Test 6 : Return to Memory
//------------------------------------

pc_to_reg = 0;

#5;

if(write_data == memory_data)
    $display("PASS : Return to Memory");
else
    $display("FAIL : Return to Memory");

//------------------------------------
// Test 7 : Return to ALU
//------------------------------------

mem_to_reg = 0;

#5;

if(write_data == alu_result)
    $display("PASS : Return to ALU");
else
    $display("FAIL : Return to ALU");

$display("--------------------------------");
$display("WRITEBACK MUX TEST COMPLETED");
$display("--------------------------------");

$finish;

end

endmodule