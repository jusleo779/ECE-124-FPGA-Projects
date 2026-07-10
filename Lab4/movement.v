module movement(
	input clock,
	input reset,
	input clken,
	input x_gt,
	input x_eq,
	input x_lt,
	input y_gt,
	input y_eq,
	input y_lt,
	input extended,
	input cap_EN,
	output reg capture_XY,
	output reg x_cnt_en,
	output reg x_cnt_up_down,
	output reg y_cnt_en,
	output reg y_cnt_up_down,
	output reg extend_EN,
	output reg posc_err
);

reg[3:0] state;
reg[3:0] next_state;

parameter IDLE = 4'b0000;
parameter FAULT = 4'b0001;
parameter WAIT_RELEASE = 4'b0010;
parameter CAPTURE = 4'b0100;
parameter MOVE = 4'b1000;



always@(posedge clock)begin
	if(reset) begin
		state <= IDLE;
	end
	else if(clken)
		state <= next_state;
end

always@(*)begin
	case(state)
		IDLE:begin
			if(cap_EN)
				next_state = CAPTURE;
			else
				next_state = IDLE;
		end
		FAULT:begin
			if(extended)
				next_state = FAULT;
			else
				next_state = IDLE;
		end
		CAPTURE:begin
			if(extended)
				next_state = FAULT;
			else if(cap_EN)
				next_state = WAIT_RELEASE;
			else
				next_state = IDLE;
		end
		WAIT_RELEASE:begin
			if(~cap_EN)
				next_state = MOVE;
			else
				next_state = WAIT_RELEASE;
		end
		MOVE: begin
			if(x_eq && y_eq)
				next_state = IDLE;
			else if(x_gt || y_gt  || x_lt || y_lt)
				next_state = MOVE;
		end
		default:begin
			next_state = IDLE;
		end
	endcase
end



always@(*)begin
	case(state)
		IDLE:begin
			extend_EN = 1'b1;
			posc_err = 1'b0;
			x_cnt_en = 1'b0;
			y_cnt_en = 1'b0;
			capture_XY = 1'b0;
			x_cnt_up_down = 1'b1;
			y_cnt_up_down = 1'b1;
		end
		FAULT:begin
			posc_err = 1'b1;

			//prevent latches
			capture_XY = 1'b0;
			x_cnt_en = 1'b0;
			y_cnt_en = 1'b0;
			extend_EN = 1'b1;
			x_cnt_up_down = 1'b1;
			y_cnt_up_down = 1'b1;
		end	
		CAPTURE: begin
			//prevent latches
			posc_err = 1'b0;
			capture_XY = 1'b0;
			x_cnt_en = 1'b0;
			y_cnt_en = 1'b0;
			extend_EN = 1'b1;
			x_cnt_up_down = 1'b1;
			y_cnt_up_down = 1'b1;
		end
		WAIT_RELEASE:begin
			capture_XY = 1'b1;

			//prevent latches
			x_cnt_en = 1'b0;
			y_cnt_en = 1'b0;
			extend_EN = 1'b0;
			x_cnt_up_down = 1'b1;
			y_cnt_up_down = 1'b1;
			posc_err = 1'b0;
		end
		MOVE:begin
			//prevent latches
			extend_EN = 1'b0;
			capture_XY = 1'b0;
			x_cnt_en = 1'b0;
			y_cnt_en = 1'b0;
			posc_err = 1'b0;

			//x movement
			if(x_gt)begin
				x_cnt_up_down = 1'b0;
				x_cnt_en = 1'b1;
			end
			else if(x_lt)begin
				x_cnt_up_down = 1'b1;
				x_cnt_en = 1'b1;
			end
			else begin
				x_cnt_en = 1'b0;
				x_cnt_up_down = 1'b1;
			end
			//y movement
			if(y_gt)begin
				y_cnt_up_down = 1'b0;
				y_cnt_en = 1'b1;
			end
			else if(y_lt)begin
				y_cnt_up_down = 1'b1;
				y_cnt_en = 1'b1;
			end
			else begin 
				y_cnt_en = 1'b0;
				y_cnt_up_down = 1'b1;
			end
		end
		default:begin 
			extend_EN = 1'b1;
			posc_err = 1'b0;
			x_cnt_en = 1'b0;
			y_cnt_en = 1'b0;
			capture_XY = 1'b0;
			x_cnt_up_down = 1'b1;
			y_cnt_up_down = 1'b1;
		end
			
	endcase
end 

endmodule
