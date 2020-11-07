-- Ghennadie Mazin
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED.all;
use work.RISCV_DATA_PATH_pkg.all;

entity RISCV_DATA_PATH is
                  Port ( 
                            clk : in std_logic;
                            clear : in std_logic;
                            
                            -- comparator
                            COMP_funct_select : in std_logic_vector(3 downto 0);
                            DISABLE_COMPARATOR1_TWC : in std_logic;
                            DISABLE_COMPARATOR2_TWC : in std_logic; 
                            DISABLE_COMPARATOR3_TWC : in std_logic; 
                            o_COMPARATOR_RESULT : out std_logic_vector(5 downto 0);
 
                            MODs_OFF_COMPARATOR1 : out std_logic_vector(17 downto 0);
                            MODs_OFF_COMPARATOR2 : out std_logic_vector(17 downto 0);
                            MODs_OFF_COMPARATOR3 : out std_logic_vector(17 downto 0);
                            
                            COMPAR1_STALLS_CPU : out std_logic;                                            
                            COMPAR2_STALLS_CPU : out std_logic;
                            COMPAR3_STALLS_CPU : out std_logic;
                            
                            DISABLE_COMPARATOR_TMR : in std_logic;
                            
                            -- ALU
                            ALU_IMM : in std_logic_vector(DATA_WIDTH - 1 downto 0);
                            ALU_IMM_select : in std_logic;
                            ALU_FUNCT_select : in std_logic_vector(3 downto 0);
                            DISABLE_ALU1_TWC : in std_logic;
                            DISABLE_ALU2_TWC : in std_logic;
                            DISABLE_ALU3_TWC : in std_logic;
                            o_ALU_RESULT : out std_logic_vector(DATA_WIDTH - 1 downto 0);
                            
                            MODs_OFF_ALU1 : out std_logic_vector(29 downto 0);
                            MODs_OFF_ALU2 : out std_logic_vector(29 downto 0);
                            MODs_OFF_ALU3 : out std_logic_vector(29 downto 0);
                            
                            ALU1_STALLS_CPU : out std_logic;                                            
                            ALU2_STALLS_CPU : out std_logic;
                            ALU3_STALLS_CPU : out std_logic;
                            
                            DISABLE_ALU_TMR : in std_logic;
                            ALU_TMR_ERROR : out std_logic;
                            
                            
                            --registers
                            rReg1Addr : in std_logic_vector(REGISTERFILE_ADDR_WIDTH - 1 downto 0);     
                            rReg2Addr : in std_logic_vector(REGISTERFILE_ADDR_WIDTH - 1 downto 0);                                               
                            wRegAddr : in std_logic_vector(REGISTERFILE_ADDR_WIDTH - 1 downto 0);
                            wRegData : in std_logic_vector(DATA_WIDTH - 1 downto 0);
                            we_Reg : in std_logic;
                            rd_Reg : in std_logic; 
                            
                            o_REG1_dataOut : out std_logic_vector(DATA_WIDTH - 1 downto 0);
                            o_REG2_dataOut : out std_logic_vector(DATA_WIDTH - 1 downto 0);
                            DISABLE_REGFILE_TMR : in std_logic;
                            xRn_STOP_CLOCK : in std_logic;
                            xRn_load_to_regfile : in std_logic;
                            load_from_xRn_addr : in std_logic_vector(2 downto 0)                                                         
                  );


end RISCV_DATA_PATH;

architecture Behavioral of RISCV_DATA_PATH is
    
    -- registers
    signal REGIGSTERA_OUTPUT_s : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal REGIGSTERB_OUTPUT_s : std_logic_vector(DATA_WIDTH - 1 downto 0);

begin

