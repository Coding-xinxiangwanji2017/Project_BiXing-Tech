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
-- 文件名称  :  M_LcdIf.vhd
-- 设    计  :  LIU Hai 
-- 邮    件  :  zheng-jianfeng@139.com
-- 校    对  :  
-- 设计日期  :  2014/04/11
-- 功能简述  :  LCD interface
-- 版本序号  :  0.1
-- 修改历史  :  1. Initial, LIU Hai, 2014/04/11
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity M_LcdIf is
    port (
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
        CpSv_FreChoice_i                : in  std_logic_vector( 2 downto 0);    -- Fresh Rate 
        
        --------------------------------
        -- DDR read
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, active low
        CpSl_DdrRdCmdEn_o               : out std_logic;                        -- DDR read command enable
        CpSv_DdrRdCmdAddr_o             : out std_logic_vector(29 downto 0);    -- DDR read command address
        CpSl_DdrRdCmdFull_i             : in  std_logic;                        -- DDR read command full
        CpSl_DdrRdDataEn_o              : out std_logic;                        -- DDR read data enable
        CpSv_DdrRdData_i                : in  std_logic_vector(63 downto 0);    -- DDR read data
        CpSl_DdrRdDataEmpty_i           : in  std_logic;                        -- DDR read data empty
        CpSv_DdrRdDataCnt_i             : in  std_logic_vector( 6 downto 0);    -- DDR read data counter
        CpSv_DdrRdTimeSlot_i            : in  std_logic_vector( 2 downto 0)     -- DDR read time slot
    );
end M_LcdIf;

architecture arch_M_LcdIf of M_LcdIf is
    ----------------------------------------------------------------------------
    -- constant declaration
    ----------------------------------------------------------------------------
    -- Refresh State
    constant PrSv_Ext100Hz_c            : std_logic_vector( 2 downto 0) := "110"; -- Ext 100Hz
    constant PrSv_Ext50Hz_c             : std_logic_vector( 2 downto 0) := "101"; -- Ext 50Hz
    constant PrSv_Ref100Hz_c            : std_logic_vector( 2 downto 0) := "100"; -- Int 100Hz
    constant PrSv_Ref85Hz_c             : std_logic_vector( 2 downto 0) := "011"; -- Int 85Hz
    constant PrSv_Ref60Hz_c             : std_logic_vector( 2 downto 0) := "010"; -- Int 60Hz
    constant PrSv_Ref50Hz_c             : std_logic_vector( 2 downto 0) := "001"; -- Int 50Hz
    
