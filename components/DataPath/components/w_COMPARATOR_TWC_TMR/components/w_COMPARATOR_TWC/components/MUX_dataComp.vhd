library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED.all;

-- By Ghennadie Mazin

entity MUX_DataComp is
  generic (
            DATA_WIDTH : natural := 32  
            );
  Port ( 
            A_in : in std_Logic_vector(DATA_WIDTH - 1 downto 0);  
            B_in : in std_Logic_vector(DATA_WIDTH - 1 downto 0);  
                        
            At_in : in std_logic_vector(DATA_WIDTH - 1 downto 0);
            Bt_in : in std_logic_vector(DATA_WIDTH - 1 downto 0);
            TEST_ON : in std_logic;
            
            A_data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0);
            B_data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0)
            );
end MUX_DataComp;

architecture RTL of MUX_DataComp is

begin
    A_data_out <= A_in when TEST_ON = '0' 
                  else 
                  At_in;
    
    B_data_out <= B_in when TEST_ON = '0'
                  else
                  Bt_in;

end RTL;
