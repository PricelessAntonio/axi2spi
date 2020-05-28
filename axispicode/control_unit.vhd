

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity control_unit is
    Port ( clk : in STD_LOGIC;
           reset:in std_logic;
           spi_en : in STD_LOGIC;
           master : in STD_LOGIC;
           ssel : in STD_LOGIC;
           MODF    :OUT STD_LOGIC;
           SLAVE_SEL_MOD:OUT STD_LOGIC;
           SLAVE_MODF:OUT STD_LOGIC);
end control_unit;

architecture Behavioral of control_unit is

begin
  process(clk,reset)
   begin
   if(reset='0')then
    MODF<='0';
    SLAVE_SEL_MOD<='0';
    SLAVE_MODF<='0';
   elsif(rising_edge(clk))then
    -----------MODF--------------
    if(master='1' and ssel='0')then
     MODF<='1';
    else
     MODF<='0';
    end if;
    
    ----------SLAVE_SEL_MOD----------
    if(ssel='0' and master='0')then
     SLAVE_SEL_MOD<='1';
    else
     SLAVE_SEL_MOD<='0';
    end if;
    
    ----------SLAVE MODF------------
    if(ssel='0' and spi_en='0')then
     SLAVE_MODF<='1';
    else
     SLAVE_MODF<='0';
    end if;
    
   end if;
  end process;
               
end Behavioral;
