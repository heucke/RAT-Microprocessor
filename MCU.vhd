--------------------------------------------------------------------------------
-- Team: Tyler Heucke & Matt Hennes
--
-- Create Date:    20:59:29 02/04/2013
-- Module Name:    MCU - Behavioral
-- Project Name:   RAT MCU
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RAT_MCU is
    Port ( IN_PORT : in  STD_LOGIC_VECTOR (7 downto 0);
           RESET : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           INT    : in  STD_LOGIC;
           OUT_PORT : out  STD_LOGIC_VECTOR (7 downto 0);
           PORT_ID : out  STD_LOGIC_VECTOR (7 downto 0);
           IO_STRB : out  STD_LOGIC);
end RAT_MCU;

architecture Behavioral of RAT_MCU is

    component prog_rom
      port (     ADDRESS : in std_logic_vector(9 downto 0);
             INSTRUCTION : out std_logic_vector(17 downto 0);
                     CLK : in std_logic);
    end component;

    component ALU
       Port ( ALU_CIN      : in  STD_LOGIC;
              ALU_SEL      : in  STD_LOGIC_VECTOR(3 downto 0);
              MULTI_BUS    : in  STD_LOGIC_VECTOR(7 downto 0);
              REG_DY_OUT   : in  STD_LOGIC_VECTOR(7 downto 0);
              INST_REG_7_0 : in  STD_LOGIC_VECTOR(7 downto 0);
              ALU_OPY_SEL  : in  STD_LOGIC;
              ALU_RESULT   : out STD_LOGIC_VECTOR(7 downto 0);
              ALU_FLG_C   : out STD_LOGIC;
              ALU_FLG_Z    : out STD_LOGIC );
    end component;

    component Interrupt
        Port ( I_SET : in STD_LOGIC;
               I_CLR : in STD_LOGIC;
               CLK   : in STD_LOGIC;
               INT_OUT : out STD_LOGIC );
    end component;

    component ControlUnit
       Port ( CLK          : in   STD_LOGIC;
              C_FLAG       : in   STD_LOGIC;
              Z_FLAG       : in   STD_LOGIC;
              INT          : in   STD_LOGIC;
              RESET        : in   STD_LOGIC;
              OPCODE_HI_5  : in   STD_LOGIC_VECTOR (4 downto 0);
              OPCODE_LO_2  : in   STD_LOGIC_VECTOR (1 downto 0);

              PC_LD        : out  STD_LOGIC;
              PC_INC       : out  STD_LOGIC;
              PC_MUX_SEL   : out  STD_LOGIC_VECTOR (1 downto 0);
              PC_OE        : out  STD_LOGIC;

              SP_LD        : out  STD_LOGIC;
              SP_MUX_SEL   : out  STD_LOGIC_VECTOR (1 downto 0);

              RF_WR        : out  STD_LOGIC;
              RF_WR_SEL    : out  STD_LOGIC_VECTOR (1 downto 0);
              RF_OE        : out  STD_LOGIC;

              ALU_OPY_SEL  : out  STD_LOGIC;
              ALU_SEL      : out  STD_LOGIC_VECTOR (3 downto 0);

              SCR_WR       : out  STD_LOGIC;
              SCR_ADDR_SEL : out  STD_LOGIC_VECTOR (1 downto 0);
              SCR_OE       : out  STD_LOGIC;

              FLG_C_LD     : out  STD_LOGIC;
              FLG_C_SET    : out  STD_LOGIC;
              FLG_C_CLR    : out  STD_LOGIC;
              FLG_SHAD_LD  : out  STD_LOGIC;
              FLG_LD_SEL   : out  STD_LOGIC;
              FLG_Z_LD     : out  STD_LOGIC;
              FLG_Z_CLR    : out  STD_LOGIC;

              I_SET        : out  STD_LOGIC;
              I_CLR        : out  STD_LOGIC;

              RST          : out  STD_LOGIC;
              IO_STRB      : out  STD_LOGIC);
    end component;

    component RegisterFile
       Port ( IN_PORT    : in    STD_LOGIC_VECTOR(7 downto 0);
              MULTI_BUS  : inout STD_LOGIC_VECTOR(7 downto 0);
              ALU_RESULT : in    STD_LOGIC_VECTOR(7 downto 0);
              RF_WR_SEL  : in    STD_LOGIC_VECTOR(1 downto 0);
              RF_WR      : in    STD_LOGIC;
              RF_OE      : in    STD_LOGIC;
              ADRX       : in    STD_LOGIC_VECTOR(4 downto 0);
              ADRY       : in    STD_LOGIC_VECTOR(4 downto 0);
              CLK        : in    STD_LOGIC;
              REG_DY_OUT : out   STD_LOGIC_VECTOR(7 downto 0) );
    end component;

    component ProgramCounter
      port ( PC_LD         : in  STD_LOGIC;
             PC_INC        : in  STD_LOGIC;
             PC_OE         : in  STD_LOGIC;
             RST           : in  STD_LOGIC;
             INST_REG_12_3 : in  STD_LOGIC_VECTOR(9 downto 0);
             MULTI_BUS     : in  STD_LOGIC_VECTOR(9 downto 0);
             PC_MUX_SEL    : in  STD_LOGIC_VECTOR(1 downto 0);
             CLK           : in  STD_LOGIC;
             PC_COUNT      : out STD_LOGIC_VECTOR(9 downto 0);
             PC_TRI        : out STD_LOGIC_VECTOR(9 downto 0) );
    end component;

    component Flags
      port ( FLG_C_SET   : in  STD_LOGIC;
             FLG_C_CLR   : in  STD_LOGIC;
             FLG_C_LD    : in  STD_LOGIC;
             FLG_Z_LD    : in  STD_LOGIC;
             FLG_Z_CLR   : in  STD_LOGIC;
             FLG_LD_SEL  : in  STD_LOGIC;
             FLG_SHAD_LD : in  STD_LOGIC;
             IN_C_FLAG   : in  STD_LOGIC;
             IN_Z_FLAG   : in  STD_LOGIC;
             CLK         : in  STD_LOGIC;
             OUT_C_FLAG  : out STD_LOGIC;
             OUT_Z_FLAG  : out STD_LOGIC );
    end component;

    component StackPointer
      Port (  SP_LD            : in STD_LOGIC;
              RST              : in STD_LOGIC;
              SP_MUX_SEL       : in STD_LOGIC_VECTOR (1 downto 0);
              MULTI_BUS        : in STD_LOGIC_VECTOR (7 downto 0);
              SP_OUT_DECREMENT : in STD_LOGIC_VECTOR (7 downto 0);
              SP_OUT_INCREMENT : in STD_LOGIC_VECTOR (7 downto 0);
              CLK              : in STD_LOGIC;
              SP_OUT           : out STD_LOGIC_VECTOR (7 downto 0));
    end component;

    component ScratchRAM
      Port ( REG_DY_OUT       : in  STD_LOGIC_VECTOR (7 downto 0);
             INST_REG_7_0     : in  STD_LOGIC_VECTOR (7 downto 0);
             SP_OUT           : in  STD_LOGIC_VECTOR (7 downto 0);
             SP_OUT_DECREMENT : in  STD_LOGIC_VECTOR (7 downto 0);
             SCR_ADDR_SEL     : in STD_LOGIC_VECTOR (1 downto 0);
             SCR_OE           : in  STD_LOGIC;
             SCR_WR           : in  STD_LOGIC;
             CLK              : in  STD_LOGIC;
             MULTI_BUS        : inout  STD_LOGIC_VECTOR (9 downto 0));
    end component;

    -- intermediate signals ----------------------------------------------------
    signal c_flag       : STD_LOGIC;
    signal z_flag       : STD_LOGIC;
    signal instruction  : STD_LOGIC_VECTOR(17 downto 0);

    signal i_set        : STD_LOGIC;
    signal i_clr        : STD_LOGIC;

    signal int_out      : STD_LOGIC;
    signal interrupt_signal: STD_LOGIC;

    signal pc_ld        : STD_LOGIC;
    signal pc_inc       : STD_LOGIC;
    signal pc_mux_sel   : STD_LOGIC_VECTOR(1 downto 0);
    signal pc_oe        : STD_LOGIC;

    signal sp_ld        : STD_LOGIC;
    signal sp_mux_sel   : STD_LOGIC_VECTOR(1 downto 0);

    signal rf_wr        : STD_LOGIC;
    signal rf_wr_sel    : STD_LOGIC_VECTOR(1 downto 0);
    signal rf_oe        : STD_LOGIC;

    signal alu_opy_sel  : STD_LOGIC;
    signal alu_sel      : STD_LOGIC_VECTOR(3 downto 0);
    signal alu_flg_c    : STD_LOGIC;
    signal alu_flg_z    : STD_LOGIC;

    signal scr_wr       : STD_LOGIC;
    signal scr_addr_sel : STD_LOGIC_VECTOR(1 downto 0);
    signal scr_oe       : STD_LOGIC;

    signal flg_c_ld     : STD_LOGIC;
    signal flg_c_set    : STD_LOGIC;
    signal flg_c_clr    : STD_LOGIC;
    signal flg_z_ld     : STD_LOGIC;
    signal flg_z_clr    : STD_LOGIC;
    signal flg_shad_ld  : STD_LOGIC;
    signal flg_ld_sel   : STD_LOGIC;
    signal rst          : STD_LOGIC;

    signal multi_bus    : STD_LOGIC_VECTOR(9 downto 0);
    signal pc_count     : STD_LOGIC_VECTOR(9 downto 0);

    signal alu_result   : STD_LOGIC_VECTOR(7 downto 0);
    signal reg_dy_out   : STD_LOGIC_VECTOR(7 downto 0);

    signal sp_out       : STD_LOGIC_VECTOR(7 downto 0);
    signal sp_out_decrement : STD_LOGIC_VECTOR(7 downto 0);
    signal sp_out_increment : STD_LOGIC_VECTOR(7 downto 0);

    -- helpful aliases ---------------------------------------------------------
    alias opcode_hi_5     : STD_LOGIC_VECTOR(4 downto 0) is instruction(17 downto 13);
    alias opcode_lo_2     : STD_LOGIC_VECTOR(1 downto 0) is instruction(1 downto 0);
    alias adr_x           : STD_LOGIC_VECTOR(4 downto 0) is instruction(12 downto 8);
    alias adr_y           : STD_LOGIC_VECTOR(4 downto 0) is instruction(7 downto 3);
    alias inst_immed_12_3 : STD_LOGIC_VECTOR(9 downto 0) is instruction(12 downto 3);
    alias inst_immed_7_0  : STD_LOGIC_VECTOR(7 downto 0) is instruction(7 downto 0);

