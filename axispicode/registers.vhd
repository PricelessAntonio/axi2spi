library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
use work.axi_spi_components_pkg.load_register;
use work.axi_spi_components_pkg.AsyncFifo_32x1_or_16;
use work.axi_spi_components_pkg.load_flipflop;
use work.axi_spi_components_pkg.interrupt_register;
 
entity registers is
  Generic (
    C_FIFO_EXIST : INTEGER := 1
  );
  Port (
    S_AXI_ACLK    :   IN STD_LOGIC;                      -- System Clock
    spi_clk       :   IN STD_LOGIC;                      -- SPI Clock
    S_AXI_ARESETN :   IN STD_LOGIC;                      -- Async System Reset
    rst_n         :   IN STD_LOGIC;                      -- Async System Reset or Software Reset
    strobe        :   IN STD_LOGIC_VECTOR(3 DOWNTO 0);   -- strobe signal for byte to be written 
        
    -- REGISTER WRITE ENABLES
    SRR_en          :   IN STD_LOGIC;
    SPICR_en        :   IN STD_LOGIC;
    SPIDTR_en       :   IN STD_LOGIC;
    SPIDRR_en       :   IN STD_LOGIC;
    SPISSR_en       :   IN STD_LOGIC;
    DGIER_en        :   IN STD_LOGIC;
    IPISR_en        :   IN STD_LOGIC;
    IPIER_en        :   IN STD_LOGIC;
        
    -- REGISTER WRITE DATA INPUT
    axi_write_bus     : IN STD_LOGIC_VECTOR(31 DOWNTO 0);   -- data to be written to registers
    
    slave_mode_select_spi : IN STD_LOGIC; -- SPISR input from SPI
    modf_spi              : IN STD_LOGIC; -- SPISR input from SPI
    
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
    
    -- FIFO FLAG OUTPUTS
    rx_full : OUT STD_LOGIC;
    rx_empty : OUT STD_LOGIC;
    tx_empty : OUT STD_LOGIC;
    tx_queue : OUT STD_LOGIC_VECTOR((1+(3*C_FIFO_EXIST)) DOWNTO 0);
        
    -- SOFTWARE RESET OUTPUT AND INPUT
    srst_n_O : OUT STD_LOGIC;
    
    -- INTERNAL INTERRUPTS
    drr_not_empty_irpt      : IN STD_LOGIC;
    slave_select_mode_irpt  : IN STD_LOGIC;
    tx_fifo_half_empty_irpt : IN STD_LOGIC;
    drr_overrun_irpt        : IN STD_LOGIC;
    drr_full_irpt           : IN STD_LOGIC;
    dtr_underrun_irpt       : IN STD_LOGIC;
    dtr_empty_irpt          : IN STD_LOGIC;
    slave_modf_irpt         : IN STD_LOGIC;
    modf_irpt               : IN STD_LOGIC;
    
    -- EXTERNAL INTERRUPT
    IP2INTC_Irpt : OUT STD_LOGIC
  );
end registers;

