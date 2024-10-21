# TPU (Tensor Processing Unit) Project

This project implements a Tensor Processing Unit (TPU) with a 32x32 Systolic Array architecture designed for efficient matrix operations. The TPU utilizes a combination of modules for address selection, quantization, systolic processing, and control logic.

## Project Structure

The project consists of several Verilog modules that work together to perform matrix computations using a systolic array. The main components include:

1. **systolic.v** - Implements the systolic array processing.
2. **systolic_controll.v** - Controls the overall operation of the TPU, managing state transitions and data flow.
3. **quantize.v** - Performs quantization of the input data from the systolic array.
4. **addr_sel.v** - Manages the address selection for the queues in the system.
5. **tpu_top.v** - The top-level module that integrates all components of the TPU.

## Module Descriptions

### 1. Systolic Array
- **Module Name**: `systolic`
- **Description**: This module implements a 32x32 systolic array for matrix multiplications. The systolic array processes input data in a pipelined manner, enabling efficient computation by distributing the workload across multiple processing elements.

### 2. Systolic Controller
- **Module Name**: `systolic_controll`
- **Description**: This module manages the state machine for the TPU operations. It coordinates the start and stop of computations and handles data flow between the systolic array and memory.

### 3. Quantization
- **Module Name**: `quantize`
- **Description**: This module quantizes the output data from the systolic array to reduce the data size and format it for further processing or storage.

### 4. Address Selector
- **Module Name**: `addr_sel`
- **Description**: This module selects addresses for reading data from the memory for the systolic array, ensuring that the correct data is accessed based on the current operation.

### 5. TPU Top Level
- **Module Name**: `tpu_top`
- **Description**: The top-level module that connects all components together, manages inputs and outputs, and orchestrates the overall TPU functionality.

## Usage

To simulate and synthesize the TPU project:

1. Ensure you have a Verilog simulator or synthesizer installed (e.g., ModelSim, Xilinx Vivado).
2. Add the Verilog files to your project workspace.
3. Compile and simulate the `tpu_top` module to observe the TPU operations.
4. Adjust parameters as necessary to fit your specific application.

## Parameters

- `ARRAY_SIZE`: Defines the size of the systolic array. Default is set to 32.
- `SRAM_DATA_WIDTH`: Width of the SRAM data bus. Default is set to 32 bits.
- `DATA_WIDTH`: Width of the input data. Default is set to 8 bits.
- `OUTPUT_DATA_WIDTH`: Width of the quantized output data. Default is set to 16 bits.

## License

This project is licensed under the MIT License. See the LICENSE file for more information.

## Contributing

If you would like to contribute to this project, please fork the repository and submit a pull request with your changes. 


