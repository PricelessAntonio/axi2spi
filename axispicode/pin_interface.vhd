

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;  
entity pin_interface is
 generic (C_NUM_TRANSFER_BITS: INTEGER:=8;
           C_NUM_SS_BITS:INTEGER:=8); 
 --------- spi internal signal ------------
    Port ( clk : in STD_LOGIC;       --- spi sck clock
           reset:in std_logic;
           enable:in std_logic;      --- spi enable
           tx_data: in std_logic;    --- tx shifter data 
           rx_data: inout std_logic;   --- rx shifter data
           MOSI_EN  :in std_logic;   --- enable MOSI_O ouput
           MISO_EN  :in std_logic;    --- enable MISO_I input
           tx_data_rdy:in std_logic;
           cpha       :in std_logic;
           cpol       :in std_logic;
           master     :in std_logic;
           manual_slave:in std_logic;
           ssel       : in std_logic;
           SS    :IN STD_LOGIC_VECTOR( C_NUM_SS_BITS-1 DOWNTO 0);
           SS_O    :out STD_LOGIC_VECTOR(C_NUM_SS_BITS-1 DOWNTO 0);
  -------- spi out port signal -------------           
           sck_o : out STD_LOGIC;   --- spi sck output to slave
           sclk_i : in STD_LOGIC;   --- spi sck input for slave mode
           MISO_I : in std_logic;   --- MISO_I in master mode
           MOSI_O : out std_logic;  --- MOSI_O out mater mode
           MISO_O : out std_logic;  --- MISO_I out slave mode
           MOSI_I : in  std_logic;  --- MOSI_O in slave mode
           MOSI_T : OUT STD_LOGIC;
           MISO_T : OUT STD_LOGIC;       
           SS_T     : out STD_LOGIC); --- slave select enable
end pin_interface;

architecture Behavioral of pin_interface is
signal rx_data_master_rising:std_logic;
signal rx_data_master_falling:std_logic;
signal rx_data_slave:std_logic;
signal MISO_T_SLAVE:STD_LOGIC;
signal MOSI_T_SLAVE:STD_LOGIC;

signal MISO_T_MASTER_rising:STD_LOGIC;
signal MISO_T_MASTER_falling:STD_LOGIC;
signal MOSI_T_MASTER_rising:STD_LOGIC;
signal MOSI_T_MASTER_falling:STD_LOGIC;

signal SS_T_MASTER_rising:std_logic;
signal SS_T_MASTER_falling:std_logic;
signal SS_T_SLAVE:std_logic;

signal SS_O_MAUAL_rising:std_logic_VECTOR(C_NUM_SS_BITS-1 downto 0);
signal SS_O_MAUAL_falling:std_logic_VECTOR(C_NUM_SS_BITS-1 downto 0);

signal SS_O_AUTO_rising:STD_LOGIC_VECTOR(C_NUM_SS_BITS-1 downto 0);
signal SS_O_AUTO_falling:STD_LOGIC_VECTOR(C_NUM_SS_BITS-1 downto 0);
signal slave_counter:integer range 0 to C_NUM_SS_BITS-1;
signal slave_counter_rising:integer range 0 to C_NUM_SS_BITS-1;
signal slave_counter_falling:integer range 0 to C_NUM_SS_BITS-1;
signal tog_rising:std_logic;
signal tog_falling:std_logic;
signal shifter_rising:unsigned(C_NUM_SS_BITS-1 downto 0):=x"fe";
signal shifter_falling:unsigned(C_NUM_SS_BITS-1 downto 0):=x"fe";

signal rising:std_logic;
signal falling:std_logic;
begin
 

 
 rising<= '1' when cpha ='1' and cpol ='1' else
          '1' when cpha ='0' and cpol ='0' else
          '0';
 
 falling<='1' when cpha ='1' and cpol ='0' else
          '1' when cpha ='0' and cpol ='1' else
          '0';


  rx_data<= rx_data_master_rising when master='1'and enable='1' and rising='1' else
            rx_data_master_falling when master='1'and enable='1' and falling='1' else
            rx_data_slave  when master='0' and enable='1'else
            'Z'            when enable='0';
            
  MOSI_T <= MOSI_T_MASTER_rising when master='1' and rising='1'else
            MOSI_T_MASTER_falling when master='1' and falling='1'else
            MOSI_T_SLAVE  when master='0' else
            '1'           when enable='0' else
            '1';
            
  MISO_T <= MISO_T_MASTER_rising when master='1' and rising ='1' else
            MISO_T_MASTER_falling when master='1' and falling ='1' else
            MISO_T_SLAVE  when master='0' else 
             '1'           when enable='0' else
            '1';
            
  SS_T  <= SS_T_MASTER_rising when master='1' and rising='1'else
           SS_T_MASTER_falling when master='1' and falling='1'else
           SS_T_SLAVE when master='0'  else
           '1';
  SS_O  <= SS_O_MAUAL_rising  when manual_slave='1' and rising='1' else
           SS_O_MAUAL_falling  when manual_slave='1' and falling='1' else
           SS_O_AUTO_rising    when manual_slave='0' and rising='1' else
           SS_O_AUTO_falling    when manual_slave='0' and falling='1'else
           x"fe" ;
          
 sck_o  <=clk when enable ='1' and master='1';
  ------confilic-----signal  confile<= '1' when master='1' and ssel='1'
  ----------------------- master mode ----------------------------
  
  -------------loop back ------------------
   process(clk,reset)
   begin
   if(reset='0')then
    MISO_T_MASTER_rising<='1';
    MISO_T_MASTER_falling<='1';
