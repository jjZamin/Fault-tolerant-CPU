library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED.all;
use work.ALU_PKG.all;

entity ALU is
  generic (
        DATA_WIDTH : integer := DATA_WIDTH --see PKG
    );
  Port ( 
            A_in : in std_logic_vector(DATA_WIDTH - 1 downto 0);
            B_in : in std_logic_Vector(DATA_WIDTH - 1 downto 0);
            funct: in std_logic_Vector(3 downto 0);
            
            Res_MOD1 : out std_logic_vector(DATA_WIDTH - 1 downto 0);
            Res_MOD2 : out std_logic_vector(DATA_WIDTH - 1 downto 0);
            Res_MOD3 : out std_logic_vector(DATA_WIDTH - 1 downto 0)
  );
end ALU;

architecture RTL of ALU is
attribute dont_touch : string;
signal res_MOD1_final : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
signal res_MOD2_final : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0'); 
signal res_MOD3_final : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');  
-- UNTOUCHABLES !
attribute dont_touch of res_MOD1_final : signal is "true";
attribute dont_touch of res_MOD2_final : signal is "true";
attribute dont_touch of res_MOD3_final : signal is "true";

begin
    
    --TESTING !!!
    ALU: process(A_in, B_in, funct)
    begin
        case funct is
            when "0000" => --ADD
                res_MOD1_final <= std_logic_vector(signed(A_in) + signed(B_in));
                res_MOD2_final <= std_logic_vector(signed(A_in) + signed(B_in));
                res_MOD3_final <= std_logic_vector(signed(A_in) + signed(B_in));
            when "1000" => --SUB
                res_MOD1_final <= std_logic_vector(signed(A_in) - signed(B_in));
                res_MOD2_final <= std_logic_vector(signed(A_in) - signed(B_in));
                res_MOD3_final <= std_logic_vector(signed(A_in) - signed(B_in));
            when "0001" => --SLL(i)   
                res_MOD1_final <= std_logic_vector(shift_left(unsigned(A_in), to_integer(unsigned(B_in(4 downto 0)))));
                res_MOD2_final <= std_logic_vector(shift_left(unsigned(A_in), to_integer(unsigned(B_in(4 downto 0))))); 
                res_MOD3_final <= std_logic_vector(shift_left(unsigned(A_in), to_integer(unsigned(B_in(4 downto 0)))));
            when "0010" => --SLTI
                if(signed(A_in) < signed(B_in)) then
                    res_MOD1_final <= x"00000001";
                else
                    res_MOD1_final <= x"00000000";
                end if;
                if(signed(A_in) < signed(B_in)) then 
                    res_MOD2_final <= x"00000001";
                else
                    res_MOD2_final <= x"00000000";
                end if;
                if(signed(A_in) < signed(B_in)) then
                    res_MOD3_final <= x"00000001";
                else
                    res_MOD3_final <= x"00000000";
                end if;
            when "0011" => --SLTIU
                if(unsigned(A_in) < unsigned(B_in)) then
                    res_MOD1_final <= x"00000001";
                else
                    res_MOD1_final <= x"00000000";
                end if;
                if(unsigned(A_in) < unsigned(B_in)) then
                    res_MOD2_final <= x"00000001";
                else
                    res_MOD2_final <= x"00000000";
                end if;
                if(unsigned(A_in) < unsigned(B_in)) then 
                    res_MOD3_final <= x"00000001";
                else
                    res_MOD3_final <= x"00000000";
                end if;
            when "0100" => --XOR(i)
                res_MOD1_final <= (A_in xor B_in);
                res_MOD2_final <= (A_in xor B_in);
                res_MOD3_final <= (A_in xor B_in); 
            when "0101" => --SRL(i)
                res_MOD1_final <= std_logic_vector(shift_right(unsigned(A_in), to_integer(unsigned(B_in(4 downto 0))))); 
                res_MOD2_final <= std_logic_vector(shift_right(unsigned(A_in), to_integer(unsigned(B_in(4 downto 0)))));
                res_MOD3_final <= std_logic_vector(shift_right(unsigned(A_in), to_integer(unsigned(B_in(4 downto 0)))));
            when "1101" => --SRA(i)
                res_MOD1_final <= std_logic_vector(shift_right(signed(A_in), to_integer(unsigned(B_in(4 downto 0))))); 
                res_MOD2_final <= std_logic_vector(shift_right(signed(A_in), to_integer(unsigned(B_in(4 downto 0)))));
                res_MOD3_final <= std_logic_vector(shift_right(signed(A_in), to_integer(unsigned(B_in(4 downto 0)))));
            when "0110" => --OR(i)
                res_MOD1_final <= (A_in or B_in); 
                res_MOD2_final <= (A_in or B_in);
                res_MOD3_final <= (A_in or B_in);
            when "0111" => --AND(i)
                res_MOD1_final <= (A_in and B_in);
                res_MOD2_final <= (A_in and B_in);
                res_MOD3_final <= (A_in and B_in); 
            when others =>
                res_MOD1_final <= (others => '0');
                res_MOD2_final <= (others => '0');
                res_MOD3_final <= (others => '0');
        end case;
    end process;
    Res_MOD1 <= res_MOD1_final;
    Res_MOD2 <= res_MOD2_final;
    Res_MOD3 <= res_MOD3_final;
end RTL;
