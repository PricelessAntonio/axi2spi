    

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

LIBRARY work; 
USE work.spi_pkg.ALL; 

entity spi_interface is
generic (C_NUM_TRANSFER_BITS: INTEGER:=8;
          C_NUM_SS_BITS:INTEGER:=8); 
    Port ( clk : in STD_LOGIC;      ----- system_clock
           sck_o:out std_logic;     ----- sck to spi slave
           slave_clk:in std_logic;  ----- slave mode clock from spi master
           reset: in std_logic;     
          ------contorl signals---------
           enable : in STD_LOGIC;   ----- spi enable signal    
           cpha_i : in std_logic;   ----- cpha in
           cpol_i : in std_logic;   ----- cpol in
           MSS    : in std_logic;   ----- Master transaction inhabit 
           loopback:in std_logic;   ----- loopback
           SSEL    : in std_logic;  ----- spi slave mode
           lsb     : in std_logic;  ----- lsb first mode
           manual_slave:in std_logic;---- manual slave select 
           master:in std_logic;      ----- master mode
         ------slave reg signals ---------
           SS    :IN STD_LOGIC_VECTOR(C_NUM_SS_BITS-1 DOWNTO 0);
        ------spi output signals-------
           MISO_I : in STD_LOGIC;     ----- MISO_I in master mode
           MOSI_O : out STD_LOGIC;    ----- MOSI_O out master mode
           MISO_O : out std_logic;    ----- MISO_O out slave mode
           MOSI_I : in std_logic;     ----- MOSI_I in slave mode
           MOSI_T: OUT STD_LOGIC;     ----- MOSI_T enable
           MISO_T: OUT STD_LOGIC;     ----- MISO_T enable
           SS_T    : OUT STD_LOGIC;   ----- slave enable
           SS_O    :out STD_LOGIC_VECTOR(C_NUM_SS_BITS-1 DOWNTO 0); ----- skave select out
        -------- status signals---------
           MODF    :OUT STD_LOGIC;    ----- MODF ERROR active low
           SLAVE_SEL_MOD:OUT STD_LOGIC; --- SLAVE SELECT ERROR active high 
           SLAVE_MODF:OUT STD_LOGIC;  ----- slave modf active low
------------ tx signal ports --------------         
           cpha_o : out std_logic;    ------ CPHA OUT TO FIFO
           cpol_o : out std_logic;    ------ CPOL OUT TO FIFO
           sclk_fifo:out std_logic;   ------ slk to fifo
           data_re: out STD_LOGIC;    ------ tx data read enable
           tx_fifo_reg:in std_logic_vector(31 downto 0);
------------ rx signal ports  --------------
           fifo_en : out STD_LOGIC;   ------ rx fifo write enable
           rx_fifo_reg:out std_logic_vector(31 downto 0));
end spi_interface;

architecture Behavioral of spi_interface is

signal clock:std_logic;
signal sck  :std_logic;
signal sck_master:std_logic;
signal sck_slave:std_logic;
signal spi_en: std_logic;

signal cpol:std_logic;
signal cpha:std_logic;

signal tx_data:std_logic;
signal rx_data:std_logic;
signal sck_i:std_logic;
signal rx_enable:std_logic;
signal data_rady:std_logic; --tx data ready send out
begin
------ spi clock mux selector ---------
 sck<=sck_master when master ='1' else ----master mode spi clock
      slave_clk  when master ='0';     ----slave mode spi clock

 spi_en<=enable and (master xnor ssel);
 
 cpol <=cpol_i when master='1' else
        '0'    when master='0';
 
 cpha <=cpha_i when master='1' else
        '0'    when master='0';      
 
sclk_fifo <= sck;
cpha_o<=cpha;
cpol_o<=cpol;

 BRG_is: BRG
  port map( clk_i=>clk,
            clk_o=>clock);
            
 clk_logic_is: clk_logic
   Port map(clk_i =>clock,
           cpol_i   =>cpol,
           cpha_i   => cpha,
           sclk_o =>sck_master);
 
 tx_shifter_is : tx_shifter
     -- generic (C_NUM_TRANSFER_BITS: INTEGER := 8);
      Port map ( clk => sck,
           reset    =>reset,
           enable => spi_en,
           cpha => cpha,
           cpol=> cpol,
           rx_enable=>rx_enable,
           lsb      =>lsb,
           data_rady=>data_rady,
          -- data_re=>data_re,
          -- data_re1=>data_re1,
          fifo_rd_en=>data_re,
           datain => tx_fifo_reg,
           dataout =>tx_data);
          
   rx_shifter_is:rx_shifter   
     Port map ( clk =>sck,
               reset=>reset,
               lsb  =>lsb,
               enable =>rx_enable,
               cpha   =>cpha,
               cpol   => cpol,
               fifo_en=>fifo_en,
               datain => rx_data,
               dataout =>rx_fifo_reg);
   
   pin_interface_is: pin_interface
      --------- spi internal signal ------------
 Port map ( clk =>sck,      --- spi sck clock
           reset=>reset,
           enable=>spi_en,     --- spi enable
           tx_data=>tx_data,    --- tx shifter data 
           rx_data=>rx_data,   --- rx shifter data
           MOSI_EN =>mss,
           MISO_EN =>loopback,
           tx_data_rdy=>data_rady,
           cpha=>cpha,
           cpol=>cpol,
           master=>master,
           manual_slave=>manual_slave,
           ss=>ss,
           ss_o=>ss_o,
           ssel=>ssel,
  -------- spi out port signal -------------           
           sck_o  => sck_o,   --- spi sck output to slave
           sclk_i => sck_i,   --- spi sck input for slave mode
           MISO_I => MISO_I,   --- MISO_I in master
           MOSI_O => MOSI_O,  --- MOSI_O out mater
           MISO_O=>MISO_O,
           MOSI_I=>MOSI_I,
           MOSI_T => MOSI_T,
           MISO_T => MISO_T,            
            SS_T      => ss_t);     --- slave select ENABLE
    
    control_unit_is:control_unit
  Port map ( clk =>sck,
             reset=>reset,
             spi_en =>enable,
             master =>master,
             ssel   =>ssel,
             MODF   =>MODF,
             SLAVE_SEL_MOD=>SLAVE_SEL_MOD,
             SLAVE_MODF=>SLAVE_MODF);
               
end Behavioral;
