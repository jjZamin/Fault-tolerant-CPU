library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.RegisterFile_pkg.all;

package RegFileVoters_pkg is

component VoterForRegisterFile is
    Port ( 
        InRegA1 : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        InRegA2 : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        InRegA3 : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        InRegB1 : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        InRegB2 : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        InRegB3 : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        RegA_out: out std_logic_vector(DATA_WIDTH - 1 downto 0);
        RegB_out: out std_logic_vector(DATA_WIDTH - 1 downto 0);
        RegFileVoterData_ERROR : out std_logic := '0'; --error occurs when all three inputs are different and parity checker can't determain the winner
        DISABLE_RegFileVoter : in std_logic := '0';
        RegFileVoter_isDisabled : out std_logic
    );
end component;

component RegFileOutputMux is
  Port ( 
        clk : in std_logic;
        clear : in std_logic;
        PureRegA : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        PureRegB : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        InputAv1 : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        InputAv2 : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        InputAv3 : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        InputBv1 : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        InputBv2 : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        InputBv3 : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        Voter_ERROR_flag : in std_logic_vector(2 downto 0);
        FinalRegOutputA : out std_logic_vector(DATA_WIDTH - 1 downto 0);
        FinalRegOutputB : out std_logic_vector(DATA_WIDTH - 1 downto 0);
        DisableVoter : out std_logic_vector(2 downto 0);
        Disable_TMR : in std_logic
  );
end component;




end RegFileVoters_pkg;