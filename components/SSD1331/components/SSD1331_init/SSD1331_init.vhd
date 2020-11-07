library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED.all;
use work.timer_pkg.all;
use work.commands_pkg.all;

entity SSD1331_init is
         generic(
                system_freq : natural := 18000000
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
end SSD1331_init;

architecture Behavioral of SSD1331_init is

signal cmd_count : integer := 0; 
constant nr_of_cmds : integer := 100;

type ROM_TYPE is array(0 to 100) of std_logic_vector(8 downto 0);

signal COMMANDS :
ROM_TYPE :=
            (
                SET_MASTER_CONFIG,
                "010001110",
                SET_DISP_OFF,
                                                 
                SET_CONTRAST_A,
                "010000000",--x"091",
                SET_CONTRAST_B,
                "010000000", --x"050",
                SET_CONTRAST_C,
                "010000000",--x"07D",
                                
                SET_MASTER_CURRENT, -- 000000110
                "000001110",   
                        
                SET_SECOND_PRECHARGE_SPEED_A,
                "010000001",--x"064", 
                SET_SECOND_PRECHARGE_SPEED_B,
                "010000010",--x"078", 
                SET_SECOND_PRECHARGE_SPEED_C,
                "010000011",--x"064",        
                                
                SET_REMAP,
                "001110010", --"x72"

                SET_DISP_STARTLINE,
                "000000000",--x"000",
                SET_DISP_OFFSET,
                "000000000",--x"000",
                
                SET_DISP_MODE_NORMAL,
                
                SET_MUX_RATIO,
                "000111111",--x"03F",

                SET_POWER_SAVE_MODE,
                "000000000",--"000001011",--x"00B",
                       
                SET_PHASE_ADJ, --<------------------
                "000110001",--x"031",
                                
                SET_DISP_CLKDIV,
                "011110000",--x"0F0", ---!!!

                SET_PRECHARGE_LEVEL,
                "000111010",--x"03A", --3e
                SET_V_COMH ,
                "000111110",--x"03e", -- 3e         
                                         
                SET_DEACT_SCOLL,                        
                SET_DISP_ON,
                
                NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP,
                NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP,
                
                CLEAR_WINDOW,
                "000000000",
                "000000000",
                "001011111",
                "000111111",               
------------------------------------------------------- 
                others => NOP
            );

signal DONE : std_logic := '1';

signal sclk_SPI : std_logic := '0';
signal cs_SPI : std_logic := '0';
signal MOSI_SPI : std_logic := '0';

-- power on
signal start_rst_timer :  std_logic := '0';
signal reset_rst_timer :  std_logic := '1';
signal rst_timer_flag  :  std_logic := '0';

-- cs timer
signal start_cs_timer :  std_logic := '0';
signal reset_cs_timer :  std_logic := '1';
signal cs_timer_flag  :  std_logic := '0';

signal loc_rst_s : std_logic := '0';
-----
signal STATES : std_logic_vector(4 downto 0) := "00001"; --IDLE: 00001, WAIT: 00010, SEND: 10000

begin

states_p : process(clk)
begin
    if(rising_edge(clk)) then
        if(clear = '1') then
            STATES <= "00001";
            ssd_dc <= '0'; --cmd
            spi_data <= (others => '0');
            spi_we <= '0';
            cmd_count <= 0;
            DONE <= '1';
            spi_addr <= (others => '0');
            start_rst_timer <= '0';
            reset_rst_timer <= '1';
            rst <= '0';
            loc_rst_s <= '0';
            start_cs_timer <= '0';
            reset_cs_timer <= '1';
            SSD1331_init_stall_cpu <= '0';
        else
            case STATES is
                when "00001" =>
                    rst <= '1';
                    loc_rst_s <= '0'; 
                    DONE <= '1';
                    cmd_count <= 0;
                    spi_addr <= (others => '0');
                    spi_data <= (others => '0');
                    spi_we <= '0';
                    
                    start_rst_timer <= '0';
                    reset_rst_timer <= '1';
                    start_cs_timer <= '0';
                    reset_cs_timer <= '1';
                    SSD1331_init_stall_cpu <= '0';                    
                    if(START = '1' and addr = x"FFFFFFFe") then
                        STATES <= "00010";
                        rst <= '0';
                        reset_rst_timer <= '0';
                        start_rst_timer <= '1';
                        DONE <= '0';
                        SSD1331_init_stall_cpu <= '1';
                    else
                        STATES <= "00001";
                    end if;
                           
                when "00010" => -- rst display
                    if(rst_timer_flag = '1') then
                        rst <= '1';
                        loc_rst_s <= '1';
                        if(loc_rst_s = '1') then
                            STATES <= "00100";
                            loc_rst_s <= '0'; 
                            start_rst_timer <= '0';
                            reset_rst_timer <= '1'; 
                        end if;
                    else
                        STATES <= "00010";
                    end if;                        
                when "00100" =>
                    if(SPI_IS_BUSY = '0' and DONE = '0') then
                        start_cs_timer <= '1';
                        reset_cs_timer <= '0';     
                        if(cs_timer_flag = '1') then
                            start_cs_timer <= '0';
                            reset_cs_timer <= '1';                                            
                            spi_data <= COMMANDS(cmd_count)(7 downto 0);
                            ssd_dc <= COMMANDS(cmd_count)(8);
                            spi_addr <= (others => '1');
                            spi_we <= '1';
                            cmd_count <= cmd_count + 1;
                            STATES <= "01000";
                        else
                            STATES <= "00100";
                        end if;
                    else
                        STATES <= "00100";
                    end if;
                when "01000" =>                    
                    spi_data <= (others => '0');
                    spi_addr <= (others => '0');
                    spi_we <= '0';
                    STATES <= "10000";
                when "10000" =>
                    if(cmd_count = (nr_of_cmds)) then
                        DONE <= '1';
                        SSD1331_init_stall_cpu <= '0';
                        STATES <= "00100";
                    else
                        DONE <= '0';
                        STATES <= "00100";
                    end if;
                when others =>
                    STATES <= "00001";
                    ssd_dc <= '0';
                    DONE <= '1';
            end case;     
        end if;
    end if;
end process;


  -- port maps for timer and SPI
  
 rst_timer : timer 
      generic map(
                timer_flag_ns => 500000, -- 5us!!
                system_freq => system_freq
      )
      
      Port map( 
                clk => clk,
                clear => clear,
                
                start_timer => start_rst_timer,
                reset_timer => reset_rst_timer,
      
                timer_flag => rst_timer_flag
      
      ); 

 cs_timer : timer 
      generic map(
                timer_flag_ns => 50*10, --ns
                system_freq => system_freq
      )
      
      Port map( 
                clk => clk,
                clear => clear,
                
                start_timer => start_cs_timer,
                reset_timer => reset_cs_timer,
      
                timer_flag => cs_timer_flag
      
      ); 
    
end Behavioral;
