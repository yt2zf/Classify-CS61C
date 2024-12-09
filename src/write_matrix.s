.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:
    # Prologue 
    addi sp sp -20
    sw s0 0(sp)
    sw s1 4(sp)
    sw s2 8(sp)
    sw s3 12(sp)
    sw ra 16(sp)

    # fopen(a0, 'w')
    mv s1 a1  # the pointer to the start of the matrix
    mv s2 a2  # number of rows
    mv s3 a3  # number of columns
    li a1 1
    jal ra fopen
    li t0 -1
    beq a0 t0 fopen_error

    mv s0 a0  # file descriptor
    
    addi sp sp -8
    sw s2 0(sp)   # &row
    sw s3 4(sp)   # &col
    mv a0 s0
    mv a1 sp
    li a2 1
    li a3 4
    jal ra fwrite # fwrite(fd, &row, 1, 4)
    li t0 1
    bne a0 t0 fwrite_error
    mv a0 s0
    addi a1 sp 4
    li a2 1
    li a3 4
    jal ra fwrite # fwrite(fd, &col, 1, 4)
    li t0 1
    bne a0 t0 fwrite_error
    addi sp sp 8

    mv a0 s0
    mv a1 s1
    mul a2 s2 s3
    li a3 4
    jal ra fwrite # fwrite(fd, inputMatrix, row*col, 4)
    mul t0 s2 s3
    bne a0 t0 fwrite_error

    # close(fd)
    mv a0 s0
    jal ra fclose
    li t0 -1
    beq a0 t0 fclose_error

    # Epilogue
    lw s0 0(sp)
    lw s1 4(sp)
    lw s2 8(sp)
    lw s3 12(sp)
    lw ra 16(sp)
    addi sp sp 20

    jr ra

fopen_error:
    li a0 27
    j exit
fwrite_error:
    li a0 30
    j exit
fclose_error:
    li a0 28
    j exit