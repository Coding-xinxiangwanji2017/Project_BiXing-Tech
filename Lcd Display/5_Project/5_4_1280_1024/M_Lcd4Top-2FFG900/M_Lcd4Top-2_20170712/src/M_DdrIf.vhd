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
-- 文件名称  :  M_DdrIf.vhd
-- 设    计  :  Zhang Wenjun
-- 邮    件  :  wenjunzhang@bixing-tech.com
-- 校    对  :
-- 设计日期  :  2016/01/28
-- 功能简述  :  DVI/LCD/DDR
-- 版本序号  :  0.1
-- 修改历史  :  1. Initial, Zhang Wenjun, 2016/01/28
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity M_DdrIf is
    port (
        --------------------------------
        -- DVI/Ext VSync
        --------------------------------
        CpSl_LcdSync_i                  : in  std_logic;                        -- Vsync

        --------------------------------
        -- SMA V Sync
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
        CpSv_ChipCtrl0_io               : inout std_logic_vector(35 downto 0);
        CpSv_ChipCtrl1_io               : inout std_logic_vector(35 downto 0);
        CpSv_ChipCtrl2_io               : inout std_logic_vector(35 downto 0)
    );
end M_DdrIf;

architecture arch_M_DdrIf of M_DdrIf is
    ----------------------------------------------------------------------------
    -- constant declaration
    ----------------------------------------------------------------------------
    constant PrSv_DviSyncCnt_1ms_s      : std_logic_vector(19 downto 0) := x"28488"; -- 1/165MHz per clock
    constant PrSv_LCDSyncCnt_1ms_s      : std_logic_vector(19 downto 0) := x"13880"; -- 1/80MHz per clock
    ----------------------------------------------------------------------------
    -- Constant declaration
    -- Clock = 80MHz
    -- (200Hz is not supported at this case)
    ------------------------------------
    -- Counter End Calculation
    -- Clock(MHz) / 1130 / Refresh Freq
    -- 1: 200Hz Refresh Rate :
    --       80 / 1126 / 200 = 355
    -- 2: 100Hz Refresh Rate :
    --      120 / 1126 / 200 = 533
    -- 3: 67Hz Refresh Rate:
    --       80 / 1126 / 134 = 530
    ------------------------------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    -- constant declaration
    ----------------------------------------------------------------------------
    ------------------------------------
    -- VCnt declaration
    ------------------------------------
    constant PrSv_VPreStart_c           : std_logic_vector(11 downto 0) := x"04A"; -- 74
    constant PrSv_VStart_c              : std_logic_vector(11 downto 0) := x"04B"; -- 75
    constant PrSv_VPreStop_c            : std_logic_vector(11 downto 0) := x"44A"; -- 1098
    constant PrSv_VStop_c               : std_logic_vector(11 downto 0) := x"44B"; -- 1099
    constant PrSv_VEnd_c                : std_logic_vector(11 downto 0) := x"464"; -- 1125

    ------------------------------------
    -- HCnt declaration
    ------------------------------------
    constant PrSv_Ref200Hz_Start_c      : std_logic_vector(11 downto 0) := x"012";  -- 18
    constant PrSv_Ref100Hz_Start_c      : std_logic_vector(11 downto 0) := x"080";  -- 128
    constant PrSv_Ref67Hz_Start_c       : std_logic_vector(11 downto 0) := x"080";  -- 128

    constant PrSv_Ref200Hz_Stop_c       : std_logic_vector(11 downto 0) := x"152";  -- 338
    constant PrSv_Ref100Hz_Stop_c       : std_logic_vector(11 downto 0) := x"1C0";  -- 448
    constant PrSv_Ref67Hz_Stop_c        : std_logic_vector(11 downto 0) := x"1C0";  -- 448


    constant PrSv_Ref200Hz_End_c        : std_logic_vector(11 downto 0) := x"164";  -- 356
    constant PrSv_Ref100Hz_End_c        : std_logic_vector(11 downto 0) := x"211";  -- 530
    constant PrSv_Ref67Hz_End_c         : std_logic_vector(11 downto 0) := x"20F";  -- 528

    ------------------------------------
    -- Refrate Contral declaration
    ------------------------------------
    constant PrSv_Ref200Hz_c            : std_logic_vector( 2 downto 0) := "100";   -- 200Hz
    constant PrSv_Ref100Hz_c            : std_logic_vector( 2 downto 0) := "010";   -- 100Hz
    constant PrSv_Ref67Hz_c             : std_logic_vector( 2 downto 0) := "001";   -- 67Hz

    ----------------------------------------------------------------------------
    -- component declaration
    ----------------------------------------------------------------------------
    -- ChipScope
    component M_Ila port (
        control                         : inout std_logic_vector(35 downto 0);
        clk                             : in    std_logic;
        trig0                           : in    std_logic_vector(63 downto 0)
    );
    end component;

