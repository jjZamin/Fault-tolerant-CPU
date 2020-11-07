library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED.all;

-- By Ghennadie Mazin
entity COMPARAPTOR_ECT is
  generic(
            DATA_WIDTH : natural := 32
  );
  Port ( 
            clk : in std_logic;
            clear : in std_logic;
            
            Res_MOD1 : in std_logic_vector(5 downto 0);
            Res_MOD2 : in std_logic_vector(5 downto 0);
            Res_MOD3 : in std_logic_vector(5 downto 0);
            funct    : in std_logic_vector(3 downto 0);
            ALU_ERROR: in std_logic;
            
            A_test   : out std_logic_vector(DATA_WIDTH - 1 downto 0);
            B_test   : out std_logic_vector(DATA_WIDTH - 1 downto 0);
            funct_out: out std_logic_vector(3 downto 0);
            
            TESTING_ON  : out std_logic;
            
            MODS_OFF : out std_logic_vector(17 downto 0);
            ALU_STALL_CPU : out std_logic
  );
end COMPARAPTOR_ECT;

architecture Behavioral of COMPARAPTOR_ECT is

    procedure checnMods(    
                            signal MOD1_in : in std_logic;
                            signal MOD2_in : in std_logic;
                            signal MOD3_in : in std_logic;
                            signal res_expected : in std_logic;
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
signal MODS_OFF_s : std_logic_vector(17 downto 0) := (others => '0');
signal funct_s : std_logic_vector(3 downto 0) := (others => '0');

-- ~ test outputs and expected result

--EQ
signal A_bEQt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := x"00111001";
signal B_bEQt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := x"00111001";
signal xpres_bEQt1 : std_logic := '1';
--NE
signal A_bNEQt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := x"00111001";
signal B_bNEQt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := x"00111101";
signal xpres_bNEQt1 : std_logic := '1';
--LT
signal A_bLTt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := x"F0000001";
signal B_bLTt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := x"10111101";
signal xpres_bLTt1 : std_logic := '1';
--GE
signal A_bGEt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := x"00000000";
signal B_bGEt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := x"F1111111";
signal xpres_bGEt1 : std_logic := '1';
--LTU
signal A_bLTUt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := x"F0000001";
signal B_bLTUt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := x"10111101";
signal xpres_bLTUt1 : std_logic := '0';
--GEU
signal A_bGEUt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := x"00000000";
signal B_bGEUt1 : std_logic_vector(DATA_WIDTH - 1 downto 0) := x"F1111111";
signal xpres_bGEUt1 : std_logic := '0';

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
                            when "0000" => -- EQ
                                A_test <= A_bEQt1;
                                B_test <= B_bEQt1;  
                            when "1111" => -- NE
                                A_test <= A_bNEQt1;
                                B_test <= B_bNEQt1;  
                            when "1001" => -- LT
                                A_test <= A_bLTt1;
                                B_test <= B_bLTt1;  
                             when "1010" => -- GE
                                A_test <= A_bGEt1;
                                B_test <= B_bGEt1;  
                             when "0001" => -- LTU
                                A_test <= A_bLTUt1;
                                B_test <= B_bLTUt1;                        
                             when "0010" => -- GEU
                                A_test <= A_bGEUt1;
                                B_test <= B_bGEUt1;  
                            when others =>
                                TESTING_ON_s <= '0';
                                ALU_STALL_CPU <= '0';
                                TESTING_DONE_s <= '1';
                                STATES <= "1000";
                        end case; 
                    when "0100" =>
                        case funct_s is
                            when "0000" => -- EQ
                                A_test <= A_bEQt1;
                                B_test <= B_bEQt1;  
                                checnMods(Res_MOD1(0), Res_MOD2(0), Res_MOD3(0), xpres_bEQt1, 
                                MODS_OFF_s(2 downto 0), TESTING_DONE_s);
                                if(TESTING_DONE_s = '1') then
                                    STATES <= "1000";
                                end if;
                            when "1111" => -- NE
                                A_test <= A_bNEQt1;
                                B_test <= B_bNEQt1;  
                                checnMods(Res_MOD1(1), Res_MOD2(1), Res_MOD3(1), xpres_bNEQt1, 
                                MODS_OFF_s(5 downto 3), TESTING_DONE_s);
                                if(TESTING_DONE_s = '1') then
                                    STATES <= "1000";
                                end if;
                            when "1001" => -- LT
                                A_test <= A_bLTt1;
                                B_test <= B_bLTt1;  
                                checnMods(Res_MOD1(2), Res_MOD2(2), Res_MOD3(2), xpres_bLTt1, 
                                MODS_OFF_s(8 downto 6), TESTING_DONE_s);
                                if(TESTING_DONE_s = '1') then
                                    STATES <= "1000";
                                end if;
                             when "1010" => -- GE
                                A_test <= A_bGEt1;
                                B_test <= B_bGEt1;  
                                checnMods(Res_MOD1(3), Res_MOD2(3), Res_MOD3(3), xpres_bGEt1, 
                                MODS_OFF_s(11 downto 9), TESTING_DONE_s);
                                if(TESTING_DONE_s = '1') then
                                    STATES <= "1000";
                                end if;
                             when "0001" => -- LTU
                                A_test <= A_bLTUt1;
                                B_test <= B_bLTUt1;  
                                checnMods(Res_MOD1(4), Res_MOD2(4), Res_MOD3(4), xpres_bLTUt1, 
                                MODS_OFF_s(14 downto 12), TESTING_DONE_s);
                                if(TESTING_DONE_s = '1') then
                                    STATES <= "1000";
                                end if;                           
                             when "0010" => -- GEU
                                A_test <= A_bGEUt1;
                                B_test <= B_bGEUt1;  
                                checnMods(Res_MOD1(5), Res_MOD2(5), Res_MOD3(5), xpres_bGEUt1, 
                                MODS_OFF_s(17 downto 15), TESTING_DONE_s);
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
end Behavioral;
