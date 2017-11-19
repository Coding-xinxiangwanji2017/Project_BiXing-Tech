--------------------------------------------------------------------------------
--           *****************          *****************
--                           **        **          
--               ***          **      **           **
--              *   *          **    **           * *
--             *     *          **  **              *
--             *     *           ****               *
--             *     *          **  **              *
--              *   *          **    **             *
--               ***          **      **          *****
--                           **        ** 
--           *****************          *****************   
--------------------------------------------------------------------------------
-- 版    权  :  BiXing Tech
-- 文件名称  :  M_LcdDis.vhd
-- 设    计  :  LIU Hai 
-- 邮    件  :  zheng-jianfeng@139.com
-- 校    对  :  
-- 设计日期  :  2014/03/25
-- 功能简述  :  LCD display
-- 版本序号  :  0.1
-- 修改历史  :  1. Initial, LIU Hai, 2014/03/25
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

entity M_LcdDis is generic (
        C3_SIMULATION                   : string := "FALSE"
    );
    port (
        --------------------------------
        -- Clock
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      : in  std_logic;                        -- Clock 100MHz

        --------------------------------
        -- DVI & VGA IF
        --------------------------------
--        CpSl_Dvi5VIn_i                  : in  std_logic;                        -- DVI power on
--        CpSl_DviHotPlug_o               : out std_logic;                        -- DVI hot plug

        CpSl_Dvi0Clk_i                  : in  std_logic;                        -- DVI port0 clk
        CpSl_Dvi0Vsync_i                : in  std_logic;                        -- DVI port0 vsync
        CpSl_Dvi0Hsync_i                : in  std_logic;                        -- DVI port0 hsync
        CpSl_Dvi0Scdt_i                 : in  std_logic;                        -- DVI port0 SCDT
        CpSl_Dvi0De_i                   : in  std_logic;                        -- DVI port0 de
--        CpSv_Dvi0Ctrl_i                 : in  std_logic_vector( 2 downto 0);    -- DVI port0 control
        CpSv_Dvi0R_i                    : in  std_logic_vector( 7 downto 0);    -- DVI port0 red
--        CpSv_Dvi0G_i                    : in  std_logic_vector( 7 downto 0);    -- DVI port0 green
--        CpSv_Dvi0B_i                    : in  std_logic_vector( 7 downto 0);    -- DVI port0 blue
--        CpSl_Dvi0Mode_o                 : out std_logic;                        -- DVI port0 mode
--        CpSl_Dvi0Sclk_o                 : out std_logic;                        -- DVI port0 I2C clk
--        CpSl_Dvi0Sdata_o                : out std_logic;                        -- DVI port0 I2C data
--        CpSl_Dvi0HsDjtr_o               : out std_logic;                        -- DVI port0 HS-DJTR
--        CpSl_Dvi0Pd_o                   : out std_logic;                        -- DVI port0 power down

--        CpSl_Dvi1Clk_i                  : in  std_logic;                        -- DVI port1 clk
--        CpSl_Dvi1Vsync_i                : in  std_logic;                        -- DVI port1 vsync
--        CpSl_Dvi1Hsync_i                : in  std_logic;                        -- DVI port1 hsync
--        CpSl_Dvi1Scdt_i                 : in  std_logic;                        -- DVI port1 SCDT
--        CpSl_Dvi1De_i                   : in  std_logic;                        -- DVI port1 de
--        CpSv_Dvi1Ctrl_i                 : in  std_logic_vector( 2 downto 0);    -- DVI port1 control
--        CpSv_Dvi1R_i                    : in  std_logic_vector( 7 downto 0);    -- DVI port1 red
--        CpSv_Dvi1G_i                    : in  std_logic_vector( 7 downto 0);    -- DVI port1 green
--        CpSv_Dvi1B_i                    : in  std_logic_vector( 7 downto 0);    -- DVI port1 blue
--        CpSl_Dvi1Mode_o                 : out std_logic;                        -- DVI port1 mode
--        CpSl_Dvi1Sclk_o                 : out std_logic;                        -- DVI port1 I2C clk
--        CpSl_Dvi1Sdata_o                : out std_logic;                        -- DVI port1 I2C data
--        CpSl_Dvi1HsDjtr_o               : out std_logic;                        -- DVI port1 HS-DJTR
--        CpSl_Dvi1Pd_o                   : out std_logic;                        -- DVI port1 power down

--        CpSl_VgaClk_iP                  : in  std_logic;                        -- VGA clk P
--        CpSl_VgaClk_iN                  : in  std_logic;                        -- VGA clk N
--        CpSl_VgaVsync_i                 : in  std_logic;                        -- VGA vsync
--        CpSl_VgaHsync_i                 : in  std_logic;                        -- VGA hsync
--        CpSl_VgaGsync_i                 : in  std_logic;                        -- VGA gsync
--        CpSv_VgaR_i                     : in  std_logic_vector( 7 downto 0);    -- VGA red
--        CpSv_VgaG_i                     : in  std_logic_vector( 7 downto 0);    -- VGA green
--        CpSv_VgaB_i                     : in  std_logic_vector( 7 downto 0);    -- VGA blue
--        CpSl_VgaCoast_o                 : out std_logic;                        -- VGA coast
--        CpSl_VgaSclk_o                  : out std_logic;                        -- VGA I2C clk
--        CpSl_VgaSdata_o                 : out std_logic;                        -- VGA I2C data
--        CpSl_VgaClamp_o                 : out std_logic;                        -- VGA CLAMP
--        CpSl_VgaClkInv_o                : out std_logic;                        -- VGA clk inv

        --------------------------------
        -- GPIO & LED & Test IF
        --------------------------------
        CpSv_Gpio_i                     : in  std_logic_vector( 7 downto 0);    -- GPIO in
        CpSv_Gpio_o                     : out std_logic_vector( 7 downto 0);    -- GPIO out
        CpSv_Led_o                      : out std_logic_vector( 3 downto 0);    -- LED out
--        CpSv_Test_o                     : out std_logic_vector( 9 downto 0);    -- Test out

        --------------------------------
        -- FMC IF
        --------------------------------
--        FMC0_M2C_i                      : in  std_logic;                        -- Port 0 m2c
--        FMC0_C2M_o                      : out std_logic;                        -- Port 0 c2m
--        FMC0_Sclk_o                     : out std_logic;                        -- Port 0 I2C clk
--        FMC0_Sdata_o                    : out std_logic;                        -- Port 0 I2C data
        FMC0_LA02_P                     : out std_logic;                        -- Port 0 FMC_LA02_P
        FMC0_LA03_P                     : out std_logic;                        -- Port 0 FMC_LA03_P
        FMC0_LA04_P                     : out std_logic;                        -- Port 0 FMC_LA04_P
        FMC0_LA05_P                     : out std_logic;                        -- Port 0 FMC_LA05_P
        FMC0_LA06_P                     : out std_logic;                        -- Port 0 FMC_LA06_P
        FMC0_LA07_P                     : out std_logic;                        -- Port 0 FMC_LA07_P
        FMC0_LA08_P                     : out std_logic;                        -- Port 0 FMC_LA08_P
        FMC0_LA09_P                     : out std_logic;                        -- Port 0 FMC_LA09_P
        FMC0_LA10_P                     : out std_logic;                        -- Port 0 FMC_LA10_P
        FMC0_LA11_P                     : out std_logic;                        -- Port 0 FMC_LA11_P
        FMC0_LA12_P                     : out std_logic;                        -- Port 0 FMC_LA12_P
        FMC0_LA13_P                     : out std_logic;                        -- Port 0 FMC_LA13_P
        FMC0_LA14_P                     : out std_logic;                        -- Port 0 FMC_LA14_P
        FMC0_LA15_P                     : out std_logic;                        -- Port 0 FMC_LA15_P
        FMC0_LA16_P                     : out std_logic;                        -- Port 0 FMC_LA16_P
        FMC0_LA19_P                     : out std_logic;                        -- Port 0 FMC_LA19_P
        FMC0_LA20_P                     : out std_logic;                        -- Port 0 FMC_LA20_P
        FMC0_LA21_P                     : out std_logic;                        -- Port 0 FMC_LA21_P
        FMC0_LA22_P                     : out std_logic;                        -- Port 0 FMC_LA22_P
        FMC0_LA23_P                     : out std_logic;                        -- Port 0 FMC_LA23_P
        FMC0_LA24_P                     : out std_logic;                        -- Port 0 FMC_LA24_P
        FMC0_LA25_P                     : out std_logic;                        -- Port 0 FMC_LA25_P
        FMC0_LA26_P                     : out std_logic;                        -- Port 0 FMC_LA26_P
        FMC0_LA27_P                     : out std_logic;                        -- Port 0 FMC_LA27_P
        FMC0_LA28_P                     : out std_logic;                        -- Port 0 FMC_LA28_P
        FMC0_LA29_P                     : out std_logic;                        -- Port 0 FMC_LA29_P
        FMC0_LA30_P                     : out std_logic;                        -- Port 0 FMC_LA30_P
        FMC0_LA31_P                     : out std_logic;                        -- Port 0 FMC_LA31_P
        FMC0_LA32_N                     : out std_logic;                        -- Port 0 FMC_LA32_N
        FMC0_LA_N                       : out std_logic_vector(27 downto 0);    -- Port 0 FMC_N

--        FMC1_M2C_i                      : in  std_logic;                        -- Port 1 m2c
--        FMC1_C2M_o                      : out std_logic;                        -- Port 1 c2m
--        FMC1_Sclk_o                     : out std_logic;                        -- Port 1 I2C clk
--        FMC1_Sdata_o                    : out std_logic;                        -- Port 1 I2C data
        FMC1_LA02_P                     : out std_logic;                        -- Port 1 FMC_LA02_P
        FMC1_LA03_P                     : out std_logic;                        -- Port 1 FMC_LA03_P
        FMC1_LA04_P                     : out std_logic;                        -- Port 1 FMC_LA04_P
        FMC1_LA05_P                     : out std_logic;                        -- Port 1 FMC_LA05_P
        FMC1_LA06_P                     : out std_logic;                        -- Port 1 FMC_LA06_P
        FMC1_LA07_P                     : out std_logic;                        -- Port 1 FMC_LA07_P
        FMC1_LA08_P                     : out std_logic;                        -- Port 1 FMC_LA08_P
        FMC1_LA09_P                     : out std_logic;                        -- Port 1 FMC_LA09_P
        FMC1_LA10_P                     : out std_logic;                        -- Port 1 FMC_LA10_P
        FMC1_LA11_P                     : out std_logic;                        -- Port 1 FMC_LA11_P
        FMC1_LA12_P                     : out std_logic;                        -- Port 1 FMC_LA12_P
        FMC1_LA13_P                     : out std_logic;                        -- Port 1 FMC_LA13_P
        FMC1_LA14_P                     : out std_logic;                        -- Port 1 FMC_LA14_P
        FMC1_LA15_P                     : out std_logic;                        -- Port 1 FMC_LA15_P
        FMC1_LA16_P                     : out std_logic;                        -- Port 1 FMC_LA16_P
        FMC1_LA19_P                     : out std_logic;                        -- Port 1 FMC_LA19_P
        FMC1_LA20_P                     : out std_logic;                        -- Port 1 FMC_LA20_P
        FMC1_LA21_P                     : out std_logic;                        -- Port 1 FMC_LA21_P
        FMC1_LA22_P                     : out std_logic;                        -- Port 1 FMC_LA22_P
        FMC1_LA23_P                     : out std_logic;                        -- Port 1 FMC_LA23_P
        FMC1_LA24_P                     : out std_logic;                        -- Port 1 FMC_LA24_P
        FMC1_LA25_P                     : out std_logic;                        -- Port 1 FMC_LA25_P
        FMC1_LA26_P                     : out std_logic;                        -- Port 1 FMC_LA26_P
        FMC1_LA27_P                     : out std_logic;                        -- Port 1 FMC_LA27_P
        FMC1_LA28_P                     : out std_logic;                        -- Port 1 FMC_LA28_P
        FMC1_LA29_P                     : out std_logic;                        -- Port 1 FMC_LA29_P
        FMC1_LA30_P                     : out std_logic;                        -- Port 1 FMC_LA30_P
        FMC1_LA31_P                     : out std_logic;                        -- Port 1 FMC_LA31_P
        FMC1_LA32_N                     : out std_logic;                        -- Port 1 FMC_LA32_N
        FMC1_LA_N                       : out std_logic_vector(27 downto 0);    -- Port 1 FMC_N

        --------------------------------
        -- DDR IF
        --------------------------------
        mcb3_dram_reset_n               : out   std_logic;
        mcb3_dram_a                     : out   std_logic_vector(13 downto 0);
        mcb3_dram_ba                    : out   std_logic_vector( 2 downto 0);
        mcb3_dram_ras_n                 : out   std_logic;
        mcb3_dram_cas_n                 : out   std_logic;
        mcb3_dram_we_n                  : out   std_logic;
        mcb3_dram_odt                   : out   std_logic;
        mcb3_dram_cke                   : out   std_logic;
        mcb3_dram_dm                    : out   std_logic;
        mcb3_dram_udm                   : out   std_logic;
        mcb3_dram_ck                    : out   std_logic;
        mcb3_dram_ck_n                  : out   std_logic;
        mcb3_dram_dqs                   : inout std_logic;
        mcb3_dram_dqs_n                 : inout std_logic;
        mcb3_dram_udqs                  : inout std_logic;
        mcb3_dram_udqs_n                : inout std_logic;
        mcb3_dram_dq                    : inout std_logic_vector(15 downto 0);
        mcb3_rzq                        : inout std_logic;
        mcb3_zio                        : inout std_logic
    );