RISCV_comparator: COMPARATOR_TWC_TMR 
        generic map(
                    DATA_WIDTH => DATA_WIDTH       
        )
         Port map( 
         
            clk => clk,
            clear => clear,

            COMPARATOR_inA => REGIGSTERA_OUTPUT_s,
            COMPARATOR_inB => REGIGSTERB_OUTPUT_s,

            COMPARATOR_funct_select  => COMP_funct_select,
            
            DISABLE_COMPARATOR1_TMR  => DISABLE_COMPARATOR1_TWC,
            DISABLE_COMPARATOR2_TMR  => DISABLE_COMPARATOR2_TWC,
            DISABLE_COMPARATOR3_TMR  => DISABLE_COMPARATOR3_TWC,
    
            -- OUTS
            COMPARATOR1_TMR_isDISABLED  => open,
            COMPARATOR2_TMR_isDISABLED  => open,
            COMPARATOR3_TMR_isDISABLED  => open,
            
            COMPARATOR_RESULT  => o_COMPARATOR_RESULT,
            
            MODs_OFF_COMPARATOR1  => MODs_OFF_COMPARATOR1,
            MODs_OFF_COMPARATOR2  => MODs_OFF_COMPARATOR2,
            MODs_OFF_COMPARATOR3  => MODs_OFF_COMPARATOR3,
            
            STALL_CPU_COMPARATOR1  => COMPAR1_STALLS_CPU,
            STALL_CPU_COMPARATOR2  => COMPAR2_STALLS_CPU,
            STALL_CPU_COMPARATOR3  => COMPAR3_STALLS_CPU,
            
            DISABLE_COMPARATOR_TMR  => DISABLE_COMPARATOR_TMR,
            COMPARATOR_TMR_isDISABLED => open

         );

  RISCV_ALU:  ALU_TWC_TMR
  generic map(
            DATA_WIDTH => DATA_WIDTH
  )

  Port map( 
            clk => clk,
            clear => clear,

            ALU_inA => REGIGSTERA_OUTPUT_s,
            ALU_inB => REGIGSTERB_OUTPUT_s,
            
            Imm_in => ALU_IMM,      
            Imm_select => ALU_IMM_select,
            funct_select => ALU_FUNCT_select,
            
            DISABLE_ALU1_TMR => DISABLE_ALU1_TWC,
            DISABLE_ALU2_TMR => DISABLE_ALU2_TWC,
            DISABLE_ALU3_TMR => DISABLE_ALU3_TWC,
    
            -- OUTS
            ALU1_TMR_isDISABLED => open,
            ALU2_TMR_isDISABLED => open,
            ALU3_TMR_isDISABLED => open,
            
            ALU_RESULT => o_ALU_RESULT,
            
            MODs_OFF_ALU1 => MODs_OFF_ALU1,
            MODs_OFF_ALU2 => MODs_OFF_ALU2,
            MODs_OFF_ALU3 => MODs_OFF_ALU3,
            
            STALL_CPUA_ALU1 => ALU1_STALLS_CPU, 
            STALL_CPUA_ALU2 => ALU2_STALLS_CPU,
            STALL_CPUA_ALU3 => ALU3_STALLS_CPU,
            
            ALU_TMR_ERROR => ALU_TMR_ERROR,
            
            DISABLE_ALU_TMR => DISABLE_ALU_TMR,
            ALU_TMR_isDISABLED => open
    
    );  

RISCV_REGFILE :RegisterFile 
  generic map(
        DATA_WIDTH => DATA_WIDTH,
        REGISTERFILE_ADDR_WIDTH => REGISTERFILE_ADDR_WIDTH,
        NUMBER_OF_REGS => NUMBER_OF_REGS
        )
  Port map(
        clk => clk,
        clear  => clear,

        isb_rRegA_addr  => rReg1Addr,
        isb_rRegB_addr  => rReg2Addr,
        isb_wReg_addr  => wRegAddr,
        isb_wData  => wRegData,
        isb_we => we_Reg,
        isb_re => rd_Reg,
        isb_rDataReg1  => REGIGSTERA_OUTPUT_s,
        isb_rDataReg2  => REGIGSTERB_OUTPUT_s,
        
        xRn_STOP_CLOCK => xRn_STOP_CLOCK,
        xRn_load_to_regfile => xRn_load_to_regfile,
        load_from_xRn_addr => load_from_xRn_addr,

        -- Errors and TMR ON/OFF
        isVoter_OFF  => open,
        DISABLE_RegisterFileTMR  => DISABLE_REGFILE_TMR,
        RegisterFileTMR_isDISABLED  => open
  );

o_REG1_dataOut <= REGIGSTERA_OUTPUT_s;
o_REG2_dataOut <= REGIGSTERB_OUTPUT_s;

end Behavioral;
