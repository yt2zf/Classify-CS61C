.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:
    # Prologue
    addi sp sp -28
    sw s0 0(sp)
    sw s1 4(sp)
    sw s2 8(sp)
    sw s3 12(sp)
    sw s4 16(sp)
    sw s5 20(sp)
    sw ra 24(sp)

    # fopen(a0, 'r')
    mv s1 a1
    mv s2 a2
    li a1 0
    jal ra fopen
    li t0 -1
    beq a0 t0 fopen_error
    mv s0 a0  # input_matrix file descriptor

    # fread(fd, &row, 4); fread(fd, &col, 4)
    mv a1 s1
    li a2 4
    jal ra fread
    li t0 4
    bne a0 t0 fread_error
    mv a0 s0
    mv a1 s2
    li a2 4
    jal ra fread
    li t0 4
    bne a0 t0 fread_error

    # matrix = malloc(4*row*col)
    lw t0 0(s1)
    lw t1 0(s2)
    mul s3 t0 t1  # total # of elements in matrix
    slli a0 s3 2  # 4*row*col
    jal ra malloc
    beqz a0 malloc_error
    mv s4 a0  # matrix pointer

    # for (i=0; i<total elements; i++) fread(fd, matrix[i], 4)
    li s5 0  # read count
read_loop_start:
    beq s5 s3 read_loop_end
    mv a0 s0
    slli t0 s5 2
    add a1 s4 t0  # matrix = matrix_base + 4*count
    li a2 4
    jal ra fread
    li t0 4
    bne a0 t0 fread_error
    addi s5 s5 1
    j read_loop_start

read_loop_end:
    # close(fd)
    mv a0 s0
    jal ra fclose
    li t0 -1
    beq a0 t0 fclose_error

    # return matrix
    mv a0 s4

    # Epilogue
    lw s0 0(sp)
    lw s1 4(sp)
    lw s2 8(sp)
    lw s3 12(sp)
    lw s4 16(sp)
    lw s5 20(sp)
    lw ra 24(sp)
    addi sp sp 28
    jr ra

fopen_error:
    li a0 27
    j exit
fread_error:
    li a0 29
    j exit
malloc_error:
    li a0 26
    j exit
fclose_error:
    li a0 28
    j exit
