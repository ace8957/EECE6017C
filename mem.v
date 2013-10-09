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
 * clock - the clock used for the memory 
 * resetn - the reset button for the system
 * run - the trigger used for running the system command
 * address - Location that data is being read to
 * led_output_wires - Drive the board LEDs when the two MSB of address is 01.
 * seg0_out - 7-segment display 0 output
 * seg1_out - 7-segment display 1 output
 * seg2_out - 7-segment display 2 output
 * seg3_out - 7-segment display 3 output
 */
module mem(clock, resetn, run, switches, led_output_wires, seg0_out,
			seg1_out, seg2_out, seg3_out);
	
	input clock, resetn, run;
	input [8:0] switches;
	wire[8:0] address;//address connection from memory to proc
	output [8:0] led_output_wires;
	output [8:0] seg0_out, seg1_out, seg2_out, seg3_out;
	
	wire [8:0] data_out;//data wire between memory and proc transfer
	reg [8:0] data_in;//data wire between memory and proc transfer
	wire a7, a8;
	wire W;

	wire led_write;
	wire mem_write;
	wire seg_write;
	wire load_switches;
	
	wire [3:0] segSelect;//the first 3 bits of the address will be the selector for which display
	wire [8:0] switches_value;
	wire [8:0] memory_output;
	
	assign a7 = address[7];
	assign a8 = address[8];
	/* Write Signals:
	 * 00 = memory write
	 * 01 = led write
	 * 10 = 7 segment write
	 * 11 = load from switches
	 */
	assign seg_write = (W & ~(a7 | ~a8));
	assign led_write = (W & ~(~a7 | a8));
	assign mem_write = (W & ~(a7 | a8));
	assign load_switches = ~(~a7 | ~a8);

	assign segSelect = {address[3], address[2], address[1], address[0]};
	
	always @(*) begin
		if(load_switches == 1'b1) begin
			data_in <= switches_value;
		end
		else begin
			data_in <= memory_output;
		end
	end
	
	regn led_reg(data_out, led_write, clock, led_output_wires); 
	
	enhanced_mem memory_control(address[6:0], clock, data_out, mem_write, memory_output);// the module for memory
	
	proc processor(data_in, resetn, clock, run, data_out, address, W);// the module for the processor
	
	seg7_scroll seven_seg_display(segSelect, data_out, seg_write, clock, seg0_out,
									seg1_out, seg2_out, seg3_out);
									
	switch_load switches_reg(clock, switches, switches_value);
	
endmodule
