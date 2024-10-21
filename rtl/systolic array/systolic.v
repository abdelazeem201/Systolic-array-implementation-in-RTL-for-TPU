// Module: systolic array for matrix multiplication (32x32) 
// Author: Ahmed Abdelazeem
// Email: a.abdelazeem201@gmail.com
//
// Description:
// This module implements a 32x32 systolic array for matrix multiplication.
// The array performs matrix multiplications using weights and data buffers. 
// The weight and data queues are shifted as needed, and multiplication results are stored in 
// a matrix that can be accessed through the `mul_outcome` output.

module systolic #(
    parameter ARRAY_SIZE = 32,             // Size of the array (32x32)
    parameter SRAM_DATA_WIDTH = 32,        // Data width for SRAM input
    parameter DATA_WIDTH = 8               // Data width for elements in the matrix
)(
    input wire clk,                             // Clock signal
    input wire rst_n,                           // Synchronous reset (active low)
    input wire alu_start,                       // Enable signal to start computation
    input wire  [8:0] cycle_num,                 // Current cycle number
    input wire  [SRAM_DATA_WIDTH-1:0] sram_rdata_w0, // SRAM input for weight queue (32-bit)
    input wire  [SRAM_DATA_WIDTH-1:0] sram_rdata_w1, 
    input wire  [SRAM_DATA_WIDTH-1:0] sram_rdata_w2, 
    input wire  [SRAM_DATA_WIDTH-1:0] sram_rdata_w3, 
    input wire  [SRAM_DATA_WIDTH-1:0] sram_rdata_w4, 
    input wire  [SRAM_DATA_WIDTH-1:0] sram_rdata_w5, 
    input wire  [SRAM_DATA_WIDTH-1:0] sram_rdata_w6, 
    input wire  [SRAM_DATA_WIDTH-1:0] sram_rdata_w7, 
    input wire  [SRAM_DATA_WIDTH-1:0] sram_rdata_d0, // SRAM input for data queue (32-bit)
    input wire  [SRAM_DATA_WIDTH-1:0] sram_rdata_d1, 
    input wire  [SRAM_DATA_WIDTH-1:0] sram_rdata_d2, 
    input wire  [SRAM_DATA_WIDTH-1:0] sram_rdata_d3, 
    input wire  [SRAM_DATA_WIDTH-1:0] sram_rdata_d4, 
    input wire  [SRAM_DATA_WIDTH-1:0] sram_rdata_d5, 
    input wire  [SRAM_DATA_WIDTH-1:0] sram_rdata_d6, 
    input wire  [SRAM_DATA_WIDTH-1:0] sram_rdata_d7, 
    input wire  [5:0] matrix_index,              // Index for selecting output matrix
    output reg signed [(ARRAY_SIZE*(DATA_WIDTH+DATA_WIDTH+5))-1:0] mul_outcome // Output of the multiplication result
);

// Local parameters for controlling matrix multiplication flow
localparam FIRST_OUT = 33;
localparam PARALLEL_START = 65;
localparam OUTCOME_WIDTH = DATA_WIDTH + DATA_WIDTH + 5; // Result width of multiplication

// Internal registers
reg signed [OUTCOME_WIDTH-1:0] matrix_mul_2D [0:ARRAY_SIZE-1][0:ARRAY_SIZE-1]; // Matrix to hold multiplication results
reg signed [OUTCOME_WIDTH-1:0] matrix_mul_2D_nx [0:ARRAY_SIZE-1][0:ARRAY_SIZE-1]; // Next state of matrix_mul_2D
reg signed [DATA_WIDTH-1:0] data_queue [0:ARRAY_SIZE-1][0:ARRAY_SIZE-1];         // Data queue for inputs
reg signed [DATA_WIDTH-1:0] weight_queue [0:ARRAY_SIZE-1][0:ARRAY_SIZE-1];       // Weight queue for inputs
reg signed [DATA_WIDTH+DATA_WIDTH-1:0] mul_result;  // Temporary variable for holding multiplication result

reg [5:0] upper_bound, lower_bound; // Variables for matrix indexing
integer i, j;                        // Loop indices for iteration

