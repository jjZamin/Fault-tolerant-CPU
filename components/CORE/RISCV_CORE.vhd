library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED.all;
use work.RISCV_CORE_pkg.all;

entity RISCV_CORE is
          generic (
                        system_freq : natural := 18000000
            );
              Port ( 
                        clk : in std_logic;
                        clear : in std_logic;
                        start : in std_logic;
                        DISABLE_SEU_MITIGATION : in std_logic;
                        
                        isb_wData : out std_logic_vector(DATA_WIDTH - 1 downto 0);
                        isb_rData : in std_logic_vector(DATA_WIDTH - 1 downto 0);
                        isb_we : out std_logic;
                        isb_rd : out std_logic;
                        isb_addr : out std_logic_vector(DATA_WIDTH - 1 downto 0);
                        isb_wMEM_size : out std_logic_vector(1 downto 0);
                        
                        isb_instruction : in std_logic_vector(DATA_WIDTH - 1 downto 0);
                        isb_ProgramCounter : out std_logic_vector(DATA_WIDTH - 1 downto 0);
                        
                        IRQ_ext : in std_logic;
                        IRQ_ext_code : in std_logic_vector(DATA_WIDTH - 1 downto 0);                       
                        SCRUB : out std_logic              
              );
end RISCV_CORE;

architecture RTL of RISCV_CORE is

    -- DATAPATH ------------------------------------------------------------------
    signal COMP_RESULT_s : std_logic_vector(5 downto 0) := (others => '0');
    signal COMP_funct_select_s : std_logic_vector(3 downto 0) := (others => '0');
    signal MODs_OFF_COMPARATOR1_s : std_logic_vector(17 downto 0) := (others => '0');
    signal MODs_OFF_COMPARATOR2_s : std_logic_vector(17 downto 0) := (others => '0');
    signal MODs_OFF_COMPARATOR3_s : std_logic_vector(17 downto 0) := (others => '0');
    signal MODs_OFF_ALU1_s : std_logic_vector(29 downto 0) := (others => '0');
    signal MODs_OFF_ALU2_s : std_logic_vector(29 downto 0) := (others => '0');
    signal MODs_OFF_ALU3_s : std_logic_vector(29 downto 0) := (others => '0');
    signal ALU_TMR_ERR_s : std_logic := '0';
    
    -- stalls
    signal COMP1_STALLS_s : std_logic := '0';
    signal COMP2_STALLS_s : std_logic := '0';
    signal COMP3_STALLS_s : std_logic := '0';   
    signal ALU1_STALLS_s : std_logic := '0';
    signal ALU2_STALLS_s : std_logic := '0';
    signal ALU3_STALLS_s : std_logic := '0';          
    signal ERR_STALL_s : std_logic := '0';
    
    -- ALU
    signal ALU_imm_s : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal ALU_imm_select_s : std_logic := '0';
    signal ALU_funct_select_s : std_logic_vector(3 downto 0) := (others => '0');        
    signal o_ALU_result_s : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    
    --registers
    signal rReg1Addr_s : std_logic_vector(REGISTERFILE_ADDR_WIDTH - 1 downto 0) := (others => '0');  
    signal rReg2Addr_s : std_logic_vector(REGISTERFILE_ADDR_WIDTH - 1 downto 0) := (others => '0');                                            
    signal wRegAddr_s : std_logic_vector(REGISTERFILE_ADDR_WIDTH - 1 downto 0) := (others => '0');
    signal wRegData_s : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal we_Reg_s : std_logic := '0';
    signal rd_Reg_s : std_logic := '0';
                  
    signal o_REG1_dataOut_s : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal o_REG2_dataOut_s : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    
    -- CONTROL UNIT ------------------------------------------------------------------
    signal FATAL_ERROR_s : std_logic := '0';
    
    signal IRQ_int : std_logic := '0';
    signal IRQ_int_code : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    
    signal LOAD_FROM_MEM_SIZE_s : std_logic_vector(2 downto 0) := (others => '0');
    signal STORE_TO_MEM_SIZE_s : std_logic_vector(2 downto 0) := (others => '0');
    signal LOAD_MEM_addr : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal STORE_MEM_addr : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal we_MEME_s : std_logic := '0';
    signal rd_MEME_s : std_logic := '0';
    
    signal imm_to_reg_s : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal to_reg_wr_select_s : std_logic_vector(2 downto 0) := (others => '0');
    
    signal CSR_addr_s : std_logic_vector(11 downto 0) := (others => '0');
    signal CSR_we_s : std_logic := '0';
    signal CRS_write_to_reg_s : std_logic_vector(31 downto 0) := (others => '0');
    signal SCRUBBED_PC_s : std_logic_vector(31 downto 0) := (others => '0');
    
    signal MEM_TO_REG_s : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    
    signal IRQ_running_software_s : std_logic_vector(31 downto 0) := (others => '0');
    signal IRQ_timer1_running_s : std_logic := '0';
    
    -- rx7
    signal stop_clock_s : std_logic := '0';
    signal load_rx7_to_reg_file : std_logic := '0';
    signal resuse_Rn : std_logic_Vector(2 downto 0) := (others => '0');
