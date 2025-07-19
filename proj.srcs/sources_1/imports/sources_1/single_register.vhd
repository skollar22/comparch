----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/23/2025 09:25:50 PM
-- Design Name: 
-- Module Name: single_register - Behavioral
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

entity single_register is
    Port ( data_in          : in STD_LOGIC_VECTOR (15 downto 0);
           clk              : in STD_LOGIC;
           write_enable     : in STD_LOGIC;
           reset            : in STD_LOGIC;
           data_out         : out STD_LOGIC_VECTOR (15 downto 0));
end single_register;

architecture Behavioral of single_register is
signal sig_reg : std_logic_vector(15 downto 0);
begin

process (clk,
         reset,
         data_in,
         write_enable )
variable reg : std_logic_vector (15 downto 0) := (others => '0');
begin
    if reset = '1' then
        -- reset sets to zero
        reg := (others => '0');
    elsif rising_edge (clk) and write_enable = '1' then
        -- only write on falling edge (because register file does that)
        -- also only write when write_enable control signal is true
        reg := data_in;
    end if;
    
    -- continuous output
    data_out <= reg;
    
    -- probe signal
    sig_reg <= reg;
end process;


end Behavioral;
