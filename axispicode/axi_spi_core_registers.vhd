library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.axi_spi_components_pkg.registers;
use work.axi_spi_components_pkg.cdc;
use work.axi_spi_components_pkg.irpt_pulse_generator;

entity axi_spi_core_registers is
  Generic (
    C_FIFO_EXIST : INTEGER := 1;
    C_NUM_SS_BITS : INTEGER := 1
  );
  Port (
    S_AXI_ACLK : IN STD_LOGIC;
    spi_clk    : IN STD_LOGIC;
    S_AXI_ARESETN : IN STD_LOGIC;
    rst_n         : OUT STD_LOGIC;
    strobe        : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    
    SRR_en : IN STD_LOGIC;
    SPICR_en : IN STD_LOGIC;
    SPIDTR_en : IN STD_LOGIC;
    SPIDRR_en : IN STD_LOGIC;
    SPISSR_en : IN STD_LOGIC;
    DGIER_en        :   IN STD_LOGIC;
    IPISR_en        :   IN STD_LOGIC;
    IPIER_en        :   IN STD_LOGIC;
          
    -- REGISTER WRITE DATA INPUT
    axi_write_bus     : IN STD_LOGIC_VECTOR(31 DOWNTO 0);   -- data to be written to registers
    
    slave_mode_select_spi : IN STD_LOGIC; -- SPISR input from SPI
    modf_spi              : IN STD_LOGIC; -- SPISR input from SPI
    slave_modf_spi        : IN STD_LOGIC;
    
    SPIDRR_Write      : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        
    -- REGISTER READ ENABLES
    SPISR_Read_en  : IN STD_LOGIC; -- Used to clear MODF bit
    SPIDRR_Read_en : IN STD_LOGIC; -- Used to read from FIFO to AXI interface
    SPIDTR_Read_en : IN STD_LOGIC; -- Used to read from transfer register to SPI 
        
    -- REGISTER READ DATA OUTPUT
    SPICR_Read       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    SPISR_Read       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    SPIDTR_Read      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    SPIDRR_Read      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    SPISSR_Read      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    Tx_FIFO_OCY_Read : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    Rx_FIFO_OCY_Read : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    DGIER_Read       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    IPISR_Read       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    IPIER_Read       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    
    -- EXTERNAL INTERRUPT
    IP2INTC_Irpt : OUT STD_LOGIC;
    
    -- REG TO SPI
    SPICR_bits_synched  : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
    SPISSR_bits_synched : OUT STD_LOGIC_VECTOR((C_NUM_SS_BITS-1) DOWNTO 0);
    rx_full : OUT STD_LOGIC;
    tx_empty : OUT STD_LOGIC
  );
end axi_spi_core_registers;

architecture Structural of axi_spi_core_registers is

  SIGNAL SPICR_Read_temp : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL SPISSR_Read_temp : STD_LOGIC_VECTOR(31 DOWNTO 0);

  SIGNAL rx_full_temp  : STD_LOGIC;
  SIGNAL rx_empty_temp : STD_LOGIC;
  SIGNAL tx_empty_temp : STD_LOGIC;
  SIGNAL dtr_underrun_temp : STD_LOGIC;
  SIGNAL drr_overrun_temp : STD_LOGIC;
  
  SIGNAL drr_not_empty_temp : STD_LOGIC;
  SIGNAL tx_fifo_half_empty_temp: STD_LOGIC;
  
  SIGNAL rx_full_synched           : STD_LOGIC;
  SIGNAL tx_empty_synched          : STD_LOGIC;
  SIGNAL modf_synched              : STD_LOGIC;
  SIGNAL slave_modf_synched        : STD_LOGIC;
  SIGNAL dtr_underrun_synched      : STD_LOGIC;
  SIGNAL drr_overrun_synched       : STD_LOGIC;
  SIGNAL slave_select_mode_synched : STD_LOGIC;
  
  SIGNAL rx_full_pulse_temp           : STD_LOGIC;
  SIGNAL tx_empty_pulse_temp          : STD_LOGIC;
  SIGNAL modf_pulse_temp              : STD_LOGIC;
  SIGNAL slave_modf_pulse_temp        : STD_LOGIC;
  SIGNAL dtr_underrun_pulse_temp      : STD_LOGIC;
  SIGNAL drr_overrun_pulse_temp       : STD_LOGIC;
  SIGNAL slave_select_mode_pulse_temp : STD_LOGIC;
  SIGNAL drr_not_empty_pulse_temp      : STD_LOGIC;
  SIGNAL tx_fifo_half_empty_pulse_temp : STD_LOGIC;
  
  SIGNAL tx_queue_temp : STD_LOGIC_VECTOR((1+(3*C_FIFO_EXIST)) DOWNTO 0);
  
  SIGNAL rst_n_temp : STD_LOGIC;
  SIGNAL srst_n_O_temp : STD_LOGIC;

