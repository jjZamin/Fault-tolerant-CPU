library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity error_control is
              Port ( 
                            clk : in std_logic;
                            clear : in std_logic;
                            
                            MODs_OFF_COMPARATOR1 : in std_logic_vector(17 downto 0);
                            MODs_OFF_COMPARATOR2 : in std_logic_vector(17 downto 0);
                            MODs_OFF_COMPARATOR3 : in std_logic_vector(17 downto 0);                        
                            MODs_OFF_ALU1 : in std_logic_vector(29 downto 0);
                            MODs_OFF_ALU2 : in std_logic_vector(29 downto 0);
                            MODs_OFF_ALU3 : in std_logic_vector(29 downto 0); 
                            ALU_TMR_ERROR : in std_logic;
                            FATAL_ERROR : out std_logic
              
              );
end error_control;

architecture Behavioral of error_control is

signal alu_tmr_err_counter : natural := 0;

begin

    fatalerror: process(clk)
    begin
        if(rising_edge(clk)) then
            if(clear = '1') then
                alu_tmr_err_counter <= 0;
                FATAL_ERROR <= '0';                        
            else
                if(ALU_TMR_ERROR = '1') then
                    alu_tmr_err_counter <= alu_tmr_err_counter + 1;
                end if;
                
                if(alu_tmr_err_counter = 4 or
                    MODs_OFF_COMPARATOR1 = "000000000000000001" or
                    MODs_OFF_COMPARATOR2 = "000010000000000000" or
                    MODs_OFF_COMPARATOR3 = "000000000001000000" or
                    MODs_OFF_ALU1 = "000000001000000000000001001000" or 
                    MODs_OFF_ALU2 = "000100000000000000100000000000" or
                    MODs_OFF_ALU3 = "000001000000000000001000000000") then

                        FATAL_ERROR <= '1';
                else
                        FATAL_ERROR <= '0';                 
                end if;
            end if;        
        end if;
    end process;
end Behavioral;
