/**
 * Embedded Systems (EECE6017C) - Lab 3
 * Simple Processor
 * Author(s): Alex Stephens <stephea5@mail.uc.edu> (AWS)
 *	      	  Josh Boroff <boroffjb@mail.uc.edu> (JBB)
 *	      	  Adam Wilford <wilforaf@mail.uc.edu> (AFW)
 * Target FPGA: Altera Cyclone II 2C20 (EP2C20F484C7)
 * Tool: Quartus II 64-bit
 * Version: 13.0.1 sp1
 *
 * Development Log:
 * Date		Developer	Description
 * 09 22 13	AWS			Initial
 */
 
/**
 * Test bench for the simple CPU
 */
 module proc_tb;
 
	reg [8:0] DIN;
	reg Resetn;
	reg Clock;
	reg Run;
	wire Done;
	wire [8:0] BusWires;
	
	proc uut(DIN, Resetn, Clock, Run, Done, BusWires);
	
	initial begin
		Resetn = 1'b0;
		Run = 1'b0;
		Clock = 1'b0;
		DIN = 9'b000000000;
		
		// Wait 10 clock cycles
		#100
		
		// Stop Reset and start running
		Resetn <= 1'b1;
		Run <= 1'b1;
		
		/**
		 * We are going to add 36 and 12 here
		 */
		
		// First, do move immediate into register 0
		DIN <= 9'b001_000_000;
		// Let first state complete
		#10
		DIN <= 9'b0_0010_0100;
		#10
		
		// Next, do move immediate into register 1
		DIN <= 9'b001_001_000;
		#10
		DIN <= 9'b0_0000_1100;
		#10
		
		// Now, add register 0 to register 1, and place in register 0
		DIN <= 9'b011_000_001;
		#40
		Run <= 1'b0;
		$finish;
	end
 
	// Clock
	always begin
		Clock = #5 ~Clock;
	end
 endmodule
