library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- REGISTER MODULE 
-- (05/11) got rid of rst input - rst will be checked in registers file to set defaults to
-- every register and only in the case where rst is NOT enabled will we use load_register

entity load_register is
    port (
        -- SYSTEM INTERFACE
        clk       :   in std_logic;
        wr_en     :   in std_logic; -- enables data to be written to register
        load_en_n :   in std_logic; -- enables value in load to be written to register asynchronously
        load      :   in std_logic_vector(31 downto 0);
        stb_in    :   in std_logic_vector(3 downto 0);
        -- DATA
        d_in      :   in std_logic_vector(31 downto 0);
        d_out     :   out std_logic_vector(31 downto 0) 
    );
end load_register;

architecture Behavioral of load_register is

begin

    process (clk, load_en_n)
    begin
    
        if load_en_n = '0' then
            d_out   <= load;
        elsif rising_edge(clk) then
            if wr_en = '1' then
                if (stb_in(0) = '1') then
                    d_out(7 DOWNTO 0) <= d_in(7 DOWNTO 0);
          
                end if;
                if (stb_in(1) = '1') then
                    d_out(15 DOWNTO 8) <= d_in(15 DOWNTO 8);
          
                end if;
                if (stb_in(2) = '1') then
                    d_out(23 DOWNTO 16) <= d_in(23 DOWNTO 16);
          
                end if;
                if (stb_in(3) = '1') then
                    d_out(31 DOWNTO 24) <= d_in(31 DOWNTO 24);
                  
                end if;
            end if;
        end if;
    end process;

end Behavioral;
