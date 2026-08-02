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
        if (mem_write)
            emem[[1:]
===
 Logic (Combinational)
        if (mem_read)
            read_data = dmem[address[31:2]];
        else
            read_data = 32'b0;
    end
[31:2]]