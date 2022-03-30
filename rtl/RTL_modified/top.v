// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Author: Ahmed Abdelazeem
// Github: https://github.com/abdelazeem201
// Email: ahmed.abdelazeem@outlook.com
// Description: top module
// Dependencies: Trends in computing have led to a proliferation of neural Network applications. Unfortunately, todays general- purpose processors are not well suited for the class of computations these applications require, creating demand
// for a new class of processors : Tensor Processing Units (TPU). These hardware accelerators are designed with
// neural networks in mind, and allow host CPUs to offload computationally expensive tensor operations to them.
// We implement our own, low-power, scalable TPU intended for embedded and mobile applications, and evaluate its
// performance using a simulated fully connected neural Network layer.
// Since: 2021-03-29 12:15:53
// LastEditors: ahmed abdelazeem
//********************************************************************
// Module Function:

module top (
    clk,
    reset,
    start,
    done,
    opcode,
    dim_1,
    dim_2,
    dim_3,
    addr_1,
    accum_table_submat_row_in,
    accum_table_submat_col_in,
    fifo_ready,
    inputMem_wr_data,
    weightMem_wr_data,
    outputMem_rd_data
);


// ========================================
// ---------- Parameters ------------------
// ========================================

    parameter WIDTH_HEIGHT = 16;
    parameter DATA_WIDTH = 8;
    parameter MAX_MAT_WH = 128;


// ========================================
// ------------ Inputs --------------------
// ========================================

    input clk;
    input reset;
    input start;
    input [2:0] opcode;
    input [$clog2(WIDTH_HEIGHT)-1:0] dim_1;
    input [$clog2(WIDTH_HEIGHT)-1:0] dim_2;
    input [$clog2(WIDTH_HEIGHT)-1:0] dim_3;
    input [7:0] addr_1;
    input [$clog2(MAX_MAT_WH/WIDTH_HEIGHT)-1:0] accum_table_submat_row_in;
    input [$clog2(MAX_MAT_WH/WIDTH_HEIGHT)-1:0] accum_table_submat_col_in;
    input [WIDTH_HEIGHT*DATA_WIDTH-1:0] inputMem_wr_data;
    input [WIDTH_HEIGHT*DATA_WIDTH-1:0] weightMem_wr_data;


// ========================================
// ------------ Outputs -------------------
// ========================================
    
    output done;
    output fifo_ready;
    output [WIDTH_HEIGHT*DATA_WIDTH*2-1:0] outputMem_rd_data;


// ========================================
// ------- Local Wires and Regs -----------
// ========================================
    
    wire [(WIDTH_HEIGHT*DATA_WIDTH)-1:0] inputMem_to_sysArr;
    wire [WIDTH_HEIGHT-1:0] inputMem_rd_en;
    wire [(WIDTH_HEIGHT*DATA_WIDTH)-1:0] inputMem_rd_addr;
    wire [(WIDTH_HEIGHT*DATA_WIDTH)-1:0] weightMem_rd_data;
    wire [(WIDTH_HEIGHT*DATA_WIDTH)-1:0] weightFifo_to_sysArr;
    wire [WIDTH_HEIGHT-1:0] outputMem_wr_en;
    wire [WIDTH_HEIGHT-1:0] mmu_col_valid_out;
    wire [2*DATA_WIDTH*WIDTH_HEIGHT-1:0] accumTable_wr_data;
    wire [$clog2(MAX_MAT_WH*(MAX_MAT_WH/WIDTH_HEIGHT))*WIDTH_HEIGHT-1:0] accumTable_wr_addr;
    wire [WIDTH_HEIGHT-1:0] accumTable_wr_en_in;
    wire [$clog2(MAX_MAT_WH*(MAX_MAT_WH/WIDTH_HEIGHT))*WIDTH_HEIGHT-1:0] accumTable_rd_addr;
    wire [2*DATA_WIDTH*WIDTH_HEIGHT-1:0] accumTable_data_out_to_relu;
    wire [(WIDTH_HEIGHT*16)-1:0] outputMem_wr_data;
    wire [WIDTH_HEIGHT-1:0] mem_to_fifo_en;
    wire [WIDTH_HEIGHT-1:0] fifo_to_arr_en;

    wire [(WIDTH_HEIGHT*DATA_WIDTH)-1:0] weightMem_rd_addr;
    wire [WIDTH_HEIGHT-1:0] weightMem_rd_en;
    wire weight_write;

    // set sys_arr_active 2 cycles after we start reading memory
    wire sys_arr_active;
    reg sys_arr_active1;
    reg sys_arr_active2;

    reg data_mem_calc_done; // high if MMU is done multiplying

    wire accum_clear;

    wire [DATA_WIDTH-1:0] mem_addr_bus_data;
    
    wire [$clog2(WIDTH_HEIGHT)-1:0] wr_accumTable_mat_row;
    wire [$clog2(MAX_MAT_WH/WIDTH_HEIGHT)-1:0] wr_accumTable_submat_row;
    wire [$clog2(MAX_MAT_WH/WIDTH_HEIGHT)-1:0] wr_accumTable_submat_col;

    wire [$clog2(WIDTH_HEIGHT)-1:0] rd_accumTable_mat_row;
    wire [$clog2(MAX_MAT_WH/WIDTH_HEIGHT)-1:0] rd_accumTable_submat_row;
    wire [$clog2(MAX_MAT_WH/WIDTH_HEIGHT)-1:0] rd_accumTable_submat_col;

    wire [7:0] outputMem_wr_addr;