--    MOSI_T_MASTER<='1';
--    SS_T_MASTER<='1';
--    SS_O_MAUAL<=x"ffffffff";
   else
   if(rising_edge(clk)and ((cpha ='0'and cpol='0')or(cpha ='1'and cpol='1')) )then
    if(enable='1' and master ='1') then
     if( MISO_EN='0'and tx_data_rdy='1' )then  ---- loopback off
       rx_data_master_rising<=MISO_I;
       MISO_T_MASTER_rising<='0';
     elsif (MISO_EN='1'and tx_data_rdy='1' )then ----loopback on MISO_T deacvtive
       rx_data_master_rising<=tx_data;
       MISO_T_MASTER_rising<='0';
     end if;
     elsif((enable='0'or tx_data_rdy='0') and master ='1')then
        MISO_T_MASTER_rising<='1';
    end if;
 end if;  
 
 if(falling_edge(clk)and ((cpha ='0'and cpol='1')or(cpha ='1'and cpol='0')) )then
    if(enable='1' and master ='1') then
     if( MISO_EN='0'and tx_data_rdy='1' )then  ---- loopback off
       rx_data_master_falling<=MISO_I;
       MISO_T_MASTER_falling<='0';
     elsif (MISO_EN='1'and tx_data_rdy='1' )then ----loopback on MISO_T deacvtive
       rx_data_master_falling<=tx_data;
       MISO_T_MASTER_falling<='0';
     end if;
     elsif((enable='0'or tx_data_rdy='0') and master ='1')then
        MISO_T_MASTER_falling<='1';
    end if;
  end if;
end if;
 end process;
------------------- master trancaction inhabit--------------------

process(clk,reset)
 begin
  if(reset='0')then
    MOSI_T_MASTER_rising<='1';
    MOSI_T_MASTER_falling<='1';
  else
   if(rising_edge(clk)and ((cpha ='0'and cpol='0')or(cpha ='1'and cpol='1')) )then
    if(enable='1' and master='1') then
      if( MOSI_EN='0' and tx_data_rdy='1')then
       MOSI_o<=tx_data;
       MOSI_T_MASTER_rising<='0';
      elsif(MOSI_EN='1' and tx_data_rdy='1')then
       MOSI_o<='Z';
       MOSI_T_MASTER_rising<='0';
       end if;
       elsif((enable='0'or tx_data_rdy='0') and master ='1')then
       MOSI_T_MASTER_rising<='1';
      end if;
     end if;
     
    if(falling_edge(clk)and ((cpha ='0'and cpol='1')or(cpha ='1'and cpol='0')) )then
    if(enable='1' and master='1') then
      if( MOSI_EN='0' and tx_data_rdy='1')then
       MOSI_o<=tx_data;
       MOSI_T_MASTER_falling<='0';
      elsif(MOSI_EN='1' and tx_data_rdy='1')then
       MOSI_o<='Z';
       MOSI_T_MASTER_falling<='0';
       end if;
       elsif((enable='0'or tx_data_rdy='0') and master ='1')then
       MOSI_T_MASTER_falling<='1';
      end if;
     end if;
    end if;
   end process;

