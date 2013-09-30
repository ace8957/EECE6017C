/**
 * Embedded Systems (EECE6017C) - Lab 3
 * Simple Processor
 * Author(s): Alex Stephens <stephea5@mail.uc.edu> (AWS)
 *	      	  Josh Boroff <boroffja@mail.uc.edu> (JBB)
 *	      	  Adam Wilford <wilforaf@mail.uc.edu> (AFW)
 * Target FPGA: Altera Cyclone II 2C20 (EP2C20F484C7)
 * Tool: Quartus II 64-bit
 * Version: 13.0.1 sp1
 */
 
/**
 * Module seg7_scroll - Write the given value to 4 7-segment displays
 * segment (4-bits, Little Endian) [in] - 1-hot encoding for which display
 *										  to write to
 * valuein (9-bits, Little Endian) [in] - Value to show across the displays
 * Write (1-bit) [in] - A posedge makes the display show the new value
 * clock (1-bit) [in] - Clock to drive sequential logic
 * seg_0_output_wires (9-bits, Little Endian) [out]- Wires to drive the actual display 0
 * seg_1_output_wires (9-bits, Little Endian) [out]- Wires to drive the actual display 1
 * seg_2_output_wires (9-bits, Little Endian) [out]- Wires to drive the actual display 2
 * seg_3_output_wires (9-bits, Little Endian) [out]- Wires to drive the actual display 3
 */
module seg7_scroll(segment, valuein, Write, clock, seg_0_output_wires,
					seg_1_output_wires, seg_2_output_wires, seg_3_output_wires);

input [3:0] segment;
input [8:0] valuein;
input Write, clock;
output [8:0] seg_0_output_wires;
output [8:0] seg_1_output_wires;
output [8:0] seg_2_output_wires;
output [8:0] seg_3_output_wires;

//wire [8:0] segValue;
//this is something I don't think is actually needed just have in the address slot which seg you would like
//dec3to8 operation(segment, clock, segValue);

/// one register for each 7 segment display
regn seg_0(valuein, segment[0], Write, seg_0_output_wires);
regn seg_1(valuein, segment[1], Write, seg_1_output_wires);
regn seg_2(valuein, segment[2], Write, seg_2_output_wires);
regn seg_3(valuein, segment[3], Write, seg_3_output_wires);

endmodule