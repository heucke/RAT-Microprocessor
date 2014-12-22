--------------------------------------------------------------------------------
-- Team: Tyler Heucke & Matt Hennes
--
-- Create Date:    14:06:55 10/14/2014
-- Module Name:    ALU - Behavioral
-- Project Name:   RAT MCU
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RegisterFile is
    Port (  IN_PORT    : in    STD_LOGIC_VECTOR(7 downto 0);
            MULTI_BUS  : inout STD_LOGIC_VECTOR(7 downto 0);
            ALU_RESULT : in    STD_LOGIC_VECTOR(7 downto 0);
            RF_WR_SEL  : in    STD_LOGIC_VECTOR(1 downto 0);
            RF_WR      : in    STD_LOGIC;
            RF_OE      : in    STD_LOGIC;
            ADRX       : in    STD_LOGIC_VECTOR(4 downto 0);
            ADRY       : in    STD_LOGIC_VECTOR(4 downto 0);
            CLK        : in    STD_LOGIC;
            REG_DY_OUT : out   STD_LOGIC_VECTOR(7 downto 0) );
end RegisterFile;

architecture Behavioral of RegisterFile is
	type    memory is array (0 to 31) of STD_LOGIC_VECTOR(7 downto 0);
	signal  dp_ram     : memory := (others => (others => '0'));
    signal  rf_mux_out : STD_LOGIC_VECTOR(7 downto 0);
begin

    multiplexer : process( RF_WR_SEL, IN_PORT, MULTI_BUS, ALU_RESULT )
    begin
        case RF_WR_SEL is
            when "00" =>
                -- Set output to alu result
                rf_mux_out <= ALU_RESULT;
            when "01" =>
                -- Set output to stack input
                rf_mux_out <= MULTI_BUS;
            when "11" =>
                -- Set output to immediate input
                rf_mux_out <= IN_PORT;
            when others => rf_mux_out <= "11111111"; --Otherwise output an interrupt
        end case;
    end process ; -- multiplexer

    instructions : process( rf_mux_out, ADRX, ADRY, RF_OE, RF_WR, CLK, dp_ram )
    begin
        if (RF_WR = '1') then
            if (rising_edge(CLK)) then
                dp_ram(conv_integer(ADRX)) <= rf_mux_out;
            end if;
        end if;

        if (RF_OE = '1') then
            MULTI_BUS <= dp_ram(conv_integer(ADRX));
        else
            MULTI_BUS <= (others => 'Z');
        end if;

        REG_DY_OUT <= dp_ram(conv_integer(ADRY));
    end process ; -- instructions

end Behavioral;

