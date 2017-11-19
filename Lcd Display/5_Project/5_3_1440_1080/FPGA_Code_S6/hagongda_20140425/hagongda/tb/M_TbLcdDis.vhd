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
-- 文件名称  :  M_TbLcdDis.vhd
-- 设    计  :  LIU Hai 
-- 邮    件  :  zheng-jianfeng@139.com
-- 校    对  :  
-- 设计日期  :  2014/04/08
-- 功能简述  :  Testbench for LCD display
-- 版本序号  :  0.1
-- 修改历史  :  1. Initial, LIU Hai, 2014/04/08
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

entity M_TbLcdDis is end M_TbLcdDis;

architecture arch_M_TbLcdDis of M_TbLcdDis is
    ----------------------------------------------------------------------------
    -- constant declaration
    ----------------------------------------------------------------------------

    ----------------------------------------------------------------------------
    -- component declaration
    ----------------------------------------------------------------------------
    component M_LcdDis generic (
        C3_SIMULATION                   : string  := "FALSE"
    );
    port (
        --------------------------------
        -- Clock
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      : in  std_logic;                        -- Clock 200MHz

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
    end component;

    component ddr3_model_c3 port (
        rst_n                           : in    std_logic;
        addr                            : in    std_logic_vector(13 downto 0);
        ba                              : in    std_logic_vector( 2 downto 0);
        ras_n                           : in    std_logic;
        cas_n                           : in    std_logic;
        we_n                            : in    std_logic;
        odt                             : in    std_logic;
        cke                             : in    std_logic;
        ck                              : in    std_logic;
        ck_n                            : in    std_logic;
        cs_n                            : in    std_logic;
        tdqs_n                          : out   std_logic_vector( 1 downto 0);
        dm_tdqs                         : inout std_logic_vector( 1 downto 0);
        dqs                             : inout std_logic_vector( 1 downto 0);
        dqs_n                           : inout std_logic_vector( 1 downto 0);
        dq                              : inout std_logic_vector(15 downto 0)
    );
    end component;

    component M_DviSim port (
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      : in  std_logic;                        -- Clock

        --------------------------------
        -- Output signals
        --------------------------------
        CpSl_DviClk_o                   : out std_logic;                        -- DVI
        CpSl_DviVsync_o                 : out std_logic;                        -- DVI
        CpSl_DviHsync_o                 : out std_logic;                        -- DVI
        CpSl_DviDe_o                    : out std_logic;                        -- DVI
        CpSv_DviR_o                     : out std_logic_vector( 7 downto 0)     -- DVI
    );
    end component;

    ----------------------------------------------------------------------------
    -- signal declaration
    ----------------------------------------------------------------------------
    -- For Global
    signal CpSl_Rst_iN                  : std_logic;
    signal CpSl_Clk_i                   : std_logic;
    signal CpSl_DviClk_i                : std_logic;
    -- For DDR
    signal mcb3_dram_reset_n            : std_logic;                            -- DDR if
    signal mcb3_dram_a                  : std_logic_vector(13 downto 0);        -- DDR if
    signal mcb3_dram_ba                 : std_logic_vector( 2 downto 0);        -- DDR if
    signal mcb3_dram_ras_n              : std_logic;                            -- DDR if
    signal mcb3_dram_cas_n              : std_logic;                            -- DDR if
    signal mcb3_dram_we_n               : std_logic;                            -- DDR if
    signal mcb3_dram_odt                : std_logic;                            -- DDR if
    signal mcb3_dram_cke                : std_logic;                            -- DDR if
    signal mcb3_dram_dm                 : std_logic;                            -- DDR if
    signal mcb3_dram_udm                : std_logic;                            -- DDR if
    signal mcb3_dram_ck                 : std_logic;                            -- DDR if
    signal mcb3_dram_ck_n               : std_logic;                            -- DDR if
    signal mcb3_dram_dqs                : std_logic;                            -- DDR if
    signal mcb3_dram_dqs_n              : std_logic;                            -- DDR if
    signal mcb3_dram_udqs               : std_logic;                            -- DDR if
    signal mcb3_dram_udqs_n             : std_logic;                            -- DDR if
    signal mcb3_dram_dq                 : std_logic_vector(15 downto 0);        -- DDR if
    signal mcb3_rzq                     : std_logic;                            -- DDR if
    signal mcb3_zio                     : std_logic;                            -- DDR if
    signal mcb3_command                 : std_logic_vector( 2 downto 0);        -- DDR model
    signal mcb3_enable1                 : std_logic;                            -- DDR model
    signal mcb3_enable2                 : std_logic;                            -- DDR model
    signal mcb3_dram_dm_vector          : std_logic_vector( 1 downto 0);        -- DDR model
    signal mcb3_dram_dqs_vector         : std_logic_vector( 1 downto 0);        -- DDR model
    signal mcb3_dram_dqs_n_vector       : std_logic_vector( 1 downto 0);        -- DDR model
    signal PrSv_Led_s                   : std_logic_vector( 3 downto 0);        -- DDR
    signal PrSl_Rst_sN                  : std_logic;                            -- Reset inner
    signal PrSl_DviClk_s                : std_logic;                            -- DVI
    signal PrSl_DviVsync_s              : std_logic;                            -- DVI
    signal PrSl_DviHsync_s              : std_logic;                            -- DVI
    signal PrSl_DviDe_s                 : std_logic;                            -- DVI
    signal PrSv_DviR_s                  : std_logic_vector( 7 downto 0);        -- DVI


begin
    ----------------------------------------------------------------------------
    -- Reset & clock
    ----------------------------------------------------------------------------
    CpSl_Rst_iN <= '0', '1' after 200 ns;

    process begin
        CpSl_Clk_i <= '1'; wait for 5 ns;
        CpSl_Clk_i <= '0'; wait for 5 ns;
    end process;

    process begin
        CpSl_DviClk_i <= '1'; wait for 3.0712530712530712530712530712531 ns;
        CpSl_DviClk_i <= '0'; wait for 3.0712530712530712530712530712531 ns;
    end process;

    ----------------------------------------------------------------------------
    -- DUT Instant
    ----------------------------------------------------------------------------
    U_M_LcdDis_0 : M_LcdDis generic map (
        C3_SIMULATION                   => "TRUE"
    )
    port map (
        --------------------------------
        -- Clock
        --------------------------------
        CpSl_Rst_iN                     => CpSl_Rst_iN                          , -- in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      => CpSl_Clk_i                           , -- in  std_logic;                        -- Clock 200MHz

        --------------------------------
        -- DVI & VGA IF
        --------------------------------
--        CpSl_Dvi5VIn_i                  => '1'                                  , -- in  std_logic;                        -- DVI power on
--        CpSl_DviHotPlug_o               => open                                 , -- out std_logic;                        -- DVI hot plug

        CpSl_Dvi0Clk_i                  => PrSl_DviClk_s                        , -- in  std_logic;                        -- DVI port0 clk
        CpSl_Dvi0Vsync_i                => PrSl_DviVsync_s                      , -- in  std_logic;                        -- DVI port0 vsync
        CpSl_Dvi0Hsync_i                => PrSl_DviHsync_s                      , -- in  std_logic;                        -- DVI port0 hsync
        CpSl_Dvi0Scdt_i                 => '0'                                  , -- in  std_logic;                        -- DVI port0 SCDT
        CpSl_Dvi0De_i                   => PrSl_DviDe_s                         , -- in  std_logic;                        -- DVI port0 de
--        CpSv_Dvi0Ctrl_i                 => "000"                                , -- in  std_logic_vector( 2 downto 0);    -- DVI port0 control
        CpSv_Dvi0R_i                    => PrSv_DviR_s                          , -- in  std_logic_vector( 7 downto 0);    -- DVI port0 red
--        CpSv_Dvi0G_i                    => x"00"                                , -- in  std_logic_vector( 7 downto 0);    -- DVI port0 green
--        CpSv_Dvi0B_i                    => x"00"                                , -- in  std_logic_vector( 7 downto 0);    -- DVI port0 blue
--        CpSl_Dvi0Mode_o                 => open                                 , -- out std_logic;                        -- DVI port0 mode
--        CpSl_Dvi0Sclk_o                 => open                                 , -- out std_logic;                        -- DVI port0 I2C clk
--        CpSl_Dvi0Sdata_o                => open                                 , -- out std_logic;                        -- DVI port0 I2C data
--        CpSl_Dvi0HsDjtr_o               => open                                 , -- out std_logic;                        -- DVI port0 HS-DJTR
--        CpSl_Dvi0Pd_o                   => open                                 , -- out std_logic;                        -- DVI port0 power down

--        CpSl_Dvi1Clk_i                  => '0'                                  , -- in  std_logic;                        -- DVI port1 clk
--        CpSl_Dvi1Vsync_i                => '0'                                  , -- in  std_logic;                        -- DVI port1 vsync
--        CpSl_Dvi1Hsync_i                => '0'                                  , -- in  std_logic;                        -- DVI port1 hsync
--        CpSl_Dvi1Scdt_i                 => '0'                                  , -- in  std_logic;                        -- DVI port1 SCDT
--        CpSl_Dvi1De_i                   => '0'                                  , -- in  std_logic;                        -- DVI port1 de
--        CpSv_Dvi1Ctrl_i                 => "000"                                , -- in  std_logic_vector( 2 downto 0);    -- DVI port1 control
--        CpSv_Dvi1R_i                    => x"00"                                , -- in  std_logic_vector( 7 downto 0);    -- DVI port1 red
--        CpSv_Dvi1G_i                    => x"00"                                , -- in  std_logic_vector( 7 downto 0);    -- DVI port1 green
--        CpSv_Dvi1B_i                    => x"00"                                , -- in  std_logic_vector( 7 downto 0);    -- DVI port1 blue
--        CpSl_Dvi1Mode_o                 => open                                 , -- out std_logic;                        -- DVI port1 mode
--        CpSl_Dvi1Sclk_o                 => open                                 , -- out std_logic;                        -- DVI port1 I2C clk
--        CpSl_Dvi1Sdata_o                => open                                 , -- out std_logic;                        -- DVI port1 I2C data
--        CpSl_Dvi1HsDjtr_o               => open                                 , -- out std_logic;                        -- DVI port1 HS-DJTR
--        CpSl_Dvi1Pd_o                   => open                                 , -- out std_logic;                        -- DVI port1 power down

--        CpSl_VgaClk_iP                  => '0'                                  , -- in  std_logic;                        -- VGA clk P
--        CpSl_VgaClk_iN                  => '0'                                  , -- in  std_logic;                        -- VGA clk N
--        CpSl_VgaVsync_i                 => '0'                                  , -- in  std_logic;                        -- VGA vsync
--        CpSl_VgaHsync_i                 => '0'                                  , -- in  std_logic;                        -- VGA hsync
--        CpSl_VgaGsync_i                 => '0'                                  , -- in  std_logic;                        -- VGA gsync
--        CpSl_VgaDe_i                    => '0'                                  , -- in  std_logic;                        -- VGA de
--        CpSv_VgaR_i                     => x"00"                                , -- in  std_logic_vector( 7 downto 0);    -- VGA red
--        CpSv_VgaG_i                     => x"00"                                , -- in  std_logic_vector( 7 downto 0);    -- VGA green
--        CpSv_VgaB_i                     => x"00"                                , -- in  std_logic_vector( 7 downto 0);    -- VGA blue
--        CpSl_VgaCoast_o                 => open                                 , -- out std_logic;                        -- VGA coast
--        CpSl_VgaSclk_o                  => open                                 , -- out std_logic;                        -- VGA I2C clk
--        CpSl_VgaSdata_o                 => open                                 , -- out std_logic;                        -- VGA I2C data
--        CpSl_VgaClamp_o                 => open                                 , -- out std_logic;                        -- VGA CLAMP
--        CpSl_VgaClkInv_o                => open                                 , -- out std_logic;                        -- VGA clk inv

        --------------------------------
        -- GPIO & LED & Test IF
        --------------------------------
        CpSv_Gpio_i                     => x"00"                                , -- in  std_logic_vector( 7 downto 0);    -- GPIO in
        CpSv_Gpio_o                     => open                                 , -- out std_logic_vector( 7 downto 0);    -- GPIO out
        CpSv_Led_o                      => PrSv_Led_s                           , -- out std_logic_vector( 3 downto 0);    -- LED out
--        CpSv_Test_o                     => open                                 , -- out std_logic_vector( 9 downto 0);    -- Test out

        --------------------------------
        -- FMC IF
        --------------------------------
--        FMC0_M2C_i                      => '1'                                  , -- in  std_logic;                        -- Port 0 m2c
--        FMC0_C2M_o                      => open                                 , -- out std_logic;                        -- Port 0 c2m
--        FMC0_Sclk_o                     => open                                 , -- out std_logic;                        -- Port 0 I2C clk
--        FMC0_Sdata_o                    => open                                 , -- out std_logic;                        -- Port 0 I2C data
        FMC0_LA02_P                     => open                                 , -- out std_logic;                        -- Port 0 FMC_LA02_P
        FMC0_LA03_P                     => open                                 , -- out std_logic;                        -- Port 0 FMC_LA03_P
        FMC0_LA04_P                     => open                                 , -- out std_logic;                        -- Port 0 FMC_LA04_P
        FMC0_LA05_P                     => open                                 , -- out std_logic;                        -- Port 0 FMC_LA05_P
        FMC0_LA06_P                     => open                                 , -- out std_logic;                        -- Port 0 FMC_LA06_P
        FMC0_LA07_P                     => open                                 , -- out std_logic;                        -- Port 0 FMC_LA07_P
        FMC0_LA08_P                     => open                                 , -- out std_logic;                        -- Port 0 FMC_LA08_P
        FMC0_LA09_P                     => open                                 , -- out std_logic;                        -- Port 0 FMC_LA09_P
        FMC0_LA10_P                     => open                                 , -- out std_logic;                        -- Port 0 FMC_LA10_P
        FMC0_LA11_P                     => open                                 , -- out std_logic;                        -- Port 0 FMC_LA11_P
        FMC0_LA12_P                     => open                                 , -- out std_logic;                        -- Port 0 FMC_LA12_P
        FMC0_LA13_P                     => open                                 , -- out std_logic;                        -- Port 0 FMC_LA13_P
        FMC0_LA14_P                     => open                                 , -- out std_logic;                        -- Port 0 FMC_LA14_P
        FMC0_LA15_P                     => open                                 , -- out std_logic;                        -- Port 0 FMC_LA15_P
        FMC0_LA16_P                     => open                                 , -- out std_logic;                        -- Port 0 FMC_LA16_P
        FMC0_LA19_P                     => open                                 , -- out std_logic;                        -- Port 0 FMC_LA19_P
        FMC0_LA20_P                     => open                                 , -- out std_logic;                        -- Port 0 FMC_LA20_P
        FMC0_LA21_P                     => open                                 , -- out std_logic;                        -- Port 0 FMC_LA21_P
        FMC0_LA22_P                     => open                                 , -- out std_logic;                        -- Port 0 FMC_LA22_P
        FMC0_LA23_P                     => open                                 , -- out std_logic;                        -- Port 0 FMC_LA23_P
        FMC0_LA24_P                     => open                                 , -- out std_logic;                        -- Port 0 FMC_LA24_P
        FMC0_LA25_P                     => open                                 , -- out std_logic;                        -- Port 0 FMC_LA25_P
        FMC0_LA26_P                     => open                                 , -- out std_logic;                        -- Port 0 FMC_LA26_P
        FMC0_LA27_P                     => open                                 , -- out std_logic;                        -- Port 0 FMC_LA27_P
        FMC0_LA28_P                     => open                                 , -- out std_logic;                        -- Port 0 FMC_LA28_P
        FMC0_LA29_P                     => open                                 , -- out std_logic;                        -- Port 0 FMC_LA29_P
        FMC0_LA30_P                     => open                                 , -- out std_logic;                        -- Port 0 FMC_LA30_P
        FMC0_LA31_P                     => open                                 , -- out std_logic;                        -- Port 0 FMC_LA31_P
        FMC0_LA32_N                     => open                                 , -- out std_logic;                        -- Port 0 FMC_LA32_N
        FMC0_LA_N                       => open                                 , -- out std_logic_vector(27 downto 0);    -- Port 0 FMC_N

--        FMC1_M2C_i                      => '1'                                  , -- in  std_logic;                        -- Port 1 m2c
--        FMC1_C2M_o                      => open                                 , -- out std_logic;                        -- Port 1 c2m
--        FMC1_Sclk_o                     => open                                 , -- out std_logic;                        -- Port 1 I2C clk
--        FMC1_Sdata_o                    => open                                 , -- out std_logic;                        -- Port 1 I2C data
        FMC1_LA02_P                     => open                                 , -- out std_logic;                        -- Port 1 FMC_LA02_P
        FMC1_LA03_P                     => open                                 , -- out std_logic;                        -- Port 1 FMC_LA03_P
        FMC1_LA04_P                     => open                                 , -- out std_logic;                        -- Port 1 FMC_LA04_P
        FMC1_LA05_P                     => open                                 , -- out std_logic;                        -- Port 1 FMC_LA05_P
        FMC1_LA06_P                     => open                                 , -- out std_logic;                        -- Port 1 FMC_LA06_P
        FMC1_LA07_P                     => open                                 , -- out std_logic;                        -- Port 1 FMC_LA07_P
        FMC1_LA08_P                     => open                                 , -- out std_logic;                        -- Port 1 FMC_LA08_P
        FMC1_LA09_P                     => open                                 , -- out std_logic;                        -- Port 1 FMC_LA09_P
        FMC1_LA10_P                     => open                                 , -- out std_logic;                        -- Port 1 FMC_LA10_P
        FMC1_LA11_P                     => open                                 , -- out std_logic;                        -- Port 1 FMC_LA11_P
        FMC1_LA12_P                     => open                                 , -- out std_logic;                        -- Port 1 FMC_LA12_P
        FMC1_LA13_P                     => open                                 , -- out std_logic;                        -- Port 1 FMC_LA13_P
        FMC1_LA14_P                     => open                                 , -- out std_logic;                        -- Port 1 FMC_LA14_P
        FMC1_LA15_P                     => open                                 , -- out std_logic;                        -- Port 1 FMC_LA15_P
        FMC1_LA16_P                     => open                                 , -- out std_logic;                        -- Port 1 FMC_LA16_P
        FMC1_LA19_P                     => open                                 , -- out std_logic;                        -- Port 1 FMC_LA19_P
        FMC1_LA20_P                     => open                                 , -- out std_logic;                        -- Port 1 FMC_LA20_P
        FMC1_LA21_P                     => open                                 , -- out std_logic;                        -- Port 1 FMC_LA21_P
        FMC1_LA22_P                     => open                                 , -- out std_logic;                        -- Port 1 FMC_LA22_P
        FMC1_LA23_P                     => open                                 , -- out std_logic;                        -- Port 1 FMC_LA23_P
        FMC1_LA24_P                     => open                                 , -- out std_logic;                        -- Port 1 FMC_LA24_P
        FMC1_LA25_P                     => open                                 , -- out std_logic;                        -- Port 1 FMC_LA25_P
        FMC1_LA26_P                     => open                                 , -- out std_logic;                        -- Port 1 FMC_LA26_P
        FMC1_LA27_P                     => open                                 , -- out std_logic;                        -- Port 1 FMC_LA27_P
        FMC1_LA28_P                     => open                                 , -- out std_logic;                        -- Port 1 FMC_LA28_P
        FMC1_LA29_P                     => open                                 , -- out std_logic;                        -- Port 1 FMC_LA29_P
        FMC1_LA30_P                     => open                                 , -- out std_logic;                        -- Port 1 FMC_LA30_P
        FMC1_LA31_P                     => open                                 , -- out std_logic;                        -- Port 1 FMC_LA31_P
        FMC1_LA32_N                     => open                                 , -- out std_logic;                        -- Port 1 FMC_LA32_N
        FMC1_LA_N                       => open                                 , -- out std_logic_vector(27 downto 0);    -- Port 1 FMC_N

        --------------------------------
        -- DDR IF
        --------------------------------
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
        mcb3_zio                        => mcb3_zio                               -- inout std_logic
    );

    -- The PULLDOWN component is connected to the ZIO signal primarily to avoid the
    -- unknown state in simulation. In real hardware, ZIO should be a no connect(NC) pin.
    zio_pulldown3 : PULLDOWN port map(O => mcb3_zio);
    rzq_pulldown3 : PULLDOWN port map(O => mcb3_rzq);

    ----------------------------------------------------------------------------
    -- DDR model
    ----------------------------------------------------------------------------
    mcb3_command <= (mcb3_dram_ras_n & mcb3_dram_cas_n & mcb3_dram_we_n);

    process (mcb3_dram_ck) begin
        if rising_edge(mcb3_dram_ck) then
            mcb3_enable1 <= mcb3_enable2;
            if (CpSl_Rst_iN = '0') then
                mcb3_enable1 <= '0';
                mcb3_enable2 <= '0';
            elsif (mcb3_command = "100") then
                mcb3_enable2 <= '0';
            elsif (mcb3_command = "101") then
                mcb3_enable2 <= '1';
            else
                mcb3_enable2 <= mcb3_enable2;
            end if;
        end if;
    end process;

    mcb3_dram_dm_vector <= (mcb3_dram_udm & mcb3_dram_dm);

    ------------------------------------
    -- Read
    ------------------------------------
    mcb3_dram_dqs_vector( 1 downto 0)  <= (mcb3_dram_udqs   & mcb3_dram_dqs  ) when (mcb3_enable2 = '0' and mcb3_enable1 = '0') else "ZZ";
    mcb3_dram_dqs_n_vector(1 downto 0) <= (mcb3_dram_udqs_n & mcb3_dram_dqs_n) when (mcb3_enable2 = '0' and mcb3_enable1 = '0') else "ZZ";

    ------------------------------------
    -- Write
    ------------------------------------
    mcb3_dram_dqs    <= mcb3_dram_dqs_vector(0)   when (mcb3_enable1 = '1') else 'Z';
    mcb3_dram_udqs   <= mcb3_dram_dqs_vector(1)   when (mcb3_enable1 = '1') else 'Z';
    mcb3_dram_dqs_n  <= mcb3_dram_dqs_n_vector(0) when (mcb3_enable1 = '1') else 'Z';
    mcb3_dram_udqs_n <= mcb3_dram_dqs_n_vector(1) when (mcb3_enable1 = '1') else 'Z';

    U_ddr3_model_c3_0 : ddr3_model_c3 port map (
        rst_n                           => mcb3_dram_reset_n                    , -- in    std_logic;
        addr                            => mcb3_dram_a                          , -- in    std_logic_vector(13 downto 0);
        ba                              => mcb3_dram_ba                         , -- in    std_logic_vector( 2 downto 0);
        ras_n                           => mcb3_dram_ras_n                      , -- in    std_logic;
        cas_n                           => mcb3_dram_cas_n                      , -- in    std_logic;
        we_n                            => mcb3_dram_we_n                       , -- in    std_logic;
        odt                             => mcb3_dram_odt                        , -- in    std_logic;
        cke                             => mcb3_dram_cke                        , -- in    std_logic;
        ck                              => mcb3_dram_ck                         , -- in    std_logic;
        ck_n                            => mcb3_dram_ck_n                       , -- in    std_logic;
        cs_n                            => '0'                                  , -- in    std_logic;
        tdqs_n                          => open                                 , -- out   std_logic_vector( 1 downto 0);
        dm_tdqs                         => mcb3_dram_dm_vector                  , -- inout std_logic_vector( 1 downto 0);
        dqs                             => mcb3_dram_dqs_vector                 , -- inout std_logic_vector( 1 downto 0);
        dqs_n                           => mcb3_dram_dqs_n_vector               , -- inout std_logic_vector( 1 downto 0);
        dq                              => mcb3_dram_dq                           -- inout std_logic_vector(15 downto 0)
    );

    ----------------------------------------------------------------------------
    -- DVI model
    ----------------------------------------------------------------------------
    PrSl_Rst_sN <= not PrSv_Led_s(0);
    U_M_DviSim_0 : M_DviSim port map (
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     => PrSl_Rst_sN                          , -- in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      => CpSl_DviClk_i                        , -- in  std_logic;                        -- Clock

        --------------------------------
        -- Output signals 
        --------------------------------
        CpSl_DviClk_o                   => PrSl_DviClk_s                        , -- out std_logic;                        -- DVI
        CpSl_DviVsync_o                 => PrSl_DviVsync_s                      , -- out std_logic;                        -- DVI
        CpSl_DviHsync_o                 => PrSl_DviHsync_s                      , -- out std_logic;                        -- DVI
        CpSl_DviDe_o                    => PrSl_DviDe_s                         , -- out std_logic;                        -- DVI
        CpSv_DviR_o                     => PrSv_DviR_s                            -- out std_logic_vector( 7 downto 0)     -- DVI
    );

end arch_M_TbLcdDis;