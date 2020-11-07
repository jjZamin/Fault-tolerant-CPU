library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.RISCV_MCU_pkg.all;

entity RISCV_MCU is
              Port ( 
                        clk : in std_logic;
                        clear : in std_logic;
                        start : in std_logic;
                        DISABLE_SEU_MITIGATION : in std_logic;
                        
                        screen_spi_clk : out std_logic;
                        screen_spi_mosi : out std_logic;
                        screen_spi_cs : out std_logic;
                        screen_rst : out std_logic;
                        screen_dc : out std_logic;
              
                        test_spi_clk : out std_logic;
                        test_spi_mosi : out std_logic;
                        test_spi_cs : out std_logic;
                        test_program_on : out std_logic;
                        
                        
                        LED_clockcheck : out std_logic;
                        LED_screen_sclk : out std_logic;
                        --LED_test_sclk : out std_logic;
                        LED_test_any : out std_logic;
                        SCRUB : out std_logic
              
              );
end RISCV_MCU;

architecture RTL of RISCV_MCU is

--core
signal core_wdata : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
signal core_rdata : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
signal core_addr : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
signal core_we : std_logic := '0';
signal core_wMemSize : std_logic_vector(1 downto 0) := (others => '0');
signal core_instruction_in : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
signal core_program_counter : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
signal core_IRQ_ext : std_logic := '0';
signal core_IRQ_ext_code : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
signal test_spi_busy : std_logic := '0';
signal test_n_screen_stall : std_logic := '0';
signal screen_irq_s : std_logic := '0';
signal irq_ext_code_s : std_logic_vector(31 downto 0) := (others => '0');
signal clk_s : std_logic := '0';

--
signal screen_spi_clk_s : std_logic := '0';
signal test_spi_clk_s : std_logic := '0';
signal screen_dc_s : std_logic := '0';
signal cnt_check : std_logic := '0';

signal scrub_s : std_logic := '0';

signal scrub_sig : std_logic := '0';
begin
        
    test_program_on <= '1' when start = '1' else '0';
    
    test_n_screen_stall <= '1' when test_spi_busy = '1' or screen_irq_s = '1' else '0';
    core_IRQ_ext_code <= x"00000001" when test_spi_busy = '1' or screen_irq_s = '1' else (others => '0');
    -----------
 core: RISCV_CORE               
            generic map(
                        system_freq => SYSTEM_FREQ
            ) 
              Port map( 
                        clk => clk_s,
                        clear => clear,
                        start => start,
                        DISABLE_SEU_MITIGATION => DISABLE_SEU_MITIGATION,
                        
                        isb_wData => core_wdata,
                        isb_rData => core_rdata,
                        isb_we => core_we,
                        isb_rd => open,
                        isb_addr => core_addr,
                        isb_wMEM_size => core_wMemSize,
                        
                        isb_instruction => core_instruction_in,
                        isb_ProgramCounter => core_program_counter,
                        
                        IRQ_ext => test_n_screen_stall,
                        IRQ_ext_code => core_IRQ_ext_code,                    
                        SCRUB => scrub_sig
              );
    
screen: RISCV_SCREEN 
             generic map(
                        system_freq => SYSTEM_FREQ
             )
             Port map(
                        clk => clk_s,
                        clear => clear,

                        screen_addr => core_addr,
                        screen_we => core_we,
                        screen_spi_wdata => core_wdata(23 downto 0),

                        screen_spi_MOSI => screen_spi_mosi,
                        screen_spi_CS => screen_spi_cs,
                        screen_spi_DC => screen_dc_s,
                        screen_spi_CLK => screen_spi_clk_s,
                        screen_rst => screen_rst,
                        
                        screen_irq_code => open,
                        screen_stall_cpu => screen_irq_s
             );


ram: RAMz 
      generic map(

                ROM_BYTES => 600,
                INSTRUCTION_WIDTH => 32,
                o_DATA_WIDTH => 32,
                DATA_WIDTH => 8,
                ADDR_WIDTH => 32
      )
      Port map(    
                clk => clk_s,
                we => core_we,
                data_in => core_wdata,       
                addr => core_addr,
                data_out => core_rdata,
                isb_wMEM_size => core_wMemSize
      );

rom: ROMz 
      generic map(
                ROM_BYTES => 3500,
                INSTRUCTION_WIDTH => 32,
                DATA_WIDTH => 8,
                ADDR_WIDTH => 32
      )
      Port map(                
                addr => core_program_counter,
                data_out => core_instruction_in
      );

test_spi_p: SPI 
  generic map(            
            --bit[1]-> polarity
            -- [0: idle -> 0, leading -> rising] 
            -- [1: idle -> 1, leading -> falling] ...  
            --bit[0]-> phase         
            -- [0: datachange on: trailing,; slave samples on leading]
            -- [1: datachange on: leading,; slave samples on trailing]
            system_frequency => SYSTEM_FREQ,
            spi_frequency => 128,
            addr => SPI_ADDR
  )
  
  Port map( 
            POLARITY => '0',
            PHASE => '1',
            
            clk => clk_s,
            clear => clear,
            isb_wdata => core_wdata,
            isb_addr => core_addr, 
            isb_we => core_we,
            SPI_TX_BUSY => test_spi_busy,
            
            sclk => test_spi_clk_s,
            cs => test_spi_cs,
            MOSI => test_spi_mosi
  );
  
  
  cntt: process(clk_s)
  variable cnt : integer := 0;
  begin
    if(rising_edge(clk_s)) then
       if(cnt < 20000000) then
           cnt := cnt + 1; 
       else
           cnt_check <= not cnt_check;    
           cnt := 0;
       end if; 
    end if;
  end process;
  screen_spi_clk <= screen_spi_clk_s;
  test_spi_clk <= test_spi_clk_s;
  screen_dc <= screen_dc_s;   
     
  LED_clockcheck <= cnt_check;
  LED_screen_sclk <= screen_spi_clk_s;
  --LED_test_sclk <= SCRUB;
  LED_test_any <= screen_dc_s;

  SCRUB <= scrub_sig;


clkkz: clk_wiz_0 
  port map(
    clk_out1 => clk_s,
    reset => '0',
    locked => open,
    clk_in1 => clk
  );


end RTL;