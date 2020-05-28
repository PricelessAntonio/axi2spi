library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity read_channel_logic is
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
    SPISR_Read_en  : OUT STD_LOGIC
  );
end read_channel_logic;

architecture Behavioral of read_channel_logic is

  -- Memory Map
  CONSTANT SRR_ADDR : STD_LOGIC_VECTOR((C_S_AXI_ADDR_WIDTH-1) DOWNTO 0)         := C_BASEADDR + x"40";
  CONSTANT SPICR_ADDR : STD_LOGIC_VECTOR((C_S_AXI_ADDR_WIDTH-1) DOWNTO 0)       := C_BASEADDR + x"60";
  CONSTANT SPISR_ADDR : STD_LOGIC_VECTOR((C_S_AXI_ADDR_WIDTH-1) DOWNTO 0)       := C_BASEADDR + x"64";
  CONSTANT SPIDTR_ADDR : STD_LOGIC_VECTOR((C_S_AXI_ADDR_WIDTH-1) DOWNTO 0)      := C_BASEADDR + x"68";
  CONSTANT SPIDRR_ADDR : STD_LOGIC_VECTOR((C_S_AXI_ADDR_WIDTH-1) DOWNTO 0)      := C_BASEADDR + x"6C";
  CONSTANT SPISSR_ADDR : STD_LOGIC_VECTOR((C_S_AXI_ADDR_WIDTH-1) DOWNTO 0)      := C_BASEADDR + x"70";
  CONSTANT Tx_FIFO_OCY_ADDR : STD_LOGIC_VECTOR((C_S_AXI_ADDR_WIDTH-1) DOWNTO 0) := C_BASEADDR + x"74";
  CONSTANT Rx_FIFO_OCY_ADDR : STD_LOGIC_VECTOR((C_S_AXI_ADDR_WIDTH-1) DOWNTO 0) := C_BASEADDR + x"78";
  CONSTANT DGIER_ADDR : STD_LOGIC_VECTOR((C_S_AXI_ADDR_WIDTH-1) DOWNTO 0)       := C_BASEADDR + x"1C";
  CONSTANT IPISR_ADDR : STD_LOGIC_VECTOR((C_S_AXI_ADDR_WIDTH-1) DOWNTO 0)       := C_BASEADDR + x"20";
  CONSTANT IPIER_ADDR : STD_LOGIC_VECTOR((C_S_AXI_ADDR_WIDTH-1) DOWNTO 0)       := C_BASEADDR + x"28";

  SIGNAL arready : STD_LOGIC;
  SIGNAL rvalid : STD_LOGIC;
  SIGNAL temp_read_address : STD_LOGIC_VECTOR((C_S_AXI_ADDR_WIDTH-1) DOWNTO 0);
  SIGNAL read_out : STD_LOGIC;

