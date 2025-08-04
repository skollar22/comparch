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
signal R, U, D    : std_logic := '0';
signal unhalt      : std_logic := '0';
signal led_array  : std_logic_vector (15 downto 0) := (others => '0');
signal switches   : std_logic_vector(15 downto 0) := (others => '0');
signal anodes     : std_logic_vector(3 downto 0) := (others => '0');
signal segments   : std_logic_vector(6 downto 0) := (others => '0');
signal dp         : std_logic := '0';

-- File input - declare but don't open yet
file input_file : text;

component single_cycle_core is
    port (
        btnL  : in  std_logic;
        btnR  : in  std_logic;
        btnU  : in  std_logic;
        btnD  : in  std_logic;
        clk   : in  std_logic;
        btnC  : in  std_logic;
        sw    : in  std_logic_vector (15 downto 0);
        led   : out std_logic_vector (15 downto 0);
        an    : out std_logic_vector (3 downto 0);
        seg   : out std_logic_vector (6 downto 0);
        dp    : out std_logic
    );
end component;

begin
    -- Instantiate UUT
    UUT : single_cycle_core
        port map (
            btnL => r_reset,
            btnR => R,
            btnU => U,
            btnD => D,
            clk  => r_CLOCK,
            btnC => unhalt,
            sw   => switches,
            led  => led_array,
            an   => anodes,
            seg  => segments,
            dp   => dp
        );
    
    -- Clock generation
    p_CLK_GEN : process
    begin
    wait for c_CLOCK_PERIOD / 2;
    r_CLOCK <= not r_CLOCK;
    end process;
    
    -- Main test process
    test_proc : process
        variable L : line; -- for reading
        variable P : line; -- for printing
        variable file_status : file_open_status;
        
        variable electoral : integer;
        variable candidate : integer;
        variable tally     : integer;
        variable tag       : integer;
        variable sw_val    : std_logic_vector(15 downto 0);
    begin
        -- Open the file
        file_open(file_status, input_file, "../../../../input.txt", read_mode);
        if file_status /= open_ok then
            assert false report "Cannot open input file" severity failure;
        end if;
        
        -- Initial reset
        r_reset <= '0';
        wait for 2 * c_CLOCK_PERIOD;
        r_reset <= '1';
        wait for 2 * c_CLOCK_PERIOD;
        r_reset <= '0';
        
        -- Process each line in file
        while not endfile(input_file) loop
            readline(input_file, L);
            read(L, electoral);
            read(L, candidate);
            read(L, tally);
            read(L, tag);
            
            -- Construct switches: [2b electoral][2b candidate][8b tally][4b tag=0000]
            sw_val := std_logic_vector(to_unsigned(electoral, 2)) &
                    std_logic_vector(to_unsigned(candidate, 2)) &
                    std_logic_vector(to_unsigned(tally, 8)) &
                    std_logic_vector(to_unsigned(tag, 4));
            
            switches <= sw_val;
            
            -- Print switches
            write(P, string'(": Electoral="));
            write(P, electoral);
            write(P, string'(" Candidate="));
            write(P, candidate);
            write(P, string'(" Tally="));
            write(P, tally);
            write(P, string'(" Tag="));
            write(P, tag);
            write(P, string'(" Switches="));
            write(P, sw_val);
            writeline(output, P);
            
            unhalt <= '1';
            wait for 2 * c_CLOCK_PERIOD;
            unhalt <= '0';
            
            wait for 20 * c_CLOCK_PERIOD; -- allow processing time
        end loop;
        
        -- Close the file
        file_close(input_file);
        
        wait for 1 sec;
        assert false report "Simulation ended" severity failure;
    end process;
    
end behave;