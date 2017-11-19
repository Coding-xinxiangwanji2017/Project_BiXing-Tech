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
-- 文件名称  :  M_Tb.vhd
-- 设    计  :  LIU Hai
-- 邮    件  :  zheng-jianfeng@139.com
-- 校    对  :
-- 设计日期  :  2016/01/22
-- 功能简述  :  Testbench
-- 版本序号  :  0.1
-- 修改历史  :  1. Initial, LIU Hai, 2016/01/22
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity M_Tb is end M_Tb;

architecture arch_M_Tb of M_Tb is
    ----------------------------------------------------------------------------
    -- constant declaration
    ----------------------------------------------------------------------------

    ----------------------------------------------------------------------------
    -- component declaration
    ----------------------------------------------------------------------------
    component M_Lcd4Top port (
        --------------------------------
        -- Reset, Clock and LED
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      : in  std_logic;                        -- Clock 100MHz, single
        CpSl_Clk_iP                     : in  std_logic;                        -- Clock 200MHz, diff
        CpSl_Clk_iN                     : in  std_logic;                        -- Clock 200MHz, diff
        CpSv_Led_o                      : out std_logic_vector( 3 downto 0);    -- LED out
        CpSv_Sma_o                      : out std_logic_vector( 3 downto 0);    -- SMA out
        CpSv_Gpio_o                     : out std_logic_vector( 4 downto 0);    -- GPIO out

        --------------------------------
        -- DVI
        --------------------------------
        CpSl_Dvi0Clk_i                  : in  std_logic;                        -- DVI clk
        CpSl_Dvi0Vsync_i                : in  std_logic;                        -- DVI vsync
        CpSl_Dvi0Hsync_i                : in  std_logic;                        -- DVI hsync
        CpSl_Dvi0De_i                   : in  std_logic;                        -- DVI de
        CpSl_Dvi0Scdt_i                 : in  std_logic;                        -- DVI SCDT
        CpSv_Dvi0R_i                    : in  std_logic_vector( 7 downto 0);    -- DVI red
        CpSl_Dvi1Scdt_i                 : in  std_logic;                        -- DVI SCDT
        CpSv_Dvi1R_i                    : in  std_logic_vector( 7 downto 0);    -- DVI red

        --------------------------------
        -- FMC IF
        --------------------------------
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
        ddr3_dq                         : inout std_logic_vector(15 downto 0);
        ddr3_dqs_p                      : inout std_logic_vector( 1 downto 0);
        ddr3_dqs_n                      : inout std_logic_vector( 1 downto 0);
        ddr3_addr                       : out   std_logic_vector(14 downto 0);
        ddr3_ba                         : out   std_logic_vector( 2 downto 0);
        ddr3_ras_n                      : out   std_logic;
        ddr3_cas_n                      : out   std_logic;
        ddr3_we_n                       : out   std_logic;
        ddr3_reset_n                    : out   std_logic;
        ddr3_ck_p                       : out   std_logic_vector( 0 downto 0);
        ddr3_ck_n                       : out   std_logic_vector( 0 downto 0);
        ddr3_cke                        : out   std_logic_vector( 0 downto 0);
        ddr3_cs_n                       : out   std_logic_vector( 0 downto 0);
        ddr3_dm                         : out   std_logic_vector( 1 downto 0);
        ddr3_odt                        : out   std_logic_vector( 0 downto 0)
    );
    end component;

    component ddr3_model is port (
        rst_n                           : in    std_logic;
        ck                              : in    std_logic;
        ck_n                            : in    std_logic;
        cke                             : in    std_logic;
        cs_n                            : in    std_logic;
        ras_n                           : in    std_logic;
        cas_n                           : in    std_logic;
        we_n                            : in    std_logic;
        dm_tdqs                         : inout std_logic_vector( 1 downto 0);
        ba                              : in    std_logic_vector( 2 downto 0);
        addr                            : in    std_logic_vector(14 downto 0);
        dq                              : inout std_logic_vector(15 downto 0);
        dqs                             : inout std_logic_vector( 1 downto 0);
        dqs_n                           : inout std_logic_vector( 1 downto 0);
        tdqs_n                          : out   std_logic_vector( 1 downto 0);
        odt                             : in    std_logic
    );
    end component;

    ----------------------------------------------------------------------------
    -- signal declaration
    ----------------------------------------------------------------------------
    signal CpSl_Rst_iN                  : std_logic;
    signal CpSl_Clk_i                   : std_logic;
    signal CpSl_Clk_iP                  : std_logic;
    signal CpSl_Clk_iN                  : std_logic;
    signal ddr3_dq                      : std_logic_vector(15 downto 0);
    signal ddr3_dqs_p                   : std_logic_vector( 1 downto 0);
    signal ddr3_dqs_n                   : std_logic_vector( 1 downto 0);
    signal ddr3_addr                    : std_logic_vector(14 downto 0);
    signal ddr3_ba                      : std_logic_vector( 2 downto 0);
    signal ddr3_ras_n                   : std_logic;
    signal ddr3_cas_n                   : std_logic;
    signal ddr3_we_n                    : std_logic;
    signal ddr3_reset_n                 : std_logic;
    signal ddr3_ck_p                    : std_logic_vector( 0 downto 0);
    signal ddr3_ck_n                    : std_logic_vector( 0 downto 0);
    signal ddr3_cke                     : std_logic_vector( 0 downto 0);
    signal ddr3_cs_n                    : std_logic_vector( 0 downto 0);
    signal ddr3_dm                      : std_logic_vector( 1 downto 0);
    signal ddr3_odt                     : std_logic_vector( 0 downto 0);


