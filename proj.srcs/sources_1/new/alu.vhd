----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/23/2025 11:06:38 AM
-- Design Name: 
-- Module Name: alu - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mips_alu is
    generic (
        DATA_SIZE : integer := 32
    );
    Port (
        src_a      : in  std_logic_vector((DATA_SIZE - 1) downto 0);
        src_b      : in  std_logic_vector((DATA_SIZE - 1) downto 0);
        alu_op     : in  std_logic_vector(3 downto 0);
        shift      : in  std_logic;
        shfunct    : in  std_logic;
        shamnt     : in  std_logic_vector(4 downto 0);
        result     : out std_logic_vector((DATA_SIZE - 1) downto 0);
        zero       : out std_logic;
        carry_out  : out std_logic
    );
end mips_alu;

architecture Behavioral of mips_alu is
    signal a, b : unsigned(DATA_SIZE downto 0);
    signal res  : unsigned((DATA_SIZE - 1) downto 0);
    signal c    : std_logic;
begin
    a <= '0' & unsigned(src_a);
    b <= '0' & unsigned(src_b);

    process(a, b, alu_op, shift, shfunct, shamnt)
    variable var_res : unsigned(DATA_SIZE downto 0);
    begin
        case alu_op is
            when "0000" => -- ADD
                var_res := a + b;
                c <= var_res(DATA_SIZE);
            when "0001" => -- SUB
                var_res := a - b;
                c <= '0';
            when "0010" => -- AND
                var_res := a and b;
                c <= '0';
            when "0011" => -- OR
                var_res := a or b;
                c <= '0';
            when "0100" => -- XOR
                var_res := a xor b;
                c <= '0';
            when "0101" => -- SLT
                if (a < b) then
                    var_res := (others => '0');
                    var_res(0) := '1';
                else
                    var_res := (others => '0');
                end if;
                c <= '0';
            when "0110" => -- ORI
                var_res := a or b;
                c <= '0';
            when "0111" => -- LUI
                var_res := b(DATA_SIZE) & b((DATA_SIZE / 2) - 1 downto 0) & X"0000";
                c <= '0';
            when "1000" => -- NOT
                var_res := not a;
                c <= '0';
            when others =>
                var_res := (others => '0');
                c <= '0';
        end case;
        
        if shift = '1' then
            if shfunct = '1' then           -- lsl
                res <= shift_left(var_res((DATA_SIZE - 1) downto 0), to_integer(unsigned(shamnt)));
            else                            -- lsr
                res <= shift_right(var_res((DATA_SIZE - 1) downto 0), to_integer(unsigned(shamnt)));
            end if;
        else                                -- no shift
            res <= var_res((DATA_SIZE - 1) downto 0);
        end if;
        
    end process;

    result    <= std_logic_vector(res);
    zero      <= '1' when res = 0 else '0';
    carry_out <= c;
end Behavioral;