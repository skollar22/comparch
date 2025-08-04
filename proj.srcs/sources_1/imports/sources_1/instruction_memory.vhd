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


            var_insn_mem(0) := "11000000000000000010100000000000"; -- swl $5
            var_insn_mem(1) := "10011100110001100000000011110000"; -- ori $6, $0, 240             # imm = 0xF0
            var_insn_mem(2) := "10010000101001100011000100000000"; -- and $6, $5, $6, lsr 4       # <- block 0
            var_insn_mem(3) := "10011100111001110000111100000000"; -- ori $7, $0, 3840            # imm = 0xF00
            var_insn_mem(4) := "10010000101001110011101000000000"; -- and $7, $5, $7, lsr 8       # <- block 1
            var_insn_mem(5) := "10011101000010001110111111011000"; -- ori $8, $0, 61400           # imm = 0xF000
            var_insn_mem(6) := "10010000101010000100001100000000"; -- and $8, $5, $8, lsr 12      # <- block 2
            var_insn_mem(7) := "10001100111000000100100000000000"; -- not $9, $7
            var_insn_mem(8) := "10010001001001010011100000000000"; -- and $7, $9, 15 # Make sure the left bits in the 32 bit register are still 0
            var_insn_mem(9) := "10011101001010010000000000000110"; -- ori $9, $0, 6               # imm = 0b0110
            var_insn_mem(10) := "10010000110010010100100001000001"; -- and $9, $6, $9, lsl 1
            var_insn_mem(11) := "10011101010010100000000000001100"; -- ori $10, $0, 12             # imm = 0b1100
            var_insn_mem(12) := "10010000111010100101000001000000"; -- and $10, $7, $10, lsr 1
            var_insn_mem(13) := "10011101011010110000000000001001"; -- ori $11, $0, 9              # imm = 0b1001
            var_insn_mem(14) := "10010000111010110011100000000000"; -- and $7, $7, $11
            var_insn_mem(15) := "10010100111010100011100000000000"; -- or $7, $7, $10
            var_insn_mem(16) := "10011101011010110000000000000011"; -- ori $11, $0, 3              # imm = 0b0011
            var_insn_mem(17) := "10010000110010110011000000000000"; -- and $6, $6, $11
            var_insn_mem(18) := "10010100110010010011000000000000"; -- or $6, $6, $9
            var_insn_mem(19) := "10011101010010100000000000001100"; -- ori $10, $0, 12             # imm = 0b1100
            var_insn_mem(20) := "10010001000010100100100010000000"; -- and $9, $8, $10, lsr 2
            var_insn_mem(21) := "10010101000000000100000010000001"; -- or $8, $8, $0, lsl 2
            var_insn_mem(22) := "10010101001010000100000000000000"; -- or $8, $9, $8
            var_insn_mem(23) := "10011000110001110011000000000000"; -- xor $6, $6, $7
            var_insn_mem(24) := "10011000110010000011000000000000"; -- xor $6, $6, $8
            var_insn_mem(25) := "10011101001010010000000000001111"; -- ori $9, $0, 15              # imm = 0xF
            var_insn_mem(26) := "10010000101010010011100000000000"; -- and $7, $5, $9              # record tag
            var_insn_mem(27) := "10010100111000000100101000000001"; -- or $9, $7, $0, lsl 8
            var_insn_mem(28) := "10010101001001100100100000000000"; -- or $9, $9, $6
            var_insn_mem(29) := "01110001001000000000000000000000"; -- dispr $9
            var_insn_mem(30) := "00010000110001100000000000000001"; -- beq $6, $7, 1
            var_insn_mem(31) := "00010000000000000000000000001011"; -- beq $0, $0, 11
            var_insn_mem(32) := "10011101001010010000111111110000"; -- ori $9, $5, 4080            # imm = 0xFF0
            var_insn_mem(33) := "10010000101010010100000100000000"; -- and $8, $5, $9, lsr 4       # record tally
            var_insn_mem(34) := "10011101001010010011000000000000"; -- ori $9, $5, 12288           # imm = 0x3000
            var_insn_mem(35) := "10010000101010010100101100000000"; -- and $9, $5, $9, lsr 12      # record candidate ID
            var_insn_mem(36) := "11100001001010100000000000000000"; -- lw $10, $9(0)
            var_insn_mem(37) := "10000001010010000101000000000000"; -- add $10, $10, $8
            var_insn_mem(38) := "01000001001010100000000000000000"; -- sw $10, $9(0)
            var_insn_mem(39) := "11100000000000010000000000000000"; -- lw $1, $0(0)
            var_insn_mem(40) := "11100000000000100000000000000001"; -- lw $2, $0(1)
            var_insn_mem(41) := "11100000000000110000000000000010"; -- lw $3, $0(2)
            var_insn_mem(42) := "11100000000001000000000000000011"; -- lw $4, $0(3)
            var_insn_mem(43) := "11111100000000000000000000000000"; -- hlt
            var_insn_mem(44) := "00010000000000000000000011010011"; -- beq $0, $0, 211
              
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
