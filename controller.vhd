library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity controller is
Port (    clk, rst : in std_logic;
          din : in std_logic_vector(7 downto 0);
          MEM_R, PC_E, AL_E, TR1_L, TR2_L, RA_E, RA_L, RB_E, RB_L, RC_E, RC_L, RD_E, RD_L, PC_L : out STD_LOGIC;
          PC_IS : out STD_LOGIC_VECTOR(1 DOWNTO 0);
          PC_OFFSET, AL_S : out std_logic_vector(3 downto 0));
          
end controller;

architecture Behavioral of controller is

component Reg_A is
  Port (  clk, rst,  RA_L, RA_E : in std_logic;
          A : in std_logic_vector(7 downto 0);
          reg_out : out std_logic_vector(7 downto 0));
end component;

--type stateType is (IDLE,PC_LATCH,DUMMY1,DUMMY2,DUMMY3,DUMMY4, PC_ENABLE, LOAD_TR1,LOAD_TR2,ALU_STORE,LOAD_INST,LOAD_IN_REG,BRANCH);
type stateType is (IDLE,FETCH,LOAD_IR,DUMMY,LOAD_TR1,LOAD_TR2,ALU_ENABLE,ALU_STORE,LOAD_INST,LOAD_INST_1,LOAD_INST_2,BRANCH,BRANCH_1);
signal state, nextstate: stateType;
signal  inst :  std_logic_vector(7 downto 0);
signal  IR_L_sig, Z_FLAG :  std_logic;

begin
-- instantiations and dataflow models 
IR: Reg_A port map (clk, rst, IR_L_sig, '1', din, inst);
PC_OFFSET <= inst(3 downto 0);
AL_S <= inst(7 downto 4);
--decode registers

-- behavioral models
Control: process(state, rst, inst, Z_FLAG)
begin
--PC_IS <= "00"; PC_E <= '0'; AL_E <= '0'; IR_L <= '0'; TR1_L <= '0';  TR2_L <= '0';  
--RA_E <= '0';  RA_L <= '0'; RB_E <= '0'; RB_L <= '0'; RC_E <= '0'; RC_L <= '0';
--RD_E <= '0'; RD_L <= '0';MEM_R <= '0';IR_L_sig<='0';
-- reset control signals
case state is
when IDLE =>
    PC_IS <= "00"; PC_E <= '0'; AL_E <= '0';  TR1_L <= '0';  TR2_L <= '0';  
    RA_E <= '0';  RA_L <= '0'; RB_E <= '0'; RB_L <= '0'; RC_E <= '0'; RC_L <= '0';
    RD_E <= '0'; RD_L <= '0';MEM_R <= '0';IR_L_sig<='0'; PC_L <= '1';
    if (rst = '0') then
    nextstate <= FETCH;
    else nextstate <= IDLE;
    end if;
when FETCH =>
    PC_IS <= "00"; PC_E <= '1'; AL_E <= '0';  TR1_L <= '0';  TR2_L <= '0';  
    RA_E <= '0';  RA_L <= '0'; RB_E <= '0'; RB_L <= '0'; RC_E <= '0'; RC_L <= '0';
    RD_E <= '0'; RD_L <= '0';MEM_R <= '1'; IR_L_sig<='0'; PC_L <= '0';
    nextstate <= LOAD_IR;
    
when LOAD_IR =>
    PC_IS <= "00"; PC_E <= '0'; AL_E <= '0';  TR1_L <= '0';  TR2_L <= '0';  
    RA_E <= '0';  RA_L <= '0'; RB_E <= '0'; RB_L <= '0'; RC_E <= '0'; RC_L <= '0';
    RD_E <= '0'; RD_L <= '0';MEM_R <= '0'; IR_L_sig<='1'; PC_L <= '0';
    nextstate <= DUMMY;
