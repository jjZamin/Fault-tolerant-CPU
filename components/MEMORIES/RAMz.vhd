library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity RAMz is
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
end RAMz;

architecture Behavioral of RAMz is

    signal addr_s : std_logic_vector(31 downto 0) := (others => '0');

    type RAM_TYPE is array(0 to ROM_BYTES - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
    
    signal RAMz : 
    RAM_TYPE :=
                (
                x"08", x"01", x"00", x"00", --begin program here when the system us on 
                                            --x"08", x"01", x"00", x"00",
                                                                         
                x"0a", x"00", x"00", x"00", --4
                x"0a", x"00", x"00", x"00", --8                
                x"01", x"00", x"00", x"00", --12                
                x"00", x"00", x"00", x"00", --16
                x"00", x"00", x"00", x"00", --20                   
                x"00", x"00", x"00", x"00", --24                                   
                x"00", x"00", x"00", x"00", --28
                x"00", x"00", x"00", x"00", --32                   
                x"00", x"00", x"00", x"00", --36
                x"00", x"00", x"00", x"00", --40                   
                x"00", x"00", x"00", x"00", --44
                x"00", x"00", x"00", x"00", --48                   
                x"00", x"00", x"00", x"00", --52
                x"00", x"00", x"00", x"00", --56                   
                x"00", x"00", x"00", x"00", --60
                x"00", x"00", x"00", x"00", --64                   
                x"00", x"00", x"00", x"00", --68
                x"00", x"00", x"00", x"00", --72                   
                x"00", x"00", x"00", x"00", --76
                x"05", x"00", x"00", x"00", --80                   
                x"00", x"00", x"00", x"00", --84
                x"00", x"00", x"00", x"00", --88                   
                x"00", x"00", x"00", x"00", --92
                x"00", x"00", x"00", x"00", --96                   
                x"00", x"00", x"00", x"00", --100
                x"00", x"00", x"00", x"00", --104                   
                x"00", x"00", x"00", x"00", --108
                x"00", x"00", x"00", x"00", --112                   
                x"00", x"00", x"00", x"00", --116
                x"00", x"00", x"00", x"00", --120                   
                x"00", x"00", x"00", x"00", --124        
                x"00", x"00", x"00", x"00", --128
                x"00", x"00", x"00", x"00", --132
                ---                   
                x"00", x"2D", x"31", x"01", --136 ->>>>>> 20000000
                x"00", x"94", x"35", x"77", --140 ------> 2 s, 2000000000 ns                   
                x"00", x"CA", x"9A", x"3B", --144 ------> 1 s,       
                x"00", x"65", x"CD", x"1D", --148 ------> 0.5 s
                --- new drawing ---                                               
                x"00", x"00", x"00", x"00", --152 ------> fx rect: start X      
                x"00", x"00", x"00", x"00", --156 ------> rect: start y                        
                x"00", x"00", x"00", x"00", --160 ------> rect: end X      
                x"00", x"00", x"00", x"00", --164 ------> rect: end y
                x"00", x"00", x"00", x"00", --168 ------> rect: color edge      
                x"00", x"00", x"00", x"00", --172 ------> rect: color fill                                                
                x"E3", x"E3", x"E3", x"E3", --176 ------> NOP screen               
                
                ----------- symbols ascii---------------
                x"20", x"21", x"22", x"23", --180 ------> x20: space, x21: ! ...
                x"24", x"25", x"26", x"27", --184 ------> x20: space, x21: ! ...
                x"28", x"29", x"2A", x"2B", --188 ------> x20: space, x21: ! ...
                x"2C", x"2D", x"2E", x"2F", --192 ------> x20: space, x21: ! ...
                x"30", x"31", x"32", x"33", --196 ------> x20: space, x21: ! ...
                x"34", x"35", x"36", x"37", --200 ------> x20: space, x21: ! ...
                x"38", x"39", x"3A", x"3B", --204 ------> x20: space, x21: ! ...
                x"3C", x"3D", x"3E", x"3F", --208 ------> x20: space, x21: ! ...
                x"40", x"41", x"42", x"43", --212 ------> x20: space, x21: ! ...
                x"44", x"45", x"46", x"47", --216 ------> x20: space, x21: ! ...
                x"48", x"49", x"4A", x"4B", --220 ------> x20: space, x21: ! ...
                x"4C", x"4D", x"4E", x"4F", --224 ------> x20: space, x21: ! ...
                x"50", x"51", x"52", x"53", --228 ------> x20: space, x21: ! ...
                x"54", x"55", x"56", x"57", --232 ------> x20: space, x21: ! ...
                x"58", x"59", x"5A", x"5B", --236 ------> x20: space, x21: ! ...
                x"5C", x"5D", x"5E", x"5F", --240 ------> x20: space, x21: ! ...
                x"7F", x"00", x"00", x"00", --244 byte: delete ..... -> 280
                x"00", x"00", x"00", x"00", --248                   
                x"00", x"00", x"00", x"00", --252
                x"00", x"00", x"00", x"00", --256                   
                x"00", x"00", x"00", x"00", --260
                x"00", x"00", x"00", x"00", --264                   
                x"00", x"00", x"00", x"00", --268
                x"00", x"00", x"00", x"00", --272                   
                x"00", x"00", x"00", x"00", --276
                x"FF", x"00", x"00", x"00", --280         
                
                ----------------------------------
                --284 -> 412, saved registers
                x"00", x"00", x"00", x"00", --284                   
                x"00", x"00", x"00", x"00", --288                   
                x"00", x"00", x"00", x"00", --292
                x"00", x"00", x"00", x"00", --296                   
                x"00", x"00", x"00", x"00", --300
                x"00", x"00", x"00", x"00", --304                   
                x"00", x"00", x"00", x"00", --308
                x"00", x"00", x"00", x"00", --312        
                x"00", x"00", x"00", x"00", --316
                x"00", x"00", x"00", x"00", --320                   
                x"00", x"00", x"00", x"00", --324                                   
                x"00", x"00", x"00", x"00", --328
                x"00", x"00", x"00", x"00", --332                   
                x"00", x"00", x"00", x"00", --336
                x"00", x"00", x"00", x"00", --340                   
                x"00", x"00", x"00", x"00", --344
                x"00", x"00", x"00", x"00", --348                   
                x"00", x"00", x"00", x"00", --352
                x"00", x"00", x"00", x"00", --356                   
                x"00", x"00", x"00", x"00", --360
                x"00", x"00", x"00", x"00", --364                   
                x"00", x"00", x"00", x"00", --368
                x"00", x"00", x"00", x"00", --372                   
                x"00", x"00", x"00", x"00", --376
                x"00", x"00", x"00", x"00", --380                   
                x"00", x"00", x"00", x"00", --384
                x"00", x"00", x"00", x"00", --388                   
                x"00", x"00", x"00", x"00", --392
                x"00", x"00", x"00", x"00", --396                   
                x"00", x"00", x"00", x"00", --400
                x"00", x"00", x"00", x"00", --404
                x"00", x"00", x"00", x"00", --408
                x"00", x"00", x"00", x"00", --412                    
                --416 -> 460, return addresses
                x"00", x"00", x"00", x"00", --416
                x"00", x"00", x"00", x"00", --420                   
                x"00", x"00", x"00", x"00", --424                                   
                x"00", x"00", x"00", x"00", --428
                x"00", x"00", x"00", x"00", --432                   
                x"00", x"00", x"00", x"00", --436
                x"00", x"00", x"00", x"00", --440                   
                x"00", x"00", x"00", x"00", --444
                x"00", x"00", x"00", x"00", --448                   
                x"00", x"00", x"00", x"00", --452
                x"00", x"00", x"00", x"00", --456                   
                x"00", x"00", x"00", x"00", --460                
                
                ----------------------------------
                -- screen commands --
                x"23", x"25", x"22", x"26", --464                   
                x"21", x"E3", x"E3", x"E3", --468
                ----------------------------------
                -- saved drawing coordinates --
                x"00", x"00", x"00", x"00", --472                   
                x"00", x"00", x"00", x"00", --476
                x"00", x"00", x"00", x"00", --480                   
                x"00", x"00", x"00", x"00", --484
                x"00", x"00", x"00", x"00", --488                   
                x"00", x"00", x"00", x"00", --492
                x"00", x"00", x"00", x"00", --496                   
                x"00", x"00", x"00", x"00", --500               
                ----------------------------------
                -- IRQ ruts --
                x"00", x"00", x"00", x"00", --504
                x"00", x"00", x"00", x"00", --508
                x"00", x"00", x"00", x"00", --512                    
                x"00", x"00", x"00", x"00", --516
                x"00", x"00", x"00", x"00", --520
                ---------------------------------
                --test reg for SPI test                   
                x"00", x"00", x"00", x"00", --524     
                ----texts-----------------    
                x"52", x"49", x"53", x"43", --528 -- RISC-V     
                x"2D", x"56", x"00", x"00", --532                 
                    others => x"00"
                );

begin
    
    
    data_out(7 downto 0) <= RAMz(to_integer(unsigned(addr(7 downto 0))));       
    data_out(15 downto 8) <= RAMz(to_integer(unsigned(addr(7 downto 0))) + 1); 
    data_out(23 downto 16) <= RAMz(to_integer(unsigned(addr(7 downto 0))) + 2);
    data_out(31 downto 24) <= RAMz(to_integer(unsigned(addr(7 downto 0))) + 3);
    
    wdata: process(clk)
    begin
        if(rising_edge(clk)) then
          if(we = '1') then
            if(to_integer(unsigned(addr)) > ROM_BYTES) then
                RAMz(200) <= x"0A";
            else
                case isb_wMEM_size is
                    when "00" =>
                        RAMz(to_integer(unsigned(addr(7 downto 0)))) <= data_in(7 downto 0);
                    when "01" =>
                        RAMz(to_integer(unsigned(addr(7 downto 0)))) <= data_in(7 downto 0);
                        RAMz(to_integer(unsigned(addr(7 downto 0))) + 1) <= data_in(15 downto 8);
                    when "10" =>
                        RAMz(to_integer(unsigned(addr(7 downto 0)))) <= data_in(7 downto 0);
                        RAMz(to_integer(unsigned(addr(7 downto 0))) + 1) <= data_in(15 downto 8);    
                        RAMz(to_integer(unsigned(addr(7 downto 0))) + 2) <= data_in(23 downto 16);
                        RAMz(to_integer(unsigned(addr(7 downto 0))) + 3) <= data_in(31 downto 24);                                                        
                    when others =>
                        RAMz(0) <= (others => '0');
                    end case;
                 end if;
             end if;      
        end if;    
    end process;
    
    
end Behavioral;
