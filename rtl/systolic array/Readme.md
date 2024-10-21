
# 32x32 Systolic Array Project (Verilog)

## Overview

This project implements a 32x32 systolic array along with its controller, designed in Verilog. Systolic arrays are widely used in applications such as deep learning accelerators, matrix multiplication, and other high-performance computing tasks. The systolic array performs parallel matrix multiplication, while the controller manages data flow, state transitions, and communication with external memory.

### Key Modules
- **Systolic Array**: Implements a 32x32 array of processing elements (PEs) that perform multiply-accumulate operations.
- **Controller**: Manages data input/output, state transitions, and timing control for the systolic array.
- **SRAM Interface**: Handles the communication between the systolic array and external memory.

## Features

- **Parameterized Design**: The systolic array and controller can be customized via parameters such as the array size and data width.
- **Finite State Machine (FSM)**: A controller with a finite state machine that manages the loading of data, operation of the systolic array, and handling of results.
- **Cycle Counter**: Tracks the number of cycles during systolic array operation.
- **Multiplication and Accumulation**: Each processing element in the array multiplies and accumulates input data to compute the matrix product.

## Directory Structure

- `systolic.v`: The main module for the 32x32 systolic array.
- `systolic_controller.v`: The controller for managing the systolic array operations.
- `README.md`: This documentation file.
- **Testbench (Optional)**: Add a testbench to simulate and verify the design.

## How It Works

1. **Matrix Multiplication**:
   - The systolic array receives a matrix of weights and data.
   - Each processing element performs a multiply-accumulate operation using its input data and weight.
   - The results are passed along to neighboring elements, and partial sums are accumulated across the array.
   
2. **Controller**:
   - The controller moves through different states (IDLE, LOAD_DATA, WAIT, ROLLING) to manage the systolic array's operation.
   - It generates control signals to trigger operations such as loading data, starting the ALU, and writing results to SRAM.

3. **SRAM Interface**:
   - External SRAM holds the input data (weights and activations) and stores the output result.
   - The controller generates the necessary address and write enable signals to interact with the SRAM.

## Input/Output Interface

### Systolic Array (`systolic.v`)
- **Inputs**:
  - `clk`: System clock.
  - `rstn`: Active-low synchronous reset.
  - `alu_start`: Signal to start multiplication and accumulation.
  - `sram_rdata_w[7:0]`: Input data from SRAM (weights).
  - `sram_rdata_d[7:0]`: Input data from SRAM (activation data).
  - `cycle_num`: Current cycle number to track the processing steps.
  - `matrix_index`: Index of the current row/column for output.

- **Outputs**:
  - `mul_outcome`: Final output matrix result after processing.

### Controller (`systolic_controller.v`)
- **Inputs**:
  - `clk`: System clock.
  - `rstn`: Active-low reset.
  - `tpu_start`: Start signal for TPU operation.

- **Outputs**:
  - `sram_write_enable`: Enable signal for writing data to SRAM.
  - `addr_serial_num`: Address of the input data.
  - `alu_start`: Start signal for the systolic array's ALU.
  - `cycle_num`: Cycle number for controlling the systolic array.
  - `matrix_index`: Index of the output matrix.
  - `data_set`: Indicates which data set is currently being processed.
  - `tpu_done`: Indicates when the operation is complete.

## How to Use

1. **Modify Parameters**: Change parameters like `ARRAY_SIZE`, `DATA_WIDTH`, etc., in the Verilog modules to adjust the size and data width of the systolic array.
2. **Simulation**: Use your preferred Verilog simulator (ModelSim, XSIM, etc.) to run simulations with the provided testbench to verify the functionality of the systolic array and controller.
3. **Synthesis**: The design can be synthesized and deployed on FPGA or ASIC hardware, depending on your application needs.
4. **Integration**: Connect the systolic array and controller to your external memory (SRAM) and processing pipeline for data input/output.

## State Machine (Controller)

- **IDLE**: The system waits for a start signal (`tpu_start`).
- **LOAD_DATA**: The controller loads the initial weights and input data into the systolic array.
- **WAIT1**: A delay state to ensure data loading is complete.
- **ROLLING**: The systolic array shifts and performs multiply-accumulate operations. Results are written back to SRAM.

## Future Improvements

- **Larger Arrays**: Extend the design to support larger systolic arrays by modifying the parameterization.
- **Buffering and Pipelining**: Implement buffering techniques for better data management and performance.
- **Advanced Memory Management**: Add more sophisticated memory handling to support larger data sets and more complex operations.

## License

This project is open-source and can be freely modified and used in any project. Contributions and improvements are welcome.

## Author

- **Ahmed Abdelazeem**
- **Email**: a.abdelazeem201@gmail.com
