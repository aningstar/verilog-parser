module abc (id3, id4);
  
  a = {b, c[0]};
  
  /* Operator precedence tests. The last operation should be completed first */
  /* due to higher precedence. */
  
  a = b ** -c;
  
  a = b * c ** d;
  a = b / c ** d;
  a = b % c ** d;
  
  a = b + c * d;
  a = b - c * d;
  
  a = b >> c + d;
  a = b >>> c + d;
  a = b << c + d;
  a = b <<< c + d;
  
  a = b < c << d;
  a = b <= c << d;
  a = b > c << d;
  a = b >= c << d;
  
  a = b == c < d;
  a = b != c < d;
  
  a = b === c == d;
  a = b !== c == d;
  
  a = b & c !== d;
  
  a = b ^ c & d;
  a = b ^~ c & d;
  a = b ~^ c & d;
  
  a = b | c ^ d;
  
  a = b && c | d;
  
  a = b || c && d;
  
  a = b ? c && d : e || f;
  
  /* This shouldn't work. */
  //a = b & &c;
  //a = b | |c;
  
  /* This should work. */
  a = b & (&c);
  a = b | (|c);
  a = &b & c;
  a = |b | c;
  
endmodule