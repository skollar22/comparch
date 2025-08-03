library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity reg_to_7seg is
    generic (
        DATA_SIZE : integer := 32;
        REG_SIZE : integer := 5
    );
    port ( clk       : in std_logic;
           reg_value : in std_logic_vector((DATA_SIZE - 1) downto 0);
           dp        : out std_logic;
           an        : out std_logic_vector(3 downto 0);
           seg       : out std_logic_vector(6 downto 0) );
end reg_to_7seg;

architecture Behavioral of reg_to_7seg is
    signal clk_divider : std_logic_vector(17 downto 0) := (others => '0');
    signal digit       : integer range 0 to 9 := 0;
    signal value       : integer range 0 to 9999 := 0;
begin

    process(clk)
    begin
        if rising_edge(clk) then
            clk_divider <= clk_divider + 1;
        end if;
    end process;
    
    an(0) <= clk_divider(17) or clk_divider(16);
    an(1) <= clk_divider(17) or not(clk_divider(16));
    an(2) <= not(clk_divider(17)) or clk_divider(16);
    an(3) <= not(clk_divider(17)) or not(clk_divider(16));
    dp <= '1';
    
    process(clk, reg_value)
        variable temp_value : integer;
    begin
        if rising_edge(clk) then
            temp_value := conv_integer(reg_value(13 downto 0));
            if temp_value > 9999 then
                value <= 9999;
            else
                value <= temp_value;
            end if;
        end if;
    end process;


    process(clk_divider(17 downto 16), value)
    begin
        case clk_divider(17 downto 16) is
            when "00" =>
                digit <= value mod 10;
            when "01" =>
                digit <= (value / 10) mod 10;
            when "10" =>
                digit <= (value / 100) mod 10;
            when "11" =>
                digit <= (value / 1000) mod 10;
        end case;
    end process;
    
    process(digit)
    begin
        case digit is
            when 0 => seg <= "1000000";
            when 1 => seg <= "1111001";
            when 2 => seg <= "0100100";
            when 3 => seg <= "0110000";
            when 4 => seg <= "0011001";
            when 5 => seg <= "0010010";
            when 6 => seg <= "0000010";
            when 7 => seg <= "1111000";
            when 8 => seg <= "0000000";
            when 9 => seg <= "0010000";
            when others => seg <= "1111111";
        end case;
    end process;
                
end Behavioral;
