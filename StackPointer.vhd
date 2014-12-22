--------------------------------------------------------------------------------
-- Team: Tyler Heucke & Matt Hennes
--
-- Create Date:    14:07:52 10/14/2014
-- Module Name:    StackPointer - Behavioral
-- Project Name:   RAT MCU
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity StackPointer is
    Port (  SP_LD            : in STD_LOGIC;
            RST              : in STD_LOGIC;
            SP_MUX_SEL       : in STD_LOGIC_VECTOR (1 downto 0);
            MULTI_BUS        : in STD_LOGIC_VECTOR (7 downto 0);
            SP_OUT_DECREMENT : in STD_LOGIC_VECTOR (7 downto 0);
            SP_OUT_INCREMENT : in STD_LOGIC_VECTOR (7 downto 0);
            CLK              : in STD_LOGIC;
            SP_OUT           : out STD_LOGIC_VECTOR (7 downto 0));
end StackPointer;

architecture Behavioral of StackPointer is
  signal pointer_in  : STD_LOGIC_VECTOR(7 downto 0);
  signal pointer_out : STD_LOGIC_VECTOR(7 downto 0);
begin

    multiplexer : process( SP_MUX_SEL, MULTI_BUS, SP_OUT_DECREMENT, SP_OUT_INCREMENT )
    begin
        case( SP_MUX_SEL ) is
            when "00" => pointer_in <= MULTI_BUS;
            when "10" => pointer_in <= SP_OUT_DECREMENT;
            when "11" => pointer_in <= SP_OUT_INCREMENT;
            when others => pointer_in <= "00000000";
        end case ;
    end process ; -- multiplexer

    instructions : process( pointer_in, SP_LD, RST, CLK, pointer_out )
    begin

        if (RST = '0') then
          if (SP_LD = '1') then
            if (rising_edge(CLK)) then
                SP_OUT <= pointer_in;
            end if;
          end if;
        else
          SP_OUT <= "00000000";
        end if ;

    end process; -- instructions

end Behavioral;

