all: 
	../verilog_parser < function_definitions_grammar.v
	../verilog_parser < task_definitions_grammar.v
	#../verilog_parser < generate_blocks.v
	../verilog_parser < module_instances_grammar.v
	../verilog_parser < array_selects_grammar.v
	../verilog_parser < bit_selects_grammar.v
	../verilog_parser < constant_declarations_grammar.v
	../verilog_parser < variable_declarations_grammar.v
	../verilog_parser < net_declarations_grammar.v
	../verilog_parser < port_declarations_grammar.v
	../verilog_parser < primitive_instances_grammar.v
	../verilog_parser < procedural_blocks_grammar.v
	../verilog_parser < specify_blocks_grammar.v
	../verilog_parser < expressions_grammar.v
	../verilog_parser < udp_declarations.v
	../verilog_parser < system_tasks_grammar.v

expressions:
	../verilog_parser < expressions_grammar.v

specify_blocks: 
	../verilog_parser specify_blocks_grammar.v

procedural_blocks: 
	../verilog_parser procedural_blocks_grammar.v

function_definitions_grammar: 
	../verilog_parser function_definitions_grammar.v

task_defintions_grammar: 
	../verilog_parser task_definitions_grammar.v

#generate_blocks: 
	#../verilog_parser generate_blocks.v

module_instances: 
	../verilog_parser module_instances_grammar.v

primitive_instances: 
	../verilog_parser primitive_instances_grammar.v

array_selects: 
	../verilog_parser array_selects_grammar.v

bit_selects: 
	../verilog_parser bit_selects_grammar.v

constant_declarations: 
	../verilog_parser constant_declarations_grammar.v

variable_declarations: 
	../verilog_parser variable_declarations_grammar.v

net_declarations: 
	../verilog_parser net_declarations_grammar.v

port_declarations: 
	../verilog_parser port_declarations_grammar.v

udp_declarations:
	../verilog_parser < udp_declarations.v

system_tasks:
	../verilog_parser < system_tasks_grammar.v


example: 
	../verilog_parser example.v

debug:
	valgrind ../verilog_parser function_definitions_grammar.v
	valgrind ../verilog_parser task_definitions_grammar.v
	#valgrind ../verilog_parser generate_blocks.v
	valgrind ../verilog_parser module_instances_grammar.v
	valgrind ../verilog_parser array_selects_grammar.v
	valgrind ../verilog_parser bit_selects_grammar.v
	valgrind ../verilog_parser constant_declarations_grammar.v
	valgrind ../verilog_parser variable_declarations_grammar.v
	valgrind ../verilog_parser net_declarations_grammar.v
	valgrind ../verilog_parser port_declarations_grammar.v
	valgrind ../verilog_parser primitive_instances_grammar.v
	valgrind ../verilog_parser procedural_blocks_grammar.v
	valgrind ../verilog_parser specify_blocks_grammar.v
	valgrind ../verilog_parser < udp_declarations.v
