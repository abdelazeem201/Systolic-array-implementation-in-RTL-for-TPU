//-----this module is for weiting data out------

module write_out#(
	parameter ARRAY_SIZE = 8,
	parameter OUTPUT_DATA_WIDTH = 16
)
(
	input clk,
	input srstn,
	input sram_write_enable,

	input [1:0] data_set,
	input [5:0] matrix_index,

	input signed [ARRAY_SIZE*OUTPUT_DATA_WIDTH-1:0] quantized_data,
	
	output reg sram_write_enable_a0,
	output reg [ARRAY_SIZE*OUTPUT_DATA_WIDTH-1:0] sram_wdata_a,
 	output reg [5:0] sram_waddr_a,

	output reg sram_write_enable_b0,
	output reg [ARRAY_SIZE*OUTPUT_DATA_WIDTH-1:0] sram_wdata_b,
 	output reg [5:0] sram_waddr_b,

	output reg sram_write_enable_c0,
	output reg [ARRAY_SIZE*OUTPUT_DATA_WIDTH-1:0] sram_wdata_c,
 	output reg [5:0] sram_waddr_c
);

integer i;
localparam MAX_INDEX = ARRAY_SIZE - 1;

//output flip-flop
reg sram_write_enable_a0_nx;
reg sram_write_enable_b0_nx;
reg sram_write_enable_c0_nx;

reg [ARRAY_SIZE*OUTPUT_DATA_WIDTH-1:0] sram_wdata_a_nx;
reg [ARRAY_SIZE*OUTPUT_DATA_WIDTH-1:0] sram_wdata_b_nx;
reg [ARRAY_SIZE*OUTPUT_DATA_WIDTH-1:0] sram_wdata_c_nx;

reg [5:0] sram_waddr_a_nx;
reg [5:0] sram_waddr_b_nx;
reg [5:0] sram_waddr_c_nx;

//---sequential logic-----
always@(posedge clk) begin
	if(~srstn) begin
		sram_write_enable_a0 <= 1;
		sram_write_enable_b0 <= 1;
		sram_write_enable_c0 <= 1;

		sram_wdata_a <= 0;
		sram_wdata_b <= 0;
		sram_wdata_c <= 0;

		sram_waddr_a <= 0;
		sram_waddr_b <= 0;
		sram_waddr_c <= 0;
	end
	else begin
		sram_write_enable_a0 <= sram_write_enable_a0_nx;
		sram_write_enable_b0 <= sram_write_enable_b0_nx;
		sram_write_enable_c0 <= sram_write_enable_c0_nx;

		sram_wdata_a <= sram_wdata_a_nx;
		sram_wdata_b <= sram_wdata_b_nx;
		sram_wdata_c <= sram_wdata_c_nx;

		sram_waddr_a <= sram_waddr_a_nx;
		sram_waddr_b <= sram_waddr_b_nx;
		sram_waddr_c <= sram_waddr_c_nx;
	end
end


