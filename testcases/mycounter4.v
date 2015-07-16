
module counter ( clk, reset, count);// good comment 1
  output [7:0] count;
  input clk, reset;// good comment 2
  wire   n42, n43, n44, N1, N2, N3, N4, N5, N6, N7, N8, n18, n22, n24, n27,
         n29, n31, n32, n33, n35, n36, n38, n40;
  wire   [7:2] \add_13/carry;

// mymux4 mux ( .mux_sel(mux_sel), .out(out), .in({ net4, net8, net16, net32}) );

   mymux4 mux2 ( .mux_sel(mux_sel/*new*/), .out(out), .in({net15, net18, net25, net32}) );

   DLX_sync_desync DLX_sync ( .DM_read_data(DM_read_data), .DM_write_data(DM_write_data),
		.DM_addr(DM_addr), .DM_write(DM_write), .DM_read(DM_read), .NPC(NPC),
		.reset(reset), .IR(IR), .byte0(byte0), .word(word), .INT(INT), .CLI(CLI),
		.PIPEEMPTY(PIPEEMPTY), .FREEZE(FREEZE), .test_si(test_si), .test_se(test_se),
		.sync_sel(sync_sel), .global_g1(global_g1), .global_g2(global_g2), .Ctrl__EXinst___Regs_1__en1(Ctrl__EXinst___Regs_1__en1/*new*/),
		.Ctrl__EXinst___Regs_1__en2(Ctrl__EXinst___Regs_1__en2/*new*/), .Ctrl__IDinst___Regs_1__en1(Ctrl__IDinst___Regs_1__en1/*new*/),
		.Ctrl__IDinst___Regs_1__en2(Ctrl__IDinst___Regs_1__en2/*new*/), .Ctrl__IFinst___Regs_1__en1(Ctrl__IFinst___Regs_1__en1/*new*/),
		.Ctrl__IFinst___Regs_1__en2(Ctrl__IFinst___Regs_1__en2/*new*/), .Ctrl__MEMinst___Regs_1__en1(Ctrl__MEMinst___Regs_1__en1/*new*/),
		.Ctrl__MEMinst___Regs_1__en2(Ctrl__MEMinst___Regs_1__en2/*new*/) );

//mymux4 mux3 ( .mux_sel(mux_sel), .out(out), .in({ net13, net16, net20, net25}) );//ok1,25 logarithmic

   mymux4 mux4 ( .mux_sel(mux_sel), .out(out), .in({net3, net5, net10, net20}) );//2 logarithmic

// mux4_1 U4 ( .x(out), .d0(in[0]), .d1(in[2]), .d2(in[1]), .d3(in[3]), .sl0(mux_sel[0]), .sl1(mux_sel[1]) );//

   inv_2 U4 ( .a(reset), 
	     .x(n18) );
  
   adhalf_2 \add_13/U1_1_3  ( .a(count[3]), .b(\add_13/carry[3]), .co(
        \add_13/carry[4]), .s(N4) );
  
   dffpr_6 \count_reg[6]  ( N7, clk, n18, 
			    count, n31
			    );

/*
pavlos 14 - 7
to n3 na odhghsei ola ta shmata
oi kathisterhseis na eine logarithmikis klimakas
*/       
  /*and2_1 and21 ( .x(net21), .a(n3), .b(net20) );
	and2_1 and22 ( .x(net22), .a(n3), .b(net21) );
	and2_1 and23 ( .x(net23), .a(n3), .b(net22) );
	and2_1 and24 ( .x(net24), .a(n3), .b(net23) );
	and2_1 and25 ( .x(net25), .a(n3), .b(net24) );
	and2_1 and26 ( .x(net26), .a(n3), .b(net25) );
	and2_1 and27 ( .x(net27), .a(n3), .b(net26) );
	and2_1 and28 ( .x(net28), .a(n3), .b(net27) );
	and2_1 and29 ( .x(net29), .a(n3), .b(net28) );
	and2_1 and30 ( .x(net30), .a(n3), .b(net29) );
	and2_1 and31 ( .x(net31), .a(n3), .b(net30) );
	and2_1 and32 ( .x(net32), .a(n3), .b(net31) );*/   

/* this is a comment */
   /* this too */
   
endmodule

