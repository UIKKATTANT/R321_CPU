module alu_control (
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg [3:0] alu_control
);
always @(*) begin
    alu_control = 4'b0000; // default ADD (for LUI, AUIPC, JAL, JALR)
    case(opcode)
        7'b0110011: begin // R-type
            case({funct7, funct3})
                10'b0000000000: alu_control = 4'b0000; // add
                10'b0100000000: alu_control = 4'b0001; // sub
                10'b0000000111: alu_control = 4'b0010; // and
                10'b0000000110: alu_control = 4'b0011; // or
                10'b0000000100: alu_control = 4'b0100; // xor
                10'b0000000001: alu_control = 4'b0101; // sll
                10'b0000000101: alu_control = 4'b0110; // srl
                10'b0100000101: alu_control = 4'b0111; // sra
                10'b0000000010: alu_control = 4'b1000; // slt
                10'b0000000011: alu_control = 4'b1001; // sltu
                default: alu_control = 4'b1111;
            endcase
        end
        7'b0010011: begin // I-type ALU
            case(funct3)
                3'b000: alu_control = 4'b0000; // addi
                3'b111: alu_control = 4'b0010; // andi
                3'b110: alu_control = 4'b0011; // ori
                3'b100: alu_control = 4'b0100; // xori
                3'b010: alu_control = 4'b1000; // slti
                3'b011: alu_control = 4'b1001; // sltiu
                3'b001: begin
                    if(funct7 == 7'b0000000) alu_control = 4'b0101; // slli
                    else alu_control = 4'b1111;
                end
                3'b101: begin
                    if(funct7 == 7'b0000000) alu_control = 4'b0110; // srli
                    else if(funct7 == 7'b0100000) alu_control = 4'b0111; // srai
                    else alu_control = 4'b1111;
                end
                default: alu_control = 4'b1111;
            endcase
        end
        7'b0000011: // Load
            alu_control = 4'b0000;
        7'b0100011: // Store
            alu_control = 4'b0000;
        7'b1100011: // Branch
            case(funct3)
                3'b000, 3'b001: alu_control = 4'b0001; // beq/bne (sub)
                3'b100, 3'b101: alu_control = 4'b1000; // blt/bge (slt)
                3'b110, 3'b111: alu_control = 4'b1001; // bltu/bgeu (sltu)
                default: alu_control = 4'b1111;
            endcase
        7'b0110111, 7'b0010111, 7'b1101111, 7'b1100111: // LUI, AUIPC, JAL, JALR
            alu_control = 4'b0000; // ADD
        default:
            alu_control = 4'b1111;
    endcase
end
endmodule