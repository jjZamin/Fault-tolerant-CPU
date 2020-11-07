library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED.all;
use work.SSD1331_ascii_pkg.all;
use work.timer_pkg.all;

-- Ghennadie Mazin
entity SSD1331_ascii is --ascii --addr: x"fffffffd"

      generic(
                system_freq : natural := 18000000
      );
      Port ( 
                clk : in std_logic;
                clear : in std_logic;
                cmd : in std_logic_vector(23 downto 0);
                addr : in std_logic_vector(31 downto 0);
                we : in std_logic;
                SPI_IS_BUSY : in std_logic;
                
                spi_addr : out std_logic_vector(31 downto 0);
                spi_data : out std_logic_vector(7 downto 0);
                spi_we : out std_logic;
                ssd_dc : out std_logic;
                
                ascii_stall_cpu : out std_logic
      );
end SSD1331_ascii;



architecture RTL of SSD1331_ascii is

--

signal POSx : std_logic_vector(7 downto 0) := (others => '0'); -- 0-95
signal POSy : std_logic_vector(7 downto 0) := (others => '0'); -- 0-63
signal POSy_cnt : integer := 0;
signal ROM_POS_cnt : integer := 0;

signal POSy_loc : std_logic_vector(7 downto 0) := (others => '0'); -- 0-63
signal START_ROM_POS_loc : natural := 0;
-- internal signals
signal mapper_is_busy : std_logic := '0';
signal START_mapping : std_logic := '0';

signal start_timer : std_logic := '0';
signal stop_timer : std_logic := '1';
signal timer_flag : std_logic := '0';

-- ROM

signal START_ROM_POS : natural := 0;

-- states:
-- idle
-- send POSx

-- map
-- done
signal STATES : std_logic_vector(8 downto 0) := "000000001";

----------------------------------------------


 --attribute rom_style : string;
 --attribute rom_style of ASCII_ROM : signal is "block";

----------------------------------------------



begin

rdata : process(clk)
begin
    if(rising_edge(clk)) then
        START_mapping <= '0';
        if(clear = '1') then
            POSx <= (others => '0');
            POSy <= (others => '0');
            START_ROM_POS <= 0;
            START_mapping <= '0';         
        else
            if(we = '1' and addr = THIS_ADDR and mapper_is_busy = '0') then
                START_mapping <= '1';
                POSx <= cmd(15 downto 8);
                POSy <= cmd(23 downto 16);
                case cmd(7 downto 0) is --ascii
                    when x"30" => -- ascii for 0
                        START_ROM_POS <= 0;
                    when x"31" => -- ascii for 1
                        START_ROM_POS <= 128;
                    when x"32" => -- ascii for 2
                        START_ROM_POS <= 128 * 2;
                    when x"33" => -- ascii for 3
                        START_ROM_POS <= 128 * 3;
                    when x"34" => -- ascii for 4
                        START_ROM_POS <= 128 * 4;
                    when x"35" => -- ascii for 5
                        START_ROM_POS <= 128 * 5;
                    when x"36" => -- ascii for 6
                        START_ROM_POS <= 128 * 6;                        
                    when x"37" => -- ascii for 7
                        START_ROM_POS <= 128 * 7;
                    when x"38" => -- ascii for 8
                        START_ROM_POS <= 128 * 8;
                    when x"39" => -- ascii for 9
                        START_ROM_POS <= 128 * 9;
                    -- caps alphabet
                    when x"41" =>     --A
                        START_ROM_POS <= 128 * 10;
                    when x"42" =>     --B
                        START_ROM_POS <= 128 * 11;
                    when x"43" =>     --C
                        START_ROM_POS <= 128 * 12;
                    when x"44" =>     --D
                        START_ROM_POS <= 128 * 13;
                    when x"45" =>     --E
                        START_ROM_POS <= 128 * 14;
                    when x"46" =>     --F
                        START_ROM_POS <= 128 * 15;
                        ----------------------------- out of order!
                    when x"52" =>     --R
                        START_ROM_POS <= 128 * 16;
                    when x"49" =>     --I
                        START_ROM_POS <= 128 * 17;                        
                    when x"53" =>     --S
                        START_ROM_POS <= 128 * 18;                                                
                    when x"56" =>     --V
                        START_ROM_POS <= 128 * 19;                                                                        
                    when x"2D" =>     -- "-"
                        START_ROM_POS <= 128 * 20;
                    when x"FF" => -- smiley
                        START_ROM_POS <= 128 * 21;     
                    when others =>
                        START_ROM_POS <= 0;
                end case;
            end if;
        end if;
    end if;
