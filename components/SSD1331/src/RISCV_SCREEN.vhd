library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED.all;
use work.RISCV_SCREEN_pkg.all;
use work.screen_SPI_pkg.all;

--****************
-- By Ghennadie Mazin, final project.
--****************

entity RISCV_SCREEN is
            generic (
                        system_freq : natural := 18000000
            );
             Port (
                        clk : in std_logic;
                        clear : in std_logic;

                        screen_addr : in std_logic_vector(31 downto 0);
                        screen_we : in std_logic;
                        screen_spi_wdata : in std_logic_vector(23 downto 0);

                        screen_spi_MOSI : out std_logic;
                        screen_spi_CS : out std_logic;
                        screen_spi_DC : out std_logic;
                        screen_spi_CLK : out std_logic;
                        screen_rst : out std_logic;
                        
                        screen_irq_code : out std_logic_vector(31 downto 0);
                        screen_stall_cpu : out std_logic

             );
end RISCV_SCREEN;

architecture Behavioral of RISCV_SCREEN is

signal rcvd_addr : std_logic_vector(31 downto 0) := (others => '0');

signal screen_dc_init : std_logic := '0';
signal screen_dc_ascii : std_logic := '0';

signal screen_spi_busy : std_logic := '0';
signal screen_spi_addr_main : std_logic_vector(31 downto 0) := (others => '0');
signal screen_spi_addr_init : std_logic_vector(31 downto 0) := (others => '0');
signal screen_spi_addr_ascii : std_logic_vector(31 downto 0) := (others => '0');

signal screen_spi_wdata_main : std_logic_vector(7 downto 0) := (others => '0');
signal screen_spi_wdata_init : std_logic_vector(7 downto 0) := (others => '0');
signal screen_spi_wdata_ascii : std_logic_vector(7 downto 0) := (others => '0');

signal screen_spi_we_main : std_logic := '0';
signal screen_spi_we_init : std_logic := '0';
signal screen_spi_we_ascii : std_logic := '0';

signal init_stallz : std_logic := '0';
signal ascii_stallz : std_logic := '0';

begin


screen_spi_addr_main <= screen_spi_addr_init when init_stallz = '1' else
                        screen_spi_addr_ascii when ascii_stallz = '1' else
                        screen_addr;

screen_spi_we_main <=   screen_spi_we_init when init_stallz = '1' else
                        screen_spi_we_ascii when ascii_stallz = '1' else
                        screen_we;

screen_spi_wdata_main <= screen_spi_wdata_init when init_stallz = '1' else
                        screen_spi_wdata_ascii when ascii_stallz = '1' else
                        screen_spi_wdata(7 downto 0);

screen_stall_cpu <= '1' when init_stallz = '1' or ascii_stallz = '1' or screen_spi_busy = '1' else
                        '0';

screen_irq_code <= x"00000001" when init_stallz = '1' or ascii_stallz = '1' or screen_spi_busy = '1' else
                        (others => '0'); -- controller knows that it's screen sending IRQ


screen_spi_DC <= '0' when init_stallz = '1' else screen_dc_ascii when ascii_stallz = '1' else '0';


init: SSD1331_init
  generic map(
           system_freq => system_freq
  )
        Port map (
                    clk => clk,
                    clear => clear,
                    start => screen_we,
                    addr => screen_addr,

                    spi_addr => screen_spi_addr_init,
                    spi_data => screen_spi_wdata_init(7 downto 0),
                    spi_we => screen_spi_we_init,
                    SPI_IS_BUSY => screen_spi_busy,

                    SSD1331_init_stall_cpu => init_stallz,

                    ssd_dc => open,
                    rst => screen_rst
        );

asccii : SSD1331_ascii
  generic map(
           system_freq => system_freq
  )
        Port map (
                  clk => clk,
                  clear => clear,
                  cmd => screen_spi_wdata(23 downto 0),
                  addr => screen_addr,
                  we => screen_we,
                  SPI_IS_BUSY => screen_spi_busy,

                  spi_addr => screen_spi_addr_ascii,
                  spi_data => screen_spi_wdata_ascii,
                  spi_we => screen_spi_we_ascii,

                  ssd_dc => screen_dc_ascii,
                  ascii_stall_cpu => ascii_stallz
        );




SPI_pm: screen_SPI
  generic map(
            --bit[1]-> polarity
            -- [0: idle -> 0, leading -> rising]
            -- [1: idle -> 1, leading -> falling] ...
            --bit[0]-> phase
            -- [0: datachange on: trailing,; slave samples on leading]
            -- [1: datachange on: leading,; slave samples on trailing]
            system_frequency => system_freq,
            spi_frequency => 100000,
            addr => SPI_ADDR
  )

  Port map(
            POLARITY => '1',
            PHASE => '1',

            clk => clk,
            clear => clear,
            isb_wdata => screen_spi_wdata_main,
            isb_addr => screen_spi_addr_main,
            isb_we => screen_spi_we_main,
            SPI_TX_BUSY => screen_spi_busy,

            sclk => screen_spi_CLK,
            cs => screen_spi_CS,
            MOSI => screen_spi_MOSI
  );

end Behavioral;
