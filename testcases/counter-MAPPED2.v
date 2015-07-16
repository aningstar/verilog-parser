
module counter_DW01_inc_0 ( A, SUM );
  input [7:0] A;
  output [7:0] SUM;

  wire   [7:2] carry, temp;

  adhalf_1 U1_1_6 ( .a(A[6]), .b(carry[6]), .co(carry[7]), .s(SUM[6]) );
  adhalf_1 U1_1_1 ( .a(A[1]), .b(A[0]), .co(carry[2]), .s(SUM[1]) );
  adhalf_1 U1_1_2 ( .a(A[2]), .b(carry[2]), .co(carry[3]), .s(SUM[2]) );
  adhalf_1 U1_1_3 ( .a(A[3]), .b(carry[3]), .co(carry[4]), .s(SUM[3]) );
  adhalf_1 U1_1_4 ( .a(A[4]), .b(carry[4]), .co(carry[5]), .s(SUM[4]) );
  adhalf_1 U1_1_5 ( .a(A[5]), .b(carry[5]), .co(carry[6]), .s(SUM[5]) );
  inv_2 U1 ( .a(A[0]), .x(SUM[0]) );
  exor2_1 U2 ( .a(carry[7]), .b(A[7]), .x(SUM[7]) );
endmodule


module counter ( clk, reset, count );
  output [7:0] count;
  input clk, reset;
  wire   N1, N2, N3, N4, N5, N6, N7, N8, n18;
  wire  [7:0] mysum;
   
   
  counter_DW01_inc_0 add_13 ( count, mysum );
  dffpr_2 \count_reg[7]  ( .d(N8), .ck(clk), .rb(n18), .q(count[7]) );
  dffpr_2 \count_reg[4]  ( .d(N5), .ck(clk), .rb(n18), .q(count[4]) );
  dffpr_2 \count_reg[5]  ( .d(N6), .ck(clk), .rb(n18), .q(count[5]) );
  dffpr_2 \count_reg[6]  ( .d(N7), .ck(clk), .rb(n18), .q(count[6]) );
  dffpr_2 \count_reg[2]  ( .d(N3), .ck(clk), .rb(n18), .q(count[2]) );
  dffpr_2 \count_reg[3]  ( .d(N4), .ck(clk), .rb(n18), .q(count[3]) );
  dffpr_2 \count_reg[1]  ( .d(N2), .ck(clk), .rb(n18), .q(count[1]) );
  dffpr_2 \count_reg[0]  ( .d(N1), .ck(clk), .rb(n18), .q(count[0]) );
  inv_2 U4 ( .a(reset), .x(n18) );
endmodule

