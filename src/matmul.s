.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:

    # Error checks
    li t0 1
    blt a1 t0 exit_bad_len
    blt a2 t0 exit_bad_len
    blt a4 t0 exit_bad_len
    blt a5 t0 exit_bad_len
    bne a2 a4 exit_col_row_unmatch
    # Prologue
    addi sp sp -36
    sw s0 0(sp)
    sw s1 4(sp)
    sw s2 8(sp)
    sw s3 12(sp)
    sw s4 16(sp)
    sw s5 20(sp)
    sw s6 24(sp)
    sw s7 28(sp)
    sw ra 32(sp)

    li s0 0  # row index of m0
    li s1 0  # col index of m1
    mv s2 a0 # pointer of m0
    mv s3 a3 # pointer of m1
    mv s4 a1 # rows of m0
    mv s5 a5 # cols of m1
    mv s6 a4 # cols of m0
    mv s7 a6 # pointer of d
    
outer_loop_start:
    beq s0 s4 outer_loop_end
inner_loop_start:
    beq s1 s5 inner_loop_end
    # call dot
    mv a0 s2
    mv a1 s3
    mv a2 s6
    li a3 1
    mv a4 s5
    jal ra dot
    sw a0 0(s7)
    addi s1 s1 1  # col index of m1 + 1
    addi s3 s3 4  # pointer to the start of next column of m1 
    addi s7 s7 4  # pointer to the next element of dest 
    j inner_loop_start
inner_loop_end:
    addi s0 s0 1  # row index of m0 + 1
    slli t0 s6 2  
    add s2 s2 t0         # pointer to the start of next row of m0
    slli t0 s1 2         
    sub s3 s3 t0         # pointer to the start of column 0 of m1
    li s1 0  # col index of m1 to zero
    j outer_loop_start

outer_loop_end:
    # Epilogue
    lw s0 0(sp)
    lw s1 4(sp)
    lw s2 8(sp)
    lw s3 12(sp)
    lw s4 16(sp)
    lw s5 20(sp)
    lw s6 24(sp)
    lw s7 28(sp)
    lw ra 32(sp)
    addi sp sp 36
    jr ra

exit_bad_len:
    li a0 38
    j exit
exit_col_row_unmatch:
    li a0 38
    j exit