end M_LcdDis;

architecture arch_M_LcdDis of M_LcdDis is
    ----------------------------------------------------------------------------
    -- constant declaration
    ----------------------------------------------------------------------------

    ----------------------------------------------------------------------------
    -- component declaration
    ----------------------------------------------------------------------------
    component M_CtrlInd port (
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      : in  std_logic;                        -- Clock

        --------------------------------
        -- Control
        --------------------------------
        CpSl_IntVsync_i                 : in  std_logic;                        -- Internal Vsync
        CpSl_PortSel_i                  : in  std_logic;                        -- Port Select in
        CpSl_ExtVsyncInd_i              : in  std_logic;                        -- External Vsync indicator
        CpSl_ExtVsync_i                 : in  std_logic;                        -- External Vsync

        --------------------------------
        -- Output signals
        --------------------------------
        CpSl_PortSel_o                  : out std_logic;                        -- Port Select out
        CpSl_ExtVsyncVld_o              : out std_logic;                        -- External vsync valid
        CpSl_VsyncCtrl_o                : out std_logic                         -- Vsync control
    );
    end component;

    component M_DviIf port (
        --------------------------------
        -- DVI input
        --------------------------------
        CpSl_DviClk_i                   : in  std_logic;                        -- DVI clk
        CpSl_DviVsync_i                 : in  std_logic;                        -- DVI V sync
        CpSl_DviHsync_i                 : in  std_logic;                        -- DVI H sync
        CpSl_DviDe_i                    : in  std_logic;                        -- DVI De
        CpSv_DviR_i                     : in  std_logic_vector( 7 downto 0);    -- DVI read

        --------------------------------
        -- DDR write
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, active low
        CpSl_DdrClk_i                   : in  std_logic;                        -- Clock
        CpSl_DdrWrCmdEn_o               : out std_logic;                        -- DDR write command enable
        CpSv_DdrWrCmdAddr_o             : out std_logic_vector(29 downto 0);    -- DDR write command address
        CpSl_DdrWrCmdFull_i             : in  std_logic;                        -- DDR write command full
        CpSl_DdrWrDataEn_o              : out std_logic;                        -- DDR write data eanble
        CpSv_DdrWrData_o                : out std_logic_vector(63 downto 0);    -- DDR write data
        CpSl_DdrWrDataFull_i            : in  std_logic;                        -- DDR write data full
        CpSv_DdrWrDataCnt_i             : in  std_logic_vector( 6 downto 0);    -- DDR write data counter
        CpSv_DdrWrTimeSlot_o            : out std_logic_vector( 2 downto 0)     -- DDR write time slot
    );
    end component;

    component M_LcdIf port (
        --------------------------------
        -- Lcd output
        --------------------------------
        CpSl_LcdClk_i                   : in  std_logic;                        -- DVI clk
        CpSl_LcdVsync_o                 : out std_logic;                        -- DVI V sync
        CpSl_LcdHsync_o                 : out std_logic;                        -- DVI H sync
        CpSv_LcdR0_o                    : out std_logic_vector(11 downto 0);    -- DVI read
        CpSv_LcdR1_o                    : out std_logic_vector(11 downto 0);    -- DVI read
        CpSv_LcdR2_o                    : out std_logic_vector(11 downto 0);    -- DVI read
        CpSv_LcdR3_o                    : out std_logic_vector(11 downto 0);    -- DVI read

        --------------------------------
        -- Control
        --------------------------------
        CpSl_VsyncCtrl_i                : in  std_logic;                        -- V sync control

        --------------------------------
        -- DDR read
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, active low
        CpSl_DdrRdCmdEn_o               : out std_logic;                        -- DDR read command enable
        CpSv_DdrRdCmdAddr_o             : out std_logic_vector(29 downto 0);    -- DDR read command address
        CpSl_DdrRdCmdFull_i             : in  std_logic;                        -- DDR read command full
        CpSl_DdrRdDataEn_o              : out std_logic;                        -- DDR read data eanble
        CpSv_DdrRdData_i                : in  std_logic_vector(63 downto 0);    -- DDR read data
        CpSl_DdrRdDataEmpty_i           : in  std_logic;                        -- DDR read data empty
        CpSv_DdrRdDataCnt_i             : in  std_logic_vector( 6 downto 0);    -- DDR read data counter
        CpSv_DdrRdTimeSlot_i            : in  std_logic_vector( 2 downto 0)     -- DDR read time slot
    );
    end component;

    component M_DdrCtrl generic (
        C3_RST_ACT_LOW                  : integer := 0      ;
        C3_SIMULATION                   : string  := "FALSE"
    );
    port (
        -- DDR3 device
        mcb3_dram_reset_n               : out   std_logic;
        mcb3_dram_a                     : out   std_logic_vector(13 downto 0);
        mcb3_dram_ba                    : out   std_logic_vector( 2 downto 0);
        mcb3_dram_ras_n                 : out   std_logic;
        mcb3_dram_cas_n                 : out   std_logic;
        mcb3_dram_we_n                  : out   std_logic;
        mcb3_dram_odt                   : out   std_logic;
        mcb3_dram_cke                   : out   std_logic;
        mcb3_dram_dm                    : out   std_logic;
        mcb3_dram_udm                   : out   std_logic;
        mcb3_dram_ck                    : out   std_logic;
        mcb3_dram_ck_n                  : out   std_logic;
        mcb3_dram_dqs                   : inout std_logic;
        mcb3_dram_dqs_n                 : inout std_logic;
        mcb3_dram_udqs                  : inout std_logic;
        mcb3_dram_udqs_n                : inout std_logic;
        mcb3_dram_dq                    : inout std_logic_vector(15 downto 0);
        mcb3_rzq                        : inout std_logic;
        mcb3_zio                        : inout std_logic;
        -- User
        c3_sys_rst_i                    : in    std_logic;
        c3_sys_clk                      : in    std_logic;
        c3_rst0                         : out   std_logic;
        c3_clk0                         : out   std_logic;
        c3_calib_done                   : out   std_logic;
        -- Write
        c3_p0_cmd_clk                   : in    std_logic;
        c3_p0_cmd_en                    : in    std_logic;
        c3_p0_cmd_instr                 : in    std_logic_vector( 2 downto 0);
        c3_p0_cmd_bl                    : in    std_logic_vector( 5 downto 0);
        c3_p0_cmd_byte_addr             : in    std_logic_vector(29 downto 0);
        c3_p0_cmd_empty                 : out   std_logic;
        c3_p0_cmd_full                  : out   std_logic;
        c3_p0_wr_clk                    : in    std_logic;
        c3_p0_wr_en                     : in    std_logic;
        c3_p0_wr_mask                   : in    std_logic_vector( 7 downto 0);
        c3_p0_wr_data                   : in    std_logic_vector(63 downto 0);
        c3_p0_wr_full                   : out   std_logic;
        c3_p0_wr_empty                  : out   std_logic;
        c3_p0_wr_count                  : out   std_logic_vector( 6 downto 0);
        c3_p0_wr_underrun               : out   std_logic;
        c3_p0_wr_error                  : out   std_logic;
        c3_p0_rd_clk                    : in    std_logic;
        c3_p0_rd_en                     : in    std_logic;
        c3_p0_rd_data                   : out   std_logic_vector(63 downto 0);
        c3_p0_rd_full                   : out   std_logic;
        c3_p0_rd_empty                  : out   std_logic;
        c3_p0_rd_count                  : out   std_logic_vector( 6 downto 0);
        c3_p0_rd_overflow               : out   std_logic;
        c3_p0_rd_error                  : out   std_logic;
        -- Read
        c3_p1_cmd_clk                   : in    std_logic;
        c3_p1_cmd_en                    : in    std_logic;
        c3_p1_cmd_instr                 : in    std_logic_vector( 2 downto 0);
        c3_p1_cmd_bl                    : in    std_logic_vector( 5 downto 0);
        c3_p1_cmd_byte_addr             : in    std_logic_vector(29 downto 0);
        c3_p1_cmd_empty                 : out   std_logic;
        c3_p1_cmd_full                  : out   std_logic;
        c3_p1_wr_clk                    : in    std_logic;
        c3_p1_wr_en                     : in    std_logic;
        c3_p1_wr_mask                   : in    std_logic_vector( 7 downto 0);
        c3_p1_wr_data                   : in    std_logic_vector(63 downto 0);
        c3_p1_wr_full                   : out   std_logic;
        c3_p1_wr_empty                  : out   std_logic;
        c3_p1_wr_count                  : out   std_logic_vector( 6 downto 0);
        c3_p1_wr_underrun               : out   std_logic;
        c3_p1_wr_error                  : out   std_logic;
        c3_p1_rd_clk                    : in    std_logic;
        c3_p1_rd_en                     : in    std_logic;
        c3_p1_rd_data                   : out   std_logic_vector(63 downto 0);
        c3_p1_rd_full                   : out   std_logic;
        c3_p1_rd_empty                  : out   std_logic;
        c3_p1_rd_count                  : out   std_logic_vector( 6 downto 0);
        c3_p1_rd_overflow               : out   std_logic;
        c3_p1_rd_error                  : out   std_logic
    );
    end component;

    component M_ClkPll port (
        reset                           : in  std_logic;
        clk_in1                         : in  std_logic;
        clk_out1                        : out std_logic;
        clk_out2                        : out std_logic;
        locked                          : out std_logic
    );
    end component;

    component remapper port (
        clock                           : in  std_logic;
        hsync                           : in  std_logic;
        vsync                           : in  std_logic;
        r1                              : in  std_logic_vector( 11 downto 0);
        r2                              : in  std_logic_vector( 11 downto 0);
        r3                              : in  std_logic_vector( 11 downto 0);
        r4                              : in  std_logic_vector( 11 downto 0);
        g1                              : in  std_logic_vector( 11 downto 0);
        g2                              : in  std_logic_vector( 11 downto 0);
        g3                              : in  std_logic_vector( 11 downto 0);
        g4                              : in  std_logic_vector( 11 downto 0);
        b1                              : in  std_logic_vector( 11 downto 0);
        b2                              : in  std_logic_vector( 11 downto 0);
        b3                              : in  std_logic_vector( 11 downto 0);
        b4                              : in  std_logic_vector( 11 downto 0);
        pardata                         : out std_logic_vector( 55 downto 0);
        pardata_h                       : out std_logic_vector(104 downto 0);
        pardata_l                       : out std_logic_vector( 90 downto 0)
    );
    end component;

    component M_DisData port (
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      : in  std_logic;                        -- Clock

        --------------------------------
        -- Output signals
        --------------------------------
        CpSl_Hsync_o                    : out std_logic;
        CpSl_Vsync_o                    : out std_logic;
        CpSv_Red0_o                     : out std_logic_vector(11 downto 0);
        CpSv_Red1_o                     : out std_logic_vector(11 downto 0);
        CpSv_Red2_o                     : out std_logic_vector(11 downto 0);
        CpSv_Red3_o                     : out std_logic_vector(11 downto 0)
    );
    end component;

    component M_HSelectIO port (
        io_reset                        : in  std_logic;
        clk_in                          : in  std_logic;
        clk_div_in                      : in  std_logic;
        locked_in                       : in  std_logic;
        data_out_from_device            : in  std_logic_vector(104 downto 0);
        data_out_to_pins_p              : out std_logic_vector( 14 downto 0);
        data_out_to_pins_n              : out std_logic_vector( 14 downto 0);
        locked_out                      : out std_logic
    );
    end component;

    component M_LSelectIO port (
        io_reset                        : in  std_logic;
        clk_in                          : in  std_logic;
        clk_div_in                      : in  std_logic;
        locked_in                       : in  std_logic;
        data_out_from_device            : in  std_logic_vector(90 downto 0);
        data_out_to_pins_p              : out std_logic_vector(12 downto 0);
        data_out_to_pins_n              : out std_logic_vector(12 downto 0);
        locked_out                      : out std_logic
    );
    end component;

