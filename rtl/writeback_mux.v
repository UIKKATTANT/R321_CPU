module writeback_mux(
    input [31:0] alu_result,
    input [31:0] memory_data,
    input [31:0] pc_plus_4,
    input mem_to_reg,
    input pc_to_reg,
    output [31:0] write_data
);
assign write_data = pc_to_reg ? pc_plus_4 :
                    mem_to_reg ? memory_data :
                    alu_result;
endmodule