module grappler(
	input clock,
	input reset,
	input sm_clken,
	input grapple_EN,
	input button,
	output reg g_out
);

reg [2:0]  state;
reg [2:0] next_state;

parameter PRESS_OPEN = 3'b001;
parameter HOLD_OPEN =  3'b010;
parameter RELEASE_OPEN = 3'b011;
parameter PRESS_CLOSE = 3'b100;
parameter HOLD_CLOSE =  3'b101;
parameter RELEASE_CLOSE = 3'b110;


//state change
always@(posedge clock)begin
	if(reset)
		state <= PRESS_OPEN;
	else if(sm_clken) begin
		state <= next_state;
	end
end

//state machine
always@(*)begin
	if(grapple_EN)begin

		case(state)
			PRESS_OPEN:begin
				if(button)
					next_state = HOLD_OPEN;
				else
					next_state = PRESS_OPEN;
			end
			HOLD_OPEN:begin
				if(~button)
					next_state = RELEASE_OPEN;
				else
					next_state = HOLD_OPEN;
			end
			RELEASE_OPEN: begin	
				next_state = PRESS_CLOSE;
			end
			PRESS_CLOSE:begin
				if(button)
					next_state = HOLD_CLOSE;
				else
					next_state = PRESS_CLOSE;
			end
			HOLD_CLOSE:begin
				if(~button)
					next_state = RELEASE_CLOSE;
				else
					next_state = HOLD_CLOSE;
			end
			RELEASE_CLOSE: begin	
				next_state = PRESS_OPEN;
			end

			default: 
				next_state = PRESS_OPEN;
		endcase
	end
	else 
		next_state = state;

end


//decoder
always@(*)begin
	case(state)
		RELEASE_OPEN:
			g_out = 1'b0;
		
		HOLD_OPEN:
			g_out = 1'b1;
		
		PRESS_OPEN:
			g_out = 1'b1;
		
		RELEASE_CLOSE:
			g_out = 1'b1;
		
		HOLD_CLOSE:
			g_out = 1'b0;
			
		PRESS_CLOSE:
			g_out = 1'b0;

		
		
		default:
			g_out = 1'b0;
	endcase
end
endmodule
