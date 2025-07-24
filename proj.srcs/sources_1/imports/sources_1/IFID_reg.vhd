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
    generic (
        PC_SIZE : integer := 8;
        DATA_SIZE : integer := 32;
        REG_SIZE : integer := 5
    );
    Port (
        instr       : in std_logic_vector((DATA_SIZE - 1) downto 0);
        next_pc     : in std_logic_vector((PC_SIZE - 1) downto 0);
        flush       : in std_logic;
        stall       : in std_logic;
        clk         : in std_logic;
        opcode      : out std_logic_vector(5 downto 0);
        rs          : out std_logic_vector((REG_SIZE - 1) downto 0);
        rt          : out std_logic_vector((REG_SIZE - 1) downto 0);
        rd          : out std_logic_vector((REG_SIZE - 1) downto 0);
        imm16b      : out std_logic_vector(15 downto 0);
        pc_out      : out std_logic_vector((PC_SIZE - 1) downto 0)
    );
end IFID_reg;

architecture Behavioral of IFID_reg is

begin

process(clk, instr, next_pc, flush, stall)
variable reg : std_logic_vector((DATA_SIZE - 1) downto 0);
variable pc_reg : std_logic_vector((PC_SIZE - 1) downto 0);
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
    
    opcode <= reg((DATA_SIZE - 1) downto (DATA_SIZE - 6));
    rs     <= reg((DATA_SIZE - 7) downto (DATA_SIZE - 6 - REG_SIZE));
    rt     <= reg((DATA_SIZE - 7 - REG_SIZE) downto (DATA_SIZE - 6 - (2 * REG_SIZE)));
    rd     <= reg((DATA_SIZE - 7 - (2 * REG_SIZE)) downto (DATA_SIZE - 6 - (3 * REG_SIZE)));
    imm16b <= reg(15 downto 0);
    pc_out <= pc_reg;
    
    -- TODO: shamnt et al outputs for r-type instructions

end process;


end Behavioral;
