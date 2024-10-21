//------- Ahmed Abdelazeem -------
// Email: a.abdelazeem201@gmail.com

//-------Quantization Module-------
// This module is designed to quantize the output data from the systolic array.
// It converts the data from a larger bit-width format (32-bit) to a smaller bit-width (16-bit).
// The input data has 16 bits for the integer part and 8 bits for the fractional part, 
// and is quantized to 8 bits for the integer and 8 bits for the fractional part.
// If the original data exceeds the 16-bit range ([-32768, 32767]), it is saturated.

module quantize#(
    parameter ARRAY_SIZE = 32,               // The size of the systolic array (32x32).
    parameter SRAM_DATA_WIDTH = 32,          // Data width of SRAM.
    parameter DATA_WIDTH = 8,                // Data width of the input data.
    parameter OUTPUT_DATA_WIDTH = 16         // Data width of the output quantized data.
)
(
    input signed [ARRAY_SIZE*(DATA_WIDTH+DATA_WIDTH+5)-1:0] ori_data,  // Original data from systolic array.
    output reg signed [ARRAY_SIZE*OUTPUT_DATA_WIDTH-1:0] quantized_data // Quantized output data.
);

// Define local parameters for saturation limits.
localparam max_val = 32767,                  // Maximum value for quantization.
          min_val = -32768;                  // Minimum value for quantization.
localparam ORI_WIDTH = DATA_WIDTH+DATA_WIDTH+5; // The bit-width of the original input data (21 bits).

// Intermediate register to hold shifted original data.
reg signed [ORI_WIDTH-1:0] ori_shifted_data;  

// Integer for loop iteration.
integer i;

//--------Quantization Process--------
// The input data is quantized by checking if it exceeds the maximum or minimum value.
// If it does, it is saturated to the respective boundary.
// Otherwise, it is directly passed to the output as a 16-bit quantized value.
always @* begin
    for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
        // Extract the original data slice.
        ori_shifted_data = ori_data[i*ORI_WIDTH +: ORI_WIDTH];
        
        // Check for saturation and quantize the data.
        if (ori_shifted_data >= max_val)
            quantized_data[i*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = max_val;
        else if (ori_shifted_data <= min_val)
            quantized_data[i*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = min_val;
        else
            quantized_data[i*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = ori_shifted_data[OUTPUT_DATA_WIDTH-1:0];
    end
end

endmodule