// ========================================
// ---------------- Logic -----------------
// ========================================

    // sys_arr_active 2 cycles after we start reading memory
    assign sys_arr_active = inputMem_rd_en[0];


// ========================================
// ------------ Master Control ------------
// ========================================
    
    master_control master_control(
        .clk                      (clk),
        .reset                    (reset),
        .reset_out                (reset_global),
        .start                    (start),
        .done                     (done),
        .opcode                   (opcode),
        .dim_1                    (dim_1),
        .dim_2                    (dim_2),
        .dim_3                    (dim_3),
        .addr_1                   (addr_1),
        .accum_table_submat_row_in(accum_table_submat_row_in),
        .accum_table_submat_col_in(accum_table_submat_col_in),
        .weight_fifo_arr_done     (fifo_to_arr_done),
        .data_mem_calc_done       (data_mem_calc_done),
        .fifo_ready               (fifo_ready),
        .bus_to_mem_addr          (mem_addr_bus_data),
        .in_mem_wr_en             (inputMem_wr_en),
        .weight_mem_out_rd_addr   (weightMem_rd_addr),
        .weight_mem_out_rd_en     (weightMem_rd_en),
        .weight_mem_wr_en         (weightMem_wr_en),
        .out_mem_out_wr_addr      (outputMem_wr_addr),
        .out_mem_out_wr_en        (outputMem_wr_en),
        .out_mem_rd_en            (outputMem_rd_en),
        .in_fifo_active           (in_fifo_active),
        .out_fifo_active          (out_fifo_active),
        .data_mem_calc_en         (data_mem_calc_en),
        .wr_submat_row_out        (wr_accumTable_submat_row),
        .wr_submat_col_out        (wr_accumTable_submat_col),
        .wr_row_num               (wr_accumTable_mat_row),
        .rd_submat_row_out        (rd_accumTable_submat_row),
        .rd_submat_col_out        (rd_accumTable_submat_col),
        .rd_row_num               (rd_accumTable_mat_row),
        .accum_clear              (accum_clear),
        .relu_en                  (relu_en)
    );
    defparam master_control.SYS_ARR_COLS = WIDTH_HEIGHT;
    defparam master_control.SYS_ARR_ROWS = WIDTH_HEIGHT;
    defparam master_control.MAX_OUT_ROWS = MAX_MAT_WH;
    defparam master_control.MAX_OUT_COLS = MAX_MAT_WH;
    defparam master_control.ADDR_WIDTH = 8;