begin
    ----------------------------------------------------------------------------
    -- Reset & clock
    ----------------------------------------------------------------------------
    process begin
        CpSl_Rst_iN <= '0'; wait for 120 ns; CpSl_Rst_iN <= '1'; wait;
    end process;

    process begin
        CpSl_Clk_i <= '1'; wait for 5 ns; CpSl_Clk_i <= '0'; wait for 5 ns;
    end process;

    process begin
        CpSl_Clk_iN <= '1'; wait for 2.5 ns; CpSl_Clk_iN <= '0'; wait for 2.5 ns;
    end process;

    CpSl_Clk_iP <= not CpSl_Clk_iN;

    ----------------------------------------------------------------------------
    -- Other input
    ----------------------------------------------------------------------------

    ----------------------------------------------------------------------------
    -- Instance
    ----------------------------------------------------------------------------
    U_M_DdrIf_0 : M_DdrIf port map (M_Lcd4Top port (
        --------------------------------
        -- Reset, Clock and LED
        --------------------------------
        CpSl_Rst_iN                     => CpSl_Rst_iN                          , -- in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      => CpSl_Clk_i                           , -- in  std_logic;                        -- Clock 100MHz, single
        CpSl_Clk_iP                     => CpSl_Clk_iP                          , -- in  std_logic;                        -- Clock 200MHz, diff
        CpSl_Clk_iN                     => CpSl_Clk_iN                          , -- in  std_logic;                        -- Clock 200MHz, diff
        CpSv_Led_o                      => open                                 , -- out std_logic_vector( 3 downto 0);    -- LED out
        CpSv_Sma_o                      => open                                 , -- out std_logic_vector( 3 downto 0);    -- SMA out
        CpSv_Gpio_o                     => open                                 , -- out std_logic_vector( 4 downto 0);    -- GPIO out

        --------------------------------
        -- DVI
        --------------------------------
        CpSl_Dvi0Clk_i                  : in  std_logic;                        -- DVI clk
        CpSl_Dvi0Vsync_i                : in  std_logic;                        -- DVI vsync
        CpSl_Dvi0Hsync_i                : in  std_logic;                        -- DVI hsync
        CpSl_Dvi0De_i                   : in  std_logic;                        -- DVI de
        CpSl_Dvi0Scdt_i                 : in  std_logic;                        -- DVI SCDT
        CpSv_Dvi0R_i                    : in  std_logic_vector( 7 downto 0);    -- DVI red
        CpSl_Dvi1Scdt_i                 : in  std_logic;                        -- DVI SCDT
        CpSv_Dvi1R_i                    : in  std_logic_vector( 7 downto 0);    -- DVI red

        --------------------------------
        -- FMC IF
        --------------------------------
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
        ddr3_dq                         => ddr3_dq                              , -- inout std_logic_vector(15 downto 0);
        ddr3_dqs_p                      => ddr3_dqs_p                           , -- inout std_logic_vector( 1 downto 0);
        ddr3_dqs_n                      => ddr3_dqs_n                           , -- inout std_logic_vector( 1 downto 0);
        ddr3_addr                       => ddr3_addr                            , -- out   std_logic_vector(14 downto 0);
        ddr3_ba                         => ddr3_ba                              , -- out   std_logic_vector( 2 downto 0);
        ddr3_ras_n                      => ddr3_ras_n                           , -- out   std_logic;
        ddr3_cas_n                      => ddr3_cas_n                           , -- out   std_logic;
        ddr3_we_n                       => ddr3_we_n                            , -- out   std_logic;
        ddr3_reset_n                    => ddr3_reset_n                         , -- out   std_logic;
        ddr3_ck_p                       => ddr3_ck_p                            , -- out   std_logic_vector( 0 downto 0);
        ddr3_ck_n                       => ddr3_ck_n                            , -- out   std_logic_vector( 0 downto 0);
        ddr3_cke                        => ddr3_cke                             , -- out   std_logic_vector( 0 downto 0);
        ddr3_cs_n                       => ddr3_cs_n                            , -- out   std_logic_vector( 0 downto 0);
        ddr3_dm                         => ddr3_dm                              , -- out   std_logic_vector( 1 downto 0);
        ddr3_odt                        => ddr3_odt                               -- out   std_logic_vector( 0 downto 0)
    );

    gen_mem : for i in 0 to 0 generate
        u_comp_ddr3 : ddr3_model port map(
            rst_n   => ddr3_reset_n                                             ,
            ck      => ddr3_ck_p((i*16)/64)                                     ,
            ck_n    => ddr3_ck_n((i*16)/64)                                     ,
            cke     => ddr3_cke((i*16)/64)                                      ,
            cs_n    => ddr3_cs_n((i*16)/64)                                     ,
            ras_n   => ddr3_ras_n                                               ,
            cas_n   => ddr3_cas_n                                               ,
            we_n    => ddr3_we_n                                                ,
            dm_tdqs => ddr3_dm((2*(i+1)-1) downto (2*i))                        ,
            ba      => ddr3_ba                                                  ,
            addr    => ddr3_addr                                                ,
            dq      => ddr3_dq(16*(i+1)-1 downto 16*(i))                        ,
            dqs     => ddr3_dqs_p((2*(i+1)-1) downto (2*i))                     ,
            dqs_n   => ddr3_dqs_n((2*(i+1)-1) downto (2*i))                     ,
            tdqs_n  => open                                                     ,
            odt     => ddr3_odt((i*16)/64)
        );
    end generate gen_mem;

end arch_M_Tb;