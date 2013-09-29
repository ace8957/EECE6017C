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