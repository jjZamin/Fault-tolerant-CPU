library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED.all;
use work.softwaretimer_pkg.all;

entity CSR is
          generic (
                    system_frq : natural := system_frq
          );
          Port ( 
                    clk : in std_logic;
                    clear : in std_logic;
                    
                    CSR_addr : in std_logic_vector(11 downto 0);
                    CSR_control_word : in std_logic_vector(31 downto 0);
                    CRS_write_to_reg : out std_logic_vector(31 downto 0);
                    CSR_we : in std_logic;
                    CSR_scrubbed_pc : in std_logic_vector(31 downto 0);
                    -- IRQs
                    IRQ_timer1 : out std_logic;
                    IRQ_code : out std_logic_vector(31 downto 0);
                    IRQ_running_software : out std_logic_vector(31 downto 0)
          );
end CSR;

architecture Behavioral of CSR is

signal IRQ_running_software_reg : std_logic_vector(31 downto 0) := (others => '0'); --IRQ(0) = timer1
signal scrubbed_pc_reg : std_logic_vector(31 downto 0) := (others => '0');

begin

scrubbed_pc_reg <= CSR_scrubbed_pc;
wreg: process(clk)
begin
    if(rising_edge(clk)) then
        if(clear = '1') then
            IRQ_running_software_reg <= (others => '0');
        else
            if(CSR_we = '1') then --set that IRQ rutine is running now. bit(0) -> timer1
                case CSR_addr is
                    when "100000000000" =>
                        IRQ_running_software_reg <= CSR_control_word;
                    when others =>
                        null;
                end case;
            end if;                
        end if;    
    end if;
end process;

rreg : process(CSR_addr, IRQ_running_software_reg, scrubbed_pc_reg)
begin
    IRQ_running_software <= IRQ_running_software_reg;
    case CSR_addr is
        when "100000000000" =>
            CRS_write_to_reg <= IRQ_running_software_reg;
        when "010000000000" =>
            CRS_write_to_reg <= scrubbed_pc_reg;
        when others =>
            CRS_write_to_reg <= (others => '0');            
    end case;
end process;


-- timers
rsc_timers: RISCV_timers 
          generic map(
                    system_frq => system_frq
          )
          Port map( 
                    clk => clk,
                    clear => clear,
                    
                    addr => CSR_addr,
                    we => CSR_we,
                    control_word => CSR_control_word,
                    IRQ_timer1 => IRQ_timer1,
                    IRQ_code => IRQ_code                
          );

end Behavioral;
