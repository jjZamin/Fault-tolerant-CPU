library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package RISCV_SCREEN_pkg is
    component SSD1331_init is
          generic(
                system_freq : natural := 20000000
        );
        Port ( 
                    clk : in std_logic;
                    clear : in std_logic;
                    start : in std_logic;        
                    addr : in std_logic_vector(31 downto 0); -- FFFFFFFe
                    
                    spi_addr : out std_logic_vector(31 downto 0);
                    spi_data : out std_logic_vector(7 downto 0);
                    spi_we : out std_logic;
                    SPI_IS_BUSY : in std_logic;
                  
                    SSD1331_init_stall_cpu : out std_logic;
                    
                    ssd_dc : out std_logic;  
                    rst : out std_logic
        );
end component;

-- Ghennadie Mazin
component SSD1331_ascii is --ascii --addr: x"fffffffd"
      generic(
                system_freq : natural := 31250000
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
end component;


end RISCV_SCREEN_pkg;

