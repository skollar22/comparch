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
              var_insn_mem(0) := X"60000000";
              var_insn_mem(1) := X"E0010000";
              var_insn_mem(2) := X"80211000";
              var_insn_mem(2) := X"40420000";
              
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
