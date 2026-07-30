module instruction_memory(

    input  [31:0] pc,
    output [31:0] instruction

);

reg [31:0] imem [0:255];

assign instruction = imem[pc[31:2]];

integer i;
initial begin

    
    for(i=0; i<256; i=i+1)
        imem[i] = 32'h00000013;

imem[0] = 32'h00C00093;   // addi x1,x0,12
imem[1] = 32'h00A00113;   // addi x2,x0,10
imem[2] = 32'h0020E1B3;   // or x3,x1,x2
imem[3] = 32'h00000013;   // nop
end

endmodule