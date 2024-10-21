//----- Systolic Array Controller ----
//------------------------------------
// Author: Ahmed Abdelazeem
// Email: a.abdelazeem201@gmail.com
//
// Description:
// This module serves as the controller for the systolic array. 
// It handles the control signals needed to start the systolic operations, 
// address generation for input data, and output result processing.
//
// Functionality:
// - Controls the shifting and multiplication operations within the systolic array.
// - Manages data loading, state transitions, cycle counting, and result output.
// - Generates control signals for the TPU (e.g., `alu_start`, `sram_write_enable`, etc.)
//------------------------------------

module systolic_controller #(
    parameter ARRAY_SIZE = 32           // Defines the size of the systolic array
)
(
    input clk,                          // System clock
    input srstn,                        // Active-low synchronous reset
    input tpu_start,                    // TPU start signal for initiating operation
    
    // Outputs
    output reg sram_write_enable,       // Enable signal for writing data to SRAM
    output reg [6:0] addr_serial_num,   // Address selector for data access (7-bit)
    output reg alu_start,               // Start signal for shifting and multiplication in the systolic array
    output reg [8:0] cycle_num,         // Cycle counter for tracking systolic array progress
    output reg [5:0] matrix_index,      // Index for writing result data to SRAM
    output reg [1:0] data_set,          // Indicates the current data set being processed
    output reg tpu_done                 // Done signal, indicates when the TPU operation is complete
);

//------------------------------------
// Local Parameters and Registers
//------------------------------------
localparam IDLE = 3'd0;                 // Idle state
localparam LOAD_DATA = 3'd1;            // State for loading data into the systolic array
localparam WAIT1 = 3'd2;                // Wait state before rolling computation begins
localparam ROLLING = 3'd3;              // Rolling computation state (shifting & multiplication)

reg [2:0] state;                        // Current state
reg [2:0] state_nx;                     // Next state

reg [1:0] data_set_nx;                  // Next state of the data set

reg tpu_done_nx;                        // Next state of the TPU done signal

// Address Selector
reg [6:0] addr_serial_num_nx;           // Next state of the address serial number

// Systolic Array Control
reg [8:0] cycle_num_nx;                 // Next state of the cycle number
reg [5:0] matrix_index_nx;              // Next state of the matrix index

//------------------------------------
// State and Register Initialization
//------------------------------------
always @(posedge clk) begin
    if (~srstn) begin                   // On reset, initialize all control signals and states
        state <= IDLE;
        data_set <= 2'b00;
        cycle_num <= 9'b0;
        matrix_index <= 6'b0;
        addr_serial_num <= 7'b0;
        tpu_done <= 1'b0;
    end
    else begin                          // Update the state and registers on each clock cycle
        state <= state_nx;
        data_set <= data_set_nx;
        cycle_num <= cycle_num_nx;
        matrix_index <= matrix_index_nx;
        addr_serial_num <= addr_serial_num_nx;
        tpu_done <= tpu_done_nx;
    end
end

