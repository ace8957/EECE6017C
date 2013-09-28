module seg7_scroll(segment, valuein, Write, clock, valueout);

input [3:0] segment;
input [8:0] valuein;
input Write, clock;
output [8:0] valueout;

//wire [8:0] segValue;
//this is something I don't think is actually needed just have in the address slot which seg you would like
//dec3to8 operation(segment, clock, segValue);

/// one register for each 7 segment display
regn seg_0(valuein, segment[0], Write, valueout);
regn seg_1(valuein, segment[1], Write, valueout);
regn seg_2(valuein, segment[2], Write, valueout);
regn seg_3(valuein, segment[3], Write, valueout);

endmodule