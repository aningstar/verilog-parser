module abc (id3, id4);

    input id3;
    output id4;

    $display("text_with_format_specifiers", a, b, c);
    $displayb("text_with_format_specifiers", a, b, c);
    $displayo("text_with_format_specifiers", a, b, c);
    $displayh("text_with_format_specifiers", a, b, c);
    
    $write("text_with_format_specifiers", a, b, c);
    $writeb("text_with_format_specifiers", a, b, c);
    $writeo("text_with_format_specifiers", a, b, c);
    $writeh("text_with_format_specifiers", a, b, c);
    
    $strobe("text_with_format_specifiers", a, b, c);
    $strobeb("text_with_format_specifiers", a, b, c);
    $strobeo("text_with_format_specifiers", a, b, c);
    $strobeh("text_with_format_specifiers", a, b, c);
    
    $monitor("text_with_format_specifiers", a, b, c);
    $monitorb("text_with_format_specifiers", a, b, c);
    $monitoro("text_with_format_specifiers", a, b, c);
    $monitorh("text_with_format_specifiers", a, b, c);

endmodule