//------------------------------------
// State Transition Logic
//------------------------------------
// This block determines how the controller transitions between states based on the 
// current state, `tpu_start` signal, and systolic operation progress.
always @(*) begin
    case (state)
        IDLE: begin
            if (tpu_start)
                state_nx = LOAD_DATA;    // Transition to LOAD_DATA when TPU start signal is asserted
            else
                state_nx = IDLE;         // Stay in IDLE if no start signal
            tpu_done_nx = 1'b0;          // Clear done signal in IDLE
        end

        LOAD_DATA: begin
            state_nx = WAIT1;            // Move to WAIT1 after loading data
            tpu_done_nx = 1'b0;
        end

        WAIT1: begin
            state_nx = ROLLING;          // Start rolling computations after WAIT1
            tpu_done_nx = 1'b0;
        end

        ROLLING: begin
            if (matrix_index == 63 && data_set == 2'b01) begin
                state_nx = IDLE;         // Transition to IDLE after finishing all matrix computations
                tpu_done_nx = 1'b1;      // Assert done signal
            end
            else begin
                state_nx = ROLLING;      // Stay in ROLLING until all operations are complete
                tpu_done_nx = 1'b0;
            end
        end

        default: begin
            state_nx = IDLE;             // Default to IDLE in case of unexpected state
            tpu_done_nx = 1'b0;
        end
    endcase
end

//------------------------------------
// Address Selector (addr_serial_num)
//------------------------------------
// This block generates the next value of the `addr_serial_num`, which controls data 
// access addresses during different phases of the systolic operation.
always @(*) begin
    case (state)
        IDLE: begin
            if (tpu_start)
                addr_serial_num_nx = 7'b0;  // Initialize address serial number at the start
            else
                addr_serial_num_nx = addr_serial_num;  // Hold current value in IDLE
        end

        LOAD_DATA:
            addr_serial_num_nx = 7'b1;      // Set address for data loading

        WAIT1: 
            addr_serial_num_nx = 7'b10;     // Set address for waiting phase

        ROLLING: begin
            if (addr_serial_num == 127)
                addr_serial_num_nx = addr_serial_num;  // Hold value when max address is reached
            else
                addr_serial_num_nx = addr_serial_num + 1;  // Increment address during rolling
        end

        default:
            addr_serial_num_nx = 7'b0;      // Default address during unexpected states
    endcase
end

//------------------------------------
// Systolic Array Control Signals
//------------------------------------
// This block generates control signals for the systolic array (e.g., `alu_start`, 
// `cycle_num`, `matrix_index`, `data_set`, and `sram_write_enable`).
always @(*) begin
    case (state)
        IDLE: begin
            alu_start = 1'b0;                // Keep ALU disabled in IDLE
            cycle_num_nx = 9'b0;             // Reset cycle counter
            matrix_index_nx = 6'b0;          // Reset matrix index
            data_set_nx = 2'b0;              // Reset data set
            sram_write_enable = 1'b0;        // Disable writing to SRAM
        end

        LOAD_DATA: begin
            alu_start = 1'b0;                // No ALU operation during data loading
            cycle_num_nx = 9'b0;             // Initialize cycle counter
            matrix_index_nx = 6'b0;          // Initialize matrix index
            data_set_nx = 2'b0;              // Set data set to initial value
            sram_write_enable = 1'b0;        // Writing to SRAM is disabled in this phase
        end

        WAIT1: begin
            alu_start = 1'b0;                // No ALU operation in WAIT1
            cycle_num_nx = 9'b0;             // Hold cycle number
            matrix_index_nx = 6'b0;          // Hold matrix index
            data_set_nx = 2'b0;              // Hold data set
            sram_write_enable = 1'b0;        // Writing to SRAM is still disabled
        end

        ROLLING: begin
            alu_start = 1'b1;                // Start the ALU for systolic array operations
            cycle_num_nx = cycle_num + 1;    // Increment cycle number
            if (cycle_num >= ARRAY_SIZE + 1) begin
                if (matrix_index == 63) begin
                    matrix_index_nx = 6'b0;  // Reset matrix index after one complete set
                    data_set_nx = data_set + 1;  // Move to the next data set
                end
                else begin
                    matrix_index_nx = matrix_index + 1;  // Increment matrix index
                    data_set_nx = data_set;              // Keep the same data set
                end
                sram_write_enable = 1'b1;    // Enable writing results to SRAM
            end
            else begin
                matrix_index_nx = 6'b0;      // Hold matrix index if not ready
                data_set_nx = data_set;      // Hold data set
                sram_write_enable = 1'b0;    // Writing disabled until ready
            end
        end

        default: begin
            alu_start = 1'b0;                // Default case: disable ALU
            cycle_num_nx = 9'b0;             // Reset cycle number
            matrix_index_nx = 6'b0;          // Reset matrix index
            data_set_nx = 2'b0;              // Reset data set
            sram_write_enable = 1'b0;        // Disable writing to SRAM
        end
    endcase
end

endmodule
