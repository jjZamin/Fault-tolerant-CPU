library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED.all;

entity ALU_ECT is
  generic(
            DATA_WIDTH : natural := 32
  );
  Port ( 
            clk : in std_logic;
            clear : in std_logic;
            
            Res_MOD1 : in std_logic_vector(DATA_WIDTH - 1 downto 0);
            Res_MOD2 : in std_logic_vector(DATA_WIDTH - 1 downto 0);
            Res_MOD3 : in std_logic_vector(DATA_WIDTH - 1 downto 0);
            funct    : in std_logic_vector(3 downto 0);
            ALU_ERROR: in std_logic;
            
            A_test   : out std_logic_vector(DATA_WIDTH - 1 downto 0);
            B_test   : out std_logic_vector(DATA_WIDTH - 1 downto 0);
            funct_out: out std_logic_vector(3 downto 0);
            
            TESTING_ON  : out std_logic;
            
            MODS_OFF : out std_logic_vector(29 downto 0);
            ALU_STALL_CPU : out std_logic
  );
end ALU_ECT;

architecture RTL of ALU_ECT is
    procedure checnMods(    
                            signal MOD1_in : in std_logic_vector(DATA_WIDTH - 1 downto 0);
                            signal MOD2_in : in std_logic_vector(DATA_WIDTH - 1 downto 0);
                            signal MOD3_in : in std_logic_vector(DATA_WIDTH - 1 downto 0);
                            signal res_expected : in std_logic_vector(DATA_WIDTH - 1 downto 0);
                            signal Mod_off : out std_logic_vector(2 downto 0);
                            signal test_done : out std_logic                           
                            ) is
    begin  
        test_done <= '0';
        if(MOD1_in /= res_expected) then
            Mod_off(0) <= '1';
        end if;
        if(MOD2_in /= res_expected) then
            Mod_off(1) <= '1';
        end if;
        if(MOD3_in /= res_expected) then
            Mod_off(2) <= '1';
        end if;
        test_done <= '1';
end procedure;

-- 0001 -> clear
-- 0010 -> stall cpu
-- 0100 -> begin text
-- 1000 -> test done
signal STATES : std_logic_vector(3 downto 0) := (others => '0');
signal ERROR_STATE : std_logic := '0';
signal TESTING_ON_s : std_logic := '0';
signal TESTING_DONE_s : std_logic := '1';
signal MODS_OFF_s : std_logic_vector(29 downto 0) := (others => '0');
signal funct_s : std_logic_vector(3 downto 0) := (others => '0');
-- ~ test outputs and expected result
-- ADD
signal A_ADDt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := x"01000010";
signal B_ADDt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := x"00100001";
signal xpres_ADDt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := x"01100011";

-- SUB
signal A_SUBt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := x"10BADDAD";
signal B_SUBt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := x"0BADDAD0";
signal xpres_SUBt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := x"050D02DD";

-- SLL
signal A_SLLt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := "10001000000000001000001001110000";
signal B_SLLt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := "00000000000000000000000000000010";
signal xpres_SLLt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := "00100000000000100000100111000000";

-- SLTI
signal A_SLTIt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := x"F00000F0";
signal B_SLTIt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := x"00000011";
signal xpres_SLTIt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := x"00000001";

-- SLTI
signal A_SLTIUt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := x"F00000F0";
signal B_SLTIUt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := x"00000011";
signal xpres_SLTIUt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := x"00000000";

-- XOR
signal A_XORt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) :=       "10001001010001001000001001110001";
signal B_XORt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) :=       "11001000010111100111001011110101";
signal xpres_XORt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) :=   "01000001000110101111000010000100";

-- SRL
signal A_SRLt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := "10001000000000001000001001110001";
signal B_SRLt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := "00000000000000000000000000000010";
signal xpres_SRLt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := "00100010000000000010000010011100";

-- SRA
signal A_SRAt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := "10001000000000001000001001110001";
signal B_SRAt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := "00000000000000000000000000000010";
signal xpres_SRAt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := "11100010000000000010000010011100";

