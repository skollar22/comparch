# Assumptions: Tally record is 6 bits long with tag size being 2 bits (meaning 3 blocks of 2 bits each).

# Structure:
# Reg 0 is the zero register.
# Reg 1-4 is allocated for the first 4 candidate tallies (for 7seg display).
# Reg 5 is the record input from switches.
# Reg 6-8 is the partition blocks.

# Load from switches
hlt
swl $5

# Block partition (tag size = 2)
lui $6, 0
ori $6, $0, 12                # imm = 0x0C
and $6, $5, $6, lsr 2         # <- block 0

lui $7, 0
ori $7, $0, 48                # imm = 0x30
and $7, $5, $7, lsr 4         # <- block 1

lui $8, 0
ori $8, $0, 192               # imm = 0xC0
and $8, $5, $8, lsr 6         # <- block 2

# Flip block 0
not $9, $6
lui $10, 0
ori $10, $0, 3                # imm = 0x3
and $6, $9, $10

# Swap (block 0, block 1, bit 1, bit 2, 1 bit long)
lui $10, 0
ori $10, $0, 1               # imm = 0x1, 0b01
and $10, $6, $10, lsl 1
lui $11, 0
ori $11, $0, 2               # imm = 0x2, 0b10
and $11, $7, $11, lsr 1

# Shift block 1 by 1 bit to the left
lui $10, 0
ori $10, $0, 2
and $10, $7, $10
or $11, $7, $0, lsl 1
or $10, $10, $0, lsr 1
lui $12, 0
ori $12, $0, 3
and $11, $11, $12
or $7, $11, $10

# XOR all blocks
xor $6, $6, $7
xor $6, $6, $8

# Extract sent tag from record
lui $9, 0
ori $9, $0, 3
and $7, $5, $9

# Show on LEDs
or $9, $7, $0, lsl 8
or $9, $9, $6
dispr $9

# Check if computed tag is equal to sent tag
beq $6, $7, 1
beq $0, $0, 13

# If computed tag = sent tag, then add tally to candidate ID's count
# First, extract tally and candidate ID from record
lui $9, 0
ori $9, $0, 4
and $8, $5, $9, lsr 2

lui $9, 0
ori $9, $0, 24
and $9, $5, $9, lsr 3

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
beq $0, $0, 170