----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/12/2025 03:12:20 PM
-- Design Name: 
-- Module Name: MEMWB_reg - Behavioral
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

entity MEMWB_reg is
  Port (
    alu_result          : in std_logic_vector(15 downto 0);
    mem_result          : in std_logic_vector(15 downto 0);
    write_reg           : in std_logic_vector(3 downto 0);
    wb_ctrl             : in std_logic_vector(3 downto 0);
    clk                 : in std_logic;
    alu_result_out      : out std_logic_vector(15 downto 0);
    mem_result_out      : out std_logic_vector(15 downto 0);
    write_reg_out       : out std_logic_vector(3 downto 0);
    reg_write           : out std_logic;
    mem_to_reg          : out std_logic;
    switch_in           : out std_logic;
    led_write           : out std_logic
  );
end MEMWB_reg;

architecture Behavioral of MEMWB_reg is

begin

process (clk, alu_result, mem_result, write_reg, wb_ctrl)
variable var_alu_result     : std_logic_vector(15 downto 0);
variable var_mem_result     : std_logic_vector(15 downto 0);
variable var_write_reg      : std_logic_vector(3 downto 0);
variable var_ctrl           : std_logic_vector(3 downto 0);
begin

    if rising_edge (clk) then
        
        var_alu_result  := alu_result;
        var_mem_result  := mem_result;
        var_write_reg   := write_reg;
        var_ctrl        := wb_ctrl;
    
    end if;
    
    alu_result_out      <= var_alu_result;
    mem_result_out      <= var_mem_result;
    write_reg_out       <= var_write_reg;
    reg_write           <= var_ctrl(3);
    mem_to_reg          <= var_ctrl(2);
    switch_in           <= var_ctrl(1);
    led_write           <= var_ctrl(0);

end process;

end Behavioral;
