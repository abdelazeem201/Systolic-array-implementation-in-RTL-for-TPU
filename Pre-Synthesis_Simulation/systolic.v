//----for systolic array, we have 32x32 output, 32x32 weight buffer, 32x32
//data buffer

module systolic#(
	parameter ARRAY_SIZE = 8,
	parameter SRAM_DATA_WIDTH = 32,
	parameter DATA_WIDTH = 8
)
(
	input clk,
	input srstn,
	input alu_start,												//enable signal, can start do mul and add plus shift
	input [8:0] cycle_num,
	//input pos_table [0:ARRAY_SIZE-1] [0:ARRAY_SIZE-1],

	input [SRAM_DATA_WIDTH-1:0] sram_rdata_w0,		//32 weight queue
	input [SRAM_DATA_WIDTH-1:0] sram_rdata_w1,

	input [SRAM_DATA_WIDTH-1:0] sram_rdata_d0,		//32 data queue
	input [SRAM_DATA_WIDTH-1:0] sram_rdata_d1,

	input [5:0] matrix_index,
	output reg signed [(ARRAY_SIZE*(DATA_WIDTH+DATA_WIDTH+5))-1:0] mul_outcome
);

localparam FIRST_OUT = ARRAY_SIZE+1;
localparam PARALLEL_START = ARRAY_SIZE+ARRAY_SIZE+1;
localparam OUTCOME_WIDTH = DATA_WIDTH+DATA_WIDTH+5;

reg signed [OUTCOME_WIDTH-1:0] matrix_mul_2D [0:ARRAY_SIZE-1] [0:ARRAY_SIZE-1]; 		
reg signed [OUTCOME_WIDTH-1:0] matrix_mul_2D_nx [0:ARRAY_SIZE-1] [0:ARRAY_SIZE-1]; 		
reg signed [DATA_WIDTH-1:0] data_queue [0:ARRAY_SIZE-1] [0:ARRAY_SIZE-1];
reg signed [DATA_WIDTH-1:0] weight_queue [0:ARRAY_SIZE-1] [0:ARRAY_SIZE-1];

reg signed [DATA_WIDTH+DATA_WIDTH-1:0] mul_result;

reg [5:0] upper_bound;
reg [5:0] lower_bound;

integer i,j;


//------data, weight------
always@(posedge clk) begin
	if(~srstn) begin
		for(i=0; i<ARRAY_SIZE; i=i+1) begin
			for(j=0; j<ARRAY_SIZE; j=j+1) begin
				weight_queue[i][j] <= 0;
				data_queue[i][j]   <= 0;
			end
		end
	end
	else begin
		if(alu_start) begin
			//weight shifting(a0)
			for(i=0; i<4; i=i+1) begin
				weight_queue[0][i] <= sram_rdata_w0[31-8*i-:8];
				weight_queue[0][i+4] <= sram_rdata_w1[31-8*i-:8];
			end
			
			for(i=1; i<ARRAY_SIZE; i=i+1) 
				for(j=0; j<ARRAY_SIZE; j=j+1) 
					weight_queue[i][j] <= weight_queue[i-1][j];
				
			//data shifting(b0)
			for(i=0; i<4; i=i+1) begin
				data_queue[i][0] <= sram_rdata_d0[31-8*i-:8];
				data_queue[i+4][0] <= sram_rdata_d1[31-8*i-:8];
			end
			
			for(i=0; i<ARRAY_SIZE; i=i+1) 
				for(j=1; j<ARRAY_SIZE; j=j+1) 
					data_queue[i][j] <= data_queue[i][j-1];
		end
	end
end

//-------multiplication unit------------
always@(posedge clk) begin
	if(~srstn) begin
		for(i=0; i<ARRAY_SIZE; i=i+1) 
			for(j=0; j<ARRAY_SIZE; j=j+1)  
				matrix_mul_2D[i][j] <= 0;
	end
	else begin
		for(i=0; i<ARRAY_SIZE; i=i+1) 
			for(j=0; j<ARRAY_SIZE; j=j+1) 
				matrix_mul_2D[i][j] <= matrix_mul_2D_nx[i][j];
	end
end

always@(*) begin
	if(alu_start) begin			//based on the mul_row_num, decode how many row operations need to do
		for(i=0; i<ARRAY_SIZE; i=i+1) begin
			for(j=0; j<ARRAY_SIZE; j=j+1) begin
				//multiplication and adding
				if( (cycle_num>=FIRST_OUT && (i+j)==(cycle_num-FIRST_OUT)%16) || (cycle_num >=PARALLEL_START && (i+j)==(cycle_num-PARALLEL_START)%16) ) begin
					mul_result = weight_queue[i][j] * data_queue[i][j];
					matrix_mul_2D_nx[i][j] =  { {5{mul_result[15]}} , mul_result };
				end
				else if( cycle_num>=1 && i+j<=(cycle_num-1) ) begin
					mul_result = weight_queue[i][j] * data_queue[i][j];
					matrix_mul_2D_nx[i][j] = matrix_mul_2D[i][j] + { {5{mul_result[15]}} , mul_result };
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
		for(i=0; i<ARRAY_SIZE; i=i+1) 
			for(j=0; j<ARRAY_SIZE; j=j+1) 
				matrix_mul_2D_nx[i][j] = matrix_mul_2D[i][j];
	end		
end

//------output data: mul_outcome(indexed by matrix_index)------
always@(*) begin	
	if(matrix_index < ARRAY_SIZE) begin
		upper_bound = matrix_index;
		lower_bound = matrix_index + ARRAY_SIZE;
	end
	else begin
		upper_bound = matrix_index - ARRAY_SIZE;
		lower_bound = matrix_index;
	end


	//initialization
	for(i=0; i<ARRAY_SIZE*OUTCOME_WIDTH; i=i+1)
		mul_outcome[i] = 0;

	//fetch data
	for(i=0; i<ARRAY_SIZE; i=i+1) begin
		for(j=0; j<ARRAY_SIZE-i; j=j+1) begin
			if(i+j == upper_bound)
				mul_outcome[i*OUTCOME_WIDTH+:OUTCOME_WIDTH] = matrix_mul_2D[i][j];
		end
	end

	for(i=1; i<ARRAY_SIZE; i=i+1) begin
		for(j=ARRAY_SIZE-i; j<ARRAY_SIZE; j=j+1) begin
			if(i+j == lower_bound)
				mul_outcome[i*OUTCOME_WIDTH+:OUTCOME_WIDTH] = matrix_mul_2D[i][j];
		end
	end

end

endmodule

