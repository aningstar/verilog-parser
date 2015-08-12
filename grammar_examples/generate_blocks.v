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
        task read_mem (input [15:0] address,
            output [31:0] data );
            reg a;
            reg vectored a,b,c;
            reg [7:0] Q [0:3][0:15];
            reg signed [7:0] d1, d2;
        endtask
        function real multiply;
            input a, b;
            real v,c;
            real a;
        endfunction
        function real multiply;
            input a, b;
        endfunction
    endgenerate

endmodule
