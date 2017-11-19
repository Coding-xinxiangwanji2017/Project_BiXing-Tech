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
-- 文件名称  :  M_Lcd4Top.vhd
-- 设    计  :  LIU Hai
-- 邮    件  :  liuwanghao@139.com
-- 校    对  :
-- 设计日期  :  2015/11/16
-- 功能简述  :  LCD4 top entity
-- 版本序号  :  0.1
-- 修改历史  :  1. Initial, LIU Hai, 2015/11/16
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

entity M_Lcd4Top_tb is

end M_Lcd4Top_tb;

architecture arch_M_Lcd4Top_tb of M_Lcd4Top_tb is
    ----------------------------------------------------------------------------
    -- constant declaration
    ----------------------------------------------------------------------------
    constant Refresh_Rate : integer := 100;                                     -- 100Hz refresh rate
    
    ----------------------------------------------------------------------------
    -- component declaration
    ----------------------------------------------------------------------------
    component M_Lcd4Top 
    generic (
        --------------------------------
        -- Refresh Rate : 100Hz/67Hz
        --------------------------------
        Refresh_Rate     : integer := 100  
    );
    port (
        --------------------------------
        -- Reset, Clock and LED
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      : in  std_logic;                        -- Clock 100MHz, single
        CpSl_Clk_iP                     : in  std_logic;                        -- Clock 200MHz, diff
        CpSl_Clk_iN                     : in  std_logic;                        -- Clock 200MHz, diff
        CpSv_Led_o                      : out std_logic_vector( 3 downto 0);    -- LED out
        CpSv_Sma_o                      : out std_logic_vector( 3 downto 0);    -- SMA out
        CpSl_Gpio_o                     : out std_logic;                        -- GPIO out
        CpSl_Test_o                     : out std_logic;                        -- pulse 1s
        CpSl_ExtVsync_i                 : in  std_logic;                        -- Sync in (V Sync)
        CpSl_ChoiceVsync_i              : in  std_logic;                        -- Choice Ext or Int Vsync
        CpSl_ExtVld_o                   : out std_logic;                        -- Ext or Int indication

        --------------------------------
        -- DVI
        --------------------------------
        CpSl_Dvi0Clk_i                  : in  std_logic;                        -- DVI clk
        CpSl_Dvi0Vsync_i                : in  std_logic;                        -- DVI vsync
        CpSl_Dvi0Hsync_i                : in  std_logic;                        -- DVI hsync
        CpSl_Dvi0Scdt_i                 : in  std_logic;                        -- DVI SCDT
        CpSl_Dvi0De_i                   : in  std_logic;                        -- DVI de
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
        
    ------------------------------------
    -- DDR3 module 
    ------------------------------------
    component ddr3_model port (
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
    signal CpSl_Rst_iN                     : std_logic                       := '0'; -- Reset, active low
    signal CpSl_Clk_i                      : std_logic                       := '0'; -- Clock 100MHz, single
    signal CpSl_Clk_iP                     : std_logic                       := '0'; -- Clock 200MHz, diff
    signal CpSl_Clk_iN                     : std_logic                       := '0'; -- Clock 200MHz, diff
    signal CpSv_Led_o                      : std_logic_vector( 3 downto 0)   := (others =>'0'); -- LED out
    signal CpSv_Sma_o                      : std_logic_vector( 3 downto 0)   := (others =>'0'); -- SMA out
    signal CpSl_Gpio_o                     : std_logic                       := '0'; -- GPIO out
    signal CpSl_Test_o                     : std_logic                       := '0'; -- pulse 1s
    signal CpSl_ExtVsync_i                 : std_logic                       := '0'; -- Sync in (V Sync)
    signal CpSl_ChoiceVsync_i              : std_logic                       := '0'; -- Choice Ext or Int Vsync
    signal CpSl_ExtVld_o                   : std_logic                       := '0'; -- Ext or Int indication
    signal CpSl_Dvi0Clk_i                  : std_logic                       := '0'; -- DVI clk
    signal CpSl_Dvi0Vsync_i                : std_logic                       := '0'; -- DVI vsync
    signal CpSl_Dvi0Hsync_i                : std_logic                       := '0'; -- DVI hsync
    signal CpSl_Dvi0Scdt_i                 : std_logic                       := '0'; -- DVI SCDT
    signal CpSl_Dvi0De_i                   : std_logic                       := '0'; -- DVI de
    signal CpSv_Dvi0R_i                    : std_logic_vector( 7 downto 0)   := (others =>'0'); -- DVI red
    signal CpSl_Dvi1Scdt_i                 : std_logic                       := '0'; -- DVI SCDT
    signal CpSv_Dvi1R_i                    : std_logic_vector( 7 downto 0)   := (others =>'0'); -- DVI red
    signal FMC0_LA02_P                     : std_logic                       := '0'; -- Port 0 FMC_LA02_P
    signal FMC0_LA03_P                     : std_logic                       := '0'; -- Port 0 FMC_LA03_P
    signal FMC0_LA04_P                     : std_logic                       := '0'; -- Port 0 FMC_LA04_P
    signal FMC0_LA05_P                     : std_logic                       := '0'; -- Port 0 FMC_LA05_P
    signal FMC0_LA06_P                     : std_logic                       := '0'; -- Port 0 FMC_LA06_P
    signal FMC0_LA07_P                     : std_logic                       := '0'; -- Port 0 FMC_LA07_P
    signal FMC0_LA08_P                     : std_logic                       := '0'; -- Port 0 FMC_LA08_P
    signal FMC0_LA09_P                     : std_logic                       := '0'; -- Port 0 FMC_LA09_P
    signal FMC0_LA10_P                     : std_logic                       := '0'; -- Port 0 FMC_LA10_P
    signal FMC0_LA11_P                     : std_logic                       := '0'; -- Port 0 FMC_LA11_P
    signal FMC0_LA12_P                     : std_logic                       := '0'; -- Port 0 FMC_LA12_P
    signal FMC0_LA13_P                     : std_logic                       := '0'; -- Port 0 FMC_LA13_P
    signal FMC0_LA14_P                     : std_logic                       := '0'; -- Port 0 FMC_LA14_P
    signal FMC0_LA15_P                     : std_logic                       := '0'; -- Port 0 FMC_LA15_P
    signal FMC0_LA16_P                     : std_logic                       := '0'; -- Port 0 FMC_LA16_P
    signal FMC0_LA19_P                     : std_logic                       := '0'; -- Port 0 FMC_LA19_P
    signal FMC0_LA20_P                     : std_logic                       := '0'; -- Port 0 FMC_LA20_P
    signal FMC0_LA21_P                     : std_logic                       := '0'; -- Port 0 FMC_LA21_P
    signal FMC0_LA22_P                     : std_logic                       := '0'; -- Port 0 FMC_LA22_P
    signal FMC0_LA23_P                     : std_logic                       := '0'; -- Port 0 FMC_LA23_P
    signal FMC0_LA24_P                     : std_logic                       := '0'; -- Port 0 FMC_LA24_P
    signal FMC0_LA25_P                     : std_logic                       := '0'; -- Port 0 FMC_LA25_P
    signal FMC0_LA26_P                     : std_logic                       := '0'; -- Port 0 FMC_LA26_P
    signal FMC0_LA27_P                     : std_logic                       := '0'; -- Port 0 FMC_LA27_P
    signal FMC0_LA28_P                     : std_logic                       := '0'; -- Port 0 FMC_LA28_P
    signal FMC0_LA29_P                     : std_logic                       := '0'; -- Port 0 FMC_LA29_P
    signal FMC0_LA30_P                     : std_logic                       := '0'; -- Port 0 FMC_LA30_P
    signal FMC0_LA31_P                     : std_logic                       := '0'; -- Port 0 FMC_LA31_P
    signal FMC0_LA32_N                     : std_logic                       := '0'; -- Port 0 FMC_LA32_N
    signal FMC0_LA_N                       : std_logic_vector(27 downto 0)   := (others =>'0'); -- Port 0 FMC_N
    signal FMC1_LA02_P                     : std_logic                       := '0'; -- Port 1 FMC_LA02_P
    signal FMC1_LA03_P                     : std_logic                       := '0'; -- Port 1 FMC_LA03_P
    signal FMC1_LA04_P                     : std_logic                       := '0'; -- Port 1 FMC_LA04_P
    signal FMC1_LA05_P                     : std_logic                       := '0'; -- Port 1 FMC_LA05_P
    signal FMC1_LA06_P                     : std_logic                       := '0'; -- Port 1 FMC_LA06_P
    signal FMC1_LA07_P                     : std_logic                       := '0'; -- Port 1 FMC_LA07_P
    signal FMC1_LA08_P                     : std_logic                       := '0'; -- Port 1 FMC_LA08_P
    signal FMC1_LA09_P                     : std_logic                       := '0'; -- Port 1 FMC_LA09_P
    signal FMC1_LA10_P                     : std_logic                       := '0'; -- Port 1 FMC_LA10_P
    signal FMC1_LA11_P                     : std_logic                       := '0'; -- Port 1 FMC_LA11_P
    signal FMC1_LA12_P                     : std_logic                       := '0'; -- Port 1 FMC_LA12_P
    signal FMC1_LA13_P                     : std_logic                       := '0'; -- Port 1 FMC_LA13_P
    signal FMC1_LA14_P                     : std_logic                       := '0'; -- Port 1 FMC_LA14_P
    signal FMC1_LA15_P                     : std_logic                       := '0'; -- Port 1 FMC_LA15_P
    signal FMC1_LA16_P                     : std_logic                       := '0'; -- Port 1 FMC_LA16_P
    signal FMC1_LA19_P                     : std_logic                       := '0'; -- Port 1 FMC_LA19_P
    signal FMC1_LA20_P                     : std_logic                       := '0'; -- Port 1 FMC_LA20_P
    signal FMC1_LA21_P                     : std_logic                       := '0'; -- Port 1 FMC_LA21_P
    signal FMC1_LA22_P                     : std_logic                       := '0'; -- Port 1 FMC_LA22_P
    signal FMC1_LA23_P                     : std_logic                       := '0'; -- Port 1 FMC_LA23_P
    signal FMC1_LA24_P                     : std_logic                       := '0'; -- Port 1 FMC_LA24_P
    signal FMC1_LA25_P                     : std_logic                       := '0'; -- Port 1 FMC_LA25_P
    signal FMC1_LA26_P                     : std_logic                       := '0'; -- Port 1 FMC_LA26_P
    signal FMC1_LA27_P                     : std_logic                       := '0'; -- Port 1 FMC_LA27_P
    signal FMC1_LA28_P                     : std_logic                       := '0'; -- Port 1 FMC_LA28_P
    signal FMC1_LA29_P                     : std_logic                       := '0'; -- Port 1 FMC_LA29_P
    signal FMC1_LA30_P                     : std_logic                       := '0'; -- Port 1 FMC_LA30_P
    signal FMC1_LA31_P                     : std_logic                       := '0'; -- Port 1 FMC_LA31_P
    signal FMC1_LA32_N                     : std_logic                       := '0'; -- Port 1 FMC_LA32_N
    signal FMC1_LA_N                       : std_logic_vector(27 downto 0)   := (others =>'0'); -- Port 1 FMC_N
    signal ddr3_dq                         : std_logic_vector(15 downto 0)   := (others =>'0');
    signal ddr3_dqs_p                      : std_logic_vector( 1 downto 0)   := (others =>'0');
    signal ddr3_dqs_n                      : std_logic_vector( 1 downto 0)   := (others =>'0');
    signal ddr3_addr                       : std_logic_vector(14 downto 0)   := (others =>'0');
    signal ddr3_ba                         : std_logic_vector( 2 downto 0)   := (others =>'0');
    signal ddr3_ras_n                      : std_logic                       := '0';
    signal ddr3_cas_n                      : std_logic                       := '0';
    signal ddr3_we_n                       : std_logic                       := '0';
    signal ddr3_reset_n                    : std_logic                       := '0';
    signal ddr3_ck_p                       : std_logic_vector( 0 downto 0)   := (others =>'0');
    signal ddr3_ck_n                       : std_logic_vector( 0 downto 0)   := (others =>'0');
    signal ddr3_cke                        : std_logic_vector( 0 downto 0)   := (others =>'0');
    signal ddr3_cs_n                       : std_logic_vector( 0 downto 0)   := (others =>'0');
    signal ddr3_dm                         : std_logic_vector( 1 downto 0)   := (others =>'0');
    signal ddr3_odt                        : std_logic_vector( 0 downto 0)   := (others =>'0');

begin

    U_M_Lcd4Top_0 : M_Lcd4Top 
    generic map(
    ------------------------------------
    -- support: (100Hz & 67Hz)
    ------------------------------------
        Refresh_Rate     => Refresh_Rate     
    )
    port map (
        CpSl_Rst_iN          => CpSl_Rst_iN          ,                      
        CpSl_Clk_i           => CpSl_Clk_i           ,                      
        CpSl_Clk_iP          => CpSl_Clk_iP          ,                      
        CpSl_Clk_iN          => CpSl_Clk_iN          ,                      
        CpSv_Led_o           => CpSv_Led_o           ,                      
        CpSv_Sma_o           => CpSv_Sma_o           ,                      
        CpSl_Gpio_o          => CpSl_Gpio_o          ,                      
        CpSl_Test_o          => CpSl_Test_o          ,                      
        CpSl_ExtVsync_i      => CpSl_ExtVsync_i      ,                      
        CpSl_ChoiceVsync_i   => CpSl_ChoiceVsync_i   ,                      
        CpSl_ExtVld_o        => CpSl_ExtVld_o        ,                      
        CpSl_Dvi0Clk_i       => CpSl_Dvi0Clk_i       ,                      
        CpSl_Dvi0Vsync_i     => CpSl_Dvi0Vsync_i     ,                      
        CpSl_Dvi0Hsync_i     => CpSl_Dvi0Hsync_i     ,                      
        CpSl_Dvi0Scdt_i      => CpSl_Dvi0Scdt_i      ,                      
        CpSl_Dvi0De_i        => CpSl_Dvi0De_i        ,                      
        CpSv_Dvi0R_i         => CpSv_Dvi0R_i         ,                      
        CpSl_Dvi1Scdt_i      => CpSl_Dvi1Scdt_i      ,                      
        CpSv_Dvi1R_i         => CpSv_Dvi1R_i         ,                      
        FMC0_LA02_P          => FMC0_LA02_P          ,                      
        FMC0_LA03_P          => FMC0_LA03_P          ,                      
        FMC0_LA04_P          => FMC0_LA04_P          ,                      
        FMC0_LA05_P          => FMC0_LA05_P          ,                      
        FMC0_LA06_P          => FMC0_LA06_P          ,                      
        FMC0_LA07_P          => FMC0_LA07_P          ,                      
        FMC0_LA08_P          => FMC0_LA08_P          ,                      
        FMC0_LA09_P          => FMC0_LA09_P          ,                      
        FMC0_LA10_P          => FMC0_LA10_P          ,                      
        FMC0_LA11_P          => FMC0_LA11_P          ,                      
        FMC0_LA12_P          => FMC0_LA12_P          ,                      
        FMC0_LA13_P          => FMC0_LA13_P          ,                      
        FMC0_LA14_P          => FMC0_LA14_P          ,                      
        FMC0_LA15_P          => FMC0_LA15_P          ,                      
        FMC0_LA16_P          => FMC0_LA16_P          ,                      
        FMC0_LA19_P          => FMC0_LA19_P          ,                      
        FMC0_LA20_P          => FMC0_LA20_P          ,                      
        FMC0_LA21_P          => FMC0_LA21_P          ,                      
        FMC0_LA22_P          => FMC0_LA22_P          ,                      
        FMC0_LA23_P          => FMC0_LA23_P          ,                      
        FMC0_LA24_P          => FMC0_LA24_P          ,                      
        FMC0_LA25_P          => FMC0_LA25_P          ,                      
        FMC0_LA26_P          => FMC0_LA26_P          ,                      
        FMC0_LA27_P          => FMC0_LA27_P          ,                      
        FMC0_LA28_P          => FMC0_LA28_P          ,                      
        FMC0_LA29_P          => FMC0_LA29_P          ,                      
        FMC0_LA30_P          => FMC0_LA30_P          ,                      
        FMC0_LA31_P          => FMC0_LA31_P          ,                      
        FMC0_LA32_N          => FMC0_LA32_N          ,                      
        FMC0_LA_N            => FMC0_LA_N            ,                      
        FMC1_LA02_P          => FMC1_LA02_P          ,                      
        FMC1_LA03_P          => FMC1_LA03_P          ,                      
        FMC1_LA04_P          => FMC1_LA04_P          ,                      
        FMC1_LA05_P          => FMC1_LA05_P          ,                      
        FMC1_LA06_P          => FMC1_LA06_P          ,                      
        FMC1_LA07_P          => FMC1_LA07_P          ,                      
        FMC1_LA08_P          => FMC1_LA08_P          ,                      
        FMC1_LA09_P          => FMC1_LA09_P          ,                      
        FMC1_LA10_P          => FMC1_LA10_P          ,                      
        FMC1_LA11_P          => FMC1_LA11_P          ,                      
        FMC1_LA12_P          => FMC1_LA12_P          ,                      
        FMC1_LA13_P          => FMC1_LA13_P          ,                      
        FMC1_LA14_P          => FMC1_LA14_P          ,                      
        FMC1_LA15_P          => FMC1_LA15_P          ,                      
        FMC1_LA16_P          => FMC1_LA16_P          ,                      
        FMC1_LA19_P          => FMC1_LA19_P          ,                      
        FMC1_LA20_P          => FMC1_LA20_P          ,                      
        FMC1_LA21_P          => FMC1_LA21_P          ,                      
        FMC1_LA22_P          => FMC1_LA22_P          ,                      
        FMC1_LA23_P          => FMC1_LA23_P          ,                      
        FMC1_LA24_P          => FMC1_LA24_P          ,                      
        FMC1_LA25_P          => FMC1_LA25_P          ,                      
        FMC1_LA26_P          => FMC1_LA26_P          ,                      
        FMC1_LA27_P          => FMC1_LA27_P          ,                      
        FMC1_LA28_P          => FMC1_LA28_P          ,                      
        FMC1_LA29_P          => FMC1_LA29_P          ,                      
        FMC1_LA30_P          => FMC1_LA30_P          ,                      
        FMC1_LA31_P          => FMC1_LA31_P          ,                      
        FMC1_LA32_N          => FMC1_LA32_N          ,                      
        FMC1_LA_N            => FMC1_LA_N            ,                      
        ddr3_dq              => ddr3_dq              ,                      
        ddr3_dqs_p           => ddr3_dqs_p           ,                      
        ddr3_dqs_n           => ddr3_dqs_n           ,                      
        ddr3_addr            => ddr3_addr            ,                      
        ddr3_ba              => ddr3_ba              ,                      
        ddr3_ras_n           => ddr3_ras_n           ,                      
        ddr3_cas_n           => ddr3_cas_n           ,                      
        ddr3_we_n            => ddr3_we_n            ,                      
        ddr3_reset_n         => ddr3_reset_n         ,                      
        ddr3_ck_p            => ddr3_ck_p            ,                      
        ddr3_ck_n            => ddr3_ck_n            ,                      
        ddr3_cke             => ddr3_cke             ,                      
        ddr3_cs_n            => ddr3_cs_n            ,                      
        ddr3_dm              => ddr3_dm              ,                      
        ddr3_odt             => ddr3_odt                                   

    );

    ----------------------------------------------------------------------------
    -- DDR3 Memory Models
    ----------------------------------------------------------------------------
    gen_mem : for i in 0 to 0 generate
        u_comp_ddr3 : ddr3_model port map(
            rst_n   => ddr3_reset_n                                             ,
            ck      => ddr3_ck_p(0)                                             ,
            ck_n    => ddr3_ck_n(0)                                             ,
            cke     => ddr3_cke(0)                                              ,
            cs_n    => ddr3_cs_n(0)                                             ,
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
            odt     => ddr3_odt(0)    
        );
    end generate gen_mem;

    ----------------------------------------------------------------------------
    -- Simulation
    ----------------------------------------------------------------------------
    -- Reset Signal
    process
    begin
        CpSl_Rst_iN <= '0';
        wait for 1 us;
        CpSl_Rst_iN <= '1';
        wait;
    end process;
    
    -- Clock Signal
    CpSl_Clk_i  <= not CpSl_Clk_i after 5 ns;  -- 100MHz
    
    CpSl_Clk_iP <= not CpSl_Clk_iP  after 2.5 ns; -- 200MHz
    CpSl_Clk_iN <= not CpSl_Clk_iP;
    
    -- External Sync In (100Hz)
--    process 
--    begin
--        CpSl_ExtVsync_i <= '0' after 1 ns;
--        wait for 10 us;
--        CpSl_ExtVsync_i <= '1' after 1 ns;
--        wait for 1 ms;
--        CpSl_ExtVsync_i <= '0' after 1 ns;
--        wait for 8 ms;
--        wait for 990 us;
--    end process;
--    
    CpSl_ExtVsync_i <= CpSl_Test_o;
    
    
    -- External Sync Selection
    CpSl_ChoiceVsync_i  <= '1' after 1 ns;
    
    CpSl_Dvi0Clk_i  <= not CpSl_Dvi0Clk_i after 3.03 ns;  -- 165MHz
    
    CpSv_Dvi0R_i <= "10101010";
    CpSv_Dvi1R_i <= "01010101";
    
    -- DVI VSync (100Hz)
    DviVsync_100Hz_gen : if (Refresh_Rate = 100) generate
        
    process 
    begin
        CpSl_Dvi0Vsync_i <= '1' after 1 ns;
        wait for 100 us;
        CpSl_Dvi0Vsync_i <= '0' after 1 ns;
        wait for 10 us;
        CpSl_Dvi0Vsync_i <= '1' after 1 ns;
        wait for 9.89 ms;
    end process;
    
    CpSl_Dvi0Scdt_i <= '1';
    CpSl_Dvi1Scdt_i <= '0';
        
    end generate DviVsync_100Hz_gen;
    
    -- DVI VSync (67Hz)
    DviVsync_67Hz_gen : if (REFRESH_RATE = 67) generate
        
    process 
    begin
        CpSl_Dvi0Vsync_i <= '1' after 1 ns;
        wait for 100 us;
        CpSl_Dvi0Vsync_i <= '0' after 1 ns;
        wait for 10 us;
        CpSl_Dvi0Vsync_i <= '1' after 1 ns;
        wait for 14.8153 ms;
    end process;
    
    CpSl_Dvi0Scdt_i <= '1';
    CpSl_Dvi1Scdt_i <= '0';
    
    end generate DviVsync_67Hz_gen;
    
    

end arch_M_Lcd4Top_tb;