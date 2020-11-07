library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use ieee.numeric_std.all;


package timer_pkg is     
    component timer is
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
    end component;

end package timer_pkg;
