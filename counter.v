/**
 * Embedded Systems (EECE6017C) - Lab 3
 * Simple Processor
 * Author(s): Alex Stephens <stephea5@mail.uc.edu> (AWS)
 *	      	  Josh Boroff <boroffja@mail.uc.edu> (JBB)
 *	      	  Adam Wilford <wilforaf@mail.uc.edu> (AFW)
 * Target FPGA: Altera Cyclone II 2C20 (EP2C20F484C7)
 * Tool: Quartus II 64-bit
 * Version: 13.0.1 sp1
 *
 */

/**
 * Module counter - This module is used to increment a count of 5 bits
 * Clock - input to say when to increment
 * reset - input for when the counter should be reset to 0
 * n - The output value of the counter
 */

module counter(clock, reset, n);
	input clock, reset;
	output reg [4:0] n;
	
	initial n = 5'b00000;
	
	always @(posedge clock or negedge reset) 
	begin
		if(!reset) n = 5'b00000;//reset to 0
		else begin
			n = n + 1;//increment
		end
	end
endmodule