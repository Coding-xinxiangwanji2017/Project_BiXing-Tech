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
-- 设    计  :  LIU Hai
-- 邮    件  :  liuwanghao@139.com
-- 校    对  :
-- 设计日期  :  2016/01/28
-- 功能简述  :  DVI/LCD/DDR
-- 版本序号  :  0.1
-- 修改历史  :  1. Initial, LIU Hai, 2016/01/28
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity M_DdrIf is
    port (
        --------------------------------
        -- External Sync
        --------------------------------
        CpSl_LcdSync_i                  : in  std_logic;                        -- Vsync (Ext or Int)

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
	    CpSl_LCD_Double_i               : in  std_logic;                        -- Double reference
        CpSv_Refresh_Rate_Sel_i         : in  std_logic_vector( 2  downto 0);   -- refresh Selection
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
    constant PrSv_LCDSyncCnt_1ms_s      : std_logic_vector(19 downto 0) := x"13880";  -- 1/80MHz per clock

    ------------------------------------
	-- Clock = 120MHz for 200Hz reference rate
	-- Clock = 80MHz  for 100Hz\60Hz\50Hz refresh rate
	------------------------------------
	-- Counter End Calculation
	-- Clock(MHz) / 1125 / Refresh Freq
	-- 1: 200Hz Refresh Rate :
	--       120 / 1125 / 200 = 533
	-- 2: 100Hz Refresh Rate :
	--       80 / 1125 / 100  = 711
	-- 60Hz 和 50Hz 的输入刷新率，输出用120Hz 和 100Hz
	-- 3: 60Hz Refresh Rate :
	--       80 / 1125 / 120 = 592
	-- 4: 50Hz Refresh Rate :
	--       80 / 1125 / 100 = 711
	------------------------------------
	-- constant declaration
	----------------------------------------------------------------------------
    constant PrSv_Ref200Hz_Start_c      : std_logic_vector(11 downto 0) := x"080"; --128
    constant PrSv_Ref100Hz_Start_c      : std_logic_vector(11 downto 0) := x"080"; --128
    constant PrSv_Ref60Hz_Start_c       : std_logic_vector(11 downto 0) := x"080"; --128
    constant PrSv_Ref50Hz_Start_c       : std_logic_vector(11 downto 0) := x"080"; --128

    constant PrSv_Ref200Hz_Stop_c       : std_logic_vector(11 downto 0) := x"1C0"; --448
    constant PrSv_Ref100Hz_Stop_c       : std_logic_vector(11 downto 0) := x"1C0"; --448
    constant PrSv_Ref60Hz_Stop_c        : std_logic_vector(11 downto 0) := x"1C0"; --448
    constant PrSv_Ref50Hz_Stop_c        : std_logic_vector(11 downto 0) := x"1C0"; --448

    constant PrSv_Ref200Hz_End_c        : std_logic_vector(11 downto 0) := x"213"; --532
    constant PrSv_Ref100Hz_End_c        : std_logic_vector(11 downto 0) := x"2C3"; --708
    constant PrSv_Ref60Hz_End_c         : std_logic_vector(11 downto 0) := x"250"; --592
    constant PrSv_Ref50Hz_End_c         : std_logic_vector(11 downto 0) := x"2C3"; --708

    constant PrSv_Ref200Hz_c            : std_logic_vector( 2 downto 0) := "100";  -- 200Hz
    constant PrSv_Ref100Hz_c            : std_logic_vector( 2 downto 0) := "011";  -- 100Hz
    constant PrSv_Ref60Hz_c             : std_logic_vector( 2 downto 0) := "010";  -- 60Hz
    constant PrSv_Ref50Hz_c             : std_logic_vector( 2 downto 0) := "001";  -- 50Hz

    ----------------------------------------------------------------------------
    -- component declaration
    ----------------------------------------------------------------------------
    -- ChipScope
    component M_ila port (
        control                         : inout std_logic_vector(35 downto 0);
        clk                             : in    std_logic;
        trig0                           : in    std_logic_vector(69 downto 0)
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

    ----------------------------------------------------------------------------
    -- signal declaration
    ----------------------------------------------------------------------------

    signal PrSl_Dvi0Hsync_s             : std_logic;                            -- DVI clk inverse
    signal PrSv_DviHCnt_s               : std_logic_vector( 15 downto 0);
    signal PrSv_DviVCnt_s               : std_logic_vector( 15 downto 0);

    -- SMA Syc
    signal PrSv_DviVSync_Cnt_s          : std_logic_vector( 19 downto 0);       -- Counter to Delay DVI VSync
    signal PrSv_LCDVSync_Cnt_s          : std_logic_vector( 19 downto 0);       -- Counter to Delay LCD VSync

    -- Internal Syc
    signal PrSl_DviVsync_Lcd_Dly1_s     : std_logic;
    signal PrSl_DviVsync_Lcd_Dly2_s     : std_logic;
    signal PrSl_DviVsync_Lcd_Dly3_s     : std_logic;
    signal PrSl_LCD_Double_Sync_s       : std_logic;
    signal PrSl_LCD_Double_Sync_Dly1_s  : std_logic;
    signal PrSl_Lcd_Inter_VSync_s       : std_logic;

    -- HCnt Constant
    signal PrSv_HCnt_Start_s            : std_logic_vector(11 downto 0);
    signal PrSv_HCnt_Stop_s             : std_logic_vector(11 downto 0);
    signal PrSv_HCnt_End_s              : std_logic_vector(11 downto 0);

    -- DVI in
    signal PrSl_DviClk_s                : std_logic;                            -- DVI clk inverse
    signal PrSl_DviDeDly_s              : std_logic;                            -- Delay CpSl_Dvi0De_i in DVI clk
    signal PrSv_CntDataIn_s             : std_logic_vector( 10 downto 0);       -- DVI input data counter
    signal PrSl_DviDvld_s               : std_logic;                            -- DVI input data valid
    signal PrSl_WfifoWen_s              : std_logic;                            -- Write DDR FIFO write enable
    signal PrSl_Dvi0RDly1_s             : std_logic_vector(  7 downto 0);       -- Delay DVI0 data 1 clk
    signal PrSl_Dvi0RDly2_s             : std_logic_vector(  7 downto 0);       -- Delay DVI0 data 2 clk
    signal PrSl_Dvi1RDly1_s             : std_logic_vector(  7 downto 0);       -- Delay DVI1 data 1 clk
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
    signal PrSv_Refresh_Rate_p1_s	    : std_logic_vector( 2  downto 0);       -- Dly1
    signal PrSv_Refresh_Rate_s	        : std_logic_vector( 2  downto 0);       -- Dly2
    signal PrSl_LCD_Double_pipe1_s      : std_logic;                            -- Dly1
    signal PrSl_LCD_Double_pipe2_s      : std_logic;                            -- Dly2
    signal PrSv_HCnt_s                  : std_logic_vector( 11 downto 0);       -- H counter
    signal PrSv_VCnt_s                  : std_logic_vector( 10 downto 0);       -- V counter
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

    -- ChipScope
    signal PrSv_ChipTrig0_s             : std_logic_vector(69 downto 0);        -- DVI ChipScope
    signal PrSv_ChipTrig1_s             : std_logic_vector(69 downto 0);        -- LCD ChipScope

begin
    ----------------------------------------------------------------------------
    -- ChipScope M_ila
    ----------------------------------------------------------------------------
    -- Dvi input
    U_M_ila_0 : M_ila port map (
        control                         => CpSv_ChipCtrl0_io                    ,
        clk                             => PrSl_DviClk_s                        ,
        trig0                           => PrSv_ChipTrig0_s
    );

    PrSv_ChipTrig0_s(           0) <= CpSl_Dvi0Vsync_i;
    PrSv_ChipTrig0_s(           1) <= CpSl_Dvi0Hsync_i;
    PrSv_ChipTrig0_s(           2) <= CpSl_Dvi0De_i   ;
    PrSv_ChipTrig0_s(           3) <= CpSl_Dvi0Scdt_i ;
    PrSv_ChipTrig0_s(11 downto  4) <= CpSv_Dvi0R_i    ;
    PrSv_ChipTrig0_s(          12) <= CpSl_Dvi1Scdt_i ;
    PrSv_ChipTrig0_s(20 downto 13) <= CpSv_Dvi1R_i    ;
    PrSv_ChipTrig0_s(          21) <= CpSl_DdrRdy_i   ;
    PrSv_ChipTrig0_s(37 downto 22) <= PrSv_DviHCnt_s  ;
    PrSv_ChipTrig0_s(53 downto 38) <= PrSv_DviVCnt_s  ;
    PrSv_ChipTrig0_s(64 downto 54) <= PrSv_CntDataIn_s;
    PrSv_ChipTrig0_s(69 downto 65) <= (others => '0');

    -- LCD output
    U_M_ila_1 : M_ila port map (
        control                         => CpSv_ChipCtrl1_io                    ,
        clk                             => CpSl_LcdClk_i                        ,
        trig0                           => PrSv_ChipTrig1_s
    );

    PrSv_ChipTrig1_s(           0) <= PrSl_Hsync_s;
    PrSv_ChipTrig1_s(12 downto  1) <= PrSv_HCnt_s;
    PrSv_ChipTrig1_s(          13) <= PrSl_Vsync_s;
    PrSv_ChipTrig1_s(24 downto 14) <= PrSv_VCnt_s;
    PrSv_ChipTrig1_s(          25) <= PrSl_Lcd_Inter_VSync_s;
    PrSv_ChipTrig1_s(          26) <= PrSl_LCD_Double_Sync_s;
    PrSv_ChipTrig1_s(34 downto 27) <= PrSv_RfifoRdata_s(31 downto 24);
    PrSv_ChipTrig1_s(42 downto 35) <= PrSv_RfifoRdata_s(23 downto 16);
    PrSv_ChipTrig1_s(50 downto 43) <= PrSv_RfifoRdata_s(15 downto  8);
    PrSv_ChipTrig1_s(58 downto 51) <= PrSv_RfifoRdata_s(7  downto  0);
    PrSv_ChipTrig1_s(69 downto 59) <= PrSv_HCnt_End_s(10 downto 0);
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
            elsif (PrSl_Dvi0Hsync_s = '0' and CpSl_Dvi0Hsync_i = '1') then -- rowedge
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
            PrSl_Dvi0RDly1_s <= (others => '0');
            PrSl_Dvi0RDly2_s <= (others => '0');

            PrSl_Dvi1RDly1_s <= (others => '0');
        elsif rising_edge(PrSl_DviClk_s) then
            PrSl_Dvi0RDly1_s <= CpSv_Dvi0R_i    ;
            PrSl_Dvi0RDly2_s <= PrSl_Dvi0RDly1_s;

            PrSl_Dvi1RDly1_s <= CpSv_Dvi1R_i;
        end if;
    end process;

    -- FIFO write data
    process (CpSl_DdrRdy_i, PrSl_DviClk_s) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSv_WfifoWdata_s <= (others => '0');
        elsif rising_edge(PrSl_DviClk_s) then
            if (CpSl_Dvi1Scdt_i = '1') then
                PrSv_WfifoWdata_s <= PrSl_Dvi0RDly1_s & PrSl_Dvi1RDly1_s;
            else
                PrSv_WfifoWdata_s <= PrSl_Dvi0RDly2_s & PrSl_Dvi0RDly1_s;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------------------
    -- DDR writ FIFO
    ----------------------------------------------------------------------------
    U_M_DviRxFifo_0 : M_DviRxFifo port map (
        rst                             => (not PrSl_DviVsyncDly2_s) and PrSl_DviVsyncDly3_s        , -- in  std_logic;
        wr_clk                          => PrSl_DviClk_s                                            , -- in  std_logic;
        wr_en                           => PrSl_WfifoWen_s                                          , -- in  std_logic;
        din                             => PrSv_WfifoWdata_s                                        , -- in  std_logic_vector( 15 downto 0);
        full                            => PrSl_WfifoFull_s                                         , -- out std_logic;

        rd_clk                          => CpSl_DdrClk_i                                            , -- in  std_logic;
        rd_en                           => PrSl_WfifoRen_s                                          , -- in  std_logic;
        dout                            => PrSv_WfifoRdata_s                                        , -- out std_logic_vector(127 downto 0);
        empty                           => PrSl_WfifoEmpty_s                                          -- out std_logic
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
    -- Internal Sync In
    ----------------------------------------------------------------------------
    -- Delay Vsync 3 clk
    process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSl_DviVsync_Lcd_Dly1_s <= '0';
            PrSl_DviVsync_Lcd_Dly2_s <= '0';
            PrSl_DviVsync_Lcd_Dly3_s <= '0';

        elsif rising_edge(CpSl_LcdClk_i) then
            -- Delay CpSl_Dvi0Vsync_i for 3 Clk
            --PrSl_DviVsync_Lcd_Dly1_s <= CpSl_Dvi0Vsync_i   ;
            -- Delay CpSl_ExtVsync_i for 3 Clk
            PrSl_DviVsync_Lcd_Dly1_s <= CpSl_LcdSync_i   ;
            PrSl_DviVsync_Lcd_Dly2_s <= PrSl_DviVsync_Lcd_Dly1_s;
            PrSl_DviVsync_Lcd_Dly3_s <= PrSl_DviVsync_Lcd_Dly2_s;

        end if;
    end process;

    -- Double the LCD refresh
    process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSl_LCD_Double_Sync_s      <= '0';
            PrSl_LCD_Double_Sync_Dly1_s <= '0';

        elsif rising_edge(CpSl_LcdClk_i) then
            if (PrSl_LCD_Double_pipe2_s = '1') then
                if (PrSv_HCnt_s = PrSv_HCnt_End_s and
                    PrSv_VCnt_s = 1124) then
                    PrSl_LCD_Double_Sync_s <= '1';
                -- use IntVsync
                --elsif(PrSl_DviVsync_Lcd_Dly3_s = '0') then
                elsif(PrSl_DviVsync_Lcd_Dly3_s = '1') then
                    PrSl_LCD_Double_Sync_s <= '0';
                end if;
            else
                PrSl_LCD_Double_Sync_s <= '0';
            end if;

            PrSl_LCD_Double_Sync_Dly1_s <= PrSl_LCD_Double_Sync_s;
        end if;
    end process;

    -- Internal VSync
    --use the Int Vsync for Lcd output image
    --PrSl_Lcd_Inter_VSync_s <= '1' when (PrSl_DviVsync_Lcd_Dly2_s = '0' and PrSl_DviVsync_Lcd_Dly3_s    = '1') else
	                           --'1' when (PrSl_LCD_Double_Sync_s   = '1' and PrSl_LCD_Double_Sync_Dly1_s = '0') else
										--'0';
    -- use the selcet Ext or Int Vsync for Lcd output image
    PrSl_Lcd_Inter_VSync_s <= '1' when (PrSl_DviVsync_Lcd_Dly2_s = '1' and PrSl_DviVsync_Lcd_Dly3_s    = '0') else
                              '1' when (PrSl_LCD_Double_Sync_s   = '1' and PrSl_LCD_Double_Sync_Dly1_s = '0') else
                              '0';
    ----------------------------------------------------------------------------
    -- LCD timing generation
    ----------------------------------------------------------------------------
    process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSv_Refresh_Rate_p1_s  <= (others => '0');
            PrSv_Refresh_Rate_s     <= (others => '0');
        elsif rising_edge(CpSl_LcdClk_i) then
            PrSv_Refresh_Rate_p1_s  <= CpSv_Refresh_Rate_Sel_i;
            PrSv_Refresh_Rate_s     <= PrSv_Refresh_Rate_p1_s;
        end if;
    end process;

	 process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSl_LCD_Double_pipe1_s <= '0';
            PrSl_LCD_Double_pipe2_s <= '0';
        elsif rising_edge(CpSl_LcdClk_i) then
            PrSl_LCD_Double_pipe1_s <= CpSl_LCD_Double_i;
            PrSl_LCD_Double_pipe2_s <= PrSl_LCD_Double_pipe1_s;
        end if;
    end process;


	 -- H Counter Selection based on the refresh rate
	 process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSv_HCnt_Start_s   <= PrSv_Ref100Hz_Start_c;
            PrSv_HCnt_Stop_s    <= PrSv_Ref100Hz_Stop_c;
            PrSv_HCnt_End_s     <= PrSv_Ref100Hz_End_c;

        elsif rising_edge(CpSl_LcdClk_i) then
            case PrSv_Refresh_Rate_s is
                when PrSv_Ref50Hz_c =>  -- 50Hz Refresh Rate
                    PrSv_HCnt_Start_s   <= PrSv_Ref50Hz_Start_c;
                    PrSv_HCnt_Stop_s    <= PrSv_Ref50Hz_Stop_c;
                    PrSv_HCnt_End_s     <= PrSv_Ref50Hz_End_c;

                when PrSv_Ref60Hz_c =>  -- 60Hz Refresh Rate
                    PrSv_HCnt_Start_s   <= PrSv_Ref60Hz_Start_c;
                    PrSv_HCnt_Stop_s    <= PrSv_Ref60Hz_Stop_c;
                    PrSv_HCnt_End_s     <= PrSv_Ref60Hz_End_c;

                when PrSv_Ref100Hz_c =>  -- 100Hz Refresh Rate
                    PrSv_HCnt_Start_s   <= PrSv_Ref100Hz_Start_c;
                    PrSv_HCnt_Stop_s    <= PrSv_Ref100Hz_Stop_c;
                    PrSv_HCnt_End_s     <= PrSv_Ref100Hz_End_c;

                when PrSv_Ref200Hz_c =>  -- 200Hz Refresh Rate
                    PrSv_HCnt_Start_s   <= PrSv_Ref200Hz_Start_c;
                    PrSv_HCnt_Stop_s    <= PrSv_Ref200Hz_Stop_c;
                    PrSv_HCnt_End_s     <= PrSv_Ref200Hz_End_c;

                when others=>
                    PrSv_HCnt_Start_s   <= PrSv_Ref100Hz_Start_c;
                    PrSv_HCnt_Stop_s    <= PrSv_Ref100Hz_Stop_c;
                    PrSv_HCnt_End_s     <= PrSv_Ref100Hz_End_c;
            end case;
        end if;
    end process;

    -- H counter
    process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSv_HCnt_s <= (others => '0');
        elsif rising_edge(CpSl_LcdClk_i) then
            if (PrSl_Lcd_Inter_VSync_s = '1') then
                PrSv_HCnt_s <= (others => '0');
            elsif (PrSv_HCnt_s = PrSv_HCnt_End_s) then
                PrSv_HCnt_s <= (others => '0');
            else
                PrSv_HCnt_s <= PrSv_HCnt_s + '1';
            end if;
        end if;
    end process;

    -- V counter
    process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSv_VCnt_s <= (others => '0');
        elsif rising_edge(CpSl_LcdClk_i) then
            if (PrSl_Lcd_Inter_VSync_s = '1') then
                PrSv_VCnt_s <= (others => '0');
            elsif (PrSv_HCnt_s = PrSv_HCnt_End_s) then
                if (PrSv_VCnt_s = 1124) then
                    PrSv_VCnt_s <= (others => '0');
                else
                    PrSv_VCnt_s <= PrSv_VCnt_s + '1';
                end if;
            else -- hold
            end if;
        end if;
    end process;

    -- H Sync
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

    -- V Sync
    process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSl_Vsync_s <= '0';
        elsif rising_edge(CpSl_LcdClk_i) then
            if (PrSv_VCnt_s = 11) then
                if (PrSv_HCnt_s = 0) then
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

    -- H display data valid
    process (CpSl_DdrRdy_i, CpSl_LcdClk_i) begin
        if (CpSl_DdrRdy_i = '0') then
            PrSl_HdisDvld_s <= '0';
        elsif rising_edge(CpSl_LcdClk_i) then
            if (PrSv_HCnt_s = PrSv_HCnt_Start_s) then
            --if (PrSv_HCnt_s = 128) then
                PrSl_HdisDvld_s <= '1';
            --elsif (PrSv_HCnt_s = 448) then
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
            if (PrSv_VCnt_s = 75) then
                PrSl_VdisDvld_s <= '1';
            elsif (PrSv_VCnt_s = 1099) then
                PrSl_VdisDvld_s <= '0';
            else -- hold
            end if;
        end if;
    end process;

    -- Read DDR FIFO read enable
    PrSl_RfifoRen_s <= PrSl_HdisDvld_s and PrSl_VdisDvld_s;

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
        empty                           => PrSl_RfifoEmpty_s                       -- out std_logic
    );

    ----------------------------------------------------------------------------
    -- DDR read control
    ----------------------------------------------------------------------------
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
            PrSl_LcdVsyncDly1_s <= PrSl_Vsync_s       ;
            PrSl_LcdVsyncDly2_s <= PrSl_LcdVsyncDly1_s;
            PrSl_LcdVsyncDly3_s <= PrSl_LcdVsyncDly2_s;

            PrSl_LcdHsyncDly1_s <= PrSl_Hsync_s and PrSl_VdisDvld_s;
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