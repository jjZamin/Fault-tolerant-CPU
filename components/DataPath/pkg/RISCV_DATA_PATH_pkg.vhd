-- Ghennadie Mazin
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED.all;
use work.xR7_pkg.all;


package RISCV_DATA_PATH_pkg is
 constant DATA_WIDTH : natural := 32;
 constant REGISTERFILE_ADDR_WIDTH : natural := 5;            
 constant NUMBER_OF_REGS : natural := 32;
                 
                    
component COMPARATOR_TWC_TMR is
        generic (
                    DATA_WIDTH : natural := DATA_WIDTH       
        );
         Port ( 
         
            clk : in std_logic;
            clear : in std_logic;

            COMPARATOR_inA : in std_logic_vector(DATA_WIDTH - 1 downto 0);
            COMPARATOR_inB : in std_logic_vector(DATA_WIDTH - 1 downto 0);

            COMPARATOR_funct_select : in std_logic_vector(3 downto 0);
            
            DISABLE_COMPARATOR1_TMR : in std_logic;
            DISABLE_COMPARATOR2_TMR : in std_logic;
            DISABLE_COMPARATOR3_TMR : in std_logic;
    
            -- OUTS
            COMPARATOR1_TMR_isDISABLED : out std_logic;
            COMPARATOR2_TMR_isDISABLED : out std_logic;
            COMPARATOR3_TMR_isDISABLED : out std_logic;
            
            COMPARATOR_RESULT : out std_logic_vector(5 downto 0);
            
            MODs_OFF_COMPARATOR1 : out std_logic_vector(17 downto 0);
            MODs_OFF_COMPARATOR2 : out std_logic_vector(17 downto 0);
            MODs_OFF_COMPARATOR3 : out std_logic_vector(17 downto 0);
            
            STALL_CPU_COMPARATOR1 : out std_logic;
            STALL_CPU_COMPARATOR2 : out std_logic;  
            STALL_CPU_COMPARATOR3 : out std_logic;
            
            DISABLE_COMPARATOR_TMR : in std_logic;
            COMPARATOR_TMR_isDISABLED : out std_logic      

         );
end component;                
            
component ALU_TWC_TMR is
  generic(
            DATA_WIDTH : natural := DATA_WIDTH
  );

  Port ( 
            clk : in std_logic;
            clear : in std_logic;

            ALU_inA : in std_logic_vector(DATA_WIDTH - 1 downto 0);
            ALU_inB : in std_logic_vector(DATA_WIDTH - 1 downto 0);
            
            Imm_in : in std_logic_Vector(DATA_WIDTH - 1 downto 0);            
            Imm_select : in std_logic;
            funct_select : in std_logic_vector(3 downto 0);
            
            DISABLE_ALU1_TMR : in std_logic;
            DISABLE_ALU2_TMR : in std_logic;
            DISABLE_ALU3_TMR : in std_logic;
    
            -- OUTS
            ALU1_TMR_isDISABLED : out std_logic;
            ALU2_TMR_isDISABLED : out std_logic;
            ALU3_TMR_isDISABLED : out std_logic;
            
            ALU_RESULT : out std_logic_vector(DATA_WIDTH - 1 downto 0);
            
            MODs_OFF_ALU1 : out std_logic_vector(29 downto 0);
            MODs_OFF_ALU2 : out std_logic_vector(29 downto 0);
            MODs_OFF_ALU3 : out std_logic_vector(29 downto 0);
            
            STALL_CPUA_ALU1 : out std_logic;
            STALL_CPUA_ALU2 : out std_logic;  
            STALL_CPUA_ALU3 : out std_logic;
            
            ALU_TMR_ERROR : out std_logic;
            
            DISABLE_ALU_TMR : in std_logic;
            ALU_TMR_isDISABLED : out std_logic        
    
    );
    end component;            
            
component RegisterFile is
  generic (
        DATA_WIDTH : integer := DATA_WIDTH;
        REGISTERFILE_ADDR_WIDTH : integer := REGISTERFILE_ADDR_WIDTH;
        NUMBER_OF_REGS: integer := NUMBER_OF_REGS
        );
  Port (
        clk : in std_logic;
        clear : in std_logic;

        isb_rRegA_addr : in std_logic_vector(REGISTERFILE_ADDR_WIDTH - 1 downto 0);
        isb_rRegB_addr : in std_logic_vector(REGISTERFILE_ADDR_WIDTH - 1 downto 0);
        isb_wReg_addr : in std_logic_vector(REGISTERFILE_ADDR_WIDTH - 1 downto 0);
        isb_wData : in std_logic_vector(DATA_WIDTH - 1 downto 0); -- data + 1 paritybit;
        isb_we : in std_logic;
        isb_re : in std_logic;
        isb_rDataReg1 : out std_logic_vector(DATA_WIDTH - 1 downto 0); -- data + 1 paritybit;
        isb_rDataReg2 : out std_logic_vector(DATA_WIDTH - 1 downto 0); -- data + 1 paritybit (bit 32)

        -- XR7--

        xRn_STOP_CLOCK : in std_logic;
        xRn_load_to_regfile : in std_logic;
        load_from_xRn_addr : in std_logic_vector(2 downto 0);

        -- Errors and TMR ON/OFF
        isVoter_OFF : out std_logic_vector(2 downto 0);
        DISABLE_RegisterFileTMR : in std_logic; --enables TMR
        RegisterFileTMR_isDISABLED : out std_logic --enabled TMR?
  );
end component;
 
    
end package RISCV_DATA_PATH_pkg;

