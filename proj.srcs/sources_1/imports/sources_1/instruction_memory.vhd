---------------------------------------------------------------------------
-- instruction_memory.vhd - Implementation of A Single-Port, 16 x 16-bit
--                          Instruction Memory.
-- 
-- Notes: refer to headers in single_cycle_core.vhd for the supported ISA.
--
-- Copyright (C) 2006 by Lih Wen Koh (lwkoh@cse.unsw.edu.au)
-- All Rights Reserved. 
--
-- The single-cycle processor core is provided AS IS, with no warranty of 
-- any kind, express or implied. The user of the program accepts full 
-- responsibility for the application of the program and the use of any 
-- results. This work may be downloaded, compiled, executed, copied, and 
-- modified solely for nonprofit, educational, noncommercial research, and 
-- noncommercial scholarship purposes provided that this notice in its 
-- entirety accompanies all copies. Copies of the modified software can be 
-- delivered to persons who use it solely for nonprofit, educational, 
-- noncommercial research, and noncommercial scholarship purposes provided 
-- that this notice in its entirety accompanies all copies.
--
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity instruction_memory is
    generic (
        PC_SIZE : integer := 8;
        DATA_SIZE : integer := 32
    );
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           hlt      : in  std_logic;
           addr_in  : in  std_logic_vector((PC_SIZE - 1) downto 0);
           insn_out : out std_logic_vector((DATA_SIZE - 1) downto 0) );
end instruction_memory;

architecture behavioral of instruction_memory is

type mem_array is array(0 to 255) of std_logic_vector((DATA_SIZE - 1) downto 0);
signal sig_insn_mem : mem_array;

begin
    mem_process: process ( clk,
                           addr_in,
                           reset ) is
  
    variable var_insn_mem : mem_array;
    variable var_addr     : integer;
  
    begin
        if (reset = '1' and rising_edge (clk)) then
            -- initial values of the instruction memory :
            --  insn_0 : load  $1, $0, 0   - load data 0($0) into $1
            --  insn_1 : load  $2, $0, 1   - load data 1($0) into $2
            --  insn_2 : add   $3, $0, $1  - $3 <- $0 + $1
            --  insn_3 : add   $4, $1, $2  - $4 <- $1 + $2
            --  insn_4 : store $3, $0, 2   - store data $3 into 2($0)
            --  insn_5 : store $4, $0, 3   - store data $4 into 3($0)
            --  insn_6 - insn_15 : noop    - end of program

--            var_insn_mem(0)  := X"0000"; -- nop
--            var_insn_mem(1)  := X"e010"; -- load $1 0($0)
--            var_insn_mem(2)  := X"8002"; -- add $2 $0 $0
--            var_insn_mem(3)  := X"e031"; -- load $3 1($0)
--            var_insn_mem(4)  := X"e042"; -- load $4 2($0)
--            var_insn_mem(5)  := X"8212"; -- add $2 $2 $1
--            var_insn_mem(6)  := X"4023"; -- store $2 3($0)
--            var_insn_mem(7)  := X"6003"; -- disp 3($0)
            
--            var_insn_mem(8)  := X"8005"; -- add $5 $0 $0
--            var_insn_mem(9)  := X"8155"; -- add $5 $1 $5
--            var_insn_mem(10) := X"1541"; -- beq $5 $4 1
--            var_insn_mem(11) := X"100d"; -- beq $0 $0 -3
            
