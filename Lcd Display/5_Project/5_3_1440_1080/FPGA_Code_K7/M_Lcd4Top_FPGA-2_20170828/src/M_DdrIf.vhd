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
-- 设    计  :  zhang wenjun
-- 邮    件  :  wenjunzhang@bixing-tech.com
-- 校    对  :
-- 设计日期  :  2017/3/10
-- 功能简述  :  DVI/LCD/DDR
-- 版本序号  :  0.1
-- 修改历史  :  1. Initial, zhang wenjun, 2017/3/10
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity M_DdrIf is
    generic (
        --------------------------------
        -- Simulation = 0 for simulation
        --------------------------------
        Simulation                      : integer := 1;
        Use_ChipScope                   : integer := 1
    );
    port (
        --------------------------------
        -- External Sync
        --------------------------------
        CpSl_LcdVsync_i                  : in  std_logic;                        -- Lcd Vsync

        --------------------------------
        -- SMA V Sync
        --------------------------------
        CpSl_DVISync_SMA_o              : out  std_logic;                       -- Sync out of DVI V Sync
        CpSl_LCDSync_SMA_o              : out  std_logic;                       -- Sync out of LCD V Sync

        --------------------------------
        -- DVI
        --------------------------------
        CpSl_Dvi0Clk_i                  : in  std_logic;                        -- DVI0 Clk
        CpSl_Dvi0Vsync_i                : in  std_logic;                        -- DVI0 VSync
        CpSl_Dvi0Hsync_i                : in  std_logic;                        -- DVI0 HSync
        CpSl_Dvi0De_i                   : in  std_logic;                        -- DVI0 De
        CpSl_Dvi0Scdt_i                 : in  std_logic;                        -- DVI0 SCDT
        CpSv_Dvi0R_i                    : in  std_logic_vector(  7 downto 0);   -- DVI0 Red
        CpSl_Dvi1Scdt_i                 : in  std_logic;                        -- DVI1 SCDT
        CpSv_Dvi1R_i                    : in  std_logic_vector(  7 downto 0);   -- DVI1 Red

        --------------------------------
        -- LCD
        --------------------------------
        CpSl_LcdClk_i                   : in  std_logic;                        -- Lcd Clk
        CpSv_FreChoice_i                : in  std_logic_vector( 2  downto 0);   -- refresh Selection
        CpSl_LcdVsync_o                 : out std_logic;                        -- LCD V sync
        CpSl_LcdHsync_o                 : out std_logic;                        -- LCD H sync
        CpSv_LcdR0_o                    : out std_logic_vector( 11 downto 0);   -- LCD Red0
        CpSv_LcdR1_o                    : out std_logic_vector( 11 downto 0);   -- LCD Red1
        CpSv_LcdR2_o                    : out std_logic_vector( 11 downto 0);   -- LCD Red2
        CpSv_LcdR3_o                    : out std_logic_vector( 11 downto 0);   -- LCD Red3

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
        CpSv_ChipCtrl0_io               : inout std_logic_vector(35 downto 0);  -- ChipScope_Ctrl0
        CpSv_ChipCtrl1_io               : inout std_logic_vector(35 downto 0);  -- ChipScope_Ctrl1
        CpSv_ChipCtrl2_io               : inout std_logic_vector(35 downto 0)   -- ChipScope_Ctrl2
    );
end M_DdrIf;

architecture arch_M_DdrIf of M_DdrIf is
    ----------------------------------------------------------------------------
    -- constant declaration
    ----------------------------------------------------------------------------
    constant PrSv_DviSyncCnt_1ms_s      : std_logic_vector(19 downto 0) := x"28488"; -- 1/165MHz per clock
    constant PrSv_LCDSyncCnt_1ms_s      : std_logic_vector(19 downto 0) := x"13880"; -- 1/80MHz per clock

    ----------------------------------------------------------------------------
	-- Clock = 90MHz
	-- Refresh rate :100Hz\85Hz\75Hz\60Hz\50Hz
	-- Image In : 1440*1080
	-- Image Out: 1440*1080
	------------------------------------
	-- Counter End Calculation
	-- Clock(MHz) / 1125 / Refresh Freq
	-- 1: 100Hz Refresh Rate :
	--       75 / 1125 / 100 = 666
	--       75 / 1136 / 100 = 660
	-- 2: 85Hz Refresh Rate :
	--      105 / 1125 / 170 = 549
	--      105 / 1136 / 170 = 543
	-- 3: 75Hz Refresh Rate :
	--      105 / 1125 / 150 = 622
	--      105 / 1136 / 150 = 616
	-- 4: 60Hz Refresh Rate :
	--       75 / 1125 / 120 = 555	
	--       75 / 1136 / 120 = 550
	-- 5: 50Hz Refresh Rate :
	--       75 / 1125 / 100 = 666
    --       75 / 1136 / 100 = 660
	------------------------------------
	--Note : 60 / 1136 / 100 = 528
	------------------------------------
	--H Timing(Hsync)
	--    |--|
	--    |  | 1Clk ===(48Clk_Head) + (480_Data) + (End)
	-- ---    ----
	--V Timing(Vsync)
	--    |--|
	--    |  |1Clk===(36行_Head）+（1080行_数据) + (9行_End)
	--  --    ---
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    -- constant declaration
    ----------------------------------------------------------------------------
    ------------------------------------
    -- VCnt declaration
    ------------------------------------
    constant PrSv_VPreStart_c           : std_logic_vector(11 downto 0) := x"023"; -- 35
    constant PrSv_VStart_c              : std_logic_vector(11 downto 0) := x"024"; -- 36
    constant PrSv_VPreStop_c            : std_logic_vector(11 downto 0) := x"45B"; -- 1115
    constant PrSv_VStop_c               : std_logic_vector(11 downto 0) := x"45C"; -- 1116
    constant PrSv_VEnd_c                : std_logic_vector(11 downto 0) := x"464"; -- 1124

    ------------------------------------
    -- HCnt declaration
    ------------------------------------
