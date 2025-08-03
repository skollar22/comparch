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
        alu_op      : out std_logic_vector(3 downto 0);  -- ALU operation select
        shift       : out std_logic
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
                shift <= '1';
            when "100010" => -- SUB
                alu_op <= "0001";
                shift <= '1';
            when "100100" => -- AND
                alu_op <= "0010";
                shift <= '1';
            when "100101" => -- OR
                alu_op <= "0011";
                shift <= '1';
            when "100110" => -- XOR
                alu_op <= "0100";
                shift <= '1';
            when "101010" => -- SLT
                alu_op <= "0101";
                shift <= '0';
            when "000100" => -- BEQ
                alu_op <= "0001"; -- SUB
                shift <= '0';
            when others =>
                alu_op <= "0000"; -- ADD by default
                shift <= '0';
        end case;
    end process;
end Behavioral;