## *Introduction:* 
For my TPU, I designed a 8x8 systolic array. As presented by picture below, under the scenario that there are two matrices need to do matrix multiplication, matrix A (named weight matrix) multiply with matrix B(named data matrix), each of the matrix is 8x8. Once they start to do matrix multiplication, these coefficients of two matrices will first transform into an order to feed into TPU, and then fed into each specific queue. Then these queues will output at most 8 datams to its connected cell, these cells will do multiplication and addition according to the weight and data it receives. And in the next cycle, each cell will forward its weight and data to next cell. Weight will foward from up to down, and data will forward from left to right.

  
   <img src= "https://github.com/Casear98/Systolic-array-implementation-in-RTL-for-tpu/blob/main/Pics/arch%20of%20Sys.png">
 
## *Google TPU Implementation:*

Let's take a look at how Google implements the systolic array in the TPU design. As a patient with obsessive-compulsive disorder, I redrawn the block diagram of Google TPU, and combined their patents to refine the structure of Matrix Multiply Unit and the structure of the cells, which is a small benefit. Of course, many details are also my guesses and may not be accurate. If you find any problems, please advise.

<img src= "https://github.com/Casear98/Systolic-array-implementation-in-RTL-for-tpu/blob/main/Pics/Arch.png">

## *Implementation:*

For each cell in systolic array, we have three registers: 1 ALU to record the cumulative result, 1 weight-register for storing matrix A’s data and forwarding to next row, 1 data-register for storing matrix B’s data and forwarding to next column. And total we have 8x8=64 cells. For 8x8 matrix multiplications, each element in matrix is 8 bit signed number, 4 bit represents integer part, 4bit represents precision part. And final answer of matrix multiplication, we use 16 bit signed number to represent, 8 bit represents integer part, 8 bit represents precision part. For testbench part, we create three sets of matrix multiplications to emulate three kinds of situation: the output of first set represents the initial entering of systolic array, the output of second set represents the steady state of systolic array, when the total systolic array hardware utilization is 100%, and the output of final set represents the leaving the systolic array. The outcome shows that these three situations can really be implemented.

## *Synthesize:*

I have succeeded synthesis the design and met  my constraints

------------  | 8x8 systolic array
----------- | -------------
Cycle time  | (3) ns
Total area  | 116493.18 

## *PnR:*

I have succeeded to meet my time constraints, and all the test-bench data passed, meaning that our functionality of layout works fine.

<img src= "https://github.com/Casear98/Systolic-array-implementation-in-RTL-for-TPU/blob/main/Pics/Capture.PNG">