// Shift weight and data queues
always @(posedge clk) begin
    if (~rst_n) begin // On reset, initialize the queues to 0
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            for (j = 0; j < ARRAY_SIZE; j = j + 1) begin
                weight_queue[i][j] <= 0;
                data_queue[i][j] <= 0;
            end
        end
    end
    else if (alu_start) begin
        // Shift weight queue
        for (i = 0; i < 4; i = i + 1) begin
            weight_queue[0][i] <= sram_rdata_w0[31-8*i-:8];
            weight_queue[0][i+4] <= sram_rdata_w1[31-8*i-:8];
            weight_queue[0][i+8] <= sram_rdata_w2[31-8*i-:8];
            weight_queue[0][i+12] <= sram_rdata_w3[31-8*i-:8];
            weight_queue[0][i+16] <= sram_rdata_w4[31-8*i-:8];
            weight_queue[0][i+20] <= sram_rdata_w5[31-8*i-:8];
            weight_queue[0][i+24] <= sram_rdata_w6[31-8*i-:8];
            weight_queue[0][i+28] <= sram_rdata_w7[31-8*i-:8];
        end
        for (i = 1; i < ARRAY_SIZE; i = i + 1)
            for (j = 0; j < ARRAY_SIZE; j = j + 1)
                weight_queue[i][j] <= weight_queue[i-1][j];
                
        // Shift data queue
        for (i = 0; i < 4; i = i + 1) begin
            data_queue[i][0] <= sram_rdata_d0[31-8*i-:8];
            data_queue[i+4][0] <= sram_rdata_d1[31-8*i-:8];
            data_queue[i+8][0] <= sram_rdata_d2[31-8*i-:8];
            data_queue[i+12][0] <= sram_rdata_d3[31-8*i-:8];
            data_queue[i+16][0] <= sram_rdata_d4[31-8*i-:8];
            data_queue[i+20][0] <= sram_rdata_d5[31-8*i-:8];
            data_queue[i+24][0] <= sram_rdata_d6[31-8*i-:8];
            data_queue[i+28][0] <= sram_rdata_d7[31-8*i-:8];
        end
        for (i = 0; i < ARRAY_SIZE; i = i + 1)
            for (j = 1; j < ARRAY_SIZE; j = j + 1)
                data_queue[i][j] <= data_queue[i][j-1];
    end
end

// Multiplication unit
always @(posedge clk) begin
    if (~rst_n) begin // Reset the matrix multiplication results to 0
        for (i = 0; i < ARRAY_SIZE; i = i + 1) 
            for (j = 0; j < ARRAY_SIZE; j = j + 1)
                matrix_mul_2D[i][j] <= 0;
    end
    else begin
        for (i = 0; i < ARRAY_SIZE; i = i + 1) 
            for (j = 0; j < ARRAY_SIZE; j = j + 1) 
                matrix_mul_2D[i][j] <= matrix_mul_2D_nx[i][j];
    end
end

// Combinational logic for multiplication and accumulation
always @(*) begin
    if (alu_start) begin
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            for (j = 0; j < ARRAY_SIZE; j = j + 1) begin
                if ((cycle_num >= FIRST_OUT && (i+j) == (cycle_num - FIRST_OUT) % 64) || 
                    (cycle_num >= PARALLEL_START && (i+j) == (cycle_num - PARALLEL_START) % 64)) begin
                    mul_result = weight_queue[i][j] * data_queue[i][j];
                    matrix_mul_2D_nx[i][j] = { {5{mul_result[15]}}, mul_result }; // Sign extension of the result
                end
                else if (cycle_num >= 1 && i + j <= (cycle_num - 1)) begin
                    mul_result = weight_queue[i][j] * data_queue[i][j];
                    matrix_mul_2D_nx[i][j] = matrix_mul_2D[i][j] + { {5{mul_result[15]}}, mul_result }; // Accumulate results
                end
                else begin
                    mul_result = 0;
                    matrix_mul_2D_nx[i][j] = matrix_mul_2D[i][j];
                end
            end
        end
    end
    else begin
        mul_result = 0;
        for (i = 0; i < ARRAY_SIZE; i = i + 1)
            for (j = 0; j < ARRAY_SIZE; j = j + 1)
                matrix_mul_2D_nx[i][j] = matrix_mul_2D[i][j];
    end
end

// Output generation: Fetch multiplication results indexed by matrix_index
always @(*) begin
    if (matrix_index < ARRAY_SIZE) begin
        upper_bound = matrix_index;
        lower_bound = matrix_index + ARRAY_SIZE;
    end
    else begin
        upper_bound = matrix_index - ARRAY_SIZE;
        lower_bound = matrix_index;
    end

    // Initialize the output
    for (i = 0; i < ARRAY_SIZE * OUTCOME_WIDTH; i = i + 1)
        mul_outcome[i] = 0;

    // Fetch data from the multiplication result matrix
    for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
        for (j = 0; j < ARRAY_SIZE - i; j = j + 1) begin
            if (i + j == upper_bound)
                mul_outcome[i * OUTCOME_WIDTH +: OUTCOME_WIDTH] = matrix_mul_2D[i][j];
        end
    end

    for (i = 1; i < ARRAY_SIZE; i = i + 1) begin
        for (j = ARRAY_SIZE - i; j < ARRAY_SIZE; j = j + 1) begin
            if (i + j == lower_bound)
                mul_outcome[i * OUTCOME_WIDTH +: OUTCOME_WIDTH] = matrix_mul_2D[i][j];
        end
    end
end

endmodule
