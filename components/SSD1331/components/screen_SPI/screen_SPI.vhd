library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED.all;
use work.screen_SPI_pkg.all;
-- By Ghennadie Mazin

entity screen_SPI is
  generic(
            --bit[1]-> polarity
            -- [0: idle -> 0, leading -> rising]
            -- [1: idle -> 1, leading -> falling] ...
            --bit[0]-> phase
            -- [0: datachange on: trailing,; slave samples on leading]
            -- [1: datachange on: leading,; slave samples on trailing]
            system_frequency : natural := SYSTEM_FREQ;
            spi_frequency : natural := SPI_FREQ;
            addr : std_logic_vector(31 downto 0) :=SPI_ADDR
  );

  Port (
            POLARITY : in std_logic;
            PHASE : in std_logic;

            clk : in std_logic;
            clear : in std_logic;
            isb_wdata : in std_logic_vector(7 downto 0);
            isb_addr : in std_logic_vector(31 downto 0);
            isb_we : in std_logic;
            SPI_TX_BUSY : out std_logic;

            sclk : out std_logic;
            cs : out std_logic;
            MOSI : out std_logic
  );
end screen_SPI;

architecture RTL of screen_SPI is

signal rdata_sig : std_logic_Vector(7 downto 0) := (others => '0');
signal begin_TX : std_logic := '0';
signal SPI_BUSY_sig : std_logic := '0';

signal start_MOSI : std_logic := '0';
signal sclk_s : std_logic := '0';
signal edge_LEADING : std_logic := '1';
signal edge_TRAILING : std_logic := '0';
signal count_spi_bits : natural := 7;
signal count_clocks :  natural := 0;

-- IDLE: 0001 / others
-- START CLOCK + CS: 0010
-- SEND DATA: 0100
-- END:     1000
signal STATES : std_logic_vector(3 downto 0) := "0001";
begin

    wdata : process(clk)
    begin
        if(rising_edge(clk)) then
            begin_TX <= '0';
            if(clear = '1') then
                begin_TX <= '0';
                rdata_sig <= (others => '0');
            else
                if(isb_we = '1') then
                   if(isb_addr = addr and SPI_BUSY_sig = '0') then
                       rdata_sig <= isb_wdata(7 downto 0);
                       begin_TX <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;

    MOSI_p: process(clk)
        variable frequency_counter : integer := 0;
        constant frequency_division : integer := system_frequency/spi_frequency/2;
    begin
        if(rising_edge(clk)) then
            if(clear = '1') then
                sclk_s <= POLARITY;
                edge_LEADING <= '1';
                edge_TRAILING <= '0';
                count_clocks <= 0;
                count_spi_bits <= 7;
            else

                if(start_MOSI = '1') then
                    if(frequency_counter < frequency_division) then
                        frequency_counter := frequency_counter + 1;
                        if(frequency_counter = frequency_division) then
                            edge_TRAILING <= '1';
                        end if;
                        if(count_clocks < 8) then
                            sclk_s <= not POLARITY;
                        else
                            sclk_s <= POLARITY;
                        end if;
                    elsif((frequency_counter < frequency_division * 2)
                         and (frequency_counter >= frequency_division)) then
                        frequency_counter := frequency_counter + 1;
                        sclk_s <= POLARITY;
                        if(frequency_counter = frequency_division * 2) then
                            frequency_counter := 0;
                            count_clocks <= count_clocks + 1;
                            edge_LEADING <= '1';
                        end if;
                    end if;

                        if(PHASE = '0' and edge_TRAILING = '1') then
                            edge_TRAILING <= '0';
                            if(count_clocks < 8) then
                                MOSI <= rdata_sig(count_spi_bits);
                            else
                                MOSI <= '0';
                            end if;

                            count_spi_bits <= count_spi_bits - 1;
                            if(count_spi_bits = 0) then
                                count_spi_bits <= 0;
                            end if;
                        end if;
                        if(PHASE = '1' and edge_LEADING = '1') then
                            edge_LEADING <= '0';
                            if(count_clocks < 8) then
                                MOSI <= rdata_sig(count_spi_bits);
                            else
                                MOSI <= '0';
                            end if;
                            count_spi_bits <= count_spi_bits - 1;
                            if(count_spi_bits = 0) then
                                count_spi_bits <= 0;
                            end if;
                        end if;
                else
                    sclk_s <= POLARITY;
                    frequency_counter := 0;
                    edge_LEADING <= '1';
                    edge_TRAILING <= '0';
                    count_clocks <= 0;
                    count_spi_bits <= 7;
                    MOSI <= '0';
                end if;
            end if;
        end if;
    end process;

    STATES_p : process(clk)
    begin
        if(rising_edge(clk)) then
            if(clear = '1') then
                STATES <= "0001";
                start_MOSI <= '0';
                cs <= '1';
                SPI_BUSY_sig <= '0';
            else
                case STATES is
                    when "0001" =>
                        cs <= '1';  -- BACK TO 1!!!!!!!!!!!!!
                        SPI_BUSY_sig <= '0';
                        start_MOSI <= '0';
                        if(begin_TX = '1') then
                            cs <= '0';
                            STATES <= "0010";
                            SPI_BUSY_sig <= '1';
                        else
                            STATES <= "0001";
                        end if;
                    when "0010" =>
                        SPI_BUSY_sig <= '1';
                        start_MOSI <= '0';
                        STATES <= "0100";
                        cs <= '0';
                    when "0100" =>
                        cs <= '0';
                        start_MOSI <= '1';
                        SPI_BUSY_sig <= '1';
                        if(count_clocks = 8) then
                            start_MOSI <= '0';
                            STATES <= "1000";
                        end if;
                    when "1000" =>
                        STATES <= "0001";
                        start_MOSI <= '0';
                        SPI_BUSY_sig <= '1';
                    when others =>
                        cs <= '1';  -- BACK TO 1!!!!!!!!!!!!!
                        SPI_BUSY_sig <= '0';
                        start_MOSI <= '0';
                        STATES <= "0001";
                end case;
            end if;
        end if;
    end process;
    sclk <= sclk_s;
    SPI_TX_BUSY <= SPI_BUSY_sig;
end RTL;
