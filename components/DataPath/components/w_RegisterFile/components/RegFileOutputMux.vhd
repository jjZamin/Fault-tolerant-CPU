
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.STD_LOGIC_UNSIGNED.all;
use work.RegisterFile_pkg.all;

--****************
-- By Ghennadie Mazin, final project.
--****************

entity RegFileOutputMux is
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
        DisableVoter : out std_logic_vector(2 downto 0);
        FinalRegOutputA : out std_logic_vector(DATA_WIDTH - 1 downto 0);
        FinalRegOutputB : out std_logic_vector(DATA_WIDTH - 1 downto 0);
        
        Voter_ERROR_flag : in std_logic_vector(2 downto 0);
        Disable_TMR : in std_logic
  );
end RegFileOutputMux;

architecture RTL of RegFileOutputMux is

signal VoterIsDisabled : std_logic_vector(2 downto 0);
signal V1_error_count : integer := 0;
signal V2_error_count : integer := 0;
signal V3_error_count : integer := 0;
signal nr_of_errors_allowed : integer := 20;

begin

    error_count: process(clk)
    begin
        if(rising_edge(clk)) then
            if(clear = '1') then
                V1_error_count <= 0;
                V2_error_count <= 0;
                V3_error_count <= 0;
                VoterIsDisabled <= (others => '0');
            else
                if(Voter_ERROR_flag(0) = '1') then -- VOTER 1 sends an errors
                    V1_error_count <= V1_error_count + 1;
                elsif(Voter_ERROR_flag(1) = '1') then -- VOTER 2 sends an errors
                    V2_error_count <= V2_error_count + 1;
                elsif(Voter_ERROR_flag(2) = '1') then -- VOTER 3 sends an errors
                    V3_error_count <= V3_error_count + 1;
                end if;
                
                if(V1_error_count > nr_of_errors_allowed) then
                    VoterIsDisabled(0) <= '1';
                elsif(V2_error_count > nr_of_errors_allowed) then
                    VoterIsDisabled(1) <= '1';
                elsif(V3_error_count > nr_of_errors_allowed) then
                    VoterIsDisabled(2) <= '1';
                end if;
            end if;
        end if;
    end process;

    FinalRegOutputA <= InputAv1 when 
                       (
                            VoterIsDisabled = "000" or
                            VoterIsDisabled = "010" or
                            VoterIsDisabled = "100" or
                            VoterIsDisabled = "110"
                       ) and Disable_TMR = '0' else
                       
                       InputAv2 when 
                       (
                            VoterIsDisabled = "001" or
                            VoterIsDisabled = "100" or
                            VoterIsDisabled = "101"
                       ) and Disable_TMR = '0' else

                       InputAv3 when 
                       (
                            VoterIsDisabled = "001" or
                            VoterIsDisabled = "010" or
                            VoterIsDisabled = "011"
                       ) and Disable_TMR = '0' else
                       
                       PureRegA when VoterIsDisabled = "111" and Disable_TMR = '0' else
                       PureRegA when Disable_TMR = '1' else
                       PureRegA;
                       
    FinalRegOutputB <= InputBv1 when 
                       (
                            VoterIsDisabled = "000" or
                            VoterIsDisabled = "010" or
                            VoterIsDisabled = "100" or
                            VoterIsDisabled = "110"
                       ) and Disable_TMR = '0' else
                       
                       InputBv2 when 
                       (
                            VoterIsDisabled = "001" or
                            VoterIsDisabled = "100" or
                            VoterIsDisabled = "101"
                       ) and Disable_TMR = '0' else

                       InputBv3 when 
                       (
                            VoterIsDisabled = "001" or
                            VoterIsDisabled = "010" or
                            VoterIsDisabled = "011"
                       ) and Disable_TMR = '0' else
                       
                       PureRegB when VoterIsDisabled = "111" and Disable_TMR = '0' else
                       PureRegB when Disable_TMR = '1' else
                       PureRegB;                            
    DisableVoter <= VoterIsDisabled;
end RTL;
