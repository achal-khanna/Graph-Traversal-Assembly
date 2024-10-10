.data

adjacency_matrix: 
    .byte 0, 1, 1, 0
    .byte 0, 0, 0, 1
    .byte 0, 0, 0, 0
    .byte 0, 0, 1, 0

source: .byte 1
vertices: .byte 4
infinite: .half 0x4000
inf_string: .asciiz "inf"

.text

# Source
la x12, source
lb x12, 0(x12)

# Vertices
la x13, vertices
lb x13, 0(x13)

# Infinte
la x14, infinite
lh x14, 0(x14)

# Adjacency Matrix
la x15, adjacency_matrix

la x16, inf_string

# Storing value 1 in x18, -1 in x19
addi x18, x0, 1
addi x19, x0, -1

# Visited - x7, Distance - x6
lui x7, 0x10000
addi x6, x7, 0
addi x7, x7, 0x200
addi x6, x6, 0x300

addi x28, x0, 0
slli x30, x13, 1 
jal x1, initialise

# Node = source
addi x28, x12, 0

add x29, x28, x7
sb x18, 0(x29)
slli x29, x28, 1
add x29, x29, x6
sh x0, 0(x29)

# Main function
jal x1, dijkstra

addi x28, x0, -2
slli x31, x13, 1
jal x1, print

initialise:
    add x29, x28, x6
    sh x14, 0(x29)
    addi x28, x28, 2
    bne x28, x30, initialise
    jalr x0, x1, 0 

dijkstra:
    beq x28, x19, end_dijkstra
    add x29, x28, x7
    sb x18, 0(x29)
    
    # i = x29
    addi x29, x0, -1
    jal x5, loop
    
    # i = x29, min_node = x28, 
    addi x28, x0, -1
    addi x29, x0, -1
    jal x5, find_min_node
    jal x0, dijkstra    
    
loop:
    addi x29, x29, 1
    beq x13, x29, end_loop
    
    add x30, x29, x7
    lb x30, 0(x30)
    bne x30, x0, loop
    
    # Computing adjacency[node][i]
    mul x30, x13, x28
    add x30, x30, x29
    add x30, x30, x15
    lb x24, 0(x30)
    
    beq x24, x0, loop
    beq x24, x19, loop
    
    # Distance[node], Distance[i]
    slli x30, x28, 1
    add x30, x30, x6
    lh x20, 0(x30)
    slli x30, x29, 1
    add x30, x30, x6
    lh x21, 0(x30)
    
    # Distance[node] + adjacency[node][i] in x31
    add x31, x20, x24
    blt x31, x21, update_distance
    jal x0, loop
    
update_distance:
    sh x31, 0(x30)
    jal x0, loop
    
end_loop:
    jalr x0, x5, 0
    
find_min_node:
    addi x29, x29, 1
    beq x13, x29, end_find
    
    add x30, x29, x7
    lb x30, 0(x30)
    bne x30, x0, find_min_node 
    
    slli x30, x29, 1
    add x30, x30, x6
    lh x22, 0(x30)
    beq x22, x14, find_min_node
    
    beq x28, x19, update_first
    
    slli x31, x28, 1
    add x31, x31, x6
    lh x23, 0(x31)
    
    bge x22, x23, find_min_node
    addi x28, x29, 0
    jal x0, find_min_node
    
update_first:
    addi x28, x29, 0
    jal x0, find_min_node    
    
end_find:
    jalr x0, x5, 0

end_dijkstra:
    jalr x0, x1, 0

print:
    addi x28, x28, 2
    beq x28, x31, end 
    add x30, x28, x6
    lh x29, 0(x30)
    
    beq x29, x14, print_str
    
    addi a1, x29, 0
    addi a0, x0, 1
    ecall
    
    addi a1, x0, 32
    addi a0, x0, 11
    ecall
    
    jal x0, print
    
print_str:
    addi a1, x16, 0
    addi a0, x0, 4
    ecall
    
    addi a1, x0, 32
    addi a0, x0, 11
    ecall
    
    jal x0, print

end:
    addi a0, x0, 10
    ecall
