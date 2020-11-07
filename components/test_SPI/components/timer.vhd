library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Ghennadie Mazin

entity timer is
  generic (
            timer_flag_ns : natural := 8*16;
            system_freq : natural := 125000000
  );
  
  Port ( 
            clk: in std_logic;
            clear: in std_logic;
            
            start_timer : in std_logic;
            reset_timer : in std_logic;
  
            timer_flag : out std_logic
  
  );
end timer;

architecture Behavioral of timer is
    constant nano_seconds : integer := 1000000000;
    constant period : integer := nano_seconds/system_freq; --in nanoseconds
    constant timer_division : integer := (timer_flag_ns)/(period);
begin
    timer_p: process(clk)
        variable timer_counter : integer := 0;	
        begin
          if(rising_edge(clk)) then
              if(clear = '1') then
                timer_counter := 0;
                timer_flag <= '0';
              else
                -- timer:
                if(start_timer = '1') then
                    if(timer_counter = timer_division) then
                        timer_flag <= '1';
                        timer_counter := 0;
                    else
                        timer_counter := timer_counter + 1;
                        timer_flag <= '0';
                    end if;
                elsif(reset_timer = '1') then
                    timer_counter := 0;
                    timer_flag <= '0';
                else
                    timer_counter := 0;
                    timer_flag <= '0';
                end if;	                  
              end if;
          end if;	                                  
    end process;
end Behavioral;