// ========================================
// ------------ Systolic Array ------------
// ========================================

    sysArr sysArr(
        .clk      (clk),
        .active   (sys_arr_active2),            // from control or software
        .datain   (inputMem_to_sysArr),         // from inputMem
        .win      (weightFifo_to_sysArr),       // from weightFifo
        .sumin    (256'd0),                     // can be used for biases
        .wwrite   ({16{weight_write}}),         // from fifo_arr
        .maccout  (accumTable_wr_data),         // to accumTable
        .wout     (),                           // Not used
        .wwriteout(),                           // Not used
        .activeout(mmu_col_valid_out),          // en for accumTable_wr_control
        .dataout  ()                            // Not used
    );
    defparam sysArr.width_height = WIDTH_HEIGHT;


// =========================================
// --------- Input Side of Array -----------
// =========================================
    
    memArr inputMem(
        .clk    (clk),
        .rd_en  (inputMem_rd_en),               // from inputMemControl
        .wr_en  ({WIDTH_HEIGHT{inputMem_wr_en}}), // from master_control
        .wr_data(inputMem_wr_data),             // from interconnect (INPUT)
        .rd_addr(inputMem_rd_addr),             // from inputMemControl
        .wr_addr({WIDTH_HEIGHT{mem_addr_bus_data}}),            // from master_control
        .rd_data(inputMem_to_sysArr)            // to sysArr
    );
    defparam inputMem.width_height = WIDTH_HEIGHT;

    rd_control inputMemControl (
        .clk      (clk),
        .reset    (reset_global),               // from master_control
        .active   (data_mem_calc_en),           // from master_control
        .rd_en    (inputMem_rd_en),             // to inputMem
        .rd_addr  (inputMem_rd_addr),           // to inputMem
        .wr_active()                            // NOTE: not sure if needed
    );
    defparam inputMemControl.width_height = WIDTH_HEIGHT;


// ========================================
// --------- Weight side of Array ---------
// ========================================
    
    memArr weightMem(
        .clk    (clk),
        .rd_en  (weightMem_rd_en),              // from master_control
        .wr_en  ({WIDTH_HEIGHT{weightMem_wr_en}}), // from master_control
        .wr_data(weightMem_wr_data),            // from interconnect (INPUT)
        .rd_addr(weightMem_rd_addr),            // from master_control
        .wr_addr({WIDTH_HEIGHT{mem_addr_bus_data}}), // from master_control
        .rd_data(weightMem_rd_data)             // to weightFifo
    );
    defparam weightMem.width_height = WIDTH_HEIGHT;

    fifo_control mem_fifo (
        .clk         (clk),
        .reset       (reset_global),            // from master_control
        .active      (in_fifo_active),          // from master_control
        .stagger_load(1'b0),                    // never stagger when filling
        .fifo_en     (mem_to_fifo_en),          // to weightFifo
        .done        (),                        // NOTE: not sure if signal needed
        .weight_write()                         // not used
    );
    defparam mem_fifo.fifo_width = WIDTH_HEIGHT;

    fifo_control fifo_arr (
        .clk         (clk),
        .reset       (reset_global),            // from master_control
        .active      (out_fifo_active),         // from master_control
        .stagger_load(1'b0),                    // fucntionality not implemented
        .fifo_en     (fifo_to_arr_en),          // to weightFifo
        .done        (fifo_to_arr_done),        // to master_control
        .weight_write(weight_write)             // to sysArr
    );
    defparam fifo_arr.fifo_width = WIDTH_HEIGHT;

    weightFifo weightFifo (
        .clk      (clk),
        .reset    (reset_global),               // from master_control
        .en       (mem_to_fifo_en | fifo_to_arr_en), // from mem_fifo & fifo_arr
        .weightIn (weightMem_rd_data),          // from weightMem
        .weightOut(weightFifo_to_sysArr)        // to sysArr
    );
    defparam weightFifo.DATA_WIDTH = DATA_WIDTH;
    defparam weightFifo.FIFO_INPUTS = WIDTH_HEIGHT;
    defparam weightFifo.FIFO_DEPTH = WIDTH_HEIGHT;


// =========================================
// --------- Output side of array ----------
// =========================================
    
    accumTable accumTable (
        .clk    (clk),
        .clear  ({WIDTH_HEIGHT{reset_global}} | {WIDTH_HEIGHT{accum_clear}}),
        .rd_en  ({WIDTH_HEIGHT{1'b1}}),         // FIXME: figure out where this signal should come from
        .wr_en  (accumTable_wr_en_in),          // from accumTableWr_control
        .rd_addr(accumTable_rd_addr),           // from accumTableRd_control
        .wr_addr(accumTable_wr_addr),           // from accumTableWr_control
        .rd_data(accumTable_data_out_to_relu),  // to reluArr
        .wr_data(accumTable_wr_data)            // from sysArr
    );
    defparam accumTable.SYS_ARR_ROWS = WIDTH_HEIGHT;
    defparam accumTable.SYS_ARR_COLS = WIDTH_HEIGHT;
    defparam accumTable.DATA_WIDTH = 2*DATA_WIDTH;
    defparam accumTable.MAX_OUT_ROWS = MAX_MAT_WH;
    defparam accumTable.MAX_OUT_COLS = MAX_MAT_WH;

    accumTableWr_control accumTableWr_control (
        .clk        (clk),
        .reset      (reset_global),             // from master_control
        .wr_en_in   (mmu_col_valid_out[0]),     // from sysArr
        .sub_row    (wr_accumTable_mat_row),    // from master_control
        .submat_m   (wr_accumTable_submat_row), // from master_control
        .submat_n   (wr_accumTable_submat_col), // from master_control
        .wr_en_out  (accumTable_wr_en_in),      // to accumTable
        .wr_addr_out(accumTable_wr_addr)        // to accumTable
    );
    defparam accumTableWr_control.SYS_ARR_ROWS = WIDTH_HEIGHT;
    defparam accumTableWr_control.SYS_ARR_COLS = WIDTH_HEIGHT;
    defparam accumTableWr_control.MAX_OUT_ROWS = MAX_MAT_WH;
    defparam accumTableWr_control.MAX_OUT_COLS = MAX_MAT_WH;

    accumTableRd_control accumTableRd_control (
        .sub_row    (rd_accumTable_mat_row),    // from master_control
        .submat_m   (rd_accumTable_submat_row), // from master_control
        .submat_n   (rd_accumTable_submat_col), // from master_control
        .rd_addr_out(accumTable_rd_addr)        // to accumTable
    );
    defparam accumTableRd_control.SYS_ARR_ROWS = WIDTH_HEIGHT;
    defparam accumTableRd_control.SYS_ARR_COLS = WIDTH_HEIGHT;
    defparam accumTableRd_control.MAX_OUT_ROWS = MAX_MAT_WH;
    defparam accumTableRd_control.MAX_OUT_COLS = MAX_MAT_WH;

    reluArr reluArr (
        .en (relu_en),                          // from master_control
        .in (accumTable_data_out_to_relu),      // from accumTable
        .out(outputMem_wr_data)                 // to outputMem
    );
    defparam reluArr.DATA_WIDTH = 2*DATA_WIDTH;
    defparam reluArr.ARR_INPUTS = WIDTH_HEIGHT;

    outputArr outputMem (
        .clk    (clk),
        .rd_en  ({WIDTH_HEIGHT{outputMem_rd_en}}), // from master_control
        .wr_en  (outputMem_wr_en),              // from master_control
        .wr_data(outputMem_wr_data),            // from reluArr
        .rd_addr({WIDTH_HEIGHT{mem_addr_bus_data}}), // from master_control
        .wr_addr({WIDTH_HEIGHT{outputMem_wr_addr}}), // from master_control
        .rd_data(outputMem_rd_data)             // to interconect (OUTPUT)
    );
    defparam outputMem.width_height = WIDTH_HEIGHT;

    /* FIXME: determine if this module is needed (don't think it is)
    wr_control outputMemControl (
        .clk    (clk),
        .reset  (reset_global),                 // from master_control
        .active (rd_to_wr_start),               // from inputMemControl NOTE: why?
        .wr_en  (outputMem_wr_en),              // to outputMem
        .wr_addr(outputMem_wr_addr_offset),     // to outputMem
        .done   (output_done),
        .sys_arr_active(sys_arr_active)
    );
    defparam outputMemControl.width_height = WIDTH_HEIGHT;
    */


// ======================================
// ----------- Flip flops ---------------
// ======================================

    integer i;

    always @(*) begin

        data_mem_calc_done = 0;
        
        for (i = 0; i < WIDTH_HEIGHT; i=i+1) begin
            // OR MMU column done signals to tell when entire MMU is done
            data_mem_calc_done = data_mem_calc_done | mmu_col_valid_out[i];
        end // for (i = 0; i < WIDTH_HEIGHT; i++)
    end

    always @(posedge clk) begin

        // set sys_arr_active 2 cycles after we read memory
        sys_arr_active1 <= sys_arr_active;
        sys_arr_active2 <= sys_arr_active1;

    end // always

endmodule // top
