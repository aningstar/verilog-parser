module abc (id3, id4);
input signed [2:WORD] id3;
input signed [WORD:1] id3;
output  signed id4;
input a,b,sel;
input signed [15:0] a, b;
output signed [31:0] result;
output reg signed [32:1] sum;
inout [0:15] data_bus;
input [15:12] addr;
//parameter WORD = 32;
input [WORD-1:0] addr;
//parameter SIZE = 4096;
input [log2(SIZE)-1:0] addr;

endmodule