//for a0, write_enable_X0 = 0 means write
always@(*) begin
	if(sram_write_enable) begin
		case(data_set)
			0: begin
				if(matrix_index < ARRAY_SIZE) begin
					sram_write_enable_a0_nx = 0;
					for(i=0; i<ARRAY_SIZE; i=i+1) begin
						if(i<=matrix_index)
							sram_wdata_a_nx[(MAX_INDEX-i)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = quantized_data[i*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH];
						else
							sram_wdata_a_nx[(MAX_INDEX-i)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = 0;
					end
					sram_waddr_a_nx = matrix_index;
				end
				else begin							//mix type
					sram_write_enable_a0_nx = 0;
				 	for(i=0; i<ARRAY_SIZE; i=i+1) begin
						if(i < 15-matrix_index)
							sram_wdata_a_nx[(MAX_INDEX-i)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = quantized_data[(i+1+(matrix_index-ARRAY_SIZE))*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH];
						else
							sram_wdata_a_nx[(MAX_INDEX-i)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = 0;
					end
					sram_waddr_a_nx = matrix_index;
				end
			end
		
			default: begin
				sram_write_enable_a0_nx = 1;
				for(i=0; i<ARRAY_SIZE*OUTPUT_DATA_WIDTH; i=i+1) 
					sram_wdata_a_nx[i] = 0;
				sram_waddr_a_nx = 0;
			end
		endcase
	end
	else begin
		sram_write_enable_a0_nx = 1;
		for(i=0; i<ARRAY_SIZE*OUTPUT_DATA_WIDTH; i=i+1) 
			sram_wdata_a_nx[i] = 0;
		sram_waddr_a_nx = 0;
	end
end

//for b0, write_enable_X0 = 0 means write
always@(*) begin
	if(sram_write_enable) begin
		case(data_set)
			0: begin
				if(matrix_index < ARRAY_SIZE) begin			//all occupied by a
					sram_write_enable_b0_nx = 1;
					for(i=0; i<ARRAY_SIZE*OUTPUT_DATA_WIDTH; i=i+1) 
						sram_wdata_b_nx[i] = 0;
					sram_waddr_b_nx = 0;
				end
				else begin														//mix type
					sram_write_enable_b0_nx = 0;
					for(i=0; i<ARRAY_SIZE; i=i+1) begin
						if(i <= matrix_index-ARRAY_SIZE)
							sram_wdata_b_nx[(MAX_INDEX-i)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = quantized_data[i*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH];
						else
							sram_wdata_b_nx[(MAX_INDEX-i)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = 0;
					end	
					sram_waddr_b_nx = matrix_index - ARRAY_SIZE;
				end
			end
		
			1: begin
				if(matrix_index < ARRAY_SIZE) begin
					sram_write_enable_b0_nx = 0;
					for(i=0; i<ARRAY_SIZE; i=i+1) begin
						if(i < ARRAY_SIZE-matrix_index-1)
							sram_wdata_b_nx[(MAX_INDEX-i)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = quantized_data[(i+1+matrix_index)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH];
						else
							sram_wdata_b_nx[(MAX_INDEX-i)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = 0;
					end
					sram_waddr_b_nx = matrix_index + ARRAY_SIZE;	
				end
				else begin
					sram_write_enable_b0_nx = 1;
					for(i=0; i<ARRAY_SIZE*OUTPUT_DATA_WIDTH; i=i+1)
						sram_wdata_b_nx[i] = 0;
					sram_waddr_b_nx = 0;
				end
			end

			default: begin
				sram_write_enable_b0_nx = 1;
				for(i=0; i<ARRAY_SIZE*OUTPUT_DATA_WIDTH; i=i+1) 
					sram_wdata_b_nx[i] = 0;
				sram_waddr_b_nx = 0;
			end
		endcase
	end
	else begin
		sram_write_enable_b0_nx = 1;
		for(i=0; i<ARRAY_SIZE*OUTPUT_DATA_WIDTH; i=i+1) 
			sram_wdata_b_nx[i] = 0;
		sram_waddr_b_nx = 0;
	end
end

//for c0, write_enable_X0 = 0 means write
always@(*) begin
	if(sram_write_enable) begin
		case(data_set)
			1: begin
				if(matrix_index < ARRAY_SIZE) begin			//all occupied by a
					sram_write_enable_c0_nx = 0;
					for(i=0; i<ARRAY_SIZE; i=i+1) begin
						if(i<=matrix_index)
							sram_wdata_c_nx[(MAX_INDEX-i)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = quantized_data[i*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH];
						else
							sram_wdata_c_nx[(MAX_INDEX-i)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = 0;
					end
					sram_waddr_c_nx = matrix_index;
				end
				else begin														//mix type
					sram_write_enable_c0_nx = 0;
					for(i=0; i<ARRAY_SIZE; i=i+1) begin
						if(i < 15-matrix_index)
							sram_wdata_c_nx[(MAX_INDEX-i)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = quantized_data[(i+1+(matrix_index-ARRAY_SIZE))*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH];
						else
							sram_wdata_c_nx[(MAX_INDEX-i)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = 0;
					end	
					sram_waddr_c_nx = matrix_index;
				end
			end

			default: begin
				sram_write_enable_c0_nx = 1;
				for(i=0; i<ARRAY_SIZE*OUTPUT_DATA_WIDTH; i=i+1) 
					sram_wdata_c_nx[i] = 0;
				sram_waddr_c_nx = 0;
			end
		endcase
	end
	else begin
		sram_write_enable_c0_nx = 1;
		for(i=0; i<ARRAY_SIZE*OUTPUT_DATA_WIDTH; i=i+1) 
			sram_wdata_c_nx[i] = 0;
		sram_waddr_c_nx = 0;
	end
end

endmodule

