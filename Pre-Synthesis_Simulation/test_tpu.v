`timescale 1ns/100ps


`define cycle_period 10
//`define End_CYCLE  250000 
module test_tpu;

localparam DATA_WIDTH = 8;
localparam OUT_DATA_WIDTH = 16;
localparam SRAM_DATA_WIDTH = 32;
localparam WEIGHT_NUM = 25, WEIGHT_WIDTH = 4;
localparam ARRAY_SIZE = 8;

//====== module I/O =====
reg clk;
reg srstn;
reg tpu_start;

wire tpu_finish;


wire sram_write_enable_a0;
wire sram_write_enable_a1;


wire sram_write_enable_b0;
wire sram_write_enable_b1;


wire sram_write_enable_c0;
wire sram_write_enable_c1;
wire sram_write_enable_c2;

wire [SRAM_DATA_WIDTH-1:0] sram_rdata_a0;
wire [SRAM_DATA_WIDTH-1:0] sram_rdata_a1;

wire [SRAM_DATA_WIDTH-1:0] sram_rdata_b0;
wire [SRAM_DATA_WIDTH-1:0] sram_rdata_b1;


wire [9:0] sram_raddr_a0;
wire [9:0] sram_raddr_a1;


wire [9:0] sram_raddr_b0;
wire [9:0] sram_raddr_b1;


wire [5:0] sram_raddr_c0;
wire [5:0] sram_raddr_c1;
wire [5:0] sram_raddr_c2;

wire [3:0] sram_bytemask_a;
wire [3:0] sram_bytemask_b;
wire [9:0] sram_waddr_a;
wire [9:0] sram_waddr_b;
wire [7:0] sram_wdata_a;
wire [7:0] sram_wdata_b;

wire [DATA_WIDTH*OUT_DATA_WIDTH-1:0] sram_wdata_c0;
wire [DATA_WIDTH*OUT_DATA_WIDTH-1:0] sram_wdata_c1;
wire [DATA_WIDTH*OUT_DATA_WIDTH-1:0] sram_wdata_c2;

wire [DATA_WIDTH*OUT_DATA_WIDTH-1:0] sram_rdata_c0;
wire [DATA_WIDTH*OUT_DATA_WIDTH-1:0] sram_rdata_c1;
wire [DATA_WIDTH*OUT_DATA_WIDTH-1:0] sram_rdata_c2;

wire [5:0] sram_waddr_c0;
wire [5:0] sram_waddr_c1;
wire [5:0] sram_waddr_c2;



wire signed [7:0] out;


//reg [7:0] mem[0:32*32-1];


//====== top connection =====



//sram connection

tpu_top my_tpu_top(
	.clk(clk),
	.srstn(srstn),
	.tpu_start(tpu_start),

	//input data
	.sram_rdata_w0(sram_rdata_a0),
	.sram_rdata_w1(sram_rdata_a1),

	.sram_rdata_d0(sram_rdata_b0),
	.sram_rdata_d1(sram_rdata_b1),

	//output weight
	.sram_raddr_w0(sram_raddr_a0),
	.sram_raddr_w1(sram_raddr_a1),

	.sram_raddr_d0(sram_raddr_b0),
	.sram_raddr_d1(sram_raddr_b1),

	//write to the SRAM for comparision
	.sram_write_enable_a0(sram_write_enable_c0),
	.sram_wdata_a(sram_wdata_c0),
	.sram_waddr_a(sram_waddr_c0),

	.sram_write_enable_b0(sram_write_enable_c1),
	.sram_wdata_b(sram_wdata_c1),
	.sram_waddr_b(sram_waddr_c1),

	.sram_write_enable_c0(sram_write_enable_c2),
	.sram_wdata_c(sram_wdata_c2),
	.sram_waddr_c(sram_waddr_c2),

	.tpu_done(tpu_finish)
);

