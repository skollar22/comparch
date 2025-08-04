---------------------------------------------------------------------------
-- register_file.vhd - Implementation of A Dual-Port, 16 x 16-bit
--                     Collection of Registers.
-- 
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

entity register_file is
    generic (
        DATA_SIZE : integer := 32;
        REG_SIZE : integer := 5
    );
    port ( reset           : in  std_logic;
           clk             : in  std_logic;
           read_register_a : in  std_logic_vector((REG_SIZE - 1) downto 0);
           read_register_b : in  std_logic_vector((REG_SIZE - 1) downto 0);
           write_enable    : in  std_logic;
           write_register  : in  std_logic_vector((REG_SIZE - 1) downto 0);
           write_data      : in  std_logic_vector((DATA_SIZE - 1) downto 0);
           buttons         : in  std_logic_vector(3 downto 0);
           read_data_a     : out std_logic_vector((DATA_SIZE - 1) downto 0);
           read_data_b     : out std_logic_vector((DATA_SIZE - 1) downto 0);
           reg_out         : out std_logic_vector((DATA_SIZE - 1) downto 0) );
end register_file;

architecture behavioral of register_file is

type reg_file is array(0 to ((2 ** REG_SIZE) - 1)) of std_logic_vector((DATA_SIZE - 1) downto 0);
signal sig_regfile : reg_file;

begin

    mem_process : process ( reset,
                            clk,
                            read_register_a,
                            read_register_b,
                            write_enable,
                            write_register,
                            write_data ) is

    variable var_regfile     : reg_file;
    variable var_read_addr_a : integer;
    variable var_read_addr_b : integer;
    variable var_write_addr  : integer;
    
    begin
    
        var_read_addr_a := conv_integer(read_register_a);
        var_read_addr_b := conv_integer(read_register_b);
        var_write_addr  := conv_integer(write_register);
        
        if (reset = '1') then
            -- initial values of the registers - reset to zeroes
            var_regfile := (others => (others => '0'));
        elsif (rising_edge (clk) and write_enable = '1') then
            -- register write on the falling clock edge
            var_regfile(var_write_addr) := write_data;
        end if;

        -- enforces value zero for register $0
        var_regfile(0) := X"00000000";

        -- continuous read of the registers at location read_register_a
        -- and read_register_b
        read_data_a <= var_regfile(var_read_addr_a); 
        read_data_b <= var_regfile(var_read_addr_b);

        -- the following are probe signals (for simulation purpose)
        sig_regfile <= var_regfile;

    end process;
    
    process(clk, reset)
    begin
        -- 4 lines for testing
        --sig_regfile(0) <= "00000000000000000000000000001111";
        --sig_regfile(1) <= "00000000000000000000000000011111";
        --sig_regfile(2) <= "00000000000000000000000000111111";
        --sig_regfile(3) <= "11111111111111111111111111111111";
        if rising_edge(clk) then
            case buttons is
                when "0010" => reg_out <= sig_regfile(1);
                when "0100" => reg_out <= sig_regfile(2);
                when "0001" => reg_out <= sig_regfile(3);
                when "1000" => reg_out <= sig_regfile(4);
                when others => null;
            end case;
        end if;
    end process;
end behavioral;
