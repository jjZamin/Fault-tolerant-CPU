library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package commands_pkg is
    
constant SET_COL_ADDR : std_logic_vector(8 downto 0) := "000010101"; -- x"15"; 
constant SET_ROW_ADDR : std_logic_vector(8 downto 0) := "001110101"; --x"75"; 
constant SET_CONTRAST_A : std_logic_vector(8 downto 0) := "010000001"; -- x"81"; 
constant SET_CONTRAST_B : std_logic_vector(8 downto 0) := "010000010";--x"82"; 
constant SET_CONTRAST_C : std_logic_vector(8 downto 0) := "010000011";--x"83"; 
constant SET_MASTER_CURRENT : std_logic_vector(8 downto 0) := "010000111";--x"087"; 
constant SET_SECOND_PRECHARGE_SPEED_A : std_logic_vector(8 downto 0) := "010001010";--x"08A";     
constant SET_SECOND_PRECHARGE_SPEED_B : std_logic_vector(8 downto 0) := "010001011";--x"08B"; 
constant SET_SECOND_PRECHARGE_SPEED_C : std_logic_vector(8 downto 0) := "010001100";--x"08C";  
constant SET_REMAP : std_logic_vector(8 downto 0) := "010100000"; --x"0A0";
constant SET_DISP_STARTLINE : std_logic_vector(8 downto 0) := "010100001";--x"0A1";
constant SET_DISP_OFFSET : std_logic_vector(8 downto 0) := "010100010"; --x"0A2";
constant SET_DISP_MODE_NORMAL : std_logic_vector(8 downto 0) := "010100100";--x"0A4";
constant SET_DISP_MODE_GS63 : std_logic_vector(8 downto 0):= "010100101";--x"0A5"; 
constant SET_MUX_RATIO : std_logic_vector(8 downto 0) := "010101000";--x"0A8";
constant SET_DIM_MODE : std_logic_vector(8 downto 0) := "010101011";--x"0AB";     
constant SET_MASTER_CONFIG : std_logic_vector(8 downto 0) := "010101101";--x"0AD";     
constant SET_DISP_ON : std_logic_vector(8 downto 0) := "010101111";--x"0AF";
constant SET_DISP_OFF : std_logic_vector(8 downto 0) := "010101110";--x"0AE";
constant SET_POWER_SAVE_MODE : std_logic_vector(8 downto 0) := "010110000";--x"0B0";
constant SET_PHASE_ADJ : std_logic_vector(8 downto 0) := "010110001";--x"0B1";
constant SET_DISP_CLKDIV : std_logic_vector(8 downto 0) := "010110011";--x"0B3";
constant SET_PRECHARGE_LEVEL : std_logic_vector(8 downto 0) := "010111011";--x"0BB";
constant SET_V_COMH : std_logic_vector(8 downto 0) := "010111110";--x"0BE";
constant SET_CMD_LOCK : std_logic_vector(8 downto 0) := "011111101";--x"0FD";

constant SET_DEACT_SCOLL : std_logic_vector(8 downto 0) := "000101110";--x"02E";

-- draws
constant SET_FILL : std_logic_vector(8 downto 0) := "000100110";--x"026";
constant CLEAR_WINDOW : std_logic_vector(8 downto 0) := "000100101";--x"025";
constant DRAW_RECT : std_logic_vector(8 downto 0) := "000100010";--x"022";
constant DRAW_LINE : std_logic_vector(8 downto 0) := "000100001";--x"021";

-- colors [(1)CCCCCBBB(1)BBBAAAAA] -- BGR: first send MSBT, then LSBT
constant BLACK_PIX : std_logic_vector(17 downto 0) := "100000000100000000";
constant WHITE_PIX : std_logic_vector(17 downto 0) := "111111111111111111";
--
constant BLUE_PIX : std_logic_vector(17 downto 0) := "111111000100000000";
constant GREEN_PIX : std_logic_vector(17 downto 0) := "111111111111111111";
constant RED_PIX : std_logic_vector(17 downto 0) := "100000000100011111";

--
constant BLACK_ABC : std_logic_vector(8 downto 0) := "100000000";
constant WHITE_AC : std_logic_vector(8 downto 0) := "100111110";
constant WHITE_B : std_logic_vector(8 downto 0) := "100111111";

constant BLUE_A : std_logic_vector(8 downto 0) := "100110010";
constant GREEN_B : std_logic_vector(8 downto 0) := "100111100";
constant RED_C : std_logic_vector(8 downto 0) := "100101000";
---

constant NOP : std_logic_vector(8 downto 0) := "011100011";--x"0E3";

end package commands_pkg;