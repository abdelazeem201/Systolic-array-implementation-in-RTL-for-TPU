// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Author: Ahmed Abdelazeem
// Github: https://github.com/abdelazeem201
// Email: ahmed.abdelazeem@outlook.com
// Description: D-FF module
// Dependencies: Trends in computing have led to a proliferation of neural Network applications. Unfortunately, todays general- purpose processors are not well suited for the class of computations these applications require, creating demand
// for a new class of processors : Tensor Processing Units (TPU). These hardware accelerators are designed with
// neural networks in mind, and allow host CPUs to offload computationally expensive tensor operations to them.
// We implement our own, low-power, scalable TPU intended for embedded and mobile applications, and evaluate its
// performance using a simulated fully connected neural Network layer.
// Since: 2021-03-27 17:18:43
// LastEditors: ahmed abdelazeem
//********************************************************************
// Module Function:
// Standard D flip-flop, transferring inputs of size DATA_WIDTH

// Inputs:
//
// clk -- clock signal
// reset -- when high, sets output to 0 on clock positive edge
// en -- enable latch
// d -- data input

// Outputs:
//
// q -- data output

module dff8(clk, reset, en, d, q);

    parameter DATA_WIDTH = 8;

    input clk;
    input reset;
    input en;
    input signed [DATA_WIDTH-1:0] d;
    output reg signed [DATA_WIDTH-1:0] q;

    always @(posedge clk) begin

        if (reset) begin
            q <= 0;
        end  // if (reset == 1'b1)

        else if (en) begin
            q <= d;
        end  // else if (en)

        else begin  // expecting this to get synthesized away (remove otherwise)
            q <= q;
        end  // else

    end  // always @(posedge clk)

endmodule  // dff8
