library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED.all;

-- By Ghennadie Mazin

entity MUX_functComp is
  Port ( 
            functInstr_in : in std_logic_vector(3 downto 0);
            functTest_in : in std_logic_vector(3 downto 0);
            TEST_ON : in std_logic;
            funct_out : out std_logic_vector(3 downto 0)            
            );
end MUX_functComp;

architecture RTL of MUX_functComp is

begin
    funct_out <= functInstr_in when TEST_ON = '0' else functTest_in;
end RTL;
