module LogicalStep_Lab2_top
(
	input				rst_n,		//reset in
	input          clkin_50,	//clock in
	input		[7:0]	sw,
	input		[3:0]	pb_n,

	output	[7:0]	leds,
	output	[6:0]	seg7_data,
	output			seg7_char1,
	output			seg7_char2
);

//these are used as intermediate signals
	wire 	[3:0] hex_A, hex_B;
	wire	[6:0] seg7_A, seg7_B;
	wire [3:0] pb;

	wire [3:0] hex_sum;	
	wire carry;
	wire [3:0] adder_carry_hex;
	wire [3:0] mux_outA, mux_outB;
	
// wire assignments
	assign hex_A = sw[3:0];
	assign hex_B = sw[7:4];

	//assign carry_out to the correct sizing
	assign adder_carry_hex = {3'b000, carry};
	
//module instantiations are here

	full_adder_4bit u0 (
		.A(hex_A),
		.B(hex_B),
		.carry_in(1'b0),
		.carry_out(carry),
		.hex_sum(hex_sum)
	);

	mux_4bit_2_to_1 mux1(
		.din_A(hex_A[3:0]),
		.din_B(hex_sum[3:0]),
		.selector(pb[2]),
		.dout(mux_outA)
	);

	mux_4bit_2_to_1 mux2(
		.din_A(hex_B[3:0]),
		.din_B(adder_carry_hex[3:0]),
		.selector(pb[2]),
		.dout(mux_outB)
	);
	

	SevenSegment u1 (
		.hex      (mux_outA), 
		.sevenseg (seg7_A)
	);

	SevenSegment u2 (
		.hex      (mux_outB), 
		.sevenseg (seg7_B)
	);

	segment7_mux u3 (
		.clk  (clkin_50),
		.din2 (seg7_A), 
		.din1 (seg7_B),
		.dout (seg7_data),
		.dig2 (seg7_char2), 
		.dig1 (seg7_char1)
	);
		
	pb_inverters u4(
		.pbin(pb_n[3:0]),
		.pbout(pb[3:0])
	);
	
	Logic_Processor u5(
		.hex_A(hex_A[3:0]),
		.hex_B(hex_B[3:0]),
		.select(pb[1:0]),
		.logic_out(leds[3:0])
	);
endmodule

module pb_inverters(
		input [3:0] pbin,
		output [3:0] pbout
	);
		assign pbout = ~(pbin);
endmodule
