.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the number of elements to use is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
    # Prologue
    
    li t0 1
    blt a2 t0 exit_bad_len
    blt a3 t0 exit_bad_stride
    blt a4 t0 exit_bad_stride

    li t0 0  # loop count=0
    mv t1 a0 # t1 = array0
    li a0 0  # result = 0
    mv t2 a1  # t2 = array1
    slli a3 a3 2 # a3 * 4
    slli a4 a4 2 # a4 * 4
loop_start:
   beq t0 a2 loop_end  # check loop condition (count < numOfEles)
   lw t3 0(t1)         # t3 = array0[loop count * stride0]
   lw t4 0(t2)         # t4 = array1[loop count * stride1]
   mul t4 t3 t4        
   add a0 a0 t4

   add t1 t1 a3  # array0 += stride0
   add t2 t2 a4  # array1 += stride1
   addi t0 t0 1  # loop count += 1
   j loop_start
   
loop_end:
    # Epilogue
    jr ra

exit_bad_len:
    li a0 36
    j exit
exit_bad_stride:
    li a0 37
    j exit