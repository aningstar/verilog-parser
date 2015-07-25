module abc (id3, id4);
    task read_mem (input [15:0] address,
        output [31:0] data );
        reg a;
        reg vectored a,b,c;
        reg [7:0] Q [0:3][0:15];
        reg signed [7:0] d1, d2;
    endtask
    task automatic write_mem();
        wire a;
        reg vectored a,b,c;
        reg [7:0] Q [0:3][0:15];
    endtask
    task read_mem;
        input [15:0] address;
        output [31:0] data;
        reg a;
        reg scalared a,b,c;
        reg vectored a,b,c;
        reg [7:0] Q [0:3][0:15];
        reg signed [7:0] d1, d2;
    endtask
endmodule
