library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.RegFileVoters_pkg.all;
use work.xR7_pkg.all;

--****************
-- By Ghennadie mazin, final project.
--****************

entity RegisterFile is
  generic (
        DATA_WIDTH : integer := 32;
        REGISTERFILE_ADDR_WIDTH : integer := 5;
        NUMBER_OF_REGS: integer := 32
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
        
        isb_rDataReg1 : out std_logic_vector(DATA_WIDTH - 1 downto 0); 
        isb_rDataReg2 : out std_logic_vector(DATA_WIDTH - 1 downto 0); 

        xRn_STOP_CLOCK : in std_logic;
        xRn_load_to_regfile : in std_logic;
        load_from_xRn_addr : in std_logic_vector(2 downto 0);

        -- Errors and TMR ON/OFF
        isVoter_OFF : out std_logic_vector(2 downto 0);
        DISABLE_RegisterFileTMR : in std_logic; --enables TMR
        RegisterFileTMR_isDISABLED : out std_logic --enabled TMR?
  );
end RegisterFile;

architecture RTL of RegisterFile is

    attribute dont_touch : string;

    signal tmrRegisters1 : REG_TYPE := ((others => (others => '0')));
    signal tmrRegisters2 : REG_TYPE := ((others => (others => '0')));
    signal tmrRegisters3 : REG_TYPE := ((others => (others => '0')));

    -- UNTOUCHABLES, software doesn't remove the redundancy
    attribute dont_touch of tmrRegisters1 : signal is "true";
    attribute dont_touch of tmrRegisters2 : signal is "true";
    attribute dont_touch of tmrRegisters3 : signal is "true";

    signal Reg1ReadA : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal Reg1ReadB : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal Reg2ReadA : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal Reg2ReadB : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal Reg3ReadA : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal Reg3ReadB : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');

    signal voter_input_RA1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal voter_input_RA2 : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal voter_input_RA3 : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal voter_input_RB1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal voter_input_RB2 : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal voter_input_RB3 : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');

    signal voter1_OutputA :  std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal voter1_OutputB :  std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal voter2_OutputA :  std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal voter2_OutputB :  std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal voter3_OutputA :  std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal voter3_OutputB :  std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');

    signal disableVoter_s : std_logic_vector(2 downto 0);
    signal Voter_ERROR_flag_s : std_logic_vector(2 downto 0);
 
      signal xRn_regFile_s :  REG_TYPE := ((others => (others => '0')));
      signal regFile_to_xRN_s :  REG_TYPE := ((others => (others => '0')));    

    
