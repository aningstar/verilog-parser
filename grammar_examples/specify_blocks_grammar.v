module abc (id3, id4);

specify
    specparam tRise_clk_q=150, tFall_clk_q=200;
    specparam tRise_control=40, tFall_control=50;
    (a => b) = 1.8;
    (a -*> b) = 2:3:4;

    specparam t1 = 3:4:6,
              t2 = 2:3:4;
    (a => y) = (t1,t2);

    // Syntax: (module_path)=delay;
    // one delay value is assigned to all transitions:
    //      0->1, 1->0, 0->Z, Z->1, 1->Z, z->0
    //
    // Examples:
    (C=>Q)=20;  // assigns a delay of 20 for all
                // transitions from C to Q

    (C=>Q)=10:14:20; // assigns min:typ:max delays to all
                     // transitions from C to Q

    // Syntax:   (module_path)=(rise_delay,fall_delay);
    // transitions:  0->1       1->0
    //               0->z       1->z
    //               z->1       z->0
    // Examples:
    specparam tPLH=12,tPHL=25;
    (C=>Q)=(tPLH,tPHL);
    specparam tPLH=12:16:22,tPHL=16:22:25;
    (C=>Q)=(tPLH,tPHL);

    // Syntax: (module_path)=(rise_delay, fall_delay, z_delay);
    //          0->1 1->0 0->z
    //          z->1 z->0 1->z
    // Examples:

    specparam tPLH = 12, tPHL = 22, tPz = 34;
    (C => Q) = (tPLH, tPHL, tPz);
    specparam tPLH=12:14:30, tPHL=16:22:40, tPz=22:30:34;
    (C => Q) = (tPLH, tPHL, tPz);

    // Syntax: (module_path)=(delay,delay,delay,delay,delay,delay);
    //          0->1 1->0 0->z z->1 1->z z->0
    // Examples:

    specparam t01=12, t10=16, t0z=13, tz1=10, t1z=14, tz0=34;
    (C => Q) = ( t01, t10, t0z, tz1, t1z, tz0);
    specparam t01=12:14:24, t10=16:18:20, t0z=13:16:30;
    specparam tz1=10:12:16, t1z=14:23:36, tz0=15:19:34;
    (C => Q) = ( t01, t10, t0z, tz1, t1z, tz0) ;

    // assign the same polarity to multiple module paths in a single statement
    (a, b, c +*> q1, q2) = 10;   // Positive Polarity
    (a, b, c -*> q1, q2) = 10;   // Negative Polarity

    (posedge clk => (qb -: d)) = (2.6, 1.8);
    (posedge clk=>(q +: d))=2;

    specparam noninvrise = 1, noninvfall = 2;
    specparam invertrise = 3, invertfall = 4;

    if(a) (b=>out)=(invertrise,invertfall); // SDPD

endspecify

endmodule

module adder (A, B, sum, carry);

    input A, B;
    output sum, carry ;

    //TODO not works for now
    //wire sum = A + B ; //continuous assignment
    //wire carry = A & B ; //continuous assignment

    specify
        //module path delays
        (A, B *> sum) = 10 ;
        (A, B *> carry) = 5 ;
    endspecify
endmodule

module adder (A, B, sum_sig, carry_sig);
    input A, B;
    output sum_sig, carry_sig ;

    //TODO not works for now
    //wire sum = A + B ; //continuous assignment
    //wire carry = A & B ; //continuous assignment

    buf g1 (sum_sig, sum) ; //zero delay buf
    buf g2 (carry_sig, carry) ; //zero delay buf

    specify
        //module path delays
        (A, B *> sum_sig) = 10 ;
        (A, B *> carry_sig) = 5 ;

    endspecify

    specify
        (clk => q) = 12;
        (data => q) = 10;
        (clr, pre *> q) = 4;
        specparam
            PATHPULSE$ = 3,
            PATHPULSE$ = ( 3, 5),
            PATHPULSE$clk$q = ( 2, 9 ),
            PATHPULSE$clr$q = 1;
    endspecify

    specify
        (in => outbar) = (2, 3);   // on event (by default)
        pulsestyle_ondetect;      // affects out
        (in => out) = (5, 6);      //    on detect style
        (clk => out) = (4);        //    on detect style
        pulsestyle_onevent;       // affects synch and out
        (in => sync) = (20, 30);   //    on event style
        (in => out) = (7, 9);   //    on event style
    endspecify
    specify
        pulsestyle_ondetect(out); // affects out only
        (in=>out)=(15,25);         //    on detect style
        (clk=>q)=5;                //    on event style (by default)
    endspecify

    specify
        (in => outbar) = (2, 3);  // not shown by default
        showcancelled;  // $showcancelled affects out
        (in => out) = (5, 6);
        (clk => out) = (4);
        noshowcancelled;  // affects sync and out
        (in => sync) = (20, 30);
        (in => out) = (7, 9);
    endspecify
    specify
        showcancelled(out); // affects out only
        (in=>out)=(15,25);
        (clk=>q)=5;
        $setup(data1, posedge data2, 2:3:4);
        $setup(posedge data1, posedge data2, 2:3:4);
        $setup(negedge data1, posedge data2, 2:3:4);
        $setup(edge 01,10 data1, posedge data2, 2:3:4);
        $setup(edge Z0 data1, posedge data2, 2:3:4);
        $setup(edge 01,X0 data1 &&& (a+b), posedge data2, 2:3:4);
        $setup(edge 01,X0 data1 &&& (a + b == 1'b0), posedge data2, 2:3:4);
        $setup(edge 01,X0 data1 &&& (a + b != 1'b0), posedge data2, 2:3:4);
        $setup(posedge data1, posedge data2, 2:3:4,adf);
        //$skew(posedge clk1, posedge clk2, tskew);
        //$skew(posedge clk1, posedge clk2, tskew, af);
        //$hold(posedge data2, data1, thold);
        //$hold(posedge data2, data1, thold, rfrf);
        //$recovery(posedge in1, out1, trecovery);
        //$recovery(posedge in1, out1, trecovery, erergf);

    endspecify

endmodule


