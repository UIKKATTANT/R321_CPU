module data_memory(

    input clk,

    input [31:0] address,
    input [31:0] write_data,

    input mem_read,
    input mem_write,

    output reg [31:0] read_data

);

    // 256 words × 32 bits
    reg [31:0] dmem [0:255];

    //=========================
    // Write Logic (Sequential)
    //=========================
    always @(posedge clk) begin
        if (mem_write) begin
            integer idx_w;
            idx_w = (address - 32'h80000000) >> 2;
            dmem[idx_w] <= write_data;
            $display("DMEM_WRITE: time=%0t addr=%h index=%0d write_data=%0d", $time, address, idx_w, write_data);
        end
    end

    //=========================
    // Read Logic (Combinational)
    //=========================
    always @(*) begin
        if (mem_read) begin
            integer idx_r;
            idx_r = (address - 32'h80000000) >> 2;
            read_data = dmem[idx_r];
            $display("DMEM_READ: time=%0t addr=%h index=%0d read_data=%0d", $time, address, idx_r, read_data);
        end else
            read_data = 32'b0;
    end

endmodule