module verilog_gates 

(
	//input ports 
	input XOR_IN1, XOR_IN2, OR_IN1, OR_IN2, NAND_IN1, NAND_IN2, AND_IN1, AND_IN2,
	
	//output ports
	output XOR_OUT, OR_OUT, NAND_OUT, AND_OUT
);

	assign AND_OUT = AND_IN1 & AND_IN2;
	assign NAND_OUT = ~(NAND_IN1 & NAND_IN2);
	assign OR_OUT = OR_IN1 | OR_IN2;
	assign XOR_OUT = XOR_IN1 ^ XOR_IN2;

endmodule
