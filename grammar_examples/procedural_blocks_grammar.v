module abc (id3, id4);
  initial // A 50 ns clock oscillator that starts after 1000 time units
    begin
      clk = 0;
      #1000 forever #25 clk = ~clk;
    end
  
  // In this example, the sensitivity list infers sequential logic
  always @(posedge clk)
    begin // non-blocking assignments prevent race conditions in byte swap
      word[15:8]<= word[7:0];
      word[7:0] <= word[15:8];
    end
  
  // In this example, the sensitivity list infers combinational logic
  always @(a, b, ci)
    sum = a + b + ci;
  
  // In this example, the sensitivity list infers combinational logic,
  // (the @* token infers sensitivity to any signal read in the statement or
  // statement group which follows it, which are sel, a and b)
  always @*
    begin
      if (a) y = a + b; // if (sel==0)
      else   y = a * b;
    end
  
  // This example using illustrates several programming statements
  always @(posedge clk) begin
    casez (opcode) //casez makes Z a don't care
      3'b1??: alu_out = accum; // ? in literal integer is same as Z
      3'b000: while (bloc_xfer) // loop until false
                repeat (5) @(posedge clk) // loop 5 clock cycles
                  begin
                    RAM[address] = data_bus;
                    address = address + 1;
                  end
      3'b011: begin : load // named group
                integer i; // local variable
                for (i=0; i; i=i+1) // i<=255
                  @(negedge clk)
                    data_bus = RAM[i];
              end
      default: accum = accum + 1; //$display(“illegal opcode in module %m”);
    endcase
  end
  
  /* 1st 'if' test (simple if). */
  initial
    begin
      if (a)
        word[15:8]<= word[7:0];
    end
  
  /* 2nd 'if' test (if-else). */
  initial
    begin
      if (a)
        word[15:8]<= word[7:0];
      else
        word[7:0] <= word[15:8];
    end
  
  /* 3rd 'if' test (the "dangling else" issue). */
  initial
    begin
      if (a)
        if (b)
          word[15:8]<= word[7:0];
        else
          word[7:0] <= word[15:8];
    end
  
endmodule