primitive mux (y, a, b, sel); //COMBINATIONAL UDP

 output y;

 input sel, a, b;

 table //Table order for inputs

 // a b sel : y //matches primitive statement

 0 ? 0 : 0; //select a; don’t care on b

 1 ? 0 : 1; //select a; don’t care on b

 ? 0 1 : 0; //select b; don’t care on a

 ? 1 1 : 1; //select b; don’t care on a

 endtable

endprimitive

primitive dff //SEQUENTIAL UDP

 (output reg q = 0,

 input clk, rst, d);

 table

 //d clk rst:state:q

 ? ? 0 : ? :0; //low true reset

 0 R 1 : ? :0; //clock in a 0

 1 R 1 : ? :1; //clock in a 1

 ? N 1 : ? :-; //ignore negedge of clk

 * ? 1 : ? :-; //ignore all edges on d

 ? ? P : ? :-; //ignore posedge of rst

 0 (0X) 1 : 0 :-; //reduce pessimism

 1 (0X) 1 : 1 :-; //reduce pessimism

 endtable

endprimitive
