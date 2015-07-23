module multiplier (a, b, product);

    parameter a_width = 8, b_width = 8;
    localparam product_width = b_width;
    input [a_width-1:0] a;
    input [b_width-1:0] b;
    output [product_width-1:0] prod;
    generate
        genvar a;
        input [a_width-1:0] a;
        output signed [31:0] result;
        output reg signed [32:1] sum;
        inout [0:15] data_bus;
        wire a, b, c;
        tri1 [7:0] data_bus;
    endgenerate

endmodule
