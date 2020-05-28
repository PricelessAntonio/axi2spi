library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity write_channel_logic is
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
end write_channel_logic;

architecture Behavioral of write_channel_logic is

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
  
  SIGNAL awready : STD_LOGIC;
  SIGNAL wready : STD_LOGIC;
  SIGNAL bvalid : STD_LOGIC;
  SIGNAL temp_write_address : STD_LOGIC_VECTOR((C_S_AXI_ADDR_WIDTH-1) DOWNTO 0);
  SIGNAL temp_write_data : STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH-1) DOWNTO 0);
  SIGNAL write_address_stored : STD_LOGIC;
  SIGNAL write_data_stored : STD_LOGIC;

begin

  store_write_address_seq : process (S_AXI_ACLK, S_AXI_ARESETN)
  begin
  
    if (S_AXI_ARESETN = '0') then
      awready <= '0';
      temp_write_address <= (OTHERS => '0');
      write_address_stored <= '0';
      
    elsif (rising_edge(S_AXI_ACLK)) then
      if (write_address_stored = '0') then
        if (S_AXI_AWVALID = '1') then
          if (awready = '1') then
            awready <= '0';
            temp_write_address <= S_AXI_AWADDR;
            write_address_stored <= '1';
            
          else
            awready <= '1';
            temp_write_address <= temp_write_address;
            write_address_stored <= '0';
          
          end if;
        else
          awready <= '0';
          temp_write_address <= temp_write_address;
          write_address_stored <= '0';
        
        end if;
      else
        if ((write_data_stored = '1') AND (S_AXI_BREADY = '1')) then
          write_address_stored <= '0';
          
        end if;
      end if;
    end if;
  
  end process store_write_address_seq;
  
  S_AXI_AWREADY <= awready;
  
  store_write_data_seq : process(S_AXI_ACLK, S_AXI_ARESETN)
  begin
  
    if (S_AXI_ARESETN = '0') then
      wready <= '0';
      temp_write_data <= (OTHERS => '0');
      write_data_stored <= '0';
      Strobe <= "0000";
      
    elsif (rising_edge(S_AXI_ACLK)) then
      if (write_data_stored = '0') then
        if (S_AXI_WVALID = '1') then
          if (wready = '1') then
            wready <= '0';
            temp_write_data <= S_AXI_WDATA;
            write_data_stored <= '1';
            Strobe <= S_AXI_WSTB;

          else
            wready <= '1';
            temp_write_data <= temp_write_data;
            write_data_stored <= '0';
            Strobe <= "0000";

          end if;
        else
          wready <= '0';
          temp_write_data <= temp_write_data;
          write_data_stored <= '0';
          Strobe <= "0000";
        
        end if;
      else
        if ((write_address_stored = '1') AND (S_AXI_BREADY = '1')) then
          write_data_stored <= '0';
          Strobe <= "0000";
          
        end if;
      end if;
    end if;
  
  end process store_write_data_seq;
  
  S_AXI_WREADY <= wready;
  
  bvalid <= write_address_stored AND write_data_stored;
  
  write_response_comb : process (S_AXI_ARESETN, bvalid, S_AXI_BREADY)
  begin
  
    if (S_AXI_ARESETN = '0') then
      S_AXI_BRESP <= "00";
      SRR_En    <= '0';
      SPICR_En  <= '0';
      SPIDTR_En <= '0';
      SPISSR_En <= '0';
      DGIER_En  <= '0';
      IPISR_En  <= '0';
      IPIER_En  <= '0';
      
    elsif ((bvalid = '1') AND (S_AXI_BREADY = '1')) then
      if (temp_write_address = SRR_ADDR) then
        S_AXI_BRESP <= "00";
        SRR_En    <= '1';
        SPICR_En  <= '0';
        SPIDTR_En <= '0';
        SPISSR_En <= '0';
        DGIER_En  <= '0';
        IPISR_En  <= '0';
        IPIER_En  <= '0';
          
      elsif (temp_write_address = SPICR_ADDR) then
        if (rvalid = '1' AND temp_read_address = SPICR_ADDR) then
          S_AXI_BRESP <= "01";
          SRR_En    <= '0';
          SPICR_En  <= '0';
          SPIDTR_En <= '0';
          SPISSR_En <= '0';
          DGIER_En  <= '0';
          IPISR_En  <= '0';
          IPIER_En  <= '0';
            
        else
          S_AXI_BRESP <= "00";
          SRR_En    <= '0';
          SPICR_En  <= '1';
          SPIDTR_En <= '0';
          SPISSR_En <= '0';
          DGIER_En  <= '0';
          IPISR_En  <= '0';
          IPIER_En  <= '0';

        end if;
      elsif (temp_write_address = SPISR_ADDR) then
        S_AXI_BRESP <= "01";
        SRR_En    <= '0';
        SPICR_En  <= '0';
        SPIDTR_En <= '0';
        SPISSR_En <= '0';
        DGIER_En  <= '0';
        IPISR_En  <= '0';
        IPIER_En  <= '0';
          
      elsif (temp_write_address = SPIDTR_ADDR) then
        if (tx_full = '0') then
          S_AXI_BRESP <= "00";
          SRR_En    <= '0';
          SPICR_En  <= '0';
          SPIDTR_En <= '1';
          SPISSR_En <= '0';
          DGIER_En  <= '0';
          IPISR_En  <= '0';
          IPIER_En  <= '0';
          
        else
          S_AXI_BRESP <= "01";
          SRR_En    <= '0';
          SPICR_En  <= '0';
          SPIDTR_En <= '0';
          SPISSR_En <= '0';
          DGIER_En  <= '0';
          IPISR_En  <= '0';
          IPIER_En  <= '0';
           
        end if;
      elsif (temp_write_address = SPIDRR_ADDR) then
        S_AXI_BRESP <= "01";
        SRR_En    <= '0';
        SPICR_En  <= '0';
        SPIDTR_En <= '0';
        SPISSR_En <= '0';
        DGIER_En  <= '0';
        IPISR_En  <= '0';
        IPIER_En  <= '0';
            
      elsif (temp_write_address = SPISSR_ADDR) then
        if (rvalid = '1' AND temp_read_address = SPISSR_ADDR) then
          S_AXI_BRESP <= "01";
          SRR_En    <= '0';
          SPICR_En  <= '0';
          SPIDTR_En <= '0';
          SPISSR_En <= '0';
          DGIER_En  <= '0';
          IPISR_En  <= '0';
          IPIER_En  <= '0';
            
        else
          S_AXI_BRESP <= "00";
          SRR_En    <= '0';
          SPICR_En  <= '0';
          SPIDTR_En <= '0';
          SPISSR_En <= '1';
          DGIER_En  <= '0';
          IPISR_En  <= '0';
          IPIER_En  <= '0';
        
        end if;
      elsif (temp_write_address = Tx_FIFO_OCY_ADDR) then
        S_AXI_BRESP <= "01";
        SRR_En    <= '0';
        SPICR_En  <= '0';
        SPIDTR_En <= '0';
        SPISSR_En <= '0';
        DGIER_En  <= '0';
        IPISR_En  <= '0';
        IPIER_En  <= '0';
          
      elsif (temp_write_address = Rx_FIFO_OCY_ADDR) then
        S_AXI_BRESP <= "01";
        SRR_En    <= '0';
        SPICR_En  <= '0';
        SPIDTR_En <= '0';
        SPISSR_En <= '0';
        DGIER_En  <= '0';
        IPISR_En  <= '0';
        IPIER_En  <= '0';
          
      elsif (temp_write_address = DGIER_ADDR) then
        if (rvalid = '1' AND temp_read_address = DGIER_ADDR) then
          S_AXI_BRESP <= "01";
          SRR_En    <= '0';
          SPICR_En  <= '0';
          SPIDTR_En <= '0';
          SPISSR_En <= '0';
          DGIER_En  <= '0';
          IPISR_En  <= '0';
          IPIER_En  <= '0';
            
        else
          S_AXI_BRESP <= "00";
          SRR_En    <= '0';
          SPICR_En  <= '0';
          SPIDTR_En <= '0';
          SPISSR_En <= '0';
          DGIER_En  <= '1';
          IPISR_En  <= '0';
          IPIER_En  <= '0';

        end if;
      elsif (temp_write_address = IPISR_ADDR) then
        if (rvalid = '1' AND temp_read_address = IPISR_ADDR) then
          S_AXI_BRESP <= "01";
          SRR_En    <= '0';
          SPICR_En  <= '0';
          SPIDTR_En <= '0';
          SPISSR_En <= '0';
          DGIER_En  <= '0';
          IPISR_En  <= '0';
          IPIER_En  <= '0';
            
        else
          S_AXI_BRESP <= "00";
          SRR_En    <= '0';
          SPICR_En  <= '0';
          SPIDTR_En <= '0';
          SPISSR_En <= '0';
          DGIER_En  <= '0';
          IPISR_En  <= '1';
          IPIER_En  <= '0';
            
        end if;
      elsif (temp_write_address = IPIER_ADDR) then
        if (rvalid = '1' AND temp_read_address = IPIER_ADDR) then
          S_AXI_BRESP <= "01";
          SRR_En    <= '0';
          SPICR_En  <= '0';
          SPIDTR_En <= '0';
          SPISSR_En <= '0';
          DGIER_En  <= '0';
          IPISR_En  <= '0';
          IPIER_En  <= '0';
            
        else
          S_AXI_BRESP <= "00";
          SRR_En    <= '0';
          SPICR_En  <= '0';
          SPIDTR_En <= '0';
          SPISSR_En <= '0';
          DGIER_En  <= '0';
          IPISR_En  <= '0';
          IPIER_En  <= '1';
        
        end if;
      else
        S_AXI_BRESP <= "11";
        SRR_En    <= '0';
        SPICR_En  <= '0';
        SPIDTR_En <= '0';
        SPISSR_En <= '0';
        DGIER_En  <= '0';
        IPISR_En  <= '0';
        IPIER_En  <= '0';
        
      end if;
    else
      S_AXI_BRESP <= "00";
      SRR_En    <= '0';
      SPICR_En  <= '0';
      SPIDTR_En <= '0';
      SPISSR_En <= '0';
      DGIER_En  <= '0';
      IPISR_En  <= '0';
      IPIER_En  <= '0';

    end if;
  
  end process write_response_comb;

  WriteToReg <= temp_write_data;
  S_AXI_BVALID <= bvalid;

end Behavioral;