architecture Behavioral of registers is

  CONSTANT software_reset_value : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"0000_000A";

  -- SRR SIGNALS
  SIGNAL SRR_Read_temp : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL SRR_en_temp     : STD_LOGIC;
  SIGNAL srst_n          : STD_LOGIC;
  
  -- SPICR SIGNALS
  SIGNAL SPICR_Read_temp : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL rx_fifo_rst_sync_rst : STD_LOGIC;
  SIGNAL Rx_FIFO_rst   : STD_LOGIC;
  SIGNAL tx_fifo_rst_sync_rst : STD_LOGIC;
  SIGNAL Tx_FIFO_rst   : STD_LOGIC;
  
  -- SPISR SIGNALS
  SIGNAL SPISR_data_in : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL SPISR_Read_temp : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL modf_sync_rst : STD_LOGIC;
  SIGNAL modf_Read_temp : STD_LOGIC;
  
  -- SPIDTR SIGNALS
  SIGNAL SPIDTR_rstn : STD_LOGIC;
  SIGNAL tx_full : STD_LOGIC;
  SIGNAL tx_empty_temp : STD_LOGIC;
  SIGNAL tx_queue_temp : STD_LOGIC_VECTOR((1+(3*C_FIFO_EXIST)) DOWNTO 0);
  
  -- SPIDRR SIGNALS
  SIGNAL SPIDRR_rstn : STD_LOGIC;
  SIGNAL rx_full_temp : STD_LOGIC;
  SIGNAL rx_empty_temp : STD_LOGIC;
  SIGNAL rx_queue : STD_LOGIC_VECTOR((1+(3*C_FIFO_EXIST)) DOWNTO 0);
  
  -- TX FIFO OCY REGISTER SIGNALS
  SIGNAL Tx_FIFO_OCY_data_in : STD_LOGIC_VECTOR(31 DOWNTO 0);
  
  -- RX FIFO OCY REGISTER SIGNALS
  SIGNAL Rx_FIFO_OCY_data_in : STD_LOGIC_VECTOR(31 DOWNTO 0);
  
  -- DGIER SIGNALS
  SIGNAL DGIER_Read_temp : STD_LOGIC_VECTOR(31 DOWNTO 0);
  
  -- IPISR SIGNALS
  SIGNAL IPISR_Read_temp      : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL wr_data_toggled      : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL irpt_wr_data_toggled : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL irpt_enable          : STD_LOGIC;
  SIGNAL IPISR_Write_irpt     : STD_LOGIC_VECTOR(31 DOWNTO 0);
  
  -- IPIER SIGNALS
  SIGNAL IPIER_Read_temp : STD_LOGIC_VECTOR(31 DOWNTO 0);
  
  -- INTERRUPT SIGNALS
  SIGNAL irpt_vector : STD_LOGIC_VECTOR(8 DOWNTO 0);
  SIGNAL IP2INTC_Irpt_temp : STD_LOGIC;

