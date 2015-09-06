
module counter ( clk, reset, count);
  output [7:0] count;
  input clk, reset;
  wire   n42, n43, n44, N1, N2, N3, N4, N5, N6, N7, N8, n18, n22, n24, n27,
         n29, n31, n32, n33, n35, n36, n38, n40;
  wire   [7:2] \add_13/carry ;

   mymux4 mux ( .mux_sel(mux_sel), .out(out), .in(
						  {net15, net18, net25, net32}) );

   mymux4 mux2 ( .mux_sel(mux_sel), .out(out), .in({
						    net3, net5, net10, net20}) );

   inv_2 U4 ( .a(reset),
	     .x(n18) );

   adhalf_2 \add_13/U1_1_3  ( .a(count[3]), .b(\add_13/carry[3] ), .co(
        \add_13/carry[4] ), .s(N4) );

   dffpr_6 \count_reg[6]  ( N7, clk, n18,
			    count, n31
			    );

endmodule

