--------------------------------------------------------------------------------
-- Company: RAT Technologies
-- Engineer: James Ratner
--
-- Create Date:    13:55:34 04/06/2014
-- Module Name:    Mux - Behavioral
-- Description: Full featured D Flip-flop intended for use as flag registers.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FlagRegister is
    Port ( FLG_IN   : in  STD_LOGIC; --flag input
           FLG_LD  : in  STD_LOGIC; --load Q with the D value
           FLG_SET : in  STD_LOGIC; --set the flag to '1'
           FLG_CLR : in  STD_LOGIC; --clear the flag to '0'
           CLK : in  STD_LOGIC; --system clock
           FLG_OUT   : out  STD_LOGIC); --flag output
end FlagRegister;

architecture Behavioral of FlagRegister is
   signal s_D : STD_LOGIC := '0';
begin
    process(CLK)
    begin
        if( rising_edge(CLK) ) then
            if( FLG_LD = '1' ) then
                s_D <= FLG_IN;
            elsif( FLG_SET = '1' ) then
                s_D <= '1';
            elsif( FLG_CLR = '1' ) then
                s_D <= '0';
         end if;
      end if;
    end process;

    FLG_OUT <= s_D;

end Behavioral;

