

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity clk_logic is
    Port ( clk_i : in STD_LOGIC;
           cpol_i  : in STD_LOGIC;
           cpha_i  : in std_logic;
           sclk_o : out STD_LOGIC);
end clk_logic;

architecture Behavioral of clk_logic is

begin

 process(clk_i)
  begin
   if(rising_edge(clk_i) and cpol_i='0')then
    sclk_o<='0';
   end if;
    
   if(falling_edge(clk_i) and cpol_i='0')then
     sclk_o<='1';
  end if;
  
   if(rising_edge(clk_i) and cpol_i='1')then
     sclk_o<='1';
  end if;
    
   if(falling_edge(clk_i) and cpol_i='1')then 
    sclk_o<='0';
  end if;
    
    end process;
     

end Behavioral;