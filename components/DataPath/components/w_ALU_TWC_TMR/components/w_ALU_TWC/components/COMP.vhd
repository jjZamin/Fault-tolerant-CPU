library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED.all;

-- by Ghennadie Mazin

entity COMP is
  generic (
            DATA_WIDTH : natural := 32
  );
  Port ( 
            Res_MOD1 : in std_logic_vector(DATA_WIDTH - 1 downto 0);
            Res_MOD2 : in std_logic_vector(DATA_WIDTH - 1 downto 0);
            Res_MOD3 : in std_logic_vector(DATA_WIDTH - 1 downto 0);
            
            ALU_TMR_DISABLED : in std_logic;
            MODS_OFF : in std_logic_vector(29 downto 0);
            TEST_ON : in std_logic;
            
            funct : in std_logic_vector(3 downto 0);
                        
            ERROR : out std_logic;
            ALU_RESULT : out std_logic_vector(DATA_WIDTH - 1 downto 0)            
  );


end COMP;

architecture RTL of COMP is

    procedure COMPARE(    
                       signal MOD1 : in std_logic_vector(DATA_WIDTH - 1 downto 0);
                       signal MOD2 : in std_logic_vector(DATA_WIDTH - 1 downto 0);
                       signal MOD3 : in std_logic_vector(DATA_WIDTH - 1 downto 0);                       
                       signal MODS_off : in std_logic_vector(2 downto 0);
                       signal TEST_ON_s : in std_logic;
                       signal DATA_OUT : out std_logic_vector(DATA_WIDTH - 1 downto 0);
                       signal alu_ERROR : out std_logic
                            ) is
    begin  
        alu_ERROR <= '0';
        DATA_OUT <= (others => '0');

        case MODS_off is
            when "000" =>
                alu_ERROR <= '0';
                if(MOD1 = MOD2 and MOD1 = MOD3) then
                    DATA_OUT <= MOD1;
                    alu_ERROR <= '0';
                else
                    alu_ERROR <= '0';
                    if(TEST_ON_s = '0') then
                        alu_ERROR <= '1';
                        DATA_OUT <= MOD1;
                    else
                        alu_ERROR <= '0';
                    end if;
                end if; 
            when "001" =>
                alu_ERROR <= '0';
                if(MOD2 = MOD3) then
                    DATA_OUT <= MOD2;
                    alu_ERROR <= '0';                    
                else
                    alu_ERROR <= '0';
                    if(TEST_ON_s = '0') then
                        alu_ERROR <= '1';
                        DATA_OUT <= MOD2;
                    else
                        alu_ERROR <= '0';
                    end if;
                end if; 
            when "010" =>
                alu_ERROR <= '0';
                if(MOD1 = MOD3) then
                    DATA_OUT <= MOD1;
                    alu_ERROR <= '0';
                else
                    alu_ERROR <= '0';
                    if(TEST_ON_s = '0') then
                        alu_ERROR <= '1';
                        DATA_OUT <= MOD1;
                    else
                        alu_ERROR <= '0';
                    end if;
                end if; 
            when "011" =>
                DATA_OUT <= MOD3;
                alu_ERROR <= '0';
            when "100" =>
                alu_ERROR <= '0';
                if(MOD1 = MOD2) then
                    DATA_OUT <= MOD1;
                    alu_ERROR <= '0';
                else
                    alu_ERROR <= '0';
                    if(TEST_ON_s = '0') then
                        DATA_OUT <= MOD1;
                        alu_ERROR <= '1';
                    else
                        alu_ERROR <= '0';
                    end if;
                end if;             
            when "101" =>
                DATA_OUT <= MOD2;
                alu_ERROR <= '0';
            when "110" =>
                DATA_OUT <= MOD1;
                alu_ERROR <= '0';
            when others =>
                DATA_OUT <= (others => '0');
                alu_ERROR <= '0';
        end case;
    end procedure;
begin

    compr: process(MODS_OFF, TEST_ON, Res_MOD1, Res_MOD2, Res_MOD3, ALU_TMR_DISABLED, funct)
    begin
        if(ALU_TMR_DISABLED = '1') then
            ALU_RESULT <= Res_MOD1;     
            ERROR <= '0';
        else
            case funct is
                when "0000" => -- add
                    COMPARE(Res_MOD1, Res_MOD2, Res_MOD3, MODS_OFF(2 downto 0), TEST_ON, ALU_RESULT, ERROR);
                when "1000" => -- sub
                    COMPARE(Res_MOD1, Res_MOD2, Res_MOD3, MODS_OFF(5 downto 3), TEST_ON, ALU_RESULT, ERROR);
                when "0001" => -- SLL
                    COMPARE(Res_MOD1, Res_MOD2, Res_MOD3, MODS_OFF(8 downto 6), TEST_ON,  ALU_RESULT, ERROR);
                when "0010" => -- SLTI
                    COMPARE(Res_MOD1, Res_MOD2, Res_MOD3, MODS_OFF(11 downto 9), TEST_ON,  ALU_RESULT, ERROR);
                when "0011" => -- SLTIU
                    COMPARE(Res_MOD1, Res_MOD2, Res_MOD3, MODS_OFF(14 downto 12), TEST_ON, ALU_RESULT, ERROR);                     
                when "0100" => -- XOR
                    COMPARE(Res_MOD1, Res_MOD2, Res_MOD3, MODS_OFF(17 downto 15), TEST_ON, ALU_RESULT, ERROR);
                when "0101" => -- SRL
                    COMPARE(Res_MOD1, Res_MOD2, Res_MOD3, MODS_OFF(20 downto 18), TEST_ON, ALU_RESULT, ERROR);
                when "1101" => -- SRA
                    COMPARE(Res_MOD1, Res_MOD2, Res_MOD3, MODS_OFF(23 downto 21), TEST_ON, ALU_RESULT, ERROR);
                when "0110" => -- OR
                    COMPARE(Res_MOD1, Res_MOD2, Res_MOD3, MODS_OFF(26 downto 24), TEST_ON, ALU_RESULT, ERROR);                            
                when "0111" => -- AND
                    COMPARE(Res_MOD1, Res_MOD2, Res_MOD3, MODS_OFF(29 downto 27), TEST_ON, ALU_RESULT, ERROR);
                when others =>
                    ALU_RESULT <= (others => '0');
                    ERROR <= '0';
            end case;
        end if;
    end process;
end RTL;