--    -- VCnt(1128 test got)
--    constant PrSv_VCntStart_c           : std_logic_vector(11 downto 0):= x"030"; -- 48
--    constant PrSv_VCntStop_c            : std_logic_vector(11 downto 0):= x"468"; -- 1128
--    constant PrSv_VCntEnd_c             : std_logic_vector(11 downto 0):= x"469"; -- 1129

    -- Lcd VCnt
    constant PrSv_VCntStart_c           : std_logic_vector(11 downto 0) := x"024"; -- 36
    constant PrSv_VCntStop_c            : std_logic_vector(11 downto 0) := x"45C"; -- 1116
    constant PrSv_VCntEnd_c             : std_logic_vector(11 downto 0) := x"464"; -- 1125
    
    -- HCnt
    constant PrSv_HCntStart_c           : std_logic_vector(11 downto 0):= x"06B"; -- 108
    constant PrSv_HCntStop_c            : std_logic_vector(11 downto 0):= x"1D3"; -- 468
    ------------------------------------
    -- LcdClk = 70MHz
    -- Refresh Rate : 100Hz\85Hz\60Hz\50Hz
    -- Image In  : 1440*1080
    -- Image Out : 1440*1080 
    -- HCntEnd = Clk / 1125 / Refresh Rate
    -- 1、100Hz Refresh Rate
    --     70/1125/100 = 622
    --     70/1125/101 = 616
    -- 2、85Hz Refresh Rate
    --     70/1125/85 = 732
    -- 3、60Hz Refresh Rate
    --     70/1125/120 = 518
    -- 4、50Hz Refresh Rate
    --     70/1125/100 = 622
    --     70/1125/102 = 610
    ------------------------------------
    constant PrSv_Ext100HzHCntEnd_c     : std_logic_vector(11 downto 0):= x"267"; -- 616
    constant PrSv_Ext50HzHCntEnd_c      : std_logic_vector(11 downto 0):= x"261"; -- 610
    constant PrSv_Ref100HzHCntEnd_c     : std_logic_vector(11 downto 0):= x"26D"; -- 622
    constant PrSv_Ref85HzHCntEnd_c      : std_logic_vector(11 downto 0):= x"2DB"; -- 732
    constant PrSv_Ref60HzHCntEnd_c      : std_logic_vector(11 downto 0):= x"205"; -- 518
    constant PrSv_Ref50HzHCntEnd_c      : std_logic_vector(11 downto 0):= x"26D"; -- 622

    ----------------------------------------------------------------------------
    -- component declaration
    ----------------------------------------------------------------------------
    component M_LcdTxFifo port (
        rst                             : in  std_logic;
        wr_clk                          : in  std_logic;
        wr_en                           : in  std_logic;
        din                             : in  std_logic_vector(63 downto 0);
        full                            : out std_logic;

        rd_clk                          : in  std_logic;
        rd_en                           : in  std_logic;
        dout                            : out std_logic_vector(31 downto 0);
        empty                           : out std_logic
    );
    end component;

    ----------------------------------------------------------------------------
    -- signal declaration
    ----------------------------------------------------------------------------
    -- FIFO
    signal PrSl_FifoWen_s               : std_logic;                            -- FIFO write enable
    signal PrSv_FifoWdata_s             : std_logic_vector(63 downto 0);        -- FIFO write data
    signal PrSl_FifoRen_s               : std_logic;                            -- FIFO read enable
    signal PrSv_FifoRdata_s             : std_logic_vector(31 downto 0);        -- FIFO read data
    signal PrSl_FifoFull_s              : std_logic;
    signal PrSl_FifoEmpty_s             : std_logic;
    -- LCD
    signal PrSv_HCnt_s                  : std_logic_vector(11 downto 0);        -- H counter
    signal PrSv_VCnt_s                  : std_logic_vector(11 downto 0);        -- V counter
    signal PrSl_Hsync_s                 : std_logic;                            -- Inner Hsync
    signal PrSl_Vsync_s                 : std_logic;                            -- Inner Vsync
    signal PrSl_DisDvld_s               : std_logic;                            -- H Display data valid
    signal PrSl_VdisDvld_s              : std_logic;                            -- V Display data valid
    signal PrSl_DoubleDly1_s            : std_logic;                            -- Delay Double 1 Clk
    signal PrSl_DoubleDly2_s            : std_logic;                            -- Delay Double 2 Clk
    
    -- Vsync 
    signal PrSl_VsyncDly1_s             : std_logic;                            -- Delay Vsync 1 Clk
    signal PrSl_VsyncDly2_s             : std_logic;                            -- Delay Vsync 2 Clk
    signal PrSl_VsyncDly3_s             : std_logic;                            -- Delay Vsync 3 Clk
    signal PrSl_VsyncTrig_s             : std_logic;                            -- Vsync Trig
    signal PrSl_LcdVsync_s              : std_logic;                            -- lcd Double Vsync
    signal PrSl_LcdVsyncDly1_s          : std_logic;                            -- Lcd Double Vsync Dly 1 Clk
    signal PrSl_LcdVsyncDly2_s          : std_logic;                            -- Lcd Double Vsync Dly 2 Clk
    
    --LCD State
    signal PrSv_HCntEnd_s               : std_logic_vector(11 downto 0);        -- HCnt End
    signal PrSv_FreState_s              : std_logic_vector( 2 downto 0);        -- Fresh Rate State
    signal PrSv_LcdState_s              : std_logic_vector( 1 downto 0);        -- Lcd State
    
    
    -- DDR
    signal PrSl_DdrRdInd_s              : std_logic;                            -- DDR read period indicator
    signal PrSl_DdrRdTrig_s             : std_logic;                            -- DDR read trigger
    signal PrSv_RdataCnt_s              : std_logic_vector( 5 downto 0);        -- DDR read data counter 
    signal PrSv_DdrRdCmdCnt_s           : std_logic_vector( 1 downto 0);        -- DDR read command counter
    signal PrSl_DdrRdCmdEn_s            : std_logic;                            -- DDR read command enable
    signal PrSv_DdrRdAddrLow_s          : std_logic_vector(10 downto 0);        -- DDR read address low part
    signal PrSv_DdrRdAddrMid_s          : std_logic_vector(10 downto 0);        -- DDR read address middle part
    signal PrSv_DdrRdAddrHig_s          : std_logic_vector( 7 downto 0);        -- DDR read address high part
    --
    signal PrSv_VisVCnt_s               : std_logic_vector(10 downto 0);        -- Visual V counter
    signal PrSl_VisDvld_s               : std_logic;                            -- Visual data valid

