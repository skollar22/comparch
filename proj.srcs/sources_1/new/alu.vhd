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

entity alu is
    generic (
        DATA_SIZE : integer := 32
    );
    Port (
        src_a      : in  std_logic_vector((DATA_SIZE - 1) downto 0);
        src_b      : in  std_logic_vector((DATA_SIZE - 1) downto 0);
        alu_op     : in  std_logic_vector(3 downto 0);
        result     : out std_logic_vector((DATA_SIZE - 1) downto 0);
        zero       : out std_logic;
        carry_out  : out std_logic
    );
end alu;

architecture Behavioral of alu is
    signal a, b : unsigned((DATA_SIZE - 1) downto 0);
    signal res  : unsigned((DATA_SIZE - 1) downto 0);
    signal c    : std_logic;
begin
    a <= unsigned(src_a);
    b <= unsigned(src_b);

    process(a, b, alu_op)
    begin
        case alu_op is
            when "0000" => -- ADD
                res <= a + b;
                c <= '0';
            when "0001" => -- SUB
                res <= a - b;
                c <= '0';
            when "0010" => -- AND
                res <= a and b;
                c <= '0';
            when "0011" => -- OR
                res <= a or b;
                c <= '0';
            when "0100" => -- XOR
                res <= a xor b;
                c <= '0';
            when "0101" => -- SLT
                if (a < b) then
                    res <= (others => '0');
                    res(0) <= '1';
                else
                    res <= (others => '0');
                end if;
                c <= '0';
            when others =>
                res <= (others => '0');
                c <= '0';
        end case;
    end process;

    result    <= std_logic_vector(res);
    zero      <= '1' when res = 0 else '0';
    carry_out <= c;
end Behavioral;