-- OR
signal A_ORt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) :=       "10001001010001001000001001110001";
signal B_ORt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) :=       "11001000010111100111001011110101";
signal xpres_ORt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) :=   "11001001010111101111001011110101";

-- AND
signal A_ANDt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) :=       "10001001010001001000001001110001";
signal B_ANDt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) :=       "11001000010111100111001011110101";
signal xpres_ANDt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) :=   "10001000010001000000001001110001";
-------------------------------------------------------------------------------------

begin    
    funct_out <= funct_s;

    -- ONE HOT STATE MACHINE
    nxState: process(clk)
    begin
        if(rising_edge(clk)) then
            A_test <= (others => '0');
            B_test <= (others => '0');
            if(ALU_ERROR = '1') then
                funct_s <= funct;            
            end if;
            if(clear = '1') then
                A_test <= (others => '0');
                B_test <= (others => '0');
                MODS_OFF_s <= (others => '0');
                STATES <= "0001";
                TESTING_ON_s <= '0';
                ALU_STALL_CPU <= '0';
                TESTING_DONE_s <= '1';
                funct_s <= (others => '0');
            else
                case STATES is
                    when "0001" =>
                        if(ALU_ERROR = '1') then
                            STATES <= "0010"; --nxt state
                            ALU_STALL_CPU <= '1';
                            TESTING_ON_s <= '1';
                            TESTING_DONE_s <= '0'; 
                        else
                            STATES <= "0001"; --nxt state        
                            ALU_STALL_CPU <= '0';
                            TESTING_ON_s <= '0';
                            TESTING_DONE_s <= '1';
                        end if;
                    when "0010" =>
                        STATES <= "0100"; -- START TEST
                        TESTING_ON_s <= '1';
                        ALU_STALL_CPU <= '1';
                        TESTING_DONE_s <= '0';
                        case funct_s is
                            when "0000" => -- add
                                A_test <= A_ADDt1;
                                B_test <= B_ADDt1;  
                            when "1000" => -- sub
                                A_test <= A_SUBt1;
                                B_test <= B_SUBt1;  
                            when "0001" => -- SLL
                                A_test <= A_SLLt1;
                                B_test <= B_SLLt1;  
                             when "0010" => -- SLTI
                                A_test <= A_SLTIt1;
                                B_test <= B_SLTIt1;  
                             when "0011" => -- SLTIU
                                A_test <= A_SLTIUt1;
                                B_test <= B_SLTIUt1;                        
                             when "0100" => -- XOR
                                A_test <= A_XORt1;
                                B_test <= B_XORt1;  
                             when "0101" => -- SRL
                                A_test <= A_SRLt1;
                                B_test <= B_SRLt1;  
                             when "1101" => -- SRA
                                A_test <= A_SRAt1;
                                B_test <= B_SRAt1;  
                             when "0110" => -- OR
                                A_test <= A_ORt1;
                                B_test <= B_ORt1;                              
                             when "0111" => -- AND
                                A_test <= A_ANDt1;
                                B_test <= B_ANDt1;    
                            when others =>
                                TESTING_ON_s <= '0';
                                ALU_STALL_CPU <= '0';
                                TESTING_DONE_s <= '1';
                                STATES <= "1000";
                        end case; 
                    when "0100" =>
                        case funct_s is
                            when "0000" => -- add
                                A_test <= A_ADDt1;
                                B_test <= B_ADDt1;  
                                checnMods(Res_MOD1, Res_MOD2, Res_MOD3, xpres_ADDt1, 
                                MODS_OFF_s(2 downto 0), TESTING_DONE_s);
                                if(TESTING_DONE_s = '1') then
                                    STATES <= "1000";
                                end if;
                            when "1000" => -- sub
                                A_test <= A_SUBt1;
                                B_test <= B_SUBt1;  
                                checnMods(Res_MOD1, Res_MOD2, Res_MOD3, xpres_SUBt1, 
                                MODS_OFF_s(5 downto 3), TESTING_DONE_s);
                                if(TESTING_DONE_s = '1') then
                                    STATES <= "1000";
                                end if;
                            when "0001" => -- SLL
                                A_test <= A_SLLt1;
                                B_test <= B_SLLt1;  
                                checnMods(Res_MOD1, Res_MOD2, Res_MOD3, xpres_SLLt1, 
                                MODS_OFF_s(8 downto 6), TESTING_DONE_s);
                                if(TESTING_DONE_s = '1') then
                                    STATES <= "1000";
                                end if;
                             when "0010" => -- SLTI
                                A_test <= A_SLTIt1;
                                B_test <= B_SLTIt1;  
                                checnMods(Res_MOD1, Res_MOD2, Res_MOD3, xpres_SLTIt1, 
                                MODS_OFF_s(11 downto 9), TESTING_DONE_s);
                                if(TESTING_DONE_s = '1') then
                                    STATES <= "1000";
                                end if;
                             when "0011" => -- SLTIU
                                A_test <= A_SLTIUt1;
                                B_test <= B_SLTIUt1;  
                                checnMods(Res_MOD1, Res_MOD2, Res_MOD3, xpres_SLTIUt1, 
                                MODS_OFF_s(14 downto 12), TESTING_DONE_s);
                                if(TESTING_DONE_s = '1') then
                                    STATES <= "1000";
                                end if;                           
                             when "0100" => -- XOR
                                A_test <= A_XORt1;
                                B_test <= B_XORt1;  
                                checnMods(Res_MOD1, Res_MOD2, Res_MOD3, xpres_XORt1, 
                                MODS_OFF_s(17 downto 15), TESTING_DONE_s);
                                if(TESTING_DONE_s = '1') then
                                    STATES <= "1000";
                                end if;   
                             when "0101" => -- SRL
                                A_test <= A_SRLt1;
                                B_test <= B_SRLt1;  
                                checnMods(Res_MOD1, Res_MOD2, Res_MOD3, xpres_SRLt1, 
                                MODS_OFF_s(20 downto 18), TESTING_DONE_s);
                                if(TESTING_DONE_s = '1') then
                                    STATES <= "1000";
                                end if;
                             when "1101" => -- SRA
                                A_test <= A_SRAt1;
                                B_test <= B_SRAt1;  
                                checnMods(Res_MOD1, Res_MOD2, Res_MOD3, xpres_SRAt1, 
                                MODS_OFF_s(23 downto 21), TESTING_DONE_s);
                                if(TESTING_DONE_s = '1') then
                                    STATES <= "1000";
                                end if;
                             when "0110" => -- OR
                                A_test <= A_ORt1;
                                B_test <= B_ORt1;  
                                checnMods(Res_MOD1, Res_MOD2, Res_MOD3, xpres_ORt1, 
                                MODS_OFF_s(26 downto 24), TESTING_DONE_s);
                                if(TESTING_DONE_s = '1') then
                                    STATES <= "1000";
                                end if;                                  
                             when "0111" => -- AND
                                A_test <= A_ANDt1;
                                B_test <= B_ANDt1;  
                                checnMods(Res_MOD1, Res_MOD2, Res_MOD3, xpres_ANDt1, 
                                MODS_OFF_s(29 downto 27), TESTING_DONE_s);
                                if(TESTING_DONE_s = '1') then
                                    STATES <= "1000";
                                end if;    
                            when others =>
                                TESTING_ON_s <= '0';
                                ALU_STALL_CPU <= '0';
                                TESTING_DONE_s <= '1';
                                STATES <= "1000";
                        end case;
                    when "1000" =>
                        if(TESTING_DONE_s = '1') then
                            TESTING_DONE_s <= '0';
                            STATES <= "0001";
                            funct_s <= (others => '0');
                        else
                            STATES <= "0100";
                        end if;
                    when others =>
                        TESTING_ON_s <= '0';
                        ALU_STALL_CPU <= '0';
                        TESTING_DONE_s <= '1';
                        STATES <= "1000";
                        funct_s <= (others => '0');
                end case;
            end if;
        end if;
    end process;
   
    TESTING_ON <= TESTING_ON_s;
    MODS_OFF <= MODS_OFF_s;
end RTL;
