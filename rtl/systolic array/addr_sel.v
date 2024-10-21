//------- Ahmed Abdelazeem -------
// Email: a.abdelazeem201@gmail.com

//-------Address Selection Module-------
// This module performs address selection for 32 queues, each queue having a size of 32+32-1 (63).
// It generates the read addresses for SRAM based on the `addr_serial_num` input.
// The module calculates and outputs the addresses for both weight (w) and data (d) banks, divided into 8 sets.

module addr_sel
(
    input wire clk,                               // Clock signal
    input wire [6:0] addr_serial_num,              // Address serial number (max value = 126)
    
    // Output addresses for weight queues (w0~w7)
    output reg [9:0] sram_raddr_w0,           // Read address for queue 0~3
    output reg [9:0] sram_raddr_w1,           // Read address for queue 4~7
    output reg [9:0] sram_raddr_w2,           // Read address for queue 8~11
    output reg [9:0] sram_raddr_w3,           // Read address for queue 12~15
    output reg [9:0] sram_raddr_w4,           // Read address for queue 16~19
    output reg [9:0] sram_raddr_w5,           // Read address for queue 20~23
    output reg [9:0] sram_raddr_w6,           // Read address for queue 24~27
    output reg [9:0] sram_raddr_w7,           // Read address for queue 28~31
    
    // Output addresses for data queues (d0~d7)
    output reg [9:0] sram_raddr_d0,           // Read address for data queue 0
    output reg [9:0] sram_raddr_d1,           // Read address for data queue 1
    output reg [9:0] sram_raddr_d2,           // Read address for data queue 2
    output reg [9:0] sram_raddr_d3,           // Read address for data queue 3
    output reg [9:0] sram_raddr_d4,           // Read address for data queue 4
    output reg [9:0] sram_raddr_d5,           // Read address for data queue 5
    output reg [9:0] sram_raddr_d6,           // Read address for data queue 6
    output reg [9:0] sram_raddr_d7            // Read address for data queue 7
);

// Internal wires for the next addresses for weight queues
wire [9:0] sram_raddr_w0_nx, sram_raddr_w1_nx, sram_raddr_w2_nx, sram_raddr_w3_nx;
wire [9:0] sram_raddr_w4_nx, sram_raddr_w5_nx, sram_raddr_w6_nx, sram_raddr_w7_nx;

// Internal wires for the next addresses for data queues
wire [9:0] sram_raddr_d0_nx, sram_raddr_d1_nx, sram_raddr_d2_nx, sram_raddr_d3_nx;
wire [9:0] sram_raddr_d4_nx, sram_raddr_d5_nx, sram_raddr_d6_nx, sram_raddr_d7_nx;

//--------Sequential Logic--------
// The SRAM read addresses are updated at the rising edge of the clock.
always @(posedge clk) begin
    sram_raddr_w0 <= sram_raddr_w0_nx;
    sram_raddr_w1 <= sram_raddr_w1_nx;
    sram_raddr_w2 <= sram_raddr_w2_nx;
    sram_raddr_w3 <= sram_raddr_w3_nx;
    sram_raddr_w4 <= sram_raddr_w4_nx;
    sram_raddr_w5 <= sram_raddr_w5_nx;
    sram_raddr_w6 <= sram_raddr_w6_nx;
    sram_raddr_w7 <= sram_raddr_w7_nx;

    sram_raddr_d0 <= sram_raddr_d0_nx;
    sram_raddr_d1 <= sram_raddr_d1_nx;
    sram_raddr_d2 <= sram_raddr_d2_nx;
    sram_raddr_d3 <= sram_raddr_d3_nx;
    sram_raddr_d4 <= sram_raddr_d4_nx;
    sram_raddr_d5 <= sram_raddr_d5_nx;
    sram_raddr_d6 <= sram_raddr_d6_nx;
    sram_raddr_d7 <= sram_raddr_d7_nx;
end

//--------Combinational Logic--------
// Weight queue address selection based on addr_serial_num
assign sram_raddr_w0_nx = (addr_serial_num <= 98) ? { {3{1'd0}}, addr_serial_num } : 127;
assign sram_raddr_w1_nx = (addr_serial_num >= 4 && addr_serial_num <= 102) ? { {3{1'd0}}, addr_serial_num - 7'd4 } : 127;
assign sram_raddr_w2_nx = (addr_serial_num >= 8 && addr_serial_num <= 106) ? { {3{1'd0}}, addr_serial_num - 7'd8 } : 127;
assign sram_raddr_w3_nx = (addr_serial_num >= 12 && addr_serial_num <= 110) ? { {3{1'd0}}, addr_serial_num - 7'd12 } : 127;
assign sram_raddr_w4_nx = (addr_serial_num >= 16 && addr_serial_num <= 114) ? { {3{1'd0}}, addr_serial_num - 7'd16 } : 127;
assign sram_raddr_w5_nx = (addr_serial_num >= 20 && addr_serial_num <= 118) ? { {3{1'd0}}, addr_serial_num - 7'd20 } : 127;
assign sram_raddr_w6_nx = (addr_serial_num >= 24 && addr_serial_num <= 122) ? { {3{1'd0}}, addr_serial_num - 7'd24 } : 127;
assign sram_raddr_w7_nx = (addr_serial_num >= 28 && addr_serial_num <= 126) ? { {3{1'd0}}, addr_serial_num - 7'd28 } : 127;

// Data queue address selection based on addr_serial_num
assign sram_raddr_d0_nx = (addr_serial_num <= 98) ? { {3{1'd0}}, addr_serial_num } : 127;
assign sram_raddr_d1_nx = (addr_serial_num >= 4 && addr_serial_num <= 102) ? { {3{1'd0}}, addr_serial_num - 7'd4 } : 127;
assign sram_raddr_d2_nx = (addr_serial_num >= 8 && addr_serial_num <= 106) ? { {3{1'd0}}, addr_serial_num - 7'd8 } : 127;
assign sram_raddr_d3_nx = (addr_serial_num >= 12 && addr_serial_num <= 110) ? { {3{1'd0}}, addr_serial_num - 7'd12 } : 127;
assign sram_raddr_d4_nx = (addr_serial_num >= 16 && addr_serial_num <= 114) ? { {3{1'd0}}, addr_serial_num - 7'd16 } : 127;
assign sram_raddr_d5_nx = (addr_serial_num >= 20 && addr_serial_num <= 118) ? { {3{1'd0}}, addr_serial_num - 7'd20 } : 127;
assign sram_raddr_d6_nx = (addr_serial_num >= 24 && addr_serial_num <= 122) ? { {3{1'd0}}, addr_serial_num - 7'd24 } : 127;
assign sram_raddr_d7_nx = (addr_serial_num >= 28 && addr_serial_num <= 126) ? { {3{1'd0}}, addr_serial_num - 7'd28 } : 127;

endmodule
