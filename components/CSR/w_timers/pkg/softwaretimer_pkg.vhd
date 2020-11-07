library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use ieee.numeric_std.all;


package softwaretimer_pkg is
    constant system_frq : natural := 125000000;
     
    component RISCV_timers is
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
    end component;


    component softtimer is
      generic (
                system_freq : natural := 125000000
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
    end component;

end package softwaretimer_pkg;
