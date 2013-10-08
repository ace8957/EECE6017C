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
 * Module regn - this module is used to create the registers from example code
 * R - Bus wires for inputing into the reg
 * Rin - the input signal to say if data needs out
 * Clock - the clock for things to happen
 * Q - the output of what is in the reg
 */
module regn(R, Rin, Clock, Q);
parameter n = 9;
input [n-1:0] R;
input Rin, Clock;
output [n-1:0] Q;
reg [n-1:0] Q;
initial begin
    Q <= 0;
end
always @(posedge Clock)
	if (Rin)
		Q <= R;
endmodule