when DUMMY =>
    PC_IS <= "00"; PC_E <= '0'; AL_E <= '0';  TR1_L <= '0';  TR2_L <= '0';  
    RA_E <= '0';  RA_L <= '0'; RB_E <= '0'; RB_L <= '0'; RC_E <= '0'; RC_L <= '0';
    RD_E <= '0'; RD_L <= '0'; MEM_R <= '0'; IR_L_sig<='0'; PC_L <= '0';
    --nextstate <= LOAD_IR;
    if (inst(7) = '0' or inst(7 downto 4) = "1000" or inst(7 downto 4) = "1001" or inst(7 downto 4) = "1010" or inst(7 downto 4) =  "1011" ) then 
        nextstate <= LOAD_TR1;
    elsif (inst(7 DOWNTO 4) = "1111") then
        nextstate <= LOAD_INST;
    elsif (inst(7 DOWNTO 4) = "1011" OR inst(7 DOWNTO 4) = "1100") then
        if (Z_FLAG='1' AND inst(7 DOWNTO 4) = "1011") then
            nextstate <= BRANCH;
        ELSIF (Z_FLAG='0' AND inst(7 DOWNTO 4) = "1100") then
            nextstate <= BRANCH;
        ELSE
            nextstate <= IDLE;
        END IF;   
    ELSE
    NEXTSTATE <= IDLE;   
    end if;   
when LOAD_TR1 =>
    TR1_L <= '1';
    PC_IS <= "00"; PC_E <= '0'; AL_E <= '0'; IR_L_sig <= '0'; TR2_L <= '0';  PC_L <= '0';
    RA_L <= '0';  RB_L <= '0'; RC_L <= '0'; 
    RD_L <= '0'; MEM_R <= '0';
    if (inst(3 downto 2) = "00") then 
        RA_E <= '1'; RB_E <= '0'; RC_E <= '0'; RD_E <= '0';
    elsif (inst(3 downto 2) = "01") then 
         RA_E <= '0'; RB_E <= '1'; RC_E <= '0'; RD_E <= '0';
    elsif (inst(3 downto 2) = "10") then 
         RA_E <= '0'; RB_E <= '0'; RC_E <= '1'; RD_E <= '0';
    elsif (inst(3 downto 2) = "11") then 
         RA_E <= '0'; RB_E <= '0'; RC_E <= '0'; RD_E <= '1';
    end if;
    if (inst(7 downto 4) = 6 or inst(7 downto 4) = 7 or inst(7 downto 4) = 8 or inst(7 downto 4) = 9 or inst(7 downto 4) = 10) then
        nextstate <= ALU_ENABLE;
    else nextstate <=  LOAD_TR2;
    end if;
when LOAD_TR2 =>
    TR2_L <= '1';
    PC_IS <= "00"; PC_E <= '0'; AL_E <= '0'; IR_L_sig <= '0'; TR1_L <= '0';  PC_L <= '0';
    RA_L <= '0';  RB_L <= '0'; RC_L <= '0'; 
    RD_L <= '0'; MEM_R <= '0';
    if (inst(1 downto 0) = "00") then 
        RA_E <= '1'; RB_E <= '0'; RC_E <= '0'; RD_E <= '0';
    elsif (inst(1 downto 0) = "01") then 
         RA_E <= '0'; RB_E <= '1'; RC_E <= '0'; RD_E <= '0';
    elsif (inst(1 downto 0) = "10") then 
         RA_E <= '0'; RB_E <= '0'; RC_E <= '1'; RD_E <= '0';
    elsif (inst(1 downto 0) = "11") then 
         RA_E <= '0'; RB_E <= '0'; RC_E <= '0'; RD_E <= '1';
    end if;
    nextstate <= ALU_ENABLE;
when ALU_ENABLE =>
    PC_IS <= "00"; PC_E <= '0'; AL_E <= '1'; IR_L_sig <= '0'; TR1_L <= '0';  TR2_L <= '0';  PC_L <= '0';
    RA_E <= '0';   RB_E <= '0';  RC_E <= '0'; 
    RD_E <= '0'; MEM_R <= '0'; RA_L <= '0';  RB_L <= '0'; RC_L <= '0'; 
        RD_L <= '0'; MEM_R <= '0';
    nextstate <= ALU_STORE;
--    if(din = "00000000") then Z_FLAG <= '1';
--         ELSE Z_FLAG <= '0'; END IF;
when ALU_STORE =>
    PC_IS <= "00"; PC_E <= '0'; AL_E <= '0'; IR_L_sig <= '0'; TR1_L <= '0';  TR2_L <= '0';  PC_L <= '1';
    RA_E <= '0';   RB_E <= '0';  RC_E <= '0'; 
    RD_E <= '0'; MEM_R <= '0';
    nextstate <= FETCH;
