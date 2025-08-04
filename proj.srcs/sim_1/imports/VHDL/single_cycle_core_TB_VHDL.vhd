
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Single_cycle_core_TB_VHDL is
end Single_cycle_core_TB_VHDL;


architecture behave of Single_cycle_core_TB_VHDL is
 
  -- 1 GHz = 2 nanoseconds period
  constant c_CLOCK_PERIOD : time := 2 ns; 


 signal r_CLOCK     : std_logic := '0';
 signal r_reset    : std_logic := '0';
 signal R, U, D, dp : std_logic := '0';
 signal r_ext      : std_logic := '0';
 signal led_array   : std_logic_vector (15 downto 0) := (others => '0');
 signal switches     : std_logic_vector(15 downto 0) := (others => '0');
 signal anodes      : std_logic_vector(3 downto 0) := (others => '0');
 signal segments    : std_logic_vector(6 downto 0) := (others => '0');
 

-- Component declaration for the Unit Under Test (UUT)
component single_cycle_core is
    port ( btnL   : in std_logic;
           btnR   : in std_logic;
           btnU   : in std_logic;
           btnD   : in std_logic;
           clk    : in std_logic;
           btnC   : in std_logic;
           sw     : in std_logic_vector (15 downto 0);
           led    : out std_logic_vector (15 downto 0);
           an     : out std_logic_vector (3 downto 0);
           seg    : out std_logic_vector (6 downto 0);
           dp     : out std_logic 
     );
      end component ;
      
      
      begin
       
        -- Instantiate the Unit Under Test (UUT)
        UUT : single_cycle_core
          port map (
            btnL    => r_reset,
            btnR    => R,
            btnU    => U,
            btnD    => D,
            clk     => r_CLOCK,
            btnC     => r_ext,
            sw      => switches,
            led     => led_array,
            an      => anodes,
            seg     => segments,
            dp      => dp
            );
       
        p_CLK_GEN : process is
        begin
          wait for c_CLOCK_PERIOD/2;
          r_CLOCK <= not r_CLOCK;
        end process p_CLK_GEN; 
         
        process                               -- main testing
        begin
            r_reset <= '0';
            switches <= "1010101010101010";
       
            wait for 2*c_CLOCK_PERIOD ;
            r_reset <= '1';
           
            wait for 2*c_CLOCK_PERIOD ;
            r_reset <= '0';         
            
            wait for 32*c_CLOCK_PERIOD ;
            switches <= "0000000000000001";
            r_ext <= '1';
            
            wait for 32*c_CLOCK_PERIOD ;
            switches <= "0000000000000010";
            r_ext <= '0';
          
            wait for 2 sec;
           
        end process;
         
      end behave;
      
      
      
      
      
      
      