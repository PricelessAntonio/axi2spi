library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity irpt_pulse_generator is
  Port (
    clk   : IN STD_LOGIC;
    rst_n : IN STD_LOGIC;
    
    rx_full           : IN STD_LOGIC;
    tx_empty          : IN STD_LOGIC;
    modf              : IN STD_LOGIC;
    slave_modf        : IN STD_LOGIC;
    dtr_underrun      : IN STD_LOGIC;
    drr_overrun       : IN STD_LOGIC;
    slave_select_mode : IN STD_LOGIC;
    drr_not_empty      : IN STD_LOGIC;
    tx_fifo_half_empty : IN STD_LOGIC;
    
    rx_full_pulse           : OUT STD_LOGIC;
    tx_empty_pulse          : OUT STD_LOGIC;
    modf_pulse              : OUT STD_LOGIC;
    slave_modf_pulse        : OUT STD_LOGIC;
    dtr_underrun_pulse      : OUT STD_LOGIC;
    drr_overrun_pulse       : OUT STD_LOGIC;
    slave_select_mode_pulse : OUT STD_LOGIC;
    drr_not_empty_pulse      : OUT STD_LOGIC;
    tx_fifo_half_empty_pulse : OUT STD_LOGIC
  );
end irpt_pulse_generator;

architecture Behavioral of irpt_pulse_generator is

  SIGNAL rx_full_temp           : STD_LOGIC;
  SIGNAL tx_empty_temp          : STD_LOGIC;
  SIGNAL modf_temp              : STD_LOGIC;
  SIGNAL slave_modf_temp        : STD_LOGIC;
  SIGNAL dtr_underrun_temp      : STD_LOGIC;
  SIGNAL drr_overrun_temp       : STD_LOGIC;
  SIGNAL slave_select_mode_temp : STD_LOGIC;
  SIGNAL drr_not_empty_temp      : STD_LOGIC;
  SIGNAL tx_fifo_half_empty_temp : STD_LOGIC;

begin

  process (clk, rst_n)
  begin
    if (rst_n = '0') then
      rx_full_temp           <= '0';
      tx_empty_temp          <= '0';
      modf_temp              <= '0';
      slave_modf_temp        <= '0';
      dtr_underrun_temp      <= '0';
      drr_overrun_temp       <= '0';
      slave_select_mode_temp <= '0';
      drr_not_empty_temp <= '0';
      tx_fifo_half_empty_temp <= '0';
      
    elsif (rising_edge(clk)) then
      rx_full_temp           <= rx_full;
      tx_empty_temp          <= tx_empty;
      modf_temp              <= modf;
      slave_modf_temp        <= slave_modf;
      dtr_underrun_temp      <= dtr_underrun;
      drr_overrun_temp       <= drr_overrun;
      slave_select_mode_temp <= slave_select_mode;
      drr_not_empty_temp <= drr_not_empty;
      tx_fifo_half_empty_temp <= tx_fifo_half_empty;
      
    end if;
  end process;
  
  rx_full_pulse           <= (NOT rx_full_temp) AND rx_full;
  tx_empty_pulse          <= (NOT tx_empty_temp) AND tx_empty;
  modf_pulse              <= (NOT modf_temp) AND modf;
  slave_modf_pulse        <= (NOT slave_modf_temp) AND slave_modf;
  dtr_underrun_pulse      <= (NOT dtr_underrun_temp) AND dtr_underrun;
  drr_overrun_pulse       <= (NOT drr_overrun_temp) AND drr_overrun;
  slave_select_mode_pulse <= (NOT slave_select_mode_temp) AND slave_select_mode;
  drr_not_empty_pulse     <= (NOT drr_not_empty_temp) AND drr_not_empty;
  tx_fifo_half_empty_pulse <= (NOT tx_fifo_half_empty_temp) AND tx_fifo_half_empty;

end Behavioral;
