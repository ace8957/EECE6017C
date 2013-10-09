// ----------------------------------------------------------------- 
// 
// bcd7seg.v - bcd to 7-segment decoder 
// 
// Note: a-g active low 
// 
// Adapted from Listing 5.18 (Example 13a) in "Learning by Example 
// Using Verilog: Basic Digital Design with a BASYS FPGA Board," 
// Richard Haskell and Darrin Hanna, LBE Books, LLC, 2008. 
// 
// Adapter: H. Carter 
// Created: 7 Feb 08 
// 
// ------------------------------------------------------------------ 
module bcd7seg ( 
 input [3:0] bcd, 
 output reg [6:0] a_to_g 
); 
 
always @ (bcd) begin 
	case (bcd) 
		0: a_to_g = 7'b0000001; 
		1: a_to_g = 7'b1001111; 
		2: a_to_g = 7'b0010010; 
		3: a_to_g = 7'b0000110; 
		4: a_to_g = 7'b1001100; 
		5: a_to_g = 7'b0100100; 
		6: a_to_g = 7'b1100000; 
		7: a_to_g = 7'b0001111; 
		8: a_to_g = 7'b0000000; 
		9: a_to_g = 7'b0001100; 
		'hA: a_to_g = 7'b1110010; 
		'hB: a_to_g = 7'b1100110; 
		'hC: a_to_g = 7'b1011100; 
		'hD: a_to_g = 7'b0110100; 
		'hE: a_to_g = 7'b1110000; 
		'hF: a_to_g = 7'b1111111; 
		default: a_to_g = 7'b0000001; // 0 
	endcase 
end 
endmodule 
