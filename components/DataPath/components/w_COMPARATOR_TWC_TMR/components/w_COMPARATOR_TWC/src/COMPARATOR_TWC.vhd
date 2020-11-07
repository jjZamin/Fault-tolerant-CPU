library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED.all;
use work.COMPARATOR_PKG.all;

entity COMPARATOR_TWC is
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
end COMPARATOR_TWC;

architecture RTL of COMPARATOR_TWC is

    -- MUX DATA
    signal At_s : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal Bt_s : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal TEST_ON_s : std_logic := '0';
    signal DataA_COMP : std_logic_Vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal DataB_COMP : std_logic_Vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    
    -- MUX FUNCT
    signal funct_test : std_logic_vector(3 downto 0) := (others => '0');
    signal funct_COMP : std_logic_vector(3 downto 0) := (others => '0');
    
    -- comp
    attribute DONT_TOUCH : string;
    signal MOD1_data : std_logic_Vector(5 downto 0) := (others => '0');
    signal MOD2_data : std_logic_Vector(5 downto 0) := (others => '0');
    signal MOD3_data : std_logic_Vector(5 downto 0) := (others => '0');
    
    attribute DONT_TOUCH of MOD1_data: signal is "TRUE";
    attribute DONT_TOUCH of MOD2_data: signal is "TRUE";
    attribute DONT_TOUCH of MOD3_data: signal is "TRUE";
    
    -- comp
    signal MODS_OFF_s : std_logic_Vector(17 downto 0) := (others => '0');
    signal ERROR_s : std_logic := '0';
    
begin

    COMP_TMR_isDISABLED <= DISABLE_COMP_TMR;
    CAMP_MODs_OFF <= MODS_OFF_s;
    
COMPAR_p: COMPARATOR 
           generic map (
                DATA_WIDTH => DATA_WIDTH
            )
           Port map ( 
                R1_in => DataA_COMP, 
                R2_in => DataB_COMP,
                funct => funct_COMP,
                
                branch_flags_MOD1 => MOD1_data, 
                branch_flags_MOD2 => MOD2_data, 
                branch_flags_MOD3 => MOD3_data
      );

COMPR_ECT_p: COMPARAPTOR_ECT
          generic map(
                DATA_WIDTH => DATA_WIDTH
          )
          Port map ( 
                clk => clk,
                clear => clear,
                
                Res_MOD1 => MOD1_data,
                Res_MOD2 => MOD2_data,
                Res_MOD3 => MOD3_data,
                funct => isb_funct,
                ALU_ERROR => ERROR_s,
                
                A_test => At_s,
                B_test => Bt_s,
                funct_out => funct_test,
                
                TESTING_ON => TEST_ON_s,
                
                MODS_OFF => MODS_OFF_s,
                ALU_STALL_CPU => COMP_STALL_CPU
          );
mxcmp_D_p: MUX_DataComp
          generic map(
                 DATA_WIDTH => DATA_WIDTH  
          )
          Port map ( 
                A_in => isb_DataR1_in,
                B_in => isb_DataR2_in,
                
                At_in => At_s, 
                Bt_in => Bt_s,
                TEST_ON => TEST_ON_s,
                
                A_data_out => DataA_COMP,
                B_data_out => DataB_COMP
          );

mx_f_p: MUX_functComp
      Port map ( 
                functInstr_in => isb_funct,
                functTest_in => funct_test,
                TEST_ON => TEST_ON_s,
                funct_out => funct_COMP 
      );

COMP_p: COMP_comp       
      Port map( 
                Res_MOD1 => MOD1_data,
                Res_MOD2 => MOD2_data, 
                Res_MOD3 => MOD3_data,
                
                COMP_TMR_DISABLED => DISABLE_COMP_TMR,
                MODS_OFF => MODS_OFF_s,
                TEST_ON  => TEST_ON_s,
                
                funct => isb_funct,
                            
                ERROR => ERROR_s,
                COMP_RESULT => isb_DataOut_COMPRESULT      
      );
end RTL;



