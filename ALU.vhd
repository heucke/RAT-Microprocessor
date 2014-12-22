--------------------------------------------------------------------------------
-- Team: Tyler Heucke & Matt Hennes
--
-- Create Date:    14:28:43 10/07/2014
-- Module Name:    ALU - Behavioral
-- Project Name:   RAT MCU
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ALU is
    Port (  ALU_CIN      : in  STD_LOGIC;
            ALU_SEL      : in  STD_LOGIC_VECTOR(3 downto 0);
            MULTI_BUS    : in  STD_LOGIC_VECTOR(7 downto 0);
            REG_DY_OUT   : in  STD_LOGIC_VECTOR(7 downto 0);
            INST_REG_7_0 : in  STD_LOGIC_VECTOR(7 downto 0);
            ALU_OPY_SEL  : in  STD_LOGIC;
            ALU_RESULT   : out STD_LOGIC_VECTOR(7 downto 0);
            ALU_FLG_C    : out STD_LOGIC;
            ALU_FLG_Z    : out STD_LOGIC  );
end ALU;

architecture Behavioral of ALU is

    signal alu_b : STD_LOGIC_VECTOR(7 downto 0);
    signal c_flg : STD_LOGIC := '0';
    signal z_flg : STD_LOGIC := '0';

begin

    multiplexer : process( ALU_OPY_SEL, REG_DY_OUT, INST_REG_7_0 )
    begin
        case( ALU_OPY_SEL ) is
            when '0'    => alu_b <= REG_DY_OUT;
            when '1'    => alu_b <= INST_REG_7_0;
            when others => alu_b <= (others => '0');
        end case ;
    end process ; -- multiplexer

    instructions : process( ALU_SEL, MULTI_BUS, alu_b, ALU_CIN, c_flg, z_flg )
        variable temp_result : STD_LOGIC_VECTOR(8 downto 0);
        -- Extra bit for overflow
    begin

        case( ALU_SEL ) is
            when "0000" =>
                --ADD
                temp_result := ('0' & MULTI_BUS) + ('0' & alu_b);
                c_flg  <= temp_result(8);
            when "0001" =>
                --ADDC
                temp_result := ('0' & MULTI_BUS) + ('0' & alu_b) + ("00000000" & ALU_CIN);
                c_flg  <= temp_result(8);
            when "0010" =>
                --SUB
                temp_result := ('0' & MULTI_BUS) - ('0' & alu_b);
                c_flg  <= temp_result(8);
            when "0011" =>
                --SUBC
                temp_result := ('0' & MULTI_BUS) - ('0' & alu_b) - ("00000000" & ALU_CIN);
                c_flg  <= temp_result(8);
            when "0100" =>
                --CMP
                temp_result := ('0' & MULTI_BUS) - ('0' & alu_b);
                c_flg  <= temp_result(8);
            when "0101" =>
                --AND
                temp_result := ('0' & MULTI_BUS) AND ('0' & alu_b);
            when "0110" =>
                --OR
                temp_result := ('0' & MULTI_BUS) OR ('0' & alu_b);
            when "0111" =>
                --EXOR
                temp_result := ('0' & MULTI_BUS) XOR ('0' & alu_b);
            when "1000" =>
                --TEST
                temp_result := ('0' & MULTI_BUS) AND ('0' & alu_b);
            when "1001" =>
                --LSL
                c_flg  <= MULTI_BUS(7);
                temp_result := '0' & MULTI_BUS(6 downto 0) & ALU_CIN;
            when "1010" =>
                --LSR
                c_flg  <= MULTI_BUS(0);
                temp_result := '0' & ALU_CIN & MULTI_BUS(7 downto 1);
            when "1011" =>
                --ROL
                c_flg  <= MULTI_BUS(7);
                temp_result := '0' & MULTI_BUS(6 downto 0) & MULTI_BUS(7);
            when "1100" =>
                --ROR
                c_flg  <= MULTI_BUS(0);
                temp_result := '0' & MULTI_BUS(0) & MULTI_BUS(7 downto 1);
            when "1101" =>
                --ASR
                c_flg  <= MULTI_BUS(0);
                temp_result := '0' & MULTI_BUS(7) & MULTI_BUS(7 downto 1);
            when "1110" =>
                --MOV
                temp_result := '0' & alu_b;
            when others => temp_result := (others => '1');
        end case ;

        if (temp_result(7 downto 0) = x"00") then -- Set Z flag if x00
            if (ALU_SEL /= "1110") then -- Don't set Z flag if MOV command
                z_flg <= '1';
            end if;
        else
            z_flg <= '0';
        end if;

        ALU_RESULT <= temp_result(7 downto 0);
        ALU_FLG_C <= c_flg;
        ALU_FLG_Z <= z_flg;

    end process ; -- instructions

end Behavioral;
