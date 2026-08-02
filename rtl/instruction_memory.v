module instruction_memory(

    input  [31:0] pc,
    output [31:0] instruction

);

reg [31:0] imem [0:255];

assign instruction = imem[(pc - 32'h80000000) >> 2];
initial begin
    $readmemh("program.hex", imem);
end
endmodule