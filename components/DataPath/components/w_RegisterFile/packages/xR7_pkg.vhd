library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

package xR7_pkg is

    type REG_TYPE is array (0 to 31) of std_logic_vector(31 downto 0);

    component xR7 is
        generic(
                DATA_WIDTH : natural := 32
        );


        Port (
                clk : in std_logic;
                clear : in std_logic;
                ---
                STOP_CLOCK : in std_logic;
                load_to_regfile : in std_logic;
                load_from_xRn_addr : in std_logic_vector(2 downto 0);
                Reg_File_In : in REG_TYPE;

                xRn_to_regfile : out REG_TYPE
        );
end component;

end xR7_pkg;
