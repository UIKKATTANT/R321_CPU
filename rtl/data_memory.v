module data_memory(

    input clk,

    input [31:0] address,
    input [31:0] write_data,

    input mem_read,
    input mem_write,

    output reg [31:0] read_data

);

    // 256 words x 32 bits
    reg [31:0] dmem [0:255];
    wire [7:0] mem_index = (address - 32'h80000000) >> 2;

    integer i;

    initial begin
        for (i = 0; i < 256; i = i + 1)
            dmem[i] = 32'b0;
    end

    //=========================
    // Write Logic (Sequential)
    //=========================
    always @(posedge clk) begin
        if (mem_write)
            dmem[mem_index] <= write_data;
    end

    //=========================
    // Read Logic (Combinational)
    //=========================
    always @(*) begin
        if (mem_read)
            read_data = dmem[mem_index];
        else
            read_data = 32'b0;
    end

endmodule
