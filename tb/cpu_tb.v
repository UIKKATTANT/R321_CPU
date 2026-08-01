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

initial begin
    #100;
    $display("DEBUG: dut.clk = %b", dut.clk);
    #100;
    $display("DEBUG: dut.clk = %b", dut.clk);
    $finish;
end

//----------------------------------------------------
// Clock – this is the CORRECT way
//----------------------------------------------------
initial clk = 0;
always #5 begin
    clk = ~clk;
    $display("CLK_TOGGLE: time=%0t", $time);
end

//----------------------------------------------------
// Waveform dump
//----------------------------------------------------
initial begin
    $dumpfile("cpu_tb.vcd");
    $dumpvars(0, cpu_tb);
end

//----------------------------------------------------
// Monitor
//----------------------------------------------------
initial begin
    $monitor("T=%0t PC=%h INST=%h x1=%0d x2=%0d x3=%0d",
             $time, dut.pc, dut.instruction,
             dut.regfile_inst.registers[1],
             dut.regfile_inst.registers[2],
             dut.regfile_inst.registers[3]);
end

//----------------------------------------------------
// Test + Register dump
//----------------------------------------------------
initial begin
    rst = 1;
    #12;
    rst = 0;

    repeat(500) @(posedge clk);

    //------------------------------------
    // Full Register Dump (all 31 registers)
    //------------------------------------
    $display("=== RTL_REGISTER_DUMP_START ===");
    $display("x1=%0d", dut.regfile_inst.registers[1]);
    $display("x2=%0d", dut.regfile_inst.registers[2]);
    $display("x3=%0d", dut.regfile_inst.registers[3]);
    $display("x4=%0d", dut.regfile_inst.registers[4]);
    $display("x5=%0d", dut.regfile_inst.registers[5]);
    $display("x6=%0d", dut.regfile_inst.registers[6]);
    $display("x7=%0d", dut.regfile_inst.registers[7]);
    $display("x8=%0d", dut.regfile_inst.registers[8]);
    $display("x9=%0d", dut.regfile_inst.registers[9]);
    $display("x10=%0d", dut.regfile_inst.registers[10]);
    $display("x11=%0d", dut.regfile_inst.registers[11]);
    $display("x12=%0d", dut.regfile_inst.registers[12]);
    $display("x13=%0d", dut.regfile_inst.registers[13]);
    $display("x14=%0d", dut.regfile_inst.registers[14]);
    $display("x15=%0d", dut.regfile_inst.registers[15]);
    $display("x16=%0d", dut.regfile_inst.registers[16]);
    $display("x17=%0d", dut.regfile_inst.registers[17]);
    $display("x18=%0d", dut.regfile_inst.registers[18]);
    $display("x19=%0d", dut.regfile_inst.registers[19]);
    $display("x20=%0d", dut.regfile_inst.registers[20]);
    $display("x21=%0d", dut.regfile_inst.registers[21]);
    $display("x22=%0d", dut.regfile_inst.registers[22]);
    $display("x23=%0d", dut.regfile_inst.registers[23]);
    $display("x24=%0d", dut.regfile_inst.registers[24]);
    $display("x25=%0d", dut.regfile_inst.registers[25]);
    $display("x26=%0d", dut.regfile_inst.registers[26]);
    $display("x27=%0d", dut.regfile_inst.registers[27]);
    $display("x28=%0d", dut.regfile_inst.registers[28]);
    $display("x29=%0d", dut.regfile_inst.registers[29]);
    $display("x30=%0d", dut.regfile_inst.registers[30]);
    $display("x31=%0d", dut.regfile_inst.registers[31]);
    $display("=== RTL_REGISTER_DUMP_END ===");

    $finish;
end

endmodule
