----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/12/2025 03:12:20 PM
-- Design Name: 
-- Module Name: EXMEM_reg - Behavioral
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

entity EXMEM_reg is
    generic (
        DATA_SIZE : integer := 32;
        REG_SIZE : integer := 5
    );
    Port (
        alu_result          : in std_logic_vector((DATA_SIZE - 1) downto 0);
        read_data_2         : in std_logic_vector((DATA_SIZE - 1) downto 0);
        write_reg           : in std_logic_vector((REG_SIZE - 1) downto 0);
        mem_ctrl            : in std_logic;
        wb_ctrl             : in std_logic_vector(3 downto 0);
        clk                 : in std_logic;
        alu_res_out         : out std_logic_vector((DATA_SIZE - 1) downto 0);
        read_data_out_2     : out std_logic_vector((DATA_SIZE - 1) downto 0);
        write_reg_out       : out std_logic_vector((REG_SIZE - 1) downto 0);
        mem_write           : out std_logic;
        wb_ctrl_out         : out std_logic_vector(3 downto 0)
    );
end EXMEM_reg;

architecture Behavioral of EXMEM_reg is

begin

process (clk, alu_result, read_data_2, write_reg, mem_ctrl, wb_ctrl)
variable var_alu_result     : std_logic_vector((DATA_SIZE - 1) downto 0);
variable var_read_data      : std_logic_vector((DATA_SIZE - 1) downto 0);
variable var_write_reg      : std_logic_vector((REG_SIZE - 1) downto 0);
variable var_ctrl           : std_logic_vector(4 downto 0);
begin
    if rising_edge (clk) then
        
        var_alu_result      := alu_result;
        var_read_data       := read_data_2;
        var_write_reg       := write_reg;
        var_ctrl            := mem_ctrl & wb_ctrl;
        
    end if;
    
    alu_res_out         <= var_alu_result;
    read_data_out_2     <= var_read_data;
    write_reg_out       <= var_write_reg;
    mem_write           <= var_ctrl(4);
    wb_ctrl_out         <= var_ctrl(3 downto 0);
    
end process;

end Behavioral;
