----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/12/2025 03:12:20 PM
-- Design Name: 
-- Module Name: IDEX_reg - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IDEX_reg is
  Port (
    read_data_1         : in std_logic_vector(15 downto 0);
    read_data_2         : in std_logic_vector(15 downto 0);
    imm_ext16b          : in std_logic_vector(15 downto 0);
    read_reg_1          : in std_logic_vector(3 downto 0);
    read_reg_2          : in std_logic_vector(3 downto 0);
    write_reg           : in std_logic_vector(3 downto 0);
    next_pc             : in std_logic_vector(3 downto 0);
    ex_ctrl             : in std_logic_vector(1 downto 0);
    mem_ctrl            : in std_logic;
    wb_ctrl             : in std_logic_vector(3 downto 0);
    clk                 : in std_logic;
    flush               : in std_logic;
    stall               : in std_logic;
    read_out_1          : out std_logic_vector(15 downto 0);
    read_out_2          : out std_logic_vector(15 downto 0);
    imm16b              : out std_logic_vector(15 downto 0);
    imm4b               : out std_logic_vector(3 downto 0);
    rr_out_1            : out std_logic_vector(3 downto 0);
    rr_out_2            : out std_logic_vector(3 downto 0);
    wr_out              : out std_logic_vector(3 downto 0);
    pc_out              : out std_logic_vector(3 downto 0);
    mem_ctrl_out        : out std_logic;
    wb_ctrl_out         : out std_logic_vector(3 downto 0);
    alu_src             : out std_logic;
    pc_add              : out std_logic
  );
end IDEX_reg;

architecture Behavioral of IDEX_reg is

begin

process (clk, flush, stall, read_data_1, read_data_2, imm_ext16b, read_reg_1, read_reg_2, write_reg, next_pc)
variable var_read_data_1    : std_logic_vector(15 downto 0);
variable var_read_data_2    : std_logic_vector(15 downto 0);
variable var_imm_16b        : std_logic_vector(15 downto 0);
variable var_rr1            : std_logic_vector(3 downto 0);
variable var_rr2            : std_logic_vector(3 downto 0);
variable var_wr             : std_logic_vector(3 downto 0);
variable var_pc             : std_logic_vector(3 downto 0);
variable var_ctrl           : std_logic_vector(6 downto 0);
begin
    if rising_edge (clk) then
        if (flush = '1') or (stall = '1') then
            var_ctrl            := (others => '0');
        else
            var_read_data_1     := read_data_1;
            var_read_data_2     := read_data_2;
            var_imm_16b         := imm_ext16b;
            var_rr1             := read_reg_1;
            var_rr2             := read_reg_2;
            var_wr              := write_reg;
            var_pc              := next_pc;
            var_ctrl            := ex_ctrl & mem_ctrl & wb_ctrl;
        end if;
    end if;
    
    read_out_1          <= var_read_data_1;
    read_out_2          <= var_read_data_2;
    imm16b              <= var_imm_16b;
    imm4b               <= var_imm_16b(3 downto 0);
    rr_out_1            <= var_rr1;
    rr_out_2            <= var_rr2;
    wr_out              <= var_wr;
    pc_out              <= var_pc;
    mem_ctrl_out        <= var_ctrl(4);
    wb_ctrl_out         <= var_ctrl(3 downto 0);
    alu_src             <= var_ctrl(6);
    pc_add              <= var_ctrl(5);
    
end process;

end Behavioral;
