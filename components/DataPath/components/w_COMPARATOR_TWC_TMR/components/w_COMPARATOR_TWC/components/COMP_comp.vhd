library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED.all;

entity COMP_comp is
     Port ( 
            Res_MOD1 : in std_logic_vector(5 downto 0);
            Res_MOD2 : in std_logic_vector(5 downto 0);
            Res_MOD3 : in std_logic_vector(5 downto 0);
            
            COMP_TMR_DISABLED : in std_logic;
            MODS_OFF : in std_logic_vector(17 downto 0); -- 6 comps * 3 mods
            TEST_ON : in std_logic;
            
            funct : in std_logic_vector(3 downto 0);
            ERROR : out std_logic;
            COMP_RESULT : out std_logic_vector(5 downto 0)   
     );
end COMP_comp;

architecture RTL of COMP_comp is

    procedure COMPARE(    
                       signal MOD1 : in std_logic_vector(5 downto 0);
                       signal MOD2 : in std_logic_vector(5 downto 0);
                       signal MOD3 : in std_logic_vector(5 downto 0);                       
                       signal MODS_off : in std_logic_vector(2 downto 0);
                       signal TEST_ON_s : in std_logic;
                       signal DATA_OUT : out std_logic_vector(5 downto 0);
                       signal BRNCH_ERROR : out std_logic
                            ) is
    begin  
        BRNCH_ERROR <= '0';
        DATA_OUT <= (others => '0');
        case MODS_off is
            when "000" =>
                BRNCH_ERROR <= '0';
                if(MOD1 = MOD2 and MOD1 = MOD3) then
                    DATA_OUT <= MOD1;
                    BRNCH_ERROR <= '0';
                else

                    BRNCH_ERROR <= '0';
                    if(TEST_ON_s = '0') then
                        BRNCH_ERROR <= '1';
                        DATA_OUT <= MOD1;
                    else
                        BRNCH_ERROR <= '0';
                    end if;
                end if; 
            when "001" =>
                BRNCH_ERROR <= '0';
                if(MOD2 = MOD3) then
                    DATA_OUT <= MOD2;
                    BRNCH_ERROR <= '0';                    
                else

                    BRNCH_ERROR <= '0';
                    if(TEST_ON_s = '0') then
                        DATA_OUT <= MOD2;                    
                        BRNCH_ERROR <= '1';
                    else
                        BRNCH_ERROR <= '0';
                    end if;
                end if; 
            when "010" =>
                BRNCH_ERROR <= '0';
                if(MOD1 = MOD3) then
                    DATA_OUT <= MOD1;
                    BRNCH_ERROR <= '0';
                else

                    BRNCH_ERROR <= '0';
                    if(TEST_ON_s = '0') then
                        BRNCH_ERROR <= '1';
                        DATA_OUT <= MOD1;
                    else
                        BRNCH_ERROR <= '0';
                    end if;
                end if; 
            when "011" =>
                DATA_OUT <= MOD3;
                BRNCH_ERROR <= '0';
            when "100" =>
                BRNCH_ERROR <= '0';
                if(MOD1 = MOD2) then
                    DATA_OUT <= MOD1;
                    BRNCH_ERROR <= '0';
                else
                    
                    BRNCH_ERROR <= '0';
                    if(TEST_ON_s = '0') then
                        BRNCH_ERROR <= '1';
                        DATA_OUT <= MOD3;
                    else
                        BRNCH_ERROR <= '0';
                    end if;
                end if;             
            when "101" =>
                DATA_OUT <= MOD2;
                BRNCH_ERROR <= '0';
            when "110" =>
                DATA_OUT <= MOD1;
                BRNCH_ERROR <= '0';
            when others =>
                DATA_OUT <= (others => '0');
                BRNCH_ERROR <= '0';
        end case;
    end procedure;
begin

    comp: process(COMP_TMR_DISABLED, MODS_OFF, TEST_ON, Res_MOD1, Res_MOD2, Res_MOD3, funct)
    begin 
        if(COMP_TMR_DISABLED = '1') then
            COMP_RESULT <= Res_MOD1;     
            ERROR <= '0';
        else
            case funct is
                when "0000" => -- bEQ
                    COMPARE(Res_MOD1, Res_MOD2, Res_MOD3, MODS_OFF(2 downto 0), TEST_ON, COMP_RESULT, ERROR);
                when "1111" => -- bNE
                    COMPARE(Res_MOD1, Res_MOD2, Res_MOD3, MODS_OFF(5 downto 3), TEST_ON, COMP_RESULT, ERROR);
                when "1001" => -- bLT
                    COMPARE(Res_MOD1, Res_MOD2, Res_MOD3, MODS_OFF(8 downto 6), TEST_ON,  COMP_RESULT, ERROR);
                when "1010" => -- bGE
                    COMPARE(Res_MOD1, Res_MOD2, Res_MOD3, MODS_OFF(11 downto 9), TEST_ON,  COMP_RESULT, ERROR);
                when "0001" => -- bLTU
                    COMPARE(Res_MOD1, Res_MOD2, Res_MOD3, MODS_OFF(14 downto 12), TEST_ON, COMP_RESULT, ERROR);                     
                when "0010" => -- bGEU
                    COMPARE(Res_MOD1, Res_MOD2, Res_MOD3, MODS_OFF(17 downto 15), TEST_ON, COMP_RESULT, ERROR);
                when others =>
                    COMP_RESULT <= (others => '0');
                    ERROR <= '0';
            end case;
        end if;
    end process;
end RTL;