--            var_insn_mem(12) := X"1232"; -- beq $2 $3 2
--            var_insn_mem(13) := X"1007"; -- beq $0 $0 7
--            var_insn_mem(14) := X"0000"; -- nop
--            var_insn_mem(15) := X"100e"; -- beq $0 $0 -2 ; infinite loop
            var_insn_mem := (others => (others => '0'));


            var_insn_mem(0) := "11111100000000000000000000000000"; -- hlt
            var_insn_mem(1) := "11000000000000000010100000000000"; -- swl $5
            var_insn_mem(2) := "10111100000001100000000000000000"; -- lui $6, 0
            var_insn_mem(3) := "10011100000001100000000001100000"; -- ori $6, $0, 96              # imm = 0x60
            var_insn_mem(4) := "10010000101001100011000010000000"; -- and $6, $5, $6, lsr 2       # <- block 0
            var_insn_mem(5) := "10111100000001110000000000000000"; -- lui $7, 0
            var_insn_mem(6) := "10011100000001110000111110000000"; -- ori $7, $0, 3968            # imm = 0xF80
            var_insn_mem(7) := "10010000101001110011100111000000"; -- and $7, $5, $7, lsr 7       # <- block 1
            var_insn_mem(8) := "10111100000010000000000000000001"; -- lui $8, 1                   # imm = 0x0001 << 16        = 0x00010000
            var_insn_mem(9) := "10011100000010001111000000000000"; -- ori $8, $0, 61440           # imm = 0x00010000 | 0xF000 = 0x0001F000
            var_insn_mem(10) := "10010000101010000100001100000000"; -- and $8, $5, $8, lsr 12      # <- block 2
            var_insn_mem(11) := "10111100000010010000000000111110"; -- lui $9, 62                  # imm = 0x003E << 16        = 0x003E0000
            var_insn_mem(12) := "10010000101010010100110001000000"; -- and $9, $5, $9, lsr 17      # <- block 3
            var_insn_mem(13) := "10111100000010100000011111000000"; -- lui $10, 1984               # imm = 0x07C0 << 16        = 0x07C00000
            var_insn_mem(14) := "10010000101010100101010110000000"; -- and $10, $5, $10, lsr 22    # <- block 4
            var_insn_mem(15) := "10111100000010111111100000000000"; -- lui $11, 63488              # imm = 0xF800 << 16        = 0xF8000000
            var_insn_mem(16) := "10010000101010110101111011000000"; -- and $11, $5, $11, lsr 27    # <- block 5
            var_insn_mem(17) := "10001101010000000101000000000000"; -- not $10, $10
            var_insn_mem(18) := "10111100000011000000000000000000"; -- lui $12, 0
            var_insn_mem(19) := "10011100000011000000000000011111"; -- ori $12, $0, 31             # imm = 0x1F
            var_insn_mem(20) := "10010001010011000101000000000000"; -- and $10, $10, $12           # Make sure the left bits in the 32 bit register are still 0
            var_insn_mem(21) := "10111100000011000000000000000000"; -- lui $12, 0
            var_insn_mem(22) := "10011100000011000000000000011100"; -- ori $12, $0, 28             # imm = 0b11100
            var_insn_mem(23) := "10010000111011000110000010000000"; -- and $12, $7, $12, lsr 2     # pos = 0b00111
            var_insn_mem(24) := "10111100000011010000000000000000"; -- lui $13, 0
            var_insn_mem(25) := "10011100000011010000000000000111"; -- ori $13, $0, 7              # imm = 0b00111
            var_insn_mem(26) := "10010001001011010110100010000001"; -- and $13, $9, $13, lsl 2     # pos = 0b11100
            var_insn_mem(27) := "10111100000011100000000000000000"; -- lui $14, 0
            var_insn_mem(28) := "10011100000011100000000000000011"; -- ori $14, $0, 3              # imm = 0b00011
            var_insn_mem(29) := "10010000111011100011100000000000"; -- and $7, $7, $14             # Mask to zero out pos 0b11100
            var_insn_mem(30) := "10010100111011010011100000000000"; -- or $7, $7, $13              # Reinsert from pos    0b11100
            var_insn_mem(31) := "10111100000011100000000000000000"; -- lui $14, 0
            var_insn_mem(32) := "10011100000011100000000000001000"; -- ori $14, $0, 8              # imm = 0b11000
            var_insn_mem(33) := "10010001001011100100100000000000"; -- and $9, $9, $14             # Mask to zero out pos 0b00111
            var_insn_mem(34) := "10010101001011000100100000000000"; -- or $9, $9, $12              # Reinsert from pos    0b00111
            var_insn_mem(35) := "10111100000011000000000000000000"; -- lui $12, 0
            var_insn_mem(36) := "10011100000011000000000000011110"; -- ori $12, $0, 30             # imm = 0b11110
            var_insn_mem(37) := "10010000110011000110000001000000"; -- and $12, $6, $12, lsr 1     # Holds the 4 bits of block 0 that get rotated off
            var_insn_mem(38) := "10010100110000000011000100000001"; -- or $6, $6, $0, lsl 4
            var_insn_mem(39) := "10111100000011010000000000000000"; -- lui $13, 0
            var_insn_mem(40) := "10011100000011010000000000010000"; -- ori $13, $0, 16             # imm = 0b10000
            var_insn_mem(41) := "10010000110011010011000000000000"; -- and $6, $6, $13             # Remove all bits except those valid after rotation
            var_insn_mem(42) := "10010100110011000011000000000000"; -- or $6, $6, $12              # Reinsert all bits that were rotated off
            var_insn_mem(43) := "10011000110001110011000000000000"; -- xor $6, $6, $7
            var_insn_mem(44) := "10011000110010000011000000000000"; -- xor $6, $6, $8
            var_insn_mem(45) := "10011000110010010011000000000000"; -- xor $6, $6, $9
            var_insn_mem(46) := "10011000110010100011000000000000"; -- xor $6, $6, $10
            var_insn_mem(47) := "10011000110010110011000000000000"; -- xor $6, $6, $11             # computed tag
            var_insn_mem(48) := "10111100000001110000000000000000"; -- lui $7, 0
            var_insn_mem(49) := "10011100000001110000000000011111"; -- ori $7, $0, 31              # imm = 0x1F
            var_insn_mem(50) := "10010000101001110011100000000000"; -- and $7, $5, $7              # record tag
            var_insn_mem(51) := "10010100111000000100001000000001"; -- or $8, $7, $0, lsl 8
            var_insn_mem(52) := "10010101000001100100000000000000"; -- or $8, $8, $6
            var_insn_mem(53) := "01110001000000000000000000000000"; -- dispr $8
            var_insn_mem(54) := "00010000111001100000000000000001"; -- beq $6, $7, 1
            var_insn_mem(55) := "00010000000000000000000000001100"; -- beq $0, $0, 12
            var_insn_mem(56) := "10111100000010000000000000001111"; -- lui $8, 15                  # imm = 0x000F << 16        = 0x000F0000
            var_insn_mem(57) := "10011100000010001111111111100000"; -- ori $8, $0, 65504           # imm = 0x000F0000 | 0xFFE0 = 0x000FFFE0
            var_insn_mem(58) := "10010000101010000100000101000000"; -- and $8, $5, $8, lsr 5       # record tally
            var_insn_mem(59) := "10111100000010010000001111110000"; -- lui $9, 1008                # imm = 0x03F0 << 16        = 0x03F00000
            var_insn_mem(60) := "10010000101010010100110100000000"; -- and $9, $5, $9, lsr 20      # record candidate ID
            var_insn_mem(61) := "11100001001010100000000000000000"; -- lw $10, $9(0)
            var_insn_mem(62) := "10000001010010000101000000000000"; -- add $10, $10, $8
            var_insn_mem(63) := "01000001001010100000000000000000"; -- sw $10, $9(0)
            var_insn_mem(64) := "11100000000000010000000000000000"; -- lw $1, $0(0)
            var_insn_mem(65) := "11100000000000100000000000000001"; -- lw $2, $0(1)
            var_insn_mem(66) := "11100000000000110000000000000010"; -- lw $3, $0(2)
            var_insn_mem(67) := "11100000000001000000000000000011"; -- lw $4, $0(3)
            var_insn_mem(68) := "00010000000000000000000010101010"; -- beq $0, $0, 170             # there will be some nops before the halt, not important
              
