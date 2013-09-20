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
	input [8:0] DIN;
	input Resetn, Clock, Run;
	output Done;
	output [8:0] BusWires;

	parameter T0 = 2'b00, T1 = 2'b01, T2 = 2'b10, T3 = 2'b11;
	parameter mv = 2'b00, mvi = 2'b01, add = 2'b10, sub = 2'b11;
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
	reg [0:9] busDriver; ///< [R0out, ..., R7out, Gout, DINout]
	
	// Control Signals
	reg DINout, RYout, RYin, RXout, RXin, Ain, Gin, Gout, AddSub;
 
	assign I = IRoutWires[8:6];
	dec3to8 decX (IR[4:6], 1'b1, Xreg);
	dec3to8 decY (IR[7:9], 1'b1, Yreg);
		
	// Control FSM state table change
    always @(Tstep_Q, Run, Done)
    begin
        case (Tstep_Q)
            T0: // data is loaded into IR in this time step
                if (!Run) Tstep_D = T0;
                else Tstep_D = T1;
            T1:
				begin
					if(!Done || Run) Tstep_D = T2;
					else Tstep_D = T0;
				end
				T2:
				begin
					if(!Run) Tstep_D = T0;
					else Tstep_D = T3;
				end
				T3:
				begin
					Tstep_D = T0;
				end
        endcase
    end

	// Control FSM outputs
	always @(Tstep_Q or I or Xreg or Yreg)
	begin
		//: : : specify initial values
		case (Tstep_Q)
		T0: // store DIN in IR in time step 0
			begin
			IRin = 1'b1;
			end
		T1: //define signals in time step 1
			case (I)
				mv: 
				begin
					RYout = 1;
					RXin = 1;
					Done = 1;
				end
				mvi:
				begin
					DINout = 1;
					RXin = 1;
					Done = 1;
				end
				add:
				begin
					RXout = 1;
					Ain = 1;
				end
				sub:
				begin
					RXout = 1;
					Ain = 1;
				end
			endcase
		T2: //define signals in time step 2
			case (I)
				add:
				begin
					RYout = 1;
					Gin = 1;
				end
				sub:
				begin
					RYout = 1;
					Gin = 1;
					AddSub = 1;
			endcase
		T3: //define signals in time step 3
			case (I)
				add:
				begin
					Gout = 1;
					RXin = 1;
					Done = 1;
				end
				sub:
				begin
					Gout = 1;
					RXin = 1;
					Done = 1;
			endcase
		endcase
	end
	
	// Control FSM flip-flops
	always @(posedge Clock, negedge Resetn) begin
		if (!Resetn) begin
			// Reset all FSM flip-flops
		end
		else begin // Check control signals and set appropriate flip-flops
		//RYin, RXin, Ain, Gin, AddSub;
			// Set the bus driver
			if(DINout && !(RXout || RYout || Gout)) begin
				busDriver = 10'b0000000001;
			end
			else if(RXout && !(DINout || RYout || Gout)) begin
				busDriver = {regX, 0, 0};
			end
			else if(RYout && !(RXout || DINout || Gout)) begin
				busDriver = {regY, 0, 0};
			end
			else if(Gout && !(RXout || RYout || DINout)) begin
				busDriver = 10'b0000000010;
			end
			else begin
				$display("Ambiguous bus driver!! Setting to DINout\n");
				busDriver = 10'b0000000001;
			end
			
			// Ain and Gin are handled by the regn module
			Rin = 8'b00000000;
			if(RXin) begin
				Rin = Rin | regX;
			end
			
			if(RYin) begin
				Rin = Rin | regY;
			end
		end
	end
	
	/** General Purpose Register Instantiations **/
	// Register input signals
	reg [0:7] Rin;
	
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
	wire [8:0] AoutWires;
	regn reg_a(BusWires, Ain, Clock, AoutWires);
	
	/** Register G **/
	wire [8:0] GinWires, GoutWires;
	regn reg_g(GinWires, Gin, Clock, GoutWires);
	
	/** Instruction Register **/
	wire [8:0] IRoutWires;
	regn reg_ir(DIN, IRin, Clock, IRoutWires);
	
	addsub Addsub(AddSub, AoutWires, BusWires, GinWires);

	// Define the bus
	case(busDriver)
		reg0: assign BusWires = R0;
		reg1: assign BusWires = R1;
		reg2: assign BusWires = R2;
		reg3: assign BusWires = R3;
		reg4: assign BusWires = R4;
		reg5: assign BusWires = R5;
		reg6: assign BusWires = R6;
		reg7: assign BusWires = R7;
		gout: assign BusWires = GoutWires;
		dinout: assign BusWires = DIN;
		default:
		begin
			$display("Undefined bus driver!! Defaulting to DIN!!\n");
			assign BusWires = DIN;
		end
	endcase
	
	
endmodule
