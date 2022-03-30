#ifndef _INSTR_SET_H
#define _INSTR_SET_H

/**
 * tpu_init - Initialize the TPU
 *
 * Sends the reset signal to every part of the TPU as well as emptying the
 * accumulator table.
 *
 * Return: -1 on failure or 0 on success
 */
int tpu_init(void);

/**
 * tpu_rd_input - Store input matrix in input memory
 * @input: Matrix to be input
 * @addr: Address to store the matrix in the TPU input memory (first element)
 * @num_rows: Number of rows in the input matrix
 * @num_cols: Number of columns in the input matrix
 *
 * Sends the read_inputs instruction to the TPU which sends the matrix over the
 * bus by sending one column at a time. The matrix is stored in the TPU's input
 * memory with the first element at address @addr.
 *
 * Return: -1 on failure or 0 on success
 */
int tpu_rd_input(const int8_t input[][], uint16_t addr, size_t num_rows,
                 size_t num_cols);

/**
 * tpu_rd_weight - Store weight matrix in weight memory
 * @weight: Matrix to be input
 * @addr: Address to store the matrix in the TPU weight memory (first element)
 * @num_rows: Number of rows in the weight matrix
 * @num_cols: Number of columns in the weight matrix
 *
 * Sends the read_weights instruction to the TPU which sends the matrix over the
 * bus by sending one column at a time. The matrix is stored in the TPU's weight
 * memory with the first element at address @addr.
 *
 * Return: -1 on failure or 0 on success
 */
int tpu_rd_weight(const int8_t weight[][], uint16_t addr, size_t num_rows,
                  size_t num_cols);

/**
 * tpu_fill_fifo - Read the weight values into the weight FIFO
 * @addr: Address to read the matrix from the TPU weight memory (first element)
 * @num_rows: Number of rows in the weight matrix
 * @num_cols: Number of columns in the weight matrix
 *
 * Sends the fill_fifo instruction to the TPU which fills the weight FIFO with a
 * weight matrix of width @num_cols and height @num_rows from the weight memory
 * specified by address @addr.
 *
 * Return: -1 on failure or 0 on success
 */
int tpu_fill_fifo(uint16_t addr, size_t num_rows, size_t num_cols);

/**
 * tpu_mat_mult - Perform a matrix multiplication
 * @addr: Address of input memory to read the input matrix from
 * @num_rows: Number of rows in the input matrix
 * @num_cols: Number of columns in the input matrix
 * @accum_row: Row index of the accumulator table to write to
 * @accum_col: Column index of the accumulator table to write to
 *
 * Sends the matrix_multiply instruction to the TPU which loads the weights from
 * the weight FIFO into the systolic array and then inputs the input matrix from
 * address @addr into the systolic array to perform a matrix multiplication.
 * Stores the result in the accumulator table at row index @accum_row and column
 * index @accum_col.
 *
 * Return: -1 on failure or 0 on success
 */
int tpu_mat_mult(uint16_t addr, size_t num_rows, size_t num_cols, int accum_row,
                 int accum_col);

/**
 * tpu_store_outputs - Stores the result into output memory
 * @addr: Address of the output memory to write the output matrix to
 * @num_rows: Number of rows in the output matrix
 * @num_cols: Number of columns in the output matrix
 * @accum_row: Row index of the accumulator table to read from
 * @accum_col: Column index of the accmulator table to read from
 * @activate: Perform activation on outputs (1 for ReLU, 0 for none)
 * @clear: Empty the accumulator table after reading (1 to empty, 0 not empty) 
 *
 * Sends the store_outputs instruction to the TPU which reads the matrix from
 * the section of the accumulator table indexed by row @accum_row and column
 * @accum_col. Reads @num_rows rows and @num_cols columns and stores them in the
 * output memory starting at the specified address @addr.
 *
 * Return: -1 on failure or 0 on success
 */
int tpu_store_outputs(uint16_t addr, size_t num_rows, size_t num_cols,
                      int accum_row, int accum_col, int activate, int clear);

/**
 * tpu_wr_outputs - Read back output matrix
 * @output: Location for the output matrix to be stored
 * @addr: Address of the output memory to read the matrix from
 * @num_rows: Number of rows in the output matrix
 * @num_cols: Number of columns in the output matrix
 *
 * Sends the write outputs instruction to the TPU which sends the matrix over
 * the bus by sending one row at a time. The matrix is read from the TPU's
 * output memory with the first row at address @addr.
 *
 * Return: -1 on failure or 0 on success
 */
int tpu_wr_outputs(int8_t *output[][], uint16_t addr, size_t num_rows,
                   size_t num_cols);

#endif