--    component M_Ila_DDR port (
--        control                         : inout std_logic_vector(35 downto 0);
--        clk                             : in    std_logic;
--        trig0                           : in    std_logic_vector(255 downto 0)
--    );
--    end component;

    -- component
    component M_DviRxFifo port (
        rst                             : in  std_logic;
        wr_clk                          : in  std_logic;
        wr_en                           : in  std_logic;
        din                             : in  std_logic_vector( 15 downto 0);
        full                            : out std_logic;

        rd_clk                          : in  std_logic;
        rd_en                           : in  std_logic;
        dout                            : out std_logic_vector(127 downto 0);
        empty                           : out std_logic
    );
    end component;

    component M_LcdTxFifo port (
        rst                             : in  std_logic;
        wr_clk                          : in  std_logic;
        wr_en                           : in  std_logic;
        din                             : in  std_logic_vector(127 downto 0);
        full                            : out std_logic;

        rd_clk                          : in  std_logic;
        rd_en                           : in  std_logic;
        dout                            : out std_logic_vector( 31 downto 0);
        empty                           : out std_logic
    );
    end component;

    component pulse2pulse port (
        in_clk                          :in  std_logic;
        out_clk                         :in  std_logic;
        rst                             :in  std_logic;
        pulsein                         :in  std_logic;
        inbusy                          :out std_logic;
        pulseout                        :out std_logic
    );
    end component;
    ----------------------------------------------------------------------------
    -- signal declaration
    ----------------------------------------------------------------------------
    -- ChipScope
    signal PrSv_ChipCtrl0_s             : std_logic_vector( 35 downto 0);       -- Chipscope control0
    signal PrSl_ChipClk0_s              : std_logic;                            -- Chipscope clock0
    signal PrSv_ChipTrig0_s             : std_logic_vector( 63 downto 0);       -- Chipscope trigger0
    signal PrSv_ChipCtrl1_s             : std_logic_vector( 35 downto 0);       -- Chipscope control1
    signal PrSl_ChipClk1_s              : std_logic;                            -- Chipscope clock1
    signal PrSv_ChipTrig1_s             : std_logic_vector( 63 downto 0);       -- Chipscope trigger1
    signal PrSv_ChipCtrl2_s             : std_logic_vector( 35 downto 0);       -- Chipscope control2
    signal PrSl_ChipClk2_s              : std_logic;                            -- Chipscope clock2
    signal PrSv_ChipTrig2_s             : std_logic_vector( 255 downto 0);      -- Chipscope trigger2

    signal PrSl_Dvi0Hsync_s             : std_logic;                            -- DVI clk inverse
    signal PrSv_DviHCnt_s               : std_logic_vector( 15 downto 0);
    signal PrSv_DviVCnt_s               : std_logic_vector( 15 downto 0);

    -- SMA Syc
    signal PrSv_DviVSync_Cnt_s          : std_logic_vector( 19 downto 0);       -- Counter to Delay DVI VSync
    signal PrSv_LCDVSync_Cnt_s          : std_logic_vector( 19 downto 0);       -- Counter to Delay LCD VSync

    -- VSync
    signal PrSl_VsyncDly1_s             : std_logic;                            -- CpSl_Vsync_i Dly 1 Clk
    signal PrSl_VsyncDly2_s             : std_logic;                            -- CpSl_Vsync_i Dly 2 Clk
    signal PrSl_VsyncDly3_s             : std_logic;                            -- CpSl_Vsync_i Dly 3 Clk
    signal PrSl_LcdVSync_s              : std_logic;                            -- Lcd Vsync

    signal PrSv_HCnt_Start_s            : std_logic_vector(11 downto 0);        -- HCnt_Start
    signal PrSv_HCnt_Stop_s             : std_logic_vector(11 downto 0);        -- Hcnt_Stop
    signal PrSv_HCnt_End_s              : std_logic_vector(11 downto 0);        -- HCnt_End

    -- DDR_Pre_Read
    signal PrSl_Hsync_Pre_s             : std_logic;                            -- Hsync_Pre
    signal PrSl_Vsync_Ddr_s             : std_logic;                            -- Vsync_Ddr_Pre
    signal PrSl_Hsync_Ddr_s             : std_logic;                            -- Hsync_Ddr_Pre
    signal PrSl_Reset_s                 : std_logic;                            -- pulse2pulse reset active high
    signal PrSl_PreVdisDvld_s           : std_logic;                            -- Lcd Pre DDR Read

    -- DVI in
    signal PrSl_DviClk_s                : std_logic;                            -- DVI clk inverse
    signal PrSl_DviDeDly_s              : std_logic;                            -- Delay CpSl_Dvi0De_i in DVI clk
    signal PrSv_CntDataIn_s             : std_logic_vector( 10 downto 0);       -- DVI input data counter
    signal PrSl_DviDvld_s               : std_logic;                            -- DVI input data valid
    signal PrSl_WfifoWen_s              : std_logic;                            -- Write DDR FIFO write enable
    signal PrSv_Dvi0RDly1_s             : std_logic_vector(  7 downto 0);       -- Delay DVI0 data 1 clk
    signal PrSv_Dvi0RDly2_s             : std_logic_vector(  7 downto 0);       -- Delay DVI0 data 2 clk
    signal PrSv_Dvi1RDly1_s             : std_logic_vector(  7 downto 0);       -- Delay DVI1 data 1 clk
    signal PrSv_WfifoWdata_s            : std_logic_vector( 15 downto 0);       -- Write DDR FIFO write data
    signal PrSl_WfifoFull_s             : std_logic;                            -- Write DDR FIFO full
    signal PrSl_WfifoRen_s              : std_logic;                            -- Write DDR FIFO read enable
    signal PrSv_WfifoRdata_s            : std_logic_vector(127 downto 0);       -- Write DDR FIFO read data
    signal PrSl_WfifoEmpty_s            : std_logic;                            -- Write DDR FIFO empty
    signal PrSl_DviVsyncDly1_s          : std_logic;                            -- Delay CpSl_Dvi0Vsync_i 1 clk
    signal PrSl_DviVsyncDly2_s          : std_logic;                            -- Delay CpSl_Dvi0Vsync_i 2 clk
    signal PrSl_DviVsyncDly3_s          : std_logic;                            -- Delay CpSl_Dvi0Vsync_i 3 clk
    signal PrSl_DviDeDly1_s             : std_logic;                            -- Delay CpSl_Dvi0De_i 1 clk
    signal PrSl_DviDeDly2_s             : std_logic;                            -- Delay CpSl_Dvi0De_i 2 clk
    signal PrSl_DviDeDly3_s             : std_logic;                            -- Delay CpSl_Dvi0De_i 3 clk
    signal PrSl_RowWrTrig_s             : std_logic;                            -- Row data write DDR trigger

    -- LCD out
    signal PrSl_LcdDouble_s             : std_logic;                            -- Lcd Double 
    signal PrSl_LcdDoubleDly1_s         : std_logic;                            -- Lcd Double Delay 1 Clk
    signal PrSl_LcdDoubleDly2_s         : std_logic;                            -- Lcd Double Delay 2 Clk
    signal PrSv_FreChoiceDly1_s	        : std_logic_vector( 2  downto 0);       -- Frequence Choice Dly 1 Clk
    signal PrSv_FreChoiceDly2_s			: std_logic_vector( 2  downto 0);       -- Frequence Choice Dly 2 Clk
    signal PrSv_HCnt_s                  : std_logic_vector( 11 downto 0);       -- H counter
    signal PrSv_VCnt_s                  : std_logic_vector( 11 downto 0);       -- V counter
    signal PrSl_Hsync_s                 : std_logic;                            -- Inner Hsync
    signal PrSl_Vsync_s                 : std_logic;                            -- Inner Vsync
    signal PrSl_HdisDvld_s              : std_logic;                            -- H display data valid
    signal PrSl_VdisDvld_s              : std_logic;                            -- V display data valid
    signal PrSl_RfifoFull_s             : std_logic;                            -- Read DDR FIFO full
    signal PrSl_RfifoRen_s              : std_logic;                            -- Read DDR FIFO read enable
    signal PrSv_RfifoRdata_s            : std_logic_vector( 31 downto 0);       -- Read DDR FIFO read data
    signal PrSl_RfifoEmpty_s            : std_logic;                            -- Read DDR FIFO empty
    signal PrSl_LcdVsyncDly1_s          : std_logic;                            -- LCD Vsync delay 1 ddr clk
    signal PrSl_LcdVsyncDly2_s          : std_logic;                            -- LCD Vsync delay 2 ddr clk
    signal PrSl_LcdVsyncDly3_s          : std_logic;                            -- LCD Vsync delay 3 ddr clk
    signal PrSl_LcdHsyncDly1_s          : std_logic;                            -- LCD Display Hsync delay 1 ddr clk
    signal PrSl_LcdHsyncDly2_s          : std_logic;                            -- LCD Display Hsync delay 2 ddr clk
    signal PrSl_LcdHsyncDly3_s          : std_logic;                            -- LCD Display Hsync delay 3 ddr clk
    signal PrSl_RowRdTrig_s             : std_logic;                            -- Row data read DDR trigger
    signal PrSl_RxFifo_s                : std_logic;

    -- DDR
    signal PrSl_WrCmdReq_s              : std_logic;                            -- Write command request
    signal PrSl_RdCmdReq_s              : std_logic;                            -- Read command request
    signal PrSv_CmdState_s              : std_logic_vector(  1 downto 0);       -- Command state
    signal PrSv_CmdCnt_s                : std_logic_vector(  6 downto 0);       -- Command counter
    signal PrSl_WrDataReq_s             : std_logic;                            -- Write data requests
    signal PrSl_WrDataState_s           : std_logic;                            -- Data state
    signal PrSv_WrDataCnt_s             : std_logic_vector(  6 downto 0);       -- Data counter
    signal PrSv_WrAddrLow_s             : std_logic_vector(  9 downto 0);       -- Write address low
    signal PrSv_RdAddrLow_s             : std_logic_vector(  9 downto 0);       -- Read address low
    signal PrSv_WrAddrMid_s             : std_logic_vector( 10 downto 0);       -- Write address middle
    signal PrSv_RdAddrMid_s             : std_logic_vector( 10 downto 0);       -- Read address middele
    signal PrSv_WrAddrHig_s             : std_logic_vector(  2 downto 0);       -- Write address high
    signal PrSv_RdAddrHig_s             : std_logic_vector(  2 downto 0);       -- Read address high

