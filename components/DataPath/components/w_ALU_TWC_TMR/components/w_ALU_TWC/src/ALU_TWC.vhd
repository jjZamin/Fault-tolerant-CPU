library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED.all;
use work.ALU_PKG.all;

entity ALU_TWC is
            generic(
                    DATA_WIDTH : natural := DATA_WIDTH
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
end ALU_TWC;

architecture RTL of ALU_TWC is

    -- MUX DATA
    signal At_s : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal Bt_s : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal TEST_ON_s : std_logic := '0';
    signal DataA_ALU : std_logic_Vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal DataB_ALU : std_logic_Vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    
    -- MUX FUNCT
    signal funct_test : std_logic_vector(3 downto 0) := (others => '0');
    signal funct_ALU : std_logic_vector(3 downto 0) := (others => '0');
    
    attribute DONT_TOUCH : string;
    
    -- ALU
    signal MOD1_data : std_logic_Vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal MOD2_data : std_logic_Vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal MOD3_data : std_logic_Vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    attribute DONT_TOUCH of MOD1_data: signal is "TRUE";
    attribute DONT_TOUCH of MOD2_data: signal is "TRUE";
    attribute DONT_TOUCH of MOD3_data: signal is "TRUE";
    
    -- ALU ECT
    signal MODS_OFF_s : std_logic_Vector(29 downto 0) := (others => '0');
    signal ERROR_s : std_logic := '0';
    
begin

    ALU_TMR_isDISABLED <= DISABLE_ALU_TMR;
    MODs_OFF <= MODS_OFF_s;
    
ALU_p: ALU 
           generic map (
                DATA_WIDTH => DATA_WIDTH
            )
           Port map ( 
                A_in => DataA_ALU, 
                B_in => DataB_ALU,
                funct => funct_ALU,
                
                Res_MOD1 => MOD1_data, 
                Res_MOD2 => MOD2_data, 
                Res_MOD3 => MOD3_data
      );

ALU_ECT_p: ALU_ECT
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
                ALU_STALL_CPU => STALL_CPU
          );
mx_D_p: MUX_data
          generic map(
                 DATA_WIDTH => DATA_WIDTH  
          )
          Port map ( 
                A_in => isb_DataR1_in,
                B_in => isb_DataR2_in,
                Imm_in => isb_Imm_in,
                select_imm => isb_select_Imm,
                
                At_in => At_s, 
                Bt_in => Bt_s,
                TEST_ON => TEST_ON_s,
                
                A_data_out => DataA_ALU,
                B_data_out => DataB_ALU
          );

mx_f_p: MUX_funct
      Port map ( 
                functInstr_in => isb_funct,
                functTest_in => funct_test,
                TEST_ON => TEST_ON_s,
                funct_out => funct_ALU 
      );


COMP_p: COMP       
    generic map(
                DATA_WIDTH => DATA_WIDTH
      )
      Port map( 
                Res_MOD1 => MOD1_data, 
                Res_MOD2 => MOD2_data, 
                Res_MOD3 => MOD3_data,
                
                ALU_TMR_DISABLED => DISABLE_ALU_TMR,
                MODS_OFF => MODS_OFF_s,
                TEST_ON  => TEST_ON_s,
                
                funct => isb_funct,
                            
                ERROR => ERROR_s,
                ALU_RESULT => isb_DataOut_ALURESULT      
      );
end RTL;