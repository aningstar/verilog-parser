module abc (id3, id4);
    task read_mem (input [15:0] address,
        output [31:0] data );
        reg a;
        reg vectored a,b,c;
        reg [7:0] Q [0:3][0:15];
        reg signed [7:0] d1, d2;
    endtask
    task automatic write_mem();
        reg vectored a,b,c;
        reg [7:0] Q [0:3][0:15];
    endtask
    task read_mem;
        input [15:0] address;
        output [31:0] data;
        inout [31:0] data;
        reg a;
        reg scalared a,b,c;
        reg vectored a,b,c;
        reg [7:0] Q [0:3][0:15];
        reg signed [7:0] d1, d2;
    endtask
    task read_mem;
        input [15:0] address;
        output [31:0] data;
        reg a;
        reg scalared a,b,c;
        reg vectored a,b,c;
        reg [7:0] Q [0:3][0:15];
        reg signed [7:0] d1, d2;
    endtask
    task automatic write_mem();
    endtask

    task write_mem;
    endtask

    task write_mem;
        reg vectored a,b,c;
        reg [7:0] Q [0:3][0:15];
    endtask

    task automatic write_mem;
        input [15:0] address;
        output [31:0] data;
        inout [31:0] data;
    endtask

    task read_mem (input [15:0] address,
         output [31:0] data );
      begin
        read_request = 1;
        wait (read_grant) addr_bus = address;
         data = data_bus;
         #5 addr_bus = 16'bz; read_request = 0;
      end
      begin
        read_request = 1;
        wait (read_grant) addr_bus = address;
         data = data_bus;
         #5 addr_bus = 16'bz; read_request = 0;
      end

    endtask

endmodule
