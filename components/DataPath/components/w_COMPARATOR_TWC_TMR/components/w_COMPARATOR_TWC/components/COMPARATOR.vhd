library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED.all;

--****************
-- By Ghennadie Mazin, final project.
--****************

entity COMPARATOR is
    generic (
            DATA_WIDTH : natural := 32
    );
    Port ( 
           R1_in : in std_logic_vector(DATA_WIDTH - 1 downto 0);
           R2_in : in std_logic_vector(DATA_WIDTH - 1 downto 0);
           branch_flags_MOD1 : out std_logic_vector(5 downto 0);
           branch_flags_MOD2 : out std_logic_vector(5 downto 0);
           branch_flags_MOD3 : out std_logic_vector(5 downto 0);
           funct: in std_logic_vector(3 downto 0)
    );
end COMPARATOR;

architecture RTL of COMPARATOR is
    attribute dont_touch : string;
    signal res_MOD1_final : std_logic_vector(5 downto 0) := (others => '0');
    signal res_MOD2_final : std_logic_vector(5 downto 0) := (others => '0'); 
    signal res_MOD3_final : std_logic_vector(5 downto 0) := (others => '0');  
    -- UNTOUCHABLES !
    
    attribute dont_touch of res_MOD1_final : signal is "true";
    attribute dont_touch of res_MOD2_final : signal is "true";
    attribute dont_touch of res_MOD3_final : signal is "true";
begin

    --bEQ
    res_MOD1_final(0)  <= '1' when (signed(R1_in) = signed(R2_in)) and funct = "0000" else '0';
    res_MOD2_final(0)  <= '1' when (signed(R1_in) = signed(R2_in)) and funct = "0000" else '0'; 
    res_MOD3_final(0)  <= '1' when (signed(R1_in) = signed(R2_in)) and funct = "0000" else '0';
    --bNE
    res_MOD1_final(1)  <= '1' when (signed(R1_in) /= signed(R2_in)) and funct = "1111" else '0'; 
    res_MOD2_final(1)  <= '1' when (signed(R1_in) /= signed(R2_in)) and funct = "1111" else '0';
    res_MOD3_final(1)  <= '1' when (signed(R1_in) /= signed(R2_in)) and funct = "1111" else '0'; 
    --bLT
    res_MOD1_final(2)  <= '1' when (signed(R1_in) < signed(R2_in)) and funct = "1001" else '0';
    res_MOD2_final(2)  <= '1' when (signed(R1_in) < signed(R2_in)) and funct = "1001" else '0'; 
    res_MOD3_final(2)  <= '1' when (signed(R1_in) < signed(R2_in)) and funct = "1001" else '0';
    --bGE    
    res_MOD1_final(3)  <= '1' when ((signed(R1_in) = signed(R2_in)) or (signed(R1_in) > signed(R2_in))) 
    and funct = "1010"
    else '0';
    res_MOD2_final(3)  <= '1' when ((signed(R1_in) = signed(R2_in)) or (signed(R1_in) > signed(R2_in))) 
    and funct = "1010"
    else '0';
    res_MOD3_final(3)  <= '1' when ((signed(R1_in) = signed(R2_in)) or (signed(R1_in) > signed(R2_in))) 
    and funct = "1010"
    else '0';
    --bLTU
    res_MOD1_final(4)  <= '1' when (unsigned(R1_in) < unsigned(R2_in)) and funct = "0001" else '0';
    res_MOD2_final(4)  <= '1' when (unsigned(R1_in) < unsigned(R2_in)) and funct = "0001" else '0'; 
    res_MOD3_final(4)  <= '1' when (unsigned(R1_in) < unsigned(R2_in)) and funct = "0001" else '0'; 
    --bGEU    
    res_MOD1_final(5)  <= '1' when ((unsigned(R1_in) = unsigned(R2_in)) or (unsigned(R1_in) > unsigned(R2_in))) 
    and funct = "0010"
    else '0';
    res_MOD2_final(5)  <= '1' when ((unsigned(R1_in) = unsigned(R2_in)) or (unsigned(R1_in) > unsigned(R2_in))) 
    and funct = "0010" 
    else '0';
    res_MOD3_final(5)  <= '1' when ((unsigned(R1_in) = unsigned(R2_in)) or (unsigned(R1_in) > unsigned(R2_in))) 
    and funct = "0010"
    else '0';

    branch_flags_MOD1 <= res_MOD1_final;
    branch_flags_MOD2 <= res_MOD2_final;
    branch_flags_MOD3 <= res_MOD3_final;
    
end RTL;
