----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.07.2025 02:25:50
-- Design Name: 
-- Module Name: halting_unit - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity halting_unit is
    generic (
        DATA_SIZE : integer := 32
    );
    Port ( reset : in STD_LOGIC;
           clk : in STD_LOGIC;
           instr : in STD_LOGIC_VECTOR ((DATA_SIZE - 1) downto 0);
           flush : in STD_LOGIC;
           stall : in STD_LOGIC;
           ext_resume : in STD_LOGIC;
           hlt : out STD_LOGIC);
end halting_unit;

architecture Behavioral of halting_unit is

constant OP_HLT     : std_logic_vector(5 downto 0) := "111111";
signal   opcode     : std_logic_vector(5 downto 0);

begin

    opcode <= instr((DATA_SIZE - 1) downto (DATA_SIZE - 6));
    process(reset, clk, opcode, flush, stall, ext_resume)
    begin
        
        if (reset = '1') then
            hlt <= '0';
        elsif (rising_edge(clk)) then
            if (ext_resume = '1') then
                hlt <= '0';
            elsif (opcode = OP_HLT) and (flush = '0') and (stall = '0') then
                hlt <= '1';
            end if;
        end if;
        
    end process;

end Behavioral;
