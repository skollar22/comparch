# Assumptions: Tally record is 12 bits long with tag size being 4 bits (meaning 3 blocks of 4 bits each).

# Structure:
# Reg 0 is the zero register.
# Reg 1-4 is allocated for the first 4 candidate tallies (for 7seg display).
# Reg 5 is the record input from switches.
# Reg 6-8 is the partition blocks.

# Load from switches
hlt
swl $5

# Block partition (tag size = 4)
lui $6, 0
ori $6, $0, 240             # imm = 0xF0
and $6, $5, $6, lsr 4       # <- block 0

lui $7, 0
ori $7, $0, 3840            # imm = 0xF00
and $7, $5, $7, lsr 8       # <- block 1

lui $8, 0
ori $8, $0, 61400           # imm = 0xF000
and $8, $5, $8, lsr 12      # <- block 2

# Flip block 1
not $9, $7
lui $10, 0
ori $10, $0, 15             # imm = 0xF
and $7, $9, $10             # Make sure the left bits in the 32 bit register are still 0

# Swap (block 0, block 1, bit 1, bit 2, 2 bits long)
lui $9, 0
ori $9, $0, 6               # imm = 0b0110
and $9, $6, $9, lsl 1
lui $10, 0
ori $10, $0, 12             # imm = 0b1100
and $10, $7, $10, lsr 1

lui $11, 0
ori $11, $0, 9              # imm = 0b1001
and $7, $7, $11
or $7, $7, $10

lui $11, 0
ori $11, $0, 3              # imm = 0b0011
and $6, $6, $11
or $6, $6, $9

# Shift block 2 by 2 bits to the left
lui $10, 0
ori $10, $0, 12             # imm = 0b1100
and $9, $8, $10, lsr 2
or $8, $8, $0, lsl 2
or $8, $9, $8

# XOR all blocks
xor $6, $6, $7
xor $6, $6, $8

# Extract sent tag from record
lui $9, 0
ori $9, $0, 15              # imm = 0xF
and $7, $5, $9              # record tag

# Show on LEDs (sent tag at position 8, computed tag at position 0)
or $9, $7, $0, lsl 8
or $9, $9, $6
dispr $9

# Check if computed tag is equal to sent tag
beq $6, $7, 1
beq $0, $0, 11

# If computed tag = sent tag, then add tally to candidate ID's count
# First, extract tally and candidate ID from record
lui $9, 0
ori $9, $0, 4080            # imm = 0xFF0
and $8, $5, $9, lsr 4       # record tally

lui $9, 0
ori $9, $0, 12288           # imm = 0x3000
and $9, $5, $9, lsr 12      # record candidate ID

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
beq $0, $0, 198