--    if(din = "00000000") then Z_FLAG <= '1';
--                 ELSE Z_FLAG <= '0'; END IF;
    if (inst(3 downto 2) = "00") then 
        RA_L <= '1'; RB_L <= '0'; RC_L <= '0'; RD_L <= '0';
    elsif (inst(3 downto 2) = "01") then 
         RA_L <= '0'; RB_L <= '1'; RC_L <= '0'; RD_L <= '0';
    elsif (inst(3 downto 2) = "10") then 
         RA_L <= '0'; RB_L <= '0'; RC_L <= '1'; RD_L <= '0';
    elsif (inst(3 downto 2) = "11") then 
         RA_L <= '0'; RB_L <= '0'; RC_L <= '0'; RD_L <= '1';
    end if;  
when LOAD_INST => 
    PC_IS <= "00"; PC_E <= '0'; AL_E <= '0';  TR1_L <= '0';  TR2_L <= '0';  
    RA_E <= '0';  RA_L <= '0'; RB_E <= '0'; RB_L <= '0'; RC_E <= '0'; RC_L <= '0';
    RD_E <= '0'; RD_L <= '0'; MEM_R <= '0'; IR_L_sig<='0'; PC_L <= '1';
    nextstate <= LOAD_INST_1;
when LOAD_INST_1 => 
    PC_IS <= "00"; PC_E <= '1'; AL_E <= '0';  TR1_L <= '0';  TR2_L <= '0';  
    RA_E <= '0';  RA_L <= '0'; RB_E <= '0'; RB_L <= '0'; RC_E <= '0'; RC_L <= '0';
    RD_E <= '0'; RD_L <= '0'; MEM_R <= '1'; IR_L_sig<='0'; PC_L <= '0';
    nextstate <= LOAD_INST_2;
when LOAD_INST_2 => 
    PC_E <= '0'; MEM_R <= '0'; IR_L_sig<='0'; PC_L <= '1';
    PC_IS <= "00";  AL_E <= '0';  TR1_L <= '0';  TR2_L <= '0';  
    RA_E <= '0';   RB_E <= '0';  RC_E <= '0'; 
    RD_E <= '0';
     if (inst(3 downto 2) = "00") then 
         RA_L <= '1'; RB_L <= '0'; RC_L <= '0'; RD_L <= '0';
     elsif (inst(3 downto 2) = "01") then 
          RA_L <= '0'; RB_L <= '1'; RC_L <= '0'; RD_L <= '0';
     elsif (inst(3 downto 2) = "10") then 
          RA_L <= '0'; RB_L <= '0'; RC_L <= '1'; RD_L <= '0';
     elsif (inst(3 downto 2) = "11") then 
          RA_L <= '0'; RB_L <= '0'; RC_L <= '0'; RD_L <= '1';
     end if;  
    nextstate <= FETCH;
when BRANCH =>
    PC_IS <= "01"; IR_L_sig <= '0'; MEM_R <= '0'; --PC_OFFSET <= inst(3 downto 0);
    PC_E <= '0'; AL_E <= '0'; TR1_L <= '0';  TR2_L <= '0';  PC_L <= '0';
    RA_E <= '0';  RA_L <= '0'; RB_E <= '0'; RB_L <= '0'; RC_E <= '0'; RC_L <= '0';
    RD_E <= '0'; RD_L <= '0'; MEM_R <= '0';
    nextstate <= BRANCH_1;
when BRANCH_1 =>
    PC_IS <= "01"; IR_L_sig <= '0'; MEM_R <= '0'; --PC_OFFSET <= inst(3 downto 0);
    PC_E <= '0'; AL_E <= '0'; TR1_L <= '0';  TR2_L <= '0';  PC_L <= '1';
    RA_E <= '0';  RA_L <= '0'; RB_E <= '0'; RB_L <= '0'; RC_E <= '0'; RC_L <= '0';
    RD_E <= '0'; RD_L <= '0'; MEM_R <= '0';
    nextstate <= FETCH;