sram_128x32b sram_128x32b_a0(
.clk(clk),
.bytemask(sram_bytemask_a),
.csb(1'b0),
.wsb(sram_write_enable_a0),
.wdata(sram_wdata_a), 
.waddr(sram_waddr_a), 
.raddr(sram_raddr_a0), 
.rdata(sram_rdata_a0)
);

sram_128x32b sram_128x32b_a1(
.clk(clk),
.bytemask(sram_bytemask_a),
.csb(1'b0),
.wsb(sram_write_enable_a1),
.wdata(sram_wdata_a), 
.waddr(sram_waddr_a), 
.raddr(sram_raddr_a1), 
.rdata(sram_rdata_a1)
);


//SRAM 2 
sram_128x32b sram_128x32b_b0(
.clk(clk),
.bytemask(sram_bytemask_b),
.csb(1'b0),
.wsb(sram_write_enable_b0),
.wdata(sram_wdata_b), 
.waddr(sram_waddr_b), 
.raddr(sram_raddr_b0), 
.rdata(sram_rdata_b0)
);

sram_128x32b sram_128x32b_b1(
.clk(clk),
.bytemask(sram_bytemask_b),
.csb(1'b0),
.wsb(sram_write_enable_b1),
.wdata(sram_wdata_b), 
.waddr(sram_waddr_b), 
.raddr(sram_raddr_b1), 
.rdata(sram_rdata_b1)
);


//write sram
sram_16x128b sram_16x128b_c0(
.clk(clk),
.csb(1'b0),
.wsb(sram_write_enable_c0),
.wdata(sram_wdata_c0), 
.waddr(sram_waddr_c0), 
.raddr(sram_raddr_c0), 
.rdata(sram_rdata_c0)
);
sram_16x128b sram_16x128b_c1(
.clk(clk),
.csb(1'b0),
.wsb(sram_write_enable_c1),
.wdata(sram_wdata_c1), 
.waddr(sram_waddr_c1), 
.raddr(sram_raddr_c1), 
.rdata(sram_rdata_c1)
);
sram_16x128b sram_16x128b_c2(
.clk(clk),
.csb(1'b0),
.wsb(sram_write_enable_c2),
.wdata(sram_wdata_c2), 
.waddr(sram_waddr_c2), 
.raddr(sram_raddr_c2), 
.rdata(sram_rdata_c2)
);



//dump wave file
initial begin
  $fsdbDumpfile("tpu.fsdb"); // "gray.fsdb" can be replaced into any name you want
  $fsdbDumpvars("+mda");              // but make sure in .fsdb format
end

//====== clock generation =====
initial begin
    srstn = 1'b1;
    clk = 1'b1;
    #(`cycle_period/2);
    while(1) begin
      #(`cycle_period/2) clk = ~clk; 
    end
end

//====== main procedural block for simulation =====
integer cycle_cnt;


integer i,j;
reg [ARRAY_SIZE*DATA_WIDTH-1:0] mat1[0:ARRAY_SIZE*3-1];
reg [ARRAY_SIZE*DATA_WIDTH-1:0] mat2[0:ARRAY_SIZE*3-1];
reg [ARRAY_SIZE*3*DATA_WIDTH-1:0] tmp_c_mat1[0:ARRAY_SIZE-1];
reg [ARRAY_SIZE*3*DATA_WIDTH-1:0] tmp_c_mat2[0:ARRAY_SIZE-1];
reg [(ARRAY_SIZE*3+3)*DATA_WIDTH-1:0] tmp_mat1[0:ARRAY_SIZE-1];
reg [(ARRAY_SIZE*3+3)*DATA_WIDTH-1:0] tmp_mat2[0:ARRAY_SIZE-1];
reg [ARRAY_SIZE*OUT_DATA_WIDTH-1:0] golden1[0:ARRAY_SIZE-1];
reg [ARRAY_SIZE*OUT_DATA_WIDTH-1:0] golden2[0:ARRAY_SIZE-1];
reg [ARRAY_SIZE*OUT_DATA_WIDTH-1:0] golden3[0:ARRAY_SIZE-1];

reg [ARRAY_SIZE*16-1:0] trans_golden1[0:(ARRAY_SIZE*2-1)-1];
reg [ARRAY_SIZE*16-1:0] trans_golden2[0:(ARRAY_SIZE*2-1)-1];
reg [ARRAY_SIZE*16-1:0] trans_golden3[0:(ARRAY_SIZE*2-1)-1];

/*
initial begin
	#(`End_CYCLE);
	$display("-----------------------------------------------------\n");
	$display("Error!!! There is something wrong with your code ...!\n");
 	$display("------The test result is .....FAIL ------------------\n");
 	$display("-----------------------------------------------------\n");
 	$finish;
end
*/
initial begin
    $readmemb("data/mat1.txt", mat1);
    $readmemb("data/mat2.txt", mat2);
    $readmemb("golden/golden1.txt",golden1);
    $readmemb("golden/golden2.txt",golden2);
    $readmemb("golden/golden3.txt",golden3);

    #(`cycle_period);
    
	data2sram;
	golden_transform;
        $write("|\n");
        $write("Three input groups of matrix\n");
        $write("|\n");
        display_data;  

        /////////////////////////////////////////////////////////
        
        tpu_start = 1'b0;

        /////////////////////////////////////////////////////////

        
        //start to do CONV2 and POOL2, and write your result into sram a0 

        cycle_cnt = 0;
        @(negedge clk);
        srstn = 1'b0;
        @(negedge clk);
        srstn = 1'b1;
        tpu_start = 1'b1;  //one-cycle pulse signal  
        @(negedge clk);
        tpu_start = 1'b0;
        while(~tpu_finish)begin    //it's mean that your sram c0, c1, c2 can be tested
            @(negedge clk);     begin
                cycle_cnt = cycle_cnt + 1;
            end
        end



	// test our three sets of answer!!!
	for(i = 0; i<(ARRAY_SIZE*2-1); i = i+1)begin
		if(trans_golden1[i] == sram_16x128b_c0.mem[i]) $write("sram #c0 address: %d PASS!!\n", i[5:0]);
		else begin
                    $write("You have wrong answer in the sram #c0 !!!\n\n");
                    $write("Your answer at address %d is \n%d %d %d %d %d %d %d %d \n",i[5:0],$signed(sram_16x128b_c0.mem[i][(ARRAY_SIZE*16-1)-:OUT_DATA_WIDTH]),$signed(sram_16x128b_c0.mem[i][((ARRAY_SIZE-1)*16-1)-:OUT_DATA_WIDTH]),$signed(sram_16x128b_c0.mem[i][((ARRAY_SIZE-2)*16-1)-:OUT_DATA_WIDTH]),$signed(sram_16x128b_c0.mem[i][((ARRAY_SIZE-3)*16-1)-:OUT_DATA_WIDTH]),$signed(sram_16x128b_c0.mem[i][((ARRAY_SIZE-4)*16-1)-:OUT_DATA_WIDTH]),$signed(sram_16x128b_c0.mem[i][((ARRAY_SIZE-5)*16-1)-:OUT_DATA_WIDTH]),$signed(sram_16x128b_c0.mem[i][((ARRAY_SIZE-6)*16-1)-:OUT_DATA_WIDTH]),$signed(sram_16x128b_c0.mem[i][((ARRAY_SIZE-7)*16-1)-:OUT_DATA_WIDTH]));
                    $write("But the golden answer is  \n%d %d %d %d %d %d %d %d \n",$signed(trans_golden1[i][((ARRAY_SIZE)*16-1)-:OUT_DATA_WIDTH]),$signed(trans_golden1[i][((ARRAY_SIZE-1)*16-1)-:OUT_DATA_WIDTH]),$signed(trans_golden1[i][((ARRAY_SIZE-2)*16-1)-:OUT_DATA_WIDTH]),$signed(trans_golden1[i][((ARRAY_SIZE-3)*16-1)-:OUT_DATA_WIDTH]),$signed(trans_golden1[i][((ARRAY_SIZE-4)*16-1)-:OUT_DATA_WIDTH]),$signed(trans_golden1[i][((ARRAY_SIZE-5)*16-1)-:OUT_DATA_WIDTH]),$signed(trans_golden1[i][((ARRAY_SIZE-6)*16-1)-:OUT_DATA_WIDTH]),$signed(trans_golden1[i][((ARRAY_SIZE-7)*16-1)-:OUT_DATA_WIDTH]));
                    $finish;
                end

	end
	for(i = 0; i<(ARRAY_SIZE*2-1); i = i+1)begin
		if(trans_golden2[i] == sram_16x128b_c1.mem[i]) $write("sram #c1 address: %d PASS!!\n", i[5:0]);
		else begin
                    $write("You have wrong answer in the sram #c1 !!!\n\n");
                    $write("Your answer at address %d is \n%d %d %d %d  \n",i[5:0],$signed(sram_16x128b_c1.mem[i][(ARRAY_SIZE*16-1)-:OUT_DATA_WIDTH]),$signed(sram_16x128b_c1.mem[i][((ARRAY_SIZE-1)*16-1)-:OUT_DATA_WIDTH]),$signed(sram_16x128b_c1.mem[i][((ARRAY_SIZE-2)*16-1)-:OUT_DATA_WIDTH]),$signed(sram_16x128b_c1.mem[i][((ARRAY_SIZE-3)*16-1)-:OUT_DATA_WIDTH]));
                    $write("But the golden answer is  \n%d %d %d %d \n",$signed(trans_golden2[i][(ARRAY_SIZE*16-1)-:OUT_DATA_WIDTH]),$signed(trans_golden2[i][((ARRAY_SIZE-1)*16-1)-:OUT_DATA_WIDTH]),$signed(trans_golden2[i][((ARRAY_SIZE-2)*16-1)-:OUT_DATA_WIDTH]),$signed(trans_golden2[i][((ARRAY_SIZE-3)*16-1)-:OUT_DATA_WIDTH]));
                    $finish;
                end

	end
	for(i = 0; i<(ARRAY_SIZE*2-1); i = i+1)begin
		if(trans_golden3[i] == sram_16x128b_c2.mem[i]) $write("sram #c1 address: %d PASS!!\n", i[5:0]);
		else begin
                    $write("You have wrong answer in the sram #c2 !!!\n\n");
                    $write("Your answer at address %d is \n%d %d %d %d  \n",i[5:0],$signed(sram_16x128b_c2.mem[i][(ARRAY_SIZE*16-1)-:OUT_DATA_WIDTH]),$signed(sram_16x128b_c2.mem[i][((ARRAY_SIZE-1)*16-1)-:OUT_DATA_WIDTH]),$signed(sram_16x128b_c2.mem[i][((ARRAY_SIZE-2)*16-1)-:OUT_DATA_WIDTH]),$signed(sram_16x128b_c2.mem[i][((ARRAY_SIZE-3)*16-1)-:OUT_DATA_WIDTH]));
                    $write("But the golden answer is  \n%d %d %d %d \n",$signed(trans_golden3[i][(ARRAY_SIZE*16-1)-:OUT_DATA_WIDTH]),$signed(trans_golden3[i][((ARRAY_SIZE-1)*16-1)-:OUT_DATA_WIDTH]),$signed(trans_golden3[i][((ARRAY_SIZE-2)*16-1)-:OUT_DATA_WIDTH]),$signed(trans_golden3[i][((ARRAY_SIZE-3)*16-1)-:OUT_DATA_WIDTH]));
                    $finish;
                end

	end
      
    $display("Total cycle count C after three matrix evaluation = %d.", cycle_cnt);
    #5 $finish;
end

task data2sram;
  begin
	// reset tmp_mat1, tmp_mat2, tmp_c_mat1, tmp_c_mat2
	for(i = 0; i< ARRAY_SIZE ; i = i + 1) begin
		tmp_c_mat1[i] = 0;
		tmp_c_mat2[i] = 0;
		tmp_mat1[i] = 0;
		tmp_mat2[i] = 0;
	end	
	// combine three batch together into tmp_mat1, tmp_mat2
	for(i = 0; i< 3 ; i = i + 1) begin
		for(j = 0; j< ARRAY_SIZE; j = j+1)begin
			tmp_c_mat1[j] = {mat1[ARRAY_SIZE*i+j], tmp_c_mat1[j][(ARRAY_SIZE*3*DATA_WIDTH-1) -: 2*DATA_WIDTH*ARRAY_SIZE]};
			tmp_c_mat2[j] = {mat2[ARRAY_SIZE*i+j], tmp_c_mat2[j][(ARRAY_SIZE*3*DATA_WIDTH-1) -: 2*DATA_WIDTH*ARRAY_SIZE]};
		end
	end
	for(i = 0; i< ARRAY_SIZE ; i = i + 1) begin
		case (i % 4)
			0 : begin
				tmp_mat1[i] = {24'b0, tmp_c_mat1[i]};
				tmp_mat2[i] = {24'b0, tmp_c_mat2[i]};
			    end
			1 : begin
				tmp_mat1[i] = {16'b0, tmp_c_mat1[i], 8'b0};
				tmp_mat2[i] = {16'b0, tmp_c_mat2[i], 8'b0};
			    end
			2 : begin
				tmp_mat1[i] = {8'b0, tmp_c_mat1[i], 16'b0};
				tmp_mat2[i] = {8'b0, tmp_c_mat2[i], 16'b0};
			    end
			3 : begin
				tmp_mat1[i] = {tmp_c_mat1[i], 24'b0};
				tmp_mat2[i] = {tmp_c_mat2[i], 24'b0};
			    end
			default : begin
					tmp_mat1[i] = 0;
					tmp_mat2[i] = 0;
				  end
		endcase
	end
	
	for(i = 0; i < 128; i=i+1)begin
		if(i < (ARRAY_SIZE*3+3))begin
		sram_128x32b_a0.char2sram(i,{tmp_mat1[0][(DATA_WIDTH*(i+1)-1) -: DATA_WIDTH], tmp_mat1[1][(DATA_WIDTH*(i+1)-1) -: DATA_WIDTH], tmp_mat1[2][(DATA_WIDTH*(i+1)-1) -: DATA_WIDTH], tmp_mat1[3][(DATA_WIDTH*(i+1)-1) -: DATA_WIDTH]});
		sram_128x32b_a1.char2sram(i,{tmp_mat1[4][(DATA_WIDTH*(i+1)-1) -: DATA_WIDTH], tmp_mat1[5][(DATA_WIDTH*(i+1)-1) -: DATA_WIDTH], tmp_mat1[6][(DATA_WIDTH*(i+1)-1) -: DATA_WIDTH], tmp_mat1[7][(DATA_WIDTH*(i+1)-1) -: DATA_WIDTH]});
		
		sram_128x32b_b0.char2sram(i,{tmp_mat2[0][(DATA_WIDTH*(i+1)-1) -: DATA_WIDTH], tmp_mat2[1][(DATA_WIDTH*(i+1)-1) -: DATA_WIDTH], tmp_mat2[2][(DATA_WIDTH*(i+1)-1) -: DATA_WIDTH], tmp_mat2[3][(DATA_WIDTH*(i+1)-1) -: DATA_WIDTH]});
		sram_128x32b_b1.char2sram(i,{tmp_mat2[4][(DATA_WIDTH*(i+1)-1) -: DATA_WIDTH], tmp_mat2[5][(DATA_WIDTH*(i+1)-1) -: DATA_WIDTH], tmp_mat2[6][(DATA_WIDTH*(i+1)-1) -: DATA_WIDTH], tmp_mat2[7][(DATA_WIDTH*(i+1)-1) -: DATA_WIDTH]});
		end
		else begin
			sram_128x32b_a0.char2sram(i, 32'b0);
			sram_128x32b_a1.char2sram(i, 32'b0);

			sram_128x32b_b0.char2sram(i, 32'b0);
			sram_128x32b_b1.char2sram(i, 32'b0);
		end

	end
	$write("SRAM a0!!!!\n");
	for(i = 0; i< 128 ; i = i + 1) begin
                    $write("SRAM at address %d is \n%d %d %d %d  \n",i[7:0],$signed(sram_128x32b_a0.mem[i][31:24]),$signed(sram_128x32b_a0.mem[i][23:16]),$signed(sram_128x32b_a0.mem[i][15:8]),$signed(sram_128x32b_a0.mem[i][7:0]));
	end
	$write("SRAM b0!!!!\n");
	for(i = 0; i< 128 ; i = i + 1) begin
                    $write("SRAM at address %d is \n%d %d %d %d  \n",i[7:0],$signed(sram_128x32b_b0.mem[i][31:24]),$signed(sram_128x32b_b0.mem[i][23:16]),$signed(sram_128x32b_b0.mem[i][15:8]),$signed(sram_128x32b_b0.mem[i][7:0]));
	end
  end
endtask	


//display the mnist image in 28x28 SRAM
task display_data;
integer this_i, this_j, this_k;
    begin
	for(this_k=0; this_k<3;this_k = this_k +1)begin
		$write("------------------------\n");
        	for(this_i=0;this_i<ARRAY_SIZE;this_i=this_i+1) begin
            		for(this_j=0;this_j<ARRAY_SIZE;this_j=this_j+1) begin
               			$write("%d",mat1[this_i][this_j]);
				$write(" ");
            		end
            		$write("\n");
        	end
		$write("\n");
        	for(this_i=0;this_i<ARRAY_SIZE;this_i=this_i+1) begin
            		for(this_j=0;this_j<ARRAY_SIZE;this_j=this_j+1) begin
               			$write("%d",mat2[this_i][this_j]);
				$write(" ");
            		end
            		$write("\n");
        	end
		$write("------------------------\n");
            	$write("\n");
	end
    end
endtask

task golden_transform;
integer this_i, this_j, this_k;
  begin
	for(this_k=0; this_k<(ARRAY_SIZE*2-1);this_k = this_k +1)begin	  
		trans_golden1[this_k] = 0;
		trans_golden2[this_k] = 0;
		trans_golden3[this_k] = 0;
	end
	for(this_k=0; this_k<(ARRAY_SIZE*2-1);this_k = this_k +1)begin	  
		for(this_i=0;this_i<ARRAY_SIZE;this_i=this_i+1) begin
            		for(this_j=0;this_j<ARRAY_SIZE;this_j=this_j+1) begin
				if((this_i+this_j)==this_k)begin
					trans_golden1[this_k] = {golden1[this_i][((this_j+1)*OUT_DATA_WIDTH-1) -: OUT_DATA_WIDTH], trans_golden1[this_k][(8*16-1)-:(7*OUT_DATA_WIDTH)]};
					trans_golden2[this_k] = {golden2[this_i][((this_j+1)*OUT_DATA_WIDTH-1) -: OUT_DATA_WIDTH], trans_golden2[this_k][(8*16-1)-:(7*OUT_DATA_WIDTH)]};
					trans_golden3[this_k] = {golden3[this_i][((this_j+1)*OUT_DATA_WIDTH-1) -: OUT_DATA_WIDTH], trans_golden3[this_k][(8*16-1)-:(7*OUT_DATA_WIDTH)]};
				end 
            		end
        	end
	end
	$write("Here shows the trans_golden1!!!\n");
	for(this_k=0; this_k<(ARRAY_SIZE*2-1);this_k = this_k +1)begin	  
		for(this_i=ARRAY_SIZE;this_i>0;this_i=this_i-1) begin
            		$write("%d ", $signed(trans_golden1[this_k][(this_i*OUT_DATA_WIDTH-1) -: OUT_DATA_WIDTH]));
        	end
		$write("\n\n");
	end

  end
endtask 





endmodule
