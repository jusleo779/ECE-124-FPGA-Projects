module Extender(
	input clock,
	input reset,
	input sm_clken,
	input button,
	input extend_EN,
	input [3:0] extender_OUT,
	output reg extender_motion,
	output reg extended,
	output reg extend_dir,
	output reg grappler_en
);

reg [2:0] state;
reg [2:0] next_state;

parameter PUSH = 3'b001;
parameter HOLD = 3'b010;
parameter EXTEND = 3'b100;
parameter RETRACT = 3'b000;



always@(posedge clock)begin
	if(reset)begin
		state <= PUSH;
	end
	else if(sm_clken)
		state <= next_state;
end

always@(*)begin
	if(extend_EN) begin
		case(state)
			PUSH:begin
				if(button)
					next_state = HOLD;
				else
					next_state = PUSH;
			end
			HOLD: begin
				if(~button)
					if(extender_OUT[3:0] == 4'b0000)
						next_state = EXTEND;
					else
						next_state = RETRACT;
				else
					next_state = HOLD;
			end

			EXTEND:begin
				if(extender_OUT[3:0] == 4'b1111)
					next_state = PUSH;
				else
					next_state = EXTEND;
			end
			RETRACT:begin
				if(extender_OUT[3:0] == 4'b0000 )
					next_state = PUSH;
				else
					next_state = RETRACT;
			end
			default:
				next_state = PUSH;
		endcase
	end
	else
		next_state = state;
end

always@(*)begin
	case(state)
		PUSH:begin
			extend_dir = 1'b1;
			extender_motion = 1'b0;
			
			if(extender_OUT[3:0] == 4'b1111)
				grappler_en = 1'b1;
			else
				grappler_en = 1'b0;

			if(extender_OUT[3:0] != 4'b0000)
				extended = 1'b1;
			else 
				extended = 1'b0;
		end
		EXTEND:begin
			extend_dir = 1'b1;
			extender_motion = 1'b1;

			if(extender_OUT[3:0] == 4'b1111)
				grappler_en = 1'b1;
			else 
				grappler_en = 1'b0;

			if(extender_OUT[3:0] != 4'b0000)
				extended = 1'b1;
			else 
				extended = 1'b0;
		end
		RETRACT:begin
			extend_dir = 1'b0;
			extender_motion = 1'b1;

			if(extender_OUT[3:0] == 4'b1111)
				grappler_en = 1'b1;
			else 
				grappler_en = 1'b0;
			if(extender_OUT[3:0] != 4'b0000)
				extended = 1'b1;
			else
				extended = 1'b0;
		end
		default:begin
			extend_dir = 1'b1;
			extender_motion = 1'b0;

			if(extender_OUT[3:0] == 4'b1111)
				grappler_en = 1'b1;
			else 
				grappler_en = 1'b0;

			if(extender_OUT[3:0] != 4'b0000)
				extended = 1'b1;
			else 
				extended = 1'b0;
		end
	endcase
end

endmodule
