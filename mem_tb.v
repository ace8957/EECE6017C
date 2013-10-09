/**
 * Embedded Systems (EECE6017C) - Lab 4 testbench
 * Short description of the assignment
 * Author(s): Alex Stephens <stephea5@mail.uc.edu> (AWS)
 *         (s): Alex Stephens <stephea6@mail.uc.edu> (AWS)

 *         (s): Alex Stephens <stephea6@mail.uc.edu> (AWS)

 *	      	  Josh Boroff <boroffja@mail.uc.edu> (JBB)
 *	      	  Adam Wilford <wilforaf@mail.uc.edu> (AFW)
 * Target FPGA: Altera Cyclone II 2C20 (EP2C20F484C7)
 * Tool: Quartus II 64-bit
 * Version: 13.0.1 sp1
 *
 * Development Log:
 * Date		Developer	Description
 * 09 28 13 AWS			Initial
 */
`timescale 1ns/1ps
/**
 * Module mem_tb - Tests each module used in this project separately before testing the top level module
 * Tests the modules:
 *      - regn <-- Ensure writes only occur with a write enable
 *      - dec3to8 <-- Ensure proper endianess, gives zero for bad inputs
 *      - counter <-- Ensure it counts when its supposed to, loads a value properly
 *      - addsub <-- Adds and subtracts two 2's complement values
 *      - seg7_scroll <-- Output matches input value and location
 *      - switch_load <-- Outputs when its told to
 *      - control_unit <-- Transitions states properly
 *      - proc <-- Executes the given instruction correctly
 *      - mem <-- Does everything correctly
 */
module mem_tb;
    /** Clock use for all units inder test **/
    reg Clock;

    /** Inputs and outputs for testing regn **/
    reg [8:0] R_regn;
    reg Rin_regn;
    wire [8:0] Q_regn;
    regn regn_dut(.R(R_regn),
                  .Rin(Rin_regn),
                  .Clock(Clock),
                  .Q(Q_regn)
    );

    /** Inputs and outputs for dec3to8 **/
    reg [2:0] W_d328;
    reg En_d328;
    wire [0:7] Y_d328;
    dec3to8 d328_dut(.W(W_d328), 
                     .En(En_d328), 
                     .Y(Y_d328)
    );

    /** Inputs and outputs for counter **/
    reg resetn_ctr, en_ctr, load_ctr;
    reg [8:0] loadVal_ctr;
    wire [8:0] n_ctr;
    counter ctr_dut(.clock(Clock),
                    .reset(resetn_ctr),
                    .countEn(en_ctr),
                    .load(load_ctr),
                    .loadVal(loadVal_ctr),
                    .n(n_ctr)
    );

    /** Inputs and outputs for addsub **/
    reg sub_as;
    reg [8:0] a_as, b_as;
    wire [8:0] out_as;
    addsub as_dut(.Sub(sub_as),
                  .A(a_as),
                  .B(b_as),
                  .Out(out_as)
    );

    /** Inputs and outputs for seg7_scroll **/
    reg [3:0] segment_s7s;
    reg [8:0] valuein_s7s;
    reg Write_s7s;
    wire [8:0] s0out_s7s, s1out_s7s, s2out_s7s, s3out_s7s;
    seg7_scroll s7s_dut(.segment(segment_s7s),
                        .valuein(valuein_s7s),
                        .Write(Write_s7s),
                        .clock(Clock),
                        .seg_0_output_wires(s0out_s7s),
                        .seg_1_output_wires(s1out_s7s),
                        .seg_2_output_wires(s2out_s7s),
                        .seg_3_output_wires(s3out_s7s)
    );

    /** Inputs and outputs for switch_load **/
    reg [8:0] switches_sl;
    wire [8:0] value_sl;
    switch_load sl_dut(.clock(Clock),
                       .switches(switches_sl),
                       .value(value_sl)
    );

    /** TODO Control unit **/
	 
    /** Inputs and outputs for proc **/
	 reg [8:0] DIN_proc;
	 reg Resetn_proc, Run_proc;
	 wire [8:0] DOUT_proc, ADDR_proc;
	 wire W_proc;
	 proc proc_dut(.DIN(DIN_proc),
						.Resetn(Resetn_proc),
						.Clock(Clock),
						.Run(Run_proc),
						.DOUT(DOUT_proc),
						.ADDR(ADDR_proc),
						.W(W_proc)
	 );
	 
    /** TODO mem **/

    /** File for writing test data **/
    integer outputFile;

    initial begin
        // Wait for global reset
        #100
        
        Clock = 1'b1;
		  Resetn_proc <= 1'b0;
		  Run_proc <= 1'b0;
        // Open a file for writing
        outputFile = $fopen("enhanced_proc_testResults.csv", "w");
        $fwrite(outputFile, "-=*=-Begin Test of Lab 4-=*=-\n");
        // Run the regn test
        doRegnTest;

        #100

        // do the dec3to8 test
        doDec3To8Test;

        #100

        // do the counter test
        doCounterTest;

        #100

        // do the addsub test
        doAddSubTest;

        #100

        // do the seg7_scroll test
        doSeg7ScrollTest;

        #100

        // do the switch_load test
        doSwitchLoadTest;

        #100

        // do the control_unit test
        doControlUnitTest;

        #100

        // do the proc test
        doProcTest;

        #100

        // do the top level (mem) test
        doMemTest;

        $fwrite(outputFile, "-=*=-Test of Lab 4 completed successfully-=*=-\n");
        $finish;
    end

    /** Run the clock at 50 MHz **/
    always begin
        #10 Clock = !Clock;
    end

    /**
     *   
    reg [8:0] R_regn;
    reg Rin_regn;
    wire [8:0] Q_regn;
    regn regn_dut(.R(R_regn),
                  .Rin(Rin_regn),
                  .Clock(Clock),
                  .Q(Q_regn)
    );
     */
    task doRegnTest; begin
        $fwrite(outputFile, "==========BEGIN MODULE REGN TEST==========\n");
        $fwrite(outputFile, "Time,R,Rin,Qexp,Q\n");
        R_regn <= 0;
        Rin_regn <= 1;
        #20
        $fwrite(outputFile, "%t,%h,%b,%h,%h\n", $time, R_regn, Rin_regn, 9'b000000000, Q_regn);
        if(Q_regn != 9'b000000000) begin
            $fwrite(outputFile, "===========END MODULE REGN TEST===========\n");
            $finish;
        end

        R_regn <= 9'b111111111;
        Rin_regn <= 1;
        #20
        $fwrite(outputFile, "%t,%h,%b,%h,%h\n", $time, R_regn, Rin_regn, 9'b111111111, Q_regn);
        if(Q_regn != 9'b111111111) begin
            $fwrite(outputFile, "===========END MODULE REGN TEST===========\n");
            $finish;
        end

        Rin_regn <= 0;
        R_regn <= 9'b010101010;
        #20
        $fwrite(outputFile, "%t,%h,%b,%h,%h\n", $time, R_regn, Rin_regn, 9'b111111111, Q_regn);
        if(Q_regn != 9'b111111111) begin
            $fwrite(outputFile, "===========END MODULE REGN TEST===========\n");
            $finish;
        end
        $fwrite(outputFile, "===========END MODULE REGN TEST===========\n");
    end
    endtask

    /**
     *
    reg [2:0] W_d328;
    reg En_d328;
    wire [0:8] Y_d328;
    dec3to8 d328_dut(.W(W_d328), 
                     .En(En_d328), 
                     .Y(Y_d328)
    );

     */
    task doDec3To8Test; begin
        $fwrite(outputFile, "==========BEGIN MODULE DEC3TO8 TEST==========\n");
        $fwrite(outputFile, "Time,W,En,Yexp,Y\n");

        En_d328 <= 1;
        
        for(W_d328 = 3'b000; W_d328 < 3'b111; W_d328 = W_d328 + 1) begin
            #20
            $fwrite(outputFile, "%t,%h,%b,%h,%h\n", $time, W_d328, En_d328, (8'b10000000 >> W_d328), Y_d328);
            if(Y_d328 != (8'b10000000 >> W_d328)) begin
                $fwrite(outputFile, "===========END MODULE DEC3TO8 TEST===========\n");   
                $finish;
            end
        end

        W_d328 <= 3'b111;
        #20
        $fwrite(outputFile, "%t,%h,%b,%h,%h\n", $time, W_d328, En_d328, 8'b00000001, Y_d328);
        if(Y_d328 != 8'b00000001) begin
            $fwrite(outputFile, "===========END MODULE DEC3TO8 TEST===========\n");   
            $finish;
        end


        En_d328 <= 0;
        W_d328 <= 3'b010;
        #20
        $fwrite(outputFile, "%t,%h,%b,%h,%h\n", $time, W_d328, En_d328, 8'b00000000, Y_d328);
        if(Y_d328 != 8'b00000000) begin
            $fwrite(outputFile, "===========END MODULE DEC3TO8 TEST===========\n");   
            $finish;      
        end
        $fwrite(outputFile, "===========END MODULE DEC3TO8 TEST===========\n");   
    end
    endtask

    /**
     *
    reg resetn_ctr, en_ctr, load_ctr;
    reg [8:0] loadVal_ctr;
    wire [8:0] n_ctr;
    counter ctr_dut(.clock(Clock),
                    .reset(resetn_ctr),
                    .countEn(en_ctr),
                    .load(load_ctr),
                    .loadVal(loadVal_ctr),
                    .n(n_ctr)
    );

     */
    task doCounterTest; begin
        $fwrite(outputFile, "==========BEGIN MODULE COUNTER TEST==========\n");
        $fwrite(outputFile, "Time,Resetn,countEn,load,loadVal,nexp,n\n");

        resetn_ctr <= 1'b1;
        en_ctr <= 1'b0;

        // Test loading a value
        load_ctr <= 1'b1;
        loadVal_ctr <= 9'b111111111;
        #20
        $fwrite(outputFile, "%t,%b,%b,%b,%h,%h,%h\n", $time, resetn_ctr, en_ctr, load_ctr, loadVal_ctr, 9'b111111111, n_ctr);
        if(n_ctr != 9'b111111111) begin
            $fwrite(outputFile, "===========END MODULE COUNTER TEST===========\n");
            $finish;
        end

        // Test counting
        load_ctr <= 1'b0;
        en_ctr <= 1'b1;
        #20
        $fwrite(outputFile, "%t,%b,%b,%b,%h,%h,%h\n", $time, resetn_ctr, en_ctr, load_ctr, loadVal_ctr, 9'b000000000, n_ctr);
        if(n_ctr != 9'b000000000) begin
            $fwrite(outputFile, "===========END MODULE COUNTER TEST===========\n");
            $finish;
        end

        #20
        $fwrite(outputFile, "%t,%b,%b,%b,%h,%h,%h\n", $time, resetn_ctr, en_ctr, load_ctr, loadVal_ctr, 9'b000000001, n_ctr);
        if(n_ctr != 9'b000000001) begin
            $fwrite(outputFile, "===========END MODULE COUNTER TEST===========\n");
            $finish;
        end


        // Test reset
        load_ctr <= 1'b0;
        en_ctr <= 1'b0;
        resetn_ctr <= 1'b0;
        #20
        $fwrite(outputFile, "%t,%b,%b,%b,%h,%h,%h\n", $time, resetn_ctr, en_ctr, load_ctr, loadVal_ctr, 9'b000000000, n_ctr);
        if(n_ctr != 9'b000000000) begin
            $fwrite(outputFile, "===========END MODULE COUNTER TEST===========\n");
            $finish;
        end

        $fwrite(outputFile, "===========END MODULE COUNTER TEST===========\n");
    end
    endtask

    /**
     *
    reg sub_as;
    reg [8:0] a_as, b_as;
    wire [8:0] out_as;
    addsub as_dut(.Sub(sub_as),
                  .A(a_as),
                  .B(b_as),
                  .Out(out_as)
    );

     */
    task doAddSubTest; begin
        $fwrite(outputFile, "==========BEGIN MODULE COUNTER TEST==========\n");
        $fwrite(outputFile, "Time,A,B,AddSub,Outexp,Out\n");

        sub_as <= 1'b0;
        a_as <= 9'b000000000;
        b_as <= 9'b000000000;
        #20
        $fwrite(outputFile, "%t,%h,%h,%b,%h,%h\n", $time, a_as, b_as, sub_as, 9'b000000000, out_as);
        if(out_as != 9'b000000000) begin
            $fwrite(outputFile, "===========END MODULE COUNTER TEST===========\n");
            $finish;
        end

        sub_as <= 1'b0;
        a_as <= 9'b111111111;
        b_as <= 9'b000000001;
        #20
        $fwrite(outputFile, "%t,%h,%h,%b,%h,%h\n", $time, a_as, b_as, sub_as, 9'b000000000, out_as);
        if(out_as != 9'b000000000) begin
            $fwrite(outputFile, "===========END MODULE COUNTER TEST===========\n");
            $finish;
        end

        sub_as <= 1'b0;
        a_as <= 9'b101010101;
        b_as <= 9'b010101010;
        #20
        $fwrite(outputFile, "%t,%h,%h,%b,%h,%h\n", $time, a_as, b_as, sub_as, 9'b111111111, out_as);
        if(out_as != 9'b111111111) begin
            $fwrite(outputFile, "===========END MODULE COUNTER TEST===========\n");
            $finish;
        end

        sub_as <= 1'b1;
        a_as <= 9'b111111111;
        b_as <= 9'b000000001;
        #20
        $fwrite(outputFile, "%t,%h,%h,%b,%h,%h\n", $time, a_as, b_as, sub_as, 9'b111111110, out_as);
        if(out_as != 9'b111111110) begin
            $fwrite(outputFile, "===========END MODULE COUNTER TEST===========\n");
            $finish;
        end

        $fwrite(outputFile, "===========END MODULE COUNTER TEST===========\n");
    end
    endtask

    /**
     *
    reg [3:0] segment_s7s;
    reg [8:0] valuein_s7s;
    reg Write_s7s;
    wire [8:0] s0out_s7s, s1out_s7s, s2out_s7s, s3out_s7s;
    seg7_scroll s7s_dut(.segment(segment_s7s),
                        .valuein(valuein_s7s),
                        .Write(Write_s7s),
                        .clock(Clock),
                        .seg_0_output_wires(s0out_s7s),
                        .seg_1_output_wires(s1out_s7s),
                        .seg_2_output_wires(s2out_s7s),
                        .seg_3_output_wires(s3out_s7s)
    );

     */
    task doSeg7ScrollTest; begin
        $fwrite(outputFile, "==========BEGIN MODULE SEG7_SCROLL TEST==========\n");
        $fwrite(outputFile, "Time,segment,valuein,Write,s0exp,s0,s1exp,s1,s2exp,s2,s3exp,s3\n");

        segment_s7s <= 4'b0000;
        valuein_s7s <= 9'b001001001;
        Write_s7s <= 1'b0;
        #10
        Write_s7s <= 1'b1;
        #10
        $fwrite(outputFile, "%t,%h,%h,%b,%h,%h,%h,%h,%h,%h,%h,%h\n",
            $time, segment_s7s, valuein_s7s, Write_s7s,
            9'b000000000, s0out_s7s,
            9'b000000000, s1out_s7s,
            9'b000000000, s2out_s7s,
            9'b000000000, s3out_s7s
        );
        if((s0out_s7s != 9'b000000000) ||
           (s1out_s7s != 9'b000000000) ||
           (s2out_s7s != 9'b000000000) ||
           (s3out_s7s != 9'b000000000)) begin
            $fwrite(outputFile, "===========END MODULE SEG7_SCROLL TEST===========\n");
            $finish;
       end

        segment_s7s <= 4'b0001;
        valuein_s7s <= 9'b001001001;
        Write_s7s <= 1'b0;
        #10
        Write_s7s <= 1'b1;
        #10
        $fwrite(outputFile, "%t,%h,%h,%b,%h,%h,%h,%h,%h,%h,%h,%h\n",
            $time, segment_s7s, valuein_s7s, Write_s7s,
            9'b001001001, s0out_s7s,
            9'b000000000, s1out_s7s,
            9'b000000000, s2out_s7s,
            9'b000000000, s3out_s7s
        );
        if((s0out_s7s != 9'b001001001) ||
           (s1out_s7s != 9'b000000000) ||
           (s2out_s7s != 9'b000000000) ||
           (s3out_s7s != 9'b000000000)) begin
            $fwrite(outputFile, "===========END MODULE SEG7_SCROLL TEST===========\n");
            $finish;
       end

        segment_s7s <= 4'b0110;
        valuein_s7s <= 9'b110110110;
        Write_s7s <= 1'b0;
        #10
        Write_s7s <= 1'b1;
        #10
        $fwrite(outputFile, "%t,%h,%h,%b,%h,%h,%h,%h,%h,%h,%h,%h\n",
            $time, segment_s7s, valuein_s7s, Write_s7s,
            9'b001001001, s0out_s7s,
            9'b110110110, s1out_s7s,
            9'b110111010, s2out_s7s,
            9'b000000000, s3out_s7s
        );
        if((s0out_s7s != 9'b001001001) ||
           (s1out_s7s != 9'b110110110) ||
           (s2out_s7s != 9'b110110110) ||
           (s3out_s7s != 9'b000000000)) begin
            $fwrite(outputFile, "===========END MODULE SEG7_SCROLL TEST===========\n");
            $finish;
       end

        segment_s7s <= 4'b1000;
        valuein_s7s <= 9'b101010101;
        Write_s7s <= 1'b0;
        #10
        Write_s7s <= 1'b0;
        #10
        $fwrite(outputFile, "%t,%h,%h,%b,%h,%h,%h,%h,%h,%h,%h,%h\n",
            $time, segment_s7s, valuein_s7s, Write_s7s,
            9'b001001001, s0out_s7s,
            9'b110110110, s1out_s7s,
            9'b110111010, s2out_s7s,
            9'b000000000, s3out_s7s
        );
        if((s0out_s7s != 9'b001001001) ||
           (s1out_s7s != 9'b110110110) ||
           (s2out_s7s != 9'b110110110) ||
           (s3out_s7s != 9'b000000000)) begin
            $fwrite(outputFile, "===========END MODULE SEG7_SCROLL TEST===========\n");
            $finish;
       end


        $fwrite(outputFile, "===========END MODULE SEG7_SCROLL TEST===========\n");
    end
    endtask

    /**
     *
    reg [8:0] switches_sl;
    wire [8:0] value_sl;
    switch_load sl_dut(.clock(Clock),
                       .switches(switches_sl),
                       .value(value_sl)
    );

     */
    task doSwitchLoadTest; begin
        $fwrite(outputFile, "==========BEGIN MODULE SWITCH_LOAD TEST==========\n");
        $fwrite(outputFile, "Time,switches,valueExp,value\n");
        
        switches_sl <= 9'b010100110;
        #20
        $fwrite(outputFile, "%t,%h,%h,%h\n", $time, switches_sl, 9'b010100110, value_sl);
        if(value_sl != 9'b010100110) begin
            $fwrite(outputFile, "===========END MODULE SWITCH_LOAD TEST===========\n");
            $finish;
        end

        $fwrite(outputFile, "===========END MODULE SWITCH_LOAD TEST===========\n");
    end
    endtask

    /**
     *
     */
    task doControlUnitTest; begin

    end
    endtask

    /**
     *
	 reg [8:0] DIN_proc;
	 reg Resetn_proc, Run_proc;
	 wire [8:0] DOUT_proc, ADDR_proc;
	 wire W_proc;
	 proc proc_dut(.DIN(DIN_proc),
						.Resetn(Resetn_proc),
						.Clock(Clock),
						.Run(Run_proc),
						.DOUT(DOUT_proc),
						.ADDR(ADDR_proc),
						.W(W_proc)
	 );
     */
    task doProcTest; begin
        $fwrite(outputFile, "==========BEGIN MODULE PROC TEST==========\n");
        $fwrite(outputFile, "Time,DIN,Resetn,Run,DOUTexp,DOUT,ADDRexp,ADDR,Wexp,W\n");
			//mvi     R0,#d100
			// Begin T0 for mvi
			DIN_proc <= 9'h40;
			Run_proc <= 1'b1;
			Resetn_proc <= 1'b1;
			#20
			
			// Begin T1 for mvi
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 0, ADDR_proc, 0, W_proc);
			Run_proc <= 1'b0;
			#20
			
			// Begin T2 for mvi
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 0, ADDR_proc, 0, W_proc);
			#20
			
			// Begin T3 for mvi
			DIN_proc <= 9'h64;
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 0, ADDR_proc, 0, W_proc);
			#20
			
			// Begin T4 for mvi
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd1, ADDR_proc, 0, W_proc);
			#20
			
			// Begin T5 for mvi
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd1, ADDR_proc, 0, W_proc);
			#20
			
			//mvi     R1,#d101
			// Begin T0 for mvi
			DIN_proc <= 9'h48;
			Run_proc <= 1'b1;
			#20
			
			// Begin T1 for mvi
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd2, ADDR_proc, 0, W_proc);
			Run_proc <= 1'b0;
			#20
			
			// Begin T2 for mvi
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd2, ADDR_proc, 0, W_proc);
			#20
			
			// Begin T3 for mvi
			DIN_proc <= 9'h65;
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd2, ADDR_proc, 0, W_proc);
			#20
			
			// Begin T4 for mvi
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd3, ADDR_proc, 0, W_proc);
			#20
			
			// Begin T5 for mvi
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd3, ADDR_proc, 0, W_proc);
			#20
			
			//mvi     R2,#d1
			// Begin T0 for mvi
			DIN_proc <= 9'h50;
			Run_proc <= 1'b1;
			#20
			
			// Begin T1 for mvi
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd4, ADDR_proc, 0, W_proc);
			Run_proc <= 1'b0;
			#20
			
			// Begin T2 for mvi
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd4, ADDR_proc, 0, W_proc);
			#20
			
			// Begin T3 for mvi
			DIN_proc <= 9'h1;
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd4, ADDR_proc, 0, W_proc);
			#20
			
			// Begin T4 for mvi
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd5, ADDR_proc, 0, W_proc);
			#20
			
			// Begin T5 for mvi
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd5, ADDR_proc, 0, W_proc);
			#20
			
			//sub     R0,R1
			// Begin T0 for sub
			DIN_proc <= 9'hc1;
			Run_proc <= 1'b1;
			#20
			
			// Begin T1 for sub
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd6, ADDR_proc, 0, W_proc);
			Run_proc <= 1'b0;
			#20
			
			// Begin T2 for sub
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd6, ADDR_proc, 0, W_proc);
			#20
			
			// Begin T3 for sub
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd6, ADDR_proc, 0, W_proc);
			#20
			
			// Begin T4 for sub
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd6, ADDR_proc, 0, W_proc);
			#20
			
			// Begin T5 for sub
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd6, ADDR_proc, 0, W_proc);
			#20

			//mvnz    R1,R0
			// Begin T0 for sub
			DIN_proc <= 9'h188;
			Run_proc <= 1'b1;
			#20
			
			// Begin T1 for sub
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd7, ADDR_proc, 0, W_proc);
			Run_proc <= 1'b0;
			#20
			
			// Begin T2 for sub
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd7, ADDR_proc, 0, W_proc);
			#20
			
			// Begin T3 for sub
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd7, ADDR_proc, 0, W_proc);
			#20
			
			//add     R0,R2
			// Begin T0 for add
			DIN_proc <= 9'h82;
			Run_proc <= 1'b1;
			#20
			
			// Begin T1 for add
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd8, ADDR_proc, 0, W_proc);
			Run_proc <= 1'b0;
			#20
			
			// Begin T2 for add
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd8, ADDR_proc, 0, W_proc);
			#20
			
			// Begin T3 for add
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd8, ADDR_proc, 0, W_proc);
			#20
			
			// Begin T4 for add
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd8, ADDR_proc, 0, W_proc);
			#20
			
			// Begin T5 for add
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd8, ADDR_proc, 0, W_proc);
			#20

			//add     R3,R1
			// Begin T0 for add
			DIN_proc <= 9'h99;
			Run_proc <= 1'b1;
			#20
			
			// Begin T1 for add
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd9, ADDR_proc, 0, W_proc);
			Run_proc <= 1'b0;
			#20
			
			// Begin T2 for add
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd9, ADDR_proc, 0, W_proc);
			#20
			
			// Begin T3 for add
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd9, ADDR_proc, 0, W_proc);
			#20
			
			// Begin T4 for add
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd9, ADDR_proc, 0, W_proc);
			#20
			
			// Begin T5 for add
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd9, ADDR_proc, 0, W_proc);
			#20

			//' Store -1 to address 0
			//st      R3,R0
			// Begin T0 for add
			DIN_proc <= 9'h158;
			Run_proc <= 1'b1;
			#20
			
			// Begin T1 for add
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd10, ADDR_proc, 0, W_proc);
			Run_proc <= 1'b0;
			#20
			
			// Begin T2 for add
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd10, ADDR_proc, 0, W_proc);
			#20
			
			// Begin T3 for add
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 9'd10, ADDR_proc, 0, W_proc);
			#20
			
			// Begin T4 for add
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 0, ADDR_proc, 0, W_proc);
			#20
			
			// Begin T5 for add
			logProc(DIN_proc, Resetn_proc, Run_proc, 0, DOUT_proc, 0, ADDR_proc, 0, W_proc);
			#20

			logProc(DIN_proc, Resetn_proc, Run_proc, 9'b111111111, DOUT_proc, 0, ADDR_proc, 1'b1, W_proc);
			//' Load -1 from addr 0
			//ld      R5,R0		  
			// Begin T0 for add
			DIN_proc <= 9'h128;
			Run_proc <= 1'b1;
			#20
			
			// Begin T1 for add
			logProc(DIN_proc, Resetn_proc, Run_proc, 9'b111111111, DOUT_proc, 9'd12, ADDR_proc, 0, W_proc);
			Run_proc <= 1'b0;
			#20
			
			// Begin T2 for add
			logProc(DIN_proc, Resetn_proc, Run_proc, 9'b111111111, DOUT_proc, 9'd12, ADDR_proc, 0, W_proc);
			#20
			
			// Begin T3 for add
			DIN_proc <= 9'b111111111;
			logProc(DIN_proc, Resetn_proc, Run_proc, 9'b111111111, DOUT_proc, 9'd12, ADDR_proc, 0, W_proc);
			#20
			
			// Begin T4 for add
			logProc(DIN_proc, Resetn_proc, Run_proc, 9'b111111111, DOUT_proc, 0, ADDR_proc, 0, W_proc);
			#20
			
			// Begin T5 for add
			logProc(DIN_proc, Resetn_proc, Run_proc, 9'b111111111, DOUT_proc, 0, ADDR_proc, 0, W_proc);
			#20
        $fwrite(outputFile, "===========END MODULE PROC TEST===========\n");
    end
    endtask

	 task logProc;
	     input [8:0] DIN;
		  input Resetn;
		  input Run;
		  input [8:0] DOUTexp;
		  input [8:0] DOUT;
		  input [8:0] ADDRexp;
		  input [8:0] ADDR;
		  input Wexp;
		  input W;
		  begin
		  $fwrite(outputFile, "%t,%h,%b,%b,%h,%h,%h,%h,%b,%b\n",
									 $time,DIN,Resetn,Run,
									 DOUTexp,DOUT,ADDRexp,ADDR,Wexp,W);
		  /*
		  if((DOUT != DOUTexp) ||
			  (ADDR != ADDRexp) ||
			  (W != Wexp))
			  begin
		      $fwrite(outputFile, "===========END MODULE PROC TEST===========\n");
				$finish;
		  end
		  */
	 end
	 endtask

    /**
     *
     */
    task doMemTest; begin

    end
    endtask


endmodule
