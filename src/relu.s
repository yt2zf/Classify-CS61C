.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    # check # elements in the array is < 1
    li t0 1
    blt a1 t0 exit_bad_len
    # Prologue

    li t0 0  # loop index=0
loop_start:
    beq t0 a1 loop_end  # check loop condition
    slli t1 t0 2  # 4*loop index
    add t1 t1 a0  # array_addr + 4*loop index
    lw t2 0(t1)   # array[index]
    bge t2 zero loop_continue
    sw zero 0(t1) # array[index] = 0
loop_continue:
    addi t0 t0 1  # loop index++
    j loop_start
loop_end:
    # Epilogue
    jr ra

exit_bad_len:
    li a0 36
    j exit