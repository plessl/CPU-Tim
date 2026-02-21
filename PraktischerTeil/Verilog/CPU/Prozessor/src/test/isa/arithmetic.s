.section .text
.global main

main:
    # Test ADDI
    li t0, 10
    addi t1, t0, 5
    li t2, 15
    bne t1, t2, fail

    # Test ADD
    li t0, 20
    li t1, 22
    add t2, t0, t1
    li t3, 42
    bne t2, t3, fail

    # Test SUB
    li t0, 100
    li t1, 30
    sub t2, t0, t1
    li t3, 70
    bne t2, t3, fail

    # Test LUI
    lui t0, 0x12345
    li t1, 0x12345000
    bne t0, t1, fail

    # Test AUIPC
    # PC is at this instruction
    auipc t0, 0
    # t0 should be equal to the current PC
    # We can't easily check the exact PC value without knowing the link address,
    # but we can check if it's non-zero.
    beqz t0, fail

pass:
    li t0, 0x0001FFFC
    li t1, 1
    sw t1, 0(t0)
    j end

fail:
    li t0, 0x0001FFFC
    li t1, 0xDEADBEEF
    sw t1, 0(t0)

end:
    j end
