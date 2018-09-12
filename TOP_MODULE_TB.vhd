library ieee;
use ieee.std_logic_1164.all;

entity tb_TOP_MODULE is
end tb_TOP_MODULE;

architecture tb of tb_TOP_MODULE is

    component TOP_MODULE
        port (clk : in std_logic;
              rst : in std_logic;
              DBUS2 : out std_logic_vector(7 downto 0) );
    end component;

    signal clk : std_logic;
    signal rst : std_logic;
    signal DBUS2 : std_logic_vector(7 downto 0);
    constant TbPeriod : time := 10 ns; -- EDIT Put right period here
    constant setup : time := 0.827 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : TOP_MODULE
    port map (clk => clk,
              rst => rst,
              DBUS2 => DBUS2);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';
    clk <= TbClock;

    stimuli : process
    begin
        rst <= '1'; -- synchronous reset
        wait for 100 ns;
        rst <= '1';
        wait for TbPeriod*0.5 - setup;
        rst <= '0';
        wait for 100 ns;

        -- EDIT Add stimuli here
        wait for 100 * TbPeriod;
        wait;
    end process;

end tb;