begin

  store_read_address_seq : PROCESS (S_AXI_ACLK, S_AXI_ARESETN) -- Stores read address when ARVALID, RREADY, and ARREADY are high
  begin
  
    if (S_AXI_ARESETN = '0') then
      arready <= '0';
      temp_read_address <= (OTHERS => '0');
      rvalid <= '0';
      
    elsif (rising_edge(S_AXI_ACLK)) then
      if (rvalid = '0') then
        if (S_AXI_ARVALID = '1') then
          if (arready = '1') then  -- arready is dependant on ARVALID
            arready <= '0';
            temp_read_address <= S_AXI_ARADDR;
            rvalid <= '1'; -- Allows read_out_logic to output read from register

          else
            arready <= '1';
            temp_read_address <= temp_read_address;
            rvalid <= '0';

          end if;
        else
          arready <= '0';
          temp_read_address <= temp_read_address;
          rvalid <= '0';

        end if;
      else
        if (S_AXI_RREADY = '1') then -- De-asserts rvalid after one clock when rready is high
          arready <= '0';
          temp_read_address <= S_AXI_ARADDR;
          rvalid <= '0';
           
        end if;
      end if;
    end if;

  end process store_read_address_seq;
  
  S_AXI_ARREADY <= arready;

  read_response_comb : process (S_AXI_ARESETN, rvalid, S_AXI_RREADY)
  begin

    if (S_AXI_ARESETN = '0') then
      S_AXI_RDATA   <= (OTHERS => '0');
      S_AXI_RRESP   <= "00";
      SPIDRR_Read_en <= '0';
      SPISR_Read_en <= '0';
      
    elsif (rvalid = '1' AND (S_AXI_RREADY = '1')) then
      if (temp_read_address = SRR_ADDR) then
        S_AXI_RDATA <= (OTHERS => '0');
        S_AXI_RRESP <= "01";
        SPIDRR_Read_en <= '0';
        SPISR_Read_en <= '0';

      elsif (temp_read_address = SPICR_ADDR) then
        S_AXI_RDATA <= SPICR_Read;
        S_AXI_RRESP <= "00";
        SPIDRR_Read_en <= '0';
        SPISR_Read_en <= '0';

      elsif (temp_read_address = SPISR_ADDR) then
        S_AXI_RDATA <= SPISR_Read;
        S_AXI_RRESP <= "00";
        SPIDRR_Read_en <= '0';
        SPISR_Read_en <= '1';
        
      elsif (temp_read_address = SPIDTR_ADDR) then
        S_AXI_RDATA <= (OTHERS => '0');
        S_AXI_RRESP <= "01";
        SPIDRR_Read_en <= '0';
        SPISR_Read_en <= '0';

      elsif (temp_read_address = SPIDRR_ADDR) then
        S_AXI_RDATA <= SPIDRR_Read;
        S_AXI_RRESP <= "00";
        SPIDRR_Read_en <= '1';
        SPISR_Read_en <= '0';

      elsif (temp_read_address = SPISSR_ADDR) then
        S_AXI_RDATA <= SPISSR_Read;
        S_AXI_RRESP <= "00";
        SPIDRR_Read_en <= '0';
        SPISR_Read_en <= '0';

      elsif (temp_read_address = Tx_FIFO_OCY_ADDR) then
        S_AXI_RDATA <= Tx_FIFO_OCY_Read;
        S_AXI_RRESP <= "00";
        SPIDRR_Read_en <= '0';
        SPISR_Read_en <= '0';

      elsif (temp_read_address = Rx_FIFO_OCY_ADDR) then
        S_AXI_RDATA <= Rx_FIFO_OCY_Read;
        S_AXI_RRESP <= "00";
        SPIDRR_Read_en <= '0';
        SPISR_Read_en <= '0';

      elsif (temp_read_address = DGIER_ADDR) then
        S_AXI_RDATA <= DGIER_Read;
        S_AXI_RRESP <= "00";
        SPIDRR_Read_en <= '0';
        SPISR_Read_en <= '0';

      elsif (temp_read_address = IPISR_ADDR) then
        S_AXI_RDATA <= IPISR_Read;
        S_AXI_RRESP <= "00";
        SPIDRR_Read_en <= '0';
        SPISR_Read_en <= '0';

      elsif (temp_read_address = IPIER_ADDR) then
        S_AXI_RDATA <= IPIER_Read;
        S_AXI_RRESP <= "00";
        SPIDRR_Read_en <= '0';
        SPISR_Read_en <= '0';

      else
        S_AXI_RDATA <= (OTHERS => '0');
        S_AXI_RRESP <= "11";
        SPIDRR_Read_en <= '0';
        SPISR_Read_en <= '0';

      end if;
    else
      S_AXI_RDATA <= (OTHERS => '0');
      S_AXI_RRESP <= "00";
      SPIDRR_Read_en <= '0';
      SPISR_Read_en <= '0';

    end if;
  
  end process read_response_comb;

  S_AXI_RVALID <= rvalid;
  temp_read_address_out <= temp_read_address;

end Behavioral;
