library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

package ROMz_pkg is

    component ROMz is
      generic (
                ROM_BYTES : natural := 6*4;
                INSTRUCTION_WIDTH : natural := 32;
                DATA_WIDTH : natural := 8;
                ADDR_WIDTH : natural := 32
      );
      Port (                
                addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
                data_out : out std_logic_vector(INSTRUCTION_WIDTH - 1 downto 0)
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
                clear : in std_logic;
                we : in std_logic;
                data_in : in std_logic_vector(o_DATA_WIDTH - 1 downto 0);            
                addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
                data_out : out std_logic_vector(o_DATA_WIDTH - 1 downto 0);
                isb_wMEM_size : in std_logic_vector(1 downto 0)
      );
end component;    
    
end ROMz_pkg;
