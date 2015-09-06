module abc (id3, id4);

    input id3;
    output id4;
    parameter [2:0] s1 = 3'b001,
                    s2 = 3'b010,
                    s3 = 3'b100;
    parameter integer period = 10;
    localparam offset = 5;
    specparam a = 3;
    event data_ready, data_sent;

endmodule
