# Assumptions:
# Tally record is 27 bits long (6 bit district ID, 6 bit candidate ID, 15 bit tally)
# Tag size is 5 bits (meaning 6 blocks of 5 bits each).

# Structure:
# Reg 0 is the zero register.
# Reg 1-4 is allocated for the first 4 candidate tallies (for 7seg display).
# Reg 5 is the record input from switches.
# Reg 6-11 is the partition blocks.

# Load from switches
hlt
swl $5

# Block partition (tag size = 4)
lui $6, 0
ori $6, $0, 96              # imm = 0x60
and $6, $5, $6, lsr 2       # <- block 0

lui $7, 0
ori $7, $0, 3968            # imm = 0xF80
and $7, $5, $7, lsr 7       # <- block 1

lui $8, 1                   # imm = 0x0001 << 16        = 0x00010000
ori $8, $0, 61440           # imm = 0x00010000 | 0xF000 = 0x0001F000
and $8, $5, $8, lsr 12      # <- block 2

lui $9, 62                  # imm = 0x003E << 16        = 0x003E0000
and $9, $5, $9, lsr 17      # <- block 3

lui $10, 1984               # imm = 0x07C0 << 16        = 0x07C00000
and $10, $5, $10, lsr 22    # <- block 4

lui $11, 63488              # imm = 0xF800 << 16        = 0xF8000000
and $11, $5, $11, lsr 27    # <- block 5

# Flip block 4
not $10, $10
lui $12, 0
ori $12, $0, 31             # imm = 0x1F
and $10, $10, $12           # Make sure the left bits in the 32 bit register are still 0

# Swap (block 1, block 3, bit 2, bit 0, 3 bits long)
lui $12, 0
ori $12, $0, 28             # imm = 0b11100
and $12, $7, $12, lsr 2     # pos = 0b00111

lui $13, 0
ori $13, $0, 7              # imm = 0b00111
and $13, $9, $13, lsl 2     # pos = 0b11100

lui $14, 0
ori $14, $0, 3              # imm = 0b00011
and $7, $7, $14             # Mask to zero out pos 0b11100
or $7, $7, $13              # Reinsert from pos    0b11100

lui $14, 0
ori $14, $0, 8              # imm = 0b11000
and $9, $9, $14             # Mask to zero out pos 0b00111
or $9, $9, $12              # Reinsert from pos    0b00111

# Shift block 0 by 4 bits to the left
lui $12, 0
ori $12, $0, 30             # imm = 0b11110
and $12, $6, $12, lsr 1     # Holds the 4 bits of block 0 that get rotated off

or $6, $6, $0, lsl 4
lui $13, 0
ori $13, $0, 16             # imm = 0b10000
and $6, $6, $13             # Remove all bits except those valid after rotation

or $6, $6, $12              # Reinsert all bits that were rotated off

# XOR all blocks
xor $6, $6, $7
xor $6, $6, $8
xor $6, $6, $9
xor $6, $6, $10
xor $6, $6, $11             # computed tag

# Extract sent tag from record
lui $7, 0
ori $7, $0, 31              # imm = 0x1F
and $7, $5, $7              # record tag

# Show on LEDs (sent tag at position 8, computed tag at position 0)
or $8, $7, $0, lsl 8
or $8, $8, $6
dispr $8

# Check if computed tag is equal to sent tag
beq $6, $7, 1
beq $0, $0, 13

# If computed tag = sent tag, then add tally to candidate ID's count
# First, extract tally and candidate ID from record
lui $8, 15                  # imm = 0x000F << 16        = 0x000F0000
ori $8, $0, 65504           # imm = 0x000F0000 | 0xFFE0 = 0x000FFFE0
and $8, $5, $8, lsr 5       # record tally

lui $9, 1008                # imm = 0x03F0 << 16        = 0x03F00000
and $9, $5, $9, lsr 20      # record candidate ID

# Add tally to candidate ID's count, then store in data memory
lw $10, $9(0)
add $10, $10, $8
sw $10, $9(0)

# For 7seg display, keep $1-$4 updated with candidate 1-4's counts (1-indexed)
lw $1, $0(0)
lw $2, $0(1)
lw $3, $0(2)
lw $4, $0(3)

# Halt and wait for next record
beq $0, $0, 170             # there will be some nops before the halt, not important
