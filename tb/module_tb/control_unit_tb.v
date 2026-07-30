`timescale 1ns/1ps

module control_unit_tb;

reg [6:0] opcode;

wire reg_write;
wire alu_src;
wire mem_read;
wire mem_write;
wire mem_to_reg;
wire branch;
wire jump;
wire jalr;
wire pc_to_reg;
wire [1:0] alu_src_a;

control_unit dut(
    .opcode(opcode),
    .reg_write(reg_write),
    .alu_src(alu_src),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_to_reg(mem_to_reg),
    .branch(branch),
    .jump(jump),
    .jalr(jalr),
    .pc_to_reg(pc_to_reg),
    .alu_src_a(alu_src_a)
);

initial begin
    $dumpfile("control_unit_tb.vcd");
    $dumpvars(0,control_unit_tb);
end

initial begin
    $monitor("T=%0t OPCODE=%b RW=%b AS=%b MR=%b MW=%b M2R=%b BR=%b JMP=%b JALR=%b PC2REG=%b ALU_A=%b",
    $time,opcode,
    reg_write,
    alu_src,
    mem_read,
    mem_write,
    mem_to_reg,
    branch,
    jump,
    jalr,
    pc_to_reg,
    alu_src_a);
end

initial begin

//------------------------------------
// R-Type
//------------------------------------

opcode = 7'b0110011;
#5;

if(reg_write && !alu_src && !mem_read && !mem_write &&
   !mem_to_reg && !branch && !jump && !jalr &&
   !pc_to_reg && alu_src_a==2'b00)
    $display("PASS : R-Type");
else
    $display("FAIL : R-Type");

//------------------------------------
// I-Type
//------------------------------------

opcode = 7'b0010011;
#5;

if(reg_write && alu_src && !mem_read && !mem_write &&
   !mem_to_reg && !branch && !jump && !jalr &&
   !pc_to_reg && alu_src_a==2'b00)
    $display("PASS : I-Type");
else
    $display("FAIL : I-Type");

//------------------------------------
// LW
//------------------------------------

opcode = 7'b0000011;
#5;

if(reg_write && alu_src && mem_read && !mem_write &&
   mem_to_reg && !branch && !jump && !jalr &&
   !pc_to_reg && alu_src_a==2'b00)
    $display("PASS : LW");
else
    $display("FAIL : LW");

//------------------------------------
// SW
//------------------------------------

opcode = 7'b0100011;
#5;

if(!reg_write && alu_src && !mem_read && mem_write &&
   !mem_to_reg && !branch && !jump && !jalr &&
   !pc_to_reg && alu_src_a==2'b00)
    $display("PASS : SW");
else
    $display("FAIL : SW");

//------------------------------------
// Branch
//------------------------------------

opcode = 7'b1100011;
#5;

if(!reg_write && !alu_src && !mem_read && !mem_write &&
   !mem_to_reg && branch && !jump && !jalr &&
   !pc_to_reg && alu_src_a==2'b00)
    $display("PASS : BRANCH");
else
    $display("FAIL : BRANCH");

//------------------------------------
// LUI
//------------------------------------

opcode = 7'b0110111;
#5;

if(reg_write && alu_src && !mem_read && !mem_write &&
   !mem_to_reg && !branch && !jump && !jalr &&
   !pc_to_reg && alu_src_a==2'b10)
    $display("PASS : LUI");
else
    $display("FAIL : LUI");

//------------------------------------
// AUIPC
//------------------------------------

opcode = 7'b0010111;
#5;

if(reg_write && alu_src && !mem_read && !mem_write &&
   !mem_to_reg && !branch && !jump && !jalr &&
   !pc_to_reg && alu_src_a==2'b01)
    $display("PASS : AUIPC");
else
    $display("FAIL : AUIPC");

//------------------------------------
// JAL
//------------------------------------

opcode = 7'b1101111;
#5;

if(reg_write && alu_src && !mem_read && !mem_write &&
   !mem_to_reg && !branch && jump && !jalr &&
   pc_to_reg)
    $display("PASS : JAL");
else
    $display("FAIL : JAL");

//------------------------------------
// JALR
//------------------------------------

opcode = 7'b1100111;
#5;

if(reg_write && alu_src && !mem_read && !mem_write &&
   !mem_to_reg && !branch && !jump && jalr &&
   pc_to_reg && alu_src_a==2'b00)
    $display("PASS : JALR");
else
    $display("FAIL : JALR");

//------------------------------------
// Invalid
//------------------------------------

opcode = 7'b1111111;
#5;

if(!reg_write && !alu_src && !mem_read && !mem_write &&
   !mem_to_reg && !branch && !jump && !jalr &&
   !pc_to_reg && alu_src_a==2'b00)
    $display("PASS : INVALID");
else
    $display("FAIL : INVALID");

$display("--------------------------------");
$display("CONTROL UNIT TEST COMPLETED");
$display("--------------------------------");

$finish;

end

endmodule