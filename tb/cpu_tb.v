`timescale 1ns/1ps

module cpu_tb;

reg clk;
reg rst;

//----------------------------------------------------
// DUT
//----------------------------------------------------

top_module dut(
    .clk(clk),
    .rst(rst)
);

//----------------------------------------------------
// Clock
//----------------------------------------------------

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

//----------------------------------------------------
// Waveform
//----------------------------------------------------

initial begin
    $dumpfile("cpu_tb.vcd");
    $dumpvars(0,cpu_tb);
end

//----------------------------------------------------
// Monitor
//----------------------------------------------------

initial begin

$monitor(
"T=%0t PC=%h INST=%h x1=%0d x2=%0d x3=%0d",
$time,
dut.pc,
dut.instruction,
dut.regfile_inst.registers[1],
dut.regfile_inst.registers[2],
dut.regfile_inst.registers[3]
);

end

//----------------------------------------------------
// Test
//----------------------------------------------------

initial begin

//------------------------------------
// Reset
//------------------------------------

rst = 1;

#12;

rst = 0;

//------------------------------------
// Execute program
//------------------------------------

repeat(6)
    @(posedge clk);

//------------------------------------
// Check Results
//------------------------------------

if (dut.regfile_inst.registers[1] == 12)
    $display("PASS : x1");
else
    $display("FAIL : x1");

if (dut.regfile_inst.registers[2] == 10)
    $display("PASS : x2");
else
    $display("FAIL : x2");

if (dut.regfile_inst.registers[3] == 12 | 10)
    $display("PASS : OR");
else
    $display("FAIL : OR");

$display("---------------------------");
$display("CPU OR TEST COMPLETED");
$display("---------------------------");

$finish;

end

endmodule