begin
  ----- SRR IMPLEMENTATION BEGIN -----
  SRR : load_register
    Port Map (
      clk        => S_AXI_ACLK,
      wr_en      => SRR_en_temp,
      load_en_n  => S_AXI_ARESETN,
      load       => x"0000_0000",
      stb_in     => strobe,
      d_in       => axi_write_bus,
      d_out      => SRR_Read_temp
    );

  --  Outputs reset signal for 1 clk when 0x0000_000A is written to SRR
  srst_n <= '0' WHEN (SRR_Read_temp = software_reset_value) ELSE '1';
  srst_n_o <= srst_n;
  SRR_en_temp <= SRR_en OR (NOT srst_n);
  ----- SRR IMPLEMENTATION END -----

  ----- SPICR IMPLEMENTATION BEGIN -----
  SPICR : load_register
    Port Map (
      clk       => S_AXI_ACLK,
      wr_en     => SPICR_en,
      load_en_n => rst_n,
      load      => x"0000_0180",
      stb_in    => strobe,
      d_in      => axi_write_bus,
      d_out     => SPICR_Read_temp
    );

  rx_fifo_rst_flipflop : load_flipflop
    Port Map (
      clk       => S_AXI_ACLK,
      sync_rst  => rx_fifo_rst_sync_rst,
      wr_en     => SPICR_en,
      load_en_n => rst_n,
      load      => '0',
      stb_in    => strobe(0),
      d_in      => axi_write_bus(6),
      d_out     => Rx_FIFO_rst
    );
  rx_fifo_rst_sync_rst <= Rx_FIFO_rst;

  tx_fifo_rst_flipflop : load_flipflop
    Port Map (
      clk       => S_AXI_ACLK,
      sync_rst  => tx_fifo_rst_sync_rst,
      wr_en     => SPICR_en,
      load_en_n => rst_n,
      load      => '0',
      stb_in    => strobe(0),
      d_in      => axi_write_bus(5),
      d_out     => Tx_FIFO_rst
    );
  tx_fifo_rst_sync_rst <= Tx_FIFO_rst;
  
  SPICR_Read <= SPICR_Read_temp(31 DOWNTO 7) & Rx_FIFO_rst & Tx_FIFO_rst & SPICR_Read_temp(4 DOWNTO 0);
  ----- SPICR IMPLEMENTATION END -----

  ----- SPISR IMPLEMENTATION BEGIN -----
  SPISR : load_register
    Port Map (
      clk       => S_AXI_ACLK,
      wr_en     => '1',
      load_en_n => rst_n,
      load      => x"0000_0025",
      stb_in    => "0001",
      d_in      => SPISR_data_in,
      d_out     => SPISR_Read_temp
    );
  SPISR_data_in <= x"0000_00" & "00" & slave_mode_select_spi & '0' & tx_full & tx_empty_temp & rx_full_temp & rx_empty_temp;

  modf_flipflop : load_flipflop
    Port Map (
      clk       => S_AXI_ACLK,
      sync_rst  => modf_sync_rst,
      wr_en     => '1',
      load_en_n => rst_n,
      load      => '0',
      stb_in    => '1',
      d_in      => modf_spi,
      d_out     => modf_Read_temp
    );
  modf_sync_rst <= SPISR_Read_en AND modf_Read_temp; -- Clears bit from modf flipflop when it is read from
  
  SPISR_Read <= SPISR_Read_temp(31 DOWNTO 5) & modf_Read_temp & SPISR_Read_temp(3 DOWNTO 0);
  ----- SPISR IMPLEMENTATION END -----

  ----- SPIDTR IMPLEMENTATION BEGIN -----
  SPIDTR : AsyncFifo_32x1_or_16
    Generic Map (
      C_FIFO_EXIST => C_FIFO_EXIST
    )
    Port Map (
      w_clk => S_AXI_ACLK,
      r_clk => spi_clk,
      rst_n => SPIDTR_rstn,
      w_en => SPIDTR_en,
      r_en => SPIDTR_Read_en,
      w_data => axi_write_bus,
      full => tx_full,
      empty => tx_empty_temp,
      r_data => SPIDTR_Read,
      queue => tx_queue_temp
    );
  tx_empty <= tx_empty_temp;
  tx_queue <= tx_queue_temp;
  SPIDTR_rstn <= rst_n AND (NOT Tx_FIFO_rst);
  ----- SPIDTR IMPLEMENTATION END -----

  ----- SPIDRR IMPLEMENTATION BEGIN -----
  SPIDRR : AsyncFifo_32x1_or_16
    Generic Map (
      C_FIFO_EXIST => C_FIFO_EXIST
    )
    Port Map (
      w_clk => spi_clk,
      r_clk => S_AXI_ACLK,
      rst_n => SPIDRR_rstn,
      w_en => SPIDRR_en,
      r_en => SPIDRR_Read_en,
      w_data => SPIDRR_Write,
      full => rx_full_temp,
      empty => rx_empty_temp,
      r_data => SPIDRR_Read,
      queue => rx_queue
    );
  rx_full <= rx_full_temp;
  rx_empty <= rx_empty_temp;
  SPIDRR_rstn <= rst_n AND (NOT Rx_FIFO_rst);
  ----- SPIDRR IMPLEMENTATION END -----

  SPISSR : load_register
    Port Map (
      clk       => S_AXI_ACLK,
      wr_en     => SPISSR_en,
      load_en_n => rst_n,
      load      => x"FFFF_FFFF",
      stb_in    => strobe,
      d_in      => axi_write_bus,
      d_out     => SPISSR_Read
    );

  FIFO_OCY_REGISTERS : if (C_FIFO_EXIST = 1) generate

    ----- Tx FIFO OCY reg IMPLEMENTATION BEGIN -----
    Tx_FIFO_OCY_reg : load_register
      Port Map (
        clk       => S_AXI_ACLK,
        wr_en     => '1',
        load_en_n => rst_n,
        load      => x"0000_0000",
        stb_in    => "0001",
        d_in      => Tx_FIFO_OCY_data_in,
        d_out     => Tx_FIFO_OCY_Read
      );
    Tx_FIFO_OCY_data_in <= x"0000_000" & tx_queue_temp(3 DOWNTO 0);
    ----- TX FIFO OCY reg IMPLEMENTATION END -----

    ----- Rx FIFO OCY reg BEGIN -----
    Rx_FIFO_OCY_reg : load_register
      Port Map (
        clk       => S_AXI_ACLK,
        wr_en     => '1',
        load_en_n => rst_n,
        load      => x"0000_0000",
        stb_in    => "0001",
        d_in      => Rx_FIFO_OCY_data_in,
        d_out     => Rx_FIFO_OCY_Read
      );
    Rx_FIFO_OCY_data_in <= x"0000_000" & rx_queue(3 DOWNTO 0);
    ----- Rx FIFO OCY reg END -----

  end generate FIFO_OCY_REGISTERS;

  ----- DGIER IMPLEMENTATION BEGIN -----
  DGIER : load_register
    Port Map (
      clk       => S_AXI_ACLK,
      wr_en     => DGIER_en,
      load_en_n => rst_n,
      load      => x"0000_0000",
      stb_in    => strobe,
      d_in      => axi_write_bus,
      d_out     => DGIER_Read_temp
    );
  DGIER_Read <= DGIER_Read_temp;
  ----- DGIER IMPLEMENTATION END -----

  IPISR_reg : interrupt_register
    Port Map (
      clk          => S_AXI_ACLK,
      rst_n        => rst_n,
      enable       => IPISR_en,
      irpt_enable  => irpt_enable,
      strobe       => strobe,
      data_in      => wr_data_toggled,
      irpt_data_in => irpt_wr_data_toggled,
      data_out     => IPISR_Read_temp
    );
  
  wr_data_toggled <= axi_write_bus XOR IPISR_Read_temp; -- Toggle write data input into register
  
  IPISR_Write_irpt <= x"0000_0" & "000" & -- Formatting interrput signals as 32 bit vector
    drr_not_empty_irpt &
    slave_select_mode_irpt &
    tx_fifo_half_empty_irpt &
    drr_overrun_irpt &
    drr_full_irpt &
    dtr_underrun_irpt &
    dtr_empty_irpt &
    slave_modf_irpt &
    modf_irpt;
  irpt_wr_data_toggled <= IPISR_Write_irpt XOR IPISR_Read_temp; -- Toggle irpt write data input into register
  irpt_enable <= '0' when (IPISR_Write_irpt = x"0000_0000") else '1'; -- Enable write of interrupt
  IPISR_Read <= IPISR_Read_temp;
  ----- IPISR IMPLEMENTATION END -----

  ----- IPIER IMPLEMENTATION BEGIN -----
  IPIER_reg   :   load_register
    Port Map (
      clk       => S_AXI_ACLK,
      wr_en     => IPIER_en,
      load_en_n => rst_n,
      load      => x"0000_0000",
      stb_in    => strobe,
      d_in      => axi_write_bus,
      d_out     => IPIER_Read_temp
    );
  IPIER_Read <= IPIER_Read_temp;
  ----- IPIER IMPLEMENTATION END -----
  
  ----- INTERRUPT LOGIC -----
  irpt_vector <= IPISR_Read_temp(8 DOWNTO 0) AND IPIER_Read_temp(8 DOWNTO 0);
  IP2INTC_Irpt_temp <= '0' when (irpt_vector = "000000000") else '1';
  IP2INTC_Irpt <= IP2INTC_Irpt_temp AND DGIER_Read_temp(31);

end Behavioral;
