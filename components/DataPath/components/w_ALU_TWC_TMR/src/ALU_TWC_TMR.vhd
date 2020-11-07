library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED.all;
use work.ALU_TWC_TMR_pkg.all;

--****************
-- By Ghennadie Mazin, final project.
--****************

entity ALU_TWC_TMR is
  generic(
            DATA_WIDTH : natural := 32
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
    end ALU_TWC_TMR;
    
architecture RTL of ALU_TWC_TMR is

    


    attribute DONT_TOUCH : string;
    --attribute DONT_TOUCH of ALU1: label is "TRUE";
    --attribute DONT_TOUCH of ALU2: label is "TRUE";
    --attribute DONT_TOUCH of ALU3: label is "TRUE";
    
    signal RES_ALU1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal RES_ALU2 : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal RES_ALU3 : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    attribute DONT_TOUCH of RES_ALU1: signal is "TRUE";
    attribute DONT_TOUCH of RES_ALU2: signal is "TRUE";
    attribute DONT_TOUCH of RES_ALU3: signal is "TRUE";
    
    
    
begin

    ALU_TMR_isDISABLED <= DISABLE_ALU_TMR;
        
    ALU1: ALU_TWC 
            generic map(
                    DATA_WIDTH => DATA_WIDTH
            )
            Port map( 
                    clk => clk,
                    clear => clear,
                    
                    isb_DataR1_in => ALU_inA,
                    isb_DataR2_in => ALU_inB,
                    isb_Imm_in => Imm_in,           
                    isb_select_Imm => Imm_select,
                    isb_funct => funct_select,
                    DISABLE_ALU_TMR => DISABLE_ALU1_TMR,

                    -- OUTS
                    ALU_TMR_isDISABLED => ALU1_TMR_isDISABLED,
                    isb_DataOut_ALURESULT => RES_ALU1,
                    MODs_OFF => MODs_OFF_ALU1,
                    STALL_CPU => STALL_CPUA_ALU1  
            );
   ALU2: ALU_TWC 
        generic map(
                DATA_WIDTH => DATA_WIDTH
        )
        Port map( 
                clk => clk,
                clear => clear,
                
                isb_DataR1_in => ALU_inA,
                isb_DataR2_in => ALU_inB,
                isb_Imm_in => Imm_in,           
                isb_select_Imm => Imm_select,
                isb_funct => funct_select,
                DISABLE_ALU_TMR => DISABLE_ALU2_TMR,

                -- OUTS
                ALU_TMR_isDISABLED => ALU2_TMR_isDISABLED,
                isb_DataOut_ALURESULT => RES_ALU2,
                MODs_OFF => MODs_OFF_ALU2,
                STALL_CPU => STALL_CPUA_ALU2
                 
        ); 
    
    ALU3: ALU_TWC 
        generic map(
                DATA_WIDTH => DATA_WIDTH
        )
        Port map( 
                clk => clk,
                clear => clear,
                
                isb_DataR1_in => ALU_inA,
                isb_DataR2_in => ALU_inB,
                isb_Imm_in => Imm_in,           
                isb_select_Imm => Imm_select,
                isb_funct => funct_select,
                DISABLE_ALU_TMR => DISABLE_ALU3_TMR,

                -- OUTS
                ALU_TMR_isDISABLED => ALU3_TMR_isDISABLED,
                isb_DataOut_ALURESULT => RES_ALU3,
                MODs_OFF => MODs_OFF_ALU3, 
                STALL_CPU => STALL_CPUA_ALU3  
        );
    
    --voter
    ALU_RESULT <= RES_ALU1 when 
                    ((RES_ALU1 = RES_ALU2 and RES_ALU1 = RES_ALU3) or 
                    (RES_ALU1 = RES_ALU2 and RES_ALU1 /= RES_ALU3) or
                    (RES_ALU1 = RES_ALU3 and RES_ALU1 /= RES_ALU2)) and DISABLE_ALU_TMR = '0' else
            RES_ALU2 when (RES_ALU2 = RES_ALU3 and RES_ALU1 /= RES_ALU2) and DISABLE_ALU_TMR = '0' else
            RES_ALU1 when DISABLE_ALU_TMR = '1' else
            RES_ALU1;
   
   ALU_TMR_ERROR <= '1' when 
                              ((RES_ALU1 /= RES_ALU2 and RES_ALU1 /= RES_ALU3 and RES_ALU2 /= RES_ALU3) 
                                and DISABLE_ALU_TMR = '0') or
                              ((RES_ALU1 /= RES_ALU2 and RES_ALU1 /= RES_ALU3 and RES_ALU2 /= RES_ALU3) 
                                and DISABLE_ALU_TMR = '0') else
                          '0';                   
 end RTL;
