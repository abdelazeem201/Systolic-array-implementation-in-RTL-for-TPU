///sram
module sram_128x32b(
input clk,
input [3:0] bytemask,
input csb,  //chip enable
input wsb,  //write enable
input [7:0] wdata, //write data
input [9:0] waddr, //write address
input [9:0] raddr, //read address

output reg [31:0] rdata //read data
);

reg [31:0] _rdata;
reg [31:0] mem[0:256-1];


///////改bytemask 
always@(posedge clk) begin
  if(~csb && ~wsb) begin
    case (bytemask)
      4'b0001 : mem[waddr][7:0] <= wdata;
      4'b0010 : mem[waddr][15:8] <= wdata;
      4'b0100 : mem[waddr][23:16] <= wdata;
      4'b1000 : mem[waddr][31:24] <= wdata;
      default: mem[waddr] <= 0; 
    endcase
  end
end
always@(posedge clk) begin
  if(~csb) begin
    _rdata <= mem[raddr];
  end
end


always@*
begin
    //rdata = #(`cycle_period*0.2) _rdata;
    rdata =  _rdata;
end



task char2sram(
 input [31:0]index,
 input [31:0]char_in
);

  mem[index] = char_in;

endtask
 

task display();

integer this_i, this_j;
reg signed [7:0] index_0,index_1,index_2,index_3;
  begin
    for(this_i=0;this_i< 80;this_i=this_i+1) begin
          index_0 = mem[this_i][31:24];
          index_1 = mem[this_i][23:16];
          index_2 = mem[this_i][15:8];
          index_3 = mem[this_i][7:0];
          $write("%d %d %d %d \n",index_0,index_1,index_2,index_3);
    end
  end

endtask


endmodule
