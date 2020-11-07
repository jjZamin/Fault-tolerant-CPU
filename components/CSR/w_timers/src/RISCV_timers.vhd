library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.softwaretimer_pkg.all;

entity RISCV_timers is
              generic(
                        system_frq : natural := system_frq
              );
              Port ( 
                        clk : in std_logic;
                        clear : in std_logic;
                        
                        addr : in std_logic_vector(11 downto 0);
                        we : in std_logic;
                        control_word : in std_logic_vector(31 downto 0);
                        IRQ_timer1 : out std_logic;
                        IRQ_code : out std_logic_vector(31 downto 0)
                
              );
end RISCV_timers;

architecture Behavioral of RISCV_timers is

    signal start_timer1 : std_logic := '0';
    signal reset_timer1 : std_logic := '1';
    signal period_timer1 : std_logic_vector(31 downto 0) := (others => '0');
    signal FLAG_timer1_s : std_logic := '0';
    signal we_period_timer1_s : std_logic := '0';
    signal IRQ_code_s : std_logic_vector(31 downto 0) := (others => '0'); --PC

begin
       
   set_timers : process(clk, clear)
   begin
       if(clear = '1') then
            start_timer1 <= '0';
            reset_timer1 <= '1';
            period_timer1 <= (others => '0');
            we_period_timer1_s <= '0';
       elsif(rising_edge(clk)) then
            we_period_timer1_s <= '0';

                if(we = '1') then
                --- timer one addr: 100000000000 for period, 100000000001 for start
                    case addr is
                        -- timer one, CSR reg
                        when "000000000010" => -- set timer period addr CSR
                            we_period_timer1_s <= '1';
                            period_timer1 <= control_word;
                        when "000000000001" => --timer one ON/OFF --cntrolwolrd bit(0) = 0/1
                            start_timer1 <= control_word(0);
                        when "000000000011" => -- set PC to jump to when timer is high
                            IRQ_code_s <= control_word;
                        when others =>
                            null;     
                    end case;
                end if;    
            end if;
   end process;


 z_timer1 : softtimer 
      generic map(
           system_freq => system_frq
      )
      
      Port map( 
                clk => clk,
                clear => clear,
                timer_flag_ns => period_timer1, 
                start_timer => start_timer1,
                reset_timer => reset_timer1,
                we_period => we_period_timer1_s,
                timer_flag => FLAG_timer1_s
      
      ); 

IRQ_timer1 <= FLAG_timer1_s;
IRQ_code <= IRQ_code_s when FLAG_timer1_s = '1' else (others => '0');

end Behavioral;
