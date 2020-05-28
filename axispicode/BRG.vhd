

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity BRG is
    generic( c_sck_ratio: integer := 2);
    Port ( CLK_I : in STD_LOGIC;
           CLK_O : out STD_LOGIC);
end BRG;

architecture Behavioral of BRG is

constant slow_clk_freq:integer:=(c_sck_ratio/2)-1;
signal counter:integer range 0 to slow_clk_freq ;
signal clk_temp: std_logic:='0';

begin


  process(clk_i)
  begin
   if(rising_edge(clk_i) )then
    if(counter = slow_clk_freq)then
    counter<=0;
    clk_temp<=not clk_temp;
    else
    counter<=counter+1;
    end if;
   end if;
  end process;
  clk_o<=clk_temp;
 

end Behavioral;
