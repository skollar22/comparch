----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/14/2025 08:11:30 PM
-- Design Name: 
-- Module Name: hazard_unit - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity hazard_unit is
    generic (
        PC_SIZE : integer := 8;
        DATA_SIZE : integer := 32;
        REG_SIZE : integer := 5
    );
    Port (
        -- in
        pc_add          : in std_logic;
        data_1          : in std_logic_vector((DATA_SIZE - 1) downto 0);
        data_2          : in std_logic_vector((DATA_SIZE - 1) downto 0);
        branch_pc       : in std_logic_vector((PC_SIZE - 1) downto 0);  -- sig_ex_next_pc / flush pc
        stall_pc        : in std_logic_vector((PC_SIZE - 1) downto 0);  -- pc remains the same as currently is, ie sig_if_curr_pc
        next_pc         : in std_logic_vector((PC_SIZE - 1) downto 0);  -- normal behaviour, ie sig_if_next_pc
        hlt             : in std_logic;
        imm8b           : in std_logic_vector((PC_SIZE - 1) downto 0);
        id_mem_read     : in std_logic;
        id_reg_rt       : in std_logic_vector((REG_SIZE - 1) downto 0);
        ex_mem_read     : in std_logic;
        ex_reg_rt       : in std_logic_vector((REG_SIZE - 1) downto 0);
        if_reg_rs       : in std_logic_vector((REG_SIZE - 1) downto 0);
        if_reg_rt       : in std_logic_vector((REG_SIZE - 1) downto 0);
        
        -- out
        if_flush        : out std_logic;
        if_stall        : out std_logic;
        new_pc          : out std_logic_vector((PC_SIZE - 1) downto 0)
    );
end hazard_unit;

architecture Behavioral of hazard_unit is

begin

process(pc_add, data_1, data_2, next_pc, 
        branch_pc, stall_pc, imm8b, hlt, id_mem_read, 
        id_reg_rt, if_reg_rs, id_reg_rt)
variable temp_pc    : std_logic_vector(PC_SIZE downto 0);
begin
    
    if (hlt = '1') then
        if_flush <= '1';
        if_stall <= '0';
        
        new_pc <= stall_pc;
    elsif (data_1 = data_2) and (pc_add = '1') then
        if_flush <= '1';
        if_stall <= '0';
        temp_pc := (('0' & branch_pc) + ('0' & imm8b));
        new_pc <= temp_pc((PC_SIZE - 1) downto 0);
    else
        if_flush <= '0';
        
        if ((id_mem_read = '1')
            and ((id_reg_rt = if_reg_rs)
            or (id_reg_rt = if_reg_rt)))
            or ((ex_mem_read = '1')
            and ((ex_reg_rt = if_reg_rs)
            or (ex_reg_rt = if_reg_rt)))
            then
            
            if_stall <= '1';
            new_pc <= stall_pc;
        else
            if_stall <= '0';
            new_pc <= next_pc;
        end if;
        
    end if;

end process;

end Behavioral;
