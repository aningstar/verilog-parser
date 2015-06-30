/* areferwf */
module ALU (out, zero, inA, inB, op);

  parameter N = 32;
  output reg [N-1:0] out;
  output reg zero;
  input wire [N-1:0] inA;
  input wire [N-1:0] inB;
  input wire[3:0] op;


  always@(inA,inB,op) begin
   case(op)
    4'b0000: out = inA & inB;         // op = 0
    4'b0001: out = inA | inB;         // op = 1
    4'b0010: out = inA + inB;         // op = 2
    4'b0110: out = inA - inB;         // op = 6
    4'b0111: out = ((inA < inB)?1:0); // op = 7
    4'b1100: out = ~(inA|inB);        // op = 12
    default: out = 32'bx;
   endcase

   if (out == 4'b0000 ) zero = 0;
   else   zero = 0;
  end

endmodule
