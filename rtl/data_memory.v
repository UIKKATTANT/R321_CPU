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
            dmem[address[31:2]] <= write_data;
            $display("DMEM_WRITE: time=%0t addr=%h index=%0d write_data=%0d", $time, address, address[31:2], write_data);
        end
    end

    //=========================
    // Read Logic (Combinational)
    //=========================
    always @(*) begin
        if (mem_read) begin
            read_data = dmem[address[31:2]];
            $display("DMEM_READ: time=%0t addr=%h index=%0d read_data=%0d", $time, address, address[31:2], read_data);
        end else
            read_data = 32'b0;
    end

endmodule