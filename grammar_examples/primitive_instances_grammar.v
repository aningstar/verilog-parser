module abc (id3, id4);

and i1 (out,in1,in2);
and #5 (o,i1,i2,i3,i4);
not #(2,3) u7 (out,in);
buf (pull0,strong1)(y,a);
wire [31:0] y, a;
buf #2.7 i[31:0] (y,a);

endmodule
