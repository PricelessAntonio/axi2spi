library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.axi_spi_components_pkg.synchronizer_Nbit;

entity cdc is
  Generic (
    C_NUM_SS_BITS : INTEGER := 1
  );
  Port (
    S_AXI_ACLK : IN STD_LOGIC;
    spi_clk    : IN STD_LOGIC;
    rst_n      : IN STD_LOGIC;
    
    -- S_AXI_ACLK to spi_clk domain
    SPICR_bits  : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    SPISSR_bits : IN STD_LOGIC_VECTOR((C_NUM_SS_BITS-1) DOWNTO 0);

    SPICR_bits_synched  : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
    SPISSR_bits_synched : OUT STD_LOGIC_VECTOR((C_NUM_SS_BITS-1) DOWNTO 0);
    
    -- spi_clk to S_AXI_ACLK domain
    rx_full           : IN STD_LOGIC;
    tx_empty          : IN STD_LOGIC;
    modf              : IN STD_LOGIC;
    slave_modf        : IN STD_LOGIC;
    dtr_underrun      : IN STD_LOGIC;
    drr_overrun       : IN STD_LOGIC;
    slave_select_mode : IN STD_LOGIC;
    
    rx_full_synched           : OUT STD_LOGIC;
    tx_empty_synched          : OUT STD_LOGIC;
    modf_synched              : OUT STD_LOGIC;
    slave_modf_synched        : OUT STD_LOGIC;
    dtr_underrun_synched      : OUT STD_LOGIC;
    drr_overrun_synched       : OUT STD_LOGIC;
    slave_select_mode_synched : OUT STD_LOGIC
  );
end cdc;

architecture Structural of cdc is

  SIGNAL axi2spi_d_in  : STD_LOGIC_VECTOR(((10+C_NUM_SS_BITS)-1) DOWNTO 0);
  SIGNAL axi2spi_d_out : STD_LOGIC_VECTOR(((10+C_NUM_SS_BITS)-1) DOWNTO 0);

  SIGNAL spi2axi_d_in  : STD_LOGIC_VECTOR(6 DOWNTO 0);
  SIGNAL spi2axi_d_out : STD_LOGIC_VECTOR(6 DOWNTO 0);

begin

  axi2spi : synchronizer_Nbit
    Generic Map (
      WIDTH => (10+C_NUM_SS_BITS)
    )
    Port Map (
      clk   => spi_clk,
      rst_n => rst_n,
      d_in  => axi2spi_d_in,
      d_out => axi2spi_d_out
    );
  
  axi2spi_d_in        <= SPISSR_bits & SPICR_bits;
  
  SPICR_bits_synched  <= axi2spi_d_out(9 DOWNTO 0);
  SPISSR_bits_synched <= axi2spi_d_out(((10+C_NUM_SS_BITS)-1) DOWNTO 10);

  spi2axi : synchronizer_Nbit
    Generic Map (
      WIDTH => 7
    )
    Port Map (
      clk   => S_AXI_ACLK,
      rst_n => rst_n,
      d_in  => spi2axi_d_in,
      d_out => spi2axi_d_out
    );
  
  spi2axi_d_in <= rx_full & tx_empty & modf & slave_modf & dtr_underrun & drr_overrun & slave_select_mode;
  
  rx_full_synched           <= spi2axi_d_out(6);
  tx_empty_synched          <= spi2axi_d_out(5);
  modf_synched              <= spi2axi_d_out(4);
  slave_modf_synched        <= spi2axi_d_out(3);
  dtr_underrun_synched      <= spi2axi_d_out(2);
  drr_overrun_synched       <= spi2axi_d_out(1);
  slave_select_mode_synched <= spi2axi_d_out(0);

end Structural;
