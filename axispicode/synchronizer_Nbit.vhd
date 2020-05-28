library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity synchronizer_Nbit is
  Generic (
    WIDTH : INTEGER
  );
  Port (
    clk   : IN STD_LOGIC;
    rst_n : IN STD_LOGIC;
    d_in  : IN STD_LOGIC_VECTOR((WIDTH-1) DOWNTO 0);
    d_out : OUT STD_LOGIC_VECTOR((WIDTH-1) DOWNTO 0)
  );
end synchronizer_Nbit;

architecture Behavioral of synchronizer_Nbit is

  SIGNAL data_temp         : STD_LOGIC_VECTOR((WIDTH-1) DOWNTO 0);
  SIGNAL synched_data_temp : STD_LOGIC_VECTOR((WIDTH-1) DOWNTO 0);

begin

  data_sync0 : process (clk, rst_n)
    begin
      if (rst_n = '0') then
        data_temp <= (OTHERS => '0');
      elsif (rising_edge(clk)) then
        data_temp <= d_in;
      end if;
  end process data_sync0;
  
  data_sync1 : process (clk, rst_n)
  begin
    if (rst_n = '0') then
      synched_data_temp <= (OTHERS => '0');
    elsif (rising_edge(clk)) then
      synched_data_temp <= data_temp;
    end if;
  end process data_sync1;
  
  d_out <= synched_data_temp;

end Behavioral;