begin

   my_prog_rom: prog_rom
   port map(     ADDRESS => pc_count,
             INSTRUCTION => instruction,
                     CLK => CLK);

   my_alu: ALU
   port map ( ALU_CIN      => c_flag,
              ALU_SEL      => alu_sel,
              MULTI_BUS    => multi_bus(7 downto 0),
              REG_DY_OUT   => reg_dy_out,
              INST_REG_7_0 => instruction(7 downto 0),
              ALU_OPY_SEL  => alu_opy_sel,
              ALU_RESULT   => alu_result,
              ALU_FLG_C    => alu_flg_c,
              ALU_FLG_Z    => alu_flg_z );

   my_interrupt: Interrupt
   port map ( I_SET        => i_set,
              I_CLR        => i_clr,
              CLK          => CLK,
              INT_OUT      => int_out);

   my_cu: ControlUnit
   port map ( CLK          => CLK,
              C_FLAG       => c_flag,
              Z_FLAG       => z_flag,
              INT          => interrupt_signal,
              RESET        => RESET,
              OPCODE_HI_5  => opcode_hi_5,
              OPCODE_LO_2  => opcode_lo_2,

              PC_LD        => pc_ld,
              PC_INC       => pc_inc,
              PC_OE        => pc_oe,
              PC_MUX_SEL   => pc_mux_sel,
              SP_LD        => sp_ld,
              SP_MUX_SEL   => sp_mux_sel,
              RF_WR        => rf_wr,
              RF_WR_SEL    => rf_wr_sel,
              RF_OE        => rf_oe,
              ALU_OPY_SEL  => alu_opy_sel,
              ALU_SEL      => alu_sel,
              SCR_WR       => scr_wr,
              SCR_OE       => scr_oe,
              SCR_ADDR_SEL => scr_addr_sel,
              FLG_C_LD     => flg_c_ld,
              FLG_C_SET    => flg_c_set,
              FLG_C_CLR    => flg_c_clr,
              FLG_SHAD_LD  => flg_shad_ld,
              FLG_LD_SEL   => flg_ld_sel,
              FLG_Z_LD     => flg_z_ld,
              FLG_Z_CLR    => flg_z_clr,
              I_SET        => i_set,
              I_CLR        => i_clr,

              RST          => rst,
              IO_STRB      => IO_STRB);


   my_regfile: RegisterFile
   port map ( IN_PORT    => IN_PORT,
              MULTI_BUS  => multi_bus(7 downto 0),
              ALU_RESULT => alu_result,
              RF_WR_SEL  => rf_wr_sel,
              RF_WR      => rf_wr,
              RF_OE      => rf_oe,
              ADRX       => adr_x,
              ADRY       => adr_y,
              REG_DY_OUT => reg_dy_out,
              CLK        => CLK);

   my_PC: ProgramCounter
   port map ( RST           => rst,
              CLK           => CLK,
              PC_LD         => pc_ld,
              PC_OE         => pc_oe,
              PC_INC        => pc_inc,
              INST_REG_12_3 => inst_immed_12_3,
              MULTI_BUS     => multi_bus,
              PC_MUX_SEL    => pc_mux_sel,
              PC_COUNT      => pc_count,
              PC_TRI        => multi_bus);

   my_flags: Flags
   port map ( FLG_C_SET => flg_c_set,
              FLG_C_CLR => flg_c_clr,
              FLG_C_LD => flg_c_ld,
              FLG_Z_LD => flg_z_ld,
              FLG_Z_CLR => flg_z_clr,
              FLG_LD_SEL => flg_ld_sel,
              FLG_SHAD_LD => flg_shad_ld,
              IN_C_FLAG => alu_flg_c,
              IN_Z_FLAG => alu_flg_z,
              CLK => CLK,
              OUT_C_FLAG => c_flag,
              OUT_Z_FLAG => z_flag);

   my_sp: StackPointer
   port map ( SP_LD => sp_ld,
              RST => rst,
              SP_MUX_SEL => sp_mux_sel,
              MULTI_BUS => multi_bus(7 downto 0),
              SP_OUT_DECREMENT => sp_out_decrement,
              SP_OUT_INCREMENT => sp_out_increment,
              CLK => CLK,
              SP_OUT => sp_out);

   my_SCR: ScratchRAM
   port map ( REG_DY_OUT => reg_dy_out,
              INST_REG_7_0 => instruction(7 downto 0),
              SP_OUT => sp_out,
              SP_OUT_DECREMENT => sp_out_decrement,
              SCR_ADDR_SEL => scr_addr_sel,
              SCR_OE => scr_oe,
              SCR_WR => scr_wr,
              CLK => CLK,
              MULTI_BUS => multi_bus);

   interrupt_signal <= (INT AND int_out);
   sp_out_decrement <= (sp_out - "00000001");
   sp_out_increment <= (sp_out + "00000001");
   OUT_PORT <= multi_bus(7 downto 0);
   PORT_ID  <= inst_immed_7_0;

end Behavioral;