begin

  core_registers : registers
  Generic Map (
    C_FIFO_EXIST => C_FIFO_EXIST
  )
  Port Map (
    S_AXI_ACLK    => S_AXI_ACLK,
    spi_clk       => spi_clk,
    S_AXI_ARESETN => S_AXI_ARESETN,
    rst_n         => rst_n_temp,
    strobe        => strobe,
    SRR_en          => SRR_en,
    SPICR_en        => SPICR_en,
    SPIDTR_en       => SPIDTR_en,
    SPIDRR_en       => SPIDRR_en,
    SPISSR_en       => SPISSR_en,
    DGIER_en        => DGIER_en,
    IPISR_en        => IPISR_en,
    IPIER_en        => IPIER_en,
    axi_write_bus     => axi_write_bus,
    slave_mode_select_spi => slave_mode_select_spi,
    modf_spi              => modf_spi,
    SPIDRR_Write      => SPIDRR_Write,
    SPISR_Read_en  => SPISR_Read_en,
    SPIDRR_Read_en => SPIDRR_Read_en,
    SPIDTR_Read_en => SPIDTR_Read_en,
    SPICR_Read       => SPICR_Read_temp,
    SPISR_Read       => SPISR_Read,
    SPIDTR_Read      => SPIDTR_Read,
    SPIDRR_Read      => SPIDRR_Read,
    SPISSR_Read      => SPISSR_Read_temp,
    Tx_FIFO_OCY_Read => Tx_FIFO_OCY_Read,
    Rx_FIFO_OCY_Read => Rx_FIFO_OCY_Read,
    DGIER_Read       => DGIER_Read,
    IPISR_Read       => IPISR_Read,
    IPIER_Read       => IPIER_Read,
    rx_full => rx_full_temp,
    rx_empty => rx_empty_temp,
    tx_empty => tx_empty_temp,
    tx_queue => tx_queue_temp,
    srst_n_O => srst_n_O_temp,
    drr_not_empty_irpt      => drr_not_empty_pulse_temp,
    slave_select_mode_irpt  => slave_select_mode_pulse_temp,
    tx_fifo_half_empty_irpt => tx_fifo_half_empty_pulse_temp,
    drr_overrun_irpt        => drr_overrun_pulse_temp,
    drr_full_irpt           => rx_full_pulse_temp,
    dtr_underrun_irpt       => dtr_underrun_pulse_temp,
    dtr_empty_irpt          => tx_empty_pulse_temp,
    slave_modf_irpt         => slave_modf_pulse_temp,
    modf_irpt               => modf_pulse_temp,
    IP2INTC_Irpt => IP2INTC_Irpt
  );
  SPICR_Read <= SPICR_Read_temp;
  SPISSR_Read <= SPISSR_Read_temp;
  rx_full <= rx_full_temp;
  tx_empty <= tx_empty_temp;
  
  clock_domain_cross : cdc
    Generic Map (
      C_NUM_SS_BITS => C_NUM_SS_BITS
    )
    Port Map (
      S_AXI_ACLK => S_AXI_ACLK,
      spi_clk    => spi_clk,
      rst_n      => rst_n_temp,
      SPICR_bits  => SPICR_Read_temp(9 DOWNTO 0),
      SPISSR_bits => SPISSR_Read_temp((C_NUM_SS_BITS-1) DOWNTO 0),
      SPICR_bits_synched  => SPICR_bits_synched,
      SPISSR_bits_synched => SPISSR_bits_synched,
      rx_full           => rx_full_temp,
      tx_empty          => tx_empty_temp,
      modf              => modf_spi,
      slave_modf        => slave_modf_spi,
      dtr_underrun      => dtr_underrun_temp,
      drr_overrun       => drr_overrun_temp,
      slave_select_mode => slave_mode_select_spi,
      rx_full_synched           => rx_full_synched,
      tx_empty_synched          => tx_empty_synched,
      modf_synched              => modf_synched,
      slave_modf_synched        => slave_modf_synched,
      dtr_underrun_synched      => dtr_underrun_synched,
      drr_overrun_synched       => drr_overrun_synched,
      slave_select_mode_synched => slave_select_mode_synched
    );
  dtr_underrun_temp <= tx_empty_temp AND SPIDTR_Read_en;
  drr_overrun_temp <= rx_full_temp AND SPIDRR_en;
  
  irpt_generator : irpt_pulse_generator
    Port Map (
      clk   => S_AXI_ACLK,
      rst_n => rst_n_temp,
      rx_full           => rx_full_synched,
      tx_empty          => tx_empty_synched,
      modf              => modf_synched,
      slave_modf        => slave_modf_synched,
      dtr_underrun      => dtr_underrun_synched,
      drr_overrun       => drr_overrun_synched,
      slave_select_mode => slave_select_mode_synched,
      drr_not_empty      => drr_not_empty_temp,
      tx_fifo_half_empty => tx_fifo_half_empty_temp,
    
      rx_full_pulse           => rx_full_pulse_temp,
      tx_empty_pulse          => tx_empty_pulse_temp,
      modf_pulse              => modf_pulse_temp,
      slave_modf_pulse        => slave_modf_pulse_temp,
      dtr_underrun_pulse      => dtr_underrun_pulse_temp,
      drr_overrun_pulse       => drr_overrun_pulse_temp,
      slave_select_mode_pulse => slave_select_mode_pulse_temp,
      drr_not_empty_pulse      => drr_not_empty_pulse_temp,
      tx_fifo_half_empty_pulse => tx_fifo_half_empty_pulse_temp
    );
  drr_not_empty_temp <= NOT rx_empty_temp;
  
  tx_half_empty_fifo_exists : if (C_FIFO_EXIST = 1) generate
    tx_fifo_half_empty_temp <= '1' WHEN (tx_queue_temp(3 DOWNTO 0) = "0111") ELSE '0';
  end generate tx_half_empty_fifo_exists;
  tx_half_empty_no_fifo : if (C_FIFO_EXIST = 0) generate
    tx_fifo_half_empty_temp <= '0';
  end generate tx_half_empty_no_fifo;
  
  rst_n_temp <= srst_n_O_temp AND S_AXI_ARESETN;
  rst_n <= rst_n_temp;

end Structural;
