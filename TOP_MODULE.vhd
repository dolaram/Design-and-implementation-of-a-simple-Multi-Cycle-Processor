library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TOP_MODULE is
  Port (clk, rst: in std_logic;
  DBUS2 : out std_logic_vector(7 downto 0) );
end TOP_MODULE;

architecture Behavioral of TOP_MODULE is
component Reg_A is
  Port (  clk, rst,  RA_L, RA_E : in std_logic;
          A : in std_logic_vector(7 downto 0);
          reg_out : out std_logic_vector(7 downto 0));
end component;
component Program_counter 
 Port (din, PC_RST: in std_logic_vector(7 downto 0);
        PC_OFFSET : in std_logic_vector(3 downto 0);
        PC_IS: in std_logic_vector(1 downto 0);
         rst, clk, PC_L, PC_E: in std_logic;
        PC_out : out std_logic_vector(7 downto 0)
         );
end component;
component controller
Port (    clk, rst : in std_logic;
          din : in std_logic_vector(7 downto 0);
          MEM_R, PC_E, AL_E, TR1_L, TR2_L, RA_E, RA_L, RB_E, RB_L, RC_E, RC_L, RD_E, RD_L, PC_L : out STD_LOGIC;
          PC_IS : out STD_LOGIC_VECTOR(1 DOWNTO 0);
          PC_OFFSET, AL_S : out std_logic_vector(3 downto 0));
end component;
component ALU
Port (  clk, rst, AL_E, TR1_L, TR2_L : in std_logic;
          din : in std_logic_vector(7 downto 0);
          AL_S : in std_logic_vector(3 downto 0);
          ALU_out : out std_logic_vector(7 downto 0)
          );
end component;
component blk_mem_gen_0
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END component;
signal DBUS , dbus_mem   : std_logic_vector (7 downto 0);
signal Z_FLAG :   std_logic;
signal PC_OUT, PC_RST : std_logic_vector(7 downto 0);
signal MEM_R_L, MEM_R, PC_E, AL_E, TR1_L, TR2_L, RA_E, RA_L, RB_E, RB_L, RC_E, RC_L, RD_E, RD_L,PC_L : STD_LOGIC;
signal PC_IS :   STD_LOGIC_VECTOR(1 DOWNTO 0);
--signal MEM_R_L :   STD_LOGIC_VECTOR(0 DOWNTO 0);
signal PC_OFFSET, AL_S :   std_logic_vector(3 downto 0);
begin
cnt1: controller port map(clk, rst, DBUS, MEM_R, PC_E, AL_E, TR1_L, TR2_L, RA_E, RA_L, RB_E, RB_L, RC_E, RC_L, RD_E, RD_L,PC_L, PC_IS, PC_OFFSET, AL_S);
alu1: ALU port map(clk, rst, AL_E, TR1_L, TR2_L, DBUS , AL_S, DBUS);
pc1: Program_counter port map (DBUS, PC_RST,PC_OFFSET,PC_IS,rst, clk, PC_L , PC_E, PC_out);
block_ram: blk_mem_gen_0 port map(clk, MEM_R, "0", PC_out, DBUS, dbus_mem);
RA: Reg_A port map (clk, rst,  RA_L, RA_E, DBUS, DBUS);
RB: Reg_A port map (clk, rst,  RB_L, RB_E, DBUS, DBUS);
RC: Reg_A port map (clk, rst,  RC_L, RC_E, DBUS, DBUS);
RD: Reg_A port map (clk, rst,  RD_L, RD_E, DBUS, DBUS);
PC_RST <= "00000001";
DBUS <= "ZZZZZZZZ" WHEN MEM_R_L = '0' ELSE 
        DBUS_MEM WHEN MEM_R_L = '1' ELSE "ZZZZZZZZ";
DBUS2 <= DBUS;
--DBUS <= DBUS_1;
MEMORYREAD: process(clk)
begin
if (clk'event and clk='1') then
    MEM_R_L <= MEM_R;
end if;
end process;
end Behavioral;
