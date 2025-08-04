library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity Single_cycle_core_TB_VHDL is
end Single_cycle_core_TB_VHDL;

architecture behave of Single_cycle_core_TB_VHDL is

  constant c_CLOCK_PERIOD : time := 2 ns;

  signal r_CLOCK    : std_logic := '0';
  signal r_reset    : std_logic := '0';
  signal unhalt_rd  : std_logic := '0';
  signal led_array  : std_logic_vector (15 downto 0) := (others => '0');
  signal switches   : std_logic_vector(15 downto 0) := (others => '0');
  signal anodes     : std_logic_vector(3 downto 0) := (others => '0');
  signal segments   : std_logic_vector(6 downto 0) := (others => '0');

  component single_cycle_core is
    port (
      btnL  : in  std_logic;
      clk   : in  std_logic;
      btnC  : in  std_logic;
      sw    : in  std_logic_vector(15 downto 0);
      led   : out std_logic_vector (15 downto 0)
    );
  end component;

  -- File input
  file input_file : text open read_mode is "input.txt";

begin

  UUT : single_cycle_core
    port map (
      btnL  => r_reset,
      clk   => r_CLOCK,
      btnC  => unhalt_rd,
      sw    => switches,
      led   => led_array
    );

  p_CLK_GEN : process
  begin
    wait for c_CLOCK_PERIOD / 2;
    r_CLOCK <= not r_CLOCK;
  end process;

  test_proc : process
    variable L : line;
    variable electoral : integer;
    variable candidate : integer;
    variable tally     : integer;

    variable sw_val : std_logic_vector(15 downto 0);
  begin
    r_reset <= '0';
    wait for 2 * c_CLOCK_PERIOD;
    r_reset <= '1';
    wait for 2 * c_CLOCK_PERIOD;
    r_reset <= '0';

    -- read each line of the file
    while not endfile(input_file) loop
      readline(input_file, L);
      read(L, electoral);
      read(L, candidate);
      read(L, tally);

      -- Construct switch input
      sw_val := std_logic_vector(to_unsigned(electoral, 2)) &  -- bits 15 downto 14
                std_logic_vector(to_unsigned(candidate, 2)) &  -- bits 13 downto 12
                std_logic_vector(to_unsigned(tally, 8)) &      -- bits 11 downto 4
                "0000";                                        -- bits 3 downto 0 (tag)

      switches <= sw_val;
      unhalt_rd <= '1';
      wait for 2 * c_CLOCK_PERIOD;
    end loop;

    wait for 1 sec;
    assert false report "Simulation ended" severity failure;
  end process;

end behave;
