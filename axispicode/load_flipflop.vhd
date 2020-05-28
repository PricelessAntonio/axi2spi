----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/21/2020 08:22:51 PM
-- Design Name: 
-- Module Name: load_flipflop - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity load_flipflop is
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
end load_flipflop;

architecture Behavioral of load_flipflop is

begin

  process (load_en_n, clk)
  begin
    if (load_en_n = '0') then
      d_out <= load;
    elsif (rising_edge(clk)) then
      if (sync_rst = '1') then
        d_out <= '0';
      elsif (wr_en = '1' AND stb_in = '1') then
        d_out <= d_in;
      end if;
    end if;
  end process;

end Behavioral;
