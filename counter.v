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
 * clock - synchronizes this counter with another system
 * reset - input for when the counter should be reset to 0
 * countEn - Enable counting
 * load - Put the loadVal into the counter
 * loadVal - Value to start the counter at
 * n - The output value of the counter
 */

module counter(clock, reset, countEn, load, loadVal, n);
	input clock, countEn, load, reset;
	input [8:0] loadVal;
	output reg [8:0] n;
	
	initial begin
		n = 9'b000000000;
	end
	
	always @(posedge clock or negedge reset) 
	begin
		if(!reset) n = 9'b000000000;//reset to 0
		else if(clock) begin
			if(!load && countEn) begin
				n = n + 1'b1;//increment
			end
			else if(load && !countEn) begin
				n = loadVal;
			end	
			else if(load && countEn) begin
				$display("Load and countEn both high! They should not both be high at the same time! Loading loadVal+1\n");
				n = loadVal + 1'b1;
			end
			else begin
				// do nothing
			end
		end
	end
endmodule