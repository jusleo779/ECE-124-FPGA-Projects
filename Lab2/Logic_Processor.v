module Logic_Processor(
	input [3:0]hex_A,
	input [3:0]hex_B,
	input [1:0] select,
	output [3:0] logic_out
);

   wire[3:0] gate_AND;
   wire[3:0] gate_OR;
   wire[3:0] gate_XOR; 
   wire[3:0]gate_XNOR;
	
	assign gate_AND = hex_A & hex_B;
	assign gate_OR = hex_A | hex_B;
	assign gate_XOR = hex_A ^ hex_B;
	assign gate_XNOR = ~(hex_A ^ hex_B);
	
	assign logic_out = (select == 2'b00)? gate_AND :
							 (select == 2'b01)? gate_OR :
							 (select == 2'b10)? gate_XOR : gate_XNOR;
	
endmodule
	
	
		