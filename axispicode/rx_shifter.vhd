

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity rx_shifter is
  generic ( C_NUM_TRANSFER_BITS:integer:=8);
  Port ( clk : in STD_LOGIC;
         reset:in std_logic;
         lsb  :in std_logic;
         enable : in STD_LOGIC;
         cpha   : in STD_LOGIC;
         cpol   : in STD_LOGIC;
         datain : in STD_LOGIC;
         fifo_en:out std_logic;
         dataout : out STD_LOGIC_VECTOR (31 downto 0));
end rx_shifter;

architecture Behavioral of rx_shifter is
signal counter:integer range 0 to C_NUM_TRANSFER_BITS-1;
signal shift_reg_rising:std_logic_vector(C_NUM_TRANSFER_BITS-1 downto 0);
signal shift_reg_falling:std_logic_vector(C_NUM_TRANSFER_BITS-1 downto 0);

signal iseight:std_logic:='0';
signal dataout_tmp:std_logic_vector(31 downto 0);

signal enable_dl:std_logic;
signal enable_dl_0:std_logic;

signal reg_8bits:std_logic_vector(31 downto 8):=x"000000"; 
signal reg_16bits:std_logic_vector(31 downto 16):=x"0000"; 

signal rising:std_logic;
signal falling:std_logic;

begin

 rising<= '1' when cpha ='1' and cpol ='1' else
          '1' when cpha ='0' and cpol ='0' else
          '0';
 
 falling<='1' when cpha ='1' and cpol ='0' else
          '1' when cpha ='0' and cpol ='1' else
          '0';



process(clk,reset)
begin
if(reset='0')then
enable_dl_0<='0';
elsif(rising_edge(clk)and ((cpha ='0'and cpol='0')or(cpha ='1'and cpol='1')))then
 if(enable='1')then
  enable_dl_0<='1';
  end if;
 end if;
 
 if(reset='0')then
enable_dl_0<='0';
 elsif(falling_edge(clk) and ((cpha ='0'and cpol='1')or(cpha ='1'and cpol='0')))then
 if(enable='1')then
  enable_dl_0<='1';
  end if;
 end if;
 end process;
 
process(clk,reset)
begin
if(reset='0')then
enable_dl<='0';
else
if(rising_edge(clk)and ((cpha ='0'and cpol='0')or(cpha ='1'and cpol='1')))then
 if(enable_dl_0='1')then
  enable_dl<='1';
  end if;
 end if;
 
if(falling_edge(clk) and ((cpha ='0'and cpol='1')or(cpha ='1'and cpol='0')))then
 if(enable_dl_0='1')then
  enable_dl<='1';
  end if;
 end if;
end if;
end process;

 process(clk)
-- variable shift_reg:std_logic_vector(7 downto 0);
  begin
   if(rising_edge(clk)and ((cpha ='0'and cpol='0')or(cpha ='1'and cpol='1')))then
    if(enable_dl='1')then
     if(lsb='1')then
     shift_reg_rising(C_NUM_TRANSFER_BITS-1 DOWNTO 0) <= datain&shift_reg_rising(C_NUM_TRANSFER_BITS-1 DOWNTO 1);
     elsif(lsb='0')then
     shift_reg_rising(C_NUM_TRANSFER_BITS-1 DOWNTO 0) <= shift_reg_rising(C_NUM_TRANSFER_BITS-1-1 DOWNTO 0)&datain;
     else
      shift_reg_rising(C_NUM_TRANSFER_BITS-1 DOWNTO 0) <= shift_reg_rising(C_NUM_TRANSFER_BITS-1-1 DOWNTO 0)&datain;
     end if;
    end if;
   end if;
   
     if(falling_edge(clk) and ((cpha ='0'and cpol='1')or(cpha ='1'and cpol='0')))then
      if(enable_dl='1')then
      if(lsb='1')then
       shift_reg_falling(C_NUM_TRANSFER_BITS-1 DOWNTO 0) <= datain&shift_reg_falling(C_NUM_TRANSFER_BITS-1 DOWNTO 1);
     elsif(lsb='0')then
       shift_reg_falling(C_NUM_TRANSFER_BITS-1 DOWNTO 0) <= shift_reg_falling(C_NUM_TRANSFER_BITS-1-1 DOWNTO 0)&datain;
       else
        shift_reg_falling(C_NUM_TRANSFER_BITS-1 DOWNTO 0) <= shift_reg_falling(C_NUM_TRANSFER_BITS-1-1 DOWNTO 0)&datain;
     end if;
    end if;
   end if;
  end process;
   
   
  
      dataout_tmp<=reg_8bits & shift_reg_rising(C_NUM_TRANSFER_BITS-1 downto 0) when C_NUM_TRANSFER_BITS=8 and rising='1' else
                   reg_8bits & shift_reg_falling(C_NUM_TRANSFER_BITS-1 downto 0) when C_NUM_TRANSFER_BITS=8 and falling='1' else
                   reg_16bits & shift_reg_rising when C_NUM_TRANSFER_BITS=16  and rising='1'else
                   reg_16bits & shift_reg_falling when C_NUM_TRANSFER_BITS=16  and falling='1'else
                   shift_reg_rising when C_NUM_TRANSFER_BITS=32 and rising='1'else  
                   shift_reg_falling when C_NUM_TRANSFER_BITS=32 and falling='1'       ;
    
     
     

 process(clk,reset)
  begin
  if(reset='0')then
   counter<=0;
   iseight<='0';
  elsif(rising_edge(clk)and ((cpha ='0'and cpol='0')or(cpha ='1'and cpol='1'))) then
   if(enable_dl='1') then
    if(counter =C_NUM_TRANSFER_BITS-1) then
     counter<=0;
     iseight<='1';
    else
    counter<=counter+1;
    iseight<='0';
      end if;
     end if;
    end if;
    
  if(reset='0')then
   counter<=0;
   iseight<='0';
  elsif(falling_edge(clk) and ((cpha ='0'and cpol='1')or(cpha ='1'and cpol='0'))) then
   if(enable_dl='1') then
    if(counter =C_NUM_TRANSFER_BITS-1) then
     counter<=0;
     iseight<='1';
    else
    counter<=counter+1;
    iseight<='0';
      end if;
     end if;
    end if;
   end process;
   --------- USE mux select doesn't have one clock delay --------------
  dataout<=dataout_tmp when iseight='1';
  fifo_en<='1' when iseight='1' else '0'; ----- enable fifo and output 8 bits data -------
   --------- same result as mux select but has one clock time delay -------------
 --process(clk)
  --begin 
   --if(rising_edge(clk)and ((cpha ='0'and cpol='0')or(cpha ='1'and cpol='1')))then
    --if(iseight='1')then
     --fifo_en<='1';
     --dataout<=dataout_tmp;
    --else
     --fifo_en<='0';
   --end if;
  --end if;
  
  --if(falling_edge(clk) and ((cpha ='0'and cpol='1')or(cpha ='1'and cpol='0')))then
    --if(iseight='1')then
    --fifo_en<='1';
    --dataout<=dataout_tmp;
    --else
    --fifo_en<='0';
   --end if;
  --end if;
 --end process;

end Behavioral;
