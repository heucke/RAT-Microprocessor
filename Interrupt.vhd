--------------------------------------------------------------------------------
-- Team: Tyler Heucke & Matt Hennes
--
-- Create Date:    11/13/2014
-- Module Name:    Interrupt - Behavioral
-- Project Name:   RAT MCU
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Interrupt is
    Port (  I_SET   : in  STD_LOGIC  ;
            I_CLR   : in  STD_LOGIC  ;
            CLK     : in  STD_LOGIC  ;
            INT_OUT : out STD_LOGIC );
end Interrupt;

architecture Behavioral of Interrupt is

begin

    instructions : process( I_SET, I_CLR, CLK )
    begin

        if rising_edge(CLK) then
            if I_SET = '1' then
                INT_OUT <= '1';
            elsif I_CLR = '1' then
                INT_OUT <= '0';
            end if ;
        end if ;

    end process ; -- instructions

end Behavioral;
