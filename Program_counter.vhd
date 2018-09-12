
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity Program_counter is
 Port (din, PC_RST: in std_logic_vector(7 downto 0);
        PC_OFFSET : in std_logic_vector(3 downto 0);
        PC_IS: in std_logic_vector(1 downto 0);
         rst, clk, PC_L, PC_E: in std_logic;
        PC_out : out std_logic_vector(7 downto 0)
         );
end Program_counter;

architecture Behavioral of Program_counter is
signal  PC_INC_1 :  std_logic_vector(7 downto 0);
signal  PC_out_reg,add :  std_logic_vector(7 downto 0);
signal  A :  std_logic_vector(7 downto 0);
begin
add <= x"01" when PC_IS(0) = '0' ELSE (PC_OFFSET(3) & PC_OFFSET(3) & PC_OFFSET(3) & PC_OFFSET(3) & PC_OFFSET(3 downto 0));
A <= PC_out_reg + add when PC_IS = "00" else
    PC_out_reg + add when PC_IS = "01" else
    din when PC_IS = "10" else
    PC_out_reg;
PC_out <= PC_out_reg when PC_E = '1' else
            (others=> 'Z') ;
pc_reg: process(clk)
begin
if (clk'event and clk='1') then
    if (rst = '1') then PC_out_reg <= PC_RST;
    elsif (PC_L = '1') then PC_out_reg <= A;
    end if;
end if;
end process;
end Behavioral;
