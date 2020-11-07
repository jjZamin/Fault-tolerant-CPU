library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED.all;

-- Ghennadie Mazin

entity RISCV_ControlUnit is
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
end RISCV_ControlUnit;

architecture RTL of RISCV_ControlUnit is

    signal INSTR_DONE : std_logic := '0';

    signal PC_out_s : std_logic_vector(31 downto 0) := (others => '0');
    signal INSTRUCTION_s : std_logic_vector(31 downto 0) := (others => '0');
    type arr_type is array (0 to 7) of std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal instruction_buffer : arr_type := ((others => (others => '0')));
    signal which_XR_to_reuse_s : std_logic_vector(2 downto 0) := (others => '0');
    
    
    attribute dont_touch : string;
    -- UNTOUCHABLES !
    signal PC_cnt1 : signed(31 downto 0) := PC_start; 
    signal PC_cnt2 : signed(31 downto 0) := PC_start;
    signal PC_cnt3 : signed(31 downto 0) := PC_start;
    signal prev_PC : signed(31 downto 0) := (others => '0');
  
    
    --attribute dont_touch of PC_cnt1 : signal is "true";
    --attribute dont_touch of PC_cnt2 : signal is "true";
    --attribute dont_touch of PC_cnt3 : signal is "true";
    
    -- instruction split
    signal OPCODE_s : std_logic_vector(6 downto 0) := (others => '0');
    signal reg_dest : std_logic_vector(4 downto 0) := (others => '0');
    signal reg_srs1 : std_logic_vector(4 downto 0) := (others => '0');
    signal reg_srs2 : std_logic_vector(4 downto 0) := (others => '0');
    signal funct3 : std_logic_vector(2 downto 0) := (others => '0');
    signal funct7 : std_logic_vector(6 downto 0) := (others => '0');
    
    -- IMM
    signal I_imm : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal S_imm : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal B_imm : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal U_imm : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal J_imm : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal JALR_reg_in : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal shamt : std_logic_vector(31 downto 0) := (others => '0');
    
    --STATES
    signal STATES : std_logic_vector(5 downto 0) := "000001";
    signal START_CLOCK : std_logic := '0';
    signal UNKNOWN_INSTRUCTION : std_logic := '0';
    signal ERROR_STALLS_s : std_logic := '0';
    ---IRQ
    signal IRQ_return_addr : std_logic_vector(31 downto 0) := (others => '0');
    signal IRQ_int_running_s : std_logic := '0';
    signal IRQ_int_begin_s : std_logic := '0';
    signal IRQ_WTF : std_logic := '0';
    
    signal SCRUB_finalPC : signed(31 downto 0) := PC_start;
    signal set_scrub_flag : std_logic := '0';
    signal fatal_error_prss_running : std_logic := '0';
    signal start_scub_seq_counting : std_logic := '0';
    signal seq_counter : natural := 0;
begin

    OPCODE_s <= INSTRUCTION(6 downto 0);
    reg_dest <= INSTRUCTION(11 downto 7);
    reg_srs1 <= INSTRUCTION(19 downto 15);
    reg_srs2 <= INSTRUCTION(24 downto 20);
    funct7 <= INSTRUCTION(31 downto 25);
    funct3 <= INSTRUCTION(14 downto 12);
    JALR_reg_in(31 downto 1) <= RS1_reg(31 downto 1);
    JALR_reg_in(0) <= '0';
    --imm
    I_imm(11 downto 0) <= INSTRUCTION(31 downto 20);
    I_imm(31 downto 12) <= (others => '0') when INSTRUCTION(31) = '0' else
                           (others => '1');
    
    S_imm(4 downto 0) <= INSTRUCTION(11 downto 7);
    S_imm(11 downto 5) <= INSTRUCTION(31 downto 25);    
    S_imm(31 downto 12) <= (others => '0') when INSTRUCTION(31) = '0' else
                           (others => '1');
    
    B_imm(0) <= '0';
    B_imm(4 downto 1) <= INSTRUCTION(11 downto 8);
    B_imm(10 downto 5) <= INSTRUCTION(30 downto 25);
    B_imm(11) <= INSTRUCTION(7);
    B_imm(12) <= INSTRUCTION(31);
    B_imm(31 downto 13) <= (others => '0') when INSTRUCTION(31) = '0' else
                           (others => '1');
    
    U_imm(11 downto 0) <= (others => '0');
    U_imm(31 downto 12) <= INSTRUCTION(31 downto 12);
    
    J_imm(0) <= '0';
    J_imm(10 downto 1) <= INSTRUCTION(30 downto 21);
    J_imm(11) <= INSTRUCTION(20);
    J_imm(19 downto 12) <= INSTRUCTION(19 downto 12);
    J_imm(20) <= INSTRUCTION(31);
    J_imm(31 downto 21) <= (others => '0') when INSTRUCTION(31) = '0' else
                           (others => '1');

    
    shamt(4 downto 0) <= reg_srs2;
    shamt(31 downto 5) <= (others => '0');
    ------ CONTROL LOGIC
    
        -- comp
        -- registers

    rDataA_regAddr <= reg_srs1; 
    rDataB_regAddr <= reg_srs2;
    wData_regAddr <= reg_dest;
    rd_reg <= '1';
    
    STOP_CLOCK <= not START_CLOCK;
