library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED.all;

entity MUX_wrReg is
          Port ( 
                    Control_Imm : in std_logic_vector(31 downto 0);
                    ALU_result : in std_logic_vector(31 downto 0);
                    MEM_read : in std_logic_vector(31 downto 0);
                    CSR_read : in std_logic_vector(31 downto 0);
                    to_reg_wr_select : in std_logic_vector(2 downto 0);
                    
                    wr_to_reg : out std_logic_vector(31 downto 0)           
          );
end MUX_wrReg;

architecture Behavioral of MUX_wrReg is

begin
    wr_to_reg <= Control_imm when (to_reg_wr_select = "001" or to_reg_wr_select = "011") else
                 MEM_read when (to_reg_wr_select = "010") else
                 CSR_read when (to_reg_wr_select = "111") 
                 else ALU_result;

end Behavioral;
