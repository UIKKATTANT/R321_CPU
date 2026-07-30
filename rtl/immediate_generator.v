module immediate_generator (
    input  [31:0] instruction,
    output reg [31:0] immediate
);

wire [6:0] opcode;
assign opcode = instruction[6:0];

always @(*) begin
    // Default output (for R-type or unsupported instructions)
    immediate = 32'b0;

    case (opcode)

        //==================================================
        // I-Type Instructions
        // addi, slti, sltiu, xori, ori, andi
        // slli, srli, srai
        // lb, lh, lw, lbu, lhu
        // jalr
        //==================================================
        7'b0010011, // OP-IMM
        7'b0000011, // LOAD
        7'b1100111: // JALR
        begin
            immediate = {{20{instruction[31]}}, instruction[31:20]};
        end

        //==================================================
        // S-Type Instructions
        // sb, sh, sw
        //==================================================
        7'b0100011:
        begin
            immediate = {{20{instruction[31]}},
                         instruction[31:25],
                         instruction[11:7]};
        end

        //==================================================
        // B-Type Instructions
        // beq, bne, blt, bge, bltu, bgeu
        //==================================================
        7'b1100011:
        begin
            immediate = {{19{instruction[31]}},
                         instruction[31],
                         instruction[7],
                         instruction[30:25],
                         instruction[11:8],
                         1'b0};
        end

        //==================================================
        // U-Type Instructions
        // lui, auipc
        //==================================================
        7'b0110111, // LUI
        7'b0010111: // AUIPC
        begin
            immediate = {instruction[31:12], 12'b0};
        end

        //==================================================
        // J-Type Instructions
        // jal
        //==================================================
        7'b1101111:
        begin
            immediate = {{11{instruction[31]}},
                         instruction[31],
                         instruction[19:12],
                         instruction[20],
                         instruction[30:21],
                         1'b0};
        end

        default:
            immediate = 32'b0;

    endcase
end

endmodule