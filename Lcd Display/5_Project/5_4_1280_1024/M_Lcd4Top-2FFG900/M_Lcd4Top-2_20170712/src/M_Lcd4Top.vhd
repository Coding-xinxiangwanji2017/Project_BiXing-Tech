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
-- 设    计  :  Zhang Wenjun
-- 邮    件  :  liuwanghao@139.com
-- 校    对  :
-- 设计日期  :  2015/11/16
-- 功能简述  :  LCD4 top entity
-- 版本序号  :  0.1
-- 修改历史  :  1. Initial, Zhang Wwenjun, 2015/11/16
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

entity M_Lcd4Top is 
    generic (
        --------------------------------
        -- Refresh Rate : 100Hz/67Hz
        --------------------------------
        Refresh_Rate     : integer := 100  
    );
    port (
        --------------------------------
        -- Reset/Clock
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset active low
        CpSl_Clk_i                      : in  std_logic;                        -- Clock 100MHz, single
        CpSl_Clk_iP                     : in  std_logic;                        -- Clock 200MHz, diff
        CpSl_Clk_iN                     : in  std_logic;                        -- Clock 200MHz, diff
        --------------------------------
        -- Led/SMA/GPIO
        --------------------------------
        CpSv_Led_o                      : out std_logic_vector( 3 downto 0);    -- LED out
        CpSv_Sma_o                      : out std_logic_vector( 3 downto 0);    -- SMA out
        CpSl_Test_o                     : out std_logic;                        -- Test Pulse
        CpSl_Gpio_o                     : out std_logic;                        -- GPIO out
        CpSl_ExtVld_o                   : out std_logic;                        -- Ext or Int indication
        CpSl_ExtVsync_i                 : in  std_logic;                        -- Sync in (V Sync)
        CpSl_ChoiceVsync_i              : in  std_logic;                        -- Choice Ext or Int Vsync
        
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
end M_Lcd4Top;

architecture arch_M_Lcd4Top of M_Lcd4Top is
    ----------------------------------------------------------------------------
    -- constant declaration
    ----------------------------------------------------------------------------

    ----------------------------------------------------------------------------
    -- component declaration
    ----------------------------------------------------------------------------
    component M_Icon port (
        control0                        : inout std_logic_vector(35 downto 0);
        control1                        : inout std_logic_vector(35 downto 0);
        control2                        : inout std_logic_vector(35 downto 0);
        control3                        : inout std_logic_vector(35 downto 0)
    );
    end component;

    -- Control Clock
    component M_ClkCtrl port (
        --------------------------------
        -- Clk & Reset
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      : in  std_logic;                        -- Clock 100MHz, Singal
        
        --------------------------------
        -- Choice Clk
        --------------------------------
        CpSl_ClkSel_i                   : in  std_logic;                        -- Choice Clock
        
        --------------------------------
        -- Clk out
        --------------------------------
        CpSl_ClkFmc_o                   : out std_logic;                        -- Clock Fmc
        CpSl_ClkLcd_o                   : out std_logic;                        -- Clock Lcd
        CpSl_ClkFre_o                   : out std_logic;                        -- Clock FreCtrl
        CpSl_PllLocked_o                : out std_logic                         -- Clock Pll Locked 
    );
    end component;

    component M_DviIf port (
        --------------------------------
        -- DVI Input
        --------------------------------
        CpSl_ExtVsync_i                 : in  std_logic;                        -- ExtVsync
        CpSl_Dvi0Clk_i                  : in  std_logic;                        -- DVI0 clk
        CpSl_Dvi0Vsync_i                : in  std_logic;                        -- DVI0 V sync
        CpSl_Dvi0Hsync_i                : in  std_logic;                        -- DVI0 H sync
        CpSl_Dvi0De_i                   : in  std_logic;                        -- DVI0 De
        CpSl_Dvi0Scdt_i                 : in  std_logic;                        -- DVI0 SCDT
        CpSv_Dvi0R_i                    : in  std_logic_vector(  7 downto 0);   -- DVI0 red
        CpSl_Dvi1Scdt_i                 : in  std_logic;                        -- DVI0 SCDT
        CpSv_Dvi1R_i                    : in  std_logic_vector(  7 downto 0);   -- DVI1 red
        CpSl_ChoiceVsync_i              : in  std_logic;                        -- Choice Ext or Int Vsync

        --------------------------------
        -- DVI Output
        --------------------------------
        CpSl_ExtVsync_o                 : out std_logic;                        -- ExtVsync
        CpSl_Dvi0Clk_o                  : out std_logic;                        -- DVI0 clk
        CpSl_Dvi0Vsync_o                : out std_logic;                        -- DVI0 V sync
        CpSl_Dvi0Hsync_o                : out std_logic;                        -- DVI0 H sync
        CpSl_Dvi0De_o                   : out std_logic;                        -- DVI0 De
        CpSl_Dvi0Scdt_o                 : out std_logic;                        -- DVI0 SCDT
        CpSv_Dvi0R_o                    : out std_logic_vector(  7 downto 0);   -- DVI0 red
        CpSl_Dvi1Scdt_o                 : out std_logic;                        -- DVI0 SCDT
        CpSv_Dvi1R_o                    : out std_logic_vector(  7 downto 0);   -- DVI1 red
        CpSl_ChoiceVsync_o              : out std_logic                         -- Choice Ext or Int Vsync
    );
    end component;

    component M_LcdVsync port (
        --------------------------------
		-- clock & reset
		--------------------------------
		CpSl_Rst_iN                     :  in std_logic;                        -- Resxt active low
		CpSl_Clk_i                      :  in std_logic;                        -- Clock 80MHz,Single
		
		--------------------------------
		-- Vsync input
		--------------------------------
        CpSl_ChoiceVsync_i              :  in  std_logic;                       -- Choice Ext or Int Vsync
		CpSl_ExtVsync_i                 :  in  std_logic;                       -- Ext vsync
		CpSl_IntVsync_i                 :  in  std_logic;                       -- int Vsync

		--------------------------------
		-- Vsync output
		--------------------------------
		CpSl_LcdVsync_o                 :  out std_logic;                       -- Lcd Vsync
		CpSl_ExtVld_o                   :  out std_logic;                       -- External Valid
		
		--------------------------------
		-- ChipScope
		--------------------------------
		CpSv_ChipCtrl3_io               : inout std_logic_vector(35 downto 0)   -- ChipScope control3
    );
    end component;
        
    component M_FreCtrl port (
        --------------------------------
        -- Reset and Clock
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Rst, active low
        CpSl_Clk_i                      : in  std_logic;                        -- Clk, 80Mhz
                                                                                  
        --------------------------------                                          
        -- Dvi                                                                     
        --------------------------------                                          
        CpSl_Dvi0Scdt_i                 : in  std_logic;                        -- Dvi0 Scdt
        CpSl_Dvi1Scdt_i                 : in  std_logic;                        -- Dvi1 Scdt
        CpSl_DviVsync_i                 : in  std_logic;                        -- Dvi Vsync

        --------------------------------
        -- Frequence Choice
        --------------------------------
        CpSv_VsyncTrig_o                : out std_logic_vector(7 downto 0 );    -- VsyncTrig
	    CpSl_ClkSel_o    			    : out std_logic;                        -- Choice Clock
        CpSv_FreChoice_o                : out std_logic_vector( 2 downto 0);    -- Choice Frequence
        CpSv_FreLed_o                   : out std_logic_vector( 3 downto 0)     -- led
            
        --------------------------------
        -- ChipScope
        --------------------------------
--        CpSv_ChipCtrl3_io               : inout std_logic_vector(35 downto 0)   -- ChipScope control3
    );
    end component;

    component M_Test generic (
        ------------------------------------
        -- Refresh Rate : 100Hz/67Hz
        ------------------------------------
        Refresh_Rate : integer := 100   
    );
    port (
        --------------------------------
        -- Reset & Clock
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                       -- Rst, active low
        CpSl_Clk_i                      : in  std_logic;                       -- Clk, 80Mhz

        --------------------------------
        -- Refersh Rate Choice
        --------------------------------
        CpSl_LcdVsync_i                 : in  std_logic;                        -- Lcd Vsync 
        CpSv_FreChoice_i                : in  std_logic_vector(2 downto 0);     -- FreChoice
        CpSv_VsyncTrig_i                : in  std_logic_vector(7 downto 0 );    -- VsyncTrig
            
        --------------------------------
        -- Pulse output
        --------------------------------
        CpSl_Vsync_o                    : out std_logic;                        -- Vsync
        CpSl_Test_o                     : out std_logic                         -- Test Pulse
    );
    end component;

    component M_DdrIf port (
        --------------------------------
        -- Lcd Vsync
        --------------------------------
        CpSl_LcdSync_i                  : in  std_logic;                        -- Lcd Vsync

        --------------------------------
        -- Test Vsync
        --------------------------------
        CpSl_DVISync_SMA_o              : out  std_logic;                       -- Sync out of DVI V Sync
        CpSl_LCDSync_SMA_o              : out  std_logic;                       -- Sync out of LCD V Sync

        --------------------------------
        -- DVI
        --------------------------------
        CpSl_Dvi0Clk_i                  : in  std_logic;                        -- DVI0 clk
        CpSl_Dvi0Vsync_i                : in  std_logic;                        -- DVI0 V sync
        CpSl_Dvi0Hsync_i                : in  std_logic;                        -- DVI0 H sync
        CpSl_Dvi0De_i                   : in  std_logic;                        -- DVI0 De
        CpSl_Dvi0Scdt_i                 : in  std_logic;                        -- DVI0 SCDT
        CpSv_Dvi0R_i                    : in  std_logic_vector(  7 downto 0);   -- DVI0 red
        CpSl_Dvi1Scdt_i                 : in  std_logic;                        -- DVI0 SCDT
        CpSv_Dvi1R_i                    : in  std_logic_vector(  7 downto 0);   -- DVI1 red

        --------------------------------
        -- LCD
        --------------------------------
        CpSl_LcdClk_i                   : in  std_logic;                        -- LCD clk
        CpSv_FreChoice_i                : in  std_logic_vector( 2  downto 0);   -- Frequence Choice
        CpSl_LcdVsync_o                 : out std_logic;                        -- LCD V sync
        CpSl_LcdHsync_o                 : out std_logic;                        -- LCD H sync
        CpSv_LcdR0_o                    : out std_logic_vector( 11 downto 0);   -- LCD red0
        CpSv_LcdR1_o                    : out std_logic_vector( 11 downto 0);   -- LCD red1
        CpSv_LcdR2_o                    : out std_logic_vector( 11 downto 0);   -- LCD red2
        CpSv_LcdR3_o                    : out std_logic_vector( 11 downto 0);   -- LCD red3

        --------------------------------
        -- DDR
        --------------------------------
        CpSl_DdrRdy_i                   : in  std_logic;                        -- DDR ready
        CpSl_DdrClk_i                   : in  std_logic;                        -- DDR clock
        CpSl_AppRdy_i                   : in  std_logic;                        -- DDR APP IF
        CpSl_AppEn_o                    : out std_logic;                        -- DDR APP IF
        CpSv_AppCmd_o                   : out std_logic_vector(  2 downto 0);   -- DDR APP IF
        CpSv_AppAddr_o                  : out std_logic_vector( 28 downto 0);   -- DDR APP IF
        CpSl_AppWdfRdy_i                : in  std_logic;                        -- DDR APP IF
        CpSl_AppWdfWren_o               : out std_logic;                        -- DDR APP IF
        CpSl_AppWdfEnd_o                : out std_logic;                        -- DDR APP IF
        CpSv_AppWdfData_o               : out std_logic_vector(127 downto 0);   -- DDR APP IF
        CpSl_AppRdDataVld_i             : in  std_logic;                        -- DDR APP IF
        CpSv_AppRdData_i                : in  std_logic_vector(127 downto 0);   -- DDR APP IF
            
        --------------------------------
        -- ChipScope
        --------------------------------
        CpSv_ChipCtrl0_io               : inout std_logic_vector(35 downto 0);  -- ChipScope Control0
        CpSv_ChipCtrl1_io               : inout std_logic_vector(35 downto 0);  -- ChipScope Control1
        CpSv_ChipCtrl2_io               : inout std_logic_vector(35 downto 0)   -- ChipScope Control2
    );
    end component;

    component M_DdrCtrl port (
        sys_rst                         : in    std_logic;
        sys_clk_p                       : in    std_logic;
        sys_clk_n                       : in    std_logic;
        ui_clk_sync_rst                 : out   std_logic;
        ui_clk                          : out   std_logic;
        init_calib_complete             : out   std_logic;

        app_addr                        : in    std_logic_vector( 28 downto 0);
        app_cmd                         : in    std_logic_vector(  2 downto 0);
        app_en                          : in    std_logic;
        app_wdf_data                    : in    std_logic_vector(127 downto 0);
        app_wdf_end                     : in    std_logic;
        app_wdf_mask                    : in    std_logic_vector( 15 downto 0);
        app_wdf_wren                    : in    std_logic;
        app_rd_data                     : out   std_logic_vector(127 downto 0);
        app_rd_data_end                 : out   std_logic;
        app_rd_data_valid               : out   std_logic;
        app_rdy                         : out   std_logic;
        app_wdf_rdy                     : out   std_logic;
        app_sr_req                      : in    std_logic;
        app_sr_active                   : out   std_logic;
        app_ref_req                     : in    std_logic;
        app_ref_ack                     : out   std_logic;
        app_zq_req                      : in    std_logic;
        app_zq_ack                      : out   std_logic;

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

    
    component M_Pattern port (
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      : in  std_logic;                        -- Clock, 80MHz

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

    component M_HSelectIO port (
        io_reset                        : in  std_logic;
        clk_in                          : in  std_logic;
        clk_div_in                      : in  std_logic;
        data_out_from_device            : in  std_logic_vector(104 downto 0);
        data_out_to_pins_p              : out std_logic_vector( 14 downto 0);
        data_out_to_pins_n              : out std_logic_vector( 14 downto 0)
    );
    end component;

    component M_LSelectIO port (
        io_reset                        : in  std_logic;
        clk_in                          : in  std_logic;
        clk_div_in                      : in  std_logic;
        data_out_from_device            : in  std_logic_vector(90 downto 0);
        data_out_to_pins_p              : out std_logic_vector(12 downto 0);
        data_out_to_pins_n              : out std_logic_vector(12 downto 0)
    );
    end component;

    ----------------------------------------------------------------------------
    -- signal declaration
    ----------------------------------------------------------------------------
    -- Chipscope
    signal PrSv_ChipCtrl0_s             : std_logic_vector( 35 downto 0);       -- Chipscope control0
    signal PrSv_ChipCtrl1_s             : std_logic_vector( 35 downto 0);       -- Chipscope control1
    signal PrSv_ChipCtrl2_s             : std_logic_vector( 35 downto 0);       -- Chipscope control2
    signal PrSv_ChipCtrl3_s             : std_logic_vector( 35 downto 0);       -- Chipscope control3

    --Selcet Clk
    signal PrSl_ClkSel_s                : std_logic;                            -- Select Clk
        
    --DVI IDDR
    signal PrSl_If_ExtVsync_s           : std_logic;                            -- ExtVsync
    signal PrSl_If_Dvi0Clk_s            : std_logic;                            -- Dvi0Clk
    signal PrSl_If_Dvi0Vsync_s          : std_logic;                            -- Dvi0Vsync
    signal PrSl_If_Dvi0Hsync_s          : std_logic;                            -- Dvi0Hsync
    signal PrSl_If_Dvi0De_s             : std_logic;                            -- Dvi0De
    signal PrSl_If_Dvi0Scdt_s           : std_logic;                            -- Dvi0Scdt
    signal PrSv_If_Dvi0R_s              : std_logic_vector(  7 downto 0);       -- Dvi0R_s
    signal PrSl_If_Dvi1Scdt_s           : std_logic;                            -- Dvi1Scdt
    signal PrSv_If_Dvi1R_s              : std_logic_vector(  7 downto 0);       -- Dvi1R
    signal PrSv_If_Vsync_s              : std_logic;                            -- Choice Ext or Int Vsync

    -- SMA outputfor test
    signal PrSl_DVISync_SMA_s           : std_logic;                            -- DVISync_SMA
    signal PrSl_LCDSync_SMA_s           : std_logic;                            -- LCDSync_SMA

    signal PrSl_ClkFmc_s                : std_logic;                            -- FMC clk
    signal PrSl_ClkLcd_s                : std_logic;                            -- LCD clk
    signal PrSl_ClkFre_s                : std_logic;                            -- refresh clk
    signal PrSl_PllLocked_s             : std_logic;                            -- Pll Locked
    signal PrSl_Dvi0DeDly1_s            : std_logic;                            -- Delay De 1 clk
    signal PrSl_Dvi0DeDly2_s            : std_logic;                            -- Delay De 2 clk
    signal PrSl_Dvi0DeDly3_s            : std_logic;                            -- Delay De 3 clk
    signal PrSl_SyncPolar_s             : std_logic;                            -- Sync polarity indicator
    signal PrSl_Dvi0Vsync_s             : std_logic;                            -- Inner Vsync
    signal PrSl_Dvi0Hsync_s             : std_logic;                            -- Inner Hsync
    signal PrSl_RealHsync_s             : std_logic;                            -- Real h sync
    signal PrSl_RealVsync_s             : std_logic;                            -- Real v sync
    signal PrSv_RealR0_s                : std_logic_vector( 11 downto 0);       -- Real red ch0
    signal PrSv_RealR1_s                : std_logic_vector( 11 downto 0);       -- Real red ch1
    signal PrSv_RealR2_s                : std_logic_vector( 11 downto 0);       -- Real red ch2
    signal PrSv_RealR3_s                : std_logic_vector( 11 downto 0);       -- Real red ch3

    signal PrSv_FreChoice_s             : std_logic_vector( 2 downto 0);        -- Refresh Rate Sel
    signal PrSv_FreLed_s                : std_logic_vector( 3 downto 0);        -- light led
    signal PrSl_TestPulse_s             : std_logic;                            -- Test Pulse Vsync
    signal PrSl_DdrRst_s                : std_logic;                            --
    signal PrSl_DdrClk_s                : std_logic;                            --
    signal PrSl_DdrRdy_s                : std_logic;                            --
    signal PrSv_AppAddr_s               : std_logic_vector( 28 downto 0);       --
    signal PrSv_AppCmd_s                : std_logic_vector(  2 downto 0);       --
    signal PrSl_AppEn_s                 : std_logic;                            --
    signal PrSv_AppWdfData_s            : std_logic_vector(127 downto 0);       --
    signal PrSl_AppWdfEnd_s             : std_logic;                            --
    signal PrSl_AppWdfWren_s            : std_logic;                            --
    signal PrSv_AppRdData_s             : std_logic_vector(127 downto 0);       --
    signal PrSl_AppRdDataVld_s          : std_logic;                            --
    signal PrSl_AppRdy_s                : std_logic;                            --
    signal PrSl_AppWdfRdy_s             : std_logic;                            --
    --
    signal PrSl_SimSwitch_s             : std_logic;                            -- Sim data switch
    signal PrSl_SimHsync_s              : std_logic;                            -- Sim h sync
    signal PrSl_SimVsync_s              : std_logic;                            -- Sim v sync
    signal PrSv_SimR0_s                 : std_logic_vector( 11 downto 0);       -- Sim red ch0
    signal PrSv_SimR1_s                 : std_logic_vector( 11 downto 0);       -- Sim red ch1
    signal PrSv_SimR2_s                 : std_logic_vector( 11 downto 0);       -- Sim red ch2
    signal PrSv_SimR3_s                 : std_logic_vector( 11 downto 0);       -- Sim red ch3
    signal PrSl_Port0Hsync_s            : std_logic;                            -- H sync
    signal PrSl_Port0Vsync_s            : std_logic;                            -- V sync
    signal PrSv_Port0R0_s               : std_logic_vector( 11 downto 0);       -- Red ch0
    signal PrSv_Port0R1_s               : std_logic_vector( 11 downto 0);       -- Red ch1
    signal PrSv_Port0R2_s               : std_logic_vector( 11 downto 0);       -- Red ch2
    signal PrSv_Port0R3_s               : std_logic_vector( 11 downto 0);       -- Red ch3
    signal PrSv_Port0G0_s               : std_logic_vector( 11 downto 0);       -- Green ch0
    signal PrSv_Port0G1_s               : std_logic_vector( 11 downto 0);       -- Green ch1
    signal PrSv_Port0G2_s               : std_logic_vector( 11 downto 0);       -- Green ch2
    signal PrSv_Port0G3_s               : std_logic_vector( 11 downto 0);       -- Green ch3
    signal PrSv_Port0B0_s               : std_logic_vector( 11 downto 0);       -- Blue ch0
    signal PrSv_Port0B1_s               : std_logic_vector( 11 downto 0);       -- Blue ch1
    signal PrSv_Port0B2_s               : std_logic_vector( 11 downto 0);       -- Blue ch2
    signal PrSv_Port0B3_s               : std_logic_vector( 11 downto 0);       -- Blue ch3
    signal PrSl_Port1Hsync_s            : std_logic;                            -- H sync
    signal PrSl_Port1Vsync_s            : std_logic;                            -- V sync
    signal PrSv_Port1R0_s               : std_logic_vector( 11 downto 0);       -- Red ch0
    signal PrSv_Port1R1_s               : std_logic_vector( 11 downto 0);       -- Red ch1
    signal PrSv_Port1R2_s               : std_logic_vector( 11 downto 0);       -- Red ch2
    signal PrSv_Port1R3_s               : std_logic_vector( 11 downto 0);       -- Red ch3
    signal PrSv_Port1G0_s               : std_logic_vector( 11 downto 0);       -- Green ch0
    signal PrSv_Port1G1_s               : std_logic_vector( 11 downto 0);       -- Green ch1
    signal PrSv_Port1G2_s               : std_logic_vector( 11 downto 0);       -- Green ch2
    signal PrSv_Port1G3_s               : std_logic_vector( 11 downto 0);       -- Green ch3
    signal PrSv_Port1B0_s               : std_logic_vector( 11 downto 0);       -- Blue ch0
    signal PrSv_Port1B1_s               : std_logic_vector( 11 downto 0);       -- Blue ch1
    signal PrSv_Port1B2_s               : std_logic_vector( 11 downto 0);       -- Blue ch2
    signal PrSv_Port1B3_s               : std_logic_vector( 11 downto 0);       -- Blue ch3
    signal PrSv_Matrix0H_s              : std_logic_vector(104 downto 0);       -- Matrix high
    signal PrSv_Matrix0HS_sP            : std_logic_vector( 14 downto 0);       -- Matrix high serial
    signal PrSv_Matrix0HS_sN            : std_logic_vector( 14 downto 0);       -- Matrix high serial
    signal PrSv_Matrix1H_s              : std_logic_vector(104 downto 0);       -- Matrix high
    signal PrSv_Matrix1HS_sP            : std_logic_vector( 14 downto 0);       -- Matrix high serial
    signal PrSv_Matrix1HS_sN            : std_logic_vector( 14 downto 0);       -- Matrix high serial
    signal PrSv_Matrix0L_s              : std_logic_vector( 90 downto 0);       -- Matrix low
    signal PrSv_Matrix0LS_sP            : std_logic_vector( 12 downto 0);       -- Matrix low serial P
    signal PrSv_Matrix0LS_sN            : std_logic_vector( 12 downto 0);       -- Matrix low serial N
    signal PrSv_Matrix1L_s              : std_logic_vector( 90 downto 0);       -- Matrix low
    signal PrSv_Matrix1LS_sP            : std_logic_vector( 12 downto 0);       -- Matrix low serial P
    signal PrSv_Matrix1LS_sN            : std_logic_vector( 12 downto 0);       -- Matrix low serial N

    signal PrSl_SelectIO_s              : std_logic;                            -- SelectIO Rst
    signal PrSl_LcdVsync_s              : std_logic;                            -- Lcd Vsync
    signal PrSv_VsyncTrig_s             : std_logic_vector(  7 downto 0);       -- Vsync Trig Cnt    
begin
    ----------------------------------------------------------------------------
    -- Chipscope
    ----------------------------------------------------------------------------
    U_M_Icon_0 : M_Icon port map (
        control0                        => PrSv_ChipCtrl0_s                     ,
		control1                        => PrSv_ChipCtrl1_s                     ,
		control2                        => PrSv_ChipCtrl2_s                     ,
        control3                        => PrSv_ChipCtrl3_s
    );

    ----------------------------------------------------------------------------
    -- Component map declaration
    ----------------------------------------------------------------------------
    -- Choice Clock
    U_M_ClkCtrl_0 : M_ClkCtrl port map (
        --------------------------------
        -- Clock & Reset
        --------------------------------
        CpSl_Rst_iN                     => CpSl_Rst_iN,                         -- Reset, active low
        CpSl_Clk_i                      => CpSl_Clk_i,                          -- Clock 100MHz, Single
                                       
        --------------------------------
        -- Choice Clk                  
        --------------------------------
        CpSl_ClkSel_i                   => PrSl_ClkSel_s,                       -- Choice Clock
                                        
        -------------------------------- 
        -- Clock out
        --------------------------------
        CpSl_ClkFmc_o                   => PrSl_ClkFmc_s,                       -- Clock Fmc
        CpSl_ClkLcd_o                   => PrSl_ClkLcd_s,                       -- Clock Lcd
        CpSl_ClkFre_o                   => PrSl_ClkFre_s,                       -- Clock FreCtrl
        CpSl_PllLocked_o                => PrSl_PllLocked_s                     -- Clock Pll Locked 
    );

    --Dvi Interface
    U_M_DviIf_0 : M_DviIf port map (
        --------------------------------
        -- DVI Input
        --------------------------------
        CpSl_ExtVsync_i                 => CpSl_ExtVsync_i                      , -- ExtVsync
        CpSl_Dvi0Clk_i                  => CpSl_Dvi0Clk_i                       , -- Dvi0Clk
        CpSl_Dvi0Vsync_i                => CpSl_Dvi0Vsync_i                     , -- Dvi0Vsync
        CpSl_Dvi0Hsync_i                => CpSl_Dvi0Hsync_i                     , -- Dvi0Hsync
        CpSl_Dvi0De_i                   => CpSl_Dvi0De_i                        , -- Dvi0De
        CpSl_Dvi0Scdt_i                 => CpSl_Dvi0Scdt_i                      , -- Dvi0Scdt
        CpSv_Dvi0R_i                    => CpSv_Dvi0R_i                         , -- Dvi0R
        CpSl_Dvi1Scdt_i                 => CpSl_Dvi1Scdt_i                      , -- Dvi1Scdt
        CpSv_Dvi1R_i                    => CpSv_Dvi1R_i                         , -- Dvi1R
        CpSl_ChoiceVsync_i              => CpSl_ChoiceVsync_i                   , -- Choice Ext or Int Vsync

        --------------------------------
        -- DVI Output
        --------------------------------
        CpSl_ExtVsync_o                 => PrSl_If_ExtVsync_s                   , -- ExtVsync
        CpSl_Dvi0Clk_o                  => PrSl_If_Dvi0Clk_s                    , -- Dvi0Clk
        CpSl_Dvi0Vsync_o                => PrSl_If_Dvi0Vsync_s                  , -- Dvi0Vsync
        CpSl_Dvi0Hsync_o                => PrSl_If_Dvi0Hsync_s                  , -- Dvi0Hsync
        CpSl_Dvi0De_o                   => PrSl_If_Dvi0De_s                     , -- Dvi0De
        CpSl_Dvi0Scdt_o                 => PrSl_If_Dvi0Scdt_s                   , -- Dvi0Scdt
        CpSv_Dvi0R_o                    => PrSv_If_Dvi0R_s                      , -- Dvi0R
        CpSl_Dvi1Scdt_o                 => PrSl_If_Dvi1Scdt_s                   , -- Dvi1Scdt
        CpSv_Dvi1R_o                    => PrSv_If_Dvi1R_s                      , -- Dvi1R
        CpSl_ChoiceVsync_o              => PrSv_If_Vsync_s                        -- Choice Ext or Int Vsync
    );

    -- Choice the Ext and Int Vsync
    U_M_LcdVsync_0: M_LcdVsync port map (
        --------------------------------
		-- clock & reset
		--------------------------------
		CpSl_Rst_iN                     => PrSl_PllLocked_s                     , -- Resxt active low
		CpSl_Clk_i                      => PrSl_ClkFre_s                        , -- Clock 80MHz,Single
		
		--------------------------------
		-- Vsync input
		--------------------------------
        CpSl_ChoiceVsync_i              => PrSv_If_Vsync_s                      , -- Choice Ext or Int Vsync
		CpSl_ExtVsync_i                 => PrSl_If_ExtVsync_s                   , -- Ext vsync
		CpSl_IntVsync_i                 => PrSl_If_Dvi0Vsync_s                  , -- int Vsync

		--------------------------------
		-- Vsync output
		--------------------------------
		CpSl_LcdVsync_o                 => PrSl_LcdVsync_s                      , -- Choice the Vsync
		CpSl_ExtVld_o                   => CpSl_ExtVld_o    		            , -- Ext or Int Indication
		
		--------------------------------
		-- ChipScope
		--------------------------------
		CpSv_ChipCtrl3_io               => PrSv_ChipCtrl3_s                       -- ChipScope control3
    );

    ------------------------------------
    -- Control the refresh rate
    ------------------------------------
    U_M_FreCtrl_0 : M_FreCtrl port map (
        --------------------------------
        --reset and clock
        --------------------------------
        CpSl_Rst_iN                     => PrSl_PllLocked_s                     , -- in std_logic;
        CpSl_Clk_i                      => PrSl_ClkFre_s                        , -- in std_logic;

        --------------------------------
        --Dvi signal
        --------------------------------
        CpSl_Dvi0Scdt_i                 => PrSl_If_Dvi0Scdt_s                   , -- in std_logic;
        CpSl_Dvi1Scdt_i                 => PrSl_If_Dvi1Scdt_s                   , -- in std_logic;
        CpSl_DviVsync_i                 => PrSl_LcdVsync_s                      , -- in std_logic;

        --------------------------------
        --Frequence Choice
        --------------------------------
        CpSv_VsyncTrig_o                => PrSv_VsyncTrig_s                     , -- out std_logic_vector(7 downto 0);
        CpSl_ClkSel_o                   => PrSl_ClkSel_s                        , -- out std_logic;
        CpSv_FreChoice_o                => PrSv_FreChoice_s                     , -- out std_logic_vector(2 downto 0);
        CpSv_FreLed_o                   => PrSv_FreLed_s                          -- out std_logic_vector(3 downto 0);
        
        --------------------------------
		-- ChipScope
		--------------------------------
--        CpSv_ChipCtrl3_io               => PrSv_ChipCtrl3_s                     -- ChipScope control3
    );

    ------------------------------------
    --  Generate Test Pulse
    ------------------------------------
    U_M_Test_0 :  M_Test generic map(
        --------------------------------
        -- Refresh Rate : 100Hz, 67Hz
        --------------------------------
        Refresh_Rate    => Refresh_Rate   
    )
    port map (
        --------------------------------
        --Reset & Clock
        --------------------------------
        CpSl_Rst_iN                     => PrSl_DdrRdy_s                        , -- Reset active low
        CpSl_Clk_i                      => PrSl_ClkFre_s                        , -- Clock 80Mhz,single


        --------------------------------
        -- Frequence Choice
        --------------------------------
        CpSl_LcdVsync_i                 => PrSl_LcdVsync_s                      , -- in  std_logic;
        CpSv_FreChoice_i                => PrSv_FreChoice_s                     , -- in  std_logic_vector(2 downto 0);
        CpSv_VsyncTrig_i                => PrSv_VsyncTrig_s                     , -- in  std_logic_vector(7 downto 0);
            
        --------------------------------
        -- Test signal
        --------------------------------
        CpSl_Vsync_o                    => PrSl_TestPulse_s                     , -- out std_logic;
        CpSl_Test_o                     => CpSl_Test_o                            -- out std_logic;
    );

    ----------------------------------------------------------------------------
    -- DDR, include:
    -- DDR interface
    -- DDR controller
    ----------------------------------------------------------------------------
    ------------------------------------
    -- DDR if with controller
    ------------------------------------
    U_M_DdrIf_0 : M_DdrIf port map (
        --------------------------------
        -- External Sync
        --------------------------------
        CpSl_LcdSync_i                  => PrSl_TestPulse_s                     , -- in  std_logic;
--        CpSl_LcdSync_i                  => PrSl_LcdVsync_s                       , -- in  std_logic;


        --------------------------------
        -- SMA V Sync
        --------------------------------
        CpSl_DVISync_SMA_o              => PrSl_DVISync_SMA_s                   , -- out  std_logic;
        CpSl_LCDSync_SMA_o              => PrSl_LCDSync_SMA_s                   , -- out  std_logic;

        --------------------------------
        -- DVI
        --------------------------------
        CpSl_Dvi0Clk_i                  => PrSl_If_Dvi0Clk_s                    , -- in  std_logic;
        CpSl_Dvi0Vsync_i                => PrSl_If_Dvi0Vsync_s                  , -- in  std_logic;                        -- DVI0 V sync
        CpSl_Dvi0Hsync_i                => PrSl_If_Dvi0Hsync_s                  , -- in  std_logic;                        -- DVI0 H sync
        CpSl_Dvi0De_i                   => PrSl_If_Dvi0De_s                     , -- in  std_logic;                        -- DVI0 De
        CpSl_Dvi0Scdt_i                 => PrSl_If_Dvi0Scdt_s                   , -- in  std_logic;                        -- DVI0 SCDT
        CpSv_Dvi0R_i                    => PrSv_If_Dvi0R_s                      , -- in  std_logic_vector(  7 downto 0);   -- DVI0 red
        CpSl_Dvi1Scdt_i                 => PrSl_If_Dvi1Scdt_s                   , -- in  std_logic;                        -- DVI0 SCDT
        CpSv_Dvi1R_i                    => PrSv_If_Dvi1R_s                      , -- in  std_logic_vector(  7 downto 0);   -- DVI1 red

        --------------------------------
        -- LCD
        --------------------------------
        CpSl_LcdClk_i                   => PrSl_ClkLcd_s                        , -- in  std_logic;                        -- LCD clk
        CpSv_FreChoice_i                => PrSv_FreChoice_s                     , -- in  std_logic_vector(  2 downto 0);   -- Frequence Choice
        CpSl_LcdVsync_o                 => PrSl_RealVsync_s                     , -- out std_logic;                        -- LCD V sync
        CpSl_LcdHsync_o                 => PrSl_RealHsync_s                     , -- out std_logic;                        -- LCD H sync
        CpSv_LcdR0_o                    => PrSv_RealR0_s                        , -- out std_logic_vector( 11 downto 0);   -- LCD red0
        CpSv_LcdR1_o                    => PrSv_RealR1_s                        , -- out std_logic_vector( 11 downto 0);   -- LCD red1
        CpSv_LcdR2_o                    => PrSv_RealR2_s                        , -- out std_logic_vector( 11 downto 0);   -- LCD red2
        CpSv_LcdR3_o                    => PrSv_RealR3_s                        , -- out std_logic_vector( 11 downto 0);   -- LCD red3

        --------------------------------
        -- DDR
        --------------------------------
        CpSl_DdrRdy_i                   => PrSl_DdrRdy_s                        , -- in  std_logic;                        -- DDR ready
        CpSl_DdrClk_i                   => PrSl_DdrClk_s                        , -- in  std_logic;                        -- DDR clock
        CpSl_AppRdy_i                   => PrSl_AppRdy_s                        , -- in  std_logic;                        -- DDR APP IF
        CpSl_AppEn_o                    => PrSl_AppEn_s                         , -- out std_logic;                        -- DDR APP IF
        CpSv_AppCmd_o                   => PrSv_AppCmd_s                        , -- out std_logic_vector(  2 downto 0);   -- DDR APP IF
        CpSv_AppAddr_o                  => PrSv_AppAddr_s                       , -- out std_logic_vector( 28 downto 0);   -- DDR APP IF
        CpSl_AppWdfRdy_i                => PrSl_AppWdfRdy_s                     , -- in  std_logic;                        -- DDR APP IF
        CpSl_AppWdfWren_o               => PrSl_AppWdfWren_s                    , -- out std_logic;                        -- DDR APP IF
        CpSl_AppWdfEnd_o                => PrSl_AppWdfEnd_s                     , -- out std_logic;                        -- DDR APP IF
        CpSv_AppWdfData_o               => PrSv_AppWdfData_s                    , -- out std_logic_vector(127 downto 0);   -- DDR APP IF
        CpSl_AppRdDataVld_i             => PrSl_AppRdDataVld_s                  , -- in  std_logic;                        -- DDR APP IF
        CpSv_AppRdData_i                => PrSv_AppRdData_s                     , -- in  std_logic_vector(127 downto 0)    -- DDR APP IF
        CpSv_ChipCtrl0_io               => PrSv_ChipCtrl0_s                     ,
        CpSv_ChipCtrl1_io               => PrSv_ChipCtrl1_s                     ,
        CpSv_ChipCtrl2_io               => PrSv_ChipCtrl2_s
    );

    ------------------------------------
    -- DDR controller
    ------------------------------------
    U_M_DdrCtrl_0 : M_DdrCtrl port map (
        sys_rst                         => CpSl_Rst_iN                          , -- in    std_logic;
        sys_clk_p                       => CpSl_Clk_iP                          , -- in    std_logic;
        sys_clk_n                       => CpSl_Clk_iN                          , -- in    std_logic;
        ui_clk_sync_rst                 => PrSl_DdrRst_s                        , -- out   std_logic;
        ui_clk                          => PrSl_DdrClk_s                        , -- out   std_logic;
        init_calib_complete             => PrSl_DdrRdy_s                        , -- out   std_logic;

        app_addr                        => PrSv_AppAddr_s                       , -- in    std_logic_vector( 28 downto 0);
        app_cmd                         => PrSv_AppCmd_s                        , -- in    std_logic_vector(  2 downto 0);
        app_en                          => PrSl_AppEn_s                         , -- in    std_logic;
        app_wdf_data                    => PrSv_AppWdfData_s                    , -- in    std_logic_vector(127 downto 0);
        app_wdf_end                     => PrSl_AppWdfEnd_s                     , -- in    std_logic;
        app_wdf_mask                    => (others => '0')                      , -- in    std_logic_vector( 15 downto 0);
        app_wdf_wren                    => PrSl_AppWdfWren_s                    , -- in    std_logic;
        app_rd_data                     => PrSv_AppRdData_s                     , -- out   std_logic_vector(127 downto 0);
        app_rd_data_end                 => open                                 , -- out   std_logic;
        app_rd_data_valid               => PrSl_AppRdDataVld_s                  , -- out   std_logic;
        app_rdy                         => PrSl_AppRdy_s                        , -- out   std_logic;
        app_wdf_rdy                     => PrSl_AppWdfRdy_s                     , -- out   std_logic;
        app_sr_req                      => '0'                                  , -- in    std_logic;
        app_sr_active                   => open                                 , -- out   std_logic;
        app_ref_req                     => '0'                                  , -- in    std_logic;
        app_ref_ack                     => open                                 , -- out   std_logic;
        app_zq_req                      => '0'                                  , -- in    std_logic;
        app_zq_ack                      => open                                 , -- out   std_logic;

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
    
    ----------------------------------------------------------------------------
    -- Image pattern generator & image data map
    ----------------------------------------------------------------------------
    ------------------------------------
    -- Test pattern
    ------------------------------------
    U_M_Pattern_0 : M_Pattern port map (
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     => PrSl_PllLocked_s                     , -- in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      => PrSl_ClkLcd_s                        , -- in  std_logic;                        -- Clock

        --------------------------------
        -- Output signals
        --------------------------------
        CpSl_Hsync_o                    => PrSl_SimHsync_s                      , -- out std_logic;
        CpSl_Vsync_o                    => PrSl_SimVsync_s                      , -- out std_logic;
        CpSv_Red0_o                     => PrSv_SimR0_s                         , -- out std_logic_vector(11 downto 0);
        CpSv_Red1_o                     => PrSv_SimR1_s                         , -- out std_logic_vector(11 downto 0);
        CpSv_Red2_o                     => PrSv_SimR2_s                         , -- out std_logic_vector(11 downto 0);
        CpSv_Red3_o                     => PrSv_SimR3_s                           -- out std_logic_vector(11 downto 0)
    );

    ------------------------------------
    -- Image data map
    ------------------------------------
    PrSl_SimSwitch_s  <= '0'; -- 0: Real data, 1: Sim data

    PrSl_Port0Hsync_s <= PrSl_SimHsync_s when (PrSl_SimSwitch_s = '1') else PrSl_RealHsync_s;
    PrSl_Port0Vsync_s <= PrSl_SimVsync_s when (PrSl_SimSwitch_s = '1') else PrSl_RealVsync_s;
    PrSv_Port0R0_s    <= PrSv_SimR0_s    when (PrSl_SimSwitch_s = '1') else PrSv_RealR0_s   ;
    PrSv_Port0R1_s    <= PrSv_SimR1_s    when (PrSl_SimSwitch_s = '1') else PrSv_RealR1_s   ;
    PrSv_Port0R2_s    <= PrSv_SimR2_s    when (PrSl_SimSwitch_s = '1') else PrSv_RealR2_s   ;
    PrSv_Port0R3_s    <= PrSv_SimR3_s    when (PrSl_SimSwitch_s = '1') else PrSv_RealR3_s   ;
    PrSv_Port0G0_s    <= PrSv_SimR0_s    when (PrSl_SimSwitch_s = '1') else PrSv_RealR0_s   ;
    PrSv_Port0G1_s    <= PrSv_SimR1_s    when (PrSl_SimSwitch_s = '1') else PrSv_RealR1_s   ;
    PrSv_Port0G2_s    <= PrSv_SimR2_s    when (PrSl_SimSwitch_s = '1') else PrSv_RealR2_s   ;
    PrSv_Port0G3_s    <= PrSv_SimR3_s    when (PrSl_SimSwitch_s = '1') else PrSv_RealR3_s   ;
    PrSv_Port0B0_s    <= PrSv_SimR0_s    when (PrSl_SimSwitch_s = '1') else PrSv_RealR0_s   ;
    PrSv_Port0B1_s    <= PrSv_SimR1_s    when (PrSl_SimSwitch_s = '1') else PrSv_RealR1_s   ;
    PrSv_Port0B2_s    <= PrSv_SimR2_s    when (PrSl_SimSwitch_s = '1') else PrSv_RealR2_s   ;
    PrSv_Port0B3_s    <= PrSv_SimR3_s    when (PrSl_SimSwitch_s = '1') else PrSv_RealR3_s   ;

    PrSl_Port1Hsync_s <= PrSl_SimHsync_s when (PrSl_SimSwitch_s = '1') else PrSl_RealHsync_s;
    PrSl_Port1Vsync_s <= PrSl_SimVsync_s when (PrSl_SimSwitch_s = '1') else PrSl_RealVsync_s;
    PrSv_Port1R0_s    <= PrSv_SimR0_s    when (PrSl_SimSwitch_s = '1') else PrSv_RealR0_s   ;
    PrSv_Port1R1_s    <= PrSv_SimR1_s    when (PrSl_SimSwitch_s = '1') else PrSv_RealR1_s   ;
    PrSv_Port1R2_s    <= PrSv_SimR2_s    when (PrSl_SimSwitch_s = '1') else PrSv_RealR2_s   ;
    PrSv_Port1R3_s    <= PrSv_SimR3_s    when (PrSl_SimSwitch_s = '1') else PrSv_RealR3_s   ;
    PrSv_Port1G0_s    <= PrSv_SimR0_s    when (PrSl_SimSwitch_s = '1') else PrSv_RealR0_s   ;
    PrSv_Port1G1_s    <= PrSv_SimR1_s    when (PrSl_SimSwitch_s = '1') else PrSv_RealR1_s   ;
    PrSv_Port1G2_s    <= PrSv_SimR2_s    when (PrSl_SimSwitch_s = '1') else PrSv_RealR2_s   ;
    PrSv_Port1G3_s    <= PrSv_SimR3_s    when (PrSl_SimSwitch_s = '1') else PrSv_RealR3_s   ;
    PrSv_Port1B0_s    <= PrSv_SimR0_s    when (PrSl_SimSwitch_s = '1') else PrSv_RealR0_s   ;
    PrSv_Port1B1_s    <= PrSv_SimR1_s    when (PrSl_SimSwitch_s = '1') else PrSv_RealR1_s   ;
    PrSv_Port1B2_s    <= PrSv_SimR2_s    when (PrSl_SimSwitch_s = '1') else PrSv_RealR2_s   ;
    PrSv_Port1B3_s    <= PrSv_SimR3_s    when (PrSl_SimSwitch_s = '1') else PrSv_RealR3_s   ;

    ----------------------------------------------------------------------------
    -- For LCD display, include:
    -- entity: Remapper
    -- entity: SelectIO
    -- FMC port map: 2p
    ----------------------------------------------------------------------------
    ------------------------------------
    -- Remapper
    ------------------------------------
    U_remapper_0 : remapper port map (
        clock                           => PrSl_ClkLcd_s                       , -- in  std_logic;
        hsync                           => PrSl_Port0Hsync_s                   , -- in  std_logic;
        vsync                           => PrSl_Port0Vsync_s                   , -- in  std_logic;
        r1                              => PrSv_Port0R0_s                      , -- in  std_logic_vector( 11 downto 0);
        r2                              => PrSv_Port0R1_s                      , -- in  std_logic_vector( 11 downto 0);
        r3                              => PrSv_Port0R2_s                      , -- in  std_logic_vector( 11 downto 0);
        r4                              => PrSv_Port0R3_s                      , -- in  std_logic_vector( 11 downto 0);
        g1                              => PrSv_Port0G0_s                      , -- in  std_logic_vector( 11 downto 0);
        g2                              => PrSv_Port0G1_s                      , -- in  std_logic_vector( 11 downto 0);
        g3                              => PrSv_Port0G2_s                      , -- in  std_logic_vector( 11 downto 0);
        g4                              => PrSv_Port0G3_s                      , -- in  std_logic_vector( 11 downto 0);
        b1                              => PrSv_Port0B0_s                      , -- in  std_logic_vector( 11 downto 0);
        b2                              => PrSv_Port0B1_s                      , -- in  std_logic_vector( 11 downto 0);
        b3                              => PrSv_Port0B2_s                      , -- in  std_logic_vector( 11 downto 0);
        b4                              => PrSv_Port0B3_s                      , -- in  std_logic_vector( 11 downto 0);
        pardata                         => open                                , -- out std_logic_vector( 55 downto 0);
        pardata_h                       => PrSv_Matrix0H_s                     , -- out std_logic_vector(104 downto 0);
        pardata_l                       => PrSv_Matrix0L_s                       -- out std_logic_vector( 90 downto 0)
    );

    U_remapper_1 : remapper port map (
        clock                           => PrSl_ClkLcd_s                        , -- in  std_logic;
        hsync                           => PrSl_Port1Hsync_s                    , -- in  std_logic;
        vsync                           => PrSl_Port1Vsync_s                    , -- in  std_logic;
        r1                              => PrSv_Port1R0_s                       , -- in  std_logic_vector( 11 downto 0);
        r2                              => PrSv_Port1R1_s                       , -- in  std_logic_vector( 11 downto 0);
        r3                              => PrSv_Port1R2_s                       , -- in  std_logic_vector( 11 downto 0);
        r4                              => PrSv_Port1R3_s                       , -- in  std_logic_vector( 11 downto 0);
        g1                              => PrSv_Port1G0_s                       , -- in  std_logic_vector( 11 downto 0);
        g2                              => PrSv_Port1G1_s                       , -- in  std_logic_vector( 11 downto 0);
        g3                              => PrSv_Port1G2_s                       , -- in  std_logic_vector( 11 downto 0);
        g4                              => PrSv_Port1G3_s                       , -- in  std_logic_vector( 11 downto 0);
        b1                              => PrSv_Port1B0_s                       , -- in  std_logic_vector( 11 downto 0);
        b2                              => PrSv_Port1B1_s                       , -- in  std_logic_vector( 11 downto 0);
        b3                              => PrSv_Port1B2_s                       , -- in  std_logic_vector( 11 downto 0);
        b4                              => PrSv_Port1B3_s                       , -- in  std_logic_vector( 11 downto 0);
        pardata                         => open                                 , -- out std_logic_vector( 55 downto 0);
        pardata_h                       => PrSv_Matrix1H_s                      , -- out std_logic_vector(104 downto 0);
        pardata_l                       => PrSv_Matrix1L_s                        -- out std_logic_vector( 90 downto 0)
    );

    ------------------------------------
    -- SelectIO
    ------------------------------------
    PrSl_SelectIO_s <= '1' when (PrSl_PllLocked_s = '0' or CpSl_Rst_iN = '0') else '0';

    U_M_HSelectIO_0 : M_HSelectIO port map (
        io_reset                        => PrSl_SelectIO_s                      , -- in  std_logic;
        clk_in                          => PrSl_ClkFmc_s                        , -- in  std_logic;
        clk_div_in                      => PrSl_ClkLcd_s                        , -- in  std_logic;
        data_out_from_device            => PrSv_Matrix0H_s                      , -- in  std_logic_vector(104 downto 0);
        data_out_to_pins_p              => PrSv_Matrix0HS_sP                    , -- out std_logic_vector( 14 downto 0);
        data_out_to_pins_n              => PrSv_Matrix0HS_sN                      -- out std_logic_vector( 14 downto 0)
    );

    U_M_LSelectIO_0 : M_LSelectIO port map (
        io_reset                        => PrSl_SelectIO_s                      , -- in  std_logic;
        clk_in                          => PrSl_ClkFmc_s                        , -- in  std_logic;
        clk_div_in                      => PrSl_ClkLcd_s                        , -- in  std_logic;
        data_out_from_device            => PrSv_Matrix0L_s                      , -- in  std_logic_vector(90 downto 0);
        data_out_to_pins_p              => PrSv_Matrix0LS_sP                    , -- out std_logic_vector(12 downto 0);
        data_out_to_pins_n              => PrSv_Matrix0LS_sN                      -- out std_logic_vector(12 downto 0)
    );

    U_M_HSelectIO_1 : M_HSelectIO port map (
        io_reset                        => PrSl_SelectIO_s                      , -- in  std_logic;
        clk_in                          => PrSl_ClkFmc_s                        , -- in  std_logic;
        clk_div_in                      => PrSl_ClkLcd_s                        , -- in  std_logic;
        data_out_from_device            => PrSv_Matrix1H_s                      , -- in  std_logic_vector(104 downto 0);
        data_out_to_pins_p              => PrSv_Matrix1HS_sP                    , -- out std_logic_vector( 14 downto 0);
        data_out_to_pins_n              => PrSv_Matrix1HS_sN                      -- out std_logic_vector( 14 downto 0)
    );

    U_M_LSelectIO_1 : M_LSelectIO port map (
        io_reset                        => PrSl_SelectIO_s                      , -- in  std_logic;
        clk_in                          => PrSl_ClkFmc_s                        , -- in  std_logic;
        clk_div_in                      => PrSl_ClkLcd_s                        , -- in  std_logic;
        data_out_from_device            => PrSv_Matrix1L_s                      , -- in  std_logic_vector(90 downto 0);
        data_out_to_pins_p              => PrSv_Matrix1LS_sP                    , -- out std_logic_vector(12 downto 0);
        data_out_to_pins_n              => PrSv_Matrix1LS_sN                      -- out std_logic_vector(12 downto 0)
    );
        
    ------------------------------------
    -- FMC port map: Port0
    ------------------------------------
    FMC0_LA02_P <= PrSv_Matrix0HS_sP( 0);
    FMC0_LA03_P <= PrSv_Matrix0HS_sP( 1);
    FMC0_LA04_P <= PrSv_Matrix0HS_sP( 2);
    FMC0_LA05_P <= PrSv_Matrix0HS_sP( 3);
    FMC0_LA06_P <= PrSv_Matrix0HS_sP( 4);
    FMC0_LA07_P <= PrSv_Matrix0HS_sP( 5);
    FMC0_LA08_P <= PrSv_Matrix0HS_sP( 6);
    FMC0_LA09_P <= PrSv_Matrix0HS_sP( 7);
    FMC0_LA10_P <= PrSv_Matrix0HS_sP( 8);
    FMC0_LA11_P <= PrSv_Matrix0HS_sP( 9);
    FMC0_LA12_P <= PrSv_Matrix0HS_sP(10);
    FMC0_LA13_P <= PrSv_Matrix0HS_sP(11);
    FMC0_LA14_P <= PrSv_Matrix0HS_sP(12);
    FMC0_LA15_P <= PrSv_Matrix0HS_sP(13);
    FMC0_LA16_P <= PrSv_Matrix0HS_sP(14);

    FMC0_LA19_P <= PrSv_Matrix0LS_sP( 0);
    FMC0_LA20_P <= PrSv_Matrix0LS_sP( 1);
    FMC0_LA21_P <= PrSv_Matrix0LS_sP( 2);
    FMC0_LA22_P <= PrSv_Matrix0LS_sP( 3);
    FMC0_LA23_P <= PrSv_Matrix0LS_sP( 4);
    FMC0_LA24_P <= PrSv_Matrix0LS_sP( 5);
    FMC0_LA25_P <= PrSv_Matrix0LS_sP( 6);
    FMC0_LA26_P <= PrSv_Matrix0LS_sP( 7);
    FMC0_LA27_P <= PrSv_Matrix0LS_sP( 8);
    FMC0_LA28_P <= PrSv_Matrix0LS_sP( 9);
    FMC0_LA29_P <= PrSv_Matrix0LS_sP(10);
    FMC0_LA30_P <= PrSv_Matrix0LS_sP(11);
    FMC0_LA31_P <= PrSv_Matrix0LS_sP(12);

    FMC0_LA32_N <= PrSl_PllLocked_s;
    FMC0_LA_N   <= PrSv_Matrix0LS_sN
                 & PrSv_Matrix0HS_sN;

    ------------------------------------
    -- FMC port map: Port1
    ------------------------------------
    FMC1_LA02_P <= PrSv_Matrix1HS_sP( 0);
    FMC1_LA03_P <= PrSv_Matrix1HS_sP( 1);
    FMC1_LA04_P <= PrSv_Matrix1HS_sP( 2);
    FMC1_LA05_P <= PrSv_Matrix1HS_sP( 3);
    FMC1_LA06_P <= PrSv_Matrix1HS_sP( 4);
    FMC1_LA07_P <= PrSv_Matrix1HS_sP( 5);
    FMC1_LA08_P <= PrSv_Matrix1HS_sP( 6);
    FMC1_LA09_P <= PrSv_Matrix1HS_sP( 7);
    FMC1_LA10_P <= PrSv_Matrix1HS_sP( 8);
    FMC1_LA11_P <= PrSv_Matrix1HS_sP( 9);
    FMC1_LA12_P <= PrSv_Matrix1HS_sP(10);
    FMC1_LA13_P <= PrSv_Matrix1HS_sP(11);
    FMC1_LA14_P <= PrSv_Matrix1HS_sP(12);
    FMC1_LA15_P <= PrSv_Matrix1HS_sP(13);
    FMC1_LA16_P <= PrSv_Matrix1HS_sP(14);

    FMC1_LA19_P <= PrSv_Matrix1LS_sP( 0);
    FMC1_LA20_P <= PrSv_Matrix1LS_sP( 1);
    FMC1_LA21_P <= PrSv_Matrix1LS_sP( 2);
    FMC1_LA22_P <= PrSv_Matrix1LS_sP( 3);
    FMC1_LA23_P <= PrSv_Matrix1LS_sP( 4);
    FMC1_LA24_P <= PrSv_Matrix1LS_sP( 5);
    FMC1_LA25_P <= PrSv_Matrix1LS_sP( 6);
    FMC1_LA26_P <= PrSv_Matrix1LS_sP( 7);
    FMC1_LA27_P <= PrSv_Matrix1LS_sP( 8);
    FMC1_LA28_P <= PrSv_Matrix1LS_sP( 9);
    FMC1_LA29_P <= PrSv_Matrix1LS_sP(10);
    FMC1_LA30_P <= PrSv_Matrix1LS_sP(11);
    FMC1_LA31_P <= PrSv_Matrix1LS_sP(12);

    FMC1_LA32_N <= PrSl_PllLocked_s;
    FMC1_LA_N   <= PrSv_Matrix1LS_sN
                 & PrSv_Matrix1HS_sN;

    ----------------------------------------------------------------------------
    -- External interface
    -- LED: 4bit
    -- SMA: 4bit
    -- GPIO: 5bit
    ----------------------------------------------------------------------------
    ------------------------------------
    -- LED
    ------------------------------------
    CpSv_Led_o(3 downto 0) <= PrSv_FreLed_s;

    ------------------------------------
    -- SMA
    ------------------------------------
    CpSv_Sma_o(0) <= PrSl_DVISync_SMA_s;
    CpSv_Sma_o(1) <= PrSl_LCDSync_SMA_s;
    CpSv_Sma_o(2) <= '0';
    CpSv_Sma_o(3) <= '0';

    ------------------------------------
    -- GPIO output
    -- Test Pulse
    -- Done signal
    ------------------------------------
    CpSl_Gpio_o <= PrSl_PllLocked_s;


end arch_M_Lcd4Top;