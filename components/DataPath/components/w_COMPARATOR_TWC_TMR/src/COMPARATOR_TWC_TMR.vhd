
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED.all;
use work.COMPARATOR_TWC_TMR_pkg.all;

entity COMPARATOR_TWC_TMR is
        generic (
                DATA_WIDTH : natural := 32       
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
end COMPARATOR_TWC_TMR;

architecture RTL of COMPARATOR_TWC_TMR is

    attribute DONT_TOUCH : string;
    attribute DONT_TOUCH of comp1: label is "TRUE";
    attribute DONT_TOUCH of comp2: label is "TRUE";
    attribute DONT_TOUCH of comp3: label is "TRUE";
    
    signal RES_COMP1 : std_logic_vector(5 downto 0) := (others => '0');
    signal RES_COMP2 : std_logic_vector(5 downto 0) := (others => '0');
    signal RES_COMP3 : std_logic_vector(5 downto 0) := (others => '0');
    attribute DONT_TOUCH of RES_COMP1: signal is "TRUE";
    attribute DONT_TOUCH of RES_COMP2: signal is "TRUE";
    attribute DONT_TOUCH of RES_COMP3: signal is "TRUE";

begin

    COMPARATOR_TMR_isDISABLED <= DISABLE_COMPARATOR_TMR;

    comp1 : COMPARATOR_TWC 
        generic map(
                DATA_WIDTH => DATA_WIDTH
        )
        Port map( 
                clk => clk,
                clear => clear,
                
                isb_DataR1_in => COMPARATOR_inA,
                isb_DataR2_in => COMPARATOR_inB,
                isb_funct => COMPARATOR_funct_select,
                DISABLE_COMP_TMR => DISABLE_COMPARATOR1_TMR,
                -- OUTS
                COMP_TMR_isDISABLED => COMPARATOR1_TMR_isDISABLED,
                isb_DataOut_COMPRESULT => RES_COMP1,
                CAMP_MODs_OFF => MODs_OFF_COMPARATOR1,
                COMP_STALL_CPU => STALL_CPU_COMPARATOR1
        );
    
    comp2 : COMPARATOR_TWC 
        generic map(
                DATA_WIDTH => DATA_WIDTH
        )
        Port map( 
                clk => clk,
                clear => clear,
                
                isb_DataR1_in => COMPARATOR_inA,
                isb_DataR2_in => COMPARATOR_inB,
                isb_funct => COMPARATOR_funct_select,
                DISABLE_COMP_TMR => DISABLE_COMPARATOR2_TMR,
                -- OUTS
                COMP_TMR_isDISABLED => COMPARATOR2_TMR_isDISABLED,
                isb_DataOut_COMPRESULT => RES_COMP2,
                CAMP_MODs_OFF => MODs_OFF_COMPARATOR2,
                COMP_STALL_CPU => STALL_CPU_COMPARATOR2
        );

    comp3 : COMPARATOR_TWC 
        generic map(
                DATA_WIDTH => DATA_WIDTH
        )
        Port map( 
                clk => clk,
                clear => clear,
                
                isb_DataR1_in => COMPARATOR_inA,
                isb_DataR2_in => COMPARATOR_inB,
                isb_funct => COMPARATOR_funct_select,
                DISABLE_COMP_TMR => DISABLE_COMPARATOR3_TMR,
                -- OUTS
                COMP_TMR_isDISABLED => COMPARATOR3_TMR_isDISABLED,
                isb_DataOut_COMPRESULT => RES_COMP3,
                CAMP_MODs_OFF => MODs_OFF_COMPARATOR3,
                COMP_STALL_CPU => STALL_CPU_COMPARATOR3
        );

        --voter
   COMPARATOR_RESULT <= RES_COMP1 when 
                    ((RES_COMP1 = RES_COMP2 and RES_COMP1 = RES_COMP3) or 
                    (RES_COMP1 = RES_COMP2 and RES_COMP1 /= RES_COMP3) or
                    (RES_COMP1 = RES_COMP3 and RES_COMP1 /= RES_COMP2)) and DISABLE_COMPARATOR_TMR = '0' else
            RES_COMP2 when (RES_COMP2 = RES_COMP3 and RES_COMP1 /= RES_COMP2) and DISABLE_COMPARATOR_TMR = '0' else
            RES_COMP1 when DISABLE_COMPARATOR_TMR = '1' 
            else                
            RES_COMP1;
      
end RTL;
