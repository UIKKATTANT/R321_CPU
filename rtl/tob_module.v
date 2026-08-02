module top_module (
    input clk,
    input rst
);
always @(posedge clk) $display("TOP_CLK_EDGE: time=%0t", $time);
    // ============================================================
    // WIRES
    // ============================================================
    wire [31:0] pc, next_pc, instruction;
    wire [31:0] pc_plus_4, branch_target, jalr_target;

    // Control signals
    wire        reg_write, alu_src, mem_read, mem_write, mem_to_reg;
    wire        branch, jump, jalr, pc_to_reg;
    wire [1:0]  alu_src_a;

    wire [31:0] immediate;
    wire [31:0] rs1_data, rs2_data, write_data;
    wire [3:0]  alu_control;
    reg  [31:0] operand_a;
    wire [31:0] operand_b;
    wire [31:0] alu_result;
    wire        zero;  // kept, but branches use direct comparator
    wire [31:0] memory_read_data;

    // ============================================================
    // PC UPDATE LOGIC
    // ============================================================
    assign pc_plus_4 = pc + 32'd4;
    assign branch_target = pc + immediate;
    assign jalr_target = (rs1_data + immediate) & ~32'b1;

    // -------- Branch condition decoder (based on funct3) --------
    wire [2:0] funct3 = instruction[14:12];
    wire       branch_cond;

    assign branch_cond = (funct3 == 3'b000) ? (rs1_data == rs2_data) :          // beq
                         (funct3 == 3'b001) ? (rs1_data != rs2_data) :          // bne
                         (funct3 == 3'b100) ? ($signed(rs1_data) < $signed(rs2_data)) : // blt
                         (funct3 == 3'b101) ? ($signed(rs1_data) >= $signed(rs2_data)) : // bge
                         (funct3 == 3'b110) ? (rs1_data < rs2_data) :           // bltu
                         (funct3 == 3'b111) ? (rs1_data >= rs2_data) :          // bgeu
                         1'b0;

    wire branch_taken = branch && branch_cond;

    // -------- Next PC selection (priority: JAL > JALR > Branch > PC+4) --------
    assign next_pc = jump        ? branch_target :
                     jalr        ? jalr_target :
                     branch_taken ? branch_target :
                     pc_plus_4;

    // ============================================================
    // ALU OPERAND A MUX
    // ============================================================
    always @(*) begin
        case (alu_src_a)
            2'b00:   operand_a = rs1_data;
            2'b01:   operand_a = pc;
            2'b10:   operand_a = 32'b0;
            default: operand_a = rs1_data;
        endcase
    end

    // ============================================================
    // MODULE INSTANTIATIONS
    // ============================================================

    program_counter pc_inst (
        .clk    (clk),
        .rst    (rst),
        .next_pc(next_pc),
        .pc     (pc)
    );

    instruction_memory imem_inst (
        .pc        (pc),
        .instruction(instruction)
    );

    control_unit ctrl_inst (
        .opcode    (instruction[6:0]),
        .reg_write (reg_write),
        .alu_src   (alu_src),
        .mem_read  (mem_read),
        .mem_write (mem_write),
        .mem_to_reg(mem_to_reg),
        .branch    (branch),
        .jump      (jump),
        .jalr      (jalr),
        .pc_to_reg (pc_to_reg),
        .alu_src_a (alu_src_a)
    );

    immediate_generator imm_inst (
        .instruction(instruction),
        .immediate  (immediate)
    );

    register_file regfile_inst (
        .clk        (clk),
        .rst        (rst),
        .reg_write  (reg_write),
        .rs1        (instruction[19:15]),
        .rs2        (instruction[24:20]),
        .rd         (instruction[11:7]),
        .write_data (write_data),
        .read_data1 (rs1_data),
        .read_data2 (rs2_data)
    );

    alu_control alu_ctrl_inst (
        .opcode     (instruction[6:0]),
        .funct3     (instruction[14:12]),
        .funct7     (instruction[31:25]),
        .alu_control(alu_control)
    );

    alu_mux alu_mux_inst (
        .rs2_data (rs2_data),
        .immediate(immediate),
        .alu_src  (alu_src),
        .operand_b(operand_b)
    );

    alu alu_inst (
        .operand_a  (operand_a),
        .operand_b  (operand_b),
        .alu_control(alu_control),
        .result     (alu_result),
        .zero       (zero)
    );

    data_memory dmem_inst (
        .clk       (clk),
        .address   (alu_result),
        .write_data(rs2_data),
        .mem_read  (mem_read),
        .mem_write (mem_write),
        .read_data (memory_read_data)
    );

    writeback_mux wb_mux_inst (
        .alu_result (alu_result),
        .memory_data(memory_read_data),
        .pc_plus_4  (pc_plus_4),
        .mem_to_reg (mem_to_reg),
        .pc_to_reg  (pc_to_reg),
        .write_data (write_data)
    );

endmodule