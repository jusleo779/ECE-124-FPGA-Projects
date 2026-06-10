`define HVAC_SIM


module LogicalStep_Lab3_top (
	input 			clkin_50,
	input 	[3:0] pb_n,
 	input 	[7:0]	sw, 	
   output	[7:0] leds,
		
	 `ifdef HVAC_SIM
				output[3:0] hvac_temp,
				output[3:0] VACATAION_TEMP,
				output[3:0] DESIRED_TEMP,
	 `endif
		
   output 	[6:0]	seg7_data, // 7-bit outputs to a 7-segment
	output 			seg7_char1,// seg7 digit1 selector
	output			seg7_char2 // seg7 digit2 selector
); 

// INTERNAL SIGNALS USED IN THE DESIGN





// declarations associated with the global clock,  push-buttons and switches
wire 			clk_in;
wire [3:0]	pb, hex_A, hex_B;

// declarations associated with the seg7 signals
wire [6:0]	seg7_A, seg7_B;


//------------------------------------------------------------------- 
// Here the circuit begins

// hookup up the clock and switches
assign clk_in = clkin_50;
assign hex_A = sw[3:0];
assign hex_B = sw[7:4];

// hookup to hex signals to the 7seg decoders (you may use your decoders from Lab2)
/*
SevenSegment  U0 (
	.hex (hex_A), .sevenseg (seg7_A)
);
*/ 
/*
SevenSegment U1 (
	.hex (hex_B), .sevenseg (seg7_B)
); 
*/

// hookup to seven_segmnent_mux function
segment7_mux U2 (
	.clk (clk_in), .din2 (seg7_A), .din1 (seg7_B), .dout (seg7_data), .dig2 (seg7_char2), .dig1 (seg7_char1)
);			 

//--------------------------------------------------------------------
// PART A build

//declare comparator signals
wire 	aeqb, agtb, altb;

//4bit comparator
/*
compx4 u3(
	.hex_A(hex_A), .hex_B(hex_B),.agtb(agtb), .altb(altb), .aeqb(aeqb)
);
*/

//connecting the leds to the outputs
//assign leds[0] = altb;
//assign leds[1] = aeqb;
//assign leds[2] = agtb;
//--------------------------------------------------------------------
// Part B build

wire [3:0] current_temp;

SevenSegment U1 (
	.hex (current_temp), .sevenseg (seg7_B)
); 

/*
compx4 u3(
	.hex_A(hex_A), .hex_B(hex_B),.agtb(agtb), .altb(altb), .aeqb(aeqb)
);
*/
/*
hvac #(.hvac_sim(1'b0)) U4(
	.clk(clk_in), .run(1'b1), .increase(agtb), .decrease(altb), .temp(current_temp)
);
*/
/*
Tester U5(
	.mc_testmode(1'b1),
	.i1eqi2(aeqb), 
	.i1gti2(agtb),
	.i1lti2(altb),
	.input1(hex_A),
	.input2(current_temp),
	.test_pass(leds[7])	
);
*/

//--------------------------------------------------------------------
// Part C build

	wire[3:0] mux_temp;
	
	SevenSegment u0(
		.hex(mux_temp), .sevenseg(seg7_A)
	);
	/*
	hvac #(.hvac_sim(hvac_sim)) u4(
		.clk(clk_in), .run(1'b1), .increase(agtb), .decrease(altb), .temp(current_temp)
	);
	*/
	`ifdef HVAC_SIM
		assign hvac_temp = current_temp;
		localparam hvac_sim = 1'b1;
	`endif
	
	`ifndef HVAC_SIM
		localparam hvac_sim = 1'b0;
	`endif
	
	
	compx4 U3(
		.hex_A(mux_temp), .hex_B(current_temp), .agtb(agtb), .altb(altb), .aeqb(aeqb)
	);
	
	Tester U5(
		.mc_testmode(pb[2]),
		.i1eqi2(aeqb), 
		.i1gti2(agtb),
		.i1lti2(altb),
		.input1 (hex_A),
		.input2 (current_temp),
		.test_pass (leds [7])
		);
		
	mux_4bit_2_to_1 U6 (
		.din_A (hex_A),
		.din_B(hex_B),
		.selector(pb[3]),
		.dout(mux_temp)
	);
		
	PB_Inverters U7(
		.pbin(pb_n),
		.pbout(pb)
	);	
	
//--------------------------------------------------------------------
// Part D build

wire increase,decrease, run;

hvac #(.hvac_sim (hvac_sim)) U4(
	.clk(clk_in), .run(run), .increase(increase), .decrease(decrease), .temp(current_temp)
);


Energy_Monitor_Control U8(
	.door_open(pb[0]), 
	.window_open(pb[1]), 
	.mc_testmode(pb[2]), 
	.vac_mode(pb[3]), 
	.i1eqi2(aeqb), 
	.i1gti2(agtb), 
	.i1lti2(altb),
	
	.blower_on(leds[3]),
	.ac_on(leds[2]),
	.at_temp(leds[1]),
	.furnace_on(leds[0]),
	.HVAC_run(run), 
	.HVAC_increase(increase), 
	.HVAC_decrease(decrease),
	.Vacation_led(leds[6]),
	.door_open_led(leds[5]),
	.window_open_led(leds[4])
);



endmodule
