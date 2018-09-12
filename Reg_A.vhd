
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Reg_A is
  Port (  clk, rst,  RA_L, RA_E : in std_logic;
          A : in std_logic_vector(7 downto 0);
          reg_out : out std_logic_vector(7 downto 0));
end Reg_A;

architecture Behavioral of Reg_A is
signal dout: std_logic_vector(7 downto 0);
begin

reg_out <= dout when RA_E = '1' else
            (others=> 'Z') ;
             
mcndreg: process(clk)
begin
if (clk'event and clk='1') then
    if (rst = '1') then dout <= (others => '0');
    elsif (RA_L = '1') then dout <= A;
    end if;
end if;
end process;

end Behavioral;
