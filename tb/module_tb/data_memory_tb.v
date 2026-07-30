`timescale 1ns/1ps

module data_memory_tb;

reg         clk;
reg  [31:0] address;
reg  [31:0] write_data;
reg         mem_read;
reg         mem_write;

wire [31:0] read_data;

data_memory dut(
    .clk(clk),
    .address(address),
    .write_data(write_data),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .read_data(read_data)
);

//-------------------------------------------------
// Clock Generation
//-------------------------------------------------

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

//-------------------------------------------------
// Dump Waveform
//-------------------------------------------------

initial begin
    $dumpfile("data_memory_tb.vcd");
    $dumpvars(0,data_memory_tb);
end

//-------------------------------------------------
// Monitor
//-------------------------------------------------

initial begin
    $monitor("T=%0t CLK=%b ADDR=%d WDATA=%d RDATA=%d MR=%b MW=%b",
             $time,
             clk,
             address,
             write_data,
             read_data,
             mem_read,
             mem_write);
end

//-------------------------------------------------
// Test Sequence
//-------------------------------------------------

initial begin

// Initialize
address    = 0;
write_data = 0;
mem_read   = 0;
mem_write  = 0;

//-------------------------------------------------
// Test 1 : Read Disabled
//-------------------------------------------------

#2;

if(read_data == 0)
    $display("PASS : Read Disabled");
else
    $display("FAIL : Read Disabled");

//-------------------------------------------------
// Test 2 : Write Address 100
//-------------------------------------------------

address    = 32'd100;
write_data = 32'd1234;
mem_write  = 1;

@(posedge clk);
#1;

mem_write = 0;

//-------------------------------------------------
// Test 3 : Read Address 100
//-------------------------------------------------

mem_read = 1;
#2;

if(read_data == 32'd1234)
    $display("PASS : Read Address 100");
else
    $display("FAIL : Read Address 100");

mem_read = 0;

//-------------------------------------------------
// Test 4 : Write Address 104
//-------------------------------------------------

address    = 32'd104;
write_data = 32'd999;
mem_write  = 1;

@(posedge clk);
#1;

mem_write = 0;

mem_read = 1;
#2;

if(read_data == 32'd999)
    $display("PASS : Read Address 104");
else
    $display("FAIL : Read Address 104");

mem_read = 0;

//-------------------------------------------------
// Test 5 : Verify Address 100 unchanged
//-------------------------------------------------

address  = 32'd100;
mem_read = 1;

#2;

if(read_data == 32'd1234)
    $display("PASS : Memory Isolation");
else
    $display("FAIL : Memory Isolation");

mem_read = 0;

//-------------------------------------------------
// Test 6 : Write Disabled
//-------------------------------------------------

address    = 32'd100;
write_data = 32'd7777;
mem_write  = 0;

@(posedge clk);

mem_read = 1;
#2;

if(read_data == 32'd1234)
    $display("PASS : Write Disabled");
else
    $display("FAIL : Write Disabled");

mem_read = 0;

//-------------------------------------------------
// Test 7 : Address Alignment
//-------------------------------------------------

address = 32'd101;
mem_read = 1;
#2;

if(read_data == 32'd1234)
    $display("PASS : Address 101");
else
    $display("FAIL : Address 101");

address = 32'd102;
#2;

if(read_data == 32'd1234)
    $display("PASS : Address 102");
else
    $display("FAIL : Address 102");

address = 32'd103;
#2;

if(read_data == 32'd1234)
    $display("PASS : Address 103");
else
    $display("FAIL : Address 103");

mem_read = 0;

//-------------------------------------------------
// Test 8 : Overwrite
//-------------------------------------------------

address    = 32'd100;
write_data = 32'd2222;
mem_write  = 1;

@(posedge clk);
#1;

mem_write = 0;

mem_read = 1;
#2;

if(read_data == 32'd2222)
    $display("PASS : Overwrite");
else
    $display("FAIL : Overwrite");

mem_read = 0;

//-------------------------------------------------
// Test 9 : Read Disabled Again
//-------------------------------------------------

#2;

if(read_data == 0)
    $display("PASS : Read Disabled Again");
else
    $display("FAIL : Read Disabled Again");

$display("--------------------------------");
$display("DATA MEMORY TEST COMPLETED");
$display("--------------------------------");

$finish;

end

endmodule