--    component M_Icon port (
--        control0                        : inout std_logic_vector(35 downto 0);
--        control1                        : inout std_logic_vector(35 downto 0)
--    );
--    end component;
--
--    component M_Ila port (
--        control                         : inout std_logic_vector(35 downto 0);
--        clk                             : in    std_logic;
--        trig0                           : in    std_logic_vector(15 downto 0)
--    );
--    end component;
--
--    component M_Vio port (
--        control                         : inout std_logic_vector(35 downto 0);
--        async_in                        : in    std_logic_vector( 7 downto 0);
--        async_out                       : out   std_logic_vector( 7 downto 0)
--    );
--    end component;

    ----------------------------------------------------------------------------
    -- signal declaration
    ----------------------------------------------------------------------------
    -- For GPIO & test
    signal PrSl_PortSelIn_s             : std_logic;                            -- Port select input
    signal PrSl_ExtVsyncInd_s           : std_logic;                            -- External Vsync indicator
    signal PrSl_ExtVsync_s              : std_logic;                            -- External Vsync
    signal PrSl_PortSel_s               : std_logic;                            -- Port select inner
    signal PrSl_ExtVsyncVld_s           : std_logic;                            -- External vsync valid
    signal PrSl_VsyncCtrl_s             : std_logic;                            -- Vsync control
    -- For DDR
    signal PrSl_DdrRst_s                : std_logic;                            -- DDR reset out, active high
    signal PrSl_DdrClk_s                : std_logic;                            -- DDR clock out
    signal PrSl_DdrRdy_s                : std_logic;                            -- DDR calibration done
    signal PrSl_DdrWrCmdEn_s            : std_logic;                            -- DDR write command enable
    signal PrSv_DdrWrCmdAddr_s          : std_logic_vector(29 downto 0);        -- DDR write command address
    signal PrSl_DdrWrCmdFull_s          : std_logic;                            -- DDR write command full
    signal PrSl_DdrWrDataEn_s           : std_logic;                            -- DDR write data eanble
    signal PrSv_DdrWrData_s             : std_logic_vector(63 downto 0);        -- DDR write data
    signal PrSl_DdrWrDataFull_s         : std_logic;                            -- DDR write data full
    signal PrSv_DdrWrDataCnt_s          : std_logic_vector( 6 downto 0);        -- DDR write data counter
    signal PrSl_DdrRdCmdEn_s            : std_logic;                            -- DDR read command enable
    signal PrSv_DdrRdCmdAddr_s          : std_logic_vector(29 downto 0);        -- DDR read command address
    signal PrSl_DdrRdCmdFull_s          : std_logic;                            -- DDR read command full
    signal PrSl_DdrRdDataEn_s           : std_logic;                            -- DDR read data eanble
    signal PrSv_DdrRdData_s             : std_logic_vector(63 downto 0);        -- DDR read data
    signal PrSl_DdrRdDataEmpty_s        : std_logic;                            -- DDR read data empty
    signal PrSv_DdrRdDataCnt_s          : std_logic_vector( 6 downto 0);        -- DDR read data counter
    signal PrSv_DdrWrTimeSlot_s         : std_logic_vector( 2 downto 0);        -- DDR write time slot
    -- Clock
    signal PrSl_ClkFmc_s                : std_logic;                            -- FMC clk
    signal PrSl_ClkLcd_s                : std_logic;                            -- LCD clk
    signal PrSl_PllLock_s               : std_logic;                            -- PLL lock
    -- Data source
    signal PrSl_RealHsync_s             : std_logic;                            -- Real h sync
    signal PrSl_RealVsync_s             : std_logic;                            -- Real v sync
    signal PrSv_RealRed0_s              : std_logic_vector(  11 downto 0);      -- Real red ch0
    signal PrSv_RealRed1_s              : std_logic_vector(  11 downto 0);      -- Real red ch1
    signal PrSv_RealRed2_s              : std_logic_vector(  11 downto 0);      -- Real red ch2
    signal PrSv_RealRed3_s              : std_logic_vector(  11 downto 0);      -- Real red ch3
    signal PrSl_SimSwitch_s             : std_logic;                            -- Sim data switch
    signal PrSl_SimHsync_s              : std_logic;                            -- Sim h sync
    signal PrSl_SimVsync_s              : std_logic;                            -- Sim v sync
    signal PrSv_SimRed0_s               : std_logic_vector(  11 downto 0);      -- Sim red ch0
    signal PrSv_SimRed1_s               : std_logic_vector(  11 downto 0);      -- Sim red ch1
    signal PrSv_SimRed2_s               : std_logic_vector(  11 downto 0);      -- Sim red ch2
    signal PrSv_SimRed3_s               : std_logic_vector(  11 downto 0);      -- Sim red ch3
    -- Remapper
    signal PrSl_Hsync_s                 : std_logic;                            -- H sync
    signal PrSl_Vsync_s                 : std_logic;                            -- V sync
    signal PrSv_P0Red0_s                : std_logic_vector(  11 downto 0);      -- Port0 Red ch0
    signal PrSv_P0Red1_s                : std_logic_vector(  11 downto 0);      -- Port0 Red ch1
    signal PrSv_P0Red2_s                : std_logic_vector(  11 downto 0);      -- Port0 Red ch2
    signal PrSv_P0Red3_s                : std_logic_vector(  11 downto 0);      -- Port0 Red ch3
    signal PrSv_P1Red0_s                : std_logic_vector(  11 downto 0);      -- Port1 Red ch0
    signal PrSv_P1Red1_s                : std_logic_vector(  11 downto 0);      -- Port1 Red ch1
    signal PrSv_P1Red2_s                : std_logic_vector(  11 downto 0);      -- Port1 Red ch2
    signal PrSv_P1Red3_s                : std_logic_vector(  11 downto 0);      -- Port1 Red ch3
    -- LCD port0 & port1
    signal PrSv_P0MatrixH_s             : std_logic_vector(104 downto 0);       -- Port 0 matrix high
    signal PrSv_P0MatrixHS_sP           : std_logic_vector( 14 downto 0);       -- Port 0 matrix high serial
    signal PrSv_P0MatrixHS_sN           : std_logic_vector( 14 downto 0);       -- Port 0 matrix high serial
    signal PrSl_P0MatrixHLock_s         : std_logic;                            -- Port 0 high SelectIO lock 
    signal PrSv_P0MatrixL_s             : std_logic_vector( 90 downto 0);       -- Port 0 matrix low
    signal PrSv_P0MatrixLS_sP           : std_logic_vector( 12 downto 0);       -- Port 0 matrix low serial P
    signal PrSv_P0MatrixLS_sN           : std_logic_vector( 12 downto 0);       -- Port 0 matrix low serial N
    signal PrSl_P0MatrixLLock_s         : std_logic;                            -- Port 0 low selectIO lock
    signal PrSv_P1MatrixH_s             : std_logic_vector(104 downto 0);       -- Port 1 matrix high
    signal PrSv_P1MatrixHS_sP           : std_logic_vector( 14 downto 0);       -- Port 1 matrix high serial
    signal PrSv_P1MatrixHS_sN           : std_logic_vector( 14 downto 0);       -- Port 1 matrix high serial
    signal PrSl_P1MatrixHLock_s         : std_logic;                            -- Port 1 high SelectIO lock 
    signal PrSv_P1MatrixL_s             : std_logic_vector( 90 downto 0);       -- Port 1 matrix low
    signal PrSv_P1MatrixLS_sP           : std_logic_vector( 12 downto 0);       -- Port 1 matrix low serial P
    signal PrSv_P1MatrixLS_sN           : std_logic_vector( 12 downto 0);       -- Port 1 matrix low serial N
    signal PrSl_P1MatrixLLock_s         : std_logic;                            -- Port 1 low selectIO lock
