// Macros for talking with different address spaces
`define CONTROL_OFFSET 2'b00
`define INPUT_OFFSET 2'b01
`define WEIGHT_OFFSET 2'b10
`define OUTPUT_OFFSET 2'b11


// Macros for control signals. Write these to get the mapped function
`define RESET 4'b1111
`define FILL_FIFO 4'b0001
`define DRAIN_FIFO 4'b0010
`define MULTIPLY 4'b0011

module matrixMultiplier (
	clk,
	reset,
	slave_address,
	slave_read,
	slave_write,
	slave_readdata,
	slave_writedata,
	slave_byteenable
);


    // BE SURE TO USE FULL AVALON (not lightweight) BUS IN QSYS
    parameter DATA_WIDTH = 64;
    parameter WIDTH_HEIGHT = 16;
    parameter TPU_DATA_WIDTH = WIDTH_HEIGHT * 8;

    input clk;
    input reset;
    input [9:0] slave_address;
    input slave_read;
    input slave_write;
    input [DATA_WIDTH-1:0] slave_writedata;
    input [(DATA_WIDTH/8)-1:0] slave_byteenable;

    output reg [DATA_WIDTH-1:0] slave_readdata;


    /* TODO:
     *
     *      - inputMem_wr_en & weightMem_wr_en                  />
     *      - outputMem_rd_en                                   />
     *      - inputMem_wr_addr & weightMem_wr_addr              />
     *      - outputMem_rd_addr                                 />
     *      - inputMem_wr_data & weightMem_wr_data              />
     *      - outputMem_rd_data                                 />
     *      - Control Signals (Write)                           />
     *          + reset                                         />
     *          + active                                        />
     *              - inputMem_rd_addr_base                     />
     *              - outputMem_wr_addr_base                    />
     *          + fill_fifo                                     />
     *              - weightMem_rd_addr_base                    />
     *          + drain_fifo                                    />
     *      - Control Signals (Read)                            />
     *          + mem_to_fifo_done                              />
     *          + fifo_to_arr_done                              />
     *          + output_done                                   />
     *      - slave_readdata                                    />
     */


    // ========================================
    // --------- wr/rd enables ----------------
    // ========================================


    wire [WIDTH_HEIGHT - 1:0] inputMem_wr_en;
    wire [WIDTH_HEIGHT - 1:0] weightMem_wr_en;
    wire [WIDTH_HEIGHT - 1:0] outputMem_rd_en;

    assign inputMem_wr_en = {16{slave_write & (slave_address[9:8] == `INPUT_OFFSET)}};
    assign weightMem_wr_en = {16{slave_write & (slave_address[9:8] == `WEIGHT_OFFSET)}};
    assign outputMem_rd_en = {16{slave_read & (slave_address[9:8] == `OUTPUT_OFFSET)}};


    // ========================================
    // ------------ wr/rd addresses -----------
    // ========================================


    wire [TPU_DATA_WIDTH - 1:0] inputMem_wr_addr;
    wire [TPU_DATA_WIDTH - 1:0] weightMem_wr_addr;
    wire [TPU_DATA_WIDTH - 1:0] outputMem_rd_addr;

    assign inputMem_wr_addr = {16{slave_address[7:0]}};
    assign weightMem_wr_addr = {16{slave_address[7:0]}};
    assign outputMem_rd_addr = {16{slave_address[7:0]}};


    // ========================================
    // ------------ wr/rd data ----------------
    // ========================================


    wire [TPU_DATA_WIDTH - 1:0] inputMem_wr_data;
    wire [TPU_DATA_WIDTH - 1:0] weightMem_wr_data;
    // Driven below by TPU output, then assigned to slave_readdata
    wire [TPU_DATA_WIDTH - 1:0] outputMem_rd_data;

    assign inputMem_wr_data = {2{slave_writedata}};
    assign weightMem_wr_data = {2{slave_writedata}};


    // ========================================
    // ----------- Control (inputs) -----------
    // ========================================


    reg [TPU_DATA_WIDTH - 1:0] inputMem_rd_addr_base;
    reg [TPU_DATA_WIDTH - 1:0] weightMem_rd_addr_base;
    reg [TPU_DATA_WIDTH - 1:0] outputMem_wr_addr_base;

    reg reset_tpu;
    reg fill_fifo;
    reg drain_fifo;
    reg multiply;

    always @(posedge clk) begin

        if ((slave_write == 1) && (slave_address[9:8] == `CONTROL_OFFSET)) begin
            case (slave_writedata[3:0])
                `RESET: begin
                    reset_tpu <= 1'b1;
                    fill_fifo <= 1'b0;
                    drain_fifo <= 1'b0;
                    multiply <= 1'b0;
                    weightMem_rd_addr_base <= 128'h0000_0000_0000_0000_0000_0000_0000_0000;
                    inputMem_rd_addr_base <= 128'h0000_0000_0000_0000_0000_0000_0000_0000;
                    outputMem_wr_addr_base <= 128'h0000_0000_0000_0000_0000_0000_0000_0000;
                end

                `FILL_FIFO: begin
                    reset_tpu <= 1'b0;
                    fill_fifo <= 1'b1;
                    drain_fifo <= 1'b0;
                    multiply <= 1'b0;
                    weightMem_rd_addr_base <= {16{slave_writedata[11:4]}};
                end

                `DRAIN_FIFO: begin
                    reset_tpu <= 1'b0;
                    fill_fifo <= 1'b0;
                    drain_fifo <= 1'b1;
                    multiply <= 1'b0;
                end

                `MULTIPLY: begin
                    reset_tpu <= 1'b0;
                    fill_fifo <= 1'b0;
                    drain_fifo <= 1'b0;
                    multiply <= 1'b1;
                    inputMem_rd_addr_base <= {16{slave_writedata[11:4]}};
                    outputMem_wr_addr_base <= {16{slave_writedata[19:12]}};
                end
            endcase // slave_writedata[3:0]
        end // if ((slave_write == 1) && (slave_address[9:8] == `CONTROL_OFFSET))
    end // always @(posedge clk)


    // ========================================
    // --------- Bus Read Side ----------------
    // ========================================


    wire mem_to_fifo_done;
    wire fifo_to_arr_done;
    wire output_done;

    always @(*) begin
        slave_readdata = 64'h0000_0000_0000_0000_0000_0000_0000_0000;

        case(slave_address[9:8])
            `CONTROL_OFFSET: slave_readdata = { 61'd0, output_done, fifo_to_arr_done, mem_to_fifo_done};
            `OUTPUT_OFFSET: slave_readdata = outputMem_rd_data[63:0];
            default: slave_readdata = 64'h0000_0000_0000_0000_0000_0000_0000_0000;
        endcase
    end // alwasy @(*)


    // ========================================
    // ------------ TPU Instantiation ---------
    // ========================================


    top TPU (
        .clk                   (clk),
        .reset                 (reset_tpu),
        .active                (multiply),
        .inputMem_wr_en        (inputMem_wr_en),
        .inputMem_wr_addr      (inputMem_wr_addr),
        .inputMem_wr_data      (inputMem_wr_data),
        .inputMem_rd_addr_base (inputMem_rd_addr_base),
        .outputMem_rd_en       (outputMem_rd_en),
        .outputMem_rd_addr     (outputMem_rd_addr),
        .outputMem_rd_data     (outputMem_rd_data),
        .outputMem_wr_addr_base(outputMem_wr_addr_base),
        .weightMem_wr_en       (weightMem_wr_en),
        .weightMem_wr_addr     (weightMem_wr_addr),
        .weightMem_wr_data     (weightMem_wr_data),
        .weightMem_rd_addr_base(weightMem_rd_addr_base),
        .fill_fifo             (fill_fifo),
        .drain_fifo            (drain_fifo),
        .mem_to_fifo_done      (mem_to_fifo_done),
        .fifo_to_arr_done      (fifo_to_arr_done),
        .output_done           (output_done)
    );


endmodule
