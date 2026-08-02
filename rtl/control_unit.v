module control_unit (
    input  [6:0] opcode,
    output reg reg_write,
    output reg alu_src,
    output reg mem_read,
    output reg mem_write,
    output reg mem_to_reg,
    output reg branch,
    output reg jump,        // for JAL
    output reg jalr,        // for JALR
    output reg pc_to_reg,   // for writeback: PC+4
    output reg [1:0] alu_src_a // 00: rs1, 01: PC, 10: 0, 11: unused
);

always @(*) begin
    // defaults
    reg_write = 0;
    alu_src   = 0;
    mem_read  = 0;
    mem_write = 0;
    mem_to_reg= 0;
    branch    = 0;
    jump      = 0;
    jalr      = 0;
    pc_to_reg = 0;
    alu_src_a = 2'b00;

    case(opcode)
        7'b0110011: begin // R-type
            reg_write = 1;
            alu_src   = 0;
            mem_read  = 0;
            mem_write = 0;
            mem_to_reg= 0;
            branch    = 0;
            jump      = 0;
            jalr      = 0;
            pc_to_reg = 0;
            alu_src_a = 2'b00; // rs1_data
        end
        7'b0010011: begin // I-type ALU
            reg_write = 1;
            alu_src   = 1;
            mem_read  = 0;
            mem_write = 0;
            mem_to_reg= 0;
            branch    = 0;
            jump      = 0;
            jalr      = 0;
            pc_to_reg = 0;
            alu_src_a = 2'b00; // rs1_data
        end
        7'b0000011: begin // Load
        $display("CONTROL: lw detected, reg_write=%0d", reg_write);
            reg_write = 1;
            alu_src   = 1;
            mem_read  = 1;
            mem_write = 0;
            mem_to_reg= 1;
            branch    = 0;
            jump      = 0;
            jalr      = 0;
            pc_to_reg = 0;
            alu_src_a = 2'b00; // rs1_data
        end
        7'b0100011: begin // Store
            reg_write = 0;
            alu_src   = 1;
            mem_read  = 0;
            mem_write = 1;
            mem_to_reg= 0;
            branch    = 0;
            jump      = 0;
            jalr      = 0;
            pc_to_reg = 0;
            alu_src_a = 2'b00; // rs1_data
        end
        7'b1100011: begin // Branch
            reg_write = 0;
            alu_src   = 0;
            mem_read  = 0;
            mem_write = 0;
            mem_to_reg= 0;
            branch    = 1;
            jump      = 0;
            jalr      = 0;
            pc_to_reg = 0;
            alu_src_a = 2'b00; // rs1_data (for comparison)
        end
        7'b0110111: begin // LUI
            reg_write = 1;
            alu_src   = 1;
            mem_read  = 0;
            mem_write = 0;
            mem_to_reg= 0;
            branch    = 0;
            jump      = 0;
            jalr      = 0;
            pc_to_reg = 0;
            alu_src_a = 2'b10; // 0
        end
        7'b0010111: begin // AUIPC
            reg_write = 1;
            alu_src   = 1;
            mem_read  = 0;
            mem_write = 0;
            mem_to_reg= 0;
            branch    = 0;
            jump      = 0;
            jalr      = 0;
            pc_to_reg = 0;
            alu_src_a = 2'b01; // PC
        end
        7'b1101111: begin // JAL
            reg_write = 1;
            alu_src   = 1; // not used for ALU result, but immediate for target
            mem_read  = 0;
            mem_write = 0;
            mem_to_reg= 0;
            branch    = 0;
            jump      = 1;
            jalr      = 0;
            pc_to_reg = 1;
            alu_src_a = 2'b00; // don't care
        end
        7'b1100111: begin // JALR
            reg_write = 1;
            alu_src   = 1;
            mem_read  = 0;
            mem_write = 0;
            mem_to_reg= 0;
            branch    = 0;
            jump      = 0;
            jalr      = 1;
            pc_to_reg = 1;
            alu_src_a = 2'b00; // rs1_data
        end
        default: ;
    endcase
    $display("CTRL_FINAL: opcode=%b reg_write=%0d", opcode, reg_write);
end
endmodule