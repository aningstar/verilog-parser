module abc (id3, id4);

wire (strong1,pull0) [0:15] sum = a + b;
wire (strong0,pull1) [0:15] #(1,1) sum = a + b;
trireg (small) #(0,0,35) ram_bit;
wire a, b, c;
tri1 [7:0] data_bus;
wire signed [1:8] result;
wire [7:0] Q [0:15][0:256];
wire #(2.4,1.8) carry;

assign mux_out = a + b;
//tri [0:15] #2.8 buf_out = a + b;

endmodule