begin

ERR_STALL_s <= '1' when 
                        COMP1_STALLS_s = '1' or
                        COMP2_STALLS_s = '1' or
                        COMP3_STALLS_s = '1' or
                        ALU1_STALLS_s = '1' or
                        ALU2_STALLS_s = '1' or                        
                        ALU3_STALLS_s = '1' else
                        '0';
 isb_we <= we_MEME_s;
 isb_rd <= rd_MEME_s;                       
                        
 isb_addr <= LOAD_MEM_addr when rd_MEME_s = '1' and we_MEME_s = '0' else
             STORE_MEM_addr when we_MEME_s = '1' and rd_MEME_s = '0' else
             (others => '0');                       
                                                
                        
risc_datapath: RISCV_DATA_PATH 
          Port map( 
                    clk => clk,
                    clear => clear,
                    
                    -- comparator
                    COMP_funct_select => COMP_funct_select_s,
                    DISABLE_COMPARATOR1_TWC => DISABLE_SEU_MITIGATION,
                    DISABLE_COMPARATOR2_TWC => DISABLE_SEU_MITIGATION,
                    DISABLE_COMPARATOR3_TWC => DISABLE_SEU_MITIGATION,
                    o_COMPARATOR_RESULT => COMP_RESULT_s,

                    MODs_OFF_COMPARATOR1 => MODs_OFF_COMPARATOR1_s,
                    MODs_OFF_COMPARATOR2 => MODs_OFF_COMPARATOR2_s,
                    MODs_OFF_COMPARATOR3 => MODs_OFF_COMPARATOR3_s,
                    
                    COMPAR1_STALLS_CPU => COMP1_STALLS_s,                                        
                    COMPAR2_STALLS_CPU => COMP2_STALLS_s,
                    COMPAR3_STALLS_CPU => COMP3_STALLS_s,
                    
                    DISABLE_COMPARATOR_TMR => DISABLE_SEU_MITIGATION,
                    
                    -- ALU
                    ALU_IMM => ALU_imm_s,
                    ALU_IMM_select => ALU_imm_select_s,
                    ALU_FUNCT_select => ALU_funct_select_s,
                    DISABLE_ALU1_TWC => DISABLE_SEU_MITIGATION,
                    DISABLE_ALU2_TWC => DISABLE_SEU_MITIGATION,
                    DISABLE_ALU3_TWC => DISABLE_SEU_MITIGATION,
                    o_ALU_RESULT => o_ALU_result_s,
                    
                    MODs_OFF_ALU1 => MODs_OFF_ALU1_s,
                    MODs_OFF_ALU2 => MODs_OFF_ALU2_s,
                    MODs_OFF_ALU3 => MODs_OFF_ALU3_s,
                    
                    ALU1_STALLS_CPU => ALU1_STALLS_s,                                          
                    ALU2_STALLS_CPU => ALU2_STALLS_s,
                    ALU3_STALLS_CPU => ALU3_STALLS_s,
                    
                    DISABLE_ALU_TMR => DISABLE_SEU_MITIGATION,
                    ALU_TMR_ERROR => ALU_TMR_ERR_s,
                    
                    
                    --registers
                    rReg1Addr => rReg1Addr_s,  
                    rReg2Addr => rReg2Addr_s,                                            
                    wRegAddr  => wRegAddr_s,
                    wRegData => wRegData_s,
                    we_Reg => we_Reg_s,
                    rd_Reg => rd_Reg_s,
                    
                    o_REG1_dataOut => o_REG1_dataOut_s,
                    o_REG2_dataOut => o_REG2_dataOut_s,
                    DISABLE_REGFILE_TMR => DISABLE_SEU_MITIGATION,
                    
                    xRn_STOP_CLOCK => stop_clock_s,
                    xRn_load_to_regfile => load_rx7_to_reg_file,
                    load_from_xRn_addr => resuse_Rn                                   
                    
          );

