Parsing Gate-Level Verilog Netlists (.v)
===

Implementation of a fully-fledged Verilog parser which performs lectical and syntactic analysis of the hardware description language using the Flex and Bison parsing tools. It subsequently creates hash tables and stores the core modules in them. Furthermore, the results can be visualized with a GUI GTK application.

Compile
===

Compile parser
```
cd parser && $(MAKE)
```
Compile project
```
make build
```

Run
===

```
make run
```

Tools
===

[Flex](https://www.gnu.org/software/flex/flex.html)

[GNU Bison](https://www.gnu.org/software/bison/)

[Tpl - a small binary serialization library for C](
https://github.com/troydhanson/tpl)

[Glade - A User Interface Designer](
https://glade.gnome.org/)

[Gtk 3](http://www.gtk.org/)

References
===

[Verilog-2001 Quick Reference Guide - Sutherland HDL, Inc.](
   http://sutherland-hdl.com/pdfs/verilog_2001_ref_guide.pdf)

[The Verilog® Hardware Description Language
Donald E. Thomas, Philip R. Moorby](
https://books.google.gr/books?id=59UxOgzH2tAC&redir_esc=y)

