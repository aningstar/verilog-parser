
module counter ( clk, reset, count );
  output [7:0] count;
  input clk, reset;
  wire   n42, n43, n44, N1, N2, N3, N4, N5, N6, N7, N8, n18, n22, n24, n27,
         n29, n31, n32, n33, n35, n36, n38, n40;
  wire   [7:2] \add_13/carry;

  inv_2 U4 ( .a(reset), .x(n18) );
  adhalf_2 \add_13/U1_1_5  ( .a(count[5]), .b(\add_13/carry[5]), .s(N6) );
  dffpr_6 \count_reg[7]  ( .d(N8), .ck(clk), .rb(n18), .q(count[7]), .qb(n27)
         );
  dffpr_3 \count_reg[0]  ( .d(N1), .ck(clk), .rb(n18), .q(n44), .qb(n38) );
  adhalf_2 \add_13/U1_1_4  ( .a(count[4]), .b(n40), .s(N5) );
  dffpr_3 \count_reg[1]  ( .d(N2), .ck(clk), .rb(n18), .q(n43), .qb(n36) );
  exor2_1 \add_13/U1_1_1  ( .a(count[1]), .b(count[0]), .x(N2) );
  adhalf_2 \add_13/U1_1_3  ( .a(count[3]), .b(\add_13/carry[3]), .co(
        \add_13/carry[4]), .s(N4) );
  dffpr_6 \count_reg[6]  ( .d(N7), .ck(clk), .rb(n18), .q(count[6]), .qb(n31)
         );
  dffpr_4 \count_reg[5]  ( .d(N6), .ck(clk), .rb(n18), .q(count[5]), .qb(n22)
         );
  exor2_2 \add_13/U1_1_2  ( .a(count[2]), .b(\add_13/carry[2]), .x(N3) );
  nand2_2 U5 ( .a(count[2]), .b(\add_13/carry[2]), .x(n29) );
  and2_4 U6 ( .a(n43), .b(n44), .x(\add_13/carry[2]) );
  nor2i_2 U7 ( .a(count[3]), .b(n29), .x(n40) );
  inv_4 U8 ( .a(n33), .x(\add_13/carry[5]) );
  inv_6 U9 ( .a(n35), .x(\add_13/carry[3]) );
  nand4i_2 U10 ( .a(n31), .b(\add_13/carry[4]), .c(count[5]), .d(count[4]),
        .x(n32) );
  buf_3 U11 ( .a(n42), .x(count[2]) );
  nand3_2 U12 ( .a(n42), .b(n43), .c(n44), .x(n35) );
  nand4i_1 U13 ( .a(n22), .b(\add_13/carry[3]), .c(count[4]), .d(count[3]),
        .x(n24) );
  exnor2_2 U14 ( .a(count[6]), .b(n24), .x(N7) );
  exor2_2 U15 ( .a(n32), .b(n27), .x(N8) );
  nand4_1 U16 ( .a(count[4]), .b(count[3]), .c(count[2]), .d(\add_13/carry[2]), .x(n33) );
  inv_2 U17 ( .a(n36), .x(count[1]) );
  inv_2 U18 ( .a(n38), .x(count[0]) );
  inv_0 U19 ( .a(count[0]), .x(N1) );
  dffpr_1 \count_reg[3]  ( .d(N4), .ck(clk), .rb(n18), .q(count[3]) );
  dffpr_1 \count_reg[2]  ( .d(N3), .ck(clk), .rb(n18), .q(n42) );
  dffpr_1 \count_reg[4]  ( .d(N5), .ck(clk), .rb(n18), .q(count[4]) );
endmodule

