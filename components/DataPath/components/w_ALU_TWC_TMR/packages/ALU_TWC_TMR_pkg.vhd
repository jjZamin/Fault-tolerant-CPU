-- Ghennadie Mazin
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED.all;

package ALU_TWC_TMR_pkg is
            
component ALU_TWC is
    

            generic(
                    DATA_WIDTH : natural := 32
            );
            Port ( 
                    clk : in std_logic;
                    clear : in std_logic;
                    
                    isb_DataR1_in : in std_logic_Vector(DATA_WIDTH - 1 downto 0);
                    isb_DataR2_in : in std_logic_Vector(DATA_WIDTH - 1 downto 0);
                    isb_Imm_in : in std_logic_Vector(DATA_WIDTH - 1 downto 0);            
                    isb_select_Imm : in std_logic;
                    isb_funct : in std_logic_vector(3 downto 0);
                    DISABLE_ALU_TMR : in std_logic;

                    -- OUTS
                    ALU_TMR_isDISABLED : out std_logic;
                    isb_DataOut_ALURESULT : out std_logic_vector(DATA_WIDTH - 1 downto 0);
                    MODs_OFF : out std_logic_vector(29 downto 0);
                    STALL_CPU : out std_logic  
            );
end component;
 
    
end package ALU_TWC_TMR_pkg;

