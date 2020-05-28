library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity interrupt_register is
  Port (
    clk          : IN STD_LOGIC;
    rst_n        : IN STD_LOGIC;
    enable       : IN STD_LOGIC;
    irpt_enable  : IN STD_LOGIC;
    strobe       : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    data_in      : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    irpt_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    data_out     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
end interrupt_register;

architecture Behavioral of interrupt_register is
begin

  process (clk, rst_n)
  begin
    if (rst_n = '0') then
      data_out <= (OTHERS => '0');
      
    elsif (rising_edge(clk)) then
      if (irpt_enable = '1') then
        data_out <= irpt_data_in;
        
      elsif (enable = '1') then
        if (strobe(0) = '1') then
          data_out(7 DOWNTO 0) <= data_in(7 DOWNTO 0);
          
        end if;
        if (strobe(1) = '1') then
          data_out(15 DOWNTO 8) <= data_in(15 DOWNTO 8);
          
        end if;
        if (strobe(2) = '1') then
          data_out(23 DOWNTO 16) <= data_in(23 DOWNTO 16);
          
        end if;
        if (strobe(3) = '1') then
          data_out(31 DOWNTO 24) <= data_in(31 DOWNTO 24);
          
        end if;
      end if;
    end if;
  end process;

end Behavioral;
