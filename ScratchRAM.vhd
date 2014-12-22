--------------------------------------------------------------------------------
-- Team: Tyler Heucke & Matt Hennes
--
-- Create Date:    14:07:52 10/14/2014
-- Module Name:    ScratchRAM - Behavioral
-- Project Name:   RAT MCU
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ScratchRAM is
    Port ( REG_DY_OUT       : in  STD_LOGIC_VECTOR (7 downto 0);
           INST_REG_7_0     : in  STD_LOGIC_VECTOR (7 downto 0);
           SP_OUT           : in  STD_LOGIC_VECTOR (7 downto 0);
           SP_OUT_DECREMENT : in  STD_LOGIC_VECTOR (7 downto 0);
           SCR_ADDR_SEL     : in STD_LOGIC_VECTOR (1 downto 0);
           SCR_OE           : in  STD_LOGIC;
           SCR_WR           : in  STD_LOGIC;
           CLK              : in  STD_LOGIC;
           MULTI_BUS        : inout  STD_LOGIC_VECTOR (9 downto 0));
end ScratchRAM;

architecture Behavioral of ScratchRAM is
	TYPE memory is array (0 to 255) of std_logic_vector (9 downto 0);
	signal BD_RAM : memory := (others => (others => '0'));
  signal scr_addr : STD_LOGIC_VECTOR(7 downto 0);
begin

    multiplexer : process( SCR_ADDR_SEL, REG_DY_OUT, INST_REG_7_0, SP_OUT, SP_OUT_DECREMENT )
    begin
        case( SCR_ADDR_SEL ) is
            when "00" => scr_addr <= REG_DY_OUT;
            when "01" => scr_addr <= INST_REG_7_0;
            when "10" => scr_addr <= SP_OUT;
            when "11" => scr_addr <= SP_OUT_DECREMENT;
            when others => scr_addr <= "00000000";
        end case ;
    end process ; -- multiplexer

	instructions : process( scr_addr, SCR_OE, SCR_WR, CLK, MULTI_BUS, BD_RAM )
	begin

		if (SCR_WR = '1') then
			if (rising_edge(CLK)) then
				BD_RAM(conv_integer(scr_addr)) <= MULTI_BUS;
			end if;
    else
      if (SCR_OE = '1') then
        MULTI_BUS <= BD_RAM(conv_integer(scr_addr));
      else
        MULTI_BUS <= (others => 'Z');
      end if;
		end if;

	end process; -- instructions

end Behavioral;