begin

    ----------------------------------------------------------------------------
    -- Chipscope
    ----------------------------------------------------------------------------
    CpSv_ChipCtrl0_io <= PrSv_ChipCtrl0_s;
    CpSv_ChipCtrl1_io <= PrSv_ChipCtrl1_s;

    -------------------------------------------------
    --Capture the DVI clock area signals
    -------------------------------------------------
    U_M_Ila_0 : M_Ila port map (
        control                         => PrSv_ChipCtrl0_s                     ,
        clk                             => PrSl_ChipClk0_s                      ,
        trig0                           => PrSv_ChipTrig0_s
    );

    PrSl_ChipClk0_s <= PrSl_DviClk_s;

    PrSv_ChipTrig0_s(           0) <= CpSl_Dvi0Vsync_i;
    PrSv_ChipTrig0_s(           1) <= CpSl_Dvi0Hsync_i;
    PrSv_ChipTrig0_s(           2) <= CpSl_Dvi0De_i   ;
    PrSv_ChipTrig0_s(           3) <= CpSl_Dvi0Scdt_i ;
    PrSv_ChipTrig0_s(11 downto  4) <= CpSv_Dvi0R_i    ;
    PrSv_ChipTrig0_s(          12) <= CpSl_Dvi1Scdt_i ;
    PrSv_ChipTrig0_s(20 downto 13) <= CpSv_Dvi1R_i    ;
    PrSv_ChipTrig0_s(31 downto 21) <= PrSv_CntDataIn_s;
    PrSv_ChipTrig0_s(47 downto 32) <= PrSv_DviHCnt_s;
    PrSv_ChipTrig0_s(63 downto 48) <= PrSv_DviVCnt_s;

    -------------------------------------------------
    --Capture the LCD clock area signals
    -------------------------------------------------
    U_M_Ila_1 : M_Ila port map (
        control                         => PrSv_ChipCtrl1_s                     ,
        clk                             => PrSl_ChipClk1_s                      ,
        trig0                           => PrSv_ChipTrig1_s
    );

    PrSl_ChipClk1_s <= CpSl_LcdClk_i;

    PrSv_ChipTrig1_s(           0) <= PrSl_Hsync_s               ;
    PrSv_ChipTrig1_s(           1) <= PrSl_Vsync_s               ;
    PrSv_ChipTrig1_s(9  downto  2) <= PrSv_RfifoRdata_s(31 downto 24);
    PrSv_ChipTrig1_s(17 downto 10) <= PrSv_RfifoRdata_s(23 downto 16);
    PrSv_ChipTrig1_s(25 downto 18) <= PrSv_RfifoRdata_s(15 downto  8);
    PrSv_ChipTrig1_s(33 downto 26) <= PrSv_RfifoRdata_s( 7 downto  0);

    PrSv_ChipTrig1_s(45 downto 34) <= PrSv_HCnt_s(11 downto 0);
    PrSv_ChipTrig1_s(56 downto 46) <= PrSv_VCnt_s(10 downto 0);
    PrSv_ChipTrig1_s(          57) <= PrSl_LcdVSync_s;
    PrSv_ChipTrig1_s(          58) <= CpSl_DdrRdy_i;
    PrSv_ChipTrig1_s(          59) <= PrSl_RfifoEmpty_s;
    PrSv_ChipTrig1_s(          60) <= '0';
    PrSv_ChipTrig1_s(          61) <= PrSl_RfifoRen_s;
    PrSv_ChipTrig1_s(63 downto 62) <= CpSv_FreChoice_i(1 downto 0);

    -------------------------------------------------
    --Capture the DDR clock area signals
    -------------------------------------------------
