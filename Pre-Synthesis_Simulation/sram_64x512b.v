///////////////////////////

module sram_64x512b(
input clk,
input csb,  //chip enable
input wsb,  //write enable
input [511:0] wdata, //write data
input [5:0] waddr, //write address
input [5:0] raddr, //read address

output reg [511:0]rdata //read data
);

localparam WEIGHT_WIDTH = 16;
localparam WEIGHT_PIXEL_NUM = 32;

/*
/////////////////////
index 0~19 : conv1_w(20)
index 20 : conv1_b(1)
index 21 ~ 1020 conv2_w(1000)
index 1021 ~ 1022 conv2_b(2)
index 1100 ~ 17099 fc1_w(16000)
index 17100 ~ 17299 score_w(200)
 
/////////////////////
*/
reg [WEIGHT_PIXEL_NUM*WEIGHT_WIDTH-1:0] mem[0:64-1];
reg [511:0] _rdata;

always@(posedge clk)
  if(~csb && ~wsb)
    mem[waddr] <= wdata;

always@(posedge clk)
  if(~csb)
    _rdata <= mem[raddr];

always@*
begin
    rdata = #(`cycle_period*0.2) _rdata;
    //rdata =  _rdata;
end


task load_w(
    input integer index,
    input [511:0] weight_input
);
    mem[index] = weight_input;
endtask

task dis();
integer i;
for (i = 21;i < 41 ;i = i + 1 ) begin
  $display("%b",mem[i]);
end

endtask

endmodule
