--------------------------------------------------------------------------------
-- Team: Tyler Heucke & Matt Hennes
--
-- Create Date:    10/30/2014
-- Module Name:    Flags - Behavioral
-- Project Name:   RAT MCU
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Flags is
  port (
    FLG_C_SET   : in STD_LOGIC;
    FLG_C_CLR   : in STD_LOGIC;
    FLG_C_LD    : in STD_LOGIC;
    FLG_Z_LD    : in STD_LOGIC;
    FLG_Z_CLR   : in STD_LOGIC;
    FLG_LD_SEL  : in STD_LOGIC;
    FLG_SHAD_LD : in STD_LOGIC;
    IN_C_FLAG   : in STD_LOGIC;
    IN_Z_FLAG   : in STD_LOGIC;
    CLK         : in STD_LOGIC;
    OUT_C_FLAG  : out STD_LOGIC;
    OUT_Z_FLAG  : out STD_LOGIC
  ) ;
end entity ; -- Flags

architecture Behavioral of Flags is

    component FlagRegister
        Port (  FLG_IN  : in  STD_LOGIC; --flag input
                FLG_LD  : in  STD_LOGIC; --load Q with the D value
                FLG_SET : in  STD_LOGIC; --set the flag to '1'
                FLG_CLR : in  STD_LOGIC; --clear the flag to '0'
                CLK     : in  STD_LOGIC; --system clock
                FLG_OUT : out  STD_LOGIC); --flag output
    end component;

    -- Intermediate signals -----------
    signal z_mux_data : STD_LOGIC;
    signal c_mux_data : STD_LOGIC;
    signal shad_z_out : STD_LOGIC;
    signal shad_c_out : STD_LOGIC;

    signal z_flag_out : STD_LOGIC;
    signal c_flag_out : STD_LOGIC;

begin

    z_mux : process( FLG_LD_SEL, IN_Z_FLAG, shad_z_out )
    begin
        case( FLG_LD_SEL ) is
            when '0' => z_mux_data <= IN_Z_FLAG;
            when '1' => z_mux_data <= shad_z_out;

            when others => z_mux_data <= '0';

        end case ;
    end process ; -- z_mux

    z_flg: FlagRegister
    port map (  FLG_IN => z_mux_data,
                FLG_LD => FLG_Z_LD,
                FLG_SET => '0',
                FLG_CLR => FLG_Z_CLR,
                CLK => CLK,
                FLG_OUT => z_flag_out);

    shad_z: FlagRegister
    port map (  FLG_IN => z_flag_out,
                FLG_LD => FLG_SHAD_LD,
                FLG_SET => '0',
                FLG_CLR => '0',
                CLK => CLK,
                FLG_OUT => shad_z_out);

    c_mux : process( FLG_LD_SEL, IN_C_FLAG, shad_c_out )
    begin
        case( FLG_LD_SEL ) is
            when '0' => c_mux_data <= IN_C_FLAG;
            when '1' => c_mux_data <= shad_c_out;

            when others => c_mux_data <= '0';

        end case ;
    end process ; -- c_mux

    c_flg: FlagRegister
    port map (  FLG_IN => c_mux_data,
                FLG_LD => FLG_C_LD,
                FLG_SET => FLG_C_SET,
                FLG_CLR => FLG_C_CLR,
                CLK => CLK,
                FLG_OUT => c_flag_out);

    shad_c: FlagRegister
    port map (  FLG_IN => c_flag_out,
                FLG_LD => FLG_SHAD_LD,
                FLG_SET => '0',
                FLG_CLR => '0',
                CLK => CLK,
                FLG_OUT => shad_c_out);

    OUT_C_FLAG <= c_flag_out;
    OUT_Z_FLAG <= z_flag_out;

end architecture ; -- Behavioral