--	U_M_Ila_2 : M_Ila_DDR port map (
--        control                         => PrSv_ChipCtrl2_s                     ,
--        clk                             => PrSl_ChipClk2_s                      ,
--        trig0                           => PrSv_ChipTrig2_s
--    );
--
--    PrSl_ChipClk2_s                <= CpSl_DdrClk_i;
--
--    PrSv_ChipTrig2_s(           0) <= '1' when (PrSl_DviVsyncDly2_s = '0' and PrSl_DviVsyncDly3_s = '1') else '0' ; -- DVI V_Sync
--    PrSv_ChipTrig2_s(           1) <= '1' when (PrSl_LcdVsyncDly2_s = '1' and PrSl_LcdVsyncDly3_s = '0') else '0' ; -- LCD V_Sync
--    --PrSv_ChipTrig2_s(           2) <= PrSl_Lcd_Inter_VSync_s;
--    PrSv_ChipTrig2_s(           3) <= PrSl_RowWrTrig_s;  -- DVI H_Sync
--    PrSv_ChipTrig2_s(           4) <= PrSl_RowRdTrig_s;  -- LCD H_Sync
--    PrSv_ChipTrig2_s(28 downto  5) <= PrSv_WrAddrHig_s & PrSv_WrAddrMid_s & PrSv_WrAddrLow_s;  -- Write Address
--    PrSv_ChipTrig2_s(52 downto 29) <= PrSv_RdAddrHig_s & PrSv_RdAddrMid_s & PrSv_RdAddrLow_s;  -- Read  Address
--    PrSv_ChipTrig2_s(          53) <= PrSv_CmdState_s(0);  -- Read/Write
--    PrSv_ChipTrig2_s(          54) <= CpSl_DdrRdy_i;
--    PrSv_ChipTrig2_s(63 downto 55) <= (others => '0');
--
--    PrSv_ChipTrig2_s(127 downto 64)  <= PrSv_WfifoRdata_s(63 downto 0);
--	PrSv_ChipTrig2_s(255 downto 128) <= CpSv_AppRdData_i(127 downto 0);

    ----------------------------------------------------------------------------
    -- DVI input, DVI clk domain
    ----------------------------------------------------------------------------
    PrSl_DviClk_s <= CpSl_Dvi0Clk_i;

    -- Delay De
    process (CpSl_DdrRdy_i, PrSl_DviClk_s) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSl_DviDeDly_s <= '0';
        elsif rising_edge(PrSl_DviClk_s) then
            PrSl_DviDeDly_s <= CpSl_Dvi0De_i;
        end if;
    end process;

    -- H counter
    process (CpSl_DdrRdy_i, PrSl_DviClk_s) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSv_DviHCnt_s      <= (others => '0');
            PrSl_Dvi0Hsync_s    <= '0';
        elsif rising_edge(PrSl_DviClk_s) then
            if (CpSl_Dvi0Hsync_i = '1') then
                PrSv_DviHCnt_s <= (others => '0');
            else
                PrSv_DviHCnt_s <= PrSv_DviHCnt_s + '1';
            end if;

            PrSl_Dvi0Hsync_s    <= CpSl_Dvi0Hsync_i;
        end if;
    end process;

    -- V counter
    process (CpSl_DdrRdy_i, PrSl_DviClk_s) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSv_DviVCnt_s <= (others => '0');
        elsif rising_edge(PrSl_DviClk_s) then
            if (CpSl_Dvi0Vsync_i = '0') then
                PrSv_DviVCnt_s  <= (others => '0');
            elsif (PrSl_Dvi0Hsync_s = '0' and CpSl_Dvi0Hsync_i = '1') then
                PrSv_DviVCnt_s <= PrSv_DviVCnt_s + '1';
            else -- hold
            end if;
        end if;
    end process;

    -- Cnt data in
    process (CpSl_DdrRdy_i, PrSl_DviClk_s) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSv_CntDataIn_s <= (others => '0');
        elsif rising_edge(PrSl_DviClk_s) then
            if (PrSl_DviDeDly_s = '1') then
                PrSv_CntDataIn_s <= PrSv_CntDataIn_s + '1';
            else
                PrSv_CntDataIn_s <= (others => '0');
            end if;
        end if;
    end process;

    -- DVI data valid
    process (CpSl_DdrRdy_i, PrSl_DviClk_s) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSl_DviDvld_s <= '0';
        elsif rising_edge(PrSl_DviClk_s) then
            if (CpSl_Dvi0Scdt_i = '1') then
                if (CpSl_Dvi1Scdt_i = '1') then
                    if (PrSl_DviDeDly_s = '1' and PrSv_CntDataIn_s = 0) then
                        PrSl_DviDvld_s <= '1';
                    elsif (PrSv_CntDataIn_s = 640) then
                        PrSl_DviDvld_s <= '0';
                    else -- hold
                    end if;
                else
                    if (PrSl_DviDeDly_s = '1' and PrSv_CntDataIn_s = 0) then
                        PrSl_DviDvld_s <= '1';
                    elsif (PrSv_CntDataIn_s = 1280) then
                        PrSl_DviDvld_s <= '0';
                    else -- hold
                    end if;
                end if;
            else
                PrSl_DviDvld_s <= '0';
            end if;
        end if;
    end process;

    -- FIFO write enable
    process (CpSl_DdrRdy_i, PrSl_DviClk_s) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSl_WfifoWen_s <= '0';
        elsif rising_edge(PrSl_DviClk_s) then
            if (CpSl_Dvi1Scdt_i = '1') then
                PrSl_WfifoWen_s <= PrSl_DviDvld_s;
            else
                PrSl_WfifoWen_s <= PrSl_DviDvld_s and PrSv_CntDataIn_s(0);
            end if;
        end if;
    end process;

    -- Delay R
    process (CpSl_DdrRdy_i, PrSl_DviClk_s) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSv_Dvi0RDly1_s <= (others => '0');
            PrSv_Dvi0RDly2_s <= (others => '0');

            PrSv_Dvi1RDly1_s <= (others => '0');
        elsif rising_edge(PrSl_DviClk_s) then

            -- Connecting to real data
            PrSv_Dvi0RDly1_s <= CpSv_Dvi0R_i;

			-- This is only for testing debugging.
