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
 * Development Log:
 * Date		Developer	Description
 * 09 18 13 				Initial development
 * 09 19 13	AWS			Added GPRs and associated control signals. Defined bus drivers.
 */

/**
 * Module mem - The top level module that contains the memory, counter, and proc to do processor operations to memory
 * mclock - the clock used for the memory 
 * pclock - the clock used for the processor
 * resetn - the reset button for the systems
 * run - the trigger used for running the system command
 * done - the signal released when an operation has completed
 * bus - the output of the bus lines 
 */
module mem(mclock, pclock, resetn, run, done, bus);
	
	input mclock, pclock, resetn, run;
	output done;
	output [8:0] bus;
	
	
	wire [4:0] n;
	wire [8:0] data;
	
	counter count(mclock, resetn, n);
	
	memory memory_control(n, mclock, data);
	
	proc processor(data, resetn, pclock, run, done, bus);
	
endmodule
