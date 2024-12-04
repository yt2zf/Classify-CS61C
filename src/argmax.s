.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    # Prologue
    # check # elements in the array is < 1
    li t0 1
    blt a1 t0 exit_bad_len

    mv t0 a0  # t0 = array
    li a0 0   # result index = 0
    lw a2 0(t0) # max val = array[0]
    li t1 1   # index = 1
loop_start:
    beq t1 a1 loop_end  # check loop condition
    slli t2 t1 2  # 4*loop index
    add t2 t2 t0  # array_addr + 4*loop index
    lw t2 0(t2)   # array[index]
    bge a2 t2 loop_continue    # max val >= array[index] continue
    mv a0 t1   # result index = index
    mv a2 t2   # max val = array[index]
loop_continue:
    addi t1 t1 1  # index++
    j loop_start

loop_end:
    # Epilogue

    jr ra

exit_bad_len:
    li a0 36
    j exit