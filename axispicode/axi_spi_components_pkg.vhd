LIBRARY IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package axi_spi_components_pkg is

  ---------------------------------------------------------------------------------
  -- AXI4-LITE INTERFACE IMPLEMENTATION BEGIN
  ---------------------------------------------------------------------------------
  component Axi4Lite_Interface is
    Generic (
      C_BASEADDR : STD_LOGIC_VECTOR; 
      C_HIGHADDR : STD_LOGIC_VECTOR;
      C_S_AXI_ADDR_WIDTH : INTEGER := 32;
      C_S_AXI_DATA_WIDTH : INTEGER := 32
    );
    Port (
      -- AXI4-Lite Interface Ports
      S_AXI_ACLK    : IN STD_LOGIC;    -- Clock
      S_AXI_ARESETN : IN STD_LOGIC;    -- Reset Active Low
     
      S_AXI_AWADDR  : IN STD_LOGIC_VECTOR((C_S_AXI_ADDR_WIDTH-1) DOWNTO 0); -- Write Address
      S_AXI_AWVALID : IN STD_LOGIC;                                         -- Write Address Valid
      S_AXI_AWREADY : OUT STD_LOGIC;                                        -- Write Address Ready
    
      S_AXI_WDATA  : IN STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH-1) DOWNTO 0); -- Write Data
      S_AXI_WSTB   : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Write Strobes
      S_AXI_WVALID : IN STD_LOGIC;                                         -- Write Valid
      S_AXI_WREADY : OUT STD_LOGIC;                                        -- Write Ready
    
      S_AXI_BRESP  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- Write Response
      S_AXI_BVALID : OUT STD_LOGIC;                    -- Write Response Valid
      S_AXI_BREADY : IN STD_LOGIC;                     -- Write Response Ready
    
      S_AXI_ARADDR  : IN STD_LOGIC_VECTOR((C_S_AXI_ADDR_WIDTH-1) DOWNTO 0); -- Read Address
      S_AXI_ARVALID : IN STD_LOGIC;                                         -- Read Address Valid
      S_AXI_ARREADY : OUT STD_LOGIC;                                        -- Read Address Ready
    
      S_AXI_RDATA  : OUT STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH-1) DOWNTO 0); -- Read Data
      S_AXI_RRESP  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);                      -- Read Response
      S_AXI_RVALID : OUT STD_LOGIC;                                         -- Read Valid
      S_AXI_RREADY : IN STD_LOGIC;                                          -- Read Ready
    
      -- Internal Ports
      WriteToReg : OUT STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH-1) DOWNTO 0); -- Input Data
      Strobe : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- Strobe sent out to registers
     
      SRR_En : OUT STD_LOGIC;    -- Software Reset Register Enable
      SPICR_En : OUT STD_LOGIC;  -- SPI Control Register Enable
      SPIDTR_En : OUT STD_LOGIC; -- SPI Data Transmit Register Enable
      SPISSR_En : OUT STD_LOGIC; -- SPI Slave Select Register Enable
      DGIER_En : OUT STD_LOGIC;  -- Device Global Interrupt Enable Register Enable
      IPISR_En : OUT STD_LOGIC;  -- IP Interrupt Status Register Enable
      IPIER_En : OUT STD_LOGIC;  -- IP Interrupt Enable Register Enable
    
      SPICR_Read : IN STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH-1) DOWNTO 0);  -- SPI Control Register Read
      SPISR_Read : IN STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH-1) DOWNTO 0);  -- SPI Status Register Read
      SPIDRR_Read : IN STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH-1) DOWNTO 0); -- SPI Data Receive Register Read
      SPISSR_Read : IN STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH-1) DOWNTO 0); -- SPI Slave Select Register Read
      Tx_FIFO_OCY_Read : IN STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH-1) DOWNTO 0); -- SPI Transmit FIFO Occupancy Register Read
      Rx_FIFO_OCY_Read : IN STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH-1) DOWNTO 0); -- SPI Receive FIFO Occupancy Register Read
      DGIER_Read : IN STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH-1) DOWNTO 0);  -- Device Global Intterupt Enable Register Read
      IPISR_Read : IN STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH-1) DOWNTO 0);  -- IP Interrupt Status Register Read
      IPIER_Read : IN STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH-1) DOWNTO 0);  -- IP Interrupt Enable Register Read
    
      SPIDRR_Read_en : OUT STD_LOGIC;                                      -- Enable read for DRR
      SPISR_Read_en : OUT STD_LOGIC
    );
  end component;
  
  component read_channel_logic is
    Generic (
      C_BASEADDR : STD_LOGIC_VECTOR;
      C_HIGHADDR : STD_LOGIC_VECTOR;
      C_S_AXI_ADDR_WIDTH : INTEGER := 32;
      C_S_AXI_DATA_WIDTH : INTEGER := 32
    );
    Port (
      S_AXI_ACLK    : IN STD_LOGIC;    -- Clock
      S_AXI_ARESETN : IN STD_LOGIC;    -- Reset Active Low
    
      S_AXI_ARADDR  : IN STD_LOGIC_VECTOR((C_S_AXI_ADDR_WIDTH-1) DOWNTO 0); -- Read Address
      S_AXI_ARVALID : IN STD_LOGIC;                                         -- Read Address Valid
      S_AXI_ARREADY : OUT STD_LOGIC;                                        -- Read Address Ready
    
      S_AXI_RDATA  : OUT STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH-1) DOWNTO 0); -- Read Data
      S_AXI_RRESP  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);                      -- Read Response
      S_AXI_RVALID : OUT STD_LOGIC;                                         -- Read Valid
      S_AXI_RREADY : IN STD_LOGIC;                                          -- Read Ready
    
      SPICR_Read : IN STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH-1) DOWNTO 0);  -- SPI Control Register Read
      SPISR_Read : IN STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH-1) DOWNTO 0);  -- SPI Status Register Read
      SPIDRR_Read : IN STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH-1) DOWNTO 0); -- SPI Data Receive Register Read
      SPISSR_Read : IN STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH-1) DOWNTO 0); -- SPI Slave Select Register Read
      Tx_FIFO_OCY_Read : IN STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH-1) DOWNTO 0); -- SPI Transmit FIFO Occupancy Register Read
      Rx_FIFO_OCY_Read : IN STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH-1) DOWNTO 0); -- SPI Receive FIFO Occupancy Register Read
      DGIER_Read : IN STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH-1) DOWNTO 0);  -- Device Global Intterupt Enable Register Read
      IPISR_Read : IN STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH-1) DOWNTO 0);  -- IP Interrupt Status Register Read
      IPIER_Read : IN STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH-1) DOWNTO 0);  -- IP Interrupt Enable Register Read
    
      temp_read_address_out : OUT STD_LOGIC_VECTOR((C_S_AXI_ADDR_WIDTH-1) DOWNTO 0);
      SPIDRR_Read_en : OUT STD_LOGIC;
      SPISR_Read_en : OUT STD_LOGIC
    );
  end component;
  
  component write_channel_logic is
    Generic (
      C_BASEADDR : STD_LOGIC_VECTOR;
      C_HIGHADDR : STD_LOGIC_VECTOR;
      C_S_AXI_ADDR_WIDTH : INTEGER := 32;
      C_S_AXI_DATA_WIDTH : INTEGER := 32
    );
    Port (
      S_AXI_ACLK    : IN STD_LOGIC;    -- Clock
      S_AXI_ARESETN : IN STD_LOGIC;    -- Reset Active Low
    
      S_AXI_AWADDR  : IN STD_LOGIC_VECTOR((C_S_AXI_ADDR_WIDTH-1) DOWNTO 0); -- Write Address
      S_AXI_AWVALID : IN STD_LOGIC;                                         -- Write Address Valid
      S_AXI_AWREADY : OUT STD_LOGIC;                                        -- Write Address Ready
    
      S_AXI_WDATA  : IN STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH-1) DOWNTO 0); -- Write Data
      S_AXI_WSTB   : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Write Strobes
      S_AXI_WVALID : IN STD_LOGIC;                                         -- Write Valid
      S_AXI_WREADY : OUT STD_LOGIC;                                        -- Write Ready
    
      S_AXI_BRESP  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- Write Response
      S_AXI_BVALID : OUT STD_LOGIC;                    -- Write Response Valid
      S_AXI_BREADY : IN STD_LOGIC;                     -- Write Response Ready
    
      WriteToReg : OUT STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH-1) DOWNTO 0); -- Input Data
      Strobe : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- Strobe sent out to registers
    
      SRR_En : OUT STD_LOGIC;    -- Software Reset Register Enable
      SPICR_En : OUT STD_LOGIC;  -- SPI Control Register Enable
      SPIDTR_En : OUT STD_LOGIC; -- SPI Data Transmit Register Enable
      SPISSR_En : OUT STD_LOGIC; -- SPI Slave Select Register Enable
      DGIER_En : OUT STD_LOGIC;  -- Device Global Interrupt Enable Register Enable
      IPISR_En : OUT STD_LOGIC;  -- IP Interrupt Status Register Enable
      IPIER_En : OUT STD_LOGIC;  -- IP Interrupt Enable Register Enable
    
      tx_full : IN STD_LOGIC;
      rvalid : IN STD_LOGIC;
      temp_read_address : IN STD_LOGIC_VECTOR((C_S_AXI_ADDR_WIDTH-1) DOWNTO 0)
    );
  end component;
  ---------------------------------------------------------------------------------
  -- AXI4-LITE INTERFACE IMPLEMENTATION END
  ---------------------------------------------------------------------------------
  
  ---------------------------------------------------------------------------------
  -- REGISTER IMPLEMENTATION BEGIN
  ---------------------------------------------------------------------------------
  component axi_spi_core_registers is
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
  end component;
  
  component registers is
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
  end component;
  
  component load_register is
    Port (
      clk       :   in std_logic;
      wr_en     :   in std_logic;
      load_en_n :   in std_logic;
      load      :   in std_logic_vector(31 downto 0);
      stb_in    :   in std_logic_vector(3 downto 0);
      d_in      :   in std_logic_vector(31 downto 0);
      d_out     :   out std_logic_vector(31 downto 0)
    );
  end component;
    
  component AsyncFifo_32x1_or_16 is
    Generic (
      C_FIFO_EXIST : INTEGER := 1
    );
    Port (
      w_clk, r_clk, rst_n, w_en, r_en : IN STD_LOGIC;
      w_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      full, empty : OUT STD_LOGIC;
      r_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      queue : OUT STD_LOGIC_VECTOR((1+(3*C_FIFO_EXIST)) DOWNTO 0)
    );
  end component;
  
  component load_flipflop is
    Port (
      clk       : IN STD_LOGIC;
      sync_rst  : IN STD_LOGIC;
      wr_en     : IN STD_LOGIC; -- enables data to be written to register
      load_en_n : IN STD_LOGIC; -- enables value in load to be written to register asynchronously
      load      : IN STD_LOGIC;
      stb_in    : IN STD_LOGIC;
      d_in      : IN STD_LOGIC;
      d_out     : OUT STD_LOGIC
    );
  end component;
  
  component interrupt_register is
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
  end component;
  
  component cdc is
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
  end component;
  
  component synchronizer_Nbit is
    Generic (
      WIDTH : INTEGER
    );
    Port (
      clk   : IN STD_LOGIC;
      rst_n : IN STD_LOGIC;
      d_in  : IN STD_LOGIC_VECTOR((WIDTH-1) DOWNTO 0);
      d_out : OUT STD_LOGIC_VECTOR((WIDTH-1) DOWNTO 0)
    );
  end component;
  
  component irpt_pulse_generator is
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
  end component;
  ---------------------------------------------------------------------------------
  -- REGISTER IMPLEMENTATION END
  ---------------------------------------------------------------------------------
 
 component spi_interface 
  generic (C_NUM_TRANSFER_BITS: INTEGER:=8;
           C_NUM_SS_BITS:INTEGER:=8); 
     Port ( clk : in STD_LOGIC;      ----- spi clock
            sck_o:out std_logic;
           sclk_fifo:out std_logic;
           slave_clk:in std_logic; 
           reset: in std_logic;
          --------control signals-----------   
           master:in std_logic;
           enable : in STD_LOGIC;   ----- spi enable signal      
           cpha_i : in std_logic;
           cpol_i : in std_logic;
           mss    : in std_logic;
           loopback:in std_logic;
           SSEL    : in std_logic;
           lsb     : in std_logic;
           manual_slave:in std_logic;
           SS    :IN STD_LOGIC_VECTOR( C_NUM_SS_BITS-1 DOWNTO 0);
           SS_O    :out STD_LOGIC_VECTOR(C_NUM_SS_BITS-1 DOWNTO 0);
           MISO_I : in STD_LOGIC;     ----- Master in slave out
           MOSI_O : out STD_LOGIC;    ----- Master out slave in
           MISO_O : out std_logic;  --- MISO_I out slave mode
           MOSI_I : in  std_logic;  --- MOSI_O in slave mode
           MOSI_T: OUT STD_LOGIC;
           MISO_T: OUT STD_LOGIC;
           cpha_o : out std_logic;
           cpol_o : out std_logic;
           SS_T    : OUT STD_LOGIC;
           MODF    :OUT STD_LOGIC;
           SLAVE_SEL_MOD:OUT STD_LOGIC;
           SLAVE_MODF:OUT STD_LOGIC;
           ------------ tx signal ports --------------          
           data_re: out STD_LOGIC;   ----- data read requeset from tx shifter fsm
           tx_fifo_reg:in std_logic_vector(31 downto 0);
         ------------- rx signal ports ---------------
           fifo_en : out STD_LOGIC;  ------ rx fifo write signal
           rx_fifo_reg:out std_logic_vector(31 downto 0));
   end component;


end axi_spi_components_pkg;