library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all; 

package RegisterFile_pkg is
    constant DATA_WIDTH : natural := 32;
    constant REGISTERFILE_ADDR_WIDTH : natural := 5;
    constant NUMBER_OF_REGS: natural := 32;

    component RegisterFile is
        generic (
              DATA_WIDTH : integer := 32;
              REGISTERFILE_ADDR_WIDTH : integer := 5;
              NUMBER_OF_REGS: integer := 32 
              );
        Port ( 
              clk : in std_logic;
              clear : in std_logic;
              
              isb_rRegA_addr : in std_logic_vector(REGISTERFILE_ADDR_WIDTH - 1 downto 0);
              isb_rRegB_addr : in std_logic_vector(REGISTERFILE_ADDR_WIDTH - 1 downto 0);
              isb_wReg_addr : in std_logic_vector(REGISTERFILE_ADDR_WIDTH - 1 downto 0);
              isb_wData : in std_logic_vector(DATA_WIDTH - 1 downto 0); -- data + 1 paritybit;
              isb_we : in std_logic;
              isb_re : in std_logic;
              isb_rDataReg1 : out std_logic_vector(DATA_WIDTH - 1 downto 0); -- data + 1 paritybit;
              isb_rDataReg2 : out std_logic_vector(DATA_WIDTH - 1 downto 0); -- data + 1 paritybit (bit 32)
              
              -- Errors and TMR ON/OFF
              isVoter_OFF : out std_logic_vector(2 downto 0);        
              DISABLE_RegisterFileTMR : in std_logic; --enables TMR
              RegisterFileTMR_isDISABLED : out std_logic --enabled TMR?
        );
      end component;
end RegisterFile_pkg;