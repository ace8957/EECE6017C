module proc (DIN, Resetn, Clock, Run, Done, BusWires);
	input [8:0] DIN;
	input Resetn, Clock, Run;
	output Done;
	output [8:0] BusWires;
	parameter T0 = 2'b00, T1 = 2'b01, T2 = 2'b10, T3 = 2'b11;
	parameter mv = 2'b00, mvi = 2'b01, add = 2'b10, sub = 2'b11;
	//declare variables
	reg [1:0] Tstep_Q;
	reg [1:0] Tstep_D;
	wire [2:0] I;
	assign I = IR[1:3];
	dec3to8 decX (IR[4:6], 1’b1, Xreg);
	dec3to8 decY (IR[7:9], 1’b1, Yreg);
	reg DINout, RYout, RYin, RXout, RXin, Ain, Gin, Gout, AddSub;
	// Control FSM state table
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
		: : : specify initial values
		case (Tstep_Q)
		T0: // store DIN in IR in time step 0
			begin
			IRin = 1’b1;
			end
		T1: //de?ne signals in time step 1
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
		T2: //de?ne signals in time step 2
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
		T3: //de?ne signals in time step 3
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
	// Control FSM ?ip-?ops
	always @(posedge Clock, negedge Resetn)
	if (!Resetn)
	: : :
	regn reg_0 (BusWires, Rin[0], Clock, R0);
	: : : instantiate other registers and the adder/subtracter unit
: : : de?ne the bus
endmodule
