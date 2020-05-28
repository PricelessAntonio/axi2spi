library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.axi_spi_components_pkg.read_channel_logic;
use work.axi_spi_components_pkg.write_channel_logic;
 
entity Axi4Lite_Interface is
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
end Axi4Lite_Interface;

architecture Structural of Axi4Lite_Interface is
  
  SIGNAL rvalid : STD_LOGIC;
  SIGNAL temp_read_address : STD_LOGIC_VECTOR((C_S_AXI_ADDR_WIDTH-1) DOWNTO 0);

begin

  write_channels : write_channel_logic
    Generic Map (
      C_BASEADDR => C_BASEADDR,
      C_HIGHADDR => C_HIGHADDR
    )
    Port Map (
      S_AXI_ACLK => S_AXI_ACLK,
      S_AXI_ARESETN => S_AXI_ARESETN,
      S_AXI_AWADDR => S_AXI_AWADDR,
      S_AXI_AWVALID => S_AXI_AWVALID,
      S_AXI_AWREADY => S_AXI_AWREADY,
      S_AXI_WDATA => S_AXI_WDATA,
      S_AXI_WSTB => S_AXI_WSTB,
      S_AXI_WVALID => S_AXI_WVALID,
      S_AXI_WREADY => S_AXI_WREADY,
      S_AXI_BRESP => S_AXI_BRESP,
      S_AXI_BVALID => S_AXI_BVALID,
      S_AXI_BREADY => S_AXI_BREADY,
      WriteToReg => WriteToReg,
      Strobe => Strobe,
      SRR_En => SRR_En,
      SPICR_En => SPICR_En,
      SPIDTR_En => SPIDTR_En,
      SPISSR_En => SPISSR_En,
      DGIER_En => DGIER_En,
      IPISR_En => IPISR_En,
      IPIER_En => IPIER_En,
      tx_full => SPISR_Read(3),
      rvalid => rvalid,
      temp_read_address => temp_read_address
    );
    
  read_channels : read_channel_logic
    Generic Map (
      C_BASEADDR => C_BASEADDR,
      C_HIGHADDR => C_HIGHADDR
    )
    Port Map (
      S_AXI_ACLK => S_AXI_ACLK,
      S_AXI_ARESETN => S_AXI_ARESETN,
      S_AXI_ARADDR => S_AXI_ARADDR,
      S_AXI_ARVALID => S_AXI_ARVALID,
      S_AXI_ARREADY => S_AXI_ARREADY,
      S_AXI_RDATA => S_AXI_RDATA,
      S_AXI_RRESP => S_AXI_RRESP,
      S_AXI_RVALID => rvalid,
      S_AXI_RREADY => S_AXI_RREADY,
      SPICR_Read => SPICR_Read,
      SPISR_Read => SPISR_Read,
      SPIDRR_Read => SPIDRR_Read,
      SPISSR_Read => SPISSR_Read,
      Tx_FIFO_OCY_Read => Tx_FIFO_OCY_Read,
      Rx_FIFO_OCY_Read => Rx_FIFO_OCY_Read,
      DGIER_Read => DGIER_Read,
      IPISR_Read => IPISR_Read,
      IPIER_Read => IPIER_Read,
      temp_read_address_out => temp_read_address,
      SPIDRR_Read_en => SPIDRR_Read_en,
      SPISR_Read_en => SPISR_Read_en
    );
      
  S_AXI_RVALID <= rvalid;

end Structural;
