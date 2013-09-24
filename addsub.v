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
 * 09 19 13	AWS			Initial
 */

/**
 * module Addsub
 * Adds or subtracts two 9-bit inputs
 * Sub (1-bit) [in] - When this is asserted, this module will subtract the two numbers
 * A (9-bit, Little Endian) [in] - First operand, 2's complement signed integer
 * B (9-bit, Little Endian) [in] - Second operand, 2's complement signed integer
 * Out (9-bit, Little Endian) [out] - Result of operation, 2's complement signed integer
 */
module addsub(Sub, A, B, Out);
	input [8:0] A, B;
	input Sub;
	output [8:0] Out;
	
	assign Out = Sub ? A - B : A + B;
	
endmodule