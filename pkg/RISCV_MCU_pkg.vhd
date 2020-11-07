
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package RISCV_MCU_pkg is
    
    constant DATA_WIDTH : natural := 32;
    constant SYSTEM_FREQ : natural := 20000000;
    constant SPI_FREQ : natural :=  256;
    constant SPI_ADDR : std_logic_vector(31 downto 0) := x"FFFFFFF0"; --test SPI addr
    
    component RISCV_CORE is
              generic (
                        system_freq : natural := SYSTEM_FREQ
            );
              Port ( 
                        clk : in std_logic;
                        clear : in std_logic;
                        start : in std_logic;
                        DISABLE_SEU_MITIGATION : in std_logic;
                        
                        isb_wData : out std_logic_vector(DATA_WIDTH - 1 downto 0);
                        isb_rData : in std_logic_vector(DATA_WIDTH - 1 downto 0);
                        isb_we : out std_logic;
                        isb_rd : out std_logic;
                        isb_addr : out std_logic_vector(DATA_WIDTH - 1 downto 0);
                        isb_wMEM_size : out std_logic_vector(1 downto 0);
                        
                        isb_instruction : in std_logic_vector(DATA_WIDTH - 1 downto 0);
                        isb_ProgramCounter : out std_logic_vector(DATA_WIDTH - 1 downto 0);
                        
                        IRQ_ext : in std_logic;
                        IRQ_ext_code : in std_logic_vector(DATA_WIDTH - 1 downto 0);                       
                        SCRUB : out std_logic              
              );
end component;

component RISCV_SCREEN is
            generic (
                        system_freq : natural := SYSTEM_FREQ
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
end component;

component RAMz is
      generic (

                ROM_BYTES : natural := 800;
                INSTRUCTION_WIDTH : natural := 32;
                o_DATA_WIDTH : natural := 32;
                DATA_WIDTH : natural := 8;
                ADDR_WIDTH : natural := 32
      );
      Port (    
                clk : in std_logic;
                we : in std_logic;
                data_in : in std_logic_vector(o_DATA_WIDTH - 1 downto 0);            
                addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
                data_out : out std_logic_vector(o_DATA_WIDTH - 1 downto 0);
                isb_wMEM_size : in std_logic_vector(1 downto 0)
      );
end component;


component ROMz is
      generic (
                ROM_BYTES : natural := 4000;
                INSTRUCTION_WIDTH : natural := 32;
                DATA_WIDTH : natural := 8;
                ADDR_WIDTH : natural := 32
      );
      Port (                
                addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
                data_out : out std_logic_vector(INSTRUCTION_WIDTH - 1 downto 0)
      );
end component;

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
            addr : std_logic_vector(31 downto 0) :=SPI_ADDR
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

component clk_wiz_0 is
  port (
    clk_out1 : out STD_LOGIC;
    reset : in STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in1 : in STD_LOGIC
  );
end component;


end package;