--when PC_LATCH =>
--    PC_E <= '0'; MEM_R <= '0'; IR_L_sig<='1'; PC_L <= '1';
--    PC_IS <= "00";  AL_E <= '0';  TR1_L <= '0';  TR2_L <= '0';  
--    RA_E <= '0';  RA_L <= '0'; RB_E <= '0'; RB_L <= '0'; RC_E <= '0'; RC_L <= '0';
--    RD_E <= '0'; RD_L <= '0';
--    nextstate <= PC_ENABLE;
--when PC_ENABLE => 
--    PC_E <= '1'; MEM_R <= '1'; IR_L_sig<='1'; PC_L <= '0';
--    PC_IS <= "00";  AL_E <= '0';  TR1_L <= '0';  TR2_L <= '0';  
--    RA_E <= '0';  RA_L <= '0'; RB_E <= '0'; RB_L <= '0'; RC_E <= '0'; RC_L <= '0';
--    RD_E <= '0'; RD_L <= '0';
--    nextstate <= DUMMY1;
--when DUMMY1 =>
--    PC_E <= '0'; MEM_R <= '0'; IR_L_sig<='0'; PC_L <= '0';
--    PC_IS <= "00";  AL_E <= '0';  TR1_L <= '0';  TR2_L <= '0';  
--    RA_E <= '0';  RA_L <= '0'; RB_E <= '0'; RB_L <= '0'; RC_E <= '0'; RC_L <= '0';
--    RD_E <= '0'; RD_L <= '0';
--    nextstate <= DUMMY2;
--when DUMMY2 =>
--    PC_E <= '0'; MEM_R <= '0'; IR_L_sig<='1'; PC_L <= '0';
--    PC_IS <= "00";  AL_E <= '0';  TR1_L <= '0';  TR2_L <= '0';  
--    RA_E <= '0';  RA_L <= '0'; RB_E <= '0'; RB_L <= '0'; RC_E <= '0'; RC_L <= '0';
--    RD_E <= '0'; RD_L <= '0';
--    if (inst(7) = '0' or inst(7 downto 4) = "1000" or inst(7 downto 4) = "1001" or inst(7 downto 4) = "1010" or inst(7 downto 4) =  "1011" ) then 
--        nextstate <= LOAD_TR1;
--    elsif (inst(7 DOWNTO 4) = "1111") then
--        nextstate <= LOAD_INST;
--    elsif (inst(7 DOWNTO 4) = "1011" OR inst(7 DOWNTO 4) = "1100") then
--        if (Z_FLAG='1' AND inst(7 DOWNTO 4) = "1011") then
--            nextstate <= BRANCH;
--        ELSIF (Z_FLAG='0' AND inst(7 DOWNTO 4) = "1100") then
--            nextstate <= BRANCH;
--        ELSE
--            nextstate <= PC_LATCH;
--        END IF;      
--        end if;
    
