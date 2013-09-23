module counter(clock, reset, n);
	input clock, reset;
	output reg [4:0] n;
	
	always @(posedge clock or negedge reset)
	begin
		if(!reset) n = 6'b000000;
		else begin
			n = n + 1;
		end
	end
endmodule