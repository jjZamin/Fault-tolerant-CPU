library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use ieee.numeric_std.all;


package SPI_pkg is 
    constant SYSTEM_FREQ : natural := 125000000;
    constant SPI_FREQ : natural := 125000000/4; --256;
    constant SPI_ADDR : std_logic_vector(31 downto 0) := x"FFFFFFFF";

    component SPI is
      generic(            
                --bit[1]-> polarity
                -- [0: idle -> 0, leading -> rising] 
                -- [1: idle -> 1, leading -> falling] ...  
                --bit[0]-> phase         
                -- [0: datachange on: trailing,; slave samples on leading]
                -- [1: datachange on: leading,; slave samples on trailing]
                system_frequency : natural := SYSTEM_FREQ;
                spi_frequency : natural := SPI_FREQ;
                addr : std_logic_vector(31 downto 0) := SPI_ADDR
      );
      
      Port ( 
                POLARITY : in std_logic;
                PHASE : in std_logic;
                
                clk : in std_logic;
                clear : in std_logic;
                isb_wdata : in std_logic_vector(31 downto 0);
                isb_addr : in std_logic_vector(31 downto 0); 
                isb_we : in std_logic;
                SPI_TX_BUSY : out std_logic;
                
                sclk : out std_logic;
                cs : out std_logic;
                MOSI : out std_logic
      );
    end component;
end package SPI_pkg;
