library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity AsyncFifo_32x1_or_16 is
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
end AsyncFifo_32x1_or_16;

architecture Behavioral of AsyncFifo_32x1_or_16 is

  -- Memory
  TYPE ram_t IS ARRAY(0 TO (1+(14*C_FIFO_EXIST))) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL ram : ram_t;
  
  SIGNAL r_ptr : STD_LOGIC_VECTOR((1+(3*C_FIFO_EXIST)) DOWNTO 0);
  SIGNAL r_ptr_temp : STD_LOGIC_VECTOR((1+(3*C_FIFO_EXIST)) DOWNTO 0);
  SIGNAL synched_r_ptr : STD_LOGIC_VECTOR((1+(3*C_FIFO_EXIST)) DOWNTO 0);
  SIGNAL w_ptr : STD_LOGIC_VECTOR((1+(3*C_FIFO_EXIST)) DOWNTO 0);
  SIGNAL w_ptr_temp : STD_LOGIC_VECTOR((1+(3*C_FIFO_EXIST)) DOWNTO 0);
  SIGNAL synched_w_ptr : STD_LOGIC_VECTOR((1+(3*C_FIFO_EXIST)) DOWNTO 0);
  SIGNAL fifo_empty : STD_LOGIC;
  SIGNAL fifo_full : STD_LOGIC;
  SIGNAL r_addr : STD_LOGIC_VECTOR((3*C_FIFO_EXIST) DOWNTO 0);
  SIGNAL w_addr : STD_LOGIC_VECTOR((3*C_FIFO_EXIST) DOWNTO 0);
  SIGNAL w_logic_en : STD_LOGIC;

begin

  -- FIFO Read Logic
  read_ptr_logic : process (r_clk, rst_n)
  begin
    if (rst_n = '0') then
      r_ptr <= (OTHERS => '0');
    elsif (rising_edge(r_clk)) then
      if ((r_en='1') AND (fifo_empty='0')) then
        r_ptr <= r_ptr + '1';
        if (C_FIFO_EXIST = 0) then
          r_ptr <= r_ptr + '1';
        end if;
      end if;
    end if;
  end process read_ptr_logic;
  
  empty_flag_logic : process (synched_w_ptr, r_ptr)
  begin
    if (synched_w_ptr = r_ptr) then
      fifo_empty <= '1';
    elsif (synched_w_ptr((3*C_FIFO_EXIST) DOWNTO 0) = r_ptr((3*C_FIFO_EXIST) DOWNTO 0)) then
      fifo_empty <= '0';
    else
      fifo_empty <= '0';
    end if;
  end process empty_flag_logic;
  
  r_addr <= r_ptr((3*C_FIFO_EXIST) DOWNTO 0);
  empty <= fifo_empty;
  
  -- FIFO Write Logic
  write_ptr_logic : process (w_clk, rst_n)
  begin
    if (rst_n = '0') then
      w_ptr <= (OTHERS => '0');
    elsif (rising_edge(w_clk)) then
      if ((w_en='1') AND (fifo_full='0')) then
        w_ptr <= w_ptr + '1';
        if (C_FIFO_EXIST = 0) then
          w_ptr <= w_ptr + '1';
        end if;
      end if;
    end if;
  end process write_ptr_logic;
  
  full_flag_logic : process (synched_r_ptr, w_ptr)
  begin
    if (synched_r_ptr = w_ptr) then
      fifo_full <= '0';
    elsif (synched_r_ptr((3*C_FIFO_EXIST) DOWNTO 0) = w_ptr((3*C_FIFO_EXIST) DOWNTO 0)) then
      fifo_full <= '1';
    else
      fifo_full <= '0';
    end if;
  end process full_flag_logic;
  
  w_addr <= w_ptr((3*C_FIFO_EXIST) DOWNTO 0);
  
  full <= fifo_full;
  
  -- Memory Logic
  fifo_ram : process (w_clk)
  begin
    if (rising_edge(w_clk)) then
      if (w_logic_en = '1') then
        ram(to_integer(unsigned(w_addr))) <= w_data;
      end if;
    end if;
  end process fifo_ram;
  
  r_data <= ram(to_integer(unsigned(r_addr)));
  
  w_logic_en <= (NOT fifo_full) and (w_en);
  
  -- Write to Read Synchronizer
  w_ptr_sync0 : process (r_clk, rst_n)
  begin
    if (rst_n = '0') then
      w_ptr_temp <= (OTHERS => '0');
    elsif (rising_edge(r_clk)) then
      w_ptr_temp <= w_ptr;
    end if;
  end process w_ptr_sync0;
  
  w_ptr_sync1 : process (r_clk, rst_n)
  begin
    if (rst_n = '0') then
      synched_w_ptr <= (OTHERS => '0');
    elsif (rising_edge(r_clk)) then
      synched_w_ptr <= w_ptr_temp;
    end if;
  end process w_ptr_sync1;
  
  -- Read to Write Synchronizer
  r_ptr_sync0 : process (w_clk, rst_n)
  begin
    if (rst_n = '0') then
      r_ptr_temp <= (OTHERS => '0');
    elsif (rising_edge(w_clk)) then
      r_ptr_temp <= r_ptr;
    end if;
  end process r_ptr_sync0;
  
  r_ptr_sync1 : process (w_clk, rst_n)
  begin
    if (rst_n = '0') then
      synched_r_ptr <= (OTHERS => '0');
    elsif (rising_edge(w_clk)) then
      synched_r_ptr <= r_ptr_temp;
    end if;
  end process r_ptr_sync1;
  
  -- Queue Logic
  queue <= synched_w_ptr - r_ptr;

end Behavioral;