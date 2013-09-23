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
 * 09 18 13 				Initial development
 * 09 19 13	AWS			Added GPRs and associated control signals. Defined bus drivers.
 */

/**
 * Module proc
 * Simple processor which can perform add, subtract, move, and move immediate
 * instructions. All values are expected to be Little Endian.
 * DIN (9-bit, Little Endian) [in] - Instructions and immediate data are read in through this port
 * Resetn (1-bit) [in] - Active low reset
 * Clock (1-bit) [in] - Enable for internal registers
 * Run (1-bit) [in] - While hight, this signal will allow the processor to continue execution
 * Done (1-bit) [out] - This signal goes high when an instruction has completed
 * BusWires (9-bit, Little Endian) [out] - Holds that value of what is currently being sent around
 */
module proc (DIN, Resetn, Clock, Run, Done, BusWires);
	// Inputs
	input [8:0] DIN;
	input Resetn;
	input Clock;
	input Run;

	// Outputs
	output Done;
	output [8:0] BusWires;

	// Type Declaration for Input
	wire [8:0] DIN;
	wire Resetn;
	wire Clock;
	wire Run;
	// Type Declaration for Output
	reg Done;
	wire [8:0] BusWires;

	parameter T0 = 2'b00,
				 T1 = 2'b01,
				 T2 = 2'b10,
				 T3 = 2'b11;
	// FSM State Registers
	reg [1:0] Tstep, Tstep_next;
	
	// Control Signals
	reg [7:0] Rin;
	reg Ain, Gin, IRin;
	reg DINout, Gout;
	reg [7:0] Rout;
	reg AddSub;

	parameter mv  = 3'b000,
				 mvi = 3'b001,
				 add = 3'b010,
				 sub = 3'b011;
	// Helpful Sections of wire
	wire [2:0] opcode;
	assign opcode = wIR[8:6];
	
	wire [2:0] Rx3, Ry3;
	assign Rx3 = wIR[5:3];
	assign Ry3 = wIR[2:0];
	
	wire [7:0] Rx, Ry;
	dec3to8 decodeX(Rx3, 1'b1, Rx);
	dec3to8 decodeY(Ry3, 1'b1, Ry);
	
	// Concatenation of *out signals
	wire [9:0] busMuxSelect; ///< {DINout, Gout, R7Out, ..., R0Out}
	assign busMuxSelect = {DINout, Gout, Rout};	
	
	// FSM Next State, depends on current state, run, and resetn
	always @ (Tstep, wIR)
	begin
		if(Done || !Resetn)
			Tstep_next <= T0;
		else begin
			case(Tstep)
				T0: begin
					Tstep_next <= T1;
				end
				T1: begin
					case(opcode)
						mv:
							Tstep_next <= T0;
						mvi:
							Tstep_next <= T0;
						add:
							Tstep_next <= T2;
						sub:
							Tstep_next <= T2;
						default:
							Tstep_next <= T0;
					endcase
				end
				T2: begin
					Tstep_next <= T3;
				end
				T3: begin
					Tstep_next <= T0;
				end
				default: begin
					Tstep_next <= T0;
				end
			endcase
		end
	end
	
	// FSM Output (Control Signals) based on current state an inputs
	always @ (posedge Clock, negedge Resetn, posedge Run)
	begin
		if(!Resetn) begin
			Rin <= 8'b0000_0000;
			Ain <= 1'b0;
			Gin <= 1'b0;
			IRin <= 1'b1;
			AddSub <= 1'b0;
			DINout <= 1'b1;
			Gout <= 1'b0;
			Rout <= 8'b0000_0000;
			Done <= 1'b0;
		end
		else if(Run) begin
			case(Tstep)
				T0: begin
					Rin <= 8'b0000_0000;
					Ain <= 1'b0;
					Gin <= 1'b0;
					IRin <= 1'b1;
					AddSub <= 1'b0;
					DINout <= 1'b1;
					Gout <= 1'b0;
					Rout <= 8'b0000_0000;
					Done <= 1'b0;
				end
				T1: begin
					case(opcode)
						mv: begin
							Rin <= Rx;
							Ain <= 1'b0;
							Gin <= 1'b0;
							IRin <= 1'b0;
							AddSub <= 1'b0;
							DINout <= 1'b0;
							Gout <= 1'b0;
							Rout <= Ry;
							Done <= 1'b1;
						end
						mvi: begin
							Rin <= Rx;
							Ain <= 1'b0;
							Gin <= 1'b0;
							IRin <= 1'b0;
							AddSub <= 1'b0;
							DINout <= 1'b1;
							Gout <= 1'b0;
							Rout <= 8'b0000_0000;
							Done <= 1'b1;
						end
						add: begin
							Rin <= 8'b0000_0000;
							Ain <= 1'b1;
							Gin <= 1'b0;
							IRin <= 1'b0;
							AddSub <= 1'b0;
							DINout <= 1'b0;
							Gout <= 1'b0;
							Rout <= Rx;
							Done <= 1'b0;
						end
						sub: begin
							Rin <= 8'b0000_0000;
							Ain <= 1'b1;
							Gin <= 1'b0;
							IRin <= 1'b0;
							AddSub <= 1'b0;
							DINout <= 1'b0;
							Gout <= 1'b0;
							Rout <= Rx;
							Done <= 1'b0;
						end
						default: begin
							Rin <= 8'b0000_0000;
							Ain <= 1'b0;
							Gin <= 1'b0;
							IRin <= 1'b1;
							AddSub <= 1'b0;
							DINout <= 1'b1;
							Gout <= 1'b0;
							Rout <= 8'b0000_0000;
							Done <= 1'b0;
						end
					endcase
				end
				T2: begin
					case(opcode)
						mv: begin
							$display("Error in FSM. mv should not get to T2\n");
							Rin <= Rx;
							Ain <= 1'b0;
							Gin <= 1'b0;
							IRin <= 1'b0;
							AddSub <= 1'b0;
							DINout <= 1'b0;
							Gout <= 1'b0;
							Rout <= Ry;
							Done <= 1'b1;
						end
						mvi: begin
							$display("Error in FSM. mv should not get to T2\n");
							Rin <= Rx;
							Ain <= 1'b0;
							Gin <= 1'b0;
							IRin <= 1'b0;
							AddSub <= 1'b0;
							DINout <= 1'b1;
							Gout <= 1'b0;
							Rout <= 8'b0000_0000;
							Done <= 1'b1;
						end
						add: begin
							Rin <= 8'b0000_0000;
							Ain <= 1'b0;
							Gin <= 1'b1;
							IRin <= 1'b0;
							AddSub <= 1'b0;
							DINout <= 1'b0;
							Gout <= 1'b0;
							Rout <= Ry;
							Done <= 1'b0;
						end
						sub: begin
							Rin <= 8'b0000_0000;
							Ain <= 1'b0;
							Gin <= 1'b1;
							IRin <= 1'b0;
							AddSub <= 1'b1;
							DINout <= 1'b0;
							Gout <= 1'b0;
							Rout <= Ry;
							Done <= 1'b0;
						end
						default: begin
							Rin <= 8'b0000_0000;
							Ain <= 1'b0;
							Gin <= 1'b0;
							IRin <= 1'b1;
							AddSub <= 1'b0;
							DINout <= 1'b1;
							Gout <= 1'b0;
							Rout <= 8'b0000_0000;
							Done <= 1'b0;
						end
					endcase
				end
				T3: begin
					case(opcode)
						mv: begin
							$display("Error in FSM. mv should not get to T2\n");
							Rin <= Rx;
							Ain <= 1'b0;
							Gin <= 1'b0;
							IRin <= 1'b0;
							AddSub <= 1'b0;
							DINout <= 1'b0;
							Gout <= 1'b0;
							Rout <= Ry;
							Done <= 1'b1;
						end
						mvi: begin
							$display("Error in FSM. mv should not get to T2\n");
							Rin <= Rx;
							Ain <= 1'b0;
							Gin <= 1'b0;
							IRin <= 1'b0;
							AddSub <= 1'b0;
							DINout <= 1'b1;
							Gout <= 1'b0;
							Rout <= 8'b0000_0000;
							Done <= 1'b1;
						end
						add: begin
							Rin <= Rx;
							Ain <= 1'b0;
							Gin <= 1'b0;
							IRin <= 1'b0;
							AddSub <= 1'b0;
							DINout <= 1'b0;
							Gout <= 1'b1;
							Rout <= 8'b0000_0000;
							Done <= 1'b1;
						end
						sub: begin
							Rin <= Rx;
							Ain <= 1'b0;
							Gin <= 1'b0;
							IRin <= 1'b0;
							AddSub <= 1'b0;
							DINout <= 1'b0;
							Gout <= 1'b1;
							Rout <= 8'b0000_0000;
							Done <= 1'b1;
						end
						default: begin
							Rin <= 8'b0000_0000;
							Ain <= 1'b0;
							Gin <= 1'b0;
							IRin <= 1'b1;
							AddSub <= 1'b0;
							DINout <= 1'b1;
							Gout <= 1'b0;
							Rout <= 8'b0000_0000;
							Done <= 1'b0;
						end
					endcase
				end
				default: begin
					$display("Unknown State. That does not bode well for you\n");
				end
			endcase
		end else begin
			// Keep all control signals the same if not running
		end
		Tstep <= Tstep_next;
	end
	
	/** Instruction Register **/
	wire [8:0] wIR;
	regn regIR(DIN, IRin, Clock, wIR);
	
	/** General Purpose Registers **/
	wire [7:0] wR[0:8];
	regn reg0(BusWires, Rin[0], Clock, wR[0]);
	regn reg1(BusWires, Rin[1], Clock, wR[1]);
	regn reg2(BusWires, Rin[2], Clock, wR[2]);
	regn reg3(BusWires, Rin[3], Clock, wR[3]);
	regn reg4(BusWires, Rin[4], Clock, wR[4]);
	regn reg5(BusWires, Rin[5], Clock, wR[5]);
	regn reg6(BusWires, Rin[6], Clock, wR[6]);
	regn reg7(BusWires, Rin[7], Clock, wR[7]);
	
	/** A Register **/
	wire [8:0] wA;
	regn regA(BusWires, Ain, Clock, wA);
	
	/** Add Subtract unit **/
	wire wAddSub;
	addsub alu(AddSub, wA, BusWires, wAddSub);
	
	/** G Register **/
	wire wG;
	regn regG(wAddSub, Gin, Clock, wG);
	
	/** Set of multiplexers used to control bus access **/
	parameter r0Out = 10'b0000000001,
				 r1Out = 10'b0000000010,
				 r2Out = 10'b0000000100,
				 r3Out = 10'b0000001000,
				 r4Out = 10'b0000010000,
				 r5Out = 10'b0000100000,
				 r6Out = 10'b0001000000,
				 r7Out = 10'b0010000000,
				 rgOut = 10'b0100000000,
				 dOut  = 10'b1000000000;
	assign BusWires = (busMuxSelect == r0Out) ? wR[0] :(
							(busMuxSelect == r1Out) ? wR[1] :(
							(busMuxSelect == r2Out) ? wR[2] :(
							(busMuxSelect == r3Out) ? wR[3] :(
							(busMuxSelect == r4Out) ? wR[4] :(
							(busMuxSelect == r5Out) ? wR[5] :(
							(busMuxSelect == r6Out) ? wR[6] :(
							(busMuxSelect == r7Out) ? wR[7] :(
							(busMuxSelect == rgOut) ? wG :(
							(busMuxSelect == dOut ) ? DIN :
							DIN)))))))));

endmodule