begin
    ----------------------------------------------------------------------------
    -- FIFO data in
    ----------------------------------------------------------------------------
    CpSl_DdrRdDataEn_o <= not CpSl_DdrRdDataEmpty_i;
    PrSl_FifoWen_s     <= not CpSl_DdrRdDataEmpty_i;
    PrSv_FifoWdata_s   <= CpSv_DdrRdData_i         ;

    ----------------------------------------------------------------------------
    -- component map
    ----------------------------------------------------------------------------
    U_M_LcdTxFifo_0 : M_LcdTxFifo port map (
--        rst                             => CpSl_VsyncCtrl_i                     , -- in  std_logic;
        rst                             => PrSl_VsyncTrig_s                     , -- in  std_logic;
        wr_clk                          => CpSl_LcdClk_i                        , -- in  std_logic;
        wr_en                           => PrSl_FifoWen_s                       , -- in  std_logic;
        din                             => PrSv_FifoWdata_s                     , -- in  std_logic_vector(63 downto 0);
        full                            => PrSl_FifoFull_s                      , -- out std_logic;

        rd_clk                          => CpSl_LcdClk_i                        , -- in  std_logic;
        rd_en                           => PrSl_FifoRen_s                       , -- in  std_logic;
        dout                            => PrSv_FifoRdata_s                     , -- out std_logic_vector(31 downto 0);
        empty                           => PrSl_FifoEmpty_s                       -- out std_logic
    );

    ----------------------------------------------------------------------------
    -- LCD State
    ----------------------------------------------------------------------------
    -- Delay CpSv_FreChoice_i 1 Clk
    process (CpSl_Rst_iN, CpSl_LcdClk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            PrSv_FreState_s <= (others => '0');
        elsif rising_edge (CpSl_LcdClk_i) then 
            PrSv_FreState_s <= CpSv_FreChoice_i;
        end if;
    end process;
    
    -- LCD State
    process (CpSl_Rst_iN, CpSl_LcdClk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            PrSv_HCntEnd_s <= (others => '0');
        elsif rising_edge (CpSl_LcdClk_i) then 
            case PrSv_FreState_s is 
                -- Ext 100Hz
                when PrSv_Ext100Hz_c => 
                    PrSv_HCntEnd_s <= PrSv_Ext100HzHCntEnd_c;
                    
                -- Ext 50Hz
                when PrSv_Ext50Hz_c => 
                    PrSv_HCntEnd_s <= PrSv_Ext50HzHCntEnd_c;
                    
                -- Int 100Hz 
                when PrSv_Ref100Hz_c => 
                    PrSv_HCntEnd_s <= PrSv_Ref100HzHCntEnd_c;
                    
                -- Int 85Hz
                when PrSv_Ref85Hz_c => 
                    PrSv_HCntEnd_s <= PrSv_Ref100HzHCntEnd_c;
                
                -- Int 60Hz 
                when PrSv_Ref60Hz_c => 
                    PrSv_HCntEnd_s <= PrSv_Ref100HzHCntEnd_c; 
                    
                -- Int 50Hz
                when PrSv_Ref50Hz_c => 
                    PrSv_HCntEnd_s <= PrSv_Ref100HzHCntEnd_c;
                    
                when others => 
                    PrSv_HCntEnd_s <= (others => '0');
             end case;
                    
        end if;
    end process;


    -- Delay CpSl_VsyncCtrl_i 3 Clk
    process (CpSl_Rst_iN, CpSl_LcdClk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            PrSl_VsyncDly1_s <= '0';
            PrSl_VsyncDly2_s <= '0';
            PrSl_VsyncDly3_s <= '0';
        elsif rising_edge (CpSl_LcdClk_i) then 
            PrSl_VsyncDly1_s <= CpSl_VsyncCtrl_i;
            PrSl_VsyncDly2_s <= PrSl_VsyncDly1_s;
            PrSl_VsyncDly3_s <= PrSl_VsyncDly2_s;
        end if;
    end process;
    
    -- VsyncTrig
    PrSl_VsyncTrig_s <= '1' when (PrSl_VsyncDly2_s = '1' and PrSl_VsyncDly3_s = '0') else '0';
    
    -- Lcd State
    process (CpSl_Rst_iN, CpSl_LcdClk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            PrSv_LcdState_s <= "00";
        elsif rising_edge (CpSl_LcdClk_i) then 
            case PrSv_LcdState_s is
                when "00" => 
                    if (PrSl_VsyncTrig_s = '1') then 
                        PrSv_LcdState_s <= "01";
                    else
                        PrSv_LcdState_s <= "00";
                    end if;
                        
                when "01" => 
                    if (PrSv_HCnt_s = PrSv_HCntEnd_s
                        and PrSv_VCnt_s = PrSv_VCntStop_c) then 
                        PrSv_LcdState_s <= "00";
                    else -- hold
                    end if;
                     
                when others => 
                    PrSv_LcdState_s <= "00";
            end case; 
        end if;
    end process;
    
    ----------------------------------------------------------------------------
    -- LCD timing generation
    ----------------------------------------------------------------------------
    -- Lcd HCnt
    process (CpSl_Rst_iN, CpSl_LcdClk_i) begin
        if (CpSl_Rst_iN = '0') then 
            PrSv_HCnt_s <= (others => '0');
        elsif rising_edge (CpSl_LcdClk_i) then 
            if (PrSv_LcdState_s = "01") then 
                if (PrSv_HCnt_s = PrSv_HCntEnd_s) then 
                    PrSv_HCnt_s <= (others => '0');
                else
                    PrSv_HCnt_s <= PrSv_HCnt_s + '1';
                end if;
            else
                PrSv_HCnt_s <= (others => '0');
            end if;
        end if;
    end process;
    
    -- Lcd VCnt
    process (CpSl_Rst_iN, CpSl_LcdClk_i) begin
        if (CpSl_Rst_iN = '0') then 
            PrSv_VCnt_s <= (others => '0');
        elsif rising_edge (CpSl_LcdClk_i) then 
            if (PrSv_LcdState_s = "01") then 
                if (PrSv_HCnt_s = PrSv_HCntEnd_s) then 
                    if (PrSv_VCnt_s = PrSv_VCntStop_c) then 
                        PrSv_VCnt_s <= PrSv_VCntStop_c;
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
    
    -- Lcd Hsync
    process (CpSl_Rst_iN, CpSl_LcdClk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            PrSl_Hsync_s <= '0';
        elsif rising_edge (CpSl_LcdClk_i) then 
            if (PrSv_LcdState_s = "01") then 
                if (PrSv_HCnt_s = 0) then 
                    PrSl_Hsync_s <= '1';
                else
                    PrSl_Hsync_s <= '0';
                end if;
            else
                PrSl_Hsync_s <= '0';
            end if;
        end if;
    end process;
    
    -- Lcd Vsync
    process (CpSl_Rst_iN, CpSl_LcdClk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            PrSl_Vsync_s <= '0';
        elsif rising_edge (CpSl_LcdClk_i) then 
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

    -- Lcd Sync output
    CpSl_LcdHsync_o <= PrSl_Hsync_s;
    CpSl_LcdVsync_o <= PrSl_Vsync_s;
    
    -- H Display data Valid
    process (CpSl_Rst_iN, CpSl_LcdClk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_DisDvld_s <= '0';
        elsif rising_edge (CpSl_LcdClk_i) then 
            if (PrSv_LcdState_s = "01") then 
                if (PrSv_HCnt_s = PrSv_HCntStart_c) then 
                    PrSl_DisDvld_s <= '1';
                elsif (PrSv_HCnt_s = PrSv_HCntStop_c) then 
                    PrSl_DisDvld_s <= '0';
                else -- hold 
                end if;
            else
                PrSl_DisDvld_s <= '0';
            end if;
        end if;
    end process;
    
    -- V display data valid
    process (CpSl_Rst_iN, CpSl_LcdClk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_VdisDvld_s <= '0';
        elsif rising_edge (CpSl_LcdClk_i) then 
            if (PrSv_LcdState_s = "01") then 
                if (PrSv_VCnt_s = PrSv_VCntStart_c) then 
                    PrSl_VdisDvld_s <= '1';
                elsif (PrSv_VCnt_s = PrSv_VCntStop_c) then 
                    PrSl_VdisDvld_s <= '0';
                else -- hold 
                end if;
            else
                PrSl_VdisDvld_s <= '0';
            end if;
        end if;
    end process;
    
    -- Enable Read data from fifo
    PrSl_FifoRen_s <= PrSl_DisDvld_s and PrSl_VdisDvld_s and (not PrSl_FifoEmpty_s);
    
    -- Data output
    CpSv_LcdR0_o <= (PrSv_FifoRdata_s(31 downto 24) & x"0") when (PrSl_FifoRen_s = '1') else (others => '0');
    CpSv_LcdR1_o <= (PrSv_FifoRdata_s(23 downto 16) & x"0") when (PrSl_FifoRen_s = '1') else (others => '0');
    CpSv_LcdR2_o <= (PrSv_FifoRdata_s(15 downto  8) & x"0") when (PrSl_FifoRen_s = '1') else (others => '0');
    CpSv_LcdR3_o <= (PrSv_FifoRdata_s( 7 downto  0) & x"0") when (PrSl_FifoRen_s = '1') else (others => '0');

    ----------------------------------------------------------------------------
    -- DDR timing generation
    ----------------------------------------------------------------------------
    -- DDR read period indicator
--    process (CpSl_Rst_iN, CpSl_LcdClk_i) begin
--        if (CpSl_Rst_iN = '0') then
--            PrSl_DdrRdInd_s <= '0';
--        elsif rising_edge(CpSl_LcdClk_i) then
--            if (PrSv_VCnt_s = 47) then
--                PrSl_DdrRdInd_s <= '1';
--            elsif (PrSv_VCnt_s = 2) then
--                PrSl_DdrRdInd_s <= '0';
--            else -- hold
--            end if;
--        end if;
--    end process;

    process (CpSl_Rst_iN, CpSl_LcdClk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            PrSl_DdrRdInd_s <= '0';
        elsif rising_edge (CpSl_LcdClk_i) then 
            if (PrSv_LcdState_s = "01") then 
                if (PrSv_VCnt_s = PrSv_VCntStart_c - 1) then 
                    PrSl_DdrRdInd_s <= '1';
                elsif (PrSv_VCnt_s = PrSv_VCntStop_c - 1) then 
                    PrSl_DdrRdInd_s <= '0';
                else -- hold
                end if;
            else
                PrSl_DdrRdInd_s <= '0';
            end if;
        end if;
    end process;

    -- DDR read period indicator
    PrSl_DdrRdTrig_s <= PrSl_DdrRdInd_s and PrSl_Hsync_s;
    
    -- DDR read data counter
    process (CpSl_Rst_iN, CpSl_LcdClk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_RdataCnt_s <= (others => '0');
        elsif rising_edge(CpSl_LcdClk_i) then
            if (PrSl_DdrRdTrig_s = '1') then
                PrSv_RdataCnt_s <= (others => '0');
            elsif (CpSl_DdrRdDataEmpty_i = '0') then
                if (PrSv_RdataCnt_s = 59) then
                    PrSv_RdataCnt_s <= (others => '0');
                else
                    PrSv_RdataCnt_s <= PrSv_RdataCnt_s + '1';
                end if;
            else -- hold
            end if;
        end if;
    end process;

    -- DDR read command enable
    process (CpSl_Rst_iN, CpSl_LcdClk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_DdrRdCmdEn_s <= '0';
        elsif rising_edge(CpSl_LcdClk_i) then
            if ((PrSl_DdrRdTrig_s = '1') or
                (PrSv_DdrRdCmdCnt_s = "01" and PrSv_RdataCnt_s = 59 and CpSl_DdrRdDataEmpty_i = '0') or
                (PrSv_DdrRdCmdCnt_s = "10" and PrSv_RdataCnt_s = 59 and CpSl_DdrRdDataEmpty_i = '0')) then
                PrSl_DdrRdCmdEn_s <= '1';
            elsif (CpSl_DdrRdCmdFull_i = '0') then
                PrSl_DdrRdCmdEn_s <= '0';
            else -- hold
            end if;
        end if;
    end process;

    -- DDR read command counter
    process (CpSl_Rst_iN, CpSl_LcdClk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_DdrRdCmdCnt_s <= "11";
        elsif rising_edge(CpSl_LcdClk_i) then
            if (PrSl_DdrRdTrig_s = '1') then
                PrSv_DdrRdCmdCnt_s <= "00";
            elsif (PrSv_DdrRdCmdCnt_s = "11") then
                PrSv_DdrRdCmdCnt_s <= PrSv_DdrRdCmdCnt_s;
            elsif (PrSl_DdrRdCmdEn_s = '1' and CpSl_DdrRdCmdFull_i = '0') then
                PrSv_DdrRdCmdCnt_s <= PrSv_DdrRdCmdCnt_s + '1';
            else -- hold
            end if;
        end if;
    end process;

    -- DDR read address low
    process (CpSl_Rst_iN, CpSl_LcdClk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_DdrRdAddrLow_s <= (others => '0');
        elsif rising_edge(CpSl_LcdClk_i) then
            if (PrSl_DdrRdCmdEn_s = '1' and CpSl_DdrRdCmdFull_i = '0') then
                if (PrSv_DdrRdCmdCnt_s = "00") then
                    PrSv_DdrRdAddrLow_s <= "00111100" & "000"; --  60
                elsif (PrSv_DdrRdCmdCnt_s = "01") then
                    PrSv_DdrRdAddrLow_s <= "01111000" & "000"; -- 120
                elsif (PrSv_DdrRdCmdCnt_s = "10") then
                    PrSv_DdrRdAddrLow_s <= "00000000" & "000"; --   0
                else -- hold
                end if;
            else -- hold
            end if;
        end if;
    end process;

    -- DDR read address middle
    process (CpSl_Rst_iN, CpSl_LcdClk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_DdrRdAddrMid_s <= (others => '1');
        elsif rising_edge(CpSl_LcdClk_i) then
            if (PrSl_DdrRdInd_s = '1') then
                if (PrSl_DdrRdTrig_s = '1') then
                    PrSv_DdrRdAddrMid_s <= PrSv_DdrRdAddrMid_s + '1';
                else -- hold
                end if;
            else
                PrSv_DdrRdAddrMid_s <= (others => '1');
            end if;
        end if;
    end process;

    -- DDR read address high
--    process (CpSl_Rst_iN, CpSl_LcdClk_i) begin
--        if (CpSl_Rst_iN = '0') then
--            PrSv_DdrRdAddrHig_s <= (others => '0');
--        elsif rising_edge(CpSl_LcdClk_i) then
--        case CpSv_DdrRdTimeSlot_i is
--            when "000"  => if (CpSl_VsyncCtrl_i = '1') then PrSv_DdrRdAddrHig_s <= "00000" & "100"; else end if;
--            when "010"  => if (CpSl_VsyncCtrl_i = '1') then PrSv_DdrRdAddrHig_s <= "00000" & "000"; else end if;
--            when "100"  => if (CpSl_VsyncCtrl_i = '1') then PrSv_DdrRdAddrHig_s <= "00000" & "010"; else end if;
--            when others => PrSv_DdrRdAddrHig_s <= (others => '0');
--        end case;
--        end if;
--    end process;
    
    -- DDR Read High Address
    process (CpSl_Rst_iN, CpSl_LcdClk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_DdrRdAddrHig_s <= (others => '0');
        elsif rising_edge(CpSl_LcdClk_i) then
        case CpSv_DdrRdTimeSlot_i is
            when "000"  => if (PrSl_VsyncTrig_s = '1') then PrSv_DdrRdAddrHig_s <= "00000" & "100"; else end if;
            when "010"  => if (PrSl_VsyncTrig_s = '1') then PrSv_DdrRdAddrHig_s <= "00000" & "000"; else end if;
            when "100"  => if (PrSl_VsyncTrig_s = '1') then PrSv_DdrRdAddrHig_s <= "00000" & "010"; else end if;
            when others => PrSv_DdrRdAddrHig_s <= (others => '0');
        end case;
        end if;
    end process;

    CpSl_DdrRdCmdEn_o   <= PrSl_DdrRdCmdEn_s;
    CpSv_DdrRdCmdAddr_o <= PrSv_DdrRdAddrHig_s & PrSv_DdrRdAddrMid_s & PrSv_DdrRdAddrLow_s;

    ----------------------------------------------------------------------------
    -- Add by liuhai @20140422
    ----------------------------------------------------------------------------
    -- Visual V counter
    process (CpSl_Rst_iN, CpSl_LcdClk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_VisVCnt_s <= b"100_0011_1000";
        elsif rising_edge(CpSl_LcdClk_i) then
            if (PrSl_Hsync_s = '1') then
                if (PrSv_VCnt_s = 46) then
                    PrSv_VisVCnt_s <= (others => '0');
                elsif (PrSv_VisVCnt_s = 1080) then
                    PrSv_VisVCnt_s <= PrSv_VisVCnt_s;
                else
                    PrSv_VisVCnt_s <= PrSv_VisVCnt_s + '1';
                end if;
            else -- hold
            end if;
        end if;
    end process;

    -- Visual data valid
    PrSl_VisDvld_s <= '1' when (PrSv_VisVCnt_s /= 1080) else '0';

end arch_M_LcdIf;