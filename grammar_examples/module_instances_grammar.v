module abc (id3, id4);

input id3;
output id4;

dff u1 (signal1 , , signal2, ,);
tribuf8bit i[7:0] (out, in, enable);
dff u1[6:0] (q[0], , d[0], clk);
dff u2 (.clk(clk),.q(q[1]),.data(d[1]));
dff u3 (.clk(clk), ,.q(q[1]),.data(d[1]),a);

dff #(2) u4 (q[3], , d[3], clk);

dff #(.delay(3)) u5 (q[3], , d[3], clk);
defparam u3.delay = 3.2;

endmodule
