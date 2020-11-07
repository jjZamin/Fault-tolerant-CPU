library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Ghennadie Mazin

entity softtimer is
  generic (
            system_freq : natural := 20000000
  );
  
  Port ( 
            clk: in std_logic;
            clear: in std_logic;
            
            timer_flag_ns : in std_logic_vector(31 downto 0);
            start_timer : in std_logic;
            reset_timer : in std_logic;
            we_period : in std_logic;
            timer_flag : out std_logic
  
  );
end softtimer;

architecture rtl of softtimer is
    constant nano_seconds : integer := 1000000000;
    constant period : integer := nano_seconds/system_freq; --in nanoseconds
    signal timer_division : natural := 0; -- := (to_integer(unsigned(timer_flag_ns)))/(period);
begin
    timer_p: process(clk, clear)
        variable timer_counter : integer := 0;	
        begin
          if(clear = '1') then
                timer_counter := 0;
                timer_flag <= '0';
                timer_division <= 0;
          elsif(rising_edge(clk)) then
            -- timer:
            if(we_period = '1') then
                timer_division <= (to_integer(unsigned(timer_flag_ns)))/(period);
            end if;
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
    end process;
    
end rtl;
