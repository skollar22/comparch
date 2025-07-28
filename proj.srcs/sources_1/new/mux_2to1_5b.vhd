----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/20/2025 12:53:01 PM
-- Design Name: 
-- Module Name: mux_2to1_5b - Behavioral
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

entity mux_2to1 is
    generic (
        MUX_SIZE : integer
    );
    Port ( mux_select : in STD_LOGIC;
           data_a : in STD_LOGIC_VECTOR ((MUX_SIZE - 1) downto 0);
           data_b : in STD_LOGIC_VECTOR ((MUX_SIZE - 1) downto 0);
           data_out : out STD_LOGIC_VECTOR ((MUX_SIZE - 1) downto 0));
end mux_2to1;

architecture Behavioral of mux_2to1 is

component mux_2to1_1b is
    port ( mux_select : in  std_logic;
           data_a     : in  std_logic;
           data_b     : in  std_logic;
           data_out   : out std_logic );
end component;

begin

    -- this for-generate-loop replicates MUX_SIZE single-bit 2-to-1 mux
    muxes : for i in (MUX_SIZE - 1) downto 0 generate
        bit_mux : mux_2to1_1b 
        port map ( mux_select => mux_select,
                   data_a     => data_a(i),
                   data_b     => data_b(i),
                   data_out   => data_out(i) );
    end generate muxes;

end Behavioral;
