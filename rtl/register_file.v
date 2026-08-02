module register_file(
    input         clk,
    input         rst,
    input         reg_write,

    input  [4:0]  rs1,
    input  [4:0]  rs2,
    input  [4:0]  rd,

    input  [31:0] write_data,

    output [31:0] read_data1,
    output [31:0] read_data2
);

reg [31:0] registers [0:31];

integer i;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] <= 32'b0;
    end else begin
    $display("REG_CLK: time=%0t", $time);
    $display("CLK_EDGE: time=%0t", $time);
    $display("RF_DEBUG: time=%0t reg_write=%0d rd=%0d write_data=%0d", $time, reg_write, rd, write_data);
    if (reg_write) $display("RF_WRITE: time=%0t rd=%0d write_data=%0d", $time, rd, write_data);
    if (reg_write && rd != 5'b0) begin
        registers[rd] <= write_data;
        $display("REG WRITE: time=%0t rd=%0d write_data=%0d", $time, rd, write_data);
    end
    end
end

assign read_data1 = (rs1 == 0) ? 32'b0 : registers[rs1];
assign read_data2 = (rs2 == 0) ? 32'b0 : registers[rs2];

endmodule
