
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PC_TB is
--  Port ( );
end PC_TB;

architecture Behavioral of PC_TB is
component Program_counter 
 Port (din, PC_RST : in std_logic_vector(7 downto 0);
 PC_OFFSET : in std_logic_vector(3 downto 0);
        PC_IS: in std_logic_vector(1 downto 0);
         rst, clk, PC_L, PC_E: in std_logic;
        PC_out : out std_logic_vector(7 downto 0)
         );
end component;



--input
signal din_tb, PC_RST_tb :  std_logic_vector(7 downto 0);
signal PC_OFFSET_tb: std_logic_vector(3 downto 0);
signal PC_IS_tb: std_logic_vector(1 downto 0);
signal rst_tb, clk_tb, PC_L_tb, PC_E_tb:  std_logic;
signal PC_out_tb :  std_logic_vector(7 downto 0);
--inout
signal dbus_tb: STD_LOGIC_VECTOR(7 downto 0); 
--time parameter
constant clk_half: time:= 10ns;
constant delay: time:= 20ns;
begin
uut: Program_counter port map(din_tb, PC_RST_tb, PC_OFFSET_tb,PC_IS_tb,rst_tb, clk_tb, PC_L_tb, PC_E_tb,PC_out_tb);
PC_RST_tb <= "00000001";
clk_proc: process
    begin
        clk_tb<='1';
        wait for clk_half;
        clk_tb<='0';
        wait for clk_half;
    end process;
test_proc: process
    begin
        wait for 100ns; 
        rst_tb<='1';
        PC_IS_tb<="00";        
        PC_E_tb<='0'; 
        PC_L_tb<='1';       
        wait for delay;
        PC_E_tb<='1';
        rst_tb<='0';
        PC_L_tb<='0';
        wait for delay;
        PC_L_tb<='1';
        PC_E_tb<='0';
        wait for delay;
        PC_E_tb<='1';
        PC_L_tb<='0';
        wait for delay;
        PC_IS_tb <="00";
        PC_L_tb <= '1';
        PC_E_tb<='0';
        wait for delay;
        PC_E_tb<='1';
        PC_L_tb<='0';
        wait for delay;
        PC_OFFSET_tb<="0010";
        PC_IS_tb <="01";
        PC_L_tb <= '1';
        PC_E_tb<='0';
        wait for delay;
        PC_E_tb<='1';
        PC_L_tb <= '0';
        wait for delay;
        din_tb <="10100101";
        PC_IS_tb <="10";
        PC_L_tb <= '1';
        PC_E_tb<='0';
        wait for delay;
        PC_E_tb <= '1';
        PC_L_tb<='0';
        wait for delay;
        PC_E_tb <= '0';
        PC_L_tb<='1';
        wait for delay;
        PC_E_tb <= '1';
        PC_L_tb<='0';
        wait;
    end process;    

end Behavioral;