------------------SS_T----------------------
process(clk,reset)
 begin
  if(reset='0')then
    SS_T_MASTER_rising<='1';
    SS_T_MASTER_falling<='1';
   else
   if(rising_edge(clk)and ((cpha ='0'and cpol='0')or(cpha ='1'and cpol='1')) )then
      if(enable='1' and master='1')then
         SS_T_MASTER_rising<='0';
       else
         SS_T_MASTER_rising<='1';
       end if;
      end if;
    if(falling_edge(clk)and ((cpha ='0'and cpol='1')or(cpha ='1'and cpol='0')) )then
      if(enable='1' and master='1')then
         SS_T_MASTER_falling<='0';
       else
         SS_T_MASTER_falling<='1';
       end if;
    end if;
   end if;
 end process;
 
 ----------------ss manual select--------------------
 process(clk,reset)
 begin
  if(reset='0')then
   SS_O_MAUAL_rising<=x"ff";
   SS_O_MAUAL_falling<=x"ff";
   else
   if(rising_edge(clk)and ((cpha ='0'and cpol='0')or(cpha ='1'and cpol='1')) )then
       if(enable='1' and master='1')then
        if(manual_slave='1')then
         SS_O_MAUAL_rising<=SS;
       else
         SS_O_MAUAL_rising<=x"ff";
       end if;
  end if;
 end if;
    if(falling_edge(clk)and ((cpha ='0'and cpol='1')or(cpha ='1'and cpol='0')) )then
     if(enable='1' and master='1')then
        if(manual_slave='1')then
         SS_O_MAUAL_falling<=SS;
       else
         SS_O_MAUAL_falling<=x"ff";
       end if;
   end if;
  end if;
 end if;
 end process;
 
 ----------ss auto select-------------------
 process(clk,reset)
  begin
   if(reset='0') then
   SS_O_AUTO_rising<=x"ff";
   SS_O_AUTO_falling<=x"ff";
   else
    if(rising_edge(clk) and ((cpha ='0'and cpol='0')or(cpha ='1'and cpol='1')) )then
     if(enable='1' and master='1') then
       if(tog_rising='1')then
         SS_O_AUTO_rising<= std_logic_vector(rotate_left(unsigned(shifter_rising), 1));
          shifter_rising<= (rotate_left(unsigned(shifter_rising), 1));
        else
         SS_O_AUTO_rising<=std_logic_vector(shifter_rising);
        end if;
       end if;
     end if;
         
    
   if(falling_edge(clk)and ((cpha ='0'and cpol='1')or(cpha ='1'and cpol='0')) )then
     if(enable='1' and master='1') then
       if(tog_rising='1')then
         SS_O_AUTO_falling<= std_logic_vector(rotate_left(unsigned(shifter_rising), 1));
          shifter_falling<= (rotate_left(unsigned(shifter_rising), 1));
        else
         SS_O_AUTO_falling<=std_logic_vector(shifter_rising);
        end if;
       end if;
     end if;
   end if;
  end process;
  
  
  
  
------------ss auto counter ---------------
   
   process(clk,reset)
  begin
   if(reset='0') then
     slave_counter_rising<=0;
     slave_counter_falling<=0;
     tog_rising<='0';
      tog_falling<='0';
   else
    if(rising_edge(clk) and ((cpha ='0'and cpol='0')or(cpha ='1'and cpol='1')) )then
     if(enable='1' and master='1') then
       if(tx_data_rdy='1')then
         if(slave_counter_rising = C_NUM_SS_BITS-1) then
           slave_counter_rising<=0;
           tog_rising<='1';
          else
           slave_counter_rising<=slave_counter_rising+1;
           tog_rising<='0';
         end if;
       end if;
     end if;
    end if;
   
   if(falling_edge(clk)and ((cpha ='0'and cpol='1')or(cpha ='1'and cpol='0')) )then
     if(enable='1' and master='1') then
       if(tx_data_rdy='1')then
         if(slave_counter_falling = C_NUM_SS_BITS-1) then
           slave_counter_falling<=0;
           tog_falling<='1';
          else
           slave_counter_falling<=slave_counter_falling+1;
           tog_falling<='0';
         end if;
       end if;
     end if;
    end if;
   end if;
  end process;
  

  -------------slave mode ------------------- 
   process(clk,reset)
   begin
   if(reset='0')then
    MOSI_T_SLAVE<='1';
    MISO_T_SLAVE<='1';
    SS_T_SLAVE<='1';
   elsif(rising_edge(clk))then 
    if(enable='1' and master ='0') then
     if(  tx_data_rdy='1' )then  
       rx_data_slave<=MOSI_I;
       MOSI_T_SLAVE<='0';
     else
       MOSI_T_SLAVE<='1';
     end if;
     elsif((enable='0'or tx_data_rdy='0') and master ='0')then
        MOSI_T_SLAVE<='1';
    end if;
    
    
     if(enable='1' and master ='0') then
     if(  tx_data_rdy='1' )then  
       MISO_O<=tx_data;
       MISO_T_SLAVE<='0';
     else
       MISO_T_SLAVE<='1';
     end if;
     elsif((enable='0'or tx_data_rdy='0') and master ='0')then
        MISO_T_SLAVE<='1';
    end if;
    
      if(enable='1' and master='0')then
         SS_T_SLAVE<='0';
       else
         SS_T_SLAVE<='1';
       end if;
   end if;
  end process;


   
end Behavioral;