begin
    RegisterFileTMR_isDISABLED <= DISABLE_RegisterFileTMR;
    -- REGISTER WRITE
    RegisterWrite: process(clk, clear)
    begin
        if(clear = '1') then
            tmrRegisters1 <= ((others => (others => '0')));
            tmrRegisters2 <= ((others => (others => '0')));
            tmrRegisters3 <= ((others => (others => '0')));        
        
        elsif(rising_edge(clk)) then
            if(DISABLE_RegisterFileTMR = '1') then
                tmrRegisters2 <= ((others => (others => '0')));
                tmrRegisters3 <= ((others => (others => '0')));
            end if;

            if(isb_we = '1' and DISABLE_RegisterFileTMR = '0') then
                if(isb_wReg_addr /= "00000") then
                    tmrRegisters1(to_integer(unsigned(isb_wReg_addr))) <= isb_wData;
                    tmrRegisters2(to_integer(unsigned(isb_wReg_addr))) <= isb_wData;
                    tmrRegisters3(to_integer(unsigned(isb_wReg_addr))) <= isb_wData;
                    tmrRegisters1(0) <= (others => '0');
                    tmrRegisters2(0) <= (others => '0');
                    tmrRegisters3(0) <= (others => '0');
                else
                    tmrRegisters1(0) <= (others => '0');
                    tmrRegisters2(0) <= (others => '0');
                    tmrRegisters3(0) <= (others => '0');
                end if;
            elsif(isb_we = '1' and DISABLE_RegisterFileTMR = '1') then --TMR is off
                if(isb_wReg_addr /= "00000") then
                    tmrRegisters1(to_integer(unsigned(isb_wReg_addr))) <= isb_wData;
                    tmrRegisters1(0) <= (others => '0');
                else
                    tmrRegisters1(0) <= (others => '0');
                end if;
            elsif(xRn_load_to_regfile = '1' and isb_we = '0') then
                tmrRegisters1 <= xRn_regFile_s;
                tmrRegisters2 <= xRn_regFile_s;
                tmrRegisters3 <= xRn_regFile_s;
            end if; 
        end if;
    end process;
    regFile_to_xRN_s <= tmrRegisters1; --write to xR7
    
    -- register read
    Reg1ReadA <= tmrRegisters1(to_integer(unsigned(isb_rRegA_addr))) when isb_re = '1' else (others => '0');
    Reg1ReadB <= tmrRegisters1(to_integer(unsigned(isb_rRegB_addr))) when isb_re = '1' else (others => '0');
    Reg2ReadA <= tmrRegisters2(to_integer(unsigned(isb_rRegA_addr))) when isb_re = '1' else (others => '0');
    Reg2ReadB <= tmrRegisters2(to_integer(unsigned(isb_rRegB_addr))) when isb_re = '1' else (others => '0');
    Reg3ReadA <= tmrRegisters3(to_integer(unsigned(isb_rRegA_addr))) when isb_re = '1' else (others => '0');
    Reg3ReadB <= tmrRegisters3(to_integer(unsigned(isb_rRegB_addr))) when isb_re = '1' else (others => '0');


    --VOTERS PORT MAP
    Voter1_pm: VoterForRegisterFile port map (
        InRegA1 => Reg1ReadA,
        InRegA2 => Reg2ReadA,  
        InRegA3 => Reg3ReadA,  
        InRegB1 => Reg1ReadB, 
        InRegB2 => Reg2ReadB,  
        InRegB3 => Reg3ReadB,   
        RegA_out => voter1_OutputA,
        RegB_out => voter1_OutputB,

        RegFileVoterData_ERROR => Voter_ERROR_flag_s(0),
        DISABLE_RegFileVoter => disableVoter_s(0),
        RegFileVoter_isDisabled => isVoter_OFF(0)
    );
    Voter2_pm: VoterForRegisterFile port map (
        InRegA1 => Reg1ReadA,
        InRegA2 => Reg2ReadA,
        InRegA3 => Reg3ReadA,
        InRegB1 => Reg1ReadB,
        InRegB2 => Reg2ReadB,
        InRegB3 => Reg3ReadB,
        RegA_out => voter2_OutputA,
        RegB_out => voter2_OutputB,

        RegFileVoterData_ERROR => Voter_ERROR_flag_s(1),
        DISABLE_RegFileVoter => disableVoter_s(1),
        RegFileVoter_isDisabled => isVoter_OFF(1)
    );
   Voter3_pm: VoterForRegisterFile port map (
        InRegA1 => Reg1ReadA,
        InRegA2 => Reg2ReadA,
        InRegA3 => Reg3ReadA,
        InRegB1 => Reg1ReadB,
        InRegB2 => Reg2ReadB,
        InRegB3 => Reg3ReadB,
        RegA_out => voter3_OutputA,
        RegB_out => voter3_OutputB,

        RegFileVoterData_ERROR => Voter_ERROR_flag_s(2),
        DISABLE_RegFileVoter => disableVoter_s(2),
        RegFileVoter_isDisabled => isVoter_OFF(2)
    );

  OutPutMUX: RegFileOutputMux Port map (
        clk => clk,
        clear => clear,
        PureRegA => Reg1ReadA,
        PureRegB => Reg1ReadB,
        InputAv1 => voter1_OutputA,
        InputAv2 => voter2_OutputA,
        InputAv3 => voter3_OutputA,
        InputBv1 => voter1_OutputB,
        InputBv2 => voter2_OutputB,
        InputBv3 => voter3_OutputB,
        DisableVoter => disableVoter_s,
        Voter_ERROR_flag => Voter_ERROR_flag_s,
        FinalRegOutputA => isb_rDataReg1,
        FinalRegOutputB => isb_rDataReg2,
        Disable_TMR => DISABLE_RegisterFileTMR
  );
  
xR7x : xR7 
        generic map(
                DATA_WIDTH => DATA_WIDTH        
        )

        Port map ( 
                clk => clk,
                clear => clear,
                ---
                STOP_CLOCK => xRn_STOP_CLOCK,
                load_to_regfile => xRn_load_to_regfile,
                load_from_xRn_addr => load_from_xRn_addr,
                
                Reg_File_In => regFile_to_xRN_s,
                xRn_to_regfile => xRn_regFile_s
        );  
  
  
end RTL;
