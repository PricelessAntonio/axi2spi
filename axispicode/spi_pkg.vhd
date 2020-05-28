

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package spi_pkg is
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
   
   component pin_interface
   --------- spi internal signal ------------
    generic (C_NUM_TRANSFER_BITS: INTEGER:=8;
           C_NUM_SS_BITS:INTEGER:=8); 
    Port ( clk : in STD_LOGIC;      --- spi sck clock
           reset:in std_logic;
           enable:in std_logic;     --- spi enable
           tx_data: in std_logic;  --- tx shifter data 
           rx_data: inout std_logic;  --- rx shifter data
           MOSI_EN  :in std_logic;    
           MISO_EN  :in std_logic;
           tx_data_rdy:in std_logic;
           cpha       :in std_logic;
           cpol       :in std_logic;
           master     :in std_logic;
           manual_slave:in std_logic;
           SS    :IN STD_LOGIC_VECTOR(C_NUM_SS_BITS-1 DOWNTO 0);
           SS_O    :out STD_LOGIC_VECTOR(C_NUM_SS_BITS-1 DOWNTO 0);
           ssel       : in std_logic;
  -------- spi out port signal -------------           
           sck_o : out STD_LOGIC;   --- spi sck output to slave
           sclk_i : in STD_LOGIC;   --- spi sck input for slave mode
           MISO_I : in std_logic;   --- MISO_I in master
           MOSI_O : out std_logic;  --- MOSI_O out mater  
           MISO_O : out std_logic;  --- MISO_I out slave mode
           MOSI_I : in std_logic;  --- MOSI_O in slave mode
           MOSI_T : OUT STD_LOGIC;
           MISO_T : OUT STD_LOGIC;     
           SS_T  : out STD_LOGIC);     --- slave select
    end component;
   
   component control_unit
      Port ( clk : in STD_LOGIC;
           reset:in std_logic;
           spi_en : in STD_LOGIC;
           master : in STD_LOGIC;
           ssel : in STD_LOGIC;
           MODF    :OUT STD_LOGIC;
           SLAVE_SEL_MOD:OUT STD_LOGIC;
           SLAVE_MODF:OUT STD_LOGIC);
   end component;
   
  
   
   component BRG
   generic( c_sck_ratio: integer := 2);
    Port ( CLK_I : in STD_LOGIC;
           CLK_O : out STD_LOGIC);
    end component;
    
    component clk_logic
     Port (clk_i : in STD_LOGIC;
           cpol_i  : in STD_LOGIC;
           cpha_i  : in std_logic;
           sclk_o : out STD_LOGIC);
     end component;
    
    component tx_shifter
     generic (C_NUM_TRANSFER_BITS: INTEGER:=8); 
     Port ( clk : in STD_LOGIC;
            reset:in std_logic;
           enable : in STD_LOGIC;
           rx_enable:out std_logic;
           data_rady:out std_logic;
           lsb    : in std_logic;
           cpha   : in std_logic;
           cpol   : in std_logic;
           datain : in STD_LOGIC_VECTOR (31 downto 0);
      --   data_re: out std_logic;    ------- data requeset signal to fifo 
        -- data_re1:out std_logic; 
           fifo_rd_en:out std_logic; ------- data requeset signal to fifo 
           dataout : out STD_LOGIC);
   end component;
   
   component tx_fifo
    generic (C_NUM_TRANSFER_BITS: INTEGER:=8); 
 port( wdata : in std_logic_vector(31 downto 0);  
       cpha : in std_logic;
       cpol : in std_logic;
       w_enable, r_enable, reset : in std_logic;
       wclk, rclk : in std_logic;
       rdata : out std_logic_vector(31 downto 0);
       full_flag, empty_flag : out std_logic);
    end component;
    

   component rx_shifter
     generic ( C_NUM_TRANSFER_BITS:integer:=8);
     Port ( clk : in STD_LOGIC;
            reset:in std_logic;
            lsb  :in std_logic;
            enable : in STD_LOGIC;
            cpha   : in STD_LOGIC;
            cpol   : in STD_LOGIC;
            fifo_en: out std_logic;
            datain : in STD_LOGIC;
            dataout: out STD_LOGIC_VECTOR (31 downto 0));
      end component;
      
    component rx_fifo
 port( wdata : in std_logic_vector(31 downto 0);
      w_enable, r_enable,reset : in std_logic;
      cpha   : in std_logic;
      cpol   : in std_logic;
      wclk, rclk : in std_logic;
      rdata : out std_logic_vector(31 downto 0);
      full_flag, empty_flag : out std_logic);
    end component;

  

end spi_pkg;
