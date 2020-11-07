
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED.all;

package COMPARATOR_TWC_TMR_pkg is
        
    constant DATA_WIDTH : natural := 32;



component COMPARATOR_TWC is
        generic(
                DATA_WIDTH : natural := DATA_WIDTH
        );
        Port ( 
                clk : in std_logic;
                clear : in std_logic;
                
                isb_DataR1_in : in std_logic_Vector(DATA_WIDTH - 1 downto 0);
                isb_DataR2_in : in std_logic_Vector(DATA_WIDTH - 1 downto 0);
                isb_funct : in std_logic_vector(3 downto 0);
                DISABLE_COMP_TMR: in std_logic;

                -- OUTS
                COMP_TMR_isDISABLED : out std_logic;
                isb_DataOut_COMPRESULT : out std_logic_vector(5 downto 0);
                CAMP_MODs_OFF : out std_logic_vector(17 downto 0);
                COMP_STALL_CPU : out std_logic  
        );
end component;

end package COMPARATOR_TWC_TMR_pkg;

