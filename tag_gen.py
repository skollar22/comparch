def flip(block: list[str]) -> None:
    for i in range(len(block)):
        block[i] = '1' if block[i] == '0' else '0'

def rotate_left(block: list[str], r: int) -> None:
    r %= len(block)
    if r == 0:
        return
    temp = block[:]
    for i in range(len(block)):
        block[i] = temp[(i + r) % len(block)]

def get_segment(block: list[str], start: int, s: int) -> list[str]:
    return [block[(start + i) % len(block)] for i in range(s)]

def set_segment(block: list[str], start: int, segment: list[str]) -> None:
    for i in range(len(segment)):
        block[(start + i) % len(block)] = segment[i]

def xor_blocks(blocks: list[list[str]]) -> str:
    result = blocks[0][:]
    for b in blocks[1:]:
        for i in range(len(result)):
            result[i] = str(int(result[i]) ^ int(b[i]))
    return ''.join(result)

def print_blocks(blocks: list[list[str]], label: str = ""):
    if label:
        print(f"{label}")
    for i, b in enumerate(blocks):
        bin_str = ''.join(b)
        hex_str = hex(int(bin_str, 2))
        print(f"    Block {i}: {bin_str} ({hex_str})")
    print()

def encrypt(message_bits: str,
            tag_size: int,
            flip_block: int,
            bx: int, by: int, px: int, py: int, s: int,
            shift_block: int, r: int) -> str:
   
    message_hex = hex(int(message_bits, 2))
    print(f"[+] Raw input bits: {message_bits} ({message_hex})")
    # Pad message to a multiple of tag_size
    remainder = len(message_bits) % tag_size
    if remainder != 0:
        padding = tag_size - remainder
        message_bits += '0' * padding
        print(f"[+] Padded to {len(message_bits)} bits: {message_bits}")
    else:
        print(f"[+] No padding needed ({len(message_bits)} bits)")
    
    # Split into blocks from RIGHT to LEFT
    # The rightmost tag_size bits become block 0
    blocks = []
    for i in range(len(message_bits), 0, -tag_size):
        start = max(0, i - tag_size)
        block = list(message_bits[start:i])
        blocks.append(block)
    
    print_blocks(blocks, "[+] Initial blocks:")
    
    # Flip one block
    print(f"[+] Flipping block {flip_block}")
    flip(blocks[flip_block])
    print_blocks(blocks, "    After flip:")
    
    # Swap segments (using right-to-left indexing within blocks)
    print(f"[+] Swapping segments of size {s}:")
    # Convert right-to-left positions to left-to-right for the existing functions
    block_size = len(blocks[bx])
    px_left = block_size - px - s  # Convert right-indexed position to left-indexed
    py_left = block_size - py - s  # Convert right-indexed position to left-indexed
    
    seg_x = get_segment(blocks[bx], px_left, s)
    seg_y = get_segment(blocks[by], py_left, s)
    seg_x_str = ''.join(seg_x)
    seg_y_str = ''.join(seg_y)
    seg_x_hex = hex(int(seg_x_str, 2))
    seg_y_hex = hex(int(seg_y_str, 2))
    print(f"    From Block {bx} at right-pos {px}): {seg_x_str} ({seg_x_hex})")
    print(f"    From Block {by} at right-pos {py}): {seg_y_str} ({seg_y_hex})")

    set_segment(blocks[bx], px_left, seg_y)
    set_segment(blocks[by], py_left, seg_x)
    print_blocks(blocks, "    After segment swap:")
    
    # Rotate one block
    print(f"[+] Rotating block {shift_block} left by {r} positions")
    rotate_left(blocks[shift_block], r)
    print_blocks(blocks, "    After rotation:")
    
    # XOR to produce result tag
    result_tag = xor_blocks(blocks)
    result_tag_hex = hex(int(result_tag, 2))
    print(f"[+] Final XOR result: {result_tag} ({result_tag_hex})")
    return result_tag

def record_to_bits(record: str) -> str:
    """Convert record like '1 3 40' into a 12-bit binary string."""
    district_id, candidate_id, tally = map(int, record.strip().split())
    if not (0 <= district_id < 4 and 0 <= candidate_id < 4 and 0 <= tally < 256):
        raise ValueError("Record values out of allowed bit range.")
    tally_bits = f"{tally:b}"
    if len(tally_bits) > 8:
        raise ValueError("Tally too large for 8-bit right-padding")
    tally_bits = tally_bits.rjust(8, '0')  # Right-pad with zeros
    return f"{district_id:02b}{candidate_id:02b}{tally_bits}"

# Test case
if __name__ == "__main__":
    print("Running tag-size-based split test case...")

    record = "1 2 12"
    message = record_to_bits(record)

    tag = encrypt(message, tag_size=4, flip_block=1,
                  bx=0, by=1, px=1, py=2, s=2,
                  shift_block=2, r=2)
