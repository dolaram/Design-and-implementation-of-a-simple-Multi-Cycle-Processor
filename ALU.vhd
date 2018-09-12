library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity ALU is
Port (  clk, rst, AL_E, TR1_L, TR2_L : in std_logic;
          din : in std_logic_vector(7 downto 0);
          AL_S : in std_logic_vector(3 downto 0);
          ALU_out : out std_logic_vector(7 downto 0)
         -- Z_FLAG : out std_logic;
          );
end ALU;

architecture Behavioral of ALU is

component Reg_A is
  Port (  clk, rst,  RA_L, RA_E : in std_logic;
          A : in std_logic_vector(7 downto 0);
          reg_out : out std_logic_vector(7 downto 0)
          );
end component;
signal TR1: std_logic_vector(7 downto 0);
signal TR2: std_logic_vector(7 downto 0);
signal ALU_out_reg: std_logic_vector(7 downto 0);
begin

TR11: Reg_A port map (clk, rst, TR1_L, '1', din, TR1);
TR22: Reg_A port map (clk, rst, TR2_L, '1', din, TR2);
ALU_OUT <= ALU_OUT_REG;
--ALU_out <= ALU_out_reg when AL_E = '1' else
--            (others=> 'Z') ;
--Z_FLAG <= '1' when ALU_out_reg = "0000000" else '0';

alu: process(clk)
begin
if (clk'event and clk='1') then
    
    if (rst = '1') then ALU_out_reg <=  (others=> '0') ;
    elsif(AL_E = '1') then
    
    --Z_FLAG <= ALU_out_reg(7) or ALU_out_reg(6) or ALU_out_reg(5) or ALU_out_reg(4) or ALU_out_reg(3) or ALU_out_reg(2) or ALU_out_reg(1)ALU_out_reg(0);
    case AL_S is
        when "0000" =>
            ALU_out_reg <= TR1 and TR2;
             
        when "0001" =>
            ALU_out_reg <= TR1 or TR2;
        when "0010" =>
            ALU_out_reg <= TR1 xor TR2;
        when "0011" =>
            ALU_out_reg <= TR1 xnor TR2;
        when "0100" =>
            ALU_out_reg <= TR1 + TR2;
        when "0101" =>
            ALU_out_reg <= TR1 - TR2;
        when "0110" =>
            ALU_out_reg <= TR1(7) & TR1(7 downto 1); -- shift right by 1 bit --arithmetic shift
        when "0111" =>
            ALU_out_reg <= TR1(6 downto 0) & '0'; -- shift left by 1 bit  --arithimetic shift
        when "1000" =>
            ALU_out_reg <= '0' & TR1(7 downto 1); -- shift right by 1 bit --logical shift
        
        when "1001" =>
            ALU_out_reg <= TR1 + "00000001"; --INC
        when "1010" =>
            ALU_out_reg <= TR1 + "11111111"; --DEC
        --         when "1100" =>
        --             ALU_out_reg <= TR1 xnor TR2;
        --         when "1101" =>
        --           ALU_out_reg <= TR1 xnor TR2;
        --         when "1110" =>
        --         ALU_out_reg <= TR1 xnor TR2;
        --         when "1111" =>
        --           ALU_out_reg <= TR1 xnor TR2;
        
        when others =>
            ALU_out_reg <= (others=> 'Z') ;
        end case;
         else ALU_out_reg <= (others=> 'Z') ;
    end if;
end if;
end process;

end Behavioral;
