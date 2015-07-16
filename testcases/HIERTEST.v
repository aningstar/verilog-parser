module level2 (in, out);   
   
  input in;
  output out;
   
   inv_2 level2_U (.a(in), .x(out));

endmodule

module level1 ( in, out );
   
  input in;
   output out;
   wire level1wire;   
   
   level2 level2_inst (.in(level1wire), .out(out));
   inv_2 level1_U (.a(in), .x(level1wire));
   
endmodule

module level0 ( in, out );
   
  input in;
   output out;
   wire level0wire;

   level1 level1_inst (.in(level0wire), .out(out));
   inv_2 level0_U (.a(in), .x(level0wire));

endmodule