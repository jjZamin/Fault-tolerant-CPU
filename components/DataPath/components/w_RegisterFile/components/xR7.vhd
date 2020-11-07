library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.xR7_pkg.all;

--****************
-- By Ghennadie Mazin, final project.
--****************

-- saving register file in xtra register to recover previous data if error occurs
entity xR7 is
        generic(
                DATA_WIDTH : natural := 32        
        );
        
        
        Port ( 
                clk : in std_logic;
                clear : in std_logic;
                ---
                STOP_CLOCK : in std_logic;
                load_to_regfile : in std_logic;
                load_from_xRn_addr : in std_logic_vector(2 downto 0);
                Reg_File_In : in REG_TYPE;

                xRn_to_regfile : out REG_TYPE        
        );
end xR7;

architecture RTL of xR7 is

    signal xR0_s : REG_TYPE := ((others => (others => '0')));
    signal xR1_s : REG_TYPE := ((others => (others => '0')));
    signal xR2_s : REG_TYPE := ((others => (others => '0')));
    signal xR3_s : REG_TYPE := ((others => (others => '0')));
    signal xR4_s : REG_TYPE := ((others => (others => '0')));    
    signal xR5_s : REG_TYPE := ((others => (others => '0')));
    signal xR6_s : REG_TYPE := ((others => (others => '0')));
    signal xR7_s : REG_TYPE := ((others => (others => '0')));
    
begin

    reg_we: process(clk)
    begin
        if(rising_edge(clk)) then
            if(clear = '1') then
                xR0_s <= ((others => (others => '0')));
                xR1_s <= ((others => (others => '0')));
                xR2_s <= ((others => (others => '0')));
                xR3_s <= ((others => (others => '0')));
                xR4_s <= ((others => (others => '0')));
                xR5_s <= ((others => (others => '0')));
                xR6_s <= ((others => (others => '0')));
                xR7_s <= ((others => (others => '0')));
            else
            ----
                if(STOP_CLOCK = '0') then
                    xR0_s <= xR1_s;
                    xR1_s <= xR2_s;
                    xR2_s <= xR3_s;
                    xR3_s <= xR4_s;
                    xR4_s <= xR5_s;
                    xR5_s <= xR6_s;
                    xR6_s <= xR7_s;
                    xR7_s <= Reg_File_In;
                end if;
            end if;
        end if;
    end process;

    load_to_regs : process(clk)
    begin
        if(rising_edge(clk)) then
            if(STOP_CLOCK = '1') then
                if(load_to_regfile = '1') then
                    case load_from_xRn_addr is
                        when "000" =>
                            xRn_to_regfile <= xR0_s;
                        when "001" =>
                            xRn_to_regfile <= xR1_s;
                        when "010" =>
                            xRn_to_regfile <= xR2_s;
                        when "011" =>
                            xRn_to_regfile <= xR3_s;
                        when "100" =>
                            xRn_to_regfile <= xR4_s;    
                        when "101" =>
                            xRn_to_regfile <= xR5_s;
                        when "110" =>
                            xRn_to_regfile <= xR6_s;
                        when "111" =>
                            xRn_to_regfile <= xR7_s;
                        when others =>
                            xRn_to_regfile <= ((others => (others => '0')));
                    end case;
               end if;
           end if;
        end if;
    end process;
end RTL;
