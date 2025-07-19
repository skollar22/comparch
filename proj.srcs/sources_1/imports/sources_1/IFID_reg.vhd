----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/12/2025 03:12:20 PM
-- Design Name: 
-- Module Name: IFID_reg - Behavioral
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

entity IFID_reg is
  Port (
    instr       : in std_logic_vector(15 downto 0);
    next_pc     : in std_logic_vector(3 downto 0);
    flush       : in std_logic;
    stall       : in std_logic;
    clk         : in std_logic;
    opcode      : out std_logic_vector(3 downto 0);
    rs          : out std_logic_vector(3 downto 0);
    rt          : out std_logic_vector(3 downto 0);
    rd          : out std_logic_vector(3 downto 0);
    imm4b       : out std_logic_vector(3 downto 0);
    imm8b       : out std_logic_vector(7 downto 0);
    pc_out      : out std_logic_vector(3 downto 0)
   );
end IFID_reg;

architecture Behavioral of IFID_reg is

begin

process(clk, instr, next_pc, flush, stall)
variable reg : std_logic_vector(15 downto 0);
variable pc_reg : std_logic_vector(3 downto 0);
begin
    if rising_edge (clk) then
        if flush = '1' then
            reg     := (others => '0');
            pc_reg  := (others => '0');
        elsif stall = '1' then
            reg := reg;
            pc_reg := pc_reg;
        else
            reg     := instr;
            pc_reg  := next_pc;
        end if;
    end if;
    
    opcode <= reg(15 downto 12);
    rs     <= reg(11 downto 8);
    rt     <= reg(7 downto 4);
    rd     <= reg(3 downto 0);
    imm4b  <= reg(3 downto 0);
    imm8b  <= reg(7 downto 0);
    pc_out <= pc_reg;

end process;


end Behavioral;
