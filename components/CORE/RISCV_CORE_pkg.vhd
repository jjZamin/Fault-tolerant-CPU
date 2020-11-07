library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED.all;

package RISCV_CORE_pkg is

 constant DATA_WIDTH : natural := 32;
 constant REGISTERFILE_ADDR_WIDTH : natural := 5;            
 constant NUMBER_OF_REGS : natural := 32;
 constant PC_start : signed(DATA_WIDTH - 1 downto 0) := "00000000000000000000000010001100"; --140
 constant PC_scrub : signed(DATA_WIDTH - 1 downto 0) := (others => '0');
 
 constant system_frq : natural := 20000000;

    component RISCV_DATA_PATH is
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
    end component;    

component RISCV_ControlUnit is
              generic(
                        DATA_WIDTH : natural := 32;
                        IRQ_CODE_WIDTH : natural := 32;
                        PC_start : signed(31 downto 0) := (others => '0');
                        PC_scrub : signed(31 downto 0) := (others => '0') 
              );
              
              Port (
                        clk : in std_logic;
                        clear : in std_logic;
                        
                        START : in std_logic;
                        
                        FATAL_ERROR : in std_logic; -- time to scrub
                        INSTRUCTION : in std_logic_vector(DATA_WIDTH - 1 downto 0);
                        ERROR_STALLS : in std_logic;
                        IRQ_int : in std_logic;
                        IRQ_int_code : in std_logic_vector(IRQ_CODE_WIDTH - 1 downto 0);
                        IRQ_ext : in std_logic;
                        IRQ_ext_code : in std_logic_vector(IRQ_CODE_WIDTH - 1 downto 0);
                        IRQ_int_running_software : in std_logic;
                       
                        BRANCH_FLAGS : in std_logic_vector(5 downto 0);
                        RS1_reg : in std_logic_vector(DATA_WIDTH - 1 downto 0); --used for JALR and MEM ACCESS OFFSET
                        
                        -- alu
                        ALU_funct_select : out std_logic_vector(3 downto 0);
                        ALU_Imm : out std_logic_vector(DATA_WIDTH - 1 downto 0);
                        ALU_Imm_select : out std_logic; --1: imm, 0: Reg2Data
                        -- comp
                        COMP_funct_select : out std_logic_vector(3 downto 0);
                        -- MEM access write 
                        we_MEM : out std_logic;
                        rd_MEM : out std_logic;
                        LOAD_FROM_MEM_SIZE : out std_logic_vector(2 downto 0);
                        LOAD_FROM_MEM_ADDR : out std_logic_vector(31 downto 0);
                        STORE_TO_MEM_SIZE : out std_logic_vector(2 downto 0);
                        STORE_TO_MEM_ADDR : out std_logic_vector(31 downto 0);
                        
                        -- registers
                        Imm_to_reg : out std_logic_vector(DATA_WIDTH - 1 downto 0); --LUI, AUIPC
                        we_reg : out std_logic;
                        rd_reg : out std_logic;
                        rDataA_regAddr : out std_logic_vector(4 downto 0);
                        rDataB_regAddr : out std_logic_vector(4 downto 0);
                        wData_regAddr : out std_logic_vector(4 downto 0);
                        to_reg_wr_select : out std_logic_vector(2 downto 0); --ALU(00), IMM(01), MEM(10), Returnaddr(11)
                        which_XR_to_reuse : out std_logic_vector(2 downto 0); --0-7 buffered instructions
                        load_registers : out std_logic;
                        STOP_CLOCK : out std_logic;
                        -- CSR
                        CSR_Addr : out std_logic_vector(11 downto 0);
                        CSR_rd : out std_logic;
                        CSR_we : out std_logic;                        -- SCRUBS
                        PC_out : out std_logic_vector(DATA_WIDTH - 1 downto 0);
                        SCRUBBED_PC : out std_logic_vector(DATA_WIDTH - 1 downto 0);                                                                     
                        SCRUB : out std_logic
              );
end component;

component MUX_wrReg is
          Port ( 
                    Control_Imm : in std_logic_vector(31 downto 0);
                    ALU_result : in std_logic_vector(31 downto 0);
                    MEM_read : in std_logic_vector(31 downto 0);
                    CSR_read : in std_logic_vector(31 downto 0);
                    to_reg_wr_select : in std_logic_vector(2 downto 0);
                    
                    wr_to_reg : out std_logic_vector(31 downto 0)           
          );
end component;

component MUX_rMEMsize is
              Port ( 
                        rMEM_in : in std_logic_vector(31 downto 0);
                        wReg_out : out std_logic_vector(31 downto 0);
                        rMEM_size : in std_logic_vector(2 downto 0); 

                        rReg_in : in std_logic_vector(31 downto 0);
                        wMEM_out : out std_logic_vector(31 downto 0);
                        wMEM_size : in std_logic_vector(2 downto 0);
                        o_wMEM_size : out std_logic_vector(1 downto 0)                        
              );
end component;


component CSR is
          generic (
                    system_frq : natural := system_frq
          );
          Port ( 
                    clk : in std_logic;
                    clear : in std_logic;
                    
                    CSR_addr : in std_logic_vector(11 downto 0);
                    CSR_control_word : in std_logic_vector(31 downto 0);
                    CSR_we : in std_logic;
                    CRS_write_to_reg : out std_logic_vector(31 downto 0);
                    CSR_scrubbed_pc : in std_logic_vector(31 downto 0);
                    -- IRQs
                    IRQ_timer1 : out std_logic;
                   
                    IRQ_code : out std_logic_vector(31 downto 0);
                    IRQ_running_software : out std_logic_vector(31 downto 0)
          
          );
end component;

component error_control is
              Port ( 
                            clk : in std_logic;
                            clear : in std_logic;
                            
                            MODs_OFF_COMPARATOR1 : in std_logic_vector(17 downto 0);
                            MODs_OFF_COMPARATOR2 : in std_logic_vector(17 downto 0);
                            MODs_OFF_COMPARATOR3 : in std_logic_vector(17 downto 0);                        
                            MODs_OFF_ALU1 : in std_logic_vector(29 downto 0);
                            MODs_OFF_ALU2 : in std_logic_vector(29 downto 0);
                            MODs_OFF_ALU3 : in std_logic_vector(29 downto 0); 
                            ALU_TMR_ERROR : in std_logic;
                            FATAL_ERROR : out std_logic
              
              );
end component;

end package RISCV_CORE_pkg;


