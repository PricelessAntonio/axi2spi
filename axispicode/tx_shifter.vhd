

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity tx_shifter is
   generic (C_NUM_TRANSFER_BITS: INTEGER := 8);
    Port ( clk : in STD_LOGIC;
           enable : in STD_LOGIC;
           reset:   in std_logic;
           rx_enable:out std_logic;
           data_rady:out std_logic;
           lsb    : in std_logic;
           cpha   : in STD_LOGIC;
           cpol   : in STD_LOGIC;
           datain : in STD_LOGIC_VECTOR (31 downto 0);
        --   data_re: out std_logic; --------data requeset signal to fifo --------------
          -- data_re1:out std_logic; 
           fifo_rd_en:out std_logic;
           dataout : out STD_LOGIC);
end tx_shifter;

architecture Behavioral of tx_shifter is

signal temp_reg: std_logic_vector(C_NUM_TRANSFER_BITS-1 downto 0);
signal LSB_counter : integer range 0 to C_NUM_TRANSFER_BITS-1;
signal MSB_counter : integer range C_NUM_TRANSFER_BITS-1 downto 0;--integer:= C_NUM_TRANSFER_BITS-1;
signal LSB_counter_enable:std_logic;
signal MSB_counter_enable:std_logic;
signal temp_enable:std_logic;
signal ss:std_logic;
signal counter_en_dl:std_logic;
signal data_re:std_logic;
signal data_re1:std_logic;
type state_type is (S0, S1,S2);
signal state, next_state : state_type; 

begin


   SYNC_PROC : process (clk,reset)
                begin 
                 if(reset='0')then
                 state<=s0;
                 elsif (rising_edge(clk)and ((cpha ='0'and cpol='0')or(cpha ='1'and cpol='1')) )then
                   state<=next_state;
                   end if;
                 if(reset='0')then
                 state<=s0;
                 elsif(falling_edge(clk) and ((cpha ='0'and cpol='1')or(cpha ='1'and cpol='0')))then
                 state<=next_state;
                 end if;
                end process;
                
   OUTPUT_DECODE : process (state) 
                    begin
                    case (state) is
                       when s0 =>
                       temp_enable<='0';
                      
                       when s1=>
                       temp_enable<='1';
                       data_re<='1';
                       
                       when s2=>
                       temp_enable<='1';
                       data_re<='0';
                       
                        when others=>
                        temp_enable<='0';
                        end case;
                      end process;
                      
   NEXT_STATE_DECODE : process (state, enable,reset)      
                        begin              
                         case state is
                         when s0 =>
                         if(reset='0')then
                         next_state<=s0;
                         elsif(enable='1')then
                         next_state<=s1;
                         end if;
                         
                         when s1=>
                         if(reset='0')then
                         next_state<=s0;
                         else
                         next_state<=s2;
                         end if;
                         
                         when s2 =>
                         if(reset='0')then
                         next_state<=s0;
                         elsif(enable='0')then
                         next_state<=s0;
                         end if;
                        end case;
                       end process;
                                
 process(clk,cpha,reset)
    begin
     if(reset='0')then
     counter_en_dl<='0';
     else
     if(rising_edge(clk)and ((cpha ='0'and cpol='0')or(cpha ='1'and cpol='1'))) then
        if(temp_enable='1')then
         if(C_NUM_TRANSFER_BITS=8)then
         temp_reg <= datain(7 downto 0);
         elsif(C_NUM_TRANSFER_BITS=16)then
          temp_reg <= datain(15 downto 0);
           elsif(C_NUM_TRANSFER_BITS=32)then
           temp_reg <= datain;
         end if;
         counter_en_dl<='1';
        else
         counter_en_dl<='0';
        end if;
       end if;
       
      if(falling_edge(clk) and ((cpha ='0'and cpol='1')or(cpha ='1'and cpol='0'))) then
       if(temp_enable='1')then
        if(C_NUM_TRANSFER_BITS=8)then
         temp_reg <= datain(7 downto 0);
         elsif(C_NUM_TRANSFER_BITS=16)then
         temp_reg <= datain(15 downto 0);
         elsif(C_NUM_TRANSFER_BITS=32)then
          temp_reg <= datain;
         end if;
        counter_en_dl<='1';
       else
        counter_en_dl<='0';
       end if;
      end if;
       
      end if;
   end process;     
      
   
               
     dataout <= temp_reg(lsb_counter) when lsb='1' else
                temp_reg(MSB_COUNTER) when lsb='0';
     rx_enable<= enable and counter_en_dl;
     data_rady<=enable and (LSB_counter_enable OR MSB_counter_enable);
     
process(clk,cpha,reset)
   begin 
    if(reset='0')then
     lsb_counter_enable<='0';
     Msb_counter_enable<='0';
    elsif(rising_edge(clk)and ((cpha ='0'and cpol='0')or(cpha ='1'and cpol='1')))then
     if(counter_en_dl ='1' and lsb='1')then
      lsb_counter_enable<='1';
     elsif(counter_en_dl ='1' and lsb='0')then
      Msb_counter_enable<='1';
      else
       lsb_counter_enable<='0';
       Msb_counter_enable<='0';
     end if;
    end if;
    
    if(reset='0')then
     lsb_counter_enable<='0';
     Msb_counter_enable<='0';
    elsif(falling_edge(clk)and ((cpha ='0'and cpol='1')or(cpha ='1'and cpol='0')))then
     if(counter_en_dl ='1' and lsb='1')then
      lsb_counter_enable<='1';
     elsif(counter_en_dl ='1' and lsb='0')then
      Msb_counter_enable<='1';
      else
       lsb_counter_enable<='0';
       Msb_counter_enable<='0';
     end if;
    end if;
   end process;
   
process(clk,reset)
  begin
  ---if(rising_edge(clk) and counter_enable='1') then
  if(reset='0')then
  lsb_counter<=0;
  msb_counter<=C_NUM_TRANSFER_BITS-1;
  elsif(rising_edge(clk)and ((cpha ='0'and cpol='0')or(cpha ='1'and cpol='1'))) then
   if(lsb_counter_enable='1')then
    if(lsb_counter =C_NUM_TRANSFER_BITS-1) then
     lsb_counter<=0;
    else
    lsb_counter<=lsb_counter+1;
      end if;
    end if;
   
    if(msb_counter_enable='1')then
      if(msb_counter=0)then
       msb_counter<=C_NUM_TRANSFER_BITS-1;
      else
       msb_counter<=msb_counter-1;
      end if;
     end if;
     
 end if;
    
    if(reset='0')then
     lsb_counter<=0;
     msb_counter<=C_NUM_TRANSFER_BITS-1;
    elsif(falling_edge(clk) and ((cpha ='0'and cpol='1')or(cpha ='1'and cpol='0'))) then
      if(lsb_counter_enable='1')then
       if(lsb_counter =C_NUM_TRANSFER_BITS-1) then
         lsb_counter<=0;
       else
       lsb_counter<=lsb_counter+1;
      end if;
    end if;

    if(msb_counter_enable='1')then
      if(msb_counter=0)then
       msb_counter<=C_NUM_TRANSFER_BITS-1;
      else
       msb_counter<=msb_counter-1;
      end if;
     end if;
    end if;
   end process;
    
 data_re1 <='1' when lsb_counter =C_NUM_TRANSFER_BITS-2 and lsb='1' else
            '1' when msb_counter=1 and lsb='0' else
            '0';    
 fifo_rd_en <= data_re or data_re1;
end Behavioral;