--    constant PrSv_Ref100Hz_Start_c      : std_logic_vector(11 downto 0) := x"06D"; -- 110
--    constant PrSv_Ref85Hz_Start_c       : std_logic_vector(11 downto 0) := x"06D"; -- 110
--    constant PrSv_Ref75Hz_Start_c       : std_logic_vector(11 downto 0) := x"06D"; -- 110
--    constant PrSv_Ref60Hz_Start_c       : std_logic_vector(11 downto 0) := x"06D"; -- 110
--    constant PrSv_Ref50Hz_Start_c       : std_logic_vector(11 downto 0) := x"06D"; -- 110
--    
--    constant PrSv_Ref100Hz_Stop_c       : std_logic_vector(11 downto 0) := x"1D5"; -- 470
--    constant PrSv_Ref85Hz_Stop_c        : std_logic_vector(11 downto 0) := x"1D5"; -- 470
--    constant PrSv_Ref75Hz_Stop_c        : std_logic_vector(11 downto 0) := x"1D5"; -- 470
--    constant PrSv_Ref60Hz_Stop_c        : std_logic_vector(11 downto 0) := x"1D5"; -- 470
--    constant PrSv_Ref50Hz_Stop_c        : std_logic_vector(11 downto 0) := x"1D5"; -- 470 
        
    constant PrSv_Ref100Hz_Start_c      : std_logic_vector(11 downto 0) := x"063"; -- 100
    constant PrSv_Ref85Hz_Start_c       : std_logic_vector(11 downto 0) := x"063"; -- 100
    constant PrSv_Ref75Hz_Start_c       : std_logic_vector(11 downto 0) := x"063"; -- 100
    constant PrSv_Ref60Hz_Start_c       : std_logic_vector(11 downto 0) := x"063"; -- 100
    constant PrSv_Ref50Hz_Start_c       : std_logic_vector(11 downto 0) := x"063"; -- 100
    
    constant PrSv_Ref100Hz_Stop_c       : std_logic_vector(11 downto 0) := x"1CB"; -- 460
    constant PrSv_Ref85Hz_Stop_c        : std_logic_vector(11 downto 0) := x"1CB"; -- 460
    constant PrSv_Ref75Hz_Stop_c        : std_logic_vector(11 downto 0) := x"1CB"; -- 460
    constant PrSv_Ref60Hz_Stop_c        : std_logic_vector(11 downto 0) := x"1CB"; -- 460
    constant PrSv_Ref50Hz_Stop_c        : std_logic_vector(11 downto 0) := x"1CB"; -- 460 
        
        
    constant PrSv_Ref100Hz_End_c        : std_logic_vector(11 downto 0) := x"298"; -- 665
    constant PrSv_Ref85Hz_End_c         : std_logic_vector(11 downto 0) := x"223"; -- 548
    constant PrSv_Ref75Hz_End_c         : std_logic_vector(11 downto 0) := x"26C"; -- 621
    constant PrSv_Ref60Hz_End_c         : std_logic_vector(11 downto 0) := x"229"; -- 554
    constant PrSv_Ref50Hz_End_c         : std_logic_vector(11 downto 0) := x"298"; -- 665

    ------------------------------------
    -- Refrate Contral declaration
    ------------------------------------
    constant PrSv_Ref100Hz_c            : std_logic_vector( 2 downto 0) := "100";  -- 100Hz
    constant PrSv_Ref85Hz_c             : std_logic_vector( 2 downto 0) := "010";  -- 85Hz
    constant PrSv_Ref75Hz_c             : std_logic_vector( 2 downto 0) := "001";  -- 75Hz
    constant PrSv_Ref60Hz_c             : std_logic_vector( 2 downto 0) := "110";  -- 60Hz
    constant PrSv_Ref50Hz_c             : std_logic_vector( 2 downto 0) := "101";  -- 50Hz

    ----------------------------------------------------------------------------
    -- component declaration
    ----------------------------------------------------------------------------
    -- ChipScope
    component M_ila port (
        control                         : inout std_logic_vector( 35 downto 0);
        clk                             : in    std_logic;
        trig0                           : in    std_logic_vector( 74 downto 0)
    );
    end component;

    -- Dvi_Data Interfance with DDR
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

    -- LCD_Data Interfance with DDR
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
    
    component pulse2pulse
    port (
       in_clk                           : in  std_logic;
       out_clk                          : in  std_logic;
       rst                              : in  std_logic;
       pulsein                          : in  std_logic;
       inbusy                           : out std_logic;
       pulseout                         : out std_logic
    );
    end component;

    ----------------------------------------------------------------------------
    -- signal declaration
    ----------------------------------------------------------------------------

    signal PrSl_Dvi0Hsync_s             : std_logic;                            -- Dvi0 Hsync
    signal PrSv_DviHCnt_s               : std_logic_vector( 15 downto 0);       -- Dvi HCnt
    signal PrSv_DviVCnt_s               : std_logic_vector( 15 downto 0);       -- Dvi VCnt

    -- SMA Syc
    signal PrSv_DviVSync_Cnt_s          : std_logic_vector( 19 downto 0);       -- Counter to Delay DVI VSync
    signal PrSv_LCDVSync_Cnt_s          : std_logic_vector( 19 downto 0);       -- Counter to Delay LCD VSync

    -- Lcd VSync
    signal PrSl_VsyncLcdDly1_s          : std_logic;                            -- Dvi Vsync Lcd Delay 1Clk 
    signal PrSl_VsyncLcdDly2_s          : std_logic;                            -- Dvi Vsync Lcd Delay 2Clk 
    signal PrSl_VsyncLcdDly3_s          : std_logic;                            -- Dvi Vsync Lcd Delay 3Clk 
                                                                                
    -- HCnt Constant                                                            
    signal PrSv_HCnt_Start_s            : std_logic_vector(11 downto 0);        -- Lcd HCnt start
    signal PrSv_HCnt_Stop_s             : std_logic_vector(11 downto 0);        -- Lcd HCnt Stop
    signal PrSv_HCnt_End_s              : std_logic_vector(11 downto 0);        -- Lcd HCnt End

    -- Dvi In
    signal PrSl_DviClk_s                : std_logic;                            -- DVI clk inverse
    signal PrSl_DviDeDly_s              : std_logic;                            -- Delay CpSl_Dvi0De_i in DVI clk
    signal PrSv_CntDataIn_s             : std_logic_vector( 10 downto 0);       -- DVI input data counter
    signal PrSl_DviDvld_s               : std_logic;                            -- DVI input data valid
    signal PrSl_WfifoWen_s              : std_logic;                            -- Write DDR FIFO write enable
    signal PrSv_Dvi0RDly1_s             : std_logic_vector(  7 downto 0);       -- Delay DVI0 RData 1 clk
    signal PrSv_Dvi0RDly2_s             : std_logic_vector(  7 downto 0);       -- Delay DVI0 RData 2 clk
    signal PrSv_Dvi1RDly1_s             : std_logic_vector(  7 downto 0);       -- Delay DVI1 RData 1 clk
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
    signal PrSv_LcdState_s              : std_logic_vector(  1 downto 0);       -- Lcd State
    signal PrSl_PreVdisDvld_s           : std_logic;                            -- Lcd Pre DDR Read  
    signal PrSv_FreChoice_s             : std_logic_vector(  2 downto 0);       -- Frequence Choice
    signal PrSv_FreChoiceDly1_s         : std_logic_vector(  2 downto 0);       -- Frequence Choice Delay 1Clk
    signal PrSl_LcdIntVsync_s           : std_logic;                            -- Lcd Interal Vsync
    signal PrSl_LcdDouble_s             : std_logic;                            -- Lcd Double
    signal PrSl_LcdDoubleDly1_s         : std_logic;                            -- Lcd Double Dly 1Clk   
    signal PrSv_HCnt_s                  : std_logic_vector( 11 downto 0);       -- H counter
    signal PrSv_VCnt_s                  : std_logic_vector( 11 downto 0);       -- V counter
    signal PrSl_Hsync_s                 : std_logic;                            -- Inner Hsync
    signal PrSl_Hsync_Pre_s             : std_logic;
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
    
    signal PrSv_LcdR0_s                 : std_logic_vector( 11 downto 0);       -- LCD Red0
    signal PrSv_LcdR1_s                 : std_logic_vector( 11 downto 0);       -- LCD Red1
    signal PrSv_LcdR2_s                 : std_logic_vector( 11 downto 0);       -- LCD Red2
    signal PrSv_LcdR3_s                 : std_logic_vector( 11 downto 0);       -- LCD Red3
    
    -- DDR
    signal PrSl_WrCmdReq_s              : std_logic;                            -- Write command request
    signal PrSl_RdCmdReq_s              : std_logic;                            -- Read command request
    signal PrSv_CmdState_s              : std_logic_vector(  1 downto 0);       -- Command state
    signal PrSv_CmdCnt_s                : std_logic_vector(  7 downto 0);       -- Command counter
    signal PrSl_WrDataReq_s             : std_logic;                            -- Write data requests
    signal PrSl_WrDataState_s           : std_logic;                            -- Data state
    signal PrSv_WrDataCnt_s             : std_logic_vector(  6 downto 0);       -- Data counter
    signal PrSv_WrAddrLow_s             : std_logic_vector( 10 downto 0);       -- Write address low
    signal PrSv_RdAddrLow_s             : std_logic_vector( 10 downto 0);       -- Read address low
    signal PrSv_WrAddrMid_s             : std_logic_vector( 10 downto 0);       -- Write address middle
    signal PrSv_RdAddrMid_s             : std_logic_vector( 10 downto 0);       -- Read address middele
    signal PrSv_WrAddrHig_s             : std_logic_vector(  2 downto 0);       -- Write address high
    signal PrSv_RdAddrHig_s             : std_logic_vector(  2 downto 0);       -- Read address high

    -- ChipScope
    signal PrSv_ChipTrig0_s             : std_logic_vector( 74 downto 0);       -- DVI ChipScope
    signal PrSv_ChipTrig1_s             : std_logic_vector( 74 downto 0);       -- LCD ChipScope
    signal PrSv_ChipTrig2_s             : std_logic_vector( 74 downto 0);       -- DDR ChipScope

    -- Reset
    signal PrSl_RxFifoRst_s             : std_logic;                            -- RxFifo Reset
    signal PrSl_Reset_s                 : std_logic;
    signal PrSl_Vsync_Ddr_s             : std_logic;
    signal PrSl_Hsync_Ddr_s             : std_logic;