--    -- Chipscope
--    signal PrSv_ChipCtrl0_s             : std_logic_vector(35 downto 0);        -- 
--    signal PrSv_ChipCtrl1_s             : std_logic_vector(35 downto 0);        -- 
--    signal PrSv_ChipTrig0_s             : std_logic_vector(15 downto 0);        -- 
--    signal PrSv_VioIn_s                 : std_logic_vector( 7 downto 0);        -- 
--    signal PrSv_VioOut_s                : std_logic_vector( 7 downto 0);        -- 

begin
--    ----------------------------------------------------------------------------
--    -- Chipscope
--    ----------------------------------------------------------------------------
--    U_M_Icon_0 : M_Icon port map (
--        control0                        => PrSv_ChipCtrl0_s                     ,
--        control1                        => PrSv_ChipCtrl1_s
--    );
--
--    U_M_Ila_0 : M_Ila port map (
--        control                         => PrSv_ChipCtrl0_s                     ,
--        clk                             => PrSl_ClkLcd_s                        ,
--        trig0                           => PrSv_ChipTrig0_s
--    );
--
--    U_M_Vio_0 : M_Vio port map (
--        control                         => PrSv_ChipCtrl1_s                     ,
--        async_in                        => PrSv_VioIn_s                         ,
--        async_out                       => PrSv_VioOut_s
--    );
--
--    PrSv_ChipTrig0_s(           0) <= PrSl_PortSel_s    ;
--    PrSv_ChipTrig0_s(           1) <= PrSl_ExtVsyncVld_s;
--    PrSv_ChipTrig0_s(15 downto  2) <= (others => '0')   ;
--
--    PrSv_VioIn_s(           0) <= PrSl_PortSel_s    ;
--    PrSv_VioIn_s(           1) <= PrSl_ExtVsyncVld_s;
--    PrSv_VioIn_s( 7 downto  2) <= (others => '0')   ;
--
--    PrSl_PortSelIn_s   <= PrSv_VioOut_s(0);
--    PrSl_ExtVsyncInd_s <= PrSv_VioOut_s(1);

    ----------------------------------------------------------------------------
    -- GPIO & test
    ----------------------------------------------------------------------------
    ------------------------------------
    -- GPIO input
    ------------------------------------
    PrSl_PortSelIn_s   <= CpSv_Gpio_i(0); -- Port select, 0: port0, 1: port1
    PrSl_ExtVsyncInd_s <= CpSv_Gpio_i(1); -- External Vsync indicator
    PrSl_ExtVsync_s    <= CpSv_Gpio_i(2); -- External Vsync

    ------------------------------------
    -- GPIO output
    ------------------------------------
    CpSv_Gpio_o(0) <= '1'; --
    CpSv_Gpio_o(1) <= '1'; --
    CpSv_Gpio_o(2) <= '1'; --
    CpSv_Gpio_o(3) <= not PrSl_PortSel_s; -- Active port0 
    CpSv_Gpio_o(4) <=     PrSl_PortSel_s; -- Active port1 
    CpSv_Gpio_o(5) <=    CpSl_Dvi0Scdt_i; -- 
    CpSv_Gpio_o(6) <= PrSl_ExtVsyncVld_s; -- 
    CpSv_Gpio_o(7) <=                '1'; -- 

    ------------------------------------
    -- LED
    ------------------------------------
    CpSv_Led_o(0) <= not PrSl_DdrRdy_s; -- DDR calibration done
    CpSv_Led_o(1) <= '1';
    CpSv_Led_o(2) <= '1';
    CpSv_Led_o(3) <= '1';

    ------------------------------------
    -- GPIO i/o process
    ------------------------------------
    U_M_CtrlInd_0 : M_CtrlInd port map (
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     => PrSl_PllLock_s                       , -- in  std_logic;                        -- Reset, active high
        CpSl_Clk_i                      => PrSl_ClkLcd_s                        , -- in  std_logic;                        -- Clock

        --------------------------------
        -- Control
        --------------------------------
        CpSl_IntVsync_i                 => CpSl_Dvi0Vsync_i                     , -- in  std_logic;                        -- Internal Vsync
        CpSl_PortSel_i                  => PrSl_PortSelIn_s                     , -- in  std_logic;                        -- Port Select in
        CpSl_ExtVsyncInd_i              => PrSl_ExtVsyncInd_s                   , -- in  std_logic;                        -- External Vsync valid
        CpSl_ExtVsync_i                 => PrSl_ExtVsync_s                      , -- in  std_logic;                        -- External Vsync

        --------------------------------
        -- Output signals
        --------------------------------
        CpSl_PortSel_o                  => PrSl_PortSel_s                       , -- out std_logic;                        -- Port Select out
        CpSl_ExtVsyncVld_o              => PrSl_ExtVsyncVld_s                   , -- out std_logic;                        -- External vsync indicator
        CpSl_VsyncCtrl_o                => PrSl_VsyncCtrl_s                       -- out std_logic                         -- Vsync control
    );

    ----------------------------------------------------------------------------
    -- DVI if
    ----------------------------------------------------------------------------
    U_M_DviIf_0 : M_DviIf port map (
        --------------------------------
        -- DVI input
        --------------------------------
        CpSl_DviClk_i                   => CpSl_Dvi0Clk_i                       , -- in  std_logic;                        -- DVI clk
        CpSl_DviVsync_i                 => CpSl_Dvi0Vsync_i                     , -- in  std_logic;                        -- DVI V sync
        CpSl_DviHsync_i                 => CpSl_Dvi0Hsync_i                     , -- in  std_logic;                        -- DVI H sync
        CpSl_DviDe_i                    => CpSl_Dvi0De_i                        , -- in  std_logic;                        -- DVI De
        CpSv_DviR_i                     => CpSv_Dvi0R_i                         , -- in  std_logic_vector( 7 downto 0);    -- DVI read

        --------------------------------
        -- DDR write
        --------------------------------
        CpSl_Rst_iN                     => CpSl_Dvi0Scdt_i and PrSl_DdrRdy_s    , -- in  std_logic;                        -- Reset, active low
        CpSl_DdrClk_i                   => PrSl_DdrClk_s                        , -- in  std_logic;                        -- Clock
        CpSl_DdrWrCmdEn_o               => PrSl_DdrWrCmdEn_s                    , -- out std_logic;                        -- DDR write command enable
        CpSv_DdrWrCmdAddr_o             => PrSv_DdrWrCmdAddr_s                  , -- out std_logic_vector(29 downto 0);    -- DDR write command address
        CpSl_DdrWrCmdFull_i             => PrSl_DdrWrCmdFull_s                  , -- in  std_logic;                        -- DDR write command full
        CpSl_DdrWrDataEn_o              => PrSl_DdrWrDataEn_s                   , -- out std_logic;                        -- DDR write data eanble
        CpSv_DdrWrData_o                => PrSv_DdrWrData_s                     , -- out std_logic_vector(63 downto 0);    -- DDR write data
        CpSl_DdrWrDataFull_i            => PrSl_DdrWrDataFull_s                 , -- in  std_logic;                        -- DDR write data full
        CpSv_DdrWrDataCnt_i             => PrSv_DdrWrDataCnt_s                  , -- in  std_logic_vector( 6 downto 0);    -- DDR write data counter
        CpSv_DdrWrTimeSlot_o            => PrSv_DdrWrTimeSlot_s                   -- out std_logic_vector( 2 downto 0)     -- DDR write time slot
    );

    ----------------------------------------------------------------------------
    -- DVI if
    ----------------------------------------------------------------------------
    U_M_LcdIf_0 : M_LcdIf port map (
        --------------------------------
        -- Lcd output
        --------------------------------
        CpSl_LcdClk_i                   => PrSl_ClkLcd_s                        , -- in  std_logic;                        -- DVI clk
        CpSl_LcdVsync_o                 => PrSl_RealVsync_s                     , -- out std_logic;                        -- DVI V sync
        CpSl_LcdHsync_o                 => PrSl_RealHsync_s                     , -- out std_logic;                        -- DVI H sync
        CpSv_LcdR0_o                    => PrSv_RealRed0_s                      , -- out std_logic_vector(11 downto 0);    -- DVI read
        CpSv_LcdR1_o                    => PrSv_RealRed1_s                      , -- out std_logic_vector(11 downto 0);    -- DVI read
        CpSv_LcdR2_o                    => PrSv_RealRed2_s                      , -- out std_logic_vector(11 downto 0);    -- DVI read
        CpSv_LcdR3_o                    => PrSv_RealRed3_s                      , -- out std_logic_vector(11 downto 0);    -- DVI read

        --------------------------------
        -- Control
        --------------------------------
        CpSl_VsyncCtrl_i                => PrSl_VsyncCtrl_s                     , -- in  std_logic;                        -- V sync control

        --------------------------------
        -- DDR read
        --------------------------------
        CpSl_Rst_iN                     => CpSl_Dvi0Scdt_i and CpSl_Rst_iN      , -- in  std_logic;                        -- Reset, active low
        CpSl_DdrRdCmdEn_o               => PrSl_DdrRdCmdEn_s                    , -- out std_logic;                        -- DDR read command enable
        CpSv_DdrRdCmdAddr_o             => PrSv_DdrRdCmdAddr_s                  , -- out std_logic_vector(29 downto 0);    -- DDR read command address
        CpSl_DdrRdCmdFull_i             => PrSl_DdrRdCmdFull_s                  , -- in  std_logic;                        -- DDR read command full
        CpSl_DdrRdDataEn_o              => PrSl_DdrRdDataEn_s                   , -- out std_logic;                        -- DDR read data eanble
        CpSv_DdrRdData_i                => PrSv_DdrRdData_s                     , -- in  std_logic_vector(63 downto 0);    -- DDR read data
        CpSl_DdrRdDataEmpty_i           => PrSl_DdrRdDataEmpty_s                , -- in  std_logic;                        -- DDR read data empty
        CpSv_DdrRdDataCnt_i             => PrSv_DdrRdDataCnt_s                  , -- in  std_logic_vector( 6 downto 0);    -- DDR read data counter
        CpSv_DdrRdTimeSlot_i            => PrSv_DdrWrTimeSlot_s                   -- in  std_logic_vector( 2 downto 0)     -- DDR read time slot
    );

    ----------------------------------------------------------------------------
    -- Instant
    ----------------------------------------------------------------------------
    ------------------------------------
    -- DDR3
    -- Input clock: 100MHz
    -- DDR3 clock:  300MHz (double to 600MHz)
    -- User clock:   60MHz  
    ------------------------------------
    U_M_DdrCtrl_0 : M_DdrCtrl generic map (
        C3_RST_ACT_LOW                  => 1            ,
        C3_SIMULATION                   => C3_SIMULATION
    )
    port map (
        -- DDR3 device
        mcb3_dram_reset_n               => mcb3_dram_reset_n                    , -- out   std_logic;
        mcb3_dram_a                     => mcb3_dram_a                          , -- out   std_logic_vector(13 downto 0);
        mcb3_dram_ba                    => mcb3_dram_ba                         , -- out   std_logic_vector( 2 downto 0);
        mcb3_dram_ras_n                 => mcb3_dram_ras_n                      , -- out   std_logic;
        mcb3_dram_cas_n                 => mcb3_dram_cas_n                      , -- out   std_logic;
        mcb3_dram_we_n                  => mcb3_dram_we_n                       , -- out   std_logic;
        mcb3_dram_odt                   => mcb3_dram_odt                        , -- out   std_logic;
        mcb3_dram_cke                   => mcb3_dram_cke                        , -- out   std_logic;
        mcb3_dram_dm                    => mcb3_dram_dm                         , -- out   std_logic;
        mcb3_dram_udm                   => mcb3_dram_udm                        , -- out   std_logic;
        mcb3_dram_ck                    => mcb3_dram_ck                         , -- out   std_logic;
        mcb3_dram_ck_n                  => mcb3_dram_ck_n                       , -- out   std_logic;
        mcb3_dram_dqs                   => mcb3_dram_dqs                        , -- inout std_logic;
        mcb3_dram_dqs_n                 => mcb3_dram_dqs_n                      , -- inout std_logic;
        mcb3_dram_udqs                  => mcb3_dram_udqs                       , -- inout std_logic;
        mcb3_dram_udqs_n                => mcb3_dram_udqs_n                     , -- inout std_logic;
        mcb3_dram_dq                    => mcb3_dram_dq                         , -- inout std_logic_vector(15 downto 0);
        mcb3_rzq                        => mcb3_rzq                             , -- inout std_logic;
        mcb3_zio                        => mcb3_zio                             , -- inout std_logic;
        -- User
        c3_sys_rst_i                    => CpSl_Rst_iN                          , -- in    std_logic;
        c3_sys_clk                      => CpSl_Clk_i                           , -- in    std_logic;
        c3_rst0                         => PrSl_DdrRst_s                        , -- out   std_logic;
        c3_clk0                         => PrSl_DdrClk_s                        , -- out   std_logic;
        c3_calib_done                   => PrSl_DdrRdy_s                        , -- out   std_logic;
        -- Write
        c3_p0_cmd_clk                   => PrSl_DdrClk_s                        , -- in    std_logic;
        c3_p0_cmd_en                    => PrSl_DdrWrCmdEn_s                    , -- in    std_logic;
        c3_p0_cmd_instr                 => "000"                                , -- in    std_logic_vector( 2 downto 0);
        c3_p0_cmd_bl                    => "111011"                             , -- in    std_logic_vector( 5 downto 0); -- 60*3*8=1440
        c3_p0_cmd_byte_addr             => PrSv_DdrWrCmdAddr_s                  , -- in    std_logic_vector(29 downto 0);
        c3_p0_cmd_empty                 => open                                 , -- out   std_logic;
        c3_p0_cmd_full                  => PrSl_DdrWrCmdFull_s                  , -- out   std_logic;
        c3_p0_wr_clk                    => PrSl_DdrClk_s                        , -- in    std_logic;
        c3_p0_wr_en                     => PrSl_DdrWrDataEn_s                   , -- in    std_logic;
        c3_p0_wr_mask                   => x"00"                                , -- in    std_logic_vector( 7 downto 0);
        c3_p0_wr_data                   => PrSv_DdrWrData_s                     , -- in    std_logic_vector(63 downto 0);
        c3_p0_wr_full                   => PrSl_DdrWrDataFull_s                 , -- out   std_logic;
        c3_p0_wr_empty                  => open                                 , -- out   std_logic;
        c3_p0_wr_count                  => PrSv_DdrWrDataCnt_s                  , -- out   std_logic_vector( 6 downto 0);
        c3_p0_wr_underrun               => open                                 , -- out   std_logic;
        c3_p0_wr_error                  => open                                 , -- out   std_logic;
        c3_p0_rd_clk                    => PrSl_DdrClk_s                        , -- in    std_logic;
        c3_p0_rd_en                     => '0'                                  , -- in    std_logic;
        c3_p0_rd_data                   => open                                 , -- out   std_logic_vector(63 downto 0);
        c3_p0_rd_full                   => open                                 , -- out   std_logic;
        c3_p0_rd_empty                  => open                                 , -- out   std_logic;
        c3_p0_rd_count                  => open                                 , -- out   std_logic_vector( 6 downto 0);
        c3_p0_rd_overflow               => open                                 , -- out   std_logic;
        c3_p0_rd_error                  => open                                 , -- out   std_logic;
        -- Read
        c3_p1_cmd_clk                   => PrSl_ClkLcd_s                        , -- in    std_logic;
        c3_p1_cmd_en                    => PrSl_DdrRdCmdEn_s                    , -- in    std_logic;
        c3_p1_cmd_instr                 => "001"                                , -- in    std_logic_vector( 2 downto 0);
        c3_p1_cmd_bl                    => "111011"                             , -- in    std_logic_vector( 5 downto 0); -- 60*3*8=1440
        c3_p1_cmd_byte_addr             => PrSv_DdrRdCmdAddr_s                  , -- in    std_logic_vector(29 downto 0);
        c3_p1_cmd_empty                 => open                                 , -- out   std_logic;
        c3_p1_cmd_full                  => PrSl_DdrRdCmdFull_s                  , -- out   std_logic;
        c3_p1_wr_clk                    => PrSl_ClkLcd_s                        , -- in    std_logic;
        c3_p1_wr_en                     => '0'                                  , -- in    std_logic;
        c3_p1_wr_mask                   => x"00"                                , -- in    std_logic_vector( 7 downto 0);
        c3_p1_wr_data                   => x"0000000000000000"                  , -- in    std_logic_vector(63 downto 0);
        c3_p1_wr_full                   => open                                 , -- out   std_logic;
        c3_p1_wr_empty                  => open                                 , -- out   std_logic;
        c3_p1_wr_count                  => open                                 , -- out   std_logic_vector( 6 downto 0);
        c3_p1_wr_underrun               => open                                 , -- out   std_logic;
        c3_p1_wr_error                  => open                                 , -- out   std_logic;
        c3_p1_rd_clk                    => PrSl_ClkLcd_s                        , -- in    std_logic;
        c3_p1_rd_en                     => PrSl_DdrRdDataEn_s                   , -- in    std_logic;
        c3_p1_rd_data                   => PrSv_DdrRdData_s                     , -- out   std_logic_vector(63 downto 0);
        c3_p1_rd_full                   => open                                 , -- out   std_logic;
        c3_p1_rd_empty                  => PrSl_DdrRdDataEmpty_s                , -- out   std_logic;
        c3_p1_rd_count                  => PrSv_DdrRdDataCnt_s                  , -- out   std_logic_vector( 6 downto 0);
        c3_p1_rd_overflow               => open                                 , -- out   std_logic;
        c3_p1_rd_error                  => open                                   -- out   std_logic
    );

    ------------------------------------
    -- Clock
    -- clk_out1: 420MHz
    -- clk_out2:  60MHz
    ------------------------------------
    U_M_ClkPll_0 : M_ClkPll port map (
        reset                           => not CpSl_Rst_iN                      , -- in  std_logic;
        clk_in1                         => CpSl_Clk_i                           , -- in  std_logic;
        clk_out1                        => PrSl_ClkFmc_s                        , -- out std_logic;
        clk_out2                        => PrSl_ClkLcd_s                        , -- out std_logic;
        locked                          => PrSl_PllLock_s                         -- out std_logic
    );

    ------------------------------------
    -- Remapper
    ------------------------------------
    U_remapper_0 : remapper port map (
        clock                           => PrSl_ClkLcd_s                        , -- in  std_logic;
        hsync                           => PrSl_Hsync_s                         , -- in  std_logic;
        vsync                           => PrSl_Vsync_s                         , -- in  std_logic;
        r1                              => PrSv_P0Red0_s                        , -- in  std_logic_vector( 11 downto 0);
        r2                              => PrSv_P0Red1_s                        , -- in  std_logic_vector( 11 downto 0);
        r3                              => PrSv_P0Red2_s                        , -- in  std_logic_vector( 11 downto 0);
        r4                              => PrSv_P0Red3_s                        , -- in  std_logic_vector( 11 downto 0);
        g1                              => PrSv_P0Red0_s                        , -- in  std_logic_vector( 11 downto 0);
        g2                              => PrSv_P0Red1_s                        , -- in  std_logic_vector( 11 downto 0);
        g3                              => PrSv_P0Red2_s                        , -- in  std_logic_vector( 11 downto 0);
        g4                              => PrSv_P0Red3_s                        , -- in  std_logic_vector( 11 downto 0);
        b1                              => PrSv_P0Red0_s                        , -- in  std_logic_vector( 11 downto 0);
        b2                              => PrSv_P0Red1_s                        , -- in  std_logic_vector( 11 downto 0);
        b3                              => PrSv_P0Red2_s                        , -- in  std_logic_vector( 11 downto 0);
        b4                              => PrSv_P0Red3_s                        , -- in  std_logic_vector( 11 downto 0);
        pardata                         => open                                 , -- out std_logic_vector( 55 downto 0);
        pardata_h                       => PrSv_P0MatrixH_s                      , -- out std_logic_vector(104 downto 0);
        pardata_l                       => PrSv_P0MatrixL_s                        -- out std_logic_vector( 90 downto 0)
    );

    U_remapper_1 : remapper port map (
        clock                           => PrSl_ClkLcd_s                        , -- in  std_logic;
        hsync                           => PrSl_Hsync_s                         , -- in  std_logic;
        vsync                           => PrSl_Vsync_s                         , -- in  std_logic;
        r1                              => PrSv_P1Red0_s                        , -- in  std_logic_vector( 11 downto 0);
        r2                              => PrSv_P1Red1_s                        , -- in  std_logic_vector( 11 downto 0);
        r3                              => PrSv_P1Red2_s                        , -- in  std_logic_vector( 11 downto 0);
        r4                              => PrSv_P1Red3_s                        , -- in  std_logic_vector( 11 downto 0);
        g1                              => PrSv_P1Red0_s                        , -- in  std_logic_vector( 11 downto 0);
        g2                              => PrSv_P1Red1_s                        , -- in  std_logic_vector( 11 downto 0);
        g3                              => PrSv_P1Red2_s                        , -- in  std_logic_vector( 11 downto 0);
        g4                              => PrSv_P1Red3_s                        , -- in  std_logic_vector( 11 downto 0);
        b1                              => PrSv_P1Red0_s                        , -- in  std_logic_vector( 11 downto 0);
        b2                              => PrSv_P1Red1_s                        , -- in  std_logic_vector( 11 downto 0);
        b3                              => PrSv_P1Red2_s                        , -- in  std_logic_vector( 11 downto 0);
        b4                              => PrSv_P1Red3_s                        , -- in  std_logic_vector( 11 downto 0);
        pardata                         => open                                 , -- out std_logic_vector( 55 downto 0);
        pardata_h                       => PrSv_P1MatrixH_s                     , -- out std_logic_vector(104 downto 0);
        pardata_l                       => PrSv_P1MatrixL_s                       -- out std_logic_vector( 90 downto 0)
    );

    PrSl_Hsync_s  <= PrSl_SimHsync_s when (PrSl_SimSwitch_s = '1') else PrSl_RealHsync_s;
    PrSl_Vsync_s  <= PrSl_SimVsync_s when (PrSl_SimSwitch_s = '1') else PrSl_RealVsync_s;
    PrSv_P0Red0_s <= PrSv_SimRed0_s  when (PrSl_SimSwitch_s = '1') else PrSv_RealRed0_s When (PrSl_PortSel_s = '0') else (others => '0');
    PrSv_P0Red1_s <= PrSv_SimRed1_s  when (PrSl_SimSwitch_s = '1') else PrSv_RealRed1_s When (PrSl_PortSel_s = '0') else (others => '0');
    PrSv_P0Red2_s <= PrSv_SimRed2_s  when (PrSl_SimSwitch_s = '1') else PrSv_RealRed2_s When (PrSl_PortSel_s = '0') else (others => '0');
    PrSv_P0Red3_s <= PrSv_SimRed3_s  when (PrSl_SimSwitch_s = '1') else PrSv_RealRed3_s When (PrSl_PortSel_s = '0') else (others => '0');
    PrSv_P1Red0_s <= PrSv_SimRed0_s  when (PrSl_SimSwitch_s = '1') else PrSv_RealRed0_s When (PrSl_PortSel_s = '1') else (others => '0');
    PrSv_P1Red1_s <= PrSv_SimRed1_s  when (PrSl_SimSwitch_s = '1') else PrSv_RealRed1_s When (PrSl_PortSel_s = '1') else (others => '0');
    PrSv_P1Red2_s <= PrSv_SimRed2_s  when (PrSl_SimSwitch_s = '1') else PrSv_RealRed2_s When (PrSl_PortSel_s = '1') else (others => '0');
    PrSv_P1Red3_s <= PrSv_SimRed3_s  when (PrSl_SimSwitch_s = '1') else PrSv_RealRed3_s When (PrSl_PortSel_s = '1') else (others => '0');

    ----------------------------------------------------------------------------
    -- Display data source
    ----------------------------------------------------------------------------
    PrSl_SimSwitch_s <= '0'; -- 0: Real data, 1: Sim data

    U_M_DisData_0 : M_DisData port map (
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     => PrSl_PllLock_s                       , -- in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      => PrSl_ClkLcd_s                        , -- in  std_logic;                        -- Clock

        --------------------------------
        -- Output signals
        --------------------------------
        CpSl_Hsync_o                    => PrSl_SimHsync_s                      , -- out std_logic;
        CpSl_Vsync_o                    => PrSl_SimVsync_s                      , -- out std_logic;
        CpSv_Red0_o                     => PrSv_SimRed0_s                       , -- out std_logic_vector(11 downto 0);
        CpSv_Red1_o                     => PrSv_SimRed1_s                       , -- out std_logic_vector(11 downto 0);
        CpSv_Red2_o                     => PrSv_SimRed2_s                       , -- out std_logic_vector(11 downto 0);
        CpSv_Red3_o                     => PrSv_SimRed3_s                         -- out std_logic_vector(11 downto 0)
    );

    ------------------------------------
    -- LCD port0
    ------------------------------------
    U_M_HSelectIO_0 : M_HSelectIO port map (
        io_reset                        => '0'                                  , -- in  std_logic;
        clk_in                          => PrSl_ClkFmc_s                        , -- in  std_logic;
        clk_div_in                      => PrSl_ClkLcd_s                        , -- in  std_logic;
        locked_in                       => PrSl_PllLock_s                       , -- in  std_logic;
        data_out_from_device            => PrSv_P0MatrixH_s                     , -- in  std_logic_vector(104 downto 0);
        data_out_to_pins_p              => PrSv_P0MatrixHS_sP                   , -- out std_logic_vector( 14 downto 0);
        data_out_to_pins_n              => PrSv_P0MatrixHS_sN                   , -- out std_logic_vector( 14 downto 0);
        locked_out                      => PrSl_P0MatrixHLock_s                   -- out std_logic
    );

    U_M_LSelectIO_0 : M_LSelectIO port map (
        io_reset                        => '0'                                  , -- in  std_logic;
        clk_in                          => PrSl_ClkFmc_s                        , -- in  std_logic;
        clk_div_in                      => PrSl_ClkLcd_s                        , -- in  std_logic;
        locked_in                       => PrSl_PllLock_s                       , -- in  std_logic;
        data_out_from_device            => PrSv_P0MatrixL_s                     , -- in  std_logic_vector(90 downto 0);
        data_out_to_pins_p              => PrSv_P0MatrixLS_sP                   , -- out std_logic_vector(12 downto 0);
        data_out_to_pins_n              => PrSv_P0MatrixLS_sN                   , -- out std_logic_vector(12 downto 0);
        locked_out                      => PrSl_P0MatrixLLock_s                   -- out std_logic
    );

    FMC0_LA02_P <= PrSv_P0MatrixHS_sP( 0);
    FMC0_LA03_P <= PrSv_P0MatrixHS_sP( 1);
    FMC0_LA04_P <= PrSv_P0MatrixHS_sP( 2);
    FMC0_LA05_P <= PrSv_P0MatrixHS_sP( 3);
    FMC0_LA06_P <= PrSv_P0MatrixHS_sP( 4);
    FMC0_LA07_P <= PrSv_P0MatrixHS_sP( 5);
    FMC0_LA08_P <= PrSv_P0MatrixHS_sP( 6);
    FMC0_LA09_P <= PrSv_P0MatrixHS_sP( 7);
    FMC0_LA10_P <= PrSv_P0MatrixHS_sP( 8);
    FMC0_LA11_P <= PrSv_P0MatrixHS_sP( 9);
    FMC0_LA12_P <= PrSv_P0MatrixHS_sP(10);
    FMC0_LA13_P <= PrSv_P0MatrixHS_sP(11);
    FMC0_LA14_P <= PrSv_P0MatrixHS_sP(12);
    FMC0_LA15_P <= PrSv_P0MatrixHS_sP(13);
    FMC0_LA16_P <= PrSv_P0MatrixHS_sP(14);

    FMC0_LA19_P <= PrSv_P0MatrixLS_sP( 0);
    FMC0_LA20_P <= PrSv_P0MatrixLS_sP( 1);
    FMC0_LA21_P <= PrSv_P0MatrixLS_sP( 2);
    FMC0_LA22_P <= PrSv_P0MatrixLS_sP( 3);
    FMC0_LA23_P <= PrSv_P0MatrixLS_sP( 4);
    FMC0_LA24_P <= PrSv_P0MatrixLS_sP( 5);
    FMC0_LA25_P <= PrSv_P0MatrixLS_sP( 6);
    FMC0_LA26_P <= PrSv_P0MatrixLS_sP( 7);
    FMC0_LA27_P <= PrSv_P0MatrixLS_sP( 8);
    FMC0_LA28_P <= PrSv_P0MatrixLS_sP( 9);
    FMC0_LA29_P <= PrSv_P0MatrixLS_sP(10);
    FMC0_LA30_P <= PrSv_P0MatrixLS_sP(11);
    FMC0_LA31_P <= PrSv_P0MatrixLS_sP(12);

    FMC0_LA32_N <= PrSl_P0MatrixHLock_s and PrSl_P0MatrixLLock_s;
    FMC0_LA_N   <= PrSv_P0MatrixLS_sN     & PrSv_P0MatrixHS_sN  ;

    ------------------------------------
    -- LCD port1
    ------------------------------------
    U_M_HSelectIO_1 : M_HSelectIO port map (
        io_reset                        => '0'                                  , -- in  std_logic;
        clk_in                          => PrSl_ClkFmc_s                        , -- in  std_logic;
        clk_div_in                      => PrSl_ClkLcd_s                        , -- in  std_logic;
        locked_in                       => PrSl_PllLock_s                       , -- in  std_logic;
        data_out_from_device            => PrSv_P1MatrixH_s                     , -- in  std_logic_vector(104 downto 0);
        data_out_to_pins_p              => PrSv_P1MatrixHS_sP                   , -- out std_logic_vector( 14 downto 0);
        data_out_to_pins_n              => PrSv_P1MatrixHS_sN                   , -- out std_logic_vector( 14 downto 0);
        locked_out                      => PrSl_P1MatrixHLock_s                   -- out std_logic
    );

    U_M_LSelectIO_1 : M_LSelectIO port map (
        io_reset                        => '0'                                  , -- in  std_logic;
        clk_in                          => PrSl_ClkFmc_s                        , -- in  std_logic;
        clk_div_in                      => PrSl_ClkLcd_s                        , -- in  std_logic;
        locked_in                       => PrSl_PllLock_s                       , -- in  std_logic;
        data_out_from_device            => PrSv_P1MatrixL_s                     , -- in  std_logic_vector(90 downto 0);
        data_out_to_pins_p              => PrSv_P1MatrixLS_sP                   , -- out std_logic_vector(12 downto 0);
        data_out_to_pins_n              => PrSv_P1MatrixLS_sN                   , -- out std_logic_vector(12 downto 0);
        locked_out                      => PrSl_P1MatrixLLock_s                   -- out std_logic
    );

    FMC1_LA02_P <= PrSv_P1MatrixHS_sP( 0);
    FMC1_LA03_P <= PrSv_P1MatrixHS_sP( 1);
    FMC1_LA04_P <= PrSv_P1MatrixHS_sP( 2);
    FMC1_LA05_P <= PrSv_P1MatrixHS_sP( 3);
    FMC1_LA06_P <= PrSv_P1MatrixHS_sP( 4);
    FMC1_LA07_P <= PrSv_P1MatrixHS_sP( 5);
    FMC1_LA08_P <= PrSv_P1MatrixHS_sP( 6);
    FMC1_LA09_P <= PrSv_P1MatrixHS_sP( 7);
    FMC1_LA10_P <= PrSv_P1MatrixHS_sP( 8);
    FMC1_LA11_P <= PrSv_P1MatrixHS_sP( 9);
    FMC1_LA12_P <= PrSv_P1MatrixHS_sP(10);
    FMC1_LA13_P <= PrSv_P1MatrixHS_sP(11);
    FMC1_LA14_P <= PrSv_P1MatrixHS_sP(12);
    FMC1_LA15_P <= PrSv_P1MatrixHS_sP(13);
    FMC1_LA16_P <= PrSv_P1MatrixHS_sP(14);

    FMC1_LA19_P <= PrSv_P1MatrixLS_sP( 0);
    FMC1_LA20_P <= PrSv_P1MatrixLS_sP( 1);
    FMC1_LA21_P <= PrSv_P1MatrixLS_sP( 2);
    FMC1_LA22_P <= PrSv_P1MatrixLS_sP( 3);
    FMC1_LA23_P <= PrSv_P1MatrixLS_sP( 4);
    FMC1_LA24_P <= PrSv_P1MatrixLS_sP( 5);
    FMC1_LA25_P <= PrSv_P1MatrixLS_sP( 6);
    FMC1_LA26_P <= PrSv_P1MatrixLS_sP( 7);
    FMC1_LA27_P <= PrSv_P1MatrixLS_sP( 8);
    FMC1_LA28_P <= PrSv_P1MatrixLS_sP( 9);
    FMC1_LA29_P <= PrSv_P1MatrixLS_sP(10);
    FMC1_LA30_P <= PrSv_P1MatrixLS_sP(11);
    FMC1_LA31_P <= PrSv_P1MatrixLS_sP(12);

    FMC1_LA32_N <= PrSl_P1MatrixHLock_s and PrSl_P1MatrixLLock_s;
    FMC1_LA_N   <= PrSv_P1MatrixLS_sN     & PrSv_P1MatrixHS_sN  ;

end arch_M_LcdDis;