end process;

states_p : process(clk)
    begin
        if(rising_edge(clk)) then
            spi_data <= (others => '0');
            if(clear = '1') then
                POSy_cnt <= 0;
                ROM_POS_cnt <= 0;
                ascii_stall_cpu <= '0';
                mapper_is_busy <= '0';
                spi_addr <= (others => '0');
                spi_we <= '0';
                ssd_dc <= '0';
                spi_data <= (others => '0');
                STATES <= "000000001";
                POSy_loc <= (others => '0');
                START_ROM_POS_loc <= 0;
                start_timer <= '0';
                stop_timer <= '1';
            else
                case STATES is
                    when "000000001" =>
                        start_timer <= '0';
                        stop_timer <= '1';
                        POSy_loc <= (others => '0');
                        START_ROM_POS_loc <= 0;
                        spi_addr <= (others => '0');
                        spi_we <= '0';
                        ssd_dc <= '0';
                        spi_data <= (others => '0');                        
                        ascii_stall_cpu <= '0';
                        mapper_is_busy <= '0';
                        POSy_cnt <= 0;
                        ROM_POS_cnt <= 0;
                        if(START_mapping = '1') then
                            POSy_loc <= POSy;
                            START_ROM_POS_loc <= START_ROM_POS;
                            ascii_stall_cpu <= '1';
                            mapper_is_busy <= '1';
                            STATES <= "000000010";
                        else
                            STATES <= "000000001";
                        end if;
                        
                    when "000000010" => -- SET COL ADDR
                        spi_addr <= (others => '0');
                        spi_we <= '0';
                        spi_data <= (others => '0');
                        start_timer <= '1';
                        stop_timer <= '0';
                        ascii_stall_cpu <= '1';
                        if(SPI_IS_BUSY = '0' and timer_flag = '1') then
                            start_timer <= '0';
                            stop_timer <= '1';
                            if(POSy_cnt = 8) then -- done
                                STATES <= "000000001";
                            else                        
                                STATES <= "000000100";
                                spi_addr <= SPI_ADDR_s;
                                spi_we <= '1';
                                ssd_dc <= '0';
                                spi_data <= SET_COL_ADDR;
                            end if;
                        else
                            STATES <= "000000010";
                        end if;
                    when "000000100" => -- X
                        spi_addr <= (others => '0');
                        spi_we <= '0';
                        ssd_dc <= '0';
                        spi_data <= (others => '0');
                        start_timer <= '1';
                        stop_timer <= '0';
                        ascii_stall_cpu <= '1';
                        if(SPI_IS_BUSY = '0' and timer_flag = '1') then
                            start_timer <= '0';
                            stop_timer <= '1';
                            STATES <= "000001000";
                            spi_addr <= SPI_ADDR_s;
                            spi_we <= '1';
                            ssd_dc <= '0';
                            spi_data <= POSx;
                        else
                            STATES <= "000000100";
                        end if;
                    when "000001000" => -- WIDTH
                        spi_addr <= (others => '0');
                        spi_we <= '0';
                        ssd_dc <= '0';
                        spi_data <= (others => '0');
                        start_timer <= '1';
                        stop_timer <= '0';
                        ascii_stall_cpu <= '1';
                        if(SPI_IS_BUSY = '0' and timer_flag = '1') then
                            start_timer <= '0';
                            stop_timer <= '1';
                            STATES <= "000010000";
                            spi_addr <= SPI_ADDR_s;
                            spi_we <= '1';
                            ssd_dc <= '0';
                            spi_data <= WIDTH;
                        else
                            STATES <= "000001000";
                        end if;                    
                    
                    when "000010000" => -- SET ROW ADDR
                        spi_addr <= (others => '0');
                        spi_we <= '0';
                        ssd_dc <= '0';
                        spi_data <= (others => '0');
                        start_timer <= '1';
                        stop_timer <= '0';
                        ascii_stall_cpu <= '1';
                        if(SPI_IS_BUSY = '0' and timer_flag = '1') then
                            start_timer <= '0';
                            stop_timer <= '1';
                            STATES <= "000100000";
                            spi_addr <= SPI_ADDR_s;
                            spi_we <= '1';
                            ssd_dc <= '0';
                            spi_data <= SET_ROW_ADDR;
                        else
                            STATES <= "000010000";
                        end if;                       
                    when "000100000" => -- POS Y !!
                        spi_addr <= (others => '0');
                        spi_we <= '0';
                        ssd_dc <= '0';
                        spi_data <= (others => '0');
                        start_timer <= '1';
                        stop_timer <= '0';
                        ascii_stall_cpu <= '1';
                        if(SPI_IS_BUSY = '0' and timer_flag = '1') then
                            start_timer <= '0';
                            stop_timer <= '1';
                            STATES <= "001000000";
                            spi_addr <= SPI_ADDR_s;
                            spi_we <= '1';
                            ssd_dc <= '0';
                            spi_data <= POSy_loc;
                            POSy_cnt <= POSy_cnt + 1;
                            POSy_loc <= POSy_loc + '1';                            
                        else
                            STATES <= "000100000";
                        end if;                      
                    when "001000000" => -- HEIGHT
                        spi_addr <= (others => '0');
                        spi_we <= '0';
                        ssd_dc <= '0';
                        spi_data <= (others => '0');
                        start_timer <= '1';
                        stop_timer <= '0';
                        ascii_stall_cpu <= '1';
                        if(SPI_IS_BUSY = '0' and timer_flag = '1') then
                            start_timer <= '0';
                            stop_timer <= '1';
                            STATES <= "010000000";
                            spi_addr <= SPI_ADDR_s;
                            spi_we <= '1';
                            ssd_dc <= '0';
                            spi_data <= HEIGHT;
                        else
                            STATES <= "001000000";
                        end if;                    
                    when "010000000" =>
                        spi_addr <= (others => '0');
                        spi_we <= '0';
                        spi_data <= (others => '0');
                        start_timer <= '1';
                        stop_timer <= '0';
                        ascii_stall_cpu <= '1';
                        if(SPI_IS_BUSY = '0' and timer_flag = '1') then
                            start_timer <= '0';
                            stop_timer <= '1';
                            STATES <= "100000000";
                            spi_addr <= SPI_ADDR_s;
                            spi_we <= '1';
                            ssd_dc <= '1';
                            spi_data <= ASCII_ROM(START_ROM_POS_loc);
                            START_ROM_POS_loc <= START_ROM_POS_loc + 1;
                            ROM_POS_cnt <= ROM_POS_cnt + 1;
                        else
                            STATES <= "010000000";
                        end if;                      
                    when "100000000" =>
                        spi_addr <= (others => '0');
                        spi_we <= '0';
                        ssd_dc <= '1';
                        spi_data <= (others => '0');
                        ascii_stall_cpu <= '1';
                        if(ROM_POS_cnt = 16) then
                            ROM_POS_cnt <= 0;
                            STATES <= "000000010";
                        else
                            STATES <= "010000000";
                        end if;                    
                    when others =>
                        STATES <= "000000001";
                        POSy_cnt <= 0;
                        ROM_POS_cnt <= 0;
                        ascii_stall_cpu <= '0';
                        mapper_is_busy <= '0';
                        spi_addr <= (others => '0');
                        spi_we <= '0';
                        ssd_dc <= '0';
                        spi_data <= (others => '0');                      
                end case;
            end if;
        end if;
    end process;
    
    
      c_timer : timer 
      generic map(
                timer_flag_ns => 50 * 4, 
                system_freq => system_freq
      )
      
      Port map( 
                clk => clk,
                clear => clear,
                
                start_timer => start_timer,
                reset_timer => stop_timer,
      
                timer_flag => timer_flag
      );                 

end RTL;