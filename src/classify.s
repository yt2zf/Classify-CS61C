.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
    # Prologue
    addi sp sp -40
    sw s0 0(sp)
    sw s1 4(sp)
    sw s2 8(sp)
    sw s3 12(sp)
    sw s4 16(sp)
    sw s5 20(sp)
    sw s6 24(sp)
    sw s7 28(sp)
    sw s8 32(sp)
    sw ra 36(sp)

    addi sp sp -24
    mv s1 a1  # char** argv
    mv s2 a2  # print/dont print
    # Read pretrained m0
    lw a0 4(s1)   # s1+4 point to filepath m0
    mv a1 sp      # pointer to rows of m0: sp
    addi a2 sp 4  # pointer to cols of m0: sp + 4
    jal ra read_matrix
    mv s3 a0  # m0 matrix pointer

    # Read pretrained m1
    lw a0 8(s1)    # s1+8 point to filepath m1
    addi a1 sp 8   # pointer to rows of m1: sp + 8
    addi a2 sp 12  # pointer to cols of m1: sp + 12
    jal ra read_matrix
    mv s4 a0  #  m1 matrix pointer   

    # Read input matrix
    lw a0 12(s1)
    addi a1 sp 16  # pointer to rows of input: sp + 16
    addi a2 sp 20  # pointer to cols of input: sp + 20
    jal ra read_matrix
    mv s5 a0  # input matrix

    # Compute h = matmul(m0, input)
    lw t0 0(sp)   # rows of m0
    lw t1 20(sp)  # cols of input
    mul a0 t0 t1
    slli a0 a0 2
    jal ra malloc # malloc(4*row*col)
    beqz a0 malloc_error
    mv s6 a0   # s6: pointer to result matrix
    mv a6 a0   # pointer to result matrix
    mv a0 s3   # m0 matrix pointer
    lw a1 0(sp)
    lw a2 4(sp)
    mv a3 s5   # input matrix pointer
    lw a4 16(sp)
    lw a5 20(sp)
    jal ra matmul

    # Compute h = relu(h)
    mv a0 s6
    lw t0 0(sp)   # rows of m0(h)
    lw t1 20(sp)  # cols of input(h)
    mul a1 t0 t1
    jal ra relu

    # Compute o = matmul(m1, h)
    lw t0 8(sp)   # rows of m1
    lw t1 20(sp)  # cols of h
    mv t2 a0      # temp store output of relu(h)
    mul a0 t0 t1
    slli a0 a0 2

    addi sp sp -4 
    sw t2 0(sp)   # caller save t2
    jal ra malloc # malloc(4*row*col)
    beqz a0 malloc_error
    lw t2 0(sp)
    addi sp sp 4

    mv s7 a0   # s7: pointer to result matrix of matmul(m1, h)
    mv a6 a0   # pointer to result matrix of matmul(m1, h)
    mv a0 s4   # m1 matrix pointer
    lw a1 8(sp)
    lw a2 12(sp)
    mv a3 t2   # pointer to h matrix
    lw a4 0(sp) # rows of h matrix
    lw a5 20(sp) # cols of h matrix
    jal ra matmul
    
    # Write output matrix o
    lw a0 16(s1) # pointer to output filename
    mv a1 s7     # pointer to result matrix of matmul(m1, h)
    lw a2 8(sp)
    lw a3 20(sp)
    jal ra write_matrix

    # Compute and return argmax(o)
    mv a0 s7
    lw t0 8(sp)
    lw t1 20(sp)
    mul a1 t0 t1
    jal ra argmax
    mv s8 a0 # return value of argmax

    # If enabled, print argmax(o) and newline
    li t0 1
    beq s2 t0 print_done
    jal ra print_int
    li a0 '\n'
    jal ra print_char

print_done:
    mv a0 s8
    addi sp sp 24

    # Epilogue
    lw s0 0(sp)
    lw s1 4(sp)
    lw s2 8(sp)
    lw s3 12(sp)
    lw s4 16(sp)
    lw s5 20(sp)
    lw s6 24(sp)
    lw s7 28(sp)
    lw s8 32(sp)
    lw ra 36(sp)
    addi sp sp 40
    jr ra

malloc_error:
    li a0 26
    j exit