--when BRANCH =>
--    PC_IS <= "01"; IR_L_sig <= '1'; MEM_R <= '1'; PC_OFFSET <= inst(3 downto 0);
--    PC_E <= '0'; AL_E <= '0'; TR1_L <= '0';  TR2_L <= '0';  PC_L <= '0';
--    RA_E <= '0';  RA_L <= '0'; RB_E <= '0'; RB_L <= '0'; RC_E <= '0'; RC_L <= '0';
--    RD_E <= '0'; RD_L <= '0'; MEM_R <= '0';
--    nextstate <= PC_LATCH;
--when LOAD_INST => 
--    PC_E <= '1'; MEM_R <= '1'; IR_L_sig<='1'; PC_L <= '0';
--    PC_IS <= "00";  AL_E <= '0';  TR1_L <= '0';  TR2_L <= '0';  
--    RA_E <= '0';   RB_E <= '0';  RC_E <= '0'; 
--     RD_L <= '0';
--    nextstate <= DUMMY3;
--when DUMMY3 =>
--    PC_E <= '0'; MEM_R <= '0'; IR_L_sig<='0'; PC_L <= '0';
--    PC_IS <= "00";  AL_E <= '0';  TR1_L <= '0';  TR2_L <= '0';  
--    RA_E <= '0';  RA_L <= '0'; RB_E <= '0'; RB_L <= '0'; RC_E <= '0'; RC_L <= '0';
--    RD_E <= '0'; RD_L <= '0';
--    nextstate <= DUMMY4;
--when DUMMY4 =>
--    PC_E <= '0'; MEM_R <= '0'; IR_L_sig<='1'; PC_L <= '1';
--    PC_IS <= "00";  AL_E <= '0';  TR1_L <= '0';  TR2_L <= '0';  
--    RA_E <= '0';  RA_L <= '0'; RB_E <= '0'; RB_L <= '0'; RC_E <= '0'; RC_L <= '0';
--    RD_E <= '0'; RD_L <= '0';
--    if (inst(3 downto 2) = "00") then 
--        RA_L <= '1'; RB_L <= '0'; RC_L <= '0'; RD_L <= '0';
--    elsif (inst(3 downto 2) = "01") then 
--         RA_L <= '0'; RB_L <= '1'; RC_L <= '0'; RD_L <= '0';
--    elsif (inst(3 downto 2) = "10") then 
--         RA_L <= '0'; RB_L <= '0'; RC_L <= '1'; RD_L <= '0';
--    elsif (inst(3 downto 2) = "11") then 
--         RA_L <= '0'; RB_L <= '0'; RC_L <= '0'; RD_L <= '1';
--    end if;
--    nextstate  <= PC_LATCH;
--when LOAD_TR1 =>
--    TR1_L <= '1';
--    PC_IS <= "11"; PC_E <= '0'; AL_E <= '0'; IR_L_sig <= '0'; TR2_L <= '0';  PC_L <= '0';
--    RA_L <= '0';  RB_L <= '0'; RC_L <= '0'; 
--    RD_L <= '0'; MEM_R <= '0';
--    if (inst(3 downto 2) = "00") then 
--        RA_E <= '1'; RB_E <= '0'; RC_E <= '0'; RD_E <= '0';
--    elsif (inst(3 downto 2) = "01") then 
--         RA_E <= '0'; RB_E <= '1'; RC_E <= '0'; RD_E <= '0';
--    elsif (inst(3 downto 2) = "10") then 
--         RA_E <= '0'; RB_E <= '0'; RC_E <= '1'; RD_E <= '0';
--    elsif (inst(3 downto 2) = "11") then 
--         RA_E <= '0'; RB_E <= '0'; RC_E <= '0'; RD_E <= '1';
--    end if;
--    if (inst(7 downto 4) = 6 or inst(7 downto 4) = 7 or inst(7 downto 4) = 8 or inst(7 downto 4) = 9 or inst(7 downto 4) = 10) then
--        nextstate <= ALU_STORE;
--    else nextstate <=  LOAD_TR2;
--    end if;
--when LOAD_TR2 =>
--    TR2_L <= '1';
--    PC_IS <= "11"; PC_E <= '0'; AL_E <= '0'; IR_L_sig <= '0'; TR1_L <= '0';  PC_L <= '0';
--    RA_L <= '0';  RB_L <= '0'; RC_L <= '0'; 
--    RD_L <= '0'; MEM_R <= '0';
--    if (inst(3 downto 2) = "00") then 
--        RA_E <= '1'; RB_E <= '0'; RC_E <= '0'; RD_E <= '0';
--    elsif (inst(3 downto 2) = "01") then 
--         RA_E <= '0'; RB_E <= '1'; RC_E <= '0'; RD_E <= '0';
--    elsif (inst(3 downto 2) = "10") then 
--         RA_E <= '0'; RB_E <= '0'; RC_E <= '1'; RD_E <= '0';
--    elsif (inst(3 downto 2) = "11") then 
--         RA_E <= '0'; RB_E <= '0'; RC_E <= '0'; RD_E <= '1';
--    end if;
--    nextstate <= ALU_STORE;
--when ALU_STORE =>
--    PC_IS <= "11"; PC_E <= '0'; AL_E <= '1'; IR_L_sig <= '0'; TR1_L <= '0';  TR2_L <= '0';  PC_L <= '0';
--    RA_E <= '0';   RB_E <= '0';  RC_E <= '0'; 
--    RD_E <= '0'; MEM_R <= '0';
--    nextstate <= PC_LATCH;
--    if (inst(3 downto 2) = "00") then 
--        RA_L <= '1'; RB_L <= '0'; RC_L <= '0'; RD_L <= '0';
--    elsif (inst(3 downto 2) = "01") then 
--         RA_L <= '0'; RB_L <= '1'; RC_L <= '0'; RD_L <= '0';
--    elsif (inst(3 downto 2) = "10") then 
--         RA_L <= '0'; RB_L <= '0'; RC_L <= '1'; RD_L <= '0';
--    elsif (inst(3 downto 2) = "11") then 
--         RA_L <= '0'; RB_L <= '0'; RC_L <= '0'; RD_L <= '1';
--    end if;
WHEN OTHERS =>
    nextstate <= IDLE;
end case;
end process;

STATE_UPDATE: process(clk, rst)
begin
if (rst = '1') then state <= IDLE;
elsif (clk'event and clk = '1') then
state <= nextstate;
IF(STATE = ALU_STORE ) THEN 
IF ( din = "00000000") THEN
Z_FLAG <= '1';
ELSE Z_FLAG <= '0';
END IF;
end if;
END IF;
end process;
end Behavioral;
