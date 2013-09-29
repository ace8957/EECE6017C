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
module mem(clock, resetn, run, address, led_output_wires, seg0_out,
			seg1_out, seg2_out, seg3_out);
	
	input clock, resetn, run;
	output [8:0] address;//address connection from memory to proc
	output [8:0] led_output_wires;
	output [8:0] seg0_out, seg1_out, seg2_out, seg3_out;
	
	wire [8:0] data_out;//data wire between memory and proc transfer
	wire [8:0] data_in;//data wire between memory and proc transfer
	wire a7, a8;
	wire W;
	/*
	reg led_write;//led writing
	reg mem_write;//memory writing
	reg seg_write;//7seg writing
	*/
	wire led_write;
	wire mem_write;
	wire seg_write;
	
	wire [3:0] segSelect;//the first 3 bits of the address will be the selector for which display
	
	assign a7 = address[7];
	assign a8 = address[8];
	/* Write Signals:
	 * 00 = memory write
	 * 01 = led write
	 * 10 = 7 segment write
	 */
	assign seg_write = (W & ~(a7 | ~a8));
	assign led_write = (W & ~(~a7 | a8));
	assign mem_write = (W & ~(a7 | a8));
	/*
	always begin
		led_write = (W & ~(~a7 | a8));
		mem_write = (W & ~(a7 | a8));
		seg_write = (W & ~(a7 | ~a8));
	end
	*/
	assign segSelect = {address[3], address[2], address[1], address[0]};
	
	regn led_reg(data_out, led_write, clock, led_output_wires); 
	
	enhanced_mem memory_control(address, clock, data_out, mem_write, data_in);// the module for memory
	
	proc processor(data_in, resetn, clock, run, data_out, address, W);// the module for the processor
	
	seg7_scroll seven_seg_display(segSelect, data_out, seg_write, clock, seg0_out,
									seg1_out, seg2_out, seg3_out);
	
endmodule
