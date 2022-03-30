module tpu(

    //////////////////////////////////////////////////////////////////////////////////////
    // FPGA Pins
    //////////////////////////////////////////////////////////////////////////////////////

    // Clock pins
    CLOCK_50,

    // Seven Segment Displays
    HEX0,
    HEX1,
    HEX2,
    HEX3,
    HEX4,
    HEX5,

    // Pushbuttons
    KEY,

    // LEDs
    LEDR,

    // Slider Switches
    SW,

    //////////////////////////////////////////////////////////////////////////////////////
    // HPS Pins
    //////////////////////////////////////////////////////////////////////////////////////

    // DDR3 SRAM
    HPS_DDR3_A,
    HPS_DDR3_BA,
    HPS_DDR3_CAS_n,
    HPS_DDR3_CKE,
    HPS_DDR3_CK_n,
    HPS_DDR3_CK_p,
    HPS_DDR3_CS_n,
    HPS_DDR3_DM,
    HPS_DDR3_DQ,
    HPS_DDR3_DQS_n,
    HPS_DDR3_DQS_p,
    HPS_DDR3_ODT,
    HPS_DDR3_RAS_n,
    HPS_DDR3_RESET_n,
    HPS_DDR3_WE_n,
    HPS_DDR3_RZQ
);

//========================================================================================
//      PORT Declarations
//========================================================================================

//////////////////////////////////////////////////////////////////////////////////////////
// FPGA Pins
//////////////////////////////////////////////////////////////////////////////////////////

input CLOCK_50;
input [3:0] KEY;
input [9:0] SW;
output [9:0] LEDR;
output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

//////////////////////////////////////////////////////////////////////////////////////////
// HPS Pins
//////////////////////////////////////////////////////////////////////////////////////////

// DDR3 SRAM
output [14:0] HPS_DDR3_A;
output [2:0] HPS_DDR3_BA;
output HPS_DDR3_CAS_n;
output HPS_DDR3_CKE;
output HPS_DDR3_CK_n;
output HPS_DDR3_CK_p;
output HPS_DDR3_CS_n;
output [3:0] HPS_DDR3_DM;
inout [31:0] HPS_DDR3_DQ;
inout [3:0] HPS_DDR3_DQS_n;
inout [3:0] HPS_DDR3_DQS_p;
output HPS_DDR3_ODT;
output HPS_DDR3_RAS_n;
output HPS_DDR3_RESET_n;
output HPS_DDR3_WE_n;
input HPS_DDR3_RZQ;

//========================================================================================
// REG/WIRE declarations
//========================================================================================

wire [31:0] hex3_hex0;
wire [15:0] hex5_hex4;

assign HEX0 = ~hex3_hex0[6:0];
assign HEX1 = ~hex3_hex0[14:8];
assign HEX2 = ~hex3_hex0[22:16];
assign HEX3 = ~hex3_hex0[30:24];
assign HEX4 = ~hex5_hex4[6:0];
assign HEX5 = ~hex5_hex4[14:8];

//========================================================================================
// Structural Coding
//========================================================================================

tpus_system  system(
    .clk_clk            (CLOCK_50),            //         clk.clk
    .reset_reset_n      (1'b1),      //       reset.reset_n

    .memory_mem_a       (HPS_DDR3_A),       //      memory.mem_a
    .memory_mem_ba      (HPS_DDR3_BA),      //            .mem_ba
    .memory_mem_cas_n   (HPS_DDR3_CAS_n),   //            .mem_cas_n
    .memory_mem_cke     (HPS_DDR3_CKE),     //            .mem_cke
    .memory_mem_ck_n    (HPS_DDR3_CK_n),    //            .mem_ck_n
    .memory_mem_ck      (HPS_DDR3_CK_p),      //            .mem_ck
    .memory_mem_cs_n    (HPS_DDR3_CS_n),    //            .mem_cs_n
    .memory_mem_dm      (HPS_DDR3_DM),      //            .mem_dm
    .memory_mem_dq      (HPS_DDR3_DQ),      //            .mem_dq
    .memory_mem_dqs_n   (HPS_DDR3_DQS_n),   //            .mem_dqs_n
    .memory_mem_dqs     (HPS_DDR3_DQS_p),     //            .mem_dqs
    .memory_mem_odt     (HPS_DDR3_ODT),     //            .mem_odt
    .memory_mem_ras_n   (HPS_DDR3_RAS_n),   //            .mem_ras_n
    .memory_mem_reset_n (HPS_DDR3_RESET_n), //            .mem_reset_n
    .memory_mem_we_n    (HPS_DDR3_WE_n),    //            .mem_we_n
    .memory_oct_rzqin   (HPS_DDR3_RZQ),   //            .oct_rzqin

    .pushbuttons_export (~KEY[3:0]), // pushbuttons.export
    .hex3_hex0_export   (hex3_hex0),   //   hex3_hex0.export
    .hex5_hex4_export   (hex5_hex4),   //   hex5_hex4.export
    .rled_export        (LEDR),        //        rled.export
    .switches_export    (SW)     //    switches.export
);

endmodule // lab1
