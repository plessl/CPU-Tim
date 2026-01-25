begin: addi x1, x1, 1
    andi x2, x1, 1
    beq x2, x0, skip
    xor x0, x0, x0
skip: j begin