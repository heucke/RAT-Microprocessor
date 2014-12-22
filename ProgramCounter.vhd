--------------------------------------------------------------------------------
-- Team: Tyler Heucke & Matt Hennes
--
-- Create Date:    14:20:48 09/30/2014
-- Module Name:    ProgramCounter - Behavioral
-- Project Name:   RAT MCU
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ProgramCounter is
    Port ( PC_LD         : in  STD_LOGIC;
           PC_INC        : in  STD_LOGIC;
           PC_OE         : in  STD_LOGIC;
           RST           : in  STD_LOGIC;
           INST_REG_12_3 : in  STD_LOGIC_VECTOR(9 downto 0);
           MULTI_BUS     : in  STD_LOGIC_VECTOR(9 downto 0);
           PC_MUX_SEL    : in  STD_LOGIC_VECTOR(1 downto 0);
           CLK           : in  STD_LOGIC;
           PC_COUNT      : out STD_LOGIC_VECTOR(9 downto 0);
           PC_TRI        : out STD_LOGIC_VECTOR(9 downto 0) );
end ProgramCounter;

architecture Behavioral of ProgramCounter is
    signal pc_mux_out : STD_LOGIC_VECTOR(9 downto 0);
    signal pc_data    : STD_LOGIC_VECTOR(9 downto 0) := "0000000001";
begin

    multiplexer : process( PC_MUX_SEL, INST_REG_12_3, MULTI_BUS, pc_mux_out )
    begin
        case PC_MUX_SEL is
          when "00"   => pc_mux_out <= INST_REG_12_3;
          -- Set input to immediate input
          when "01"   => pc_mux_out <= MULTI_BUS;
          -- Set input to stack input
          when others => pc_mux_out <= (others => '1');
          -- Otherwise input an interrupt
        end case;
    end process ; -- multiplexer

    instructions : process( PC_LD, PC_INC, PC_OE, RST, INST_REG_12_3, CLK, pc_mux_out, pc_data )
    begin
        if (RST = '1') then                 --Reset if reset signal received
              pc_data <= "0000000001";
        else

          if (rising_edge(CLK)) then  --Synchronous functionality here
            if (PC_LD = '1') then          --Load data if load signal is present
              pc_data <= pc_mux_out;
            elsif (PC_INC = '1') then      --Increment if incrememt signal is present
              pc_data <= pc_data + '1';
            end if;

          end if;

        end if;

        if (PC_OE = '0') then --Output Z for tri-state output if PC_OE signal is low
          PC_TRI <= "ZZZZZZZZZZ";
        else -- Otherwise, sync tri-state output to PC_COUNT
          PC_TRI <= pc_data;
        end if;

        PC_COUNT <= pc_data; -- Set PC_COUNT to the internal signal pc_mux_out
    end process ; -- instructions

end Behavioral;

