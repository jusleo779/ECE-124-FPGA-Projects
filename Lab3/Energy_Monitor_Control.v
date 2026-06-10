module Energy_Monitor_Control ( 	
    input door_open, window_open, mc_testmode, vac_mode,
    input i1eqi2, i1gti2, i1lti2,

    output reg blower_on, ac_on, furnace_on, at_temp,
    output reg HVAC_run, HVAC_increase, HVAC_decrease,
    output reg Vacation_led, door_open_led, window_open_led
); 

    always @(*) begin
        HVAC_run        = 1'b0;
        HVAC_increase   = 1'b0;
        HVAC_decrease   = 1'b0;
        furnace_on      = 1'b0;
        ac_on           = 1'b0;
        at_temp         = 1'b0;
        blower_on       = 1'b0;
        
        door_open_led   = door_open;
        window_open_led = window_open;
        Vacation_led    = vac_mode;

 
        if (!i1eqi2 && !door_open && !window_open && !mc_testmode) begin
            HVAC_run = 1'b1;
        end

        
        if (HVAC_run) begin
            HVAC_increase = i1gti2; 
            HVAC_decrease = i1lti2; 
        end

        if (i1lti2) begin
            ac_on = 1'b1;      
        end
        
        if (i1gti2) begin
            furnace_on = 1'b1; 
        end
        
        if (i1eqi2) begin
            at_temp = 1'b1;  
        end

        if ((i1gti2 || i1lti2) && !mc_testmode && !window_open && !door_open) begin
            blower_on = 1'b1;
        end
        
    end
	
endmodule
