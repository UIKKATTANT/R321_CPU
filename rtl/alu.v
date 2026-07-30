module alu (
    input [31:0] operand_a,
    input [31:0] operand_b,
    input [3:0] alu_control,
    output reg [31:0] result,
    output     zero
);

always@(*)begin
    result = 32'b0;
    case(alu_control)
    4'b0000 : result = (operand_a + operand_b); // add
    4'b0001 : result = (operand_a - operand_b); // sub
    4'b0010 : result = (operand_a & operand_b); // and
    4'b0011 : result = (operand_a | operand_b); // or
    4'b0100 : result = (operand_a ^ operand_b); // xor
    4'b0101 : result = (operand_a << operand_b[4:0]); // sll
    4'b0110 : result = (operand_a >> operand_b[4:0]); // srl
    4'b0111 : result = ($signed(operand_a) >>> operand_b[4:0]); // sra
    4'b1000 : result = ($signed(operand_a) < $signed(operand_b)) ? 32'b1 : 32'b0; // slt
    4'b1001 : result = (operand_a < operand_b) ? 32'b1 : 32'b0; // sltu
    default : result = 32'b0;
    endcase
end

assign zero =(result == 32'b0);

endmodule