.data
path: .asciiz "graphs.txt"
buffer: .byte 0     # A default garbage value of 0 is chosen.
buffer_size: .byte 1

open_error_str: .asciiz "Opening file failed."

# Index of source for dfs, indices are from 0 to n-1, where n is no. of vertices
source: .byte 2

.text

jal x1, open_file

# Defining the parameters for read to optimise.
la a2, buffer
la a3, buffer_size
lb a3, 0(a3)

# The contents of "graphs.txt" is stored in 0x10000100
lui x6, 0x10000
addi x6, x6, 0x100

# New line and space character defined
addi t3, zero, 0x0A
addi t4, zero, 32

jal x1, read_file

# Graph stored in 0x10000100
lui x6, 0x10000
addi x6, x6, 0x100

jal x1, dfs

jal x0, end
    
open_file:
    # Opening file in VFS, getting its file descriptor
    addi a0, zero, 13
    la a1, path
    ecall
    
    addi x6, x0, -1
    beq a0, x6, open_error
    
    addi a1, a0, 0
    jalr x0, x1, 0
    
read_file:
    addi a0, zero, 14
    ecall
    blt a0, a3, close_file
    
    lb t5, 0(a2)
    beq t5, t3, read_file
    beq t5, t4, read_file

    # Converting from ascii to normal int 
    addi t5, t5, -48
    sb t5, 0(x6)
    addi x6, x6, 1
    
    jal x0, read_file

open_error:
    # Printing string read_error
    addi a0, zero, 4
    la a1, open_error_str
    ecall
    beq x0, x0, end
    
close_file:
    addi a0, zero, 16
    ecall
    jalr x0, x1, 0
    
dfs:
    # Creating a visited array at 0x10000500 stored in x13
    lui x13, 0x10000
    addi x13, x13, 0x500 
    
    la x12, source
    lb x12, 0(x12)
    
    # Number of vertices
    lb x14, 0(x6)
    addi x18, x14, -1
    
    # Address of graph
    addi x15, x6, 1
    
    # Keeping the number 1 in x7
    addi t2, zero, 1
    
    # Logic
    addi t4, sp, 0
    
    addi sp, sp, -1
    sb x12, 0(sp)
    
    # visited[src] = 1
    add t3, x12, x13 
    sb t2, 0(t3)
    
    jal x5, stack_loop
    
stack_loop:
    beq sp, t4, close
    lb t5, 0(sp)
    
    addi a1, t5, 0
    addi a0, zero, 1
    ecall
    
    # Printing space
    addi a1, zero, 32
    addi a0, zero, 11
    ecall
    
    addi sp, sp, 1

    addi t6, x18, 0
    mul x19, t5, x14
    
    beq x0, x0, loop
    
loop:
    beq t6, x0, stack_loop
    add x22, t6, x19
    add x22, x22, x15 
    lb x23, 0(x22)
    
    # visited[i]
    add x20, x13, t6
    addi t6, t6, -1
    
    beq x23, x0, loop
    
    lb x21, 0(x20)
    bne x21, x0, loop
    
    # visited[i] = 1
    sb t2, 0(x20)
    addi sp, sp, -1
    addi t6, t6, 1
    sb t6, 0(sp) 
    addi t6, t6, -1
    beq x0, x0, loop

close:
    jalr x0, x1, 0
    
end:
    addi a0, zero, 10
    ecall
