/**
 * Embedded Systems (EECE6017C) - Lab 4 testbench
 * Short description of the assignment
 * Author(s): Alex Stephens <stephea5@mail.uc.edu> (AWS)
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
    wire [0:8] Y_d328;
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
    /** TODO proc **/
    /** TODO mem **/

    /** File for writing test data **/
    integer outputFile;

    initial begin
        // Wait for global reset
        #100
        
        // Open a file for writing
        file = $fopen("enhanced_proc_testResults.csv", "w");

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

    end

    /** Run the clock at 50 MHz **/
    always begin
        Clock = #10 !Clock;
    end

    /**
     *
     */
    task doRegnTest begin

    endtask

    /**
     *
     */
    task doDec3To8Test begin

    endtask

    /**
     *
     */
    task doCounterTest begin

    endtask

    /**
     *
     */
    task doAddSubTest begin

    endtask

    /**
     *
     */
    task doSeg7ScrollTest begin

    endtask

    /**
     *
     */
    task doSwitchLoadTest begin

    endtask

    /**
     *
     */
    task doControlUnitTest begin

    endtask

    /**
     *
     */
    task doProcTest begin

    endtask

    /**
     *
     */
    task doMemTest begin

    endtask


endmodule
