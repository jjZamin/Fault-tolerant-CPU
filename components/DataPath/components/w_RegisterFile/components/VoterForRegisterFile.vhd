library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.RegisterFile_pkg.all;

entity VoterForRegisterFile is
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
end VoterForRegisterFile;

architecture RTL of VoterForRegisterFile is  
    
begin
    
    RegA_out <= InRegA1 when 
                        ((InRegA1 = InRegA2 and InRegA1 = InRegA3) or 
                        (InRegA1 = InRegA2 and InRegA1 /= InRegA3) or
                        (InRegA1 = InRegA3 and InRegA1 /= InRegA2)) and DISABLE_RegFileVoter = '0' else
                InRegA2 when (InRegA2 = InRegA3 and InRegA1 /= InRegA2) and DISABLE_RegFileVoter = '0' else
                InRegA1;
    RegB_out <= InRegB1 when 
                        ((InRegB1 = InRegB2 and InRegB1 = InRegB3) or 
                        (InRegB1 = InRegB2 and InRegB1 /= InRegB3) or
                        (InRegB1 = InRegB3 and InRegB1 /= InRegB2)) and DISABLE_RegFileVoter = '0' else
                InRegB2 when (InRegB2 = InRegB3 and InRegB1 /= InRegB2) and DISABLE_RegFileVoter = '0' else
                InRegB1;
    
    RegFileVoterData_ERROR <= '1' when 
                              ((InRegA1 /= InRegA2 and InRegA1 /= InRegA3 and InRegA2 /= InRegA3) 
                                and DISABLE_RegFileVoter = '0') or
                              ((InRegB1 /= InRegB2 and InRegB1 /= InRegB3 and InRegB2 /= InRegB3) 
                                and DISABLE_RegFileVoter = '0') else
                              '0';
    RegFileVoter_isDisabled <= DISABLE_RegFileVoter;
end RTL;