--            PrSv_Dvi0RDly1_s <= PrSv_CntDataIn_s(7 downto 0) + 1;

            PrSv_Dvi0RDly2_s <= PrSv_Dvi0RDly1_s;

            PrSv_Dvi1RDly1_s <= CpSv_Dvi1R_i;
        end if;
    end process;

    -- FIFO write data
    process (CpSl_DdrRdy_i, PrSl_DviClk_s) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSv_WfifoWdata_s <= (others => '0');
        elsif rising_edge(PrSl_DviClk_s) then
            if (CpSl_Dvi1Scdt_i = '1') then
                PrSv_WfifoWdata_s <= PrSv_Dvi0RDly1_s & PrSv_Dvi1RDly1_s;
            else
                PrSv_WfifoWdata_s <= PrSv_Dvi0RDly2_s & PrSv_Dvi0RDly1_s;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------------------
    -- DDR writ FIFO
    ----------------------------------------------------------------------------
    -- FIFO Rest
    PrSl_RxFifo_s <= (not PrSl_DviVsyncDly2_s) and PrSl_DviVsyncDly3_s;

    U_M_DviRxFifo_0 : M_DviRxFifo port map (
        rst                             => PrSl_RxFifo_s                        , -- in  std_logic;
        wr_clk                          => PrSl_DviClk_s                        , -- in  std_logic;
        wr_en                           => PrSl_WfifoWen_s                      , -- in  std_logic;
        din                             => PrSv_WfifoWdata_s                    , -- in  std_logic_vector( 15 downto 0);
        full                            => PrSl_WfifoFull_s                     , -- out std_logic;

        rd_clk                          => CpSl_DdrClk_i                        , -- in  std_logic;
        rd_en                           => PrSl_WfifoRen_s                      , -- in  std_logic;
        dout                            => PrSv_WfifoRdata_s                    , -- out std_logic_vector(127 downto 0);
        empty                           => PrSl_WfifoEmpty_s                      -- out std_logic
    );


    -- Write DDR FIFO read enable
    PrSl_WfifoRen_s <= CpSl_AppWdfRdy_i when PrSl_WrDataState_s = '1' else '0';

    -- Write DDR FIFO read data
    CpSv_AppWdfData_o <= PrSv_WfifoRdata_s;

    -- DDR write data enable/end
    CpSl_AppWdfWrEn_o <= CpSl_AppWdfRdy_i when PrSl_WrDataState_s = '1' else '0';
    CpSl_AppWdfEnd_o  <= CpSl_AppWdfRdy_i when PrSl_WrDataState_s = '1' else '0';

    ----------------------------------------------------------------------------
    -- DDR write control
    ----------------------------------------------------------------------------
    -- Delay Cpsl_Dvi0Vsync_i, CpSl_Dvi0De_i 3 clk
    process (CpSl_DdrRdy_i, CpSl_DdrClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSl_DviVsyncDly1_s <= '0';
            PrSl_DviVsyncDly2_s <= '0';
            PrSl_DviVsyncDly3_s <= '0';

            PrSl_DviDeDly1_s <= '0';
            PrSl_DviDeDly2_s <= '0';
            PrSl_DviDeDly3_s <= '0';
        elsif rising_edge(CpSl_DdrClk_i) then
            PrSl_DviVsyncDly1_s <= CpSl_Dvi0Vsync_i   ;
            PrSl_DviVsyncDly2_s <= PrSl_DviVsyncDly1_s;
            PrSl_DviVsyncDly3_s <= PrSl_DviVsyncDly2_s;

            PrSl_DviDeDly1_s <= CpSl_Dvi0De_i   ;
            PrSl_DviDeDly2_s <= PrSl_DviDeDly1_s;
            PrSl_DviDeDly3_s <= PrSl_DviDeDly2_s;
        end if;
    end process;

    -- Row data write DDR trigger
    PrSl_RowWrTrig_s <= (not PrSl_DviDeDly2_s) and PrSl_DviDeDly3_s;

    ----------------------------------------------------------------------------
    -- Internal/External Sync In
    ----------------------------------------------------------------------------
    -- Delay CpSl_LcdSync_i 3 clk
    process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSl_VsyncDly1_s <= '0';
            PrSl_VsyncDly2_s <= '0';
            PrSl_VsyncDly3_s <= '0';

        elsif rising_edge(CpSl_LcdClk_i) then
            PrSl_VsyncDly1_s <= CpSl_LcdSync_i;
            PrSl_VsyncDly2_s <= PrSl_VsyncDly1_s;
            PrSl_VsyncDly3_s <= PrSl_VsyncDly2_s;

        end if;
    end process;
    
    -- Lcd Double signle
--    process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
--        if (CpSl_DdrRdy_i = '0') then 
--            PrSl_LcdDouble_s <= '0';
--        elsif rising_edge(CpSl_LcdClk_i) then 
--            if (PrSv_HCnt_s = PrSv_HCnt_End_s
--                and PrSv_VCnt_s = PrSv_VEnd_c) then 
--                PrSl_LcdDouble_s <= '1';
--            elsif (PrSl_VsyncDly3_s = '1') then 
--                PrSl_LcdDouble_s <= '0';
--            else -- hold
--            end if;
--        end if;
--    end process;
--
--    process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
--        if (CpSl_DdrRdy_i = '0') then
--            PrSl_LcdDoubleDly1_s <= '0';
--            PrSl_LcdDoubleDly2_s <= '0';
--
--        elsif rising_edge(CpSl_LcdClk_i) then
--            PrSl_LcdDoubleDly1_s <= PrSl_LcdDouble_s;
--            PrSl_LcdDoubleDly2_s <= PrSl_LcdDoubleDly1_s;
--
--        end if;
--    end process;
    
    -- use the Vsync for Lcd output image
--    PrSl_LcdVSync_s <= '1' when (PrSl_VsyncDly2_s = '1' and PrSl_VsyncDly3_s = '0') else
--                        '1' when (PrSl_LcdDoubleDly1_s = '1' and PrSl_LcdDoubleDly2_s = '0') else
--                        '0';
    PrSl_LcdVSync_s <= '1' when (PrSl_VsyncDly2_s = '1' and PrSl_VsyncDly3_s = '0') else
                        '0';
							  
    ----------------------------------------------------------------------------
    -- LCD timing generation
    ----------------------------------------------------------------------------
    process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSv_FreChoiceDly1_s  <= (others => '0');
            PrSv_FreChoiceDly2_s  <= (others => '0');
        elsif rising_edge(CpSl_LcdClk_i) then
            PrSv_FreChoiceDly1_s  <= CpSv_FreChoice_i;
            PrSv_FreChoiceDly2_s  <= PrSv_FreChoiceDly1_s;
        end if;
    end process;

	 -- H Counter Selection based on the refresh rate
	 process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSv_HCnt_Start_s   <= (others => '0');
            PrSv_HCnt_Stop_s    <= (others => '0');
            PrSv_HCnt_End_s     <= (others => '0');

        elsif rising_edge(CpSl_LcdClk_i) then
            case PrSv_FreChoiceDly2_s is
                when PrSv_Ref67Hz_c =>  -- 67Hz Refresh Rate
                    PrSv_HCnt_Start_s   <= PrSv_Ref67Hz_Start_c;
                    PrSv_HCnt_Stop_s    <= PrSv_Ref67Hz_Stop_c;
                    PrSv_HCnt_End_s 	<= PrSv_Ref67Hz_End_c;

                when PrSv_Ref100Hz_c =>  -- 100Hz Refresh Rate
                    PrSv_HCnt_Start_s   <= PrSv_Ref100Hz_Start_c;
                    PrSv_HCnt_Stop_s    <= PrSv_Ref100Hz_Stop_c;
                    PrSv_HCnt_End_s 	<= PrSv_Ref100Hz_End_c;

                when PrSv_Ref200Hz_c =>  -- 200Hz Refresh Rate
                    PrSv_HCnt_Start_s   <= PrSv_Ref200Hz_Start_c;
                    PrSv_HCnt_Stop_s    <= PrSv_Ref200Hz_Stop_c;
                    PrSv_HCnt_End_s 	<= PrSv_Ref200Hz_End_c;

                when others =>
                    PrSv_HCnt_Start_s   <= (others => '0');
                    PrSv_HCnt_Stop_s    <= (others => '0');
                    PrSv_HCnt_End_s     <= (others => '0');

            end case;
        end if;
    end process;
    
    -- Lcd HCnt
    process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSv_HCnt_s <= (others => '0');
        elsif rising_edge(CpSl_LcdClk_i) then
            if (PrSl_LcdVSync_s = '1') then 
                PrSv_HCnt_s <= (others => '0');
            elsif (PrSv_HCnt_s = PrSv_HCnt_End_s) then 
                PrSv_HCnt_s <= (others => '0');
            else
                PrSv_HCnt_s <= PrSv_HCnt_s + '1';
            end if;
        end if;
    end process;

    -- VCnt
    process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSv_VCnt_s <= (others => '0');
        elsif rising_edge(CpSl_LcdClk_i) then
            if (PrSl_LcdVSync_s = '1') then
                PrSv_VCnt_s <= (others => '0');
            elsif (PrSv_HCnt_s = PrSv_HCnt_End_s) then 
                if (PrSv_VCnt_s = PrSv_VEnd_c) then 
                    PrSv_VCnt_s <= PrSv_VEnd_c;
                else
                    PrSv_VCnt_s <= PrSv_VCnt_s + '1';
                end if;
            else -- hold
            end if;
        end if;
    end process;

    -- HSync
    process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSl_Hsync_s <= '0';
        elsif rising_edge(CpSl_LcdClk_i) then
            if (PrSv_HCnt_s = 0) then
                PrSl_Hsync_s <= '1';
            else
                PrSl_Hsync_s <= '0';
            end if;
        end if;
    end process;

    -- VSync
    process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSl_Vsync_s <= '0';
        elsif rising_edge(CpSl_LcdClk_i) then
            if (PrSv_HCnt_s = 0 and PrSv_VCnt_s = 11) then 
                PrSl_Vsync_s <= '1';
            else
                PrSl_Vsync_s <= '0';
            end if;
        end if;
    end process;

    -- LCD output
    CpSl_LcdVsync_o <= PrSl_Vsync_s;
    CpSl_LcdHsync_o <= PrSl_Hsync_s;

    -- H Sync (Previous for DDR read data)
    process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSl_Hsync_Pre_s <= '0';
        elsif rising_edge(CpSl_LcdClk_i) then

            if (PrSv_HCnt_s = PrSv_HCnt_Start_s) then
                PrSl_Hsync_Pre_s <= '1';
            else
                PrSl_Hsync_Pre_s <= '0';
            end if;
            
            
            
        end if;
    end process;
    
    -- VPrevious Read data to TxFifo
    process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSl_PreVdisDvld_s <= '0';
        elsif rising_edge(CpSl_LcdClk_i) then
            if (PrSv_VCnt_s = PrSv_VPreStart_c) then
                PrSl_PreVdisDvld_s <= '1';
            elsif (PrSv_VCnt_s = PrSv_VPreStop_c) then
                PrSl_PreVdisDvld_s <= '0';
            else -- hold
            end if;
        end if;
    end process;
    
    -- H display data valid
    process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSl_HdisDvld_s <= '0';
        elsif rising_edge(CpSl_LcdClk_i) then
            if (PrSv_HCnt_s = PrSv_HCnt_Start_s) then 
                PrSl_HdisDvld_s <= '1';
            elsif (PrSv_HCnt_s = PrSv_HCnt_Stop_s) then
                PrSl_HdisDvld_s <= '0';
            else -- hold
            end if;
        end if;
    end process;

    -- V display data valid
    process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSl_VdisDvld_s <= '0';
        elsif rising_edge(CpSl_LcdClk_i) then
            if (PrSv_VCnt_s = PrSv_VStart_c) then
                PrSl_VdisDvld_s <= '1';
            elsif (PrSv_VCnt_s = PrSv_VStop_c) then
                PrSl_VdisDvld_s <= '0';
            else -- hold
            end if;
        end if;
    end process;

    -- Read DDR FIFO read enable
    PrSl_RfifoRen_s <= PrSl_HdisDvld_s and PrSl_VdisDvld_s and (not PrSl_RfifoEmpty_s);

    -- Data output
    CpSv_LcdR0_o <= (PrSv_RfifoRdata_s(31 downto 24) & x"0") when (PrSl_RfifoRen_s = '1') else (others => '0');
    CpSv_LcdR1_o <= (PrSv_RfifoRdata_s(23 downto 16) & x"0") when (PrSl_RfifoRen_s = '1') else (others => '0');
    CpSv_LcdR2_o <= (PrSv_RfifoRdata_s(15 downto  8) & x"0") when (PrSl_RfifoRen_s = '1') else (others => '0');
    CpSv_LcdR3_o <= (PrSv_RfifoRdata_s( 7 downto  0) & x"0") when (PrSl_RfifoRen_s = '1') else (others => '0');

    ----------------------------------------------------------------------------
    -- LCD read FIFO
    ----------------------------------------------------------------------------
    U_M_LcdTxFifo_0 : M_LcdTxFifo port map (
        rst                             => PrSl_Vsync_s                         , -- in  std_logic;
        wr_clk                          => CpSl_DdrClk_i                        , -- in  std_logic;
        wr_en                           => CpSl_AppRdDataVld_i                  , -- in  std_logic;
        din                             => CpSv_AppRdData_i                     , -- in  std_logic_vector(127 downto 0);
        full                            => PrSl_RfifoFull_s                     , -- out std_logic;

        rd_clk                          => CpSl_LcdClk_i                        , -- in  std_logic;
        rd_en                           => PrSl_RfifoRen_s                      , -- in  std_logic;
        dout                            => PrSv_RfifoRdata_s                    , -- out std_logic_vector( 31 downto 0);
        empty                           => PrSl_RfifoEmpty_s                      -- out std_logic
    );

    ----------------------------------------------------------------------------
    -- DDR read control
    ----------------------------------------------------------------------------
    -- Read data from DDR to Lcd_TxFifo
    PrSl_Reset_s <= not CpSl_DdrRdy_i;
    Vsync_Ddr_Clk_s: pulse2pulse
    port map (
       in_clk   => CpSl_LcdClk_i,
       out_clk  => CpSl_DdrClk_i,
       rst      => PrSl_Reset_s,
       pulsein  => PrSl_Vsync_s,
       inbusy   => open,
       pulseout => PrSl_Vsync_Ddr_s
    );

    Hsync_Ddr_Clk_s: pulse2pulse
    port map (
       in_clk   => CpSl_LcdClk_i,
       out_clk  => CpSl_DdrClk_i,
       rst      => PrSl_Reset_s,
       pulsein  => PrSl_Hsync_Pre_s,
       inbusy   => open,
       pulseout => PrSl_Hsync_Ddr_s
    );

    -- Delay PrSl_Vsync_s/(PrSl_Hsync_s and PrSl_VdisDvld_s) 3 clk
    process (CpSl_DdrRdy_i, CpSl_DdrClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSl_LcdVsyncDly1_s <= '0';
            PrSl_LcdVsyncDly2_s <= '0';
            PrSl_LcdVsyncDly3_s <= '0';

            PrSl_LcdHsyncDly1_s <= '0';
            PrSl_LcdHsyncDly2_s <= '0';
            PrSl_LcdHsyncDly3_s <= '0';
        elsif rising_edge(CpSl_DdrClk_i) then
            PrSl_LcdVsyncDly1_s <= PrSl_Vsync_Ddr_s   ;
            PrSl_LcdVsyncDly2_s <= PrSl_LcdVsyncDly1_s;
            PrSl_LcdVsyncDly3_s <= PrSl_LcdVsyncDly2_s;

            PrSl_LcdHsyncDly1_s <= PrSl_Hsync_Ddr_s and PrSl_PreVdisDvld_s;
            PrSl_LcdHsyncDly2_s <= PrSl_LcdHsyncDly1_s;
            PrSl_LcdHsyncDly3_s <= PrSl_LcdHsyncDly2_s;
        end if;
    end process;

    -- Row data read DDR trigger
    PrSl_RowRdTrig_s <= PrSl_LcdHsyncDly2_s and (not PrSl_LcdHsyncDly3_s);

    ----------------------------------------------------------------------------
    -- DDR
    ----------------------------------------------------------------------------
    -- Gen command request
    process (CpSl_DdrRdy_i, CpSl_DdrClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSl_WrCmdReq_s <= '0';
            PrSl_RdCmdReq_s <= '0';
        elsif rising_edge(CpSl_DdrClk_i) then
            -- ddr write
            if (PrSl_RowWrTrig_s = '1') then
                PrSl_WrCmdReq_s <= '1';
            elsif (PrSv_CmdState_s = "01") then
                PrSl_WrCmdReq_s <= '0';
            else -- hold
            end if;

            -- ddr read
            if (PrSl_RowRdTrig_s = '1') then
                PrSl_RdCmdReq_s <= '1';
            elsif (PrSv_CmdState_s = "10") then
                PrSl_RdCmdReq_s <= '0';
            else -- hold
            end if;
        end if;
    end process;

    -- Gen command state
    process (CpSl_DdrRdy_i, CpSl_DdrClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSv_CmdState_s <= "00";
        elsif rising_edge(CpSl_DdrClk_i) then
            case PrSv_CmdState_s is
            when "00" =>
                if (PrSl_RdCmdReq_s = '1') then
                    PrSv_CmdState_s <= "10";
                elsif (PrSl_WrCmdReq_s = '1') then
                    PrSv_CmdState_s <= "01";
                else -- hold
                end if;
            when "01" =>
                if (CpSl_AppRdy_i = '1' and PrSv_CmdCnt_s = 79) then
                    if (PrSl_RdCmdReq_s = '1') then
                        PrSv_CmdState_s <= "10";
                    else
                        PrSv_CmdState_s <= "00";
                    end if;
                else -- hold
                end if;
            when "10" =>
                if (CpSl_AppRdy_i = '1' and PrSv_CmdCnt_s = 79) then
                    if (PrSl_WrCmdReq_s = '1') then
                        PrSv_CmdState_s <= "01";
                    else
                        PrSv_CmdState_s <= "00";
                    end if;
                else -- hold
                end if;
            when others => PrSv_CmdState_s <= "00";
            end case;
        end if;
    end process;

    -- Gen command counter
    process (CpSl_DdrRdy_i, CpSl_DdrClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSv_CmdCnt_s <= (others => '0');
        elsif rising_edge(CpSl_DdrClk_i) then
            if (CpSl_AppRdy_i = '1' and PrSv_CmdState_s /= x"0") then
                if (PrSv_CmdCnt_s = 79) then
                    PrSv_CmdCnt_s <= (others => '0');
                else
                    PrSv_CmdCnt_s <= PrSv_CmdCnt_s + '1';
                end if;
            else -- hold
            end if;
        end if;
    end process;

    -- Gen data request
    process (CpSl_DdrRdy_i, CpSl_DdrClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSl_WrDataReq_s <= '0';
        elsif rising_edge(CpSl_DdrClk_i) then
            if (PrSl_RowWrTrig_s = '1') then
                PrSl_WrDataReq_s <= '1';
            elsif (PrSl_WrDataState_s = '1') then
                PrSl_WrDataReq_s <= '0';
            else -- hold
            end if;
        end if;
    end process;

    -- Gen data state
    process (CpSl_DdrRdy_i, CpSl_DdrClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSl_WrDataState_s <= '0';
        elsif rising_edge(CpSl_DdrClk_i) then
            case PrSl_WrDataState_s is
            when '0' =>
                if (PrSl_WrDataReq_s = '1') then
                    PrSl_WrDataState_s <= '1';
                else -- hold
                end if;
            when '1' =>
                if (CpSl_AppWdfRdy_i = '1' and PrSv_WrDataCnt_s = 79) then
                    PrSl_WrDataState_s <= '0';
                else -- hold
                end if;
            when others => PrSl_WrDataState_s <= '0';
            end case;
        end if;
    end process;

    -- Gen data counter
    process (CpSl_DdrRdy_i, CpSl_DdrClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSv_WrDataCnt_s <= (others => '0');
        elsif rising_edge(CpSl_DdrClk_i) then
            if (CpSl_AppWdfRdy_i = '1' and PrSl_WrDataState_s = '1') then
                if (PrSv_WrDataCnt_s = 79) then
                    PrSv_WrDataCnt_s <= (others => '0');
                else
                    PrSv_WrDataCnt_s <= PrSv_WrDataCnt_s + '1';
                end if;
            else -- hold
            end if;
        end if;
    end process;

    -- Address low
    process (CpSl_DdrRdy_i, CpSl_DdrClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSv_WrAddrLow_s <= (others => '0');
            PrSv_RdAddrLow_s <= (others => '0');
        elsif rising_edge(CpSl_DdrClk_i) then
            if (PrSl_RowWrTrig_s = '1') then
                PrSv_WrAddrLow_s <= (others => '0');
            elsif (PrSv_CmdState_s(0) = '1' and CpSl_AppRdy_i = '1') then
                PrSv_WrAddrLow_s <= PrSv_WrAddrLow_s + 8;
            else -- hold
            end if;

            if (PrSl_RowRdTrig_s = '1') then
                PrSv_RdAddrLow_s <= (others => '0');
            elsif (PrSv_CmdState_s(1) = '1' and CpSl_AppRdy_i = '1') then
                PrSv_RdAddrLow_s <= PrSv_RdAddrLow_s + 8;
            else -- hold
            end if;
        end if;
    end process;

    -- Address middle
    process (CpSl_DdrRdy_i, CpSl_DdrClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSv_WrAddrMid_s <= (others => '1');
            PrSv_RdAddrMid_s <= (others => '1');
        elsif rising_edge(CpSl_DdrClk_i) then
            if (PrSl_DviVsyncDly2_s = '0' and PrSl_DviVsyncDly3_s = '1') then
                PrSv_WrAddrMid_s <= (others => '1');
            elsif (PrSl_RowWrTrig_s = '1') then
                PrSv_WrAddrMid_s <= PrSv_WrAddrMid_s + '1';
            else -- hold
            end if;

            if (PrSl_LcdVsyncDly2_s = '1' and PrSl_LcdVsyncDly3_s = '0') then
                PrSv_RdAddrMid_s <= (others => '1');
            elsif (PrSl_RowRdTrig_s = '1') then
                PrSv_RdAddrMid_s <= PrSv_RdAddrMid_s + '1';
            else -- hold
            end if;
        end if;
    end process;

    -- DDR write address high
    process (CpSl_DdrRdy_i, CpSl_DdrClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSv_WrAddrHig_s <= (others => '0');
        elsif rising_edge(CpSl_DdrClk_i) then
        case PrSv_WrAddrHig_s is
            when "000"  => if (PrSl_DviVsyncDly2_s = '0' and PrSl_DviVsyncDly3_s = '1') then PrSv_WrAddrHig_s <= "010"; else end if;
            when "010"  => if (PrSl_DviVsyncDly2_s = '0' and PrSl_DviVsyncDly3_s = '1') then PrSv_WrAddrHig_s <= "100"; else end if;
            when "100"  => if (PrSl_DviVsyncDly2_s = '0' and PrSl_DviVsyncDly3_s = '1') then PrSv_WrAddrHig_s <= "000"; else end if;
            when others => PrSv_WrAddrHig_s <= (others => '0');
        end case;
        end if;
    end process;

    -- DDR read address high
    process (CpSl_DdrRdy_i, CpSl_DdrClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSv_RdAddrHig_s <= (others => '0');
        elsif rising_edge(CpSl_DdrClk_i) then
        case PrSv_WrAddrHig_s is
            when "000"  => if (PrSl_LcdVsyncDly2_s = '1' and PrSl_LcdVsyncDly3_s = '0') then PrSv_RdAddrHig_s <= "100"; else end if;
            when "010"  => if (PrSl_LcdVsyncDly2_s = '1' and PrSl_LcdVsyncDly3_s = '0') then PrSv_RdAddrHig_s <= "000"; else end if;
            when "100"  => if (PrSl_LcdVsyncDly2_s = '1' and PrSl_LcdVsyncDly3_s = '0') then PrSv_RdAddrHig_s <= "010"; else end if;
            when others => PrSv_RdAddrHig_s <= (others => '0');
        end case;
        end if;
    end process;

    ----------------------------------------------------------------------------
    -- Assignment
    ----------------------------------------------------------------------------
    -- Command enable
    CpSl_AppEn_o <= '1' when PrSv_CmdState_s /= "00" else '0';

    -- Command, 000: write, 001: read
    CpSv_AppCmd_o <= "000" when PrSv_CmdState_s(0) = '1' else "001";

    -- Command address
    CpSv_AppAddr_o(28 downto 24) <= "00000";
    CpSv_AppAddr_o(23 downto  0) <= (PrSv_WrAddrHig_s & PrSv_WrAddrMid_s & PrSv_WrAddrLow_s) when (PrSv_CmdState_s(0) = '1') else
                                    (PrSv_RdAddrHig_s & PrSv_RdAddrMid_s & PrSv_RdAddrLow_s);

    ----------------------------------------------------------------------------
    -- SMA VSync Output
    ----------------------------------------------------------------------------
    --Dvi Vsync
    process (CpSl_DdrRdy_i, PrSl_DviClk_s) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSv_DviVSync_Cnt_s <= (others => '0');
        elsif rising_edge(PrSl_DviClk_s) then
            if (CpSl_Dvi0Vsync_i = '0') then
                PrSv_DviVSync_Cnt_s <= (others => '0');
            elsif (PrSv_DviVSync_Cnt_s /= PrSv_DviSyncCnt_1ms_s) then
                PrSv_DviVSync_Cnt_s <= PrSv_DviVSync_Cnt_s + '1';
            else
            end if;
        end if;
    end process;

    process (CpSl_DdrRdy_i, PrSl_DviClk_s) begin
        if (CpSl_DdrRdy_i = '0') then
            CpSl_DVISync_SMA_o <= '0';
        elsif rising_edge(PrSl_DviClk_s) then
            if (PrSv_DviVSync_Cnt_s /= PrSv_DviSyncCnt_1ms_s) then
                CpSl_DVISync_SMA_o <= '1';
            else
                CpSl_DVISync_SMA_o <= '0';
            end if;
        end if;
    end process;

    --Lcd Vsync
    process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSv_LCDVSync_Cnt_s <= (others => '0');
        elsif rising_edge(CpSl_LcdClk_i) then
            if (PrSl_Vsync_s = '1') then
                PrSv_LCDVSync_Cnt_s <= (others => '0');
            elsif (PrSv_LCDVSync_Cnt_s /= PrSv_LCDSyncCnt_1ms_s) then
                PrSv_LCDVSync_Cnt_s <= PrSv_LCDVSync_Cnt_s + '1';
            else
            end if;
        end if;
    end process;

    process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            CpSl_LCDSync_SMA_o <= '0';
        elsif rising_edge(CpSl_LcdClk_i) then
            if (PrSv_LCDVSync_Cnt_s /= PrSv_LCDSyncCnt_1ms_s) then
                CpSl_LCDSync_SMA_o <= '1';
            else
                CpSl_LCDSync_SMA_o <= '0';
            end if;
        end if;
    end process;

end arch_M_DdrIf;