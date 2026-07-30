module alu_mux(

    input  [31:0] rs2_data,
    input  [31:0] immediate,

    input         alu_src,

    output [31:0] operand_b

);
assign operand_b = (alu_src) ? immediate : rs2_data;
endmodule