begin
    
    PrSl_Reset_s    <= not CpSl_DdrRdy_i;
    
    ----------------------------------------------------------------------------
    -- ChipScope M_ila
    ----------------------------------------------------------------------------
    -- Dvi input
    ChipScope : if (Use_ChipScope = 1) generate
    U_M_ila_0 : M_ila port map (
        control                         => CpSv_ChipCtrl0_io                    ,
        clk                             => PrSl_DviClk_s                        ,
        trig0                           => PrSv_ChipTrig0_s
    );

    PrSv_ChipTrig0_s(           0)      <= CpSl_Dvi0Vsync_i;
    PrSv_ChipTrig0_s(           1)      <= CpSl_Dvi0Hsync_i;
    PrSv_ChipTrig0_s(           2)      <= CpSl_Dvi0De_i   ;
    PrSv_ChipTrig0_s(           3)      <= CpSl_Dvi0Scdt_i ;
    PrSv_ChipTrig0_s(11 downto  4)      <= CpSv_Dvi0R_i    ;
    PrSv_ChipTrig0_s(          12)      <= CpSl_Dvi1Scdt_i ;
    PrSv_ChipTrig0_s(20 downto 13)      <= CpSv_Dvi1R_i    ;
    PrSv_ChipTrig0_s(31 downto 21)      <= PrSv_CntDataIn_s;
    PrSv_ChipTrig0_s(47 downto 32)      <= PrSv_DviHCnt_s  ;
    PrSv_ChipTrig0_s(63 downto 48)      <= PrSv_DviVCnt_s  ;
    PrSv_ChipTrig0_s(74 downto 64)      <= (others => '0');

    -- LCD output
    U_M_ila_1 : M_ila port map (
        control                         => CpSv_ChipCtrl1_io                    ,
        clk                             => CpSl_LcdClk_i                        ,
        trig0                           => PrSv_ChipTrig1_s
    );

    PrSv_ChipTrig1_s(            0)     <= PrSl_Hsync_s;
    PrSv_ChipTrig1_s(12 downto   1)     <= PrSv_HCnt_s;
    PrSv_ChipTrig1_s(           13)     <= PrSl_Vsync_s;
    PrSv_ChipTrig1_s(24 downto  14)     <= PrSv_VCnt_s(10 downto 0);
    PrSv_ChipTrig1_s(           25)     <= PrSl_LcdIntVsync_s;
    PrSv_ChipTrig1_s(           26)     <= PrSl_LcdDouble_s;
    PrSv_ChipTrig1_s(34 downto  27)     <= PrSv_LcdR0_s(7 downto 0);
    PrSv_ChipTrig1_s(42 downto  35)     <= PrSv_LcdR1_s(7 downto 0);
    PrSv_ChipTrig1_s(50 downto  43)     <= PrSv_LcdR2_s(7 downto 0);
    PrSv_ChipTrig1_s(58 downto  51)     <= PrSv_LcdR3_s(7 downto 0);
    PrSv_ChipTrig1_s(69 downto  59)     <= PrSv_HCnt_End_s(10 downto 0);
    PrSv_ChipTrig1_s(74 downto  70)     <= (others => '0');
        
    end generate ChipScope;
    
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

    -- Dvi Data Valid
    process (CpSl_DdrRdy_i, PrSl_DviClk_s) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSl_DviDvld_s <= '0';
        elsif rising_edge(PrSl_DviClk_s) then
            if (CpSl_Dvi0Scdt_i = '1') then
                if (CpSl_Dvi1Scdt_i = '1') then
                    if (PrSl_DviDeDly_s = '1' and PrSv_CntDataIn_s = 0) then
                        PrSl_DviDvld_s <= '1';
                    elsif (PrSv_CntDataIn_s = 720) then
                        PrSl_DviDvld_s <= '0';
                    else -- hold
                    end if;
                else
                    if (PrSl_DviDeDly_s = '1' and PrSv_CntDataIn_s = 0) then
                        PrSl_DviDvld_s <= '1';
                    elsif (PrSv_CntDataIn_s = 1440) then
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

    -- Delay Red
    -- Red Real_Data 
    Real_Red_data : if (Simulation = 1) generate
    process (CpSl_DdrRdy_i, PrSl_DviClk_s) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSv_Dvi0RDly1_s <= (others => '0');
            PrSv_Dvi0RDly2_s <= (others => '0');
               
            PrSv_Dvi1RDly1_s <= (others => '0');
        elsif rising_edge(PrSl_DviClk_s) then
            PrSv_Dvi0RDly1_s <= CpSv_Dvi0R_i    ;
            PrSv_Dvi0RDly2_s <= PrSv_Dvi0RDly1_s;
               
            PrSv_Dvi1RDly1_s <= CpSv_Dvi1R_i;
        end if;
    end process;
    end generate Real_Red_data;
    
    -- Red Sim_Data
    Sim_Red_data : if (Simulation = 0) generate
    process (CpSl_DdrRdy_i, PrSl_DviClk_s) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSv_Dvi0RDly1_s <= (others => '0');
            PrSv_Dvi0RDly2_s <= (others => '0');

            PrSv_Dvi1RDly1_s <= (others => '0');
        elsif rising_edge(PrSl_DviClk_s) then
            PrSv_Dvi0RDly1_s <= PrSv_CntDataIn_s( 7 downto 0);
            PrSv_Dvi0RDly2_s <= PrSv_Dvi0RDly1_s;

            PrSv_Dvi1RDly1_s <= PrSv_CntDataIn_s( 7 downto 0);
        end if;
    end process;
    end generate Sim_Red_data;


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
    PrSl_RxFifoRst_s <= (not PrSl_DviVsyncDly2_s) and PrSl_DviVsyncDly3_s;
    U_M_DviRxFifo_0 : M_DviRxFifo port map (
        rst                             => PrSl_RxFifoRst_s                     , -- in  std_logic;
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
    CpSl_AppWdfWren_o <= CpSl_AppWdfRdy_i when PrSl_WrDataState_s = '1' else '0';
    CpSl_AppWdfEnd_o  <= CpSl_AppWdfRdy_i when PrSl_WrDataState_s = '1' else '0';

    ----------------------------------------------------------------------------
    -- DDR write control
    ----------------------------------------------------------------------------
    -- Delay CpSl_Dvi0Vsync_i, CpSl_Dvi0De_i 3 clk
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
    -- Lcd VSync
    ----------------------------------------------------------------------------
    -- Delay Vsync 3 clk
    process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSl_VsyncLcdDly1_s <= '0';
            PrSl_VsyncLcdDly2_s <= '0';
            PrSl_VsyncLcdDly3_s <= '0';

        elsif rising_edge(CpSl_LcdClk_i) then
            PrSl_VsyncLcdDly1_s <= CpSl_LcdVsync_i;
            PrSl_VsyncLcdDly2_s <= PrSl_VsyncLcdDly1_s;
            PrSl_VsyncLcdDly3_s <= PrSl_VsyncLcdDly2_s;
                                      
        end if;
    end process;
    
    -- Internal VSync
    --use the generate Vsync Pulsefor Lcd output image
    PrSl_LcdIntVsync_s <= '1' when (PrSl_VsyncLcdDly2_s = '0' and PrSl_VsyncLcdDly3_s = '1') else
                          '0';    

    ----------------------------------------------------------------------------
    -- Lcd timing generation
    ----------------------------------------------------------------------------
    process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSv_FreChoice_s     <= (others => '0');
            PrSv_FreChoiceDly1_s <= (others => '0');

        elsif rising_edge(CpSl_LcdClk_i) then
            PrSv_FreChoice_s     <= CpSv_FreChoice_i;
            PrSv_FreChoiceDly1_s <= PrSv_FreChoice_s;
            
        end if;
    end process;

	 -- H Counter Selection based on the refresh rate
	 process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSv_HCnt_Start_s <= (others => '0');
            PrSv_HCnt_Stop_s  <= (others => '0');
            PrSv_HCnt_End_s   <= (others => '0');

        elsif rising_edge(CpSl_LcdClk_i) then
            case PrSv_FreChoiceDly1_s is
                when PrSv_Ref100Hz_c =>  -- 100Hz Refresh Rate
                    PrSv_HCnt_Start_s   <= PrSv_Ref100Hz_Start_c;
                    PrSv_HCnt_Stop_s    <= PrSv_Ref100Hz_Stop_c;
                    PrSv_HCnt_End_s     <= PrSv_Ref100Hz_End_c;

                when PrSv_Ref85Hz_c =>  -- 85Hz Refresh Rate
                    PrSv_HCnt_Start_s   <= PrSv_Ref85Hz_Start_c;
                    PrSv_HCnt_Stop_s    <= PrSv_Ref85Hz_Stop_c;
                    PrSv_HCnt_End_s     <= PrSv_Ref85Hz_End_c;

                when PrSv_Ref75Hz_c =>  -- 75Hz Refresh Rate
                    PrSv_HCnt_Start_s   <= PrSv_Ref75Hz_Start_c;
                    PrSv_HCnt_Stop_s    <= PrSv_Ref75Hz_Stop_c;
                    PrSv_HCnt_End_s     <= PrSv_Ref75Hz_End_c;
                    
                when PrSv_Ref60Hz_c =>  -- 60Hz Refresh Rate
                    PrSv_HCnt_Start_s   <= PrSv_Ref60Hz_Start_c;
                    PrSv_HCnt_Stop_s    <= PrSv_Ref60Hz_Stop_c;
                    PrSv_HCnt_End_s     <= PrSv_Ref60Hz_End_c;

                when PrSv_Ref50Hz_c =>  -- 50Hz Refresh Rate
                    PrSv_HCnt_Start_s   <= PrSv_Ref50Hz_Start_c;
                    PrSv_HCnt_Stop_s    <= PrSv_Ref50Hz_Stop_c;
                    PrSv_HCnt_End_s     <= PrSv_Ref50Hz_End_c;

                when others =>
                    PrSv_HCnt_Start_s   <= (others => '0');
                    PrSv_HCnt_Stop_s    <= (others => '0');
                    PrSv_HCnt_End_s     <= (others => '0');
                    
            end case;
        end if;
    end process;

    -- LCD State
    process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin 
        if (CpSl_DdrRdy_i = '0') then 
            PrSv_LcdState_s <= "00";
        elsif rising_edge(CpSl_LcdClk_i) then 
            case PrSv_LcdState_s is
                when "00" => 
                    if (PrSl_LcdIntVsync_s = '1') then 
                        PrSv_LcdState_s <= "01";
                    else
                        PrSv_LcdState_s <= "00";
                    end if;
                        
                when "01" => 
                    if (PrSv_HCnt_s = PrSv_HCnt_End_s
                        and PrSv_VCnt_s = PrSv_VEnd_c) then 
                        PrSv_LcdState_s <= "00";
                    else
                    end if;
                     
                when others => 
                    PrSv_LcdState_s <= "00";
                        
            end case; 
            
        end if;
    end process;

    -- HCnt
--    process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
--        if (CpSl_DdrRdy_i = '0') then
--            PrSv_HCnt_s <= (others => '0');
--        elsif rising_edge(CpSl_LcdClk_i) then
--            if (PrSv_LcdState_s = "01") then
--                if (PrSv_HCnt_s = PrSv_HCnt_End_s) then
--                    PrSv_HCnt_s <= (others => '0');
--                else
--                    PrSv_HCnt_s <= PrSv_HCnt_s + '1';
--                end if;
--            else
--                PrSv_HCnt_s <= (others => '0');
--            end if;
--        end if;
--    end process;

    process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSv_HCnt_s <= (others => '0');
        elsif rising_edge(CpSl_LcdClk_i) then
            if (PrSl_LcdIntVsync_s = '1') then 
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
            if (PrSv_LcdState_s = "01") then 
                if (PrSv_HCnt_s = PrSv_HCnt_End_s) then 
                    if (PrSv_VCnt_s = PrSv_VEnd_c) then 
                        PrSv_VCnt_s <= PrSv_VEnd_c;
                    else
                        PrSv_VCnt_s <= PrSv_VCnt_s + '1';
                    end if;
                else -- hold
                end if;
            else
                PrSv_VCnt_s <= (others => '0');
            end if;
        end if;
    end process;

    -- HSync
--    process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
--        if (CpSl_DdrRdy_i = '0') then
--            PrSl_Hsync_s <= '0';
--        elsif rising_edge(CpSl_LcdClk_i) then
--            if (PrSv_LcdState_s = "01") then 
--                if (PrSv_HCnt_s = 0) then
--                    PrSl_Hsync_s <= '1';
--                else
--                    PrSl_Hsync_s <= '0';
--                end if;
--            else 
--                PrSl_Hsync_s <= '0';
--            end if;
--        end if;
--    end process;
    
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
            if (PrSv_LcdState_s = "01") then 
                if (PrSv_VCnt_s = 0 and PrSv_HCnt_s = 0) then 
                    PrSl_Vsync_s <= '1';
                else
                    PrSl_Vsync_s <= '0';
                end if;
            else
                PrSl_Vsync_s <= '0';
            end if;
        end if;
    end process;
    
    -- LCD output
    CpSl_LcdVsync_o <= PrSl_Vsync_s;
    CpSl_LcdHsync_o <= PrSl_Hsync_s;

    -- H Sync (Previous for DDR read data)
--    process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
--        if (CpSl_DdrRdy_i = '0') then
--            PrSl_Hsync_Pre_s <= '0';
--        elsif rising_edge(CpSl_LcdClk_i) then
--            if (PrSv_HCnt_s = PrSv_HCnt_Start_s) then
--                PrSl_Hsync_Pre_s <= '1';
--            else
--                PrSl_Hsync_Pre_s <= '0';
--            end if;
--        end if;
--    end process;

    process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSl_Hsync_Pre_s <= '0';
        elsif rising_edge(CpSl_LcdClk_i) then
            if (PrSv_LcdState_s = "01") then 
                if (PrSv_HCnt_s = PrSv_HCnt_Start_s) then
                    PrSl_Hsync_Pre_s <= '1';
                else
                    PrSl_Hsync_Pre_s <= '0';
                end if;
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
            if (PrSv_LcdState_s = "01") then 
                if (PrSv_VCnt_s = PrSv_VPreStart_c) then
                    PrSl_PreVdisDvld_s <= '1';
                elsif (PrSv_VCnt_s = PrSv_VPreStop_c) then
                    PrSl_PreVdisDvld_s <= '0';
                else -- hold
                end if;
            else
                PrSl_PreVdisDvld_s <= '0';
            end if;
        end if;
    end process;
    
    -- H display data valid
    process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSl_HdisDvld_s <= '0';
        elsif rising_edge(CpSl_LcdClk_i) then
            if (PrSv_LcdState_s = "01") then 
                if (PrSv_HCnt_s = PrSv_HCnt_Start_s) then 
                    PrSl_HdisDvld_s <= '1';
                elsif (PrSv_HCnt_s = PrSv_HCnt_Stop_s) then
                    PrSl_HdisDvld_s <= '0';
                else -- hold
                end if;
            else
                PrSl_HdisDvld_s <= '0';
            end if;
        end if;
    end process;

    -- V display data valid
    process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSl_VdisDvld_s <= '0';
        elsif rising_edge(CpSl_LcdClk_i) then
            if (PrSv_LcdState_s = "01") then 
                if (PrSv_VCnt_s = PrSv_VStart_c) then
                    PrSl_VdisDvld_s <= '1';
                elsif (PrSv_VCnt_s = PrSv_VStop_c) then
                    PrSl_VdisDvld_s <= '0';
                else -- hold
                end if;
            else
                PrSl_VdisDvld_s <= '0';
            end if;
        end if;
    end process;

    -- Read DDR FIFO read enable
    PrSl_RfifoRen_s <= PrSl_HdisDvld_s and PrSl_VdisDvld_s and (not PrSl_RfifoEmpty_s);
    
    -- Data output
    PrSv_LcdR0_s <= (x"0" & PrSv_RfifoRdata_s(31 downto 24)) when (PrSl_RfifoRen_s = '1') else (others => '0');
    PrSv_LcdR1_s <= (x"0" & PrSv_RfifoRdata_s(23 downto 16)) when (PrSl_RfifoRen_s = '1') else (others => '0');
    PrSv_LcdR2_s <= (x"0" & PrSv_RfifoRdata_s(15 downto  8)) when (PrSl_RfifoRen_s = '1') else (others => '0');
    PrSv_LcdR3_s <= (x"0" & PrSv_RfifoRdata_s( 7 downto  0)) when (PrSl_RfifoRen_s = '1') else (others => '0');

    CpSv_LcdR0_o <= PrSv_LcdR0_s(7 downto 0) & x"0";
    CpSv_LcdR1_o <= PrSv_LcdR1_s(7 downto 0) & x"0";
    CpSv_LcdR2_o <= PrSv_LcdR2_s(7 downto 0) & x"0";
    CpSv_LcdR3_o <= PrSv_LcdR3_s(7 downto 0) & x"0";

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
            PrSl_LcdVsyncDly1_s <= PrSl_Vsync_Ddr_s;
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
            if (PrSl_RowWrTrig_s = '1') then
                PrSl_WrCmdReq_s <= '1';
            elsif (PrSv_CmdState_s = "01") then
                PrSl_WrCmdReq_s <= '0';
            else -- hold
            end if;
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
                if (CpSl_AppRdy_i = '1' and PrSv_CmdCnt_s = 89) then
                    if (PrSl_RdCmdReq_s = '1') then
                        PrSv_CmdState_s <= "10";
                    else
                        PrSv_CmdState_s <= "00";
                    end if;
                else -- hold
                end if;
            when "10" =>
                if (CpSl_AppRdy_i = '1' and PrSv_CmdCnt_s = 89) then
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
                if (PrSv_CmdCnt_s = 89) then
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
                if (CpSl_AppWdfRdy_i = '1' and PrSv_WrDataCnt_s = 89) then
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
                if (PrSv_WrDataCnt_s = 89) then
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
            when "010"  => if (PrSl_DviVsyncDly2_s = '0' and PrSl_DviVsyncDly3_s = '1') then PrSv_WrAddrHig_s <= "000"; else end if;
            -- when "100"  => if (PrSl_DviVsyncDly2_s = '0' and PrSl_DviVsyncDly3_s = '1') then PrSv_WrAddrHig_s <= "000"; else end if;
            when others => PrSv_WrAddrHig_s <= (others => '0');
        end case;
        end if;
    end process;

    -- DDR read address high
    -- Sim DDR
    Sim_Read_Ddr : if (Simulation = 0) generate 
    process (CpSl_DdrRdy_i, CpSl_DdrClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSv_RdAddrHig_s <= (others => '0');
        elsif rising_edge(CpSl_DdrClk_i) then
        case PrSv_WrAddrHig_s is
            when "000"  => if (PrSl_LcdVsyncDly2_s = '1' and PrSl_LcdVsyncDly3_s = '0') then PrSv_RdAddrHig_s <= "000"; else end if;
            when "010"  => if (PrSl_LcdVsyncDly2_s = '1' and PrSl_LcdVsyncDly3_s = '0') then PrSv_RdAddrHig_s <= "010"; else end if;
            -- when "100"  => if (PrSl_LcdVsyncDly2_s = '1' and PrSl_LcdVsyncDly3_s = '0') then PrSv_RdAddrHig_s <= "010"; else end if;
            when others => PrSv_RdAddrHig_s <= (others => '0');
        end case;
        end if;
    end process;
    end generate Sim_Read_Ddr;
    
    -- Real DDR
    Real_Read_Ddr : if (Simulation = 1) generate 
    process (CpSl_DdrRdy_i, CpSl_DdrClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSv_RdAddrHig_s <= (others => '0');
        elsif rising_edge(CpSl_DdrClk_i) then
        case PrSv_WrAddrHig_s is
            when "000"  => if (PrSl_LcdVsyncDly2_s = '1' and PrSl_LcdVsyncDly3_s = '0') then PrSv_RdAddrHig_s <= "010"; else end if;
            when "010"  => if (PrSl_LcdVsyncDly2_s = '1' and PrSl_LcdVsyncDly3_s = '0') then PrSv_RdAddrHig_s <= "000"; else end if;
            -- when "100"  => if (PrSl_LcdVsyncDly2_s = '1' and PrSl_LcdVsyncDly3_s = '0') then PrSv_RdAddrHig_s <= "010"; else end if;
            when others => PrSv_RdAddrHig_s <= (others => '0');
        end case;
        end if;
    end process;
    end generate Real_Read_Ddr;
    
    ----------------------------------------------------------------------------
    -- Assignment
    ----------------------------------------------------------------------------
    -- Command enable
    CpSl_AppEn_o <= '1' when PrSv_CmdState_s /= "00" else '0';

    -- Command, 000: write, 001: read
    CpSv_AppCmd_o <= "000" when PrSv_CmdState_s(0) = '1' else "001";

    -- Command address
    CpSv_AppAddr_o(28 downto 25) <= "0000";
    CpSv_AppAddr_o(24 downto  0) <= (PrSv_WrAddrHig_s & PrSv_WrAddrMid_s & PrSv_WrAddrLow_s) when (PrSv_CmdState_s(0) = '1') else
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
            elsif (PrSl_Dvi0Hsync_s = '0' and CpSl_Dvi0Hsync_i = '1') then -- rowedge
                PrSv_DviVCnt_s <= PrSv_DviVCnt_s + '1';
            else -- hold
            end if;
        end if;
    end process;
    

end arch_M_DdrIf;