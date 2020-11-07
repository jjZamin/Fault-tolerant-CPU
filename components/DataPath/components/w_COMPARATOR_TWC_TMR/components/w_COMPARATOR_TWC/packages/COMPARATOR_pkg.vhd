
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED.all;

package COMPARATOR_PKG is
        
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




    component COMPARATOR is
    generic (
            DATA_WIDTH : natural := 32
    );
    Port ( 
           R1_in : in std_logic_vector(DATA_WIDTH - 1 downto 0);
           R2_in : in std_logic_vector(DATA_WIDTH - 1 downto 0);
           branch_flags_MOD1 : out std_logic_vector(5 downto 0);
           branch_flags_MOD2 : out std_logic_vector(5 downto 0);
           branch_flags_MOD3 : out std_logic_vector(5 downto 0);
           funct: in std_logic_vector(3 downto 0)
    );
    end component;
        
    component COMPARAPTOR_ECT is
          generic(
                    DATA_WIDTH : natural := 32
          );
          Port ( 
                    clk : in std_logic;
                    clear : in std_logic;
                    
                    Res_MOD1 : in std_logic_vector(5 downto 0);
                    Res_MOD2 : in std_logic_vector(5 downto 0);
                    Res_MOD3 : in std_logic_vector(5 downto 0);
                    funct    : in std_logic_vector(3 downto 0);
                    ALU_ERROR: in std_logic;
                    
                    A_test   : out std_logic_vector(DATA_WIDTH - 1 downto 0);
                    B_test   : out std_logic_vector(DATA_WIDTH - 1 downto 0);
                    funct_out: out std_logic_vector(3 downto 0);
                    
                    TESTING_ON  : out std_logic;
                    
                    MODS_OFF : out std_logic_vector(17 downto 0);
                    ALU_STALL_CPU : out std_logic
      );
    end component;
        
    component MUX_dataComp is
      generic (
                DATA_WIDTH : natural := DATA_WIDTH  
                );
      Port ( 
                A_in : in std_Logic_vector(DATA_WIDTH - 1 downto 0);  
                B_in : in std_Logic_vector(DATA_WIDTH - 1 downto 0);  
                
                At_in : in std_logic_vector(DATA_WIDTH - 1 downto 0);
                Bt_in : in std_logic_vector(DATA_WIDTH - 1 downto 0);
                TEST_ON : in std_logic;
                
                A_data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0);
                B_data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0)
                );
    
    
    end component;    
        
    component MUX_functComp is
      Port ( 
                functInstr_in : in std_logic_vector(3 downto 0);
                functTest_in : in std_logic_vector(3 downto 0);
                TEST_ON : in std_logic;
                funct_out : out std_logic_vector(3 downto 0)            
                );
    
    end component;   
    
    
    component COMP_comp is
         Port ( 
                Res_MOD1 : in std_logic_vector(5 downto 0);
                Res_MOD2 : in std_logic_vector(5 downto 0);
                Res_MOD3 : in std_logic_vector(5 downto 0);
                
                COMP_TMR_DISABLED : in std_logic;
                MODS_OFF : in std_logic_vector(17 downto 0); -- 6 comps * 3 mods
                TEST_ON : in std_logic;
                
                funct : in std_logic_vector(3 downto 0);
                ERROR : out std_logic;
                COMP_RESULT : out std_logic_vector(5 downto 0)   
         );
    end component;
end package COMPARATOR_PKG;