--------------------------------------------------------------------------------
    COMP_funct_select <= 
                        "0000" when OPCODE_s = "1100011" and funct3 = "000" else --BEQ
                        "1111" when OPCODE_s = "1100011" and funct3 = "001" else --BNE
                        "1001" when OPCODE_s = "1100011" and funct3 = "100" else --BLT
                        "1010" when OPCODE_s = "1100011" and funct3 = "101" else --BGE
                        "0001" when OPCODE_s = "1100011" and funct3 = "110" else --BLTU
                        "0010" when OPCODE_s = "1100011" and funct3 = "111" else --BGEU
                        "0000";    
--------------------------------------------------------------------------------    
    -- MEM access  
    
    -- store
    we_MEM <= '1' when OPCODE_s = "0100011" and ERROR_STALLS_s = '0' else '0';
    
    STORE_TO_MEM_SIZE <= funct3 when OPCODE_s = "0100011" else (others => '0'); --load byte/hw/w/u
    STORE_TO_MEM_ADDR <= std_logic_vector(signed(RS1_reg) + signed(S_imm)) 
                        when OPCODE_s = "0100011" else (others => '0');
    SCRUBBED_PC <= std_logic_vector(SCRUB_finalPC);
    --load
    rd_MEM <= '1' when OPCODE_s = "0000011" and ERROR_STALLS_s = '0' else '0';
    LOAD_FROM_MEM_SIZE <= funct3 when OPCODE_s = "0000011" else (others => '0'); --load byte/hw/w/u
    LOAD_FROM_MEM_ADDR <= std_logic_vector(signed(RS1_reg) + signed(I_imm)) 
                        when OPCODE_s = "0000011" else (others => '0');
    --------------------------------------------------------------------------------                    
    we_reg <= 
                    '1' when 
                    (OPCODE_s = "0110111" or OPCODE_s = "0010111"   -- LUI, AUIPC
                     or OPCODE_s = "1101111"                        -- JAL
                     or OPCODE_s = "1100111"                        -- JALR 
                     or OPCODE_s = "0000011"                          -- Loads from MEM
                     or OPCODE_s = "0010011"                         --ALUi
                     or OPCODE_s = "0110011"
                     or OPCODE_s = "1110011"                         --ALU
                     )  and ERROR_STALLS_s = '0'
                    else '0';
    --------------------------------------------------------------------------------                    
    Imm_to_reg <= U_imm when 
                    (OPCODE_s = "0110111") else   -- LUI, 
                  std_logic_vector((signed(U_imm) + pc_cnt1 - x"00000004")) when 
                    (OPCODE_s = "0010111") else   --AUIPC
                  std_logic_vector(PC_cnt1) when (OPCODE_s = "1101111" -- JAL,
                    or OPCODE_s = "1100111") -- JALR  
                    
                    else (others => '0');
    --------------------------------------------------------------------------------                
    to_reg_wr_select <= "001" when
                    (OPCODE_s = "0110111" or OPCODE_s = "0010111") else -- LUI, AUIPC
                    "011" when (OPCODE_s = "1101111" or OPCODE_s = "1100111") else -- JAL, JALR
                    "010" when (OPCODE_s = "0000011") else --Load from mem
                    "111" when (OPCODE_s = "1110011") -- CSR register
                    else (others => '0'); --ALU
    
    -------------------------------------------------------------------------------
    --CSR
    CSR_Addr(11 downto 0) <= I_imm(11 downto 0) when OPCODE_s = "1110011" else (others => '0');
    CSR_rd <= '1';
    CSR_we <= '1' when OPCODE_s = "1110011" and ERROR_STALLS_s = '0' else '0';
    
    --------------------------------------------------------------------------------                
    ALU_funct_select(2 downto 0) <= funct3 when OPCODE_s = "0010011" or OPCODE_s = "0110011" 
                                    else (others => '0');
    ALU_funct_select(3) <= I_imm(10) when 
                                    (OPCODE_s = "0010011" and funct3 = "001") or
                                    (OPCODE_s = "0010011" and funct3 = "101") or 
                                    (OPCODE_s = "0010011" and funct3 = "101") 
    
                                    or OPCODE_s = "0110011" 
                                    else '0';
    
    
    
    ALU_Imm <= I_imm when (OPCODE_s = "0010011") and 
    (
        funct3 = "000" or --ADDI 
        funct3 = "010" or --SLTI
        funct3 = "011" or --SLTIU
        funct3 = "100" or --XORI
        funct3 = "110" or --ORI
        funct3 = "111"    -- ANDI
        --funct3 = "001" or -- SLLI
        --funct3 = "101"  --   SRLI/SRAI
    ) else 
        shamt when (OPCODE_s = "0010011") and
    ( 
        funct3 = "001" or -- SLLI
        funct3 = "101"  --   SRLI/SRAI 
    ) else
    
    (others => '0');
    
    ALU_Imm_select <= '1' when (OPCODE_s = "0010011") and 
    (
        funct3 = "000" or --ADDI 
        funct3 = "010" or --SLTI
        funct3 = "011" or --SLTIU
        funct3 = "100" or --XORI
        funct3 = "110" or --ORI
        funct3 = "111" or -- ANDI;
        funct3 = "001" or -- SLLI
        funct3 = "101"  --   SRLI/SRAI
    ) else '0';           

    INSTR_DONE <= '1' when OPCODE_s = "0000000" else '0';
    UNKNOWN_INSTRUCTION <= '0' when 
                    OPCODE_s = "0110111" or                    
                    OPCODE_s = "0010111" or
                    OPCODE_s = "1101111" or
                   (OPCODE_s = "1100111" and funct3 = "000") or
                   -- BQ
                   (OPCODE_s = "1100011" and funct3 = "000") or
                   (OPCODE_s = "1100011" and funct3 = "001") or
                   (OPCODE_s = "1100011" and funct3 = "100") or
                   (OPCODE_s = "1100011" and funct3 = "101") or
                   (OPCODE_s = "1100011" and funct3 = "110") or
                   (OPCODE_s = "1100011" and funct3 = "111") or
                   -- loads
                   (OPCODE_s = "0000011" and funct3 = "000") or                    
                   (OPCODE_s = "0000011" and funct3 = "001") or
                   (OPCODE_s = "0000011" and funct3 = "010") or
                   (OPCODE_s = "0000011" and funct3 = "100") or
                   (OPCODE_s = "0000011" and funct3 = "101") or 
                    -- stores
                   (OPCODE_s = "0100011" and funct3 = "000") or
                   (OPCODE_s = "0100011" and funct3 = "001") or
                   (OPCODE_s = "0100011" and funct3 = "010") or                    

                    -- ALUi
                   (OPCODE_s = "0010011" and funct3 = "000") or
                   (OPCODE_s = "0010011" and funct3 = "010") or
                   (OPCODE_s = "0010011" and funct3 = "011") or
                   (OPCODE_s = "0010011" and funct3 = "100") or
                   (OPCODE_s = "0010011" and funct3 = "110") or
                   (OPCODE_s = "0010011" and funct3 = "111") or
                   (OPCODE_s = "0010011" and funct3 = "001"  and funct7 = "0000000") or
                   (OPCODE_s = "0010011" and funct3 = "101"  and funct7 = "0000000") or
                   (OPCODE_s = "0010011" and funct3 = "101"  and funct7 = "0100000") or 
                    -- ALU
                   (OPCODE_s = "0110011" and funct3 = "000"  and funct7 = "0000000") or
                   (OPCODE_s = "0110011" and funct3 = "000"  and funct7 = "0100000") or
                   (OPCODE_s = "0110011" and funct3 = "001"  and funct7 = "0000000") or
                   (OPCODE_s = "0110011" and funct3 = "010"  and funct7 = "0000000") or
                   (OPCODE_s = "0110011" and funct3 = "011"  and funct7 = "0000000") or
                   (OPCODE_s = "0110011" and funct3 = "100"  and funct7 = "0000000") or
                   (OPCODE_s = "0110011" and funct3 = "101"  and funct7 = "0000000") or
                   (OPCODE_s = "0110011" and funct3 = "101"  and funct7 = "0100000") or
                   (OPCODE_s = "0110011" and funct3 = "110"  and funct7 = "0000000") or
                   (OPCODE_s = "0110011" and funct3 = "111"  and funct7 = "0000000") or
                    -- CSR   
                   (OPCODE_s = "1110011" and funct3 = "001") or
                   (OPCODE_s = "1110011" and funct3 = "010") or
                   (OPCODE_s = "1110011" and funct3 = "011") 
                else '1';                    
    --internal IRQ            

    irq_int_p: process(clk)
    begin
        if(rising_edge(clk)) then
            if(clear = '1') then
                IRQ_int_running_s <= '0';
            else
                if(IRQ_int_running_software = '1') then
                    IRQ_int_running_s <= '1';
                else
                    IRQ_int_running_s <= '0';
                end if;            
            end if;
        end if;    
    end process;
                    
    PC_p : process(clk, clear)
    begin
        if(clear = '1') then
            PC_cnt1 <= PC_start;
            PC_cnt2 <= PC_start;
            PC_cnt3 <= PC_start;
            PC_out <= std_logic_vector(PC_start);
            PC_out_s <= std_logic_vector(PC_start);
            IRQ_return_addr <= (others => '0');
            set_scrub_flag <= '0';
            fatal_error_prss_running <= '0';
            start_scub_seq_counting <= '0';
            seq_counter <= 0;   
            SCRUB_finalPC <= (others => '0'); 
        elsif(rising_edge(clk)) then
            IRQ_int_begin_s <= '0';
        ---     
                if(FATAL_ERROR = '1') then
                    PC_out <= std_logic_vector(PC_scrub);
                    PC_out_s <= std_logic_vector(PC_scrub);  
                end if;
        
        
                if(START_CLOCK = '1') then
                    --buffering last 6 instructions
                    instruction_buffer(0) <= instruction_buffer(1);
                    instruction_buffer(1) <= instruction_buffer(2);
                    instruction_buffer(2) <= instruction_buffer(3);
                    instruction_buffer(3) <= instruction_buffer(4);
                    instruction_buffer(4) <= instruction_buffer(5);
                    instruction_buffer(5) <= instruction_buffer(6);
                    instruction_buffer(6) <= instruction_buffer(7);
                    instruction_buffer(7) <= PC_out_s;
                    -----------------------------------------------------------
                    --COUNTER
                    ------------------------------------------------------------------------------                     
                    --set the global SCRUB flag when the registers are saved into the
                    --scrub register
                    if(start_scub_seq_counting = '1') then
                        seq_counter <= seq_counter + 1;
                        if(seq_counter = 31) then
                            start_scub_seq_counting <= '0';
                            set_scrub_flag <= '1';
                        end if;
                    end if;
                    
                    if(IRQ_int = '1' and IRQ_int_running_software = '0' and ERROR_STALLS = '0') then --timer, internal IRQ
                        IRQ_return_addr <= PC_out_s;
                        PC_out <= IRQ_int_code; --where to jump for the interrupt
                        PC_out_s <= IRQ_int_code;                                     
                        PC_cnt1 <= to_integer(unsigned(IRQ_int_code)) + x"00000004";                   
                    elsif(IRQ_int_running_software = '0' and IRQ_int_begin_s = '0' 
                                    and IRQ_int_running_s = '1'  and ERROR_STALLS = '0') then   
                        PC_out <= IRQ_return_addr;
                        PC_cnt1 <= to_integer(unsigned(IRQ_return_addr)) + x"00000004";                    
                    elsif(ERROR_STALLS = '1' and FATAL_ERROR = '0') then --error checking in ALU and COMPARATORS
                        PC_out <= instruction_buffer(7);
                        PC_out_s <= instruction_buffer(7);                                          
                        PC_cnt1 <= to_integer(unsigned(instruction_buffer(7))) + x"00000004";   
                    elsif(FATAL_ERROR = '1' and fatal_error_prss_running = '0') then
                        SCRUB_finalPC <= signed(instruction_buffer(6));
                        
                        fatal_error_prss_running <= '1';
                        start_scub_seq_counting <= '1';
                        PC_out <= std_logic_vector(PC_scrub);
                        PC_out_s <= std_logic_vector(PC_scrub);                                  
                        PC_cnt1 <= PC_scrub + x"00000004";
                        
                    -- this isnt a real external interrupt, rather it's an SPI stall
                    elsif(IRQ_ext = '1' and IRQ_ext_code = x"00000001") then --screen and test SPIs STALLS
                        PC_out <= instruction_buffer(7) + x"00000004";
                        PC_out_s <= instruction_buffer(7);                                          
                        PC_cnt1 <= to_integer(unsigned(instruction_buffer(7))) + x"00000008"; 
                    -------------------------------------------------------------------------------
                    else
                        case OPCODE_s is
                            when "1101111" => --JAL
                                PC_out <= std_logic_vector(PC_cnt1 - x"00000004" + signed(J_imm));
                                PC_out_s <= std_logic_vector(PC_cnt1 - x"00000004" + signed(J_imm));
                                PC_cnt1 <= (PC_cnt1 + signed(J_imm));
                            when "1100111" => --JALR
                                PC_out <= std_logic_vector(signed(I_imm) + signed(JALR_reg_in));
                                PC_out_s <= std_logic_vector(signed(I_imm) + signed(JALR_reg_in));                        
                                PC_cnt1 <= (signed(I_imm) + signed(JALR_reg_in) + x"00000004");    
                            when "1100011" =>
                                case funct3 is
                                    when "000" =>
                                        if(BRANCH_FLAGS(0) = '1') then --BEQ
                                            PC_out <= std_logic_vector(PC_cnt1 - x"00000004" + signed(B_imm));
                                            PC_out_s <= std_logic_vector(PC_cnt1 - x"00000004" + signed(B_imm)); 
                                            PC_cnt1 <= (PC_cnt1 - x"00000004" + signed(B_imm) + x"00000004"); 
                                        else
                                            PC_out <= std_logic_vector(PC_cnt1);
                                            PC_out_s <= std_logic_vector(PC_cnt1);                                            
                                            PC_cnt1 <= PC_cnt1 + x"00000004";  
                                        end if;
                                    when "001" =>
                                        if(BRANCH_FLAGS(1) = '1') then --BNE
                                            PC_out <= std_logic_vector(PC_cnt1 - x"00000004" + signed(B_imm));
                                            PC_out_s <= std_logic_vector(PC_cnt1 - x"00000004" + signed(B_imm));
                                            PC_cnt1 <= (PC_cnt1 - x"00000004" + signed(B_imm) + x"00000004"); 
                                        else
                                            PC_out <= std_logic_vector(PC_cnt1);
                                            PC_out_s <= std_logic_vector(PC_cnt1);                                            
                                            PC_cnt1 <= PC_cnt1 + x"00000004";  
                                        end if;                               
                                    when "100" =>
                                        if(BRANCH_FLAGS(2) = '1') then --BLT
                                            PC_out <= std_logic_vector(PC_cnt1 - x"00000004" + signed(B_imm));
                                            PC_out_s <= std_logic_vector(PC_cnt1 - x"00000004" + signed(B_imm));
                                            PC_cnt1 <= (PC_cnt1 - x"00000004" + signed(B_imm) + x"00000004"); 
                                        else
                                            PC_out <= std_logic_vector(PC_cnt1);
                                            PC_out_s <= std_logic_vector(PC_cnt1);                                            
                                            PC_cnt1 <= PC_cnt1 + x"00000004";  
                                        end if;                               
                                    when "101" =>
                                        if(BRANCH_FLAGS(3) = '1') then --BGE
                                            PC_out <= std_logic_vector(PC_cnt1 - x"00000004" + signed(B_imm));
                                            PC_out_s <= std_logic_vector(PC_cnt1 - x"00000004" + signed(B_imm));
                                            PC_cnt1 <= (PC_cnt1 - x"00000004" + signed(B_imm) + x"00000004"); 
                                        else
                                            PC_out <= std_logic_vector(PC_cnt1);
                                            PC_out_s <= std_logic_vector(PC_cnt1);                                            
                                            PC_cnt1 <= PC_cnt1 + x"00000004";  
                                        end if;                               
                                    when "110" =>
                                        if(BRANCH_FLAGS(4) = '1') then --BLTU
                                            PC_out <= std_logic_vector(PC_cnt1 - x"00000004" + signed(B_imm));
                                            PC_out_s <= std_logic_vector(PC_cnt1 - x"00000004" + signed(B_imm));
                                            PC_cnt1 <= (PC_cnt1 - x"00000004" + signed(B_imm) + x"00000004"); 
                                        else
                                            PC_out <= std_logic_vector(PC_cnt1);
                                            PC_out_s <= std_logic_vector(PC_cnt1);                                            
                                            PC_cnt1 <= PC_cnt1 + x"00000004";  
                                        end if;  
                                    when "111" =>
                                        if(BRANCH_FLAGS(5) = '1') then --BGEU
                                            PC_out <= std_logic_vector(PC_cnt1 - x"00000004" + signed(B_imm));
                                            PC_out_s <= std_logic_vector(PC_cnt1 - x"00000004" + signed(B_imm));
                                            PC_cnt1 <= (PC_cnt1 - x"00000004" + signed(B_imm) + x"00000004"); 
                                        else
                                            PC_out <= std_logic_vector(PC_cnt1);
                                            PC_out_s <= std_logic_vector(PC_cnt1);                                            
                                            PC_cnt1 <= PC_cnt1 + x"00000004";  
                                        end if;  
                                    when others =>
                                        PC_out <= std_logic_vector(PC_cnt1);
                                        PC_out_s <= std_logic_vector(PC_cnt1);                                            
                                        PC_cnt1 <= PC_cnt1 + x"00000004";                                
                                end case;
                            when others =>
                                PC_out <= std_logic_vector(PC_cnt1);
                                PC_out_s <= std_logic_vector(PC_cnt1);                                            
                                PC_cnt1 <= PC_cnt1 + x"00000004";           
                        end case;          
                    end if;
                end if;
            end if;
    end process;
    -- states of the processor
    states_p: process(clk)
    begin
        if(rising_edge(clk)) then
            if(clear = '1') then
                STATES <= "000001";
                START_CLOCK <= '0';
                which_XR_to_reuse <= (others => '0');
                load_registers <= '0';      
                ERROR_STALLS_s <= '0';
                SCRUB <= '0';
            else
            -----
                load_registers <= '0';
                which_XR_to_reuse <= "000";
                SCRUB <= '0';
                case STATES is
                    when "000001" => --IDLE 
                        START_CLOCK <= '0';
                        if(START = '1') then
                            STATES <= "000010";
                        else
                            STATES <= "000001";
                        end if;
                    when "000010" => --RUN
                        if(ERROR_STALLS = '1' and FATAL_ERROR = '0') then
                            START_CLOCK <= '0';
                            load_registers <= '1'; --reload register from previous instruction, so data wont be lost
                            which_XR_to_reuse <= "110"; --use the saved register from previous instruction
                            ERROR_STALLS_s <= '1';
                        
                        ------------------- PSEUDO IRQ --- for screen stalls
                        elsif(IRQ_ext = '1' and IRQ_ext_code = x"00000001") then
                            START_CLOCK <= '0';
                            load_registers <= '0'; --reload register from previous instruction, so data wont be lost
                            which_XR_to_reuse <= "110"; --use the saved register from previous instruction
                            ERROR_STALLS_s <= '1';
                        -------------------------------------------------------
                        elsif(FATAL_ERROR = '1') then
                            STATES <= "000100";
                            START_CLOCK <= '0';
                            load_registers <= '1'; --reload register from previous instruction, so data wont be lost
                            which_XR_to_reuse <= "110"; --use the saved register from previous instruction
                            ERROR_STALLS_s <= '1';
                        elsif(UNKNOWN_INSTRUCTION = '1') then
                            STATES <= "100000";     
                        elsif(INSTR_DONE = '1') then
                            STATES <= "100000";  
                        else
                            START_CLOCK <= '1'; -- keep running
                            ERROR_STALLS_s <= '0';
                        end if;
                    when "000100" => --FATAL_ERROR!
                        START_CLOCK <= '1'; -- keep running
                        ERROR_STALLS_s <= '0';
                        load_registers <= '0';
                        which_XR_to_reuse <= "000";
                        if(set_scrub_flag = '1') then
                            STATES <= "001000";
                        end if;
                    when "001000" => --SCRUB
                        SCRUB <= '1';
                        START_CLOCK <= '0';
                        STATES <= "001000";
                        if(INSTR_DONE = '1') then
                            STATES <= "100000"; 
                        end if;
                    when "010000" => -- 
                        STATES <= "010000";
                    when "100000" =>   -- the end
                        START_CLOCK <= '0';
                        STATES <= "100000";                        
                    when others =>
                        STATES <= "000010";
                end case;
            end if;
        end if;
    end process;
end RTL;