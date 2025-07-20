----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/14/2025 08:00:29 PM
-- Design Name: 
-- Module Name: forwarding_unit - Behavioral
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

entity forwarding_unit is
    generic (
        DATA_SIZE : integer := 32;
        REG_SIZE : integer := 5
    );
    Port (
        -- control
        id_reg_1        : in std_logic_vector((REG_SIZE - 1) downto 0);
        id_reg_2        : in std_logic_vector((REG_SIZE - 1) downto 0);
        ex_write_reg    : in std_logic_vector((REG_SIZE - 1) downto 0);
        mem_write_reg   : in std_logic_vector((REG_SIZE - 1) downto 0);
        
        -- data
        id_reg_1_data   : in std_logic_vector((DATA_SIZE - 1) downto 0);
        id_reg_2_data   : in std_logic_vector((DATA_SIZE - 1) downto 0);
        ex_wr_data      : in std_logic_vector((DATA_SIZE - 1) downto 0);
        mem_wr_data     : in std_logic_vector((DATA_SIZE - 1) downto 0);
        
        -- outputs
        reg_1_out       : out std_logic_vector((DATA_SIZE - 1) downto 0);
        reg_2_out       : out std_logic_vector((DATA_SIZE - 1) downto 0)
    );
end forwarding_unit;

architecture Behavioral of forwarding_unit is

begin

process(id_reg_1, id_reg_2, ex_write_reg, 
        mem_write_reg, id_reg_1_data, id_reg_2_data, 
        ex_wr_data, mem_wr_data)

begin

    if id_reg_1 = "00000" then
        reg_1_out <= (others => '0');
    elsif id_reg_1 = ex_write_reg then
        reg_1_out <= ex_wr_data;
    elsif id_reg_1 = mem_write_reg then
        reg_1_out <= mem_wr_data;
    else
        reg_1_out <= id_reg_1_data;
    end if;
    
    if id_reg_2 = "00000" then
        reg_2_out <= (others => '0');
    elsif id_reg_2 = ex_write_reg then
        reg_2_out <= ex_wr_data;
    elsif id_reg_2 = mem_write_reg then
        reg_2_out <= mem_wr_data;
    else
        reg_2_out <= id_reg_2_data;
    end if;

end process;

end Behavioral;
