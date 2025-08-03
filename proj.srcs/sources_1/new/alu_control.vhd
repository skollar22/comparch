----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/23/2025 10:55:26 AM
-- Design Name: 
-- Module Name: alu_control - Behavioral
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

entity alu_control is
    Port (
        opcode      : in  std_logic_vector(5 downto 0);
        funct       : in  std_logic_vector(3 downto 0); -- for R-type
        alu_op      : out std_logic_vector(3 downto 0)  -- ALU operation select
    );
end alu_control;

architecture Behavioral of alu_control is
begin
    process(opcode, funct)
    begin
        -- Default: ADD
        alu_op <= "0000";
        case opcode is
            when "100000" => -- ADD
                alu_op <= "0000";
            when "100010" => -- SUB
                alu_op <= "0001";
            when "100100" => -- AND
                alu_op <= "0010";
            when "100101" => -- OR
                alu_op <= "0011";
            when "100110" => -- XOR
                alu_op <= "0100";
            when "101010" => -- SLT
                alu_op <= "0101";
            when "000100" => -- BEQ
                alu_op <= "0001"; -- SUB
            when "100111" => -- ANDI
                alu_op <= "0110";
            when "101111" => -- LUI
                alu_op <= "0111";
            when "100011" => -- NOT
                alu_op <= "1000";
            when others =>
                alu_op <= "0000"; -- ADD by default
        end case;
    end process;
end Behavioral;