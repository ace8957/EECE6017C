module switch_load(clock, switches, value);

input clock;//clock input
output reg [8:0] value;//output value of the switches
input [8:0] switches;//we will connect the physical switches here

always @(posedge clock) begin
	value <= switches;
end

endmodule
