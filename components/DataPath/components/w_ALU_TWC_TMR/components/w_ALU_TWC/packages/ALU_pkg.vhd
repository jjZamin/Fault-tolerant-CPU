
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED.all;

package ALU_PKG is
        
    constant DATA_WIDTH : natural := 32;

    component ALU is
      generic (
            DATA_WIDTH : integer := DATA_WIDTH
        );
      Port ( 
                A_in : in std_logic_vector(DATA_WIDTH - 1 downto 0);
                B_in : in std_logic_Vector(DATA_WIDTH - 1 downto 0);
                funct: in std_logic_Vector(3 downto 0);
                
                Res_MOD1 : out std_logic_vector(DATA_WIDTH - 1 downto 0);
                Res_MOD2 : out std_logic_vector(DATA_WIDTH - 1 downto 0);
                Res_MOD3 : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    
      );
    end component;
        
    component ALU_ECT is
      generic(
                DATA_WIDTH : natural := DATA_WIDTH
      );
      Port ( 
                clk : in std_logic;
                clear : in std_logic;
                
                Res_MOD1 : in std_logic_vector(DATA_WIDTH - 1 downto 0);
                Res_MOD2 : in std_logic_vector(DATA_WIDTH - 1 downto 0);
                Res_MOD3 : in std_logic_vector(DATA_WIDTH - 1 downto 0);
                funct    : in std_logic_vector(3 downto 0);
                ALU_ERROR: in std_logic;
                
                A_test   : out std_logic_vector(DATA_WIDTH - 1 downto 0);
                B_test   : out std_logic_vector(DATA_WIDTH - 1 downto 0);
                funct_out: out std_logic_vector(3 downto 0);
                
                TESTING_ON  : out std_logic;
                
                MODS_OFF : out std_logic_vector(29 downto 0);
                ALU_STALL_CPU : out std_logic
      );
    end component;
        
    component MUX_data is
      generic (
                DATA_WIDTH : natural := DATA_WIDTH  
                );
      Port ( 
                A_in : in std_Logic_vector(DATA_WIDTH - 1 downto 0);  
                B_in : in std_Logic_vector(DATA_WIDTH - 1 downto 0);  
                Imm_in : in std_Logic_vector(DATA_WIDTH - 1 downto 0);  
                select_imm : in std_logic;
                
                At_in : in std_logic_vector(DATA_WIDTH - 1 downto 0);
                Bt_in : in std_logic_vector(DATA_WIDTH - 1 downto 0);
                TEST_ON : in std_logic;
                
                A_data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0);
                B_data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0)
                );
    
    
    end component;    
        
    component MUX_funct is
      Port ( 
                functInstr_in : in std_logic_vector(3 downto 0);
                functTest_in : in std_logic_vector(3 downto 0);
                TEST_ON : in std_logic;
                funct_out : out std_logic_vector(3 downto 0)            
                );
    
    end component;   
    
    
    component COMP is
      generic (
                DATA_WIDTH : natural := 32
      );
      Port ( 
                Res_MOD1 : in std_logic_vector(DATA_WIDTH - 1 downto 0);
                Res_MOD2 : in std_logic_vector(DATA_WIDTH - 1 downto 0);
                Res_MOD3 : in std_logic_vector(DATA_WIDTH - 1 downto 0);
                
                ALU_TMR_DISABLED : in std_logic;
                MODS_OFF : in std_logic_vector(29 downto 0);
                TEST_ON : in std_logic;
                
                funct : in std_logic_vector(3 downto 0);
                            
                ERROR : out std_logic;
                ALU_RESULT : out std_logic_vector(DATA_WIDTH - 1 downto 0)            
      );
    
    
    end component;
 
    
end package ALU_PKG;