risc_control: RISCV_ControlUnit 
      generic map(
                DATA_WIDTH => DATA_WIDTH,
                IRQ_CODE_WIDTH => DATA_WIDTH,
                PC_start => PC_start,
                PC_scrub => PC_scrub
                
      )
      
      Port map(
                clk => clk,
                clear => clear,
                
                START => start,
                
                FATAL_ERROR => FATAL_ERROR_s,
                INSTRUCTION => isb_instruction,
                ERROR_STALLS => ERR_STALL_s,
                IRQ_int => IRQ_int,             --!!!!!!!!!!!!!!! only timer for now, CSR
                IRQ_int_code => IRQ_int_code,   --!!!!!!!!!!!!!!!
                IRQ_ext => IRQ_ext,
                IRQ_ext_code => IRQ_ext_code,
                IRQ_int_running_software => IRQ_running_software_s(0), --only for timer now
                BRANCH_FLAGS => COMP_RESULT_s,
                RS1_reg => o_REG1_dataOut_s,
                
                -- alu
                ALU_funct_select => ALU_funct_select_s,
                ALU_Imm => ALU_imm_s,
                ALU_Imm_select => ALU_imm_select_s,
                -- comp
                COMP_funct_select => COMP_funct_select_s,
                -- MEM access write 
                we_MEM => we_MEME_s,
                rd_MEM => rd_MEME_s,
                LOAD_FROM_MEM_SIZE => LOAD_FROM_MEM_SIZE_s,
                LOAD_FROM_MEM_ADDR => LOAD_MEM_addr,
                STORE_TO_MEM_SIZE => STORE_TO_MEM_SIZE_s,
                STORE_TO_MEM_ADDR => STORE_MEM_addr,
                
                -- registers
                Imm_to_reg => imm_to_reg_s,
                we_reg => we_Reg_s,
                rd_reg => rd_Reg_s,
                rDataA_regAddr => rReg1Addr_s,
                rDataB_regAddr => rReg2Addr_s,
                wData_regAddr => wRegAddr_s,
                to_reg_wr_select => to_reg_wr_select_s,
                which_XR_to_reuse => resuse_Rn,   
                load_registers => load_rx7_to_reg_file,                  
                STOP_CLOCK => stop_clock_s,
                -- CSR
                CSR_Addr => CSR_addr_s,
                CSR_rd => open,                          --!!!
                CSR_we => CSR_we_s,         
                PC_out => isb_ProgramCounter,
                SCRUBBED_PC => SCRUBBED_PC_s,       
                SCRUB => SCRUB

          );

mux_wreg: MUX_wrReg 
          Port map( 
                    Control_Imm => imm_to_reg_s,
                    ALU_result => o_ALU_result_s,
                    MEM_read => MEM_TO_REG_s,
                    CSR_read => CRS_write_to_reg_s,
                    to_reg_wr_select => to_reg_wr_select_s,
                    
                    wr_to_reg => wRegData_s           
          );

mx_memsize: MUX_rMEMsize 
              Port map( 
                        rMEM_in => isb_rData,
                        wReg_out => MEM_TO_REG_s,
                        rMEM_size => LOAD_FROM_MEM_SIZE_s,
                        rReg_in => o_REG2_dataOut_s,
                        wMEM_out => isb_wData,
                        wMEM_size => STORE_TO_MEM_SIZE_s,
                        o_wMEM_size => isb_wMEM_size                     
              );

risc_csr: CSR 
          generic map (
                    system_frq => system_freq
          )
          Port map( 
                    clk => clk,
                    clear => clear,
                    
                    CSR_addr => CSR_addr_s,
                    CSR_control_word => o_REG1_dataOut_s, 
                    CSR_we => CSR_we_s,
                    CRS_write_to_reg => CRS_write_to_reg_s,
                    CSR_scrubbed_pc => SCRUBBED_PC_s,
                    -- IRQs
                    IRQ_timer1 => IRQ_int,
                    IRQ_running_software => IRQ_running_software_s,
                    IRQ_code => IRQ_int_code
          );
          
err_cntr: error_control
              Port map( 
                            clk => clk,
                            clear => clear,
                            
                            MODs_OFF_COMPARATOR1 => MODs_OFF_COMPARATOR1_s,
                            MODs_OFF_COMPARATOR2 => MODs_OFF_COMPARATOR2_s,
                            MODs_OFF_COMPARATOR3 => MODs_OFF_COMPARATOR3_s,                        
                            MODs_OFF_ALU1 => MODs_OFF_ALU1_s,
                            MODs_OFF_ALU2 => MODs_OFF_ALU2_s,
                            MODs_OFF_ALU3 => MODs_OFF_ALU3_s,
                            ALU_TMR_ERROR => ALU_TMR_ERR_s,
                            FATAL_ERROR  => FATAL_ERROR_s             
              );          

end RTL;
