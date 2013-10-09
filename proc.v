/**
 * Embedded Systems (EECE6017C) - Lab 4
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
 * 09 18 13 			Initial development
 * 09 19 13	AWS			Added GPRs and associated control signals. Defined bus drivers.
 * 09 25 13				Began development on enhanced version on new branch
 */

/**
 * Module proc
 * Enhanced processor with a 9-bit synchronous memory interface and program counter
 * DIN (9-bit, Little Endian) [in] - Data input, values from memory are read in through this port.
 * Resetn (1-bit) [in] - Active low reset
 * Clock (1-bit) [in] - Enable for internal registers
 * Run (1-bit) [in] - While hight, this signal will allow the processor to continue execution
 * Done (1-bit) [out] - This signal goes high when an instruction has completed
 * DOUT (9-bit, Little Endian) [out] - Data being sent to memory
 * ADDR (9-bit, Little Endian) [out] - Address to access from memory
 * W (1-bit) [out] - Memory write enable
 */
module proc (DIN, Resetn, Clock, Run, DOUT, ADDR, W);
	input [8:0] DIN;
	input Resetn, Clock, Run;
	output reg W;
	output [8:0] DOUT;
	output [8:0] ADDR;

	parameter T0 = 3'b000, T1 = 3'b001, T2 = 3'b010, T3 = 3'b011, T4 = 3'b100, T5 = 3'b101, T6 = 3'b110;
	parameter mv = 3'b000, mvi = 3'b001, add = 3'b010, sub = 3'b011, ld = 3'b100, st = 3'b101, mvnz = 3'b110;
	parameter reg0 = 10'b1000000000,
				 reg1 = 10'b0100000000,
				 reg2 = 10'b0010000000,
				 reg3 = 10'b0001000000,
				 reg4 = 10'b0000100000,
				 reg5 = 10'b0000010000,
				 reg6 = 10'b0000001000,
				 pcout = 10'b0000000100,
				 gout = 10'b0000000010,
				 dinout = 10'b0000000001;
	
	//declare variables
	reg [2:0] Tstep_Q;
	reg [2:0] Tstep_D;
	reg [8:0] BusWires;
	reg Done;
	wire [2:0] I;
	wire [0:7] regX, regY; ///<-- These are 1-hot encoding, Big Endian!!
	wire [8:0] IRoutWires;
	wire [8:0] GinWires, GoutWires;
	wire [8:0] AoutWires;
	wire GNZ;
	or(GNZ, GoutWires[0],
				GoutWires[1],
				GoutWires[2],
				GoutWires[3],
				GoutWires[4],
				GoutWires[5],
				GoutWires[6],
				GoutWires[7],
				GoutWires[8]
	);
	// Register input signals
	reg [0:7] Rin;
	reg [0:9] busDriver; ///< [R0out, ..., R6out, PCout, Gout, DINout]
	
	// Control Signals
	reg IRin, DINout, RYout, RYin, RXout, RXin, Ain, Gin, Gout, AddSub,
		 PCincr, PCout, ADDRin, DOUTin, W_D;
 
	assign I = IRoutWires[8:6];
	dec3to8 decX (IRoutWires[5:3], 1'b1, regX);
	dec3to8 decY (IRoutWires[2:0], 1'b1, regY);
		
	initial begin
		IRin <= 0;
		Done <= 0;
		DINout <= 1;
		RYout <= 0;
		RYin <= 0;
		RXout <= 0;
		RXin <= 0;
		Ain <= 0;
		Gin <= 0;
		Gout <= 0;
		AddSub <= 0;
		PCout <= 0;
		ADDRin <= 0;
		DOUTin <= 0;
		W_D <= 0;
		PCincr <= 0;
	end
	
	// Control FSM state table change
    always @(Tstep_Q, Run, Done)
    begin
	 // Default Tstep_D value:
	 Tstep_D = T0;
		if(Done) begin
			Tstep_D <= T0;
		end
		else begin
        case (Tstep_Q)
            T0: // data is loaded into IR in this time step
				begin
				if(!Run)
					Tstep_D <= T0;
				else
					Tstep_D <= T1;
				end
            T1:
				begin
					Tstep_D <= T2;
				end
				T2:
				begin
					Tstep_D <= T3;
				end
				T3:
				begin
					Tstep_D <= T4;
				end
				T4:
				begin
					Tstep_D <= T5;
				end
				T5:
				begin
					Tstep_D <= T6;
				end
				T6:
				begin
					Tstep_D <= T0;
				end
				default:
					Tstep_D <= T0;
        endcase
	  end
    end

	// Control FSM outputs
	always @(Tstep_Q or I or GNZ)
	begin
		$display("Doing timestep %d\n", Tstep_Q);
		case (Tstep_Q)
		T0: // store DIN in IR in time step 0
			begin
				IRin <= 0;
				Done <= 0;
				DINout <= 0;
				RYout <= 0;
				RYin <= 0;
				RXout <= 0;
				RXin <= 0;
				Ain <= 0;
				Gin <= 0;
				Gout <= 0;
				AddSub <= 0;
				PCout <= 1;
				ADDRin <= 1;
				DOUTin <= 0;
				W_D <= 0;
				PCincr <= 0;
			end
		T1:
			begin
				IRin <= 0;
				Done <= 0;
				DINout <= 1;
				RYout <= 0;
				RYin <= 0;
				RXout <= 0;
				RXin <= 0;
				Ain <= 0;
				Gin <= 0;
				Gout <= 0;
				AddSub <= 0;
				PCout <= 0;
				ADDRin <= 0;
				DOUTin <= 0;
				W_D <= 0;
				PCincr <= 0;
			end
		T2:
			begin
				IRin <= 1;
				Done <= 0;
				DINout <= 0;
				RYout <= 0;
				RYin <= 0;
				RXout <= 0;
				RXin <= 0;
				Ain <= 0;
				Gin <= 0;
				Gout <= 0;
				AddSub <= 0;
				PCout <= 0;
				ADDRin <= 0;
				DOUTin <= 0;
				W_D <= 0;
				PCincr <= 1;
			end
		T3: //define signals in time step 1
			begin
			$display("I = %b\n", I);
			case (I)
				mv: 
				begin
					IRin <= 0;
					Done <= 1;
					DINout <= 0;
					RYout <= 1;
					RYin <= 0;
					RXout <= 0;
					RXin <= 1;
					Ain <= 0;
					Gin <= 0;
					Gout <= 0;
					AddSub <= 0;
					PCout <= 0;
					ADDRin <= 0;
					DOUTin <= 0;
					W_D <= 0;
					PCincr <= 0;
				end
				mvi:
				begin
					IRin <= 0;
					Done <= 0;
					DINout <= 0;
					RYout <= 0;
					RYin <= 0;
					RXout <= 0;
					RXin <= 0;
					Ain <= 0;
					Gin <= 0;
					Gout <= 0;
					AddSub <= 0;
					PCout <= 1;
					ADDRin <= 1;
					DOUTin <= 0;
					W_D <= 0;
					PCincr <= 0;
				end
				add:
				begin
					IRin <= 0;
					Done <= 0;
					DINout <= 0;
					RYout <= 0;
					RYin <= 0;
					RXout <= 1;
					RXin <= 0;
					Ain <= 1;
					Gin <= 0;
					Gout <= 0;
					AddSub <= 0;
					PCout <= 0;
					ADDRin <= 0;
					DOUTin <= 0;
					W_D <= 0;
					PCincr <= 0;
				end
				sub:
				begin
					IRin <= 0;
					Done <= 0;
					DINout <= 0;
					RYout <= 0;
					RYin <= 0;
					RXout <= 1;
					RXin <= 0;
					Ain <= 1;
					Gin <= 0;
					Gout <= 0;
					AddSub <= 0;
					PCout <= 0;
					ADDRin <= 0;
					DOUTin <= 0;
					W_D <= 0;
					PCincr <= 0;
				end
				ld:
				begin
					IRin <= 0;
					Done <= 0;
					DINout <= 0;
					RYout <= 1;
					RYin <= 0;
					RXout <= 0;
					RXin <= 0;
					Ain <= 0;
					Gin <= 0;
					Gout <= 0;
					AddSub <= 0;
					PCout <= 0;
					ADDRin <= 1;
					DOUTin <= 0;
					W_D <= 0;
					PCincr <= 0;
				end
				st:
				begin
					$display("Doing st on tstep 3\n");
					IRin <= 0;
					Done <= 0;
					DINout <= 0;
					RYout <= 1;
					RYin <= 0;
					RXout <= 0;
					RXin <= 0;
					Ain <= 0;
					Gin <= 0;
					Gout <= 0;
					AddSub <= 0;
					PCout <= 0;
					ADDRin <= 1;
					DOUTin <= 0;
					W_D <= 0;
					PCincr <= 0;
				end
				mvnz:
				begin
					if(GNZ)
					begin
						IRin <= 0;
						Done <= 1;
						DINout <= 0;
						RYout <= 1;
						RYin <= 0;
						RXout <= 0;
						RXin <= 1;
						Ain <= 0;
						Gin <= 0;
						Gout <= 0;
						AddSub <= 0;
						PCout <= 0;
						ADDRin <= 0;
						DOUTin <= 0;
						W_D <= 0;
						PCincr <= 0;
					end
					else  begin
						IRin <= 0;
						Done <= 1;
						DINout <= 0;
						RYout <= 0;
						RYin <= 0;
						RXout <= 0;
						RXin <= 0;
						Ain <= 0;
						Gin <= 0;
						Gout <= 0;
						AddSub <= 0;
						PCout <= 0;
						ADDRin <= 0;
						DOUTin <= 0;
						W_D <= 0;
						PCincr <= 0;
					end
				end
				default:
				begin
					IRin <= 0;
					Done <= 0;
					DINout <= 1;
					RYout <= 0;
					RYin <= 0;
					RXout <= 0;
					RXin <= 0;
					Ain <= 0;
					Gin <= 0;
					Gout <= 0;
					AddSub <= 0;
					PCout <= 0;
					ADDRin <= 0;
					DOUTin <= 0;
					W_D <= 0;
					PCincr <= 0;
				end
			endcase
			end
		T4: //define signals in time step 3
			begin
			case (I)
				add:
				begin
					IRin <= 0;
					Done <= 0;
					DINout <= 0;
					RYout <= 1;
					RYin <= 0;
					RXout <= 0;
					RXin <= 0;
					Ain <= 0;
					Gin <= 1;
					Gout <= 0;
					AddSub <= 0;
					PCout <= 0;
					ADDRin <= 0;
					DOUTin <= 0;
					W_D <= 0;
					PCincr <= 0;
				end
				sub:
				begin
					IRin <= 0;
					Done <= 0;
					DINout <= 0;
					RYout <= 1;
					RYin <= 0;
					RXout <= 0;
					RXin <= 0;
					Ain <= 0;
					Gin <= 1;
					Gout <= 0;
					AddSub <= 1;
					PCout <= 0;
					ADDRin <= 0;
					DOUTin <= 0;
					W_D <= 0;
					PCincr <= 0;
				end
				default:
				begin		
					IRin <= 0;
					Done <= 0;
					DINout <= 1;
					RYout <= 0;
					RYin <= 0;
					RXout <= 0;
					RXin <= 0;
					Ain <= 0;
					Gin <= 0;
					Gout <= 0;
					AddSub <= 0;
					PCout <= 0;
					ADDRin <= 0;
					DOUTin <= 0;
					W_D <= 0;
					PCincr <= 0;
				end
			endcase
			end
		T5: //define signals in time step 3
			begin
			case (I)
				mvi:
				begin	
					IRin <= 0;
					Done <= 1;
					DINout <= 1;
					RYout <= 0;
					RYin <= 0;
					RXout <= 0;
					RXin <= 1;
					Ain <= 0;
					Gin <= 0;
					Gout <= 0;
					AddSub <= 0;
					PCout <= 0;
					ADDRin <= 0;
					DOUTin <= 0;
					W_D <= 0;
					PCincr <= 1;
				end
				add:
				begin
					IRin <= 0;
					Done <= 1;
					DINout <= 0;
					RYout <= 0;
					RYin <= 0;
					RXout <= 0;
					RXin <= 1;
					Ain <= 0;
					Gin <= 0;
					Gout <= 1;
					AddSub <= 0;
					PCout <= 0;
					ADDRin <= 0;
					DOUTin <= 0;
					W_D <= 0;
					PCincr <= 0;
				end
				sub:
				begin
					IRin <= 0;
					Done <= 1;
					DINout <= 0;
					RYout <= 0;
					RYin <= 0;
					RXout <= 0;
					RXin <= 1;
					Ain <= 0;
					Gin <= 0;
					Gout <= 1;
					AddSub <= 0;
					PCout <= 0;
					ADDRin <= 0;
					DOUTin <= 0;
					W_D <= 0;
					PCincr <= 0;
				end
				ld:
				begin
					IRin <= 0;
					Done <= 1;
					DINout <= 1;
					RYout <= 0;
					RYin <= 0;
					RXout <= 0;
					RXin <= 1;
					Ain <= 0;
					Gin <= 0;
					Gout <= 0;
					AddSub <= 0;
					PCout <= 0;
					ADDRin <= 0;
					DOUTin <= 0;
					W_D <= 0;
					PCincr <= 0;
				end
				st:
				begin	
					IRin <= 0;
					Done <= 0;
					DINout <= 0;
					RYout <= 0;
					RYin <= 0;
					RXout <= 1;
					RXin <= 0;
					Ain <= 0;
					Gin <= 0;
					Gout <= 0;
					AddSub <= 0;
					PCout <= 0;
					ADDRin <= 0;
					DOUTin <= 1;
					W_D <= 1;
					PCincr <= 0;
				end
				default:
				begin
					IRin <= 0;
					Done <= 0;
					DINout <= 1;
					RYout <= 0;
					RYin <= 0;
					RXout <= 0;
					RXin <= 0;
					Ain <= 0;
					Gin <= 0;
					Gout <= 0;
					AddSub <= 0;
					PCout <= 0;
					ADDRin <= 0;
					DOUTin <= 0;
					W_D <= 0;
					PCincr <= 0;
				end
			endcase
			end
			T6: begin
				case(I)
					st:
					begin
						IRin <= 0;
						Done <= 1;
						DINout <= 1;
						RYout <= 0;
						RYin <= 0;
						RXout <= 0;
						RXin <= 0;
						Ain <= 0;
						Gin <= 0;
						Gout <= 0;
						AddSub <= 0;
						PCout <= 0;
						ADDRin <= 0;
						DOUTin <= 0;
						W_D <= 0;
						PCincr <= 0;
					end
					default:
					begin
						IRin <= 0;
						Done <= 0;
						DINout <= 1;
						RYout <= 0;
						RYin <= 0;
						RXout <= 0;
						RXin <= 0;
						Ain <= 0;
						Gin <= 0;
						Gout <= 0;
						AddSub <= 0;
						PCout <= 0;
						ADDRin <= 0;
						DOUTin <= 0;
						W_D <= 0;
						PCincr <= 0;
					end
				endcase
			end
			default:
			begin
				IRin <= 0;
				Done <= 0;
				DINout <= 1;
				RYout <= 0;
				RYin <= 0;
				RXout <= 0;
				RXin <= 0;
				Ain <= 0;
				Gin <= 0;
				Gout <= 0;
				AddSub <= 0;
				PCout <= 0;
				ADDRin <= 0;
				DOUTin <= 0;
				W_D <= 0;
				PCincr <= 0;
			end
		endcase
	end
	
	// Control FSM flip-flops
	always @(posedge Clock, negedge Resetn) begin
		if (!Resetn) begin
			Tstep_Q <= T0;
			W <= 0;
		end
		else begin
			Tstep_Q <= Tstep_D;
			W <= W_D;
		end
	end
	
	/** General Purpose Register Instantiations **/
	
	// Register outputs
	wire [8:0] R0, R1, R2, R3, R4, R5, R6, PC;
	
	// General Purpose Registers
	regn reg_0(BusWires, Rin[0], Clock, R0);

	regn reg_1(BusWires, Rin[1], Clock, R1);				
	
	regn reg_2(BusWires, Rin[2], Clock, R2);
				
	regn reg_3(BusWires, Rin[3], Clock, R3);
	
	regn reg_4(BusWires, Rin[4], Clock, R4);
	
	regn reg_5(BusWires, Rin[5], Clock, R5);
	
	regn reg_6(BusWires, Rin[6], Clock, R6);
	
	regn addr_reg(BusWires, ADDRin, Clock, ADDR);
	
	regn dout_reg(BusWires, DOUTin, Clock, DOUT);
	
	counter reg_pc(Clock, Resetn, PCincr, Rin[7], BusWires, PC);
	
	/** Register A **/
	regn reg_a(BusWires, Ain, Clock, AoutWires);
	
	/** Register G **/

	regn reg_g(GinWires, Gin, Clock, GoutWires);
	
	/** Instruction Register **/
	regn reg_ir(DIN, IRin, Clock, IRoutWires);
	
	addsub Addsub(AddSub, AoutWires, BusWires, GinWires);
	

	always @ (RXout, RYout, Gout, DINout, PCout, regX, regY)
	begin // Check control signals and set appropriate flip-flops
		//RYin, RXin, Ain, Gin, AddSub;
			// Set the bus driver
			if(DINout && !(RXout || RYout || Gout || PCout)) begin
				busDriver = 10'b0000000001;
			end
			else if(RXout && !(DINout || RYout || Gout || PCout)) begin
				busDriver = {regX, 1'b0, 1'b0};
			end
			else if(RYout && !(RXout || DINout || Gout || PCout)) begin
				busDriver = {regY, 1'b0, 1'b0};
			end
			else if(Gout && !(RXout || RYout || DINout || PCout)) begin
				busDriver = gout;
			end
			else if(PCout && !(RXout || RYout || DINout || Gout)) begin
				busDriver = pcout;
			end
			else begin
				$display("Ambiguous bus driver!! Setting to DINout at time ");
				$display($time);
				$display("DINout = %b\nRXout = %b\nRYout = %b\nGout = %b\nPCout = %b\n",
							DINout, RXout, RYout, Gout, PCout);
				busDriver = dinout;
			end
			
	end
	
	always @ (RXin, RYin, regX, regY)
	begin
		Rin = 8'b00000000;
		if(RXin) begin
			Rin = Rin | regX;
		end
		
		if(RYin) begin
			Rin = Rin | regY;
		end
	end
	
	// Define the bus
	always @ (busDriver, R0, R1, R2, R3, R4, R5, R6, PC, GoutWires, DIN) begin
		case(busDriver)
			reg0: BusWires <= R0;
			reg1: BusWires <= R1;
			reg2: BusWires <= R2;
			reg3: BusWires <= R3;
			reg4: BusWires <= R4;
			reg5: BusWires <= R5;
			reg6: BusWires <= R6;
			pcout: BusWires <= PC;
			gout: BusWires <= GoutWires;
			dinout: BusWires <= DIN;
			default:
			begin
				$display("Undefined bus driver!! Defaulting to DIN at time ");
				$display($time);
				BusWires <= DIN;
			end
		endcase
	end
endmodule
