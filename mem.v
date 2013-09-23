module mem(mclock, pclock, resetn, run, done, bus);
	
	input mclock, pclock, resetn, run;
	output done;
	output [8:0] bus;
	
	
	wire [4:0] n;
	wire [8:0] data;
	
	counter count(mclock, resetn, n);
	
	memory memory_control(n, mclock, data);
	
	proc processor(data, resetn, pclock, run, done, bus);
	
endmodule
