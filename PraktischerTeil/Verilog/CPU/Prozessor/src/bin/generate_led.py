import random

NUM_LINES = 4096
BITS_PER_LINE = 4
BLOCK_SIZE = 64

lines = []
for block_start in range(0, NUM_LINES, BLOCK_SIZE):
    bitvector = ''.join(random.choice('01') for _ in range(BITS_PER_LINE))
    for _ in range(BLOCK_SIZE):
        lines.append(bitvector)

output = '\n'.join(lines)
print(output)