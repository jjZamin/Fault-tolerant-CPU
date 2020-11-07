library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED.all;

entity MUX_rMEMsize is
              Port ( 
                        rMEM_in : in std_logic_vector(31 downto 0);
                        wReg_out : out std_logic_vector(31 downto 0);
                        rMEM_size : in std_logic_vector(2 downto 0); 

                        rReg_in : in std_logic_vector(31 downto 0);
                        wMEM_out : out std_logic_vector(31 downto 0);
                        wMEM_size : in std_logic_vector(2 downto 0);
                        
                        o_wMEM_size : out std_logic_vector(1 downto 0)                        
              );
end MUX_rMEMsize;

architecture RTL of MUX_rMEMsize is
begin
        
        wMem: process(wMEM_size, rReg_in)
        begin
            case wMEM_size is
                when "000" => --SB
                    o_wMEM_size <= "00";
                    wMEM_out(7 downto 0) <= rReg_in(7 downto 0);
                    wMEM_out(31 downto 8) <= (others => '0');
                when "001" => --SH
                    o_wMEM_size <= "01";
                    wMEM_out(15 downto 0) <= rReg_in(15 downto 0);
                    wMEM_out(31 downto 16) <= (others => '0');   
                when "010" => --SW
                    o_wMEM_size <= "10";
                    wMEM_out <= rReg_in;
                when others =>
                    o_wMEM_size <= "00";
                    wMEM_out <= (others => '0');                
            end case;
        end process;

        rMem: process(rMEM_size, rMEM_in)
        begin
            case rMEM_size is
                when "000" => --LB
                    wReg_out(7 downto 0) <= rMEM_in(7 downto 0);
                        case rMEM_in(7) is
                            when '1' =>
                                wReg_out(31 downto 8) <= (others => '1');
                            when others =>
                                wReg_out(31 downto 8) <= (others => '0');                                          
                        end case;
                when "001" => --LH
                    wReg_out(15 downto 0) <= rMEM_in(15 downto 0);
                        case rMEM_in(15) is
                            when '1' =>
                                wReg_out(31 downto 16) <= (others => '1'); 
                            when others =>
                                wReg_out(31 downto 16) <= (others => '0');                                         
                        end case;                    

               when "010" => --LW
                    wReg_out <= rMEM_in;
                    
               when "100" => --LBU
                    wReg_out(7 downto 0) <= rMEM_in(7 downto 0);
                    wReg_out(31 downto 8) <= (others => '0');
               when "101" => --LHU
                    wReg_out(15 downto 0) <= rMEM_in(15 downto 0);
                    wReg_out(31 downto 16) <= (others => '0');                                    
               when others =>
                    wReg_out <= (others => '0');                
            end case;            
        end process;
end RTL;
