// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Author: Ahmed Abdelazeem
// Github: https://github.com/abdelazeem201
// Email: ahmed.abdelazeem@outlook.com
// Description: FIFO module
// Dependencies: Trends in computing have led to a proliferation of neural Network applications. Unfortunately, todays general- purpose processors are not well suited for the class of computations these applications require, creating demand
// for a new class of processors : Tensor Processing Units (TPU). These hardware accelerators are designed with
// neural networks in mind, and allow host CPUs to offload computationally expensive tensor operations to them.
// We implement our own, low-power, scalable TPU intended for embedded and mobile applications, and evaluate its
// performance using a simulated fully connected neural Network layer.
// Since: 2021-03-27 18:18:23
// LastEditors: ahmed abdelazeem
//********************************************************************
// Module Function:

// Inputs:
//
// clk -- clock signal
// reset -- when high, simultaneously sets all registers to 0 on positive clock edge
// en -- when high, moves the data through FIFO
// weightIn -- input at front of FIFO

// Outputs:
//
// weightOut -- output at end of FIFO

module weightFifo(clk, reset, en, weightIn, weightOut);

    parameter DATA_WIDTH = 8;  // must be same as DATA_WIDTH in dff8.v
    parameter FIFO_INPUTS = 4;
    localparam FIFO_WIDTH = DATA_WIDTH*FIFO_INPUTS;  // number of output weights
    parameter FIFO_DEPTH = 4;  // number of stage weights

    input clk;
    input reset;
    input [FIFO_INPUTS-1:0] en;  // MSB is leftmost column in the array
    input [FIFO_WIDTH-1:0] weightIn;  // MSB is leftmost column in the array
    output wire [FIFO_WIDTH-1:0] weightOut;  // LSB is leftmost column in the array

    wire [FIFO_INPUTS*FIFO_DEPTH-1:0] colEn;  // enable signals to be sent to each element in a respective column
    wire [FIFO_WIDTH*FIFO_DEPTH-1:0] dffIn;  // inputs to each element of dff array
    wire [FIFO_WIDTH*FIFO_DEPTH-1:0] dffOut;   // ouputs of each element of dff array
    
    dff8 dffArray[FIFO_INPUTS*FIFO_DEPTH-1:0] (  // array of elements in row-major order
        .clk(clk),
        .reset(reset),
        .en(colEn),
        .d(dffIn),
        .q(dffOut)
    );

    assign dffIn[FIFO_WIDTH-1:0] = weightIn;  // assign beginning of array to input
    assign weightOut = dffOut[FIFO_WIDTH*FIFO_DEPTH-1:FIFO_WIDTH*(FIFO_DEPTH-1)];  // assign end of array to output

    generate
        genvar i;
        for (i=1; i<FIFO_DEPTH; i=i+1) begin : assignConn  // use for-loop to dynamically make connections between FFs
            assign dffIn[FIFO_WIDTH*(i+1)-1:FIFO_WIDTH*i] = dffOut[FIFO_WIDTH*i-1:FIFO_WIDTH*(i-1)];
        end  // for (i=0; i<FIFO_DEPTH; i=i+1)
    endgenerate

    generate
        genvar j;
        for (i=0; i<FIFO_INPUTS; i=i+1) begin : widthIndex  // use for-loop to dynamically make enable connections to each column
            for (j=0; j<FIFO_DEPTH; j=j+1) begin : depthIndex
                assign colEn[j*FIFO_DEPTH+i] = en[i];  // assign all dff8's in each column to the same enable signal
            end  // for (j=0; j<FIFO_DEPTH; j=j+1)
        end  // for (i=0; i<FIFO_WIDTH; i=i+1)
    endgenerate
endmodule  // weightFifo
