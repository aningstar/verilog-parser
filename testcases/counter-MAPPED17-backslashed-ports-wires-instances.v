
module counter_DW01_inc_0 (A,SUM);
  input [7:0] A;
  output [7:0] SUM;

  wire   [7:2] carry;

  adhalf_1 U1_1_6 ( .a(A[6]), .b(carry[6]), .co(carry[7]), .s(SUM[6]) );
  adhalf_1 U1_1_1 ( .a(A[1]), .b(A[0]), .co(carry[2]), .s(SUM[1]) );
  adhalf_1 U1_1_2 ( .a(A[2]), .b(carry[2]), .co(carry[3]), .s(SUM[2]) );
  adhalf_1 U1_1_3 ( .a(A[3]), .b(carry[3]), .co(carry[4]), .s(SUM[3]) );
  adhalf_1 U1_1_4 ( .a(A[4]), .b(carry[4]), .co(carry[5]), .s(SUM[4]) );
  adhalf_1 U1_1_5 ( .a(A[5]), .b(carry[5]), .co(carry[6]), .s(SUM[5]) );
  inv_2 U1 ( .a(A[0]), .x(SUM[0]) );
  exor2_1 U2 ( .a(carry[7]), .b(A[7]), .x(SUM[7]) );
endmodule


module counter ( \clk[0], \reset[1], count );
  output [7:0] count;
  input \clk[0] , \reset[1];
   wire [5:3] internal;   
  wire   \N1[0], \N2[0], \N3[0], \N7[0], \N8[0], n18;

  counter_DW01_inc_0 add_13 ( .A(count), .SUM ( { 
			     \N8[0], \N7[0], internal[5:3], \N3[0], \N2[0], \N1[0] } ) );
  dffpr_2 \count_reg[7]  ( .d(\N8[0]), .ck(\clk[0]), .rb(n18), .q(count[7]) );
  dffpr_2 \count_reg[4]  ( .d(internal[4]), .ck(\clk[0]), .rb(n18), .q(count[4]) );
  dffpr_2 \count_reg[5]  ( .d(internal[5]), .ck(\clk[0]), .rb(n18), .q(count[5]) );
  dffpr_2 \count_reg[6]  ( .d(\N7[0]), .ck(\clk[0]), .rb(n18), .q(count[6]) );
  dffpr_2 \count_reg[2]  ( .d(\N3[0]), .ck(\clk[0]), .rb(n18), .q(count[2]) );
  dffpr_2 \count_reg[3]  ( .d(internal[3]), .ck(\clk[0]), .rb(n18), .q(count[3]) );
  dffpr_2 \count_reg[1]  ( .d(\N2[0]), .ck(\clk[0]), .rb(n18), .q(count[1]) );
  dffpr_2 \count_reg[0]  ( .d(\N1[0]), .ck(\clk[0]), .rb(n18), .q(count[0]) );
  inv_2 U4 ( .a(\reset[1]), .x(n18) );
endmodule

