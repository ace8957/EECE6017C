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
 * 09 18 13 				Initial development
 * 09 19 13	AWS			Added GPRs and associated control signals. Defined bus drivers.
 * 09 25 13					Began development on enhanced version on new branch
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
module proc (DIN, Resetn, Clock, Run, Done, DOUT, ADDR, W);
	input [8:0] DIN;
	input Resetn, Clock, Run;
	output reg Done, W;
	output reg [8:0] DOUT, ADDR;


	parameter T0 = 2'b00, T1 = 2'b01, T2 = 2'b10, T3 = 2'b11;
	parameter mv = 3'b000, mvi = 3'b001, add = 3'b010, sub = 3'b011, ld = 3'b100, st = 3'b101, mvnz = 3'b110;
	parameter reg0 = 10'b1000000000,
				 reg1 = 10'b0100000000,
				 reg2 = 10'b0010000000,
				 reg3 = 10'b0001000000,
				 reg4 = 10'b0000100000,
				 reg5 = 10'b0000010000,
				 reg6 = 10'b0000001000,
				 reg7 = 10'b0000000100,
				 gout = 10'b0000000010,
				 dinout = 10'b0000000001;
	
	//declare variables
	reg [1:0] Tstep_Q;
	reg [1:0] Tstep_D;
	wire [2:0] I;
	wire [0:7] regX, regY; ///<-- These are 1-hot encoding, Big Endian!!
	wire [8:0] IRoutWires;
	wire [8:0] GinWires, GoutWires;
	wire [8:0] AoutWires;
	// Register input signals
	reg [0:7] Rin;
	reg [0:9] busDriver; ///< [R0out, ..., R7out, Gout, DINout]
	
	// Control Signals
	reg IRin, DINout, RYout, RYin, RXout, RXin, Ain, Gin, Gout, AddSub,
		 ;
 
	assign I = IRoutWires[8:6];
	dec3to8 decX (IRoutWires[5:3], 1'b1, regX);
	dec3to8 decY (IRoutWires[2:0], 1'b1, regY);
		
	// Control FSM state table change
    always @(Tstep_Q, Run, Done)
    begin
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
					Tstep_D <= T0;
				end
        endcase
	  end
    end

	// Control FSM outputs
	always @(Tstep_Q or I or regX or regY)
	begin
		//: : : specify initial values
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
		//reg IRin, DINout, RYout, RYin, RXout, RXin, Ain, Gin, Gout, AddSub;
		case (Tstep_Q)
		T0: // store DIN in IR in time step 0
			begin
			//IRin <= 1;
				PCout <= 1;
				ADDRin <= 1;
			end
		T1:
			begin
				IRin <=1;
				PCincr <=1;
		T2: //define signals in time step 1
			case (I)
				mv: 
				begin
					RYout <= 1;
					RXin <= 1;
					Done <= 1;			
				end
				mvi:
				begin
					PCout <=1;
					ADDRin <=1;
				end
				add:
				begin
					RXout <= 1;
					Ain <= 1;
				end
				sub:
				begin
					RXout <= 1;
					Ain <= 1;
				end
				ld:
				begin
					RYout <=1;
					ADDRin <=1;
				end
				st:
				begin
					RYout <=1;
					ADDRin <=1;
				end
				mvnz:
				begin
					if(GNZ)
					begin
						RYout <=1;
						ADDRin <=1;
					end
					else Done <= 1;
				end
				default:
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
				end
			endcase
		T3: //define signals in time step 3
			case (I)
				mvi:
				begin	
					PCincr <=1;
					DINout <=1;
					RXin <=1;
					Done <=1;
				add:
				begin
					RYout <= 1;
					Gin <= 1;				
				end
				sub:
				begin
					RYout <= 1;
					Gin <= 1;
					AddSub <= 1;
				end
				ld:
				begin
					DINout <=1;
					RXin <=1;
					Done <=1;
				end
				st:
				begin	
					RXout <=1;
					DOUTin <=1;
					W_D <=1;
					Done <=1;//This may need to be in another step unsure
				default:
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
				end
			endcase
		T4: //define signals in time step 3
			case (I)
				add:
				begin
					Done <= 1;
					Gout <= 1;
					RXin <= 1;
				end
				sub:
				begin
					Done <= 1;
					RXin <= 1;
					Gout <= 1;				
				end
				default:
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
				end
			endcase
		endcase
	end
	
	// Control FSM flip-flops
	always @(posedge Clock, negedge Resetn) begin
		if (!Resetn) begin
			// Reset all FSM flip-flops
			/*
			busDriver = dinout;
			DINout = 0;
			RYout = 0;
			RYin = 0;
			RXout = 0;
			RXin = 0;
			Ain = 0;
			Gin = 0;
			Gout = 0;
			AddSub = 0;
			Tstep_Q = 2'b00;
			Tstep_D = 2'b00;
			*/
		end
		else Tstep_Q <= Tstep_D;
		
	end
	
	/** General Purpose Register Instantiations **/
	
	// Register outputs
	wire [8:0] R0, R1, R2, R3, R4, R5, R6, R7;
	
	// General Purpose Registers
	regn reg_0(BusWires, Rin[0], Clock, R0);

	regn reg_1(BusWires, Rin[1], Clock, R1);				
	
	regn reg_2(BusWires, Rin[2], Clock, R2);
				
	regn reg_3(BusWires, Rin[3], Clock, R3);
	
	regn reg_4(BusWires, Rin[4], Clock, R4);
	
	regn reg_5(BusWires, Rin[5], Clock, R5);
	
	regn reg_6(BusWires, Rin[6], Clock, R6);
	
	regn reg_7(BusWires, Rin[7], Clock, R7);
	
	/** Register A **/
	regn reg_a(BusWires, Ain, Clock, AoutWires);
	
	/** Register G **/

	regn reg_g(GinWires, Gin, Clock, GoutWires);
	
	/** Instruction Register **/
	regn reg_ir(DIN, IRin, Clock, IRoutWires);
	
	addsub Addsub(AddSub, AoutWires, BusWires, GinWires);
	

	always @ (RXout, RYout, Gout, DINout, regX, regY)
	begin // Check control signals and set appropriate flip-flops
		//RYin, RXin, Ain, Gin, AddSub;
			// Set the bus driver
			if(DINout && !(RXout || RYout || Gout)) begin
				busDriver = 10'b0000000001;
			end
			else if(RXout && !(DINout || RYout || Gout)) begin
				busDriver = {regX, 1'b0, 1'b0};
			end
			else if(RYout && !(RXout || DINout || Gout)) begin
				busDriver = {regY, 1'b0, 1'b0};
			end
			else if(Gout && !(RXout || RYout || DINout)) begin
				busDriver = 10'b0000000010;
			end
			else begin
				$display("Ambiguous bus driver!! Setting to DINout\n");
				busDriver = 10'b0000000001;
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
	always @ (busDriver, R0, R1, R2, R3, R4, R5, R6, R7, GoutWires, DIN) begin
		case(busDriver)
			reg0: BusWires <= R0;
			reg1: BusWires <= R1;
			reg2: BusWires <= R2;
			reg3: BusWires <= R3;
			reg4: BusWires <= R4;
			reg5: BusWires <= R5;
			reg6: BusWires <= R6;
			reg7: BusWires <= R7;
			gout: BusWires <= GoutWires;
			dinout: BusWires <= DIN;
			default:
			begin
				$display("Undefined bus driver!! Defaulting to DIN!!\n");
				BusWires <= DIN;
			end
		endcase
	end
	

	
	
endmodule