--            var_insn_mem(0) := X"FC000000"; -- halt
--            var_insn_mem(1) := X"60000000"; -- display 1 on led
            
--            var_insn_mem(0) := X"c010"; -- load from switch into $1
--            var_insn_mem(1) := X"4010"; -- store $1 0($0)
--            var_insn_mem(2) := X"e032"; -- load $3 2($0) -> $3 = 2
--            var_insn_mem(3) := X"e021"; -- load $2 1($0) -> $2 = 1
--            var_insn_mem(4) := X"1122"; -- beq $1 $2 2
--            var_insn_mem(5) := X"1133"; -- beq $1 $3 3
--            var_insn_mem(6) := X"1007"; -- beq $0 $0 7
--            var_insn_mem(7) := X"6003"; -- disp 3($0) -> leds = prev switch
--            var_insn_mem(8) := X"1004"; -- beq $0 $0 4
--            var_insn_mem(9) := X"8115"; -- add $5 $1 $1
--            var_insn_mem(10) := X"8515"; -- add $5 $5 $1
--            var_insn_mem(11) := X"4054"; -- store $5 4($0)
--            var_insn_mem(12) := X"6004"; -- disp 4($0)
--            var_insn_mem(13) := X"1002"; -- beq $0 $0 2
--            var_insn_mem(14) := X"4013"; -- store $1 3($0)
--            var_insn_mem(15) := X"0000"; -- nop

        
        end if;
        
        var_addr := conv_integer(addr_in);
        
        if (hlt = '1') then
            insn_out <= (others => '0');
        else
            insn_out <= var_insn_mem(var_addr);
        end if;
                    

        -- the following are probe signals (for simulation purpose)
        sig_insn_mem <= var_insn_mem;

    end process;
  
end behavioral;
