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
-- 文件名称  :  M_DviIf.vhd
-- 设    计  :  LIU Hai 
-- 邮    件  :  zheng-jianfeng@139.com
-- 校    对  :  
-- 设计日期  :  2014/04/08
-- 功能简述  :  DVI interface
-- 版本序号  :  0.1
-- 修改历史  :  1. Initial, LIU Hai, 2014/04/08
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity M_DviIf is
    port (
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
end M_DviIf;

architecture arch_M_DviIf of M_DviIf is
    ----------------------------------------------------------------------------
    -- constant declaration
    ----------------------------------------------------------------------------

    ----------------------------------------------------------------------------
    -- component declaration
    ----------------------------------------------------------------------------
    component M_DviRxFifo port (
        rst                             : in  std_logic;
        wr_clk                          : in  std_logic;
        wr_en                           : in  std_logic;
        din                             : in  std_logic_vector( 7 downto 0);
        full                            : out std_logic;

        rd_clk                          : in  std_logic;
        rd_en                           : in  std_logic;
        dout                            : out std_logic_vector(63 downto 0);
        empty                           : out std_logic
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

    ----------------------------------------------------------------------------
    -- signal declaration
    ----------------------------------------------------------------------------
    -- 
--    signal PrSv_ChipCtrl0_s             : std_logic_vector(35 downto 0);        -- 
--    signal PrSv_ChipCtrl1_s             : std_logic_vector(35 downto 0);        -- 
--    signal PrSv_ChipTrig0_s             : std_logic_vector(15 downto 0);        -- 
--    signal PrSv_ChipTrig1_s             : std_logic_vector(15 downto 0);        -- 
    --
    signal PrSl_DviClk_s                : std_logic;                            -- DVI clk inverse
    signal PrSl_DviDeDly_s              : std_logic;                            -- Delay CpSl_DviDe_i in DVI clk
    signal PrSv_CntDataIn_s             : std_logic_vector(10 downto 0);        -- DVI input data counter
    signal PrSl_FifoWen_s               : std_logic;                            -- FIFO write enable
    signal PrSv_FifoWdata_s             : std_logic_vector( 7 downto 0);        -- FIFO write data
    signal PrSl_DviVsyncDly1_s          : std_logic;                            -- Delay CpSl_DviVsync_i 1 clk 
    signal PrSl_DviVsyncDly2_s          : std_logic;                            -- Delay CpSl_DviVsync_i 2 clk 
    signal PrSl_DviVsyncDly3_s          : std_logic;                            -- Delay CpSl_DviVsync_i 3 clk 
    signal PrSl_DviHsyncDly1_s          : std_logic;                            -- Delay CpSl_DviHsync_i 1 clk 
    signal PrSl_DviHsyncDly2_s          : std_logic;                            -- Delay CpSl_DviHsync_i 2 clk 
    signal PrSl_DviHsyncDly3_s          : std_logic;                            -- Delay CpSl_DviHsync_i 3 clk 
    signal PrSl_DviDeDly1_s             : std_logic;                            -- Delay CpSl_DviDe_i 1 clk
    signal PrSl_DviDeDly2_s             : std_logic;                            -- Delay CpSl_DviDe_i 2 clk
    signal PrSl_DviDeDly3_s             : std_logic;                            -- Delay CpSl_DviDe_i 3 clk
    signal PrSl_RowRdStart_s            : std_logic;                            -- Row data read start
    signal PrSl_RowCntEn_s              : std_logic;                            -- Row counter enable
    signal PrSv_RowCnt_s                : std_logic_vector( 5 downto 0);        -- Row counter
    signal PrSl_FifoRen_s               : std_logic;                            -- FIFO read enable
    signal PrSv_RowCmdCnt_s             : std_logic_vector( 1 downto 0);        -- Row command counter
    signal PrSl_DdrWrCmdEn_s            : std_logic;                            -- DDR write command enable
    signal PrSv_DdrWrAddrLow_s          : std_logic_vector(10 downto 0);        -- DDR write address low part
    signal PrSv_DdrWrAddrMid_s          : std_logic_vector(10 downto 0);        -- DDR write address middle part
    signal PrSv_DdrWrAddrHig_s          : std_logic_vector( 7 downto 0);        -- DDR write address high part
    signal PrSl_FifoFull_s              : std_logic;
    signal PrSl_FifoEmpty_s             : std_logic;

begin
--    ----------------------------------------------------------------------------
--    -- Chipscope
--    ----------------------------------------------------------------------------
--    U_M_Icon_0 : M_Icon port map (
--        control0                        => PrSv_ChipCtrl0_s                     ,
--        control1                        => PrSv_ChipCtrl1_s
--    );
--
--    ------------------------------------
--    -- DDR
--    ------------------------------------
--    U_M_Ila_0 : M_Ila port map (
--        control                         => PrSv_ChipCtrl0_s                     ,
--        clk                             => PrSl_DviClk_s                        ,
--        trig0                           => PrSv_ChipTrig0_s
--    );
--
--    U_M_Ila_1 : M_Ila port map (
--        control                         => PrSv_ChipCtrl1_s                     ,
--        clk                             => PrSl_DviClk_s                        ,
--        trig0                           => PrSv_ChipTrig1_s
--    );
--
--    PrSv_ChipTrig0_s( 7 downto  0) <= PrSv_FifoWdata_s;
--    PrSv_ChipTrig0_s(           8) <= PrSl_FifoWen_s  ;
--    PrSv_ChipTrig0_s(           9) <= CpSl_DviVsync_i ;
--    PrSv_ChipTrig0_s(15 downto 10) <= (others => '0') ;
--
--    PrSv_ChipTrig1_s( 7 downto  0) <= PrSv_FifoWdata_s;
--    PrSv_ChipTrig1_s(           8) <= PrSl_FifoWen_s  ;
--    PrSv_ChipTrig1_s(           9) <= CpSl_DviVsync_i ;
--    PrSv_ChipTrig1_s(15 downto 10) <= (others => '0') ;

    ----------------------------------------------------------------------------
    -- DVI input, DVI clk domain
    ----------------------------------------------------------------------------
    PrSl_DviClk_s <= not CpSl_DviClk_i;

    -- Delay De
    process (CpSl_Rst_iN, PrSl_DviClk_s) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_DviDeDly_s <= '0';
        elsif rising_edge(PrSl_DviClk_s) then
            PrSl_DviDeDly_s <= CpSl_DviDe_i ;
        end if;
    end process;

    -- Cnt data in
    process (CpSl_Rst_iN, PrSl_DviClk_s) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_CntDataIn_s <= "10110100000"; -- 1440
        elsif rising_edge(PrSl_DviClk_s) then
            if (CpSl_DviDe_i = '1' and PrSl_DviDeDly_s = '0') then
                PrSv_CntDataIn_s <= (others => '0');
            elsif (PrSv_CntDataIn_s = 1440) then
                PrSv_CntDataIn_s <= PrSv_CntDataIn_s;
            else
                PrSv_CntDataIn_s <= PrSv_CntDataIn_s + '1';
            end if;
        end if;
    end process;

    -- FIFO write enable
    PrSl_FifoWen_s <= '1' when PrSv_CntDataIn_s /= 1440 else '0';

    -- Delay R
    process (CpSl_Rst_iN, PrSl_DviClk_s) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_FifoWdata_s <= (others => '0');
        elsif rising_edge(PrSl_DviClk_s) then
            PrSv_FifoWdata_s <= CpSv_DviR_i ;
        end if;
    end process;

    ----------------------------------------------------------------------------
    -- DDR write control
    ----------------------------------------------------------------------------
    -- Delay CpSl_DviVsync_i, CpSl_DviHsync_i, CpSl_DviDe_i 3 clk
    process (CpSl_Rst_iN, CpSl_DdrClk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_DviVsyncDly1_s <= '0';
            PrSl_DviVsyncDly2_s <= '0';
            PrSl_DviVsyncDly3_s <= '0';

            PrSl_DviHsyncDly1_s <= '0';
            PrSl_DviHsyncDly2_s <= '0';
            PrSl_DviHsyncDly3_s <= '0';

            PrSl_DviDeDly1_s <= '0';
            PrSl_DviDeDly2_s <= '0';
            PrSl_DviDeDly3_s <= '0';
        elsif rising_edge(CpSl_DdrClk_i) then
            PrSl_DviVsyncDly1_s <= CpSl_DviVsync_i    ;
            PrSl_DviVsyncDly2_s <= PrSl_DviVsyncDly1_s;
            PrSl_DviVsyncDly3_s <= PrSl_DviVsyncDly2_s;

            PrSl_DviHsyncDly1_s <= CpSl_DviHsync_i    ;
            PrSl_DviHsyncDly2_s <= PrSl_DviHsyncDly1_s;
            PrSl_DviHsyncDly3_s <= PrSl_DviHsyncDly2_s;

            PrSl_DviDeDly1_s <= CpSl_DviDe_i    ;
            PrSl_DviDeDly2_s <= PrSl_DviDeDly1_s;
            PrSl_DviDeDly3_s <= PrSl_DviDeDly2_s;
        end if;
    end process;

    -- Row data read start
    PrSl_RowRdStart_s <= (not PrSl_DviDeDly2_s) and PrSl_DviDeDly3_s;

    -- Row counter enable
    process (CpSl_Rst_iN, CpSl_DdrClk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_RowCntEn_s <= '0';
        elsif rising_edge(CpSl_DdrClk_i) then
            if ((PrSl_RowRdStart_s = '1') or
                (PrSv_RowCmdCnt_s = "00" and PrSl_DdrWrCmdEn_s = '1' and CpSl_DdrWrCmdFull_i = '0') or
                (PrSv_RowCmdCnt_s = "01" and PrSl_DdrWrCmdEn_s = '1' and CpSl_DdrWrCmdFull_i = '0'))then
                PrSl_RowCntEn_s <= '1';
            elsif (PrSv_RowCnt_s = 59 and CpSl_DdrWrDataFull_i = '0') then
                PrSl_RowCntEn_s <= '0';
            else -- hold
            end if;
        end if;
    end process;

    -- Row counter
    process (CpSl_Rst_iN, CpSl_DdrClk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_RowCnt_s <= "111100"; -- 60
        elsif rising_edge(CpSl_DdrClk_i) then
            if ((PrSl_RowRdStart_s = '1') or
                (PrSv_RowCmdCnt_s = "00" and PrSl_DdrWrCmdEn_s = '1' and CpSl_DdrWrCmdFull_i = '0') or
                (PrSv_RowCmdCnt_s = "01" and PrSl_DdrWrCmdEn_s = '1' and CpSl_DdrWrCmdFull_i = '0'))then
                PrSv_RowCnt_s <= (others => '0');
            elsif (PrSl_RowCntEn_s = '1' and CpSl_DdrWrDataFull_i = '0') then
                PrSv_RowCnt_s <= PrSv_RowCnt_s + '1';
            else -- hold
            end if;
        end if;
    end process;

    -- FIFO read enable
    PrSl_FifoRen_s <= PrSl_RowCntEn_s and (not CpSl_DdrWrDataFull_i);

    -- Row command counter
    process (CpSl_Rst_iN, CpSl_DdrClk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_RowCmdCnt_s <= "11";
        elsif rising_edge(CpSl_DdrClk_i) then
            if (PrSl_RowRdStart_s = '1') then
                PrSv_RowCmdCnt_s <= "00";
            elsif (PrSl_DdrWrCmdEn_s = '1' and CpSl_DdrWrCmdFull_i = '0') then
                PrSv_RowCmdCnt_s <= PrSv_RowCmdCnt_s + '1';
            else -- hold
            end if;
        end if;
    end process;

    -- DDR write command enable
    process (CpSl_Rst_iN, CpSl_DdrClk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_DdrWrCmdEn_s <= '0';
        elsif rising_edge(CpSl_DdrClk_i) then
            if (PrSv_RowCnt_s = 59 and CpSl_DdrWrDataFull_i = '0') then
                PrSl_DdrWrCmdEn_s <= '1';
            elsif (CpSl_DdrWrCmdFull_i = '0') then
                PrSl_DdrWrCmdEn_s <= '0';
            else -- hold
            end if;
        end if;
    end process;

    ----------------------------------------------------------------------------
    -- Instant
    ----------------------------------------------------------------------------
    U_M_DviRxFifo_0 : M_DviRxFifo port map (
        rst                             => CpSl_DviVsync_i                      , -- in  std_logic;
        wr_clk                          => PrSl_DviClk_s                        , -- in  std_logic;
        wr_en                           => PrSl_FifoWen_s                       , -- in  std_logic;
        din                             => PrSv_FifoWdata_s                     , -- in  std_logic_vector( 7 downto 0);
        full                            => PrSl_FifoFull_s                      , -- out std_logic;

        rd_clk                          => CpSl_DdrClk_i                        , -- in  std_logic;
        rd_en                           => PrSl_FifoRen_s                       , -- in  std_logic;
        dout                            => CpSv_DdrWrData_o                     , -- out std_logic_vector(63 downto 0);
        empty                           => PrSl_FifoEmpty_s                       -- out std_logic
    );

    ----------------------------------------------------------------------------
    -- DDR write
    ----------------------------------------------------------------------------
    -- DDR write address low
    process (CpSl_Rst_iN, CpSl_DdrClk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_DdrWrAddrLow_s <= (others => '0');
        elsif rising_edge(CpSl_DdrClk_i) then
            if (PrSl_DdrWrCmdEn_s = '1' and CpSl_DdrWrCmdFull_i = '0') then
                if (PrSv_RowCmdCnt_s = "00") then
                    PrSv_DdrWrAddrLow_s <= "00111100" & "000"; --  60
                elsif (PrSv_RowCmdCnt_s = "01") then
                    PrSv_DdrWrAddrLow_s <= "01111000" & "000"; -- 120
                elsif (PrSv_RowCmdCnt_s = "10") then
                    PrSv_DdrWrAddrLow_s <= "00000000" & "000"; --   0
                else -- hold
                end if;
            else -- hold
            end if;
        end if;
    end process;

    -- DDR write address middle
    process (CpSl_Rst_iN, CpSl_DdrClk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_DdrWrAddrMid_s <= (others => '1');
        elsif rising_edge(CpSl_DdrClk_i) then
            if (PrSl_DviVsyncDly2_s = '0') then
                if (PrSl_DviDeDly2_s = '0' and PrSl_DviDeDly3_s = '1') then
                    PrSv_DdrWrAddrMid_s <= PrSv_DdrWrAddrMid_s + '1';
                else -- hold
                end if;
            else
                PrSv_DdrWrAddrMid_s <= (others => '1');
            end if;
        end if;
    end process;

    -- DDR write address high
    process (CpSl_Rst_iN, CpSl_DdrClk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_DdrWrAddrHig_s <= (others => '0');
        elsif rising_edge(CpSl_DdrClk_i) then
        case PrSv_DdrWrAddrHig_s( 2 downto 0) is
            when "000"  => if (PrSl_DviVsyncDly2_s = '0' and PrSl_DviVsyncDly3_s = '1') then PrSv_DdrWrAddrHig_s <= "00000" & "010"; else end if;
            when "010"  => if (PrSl_DviVsyncDly2_s = '0' and PrSl_DviVsyncDly3_s = '1') then PrSv_DdrWrAddrHig_s <= "00000" & "100"; else end if;
            when "100"  => if (PrSl_DviVsyncDly2_s = '0' and PrSl_DviVsyncDly3_s = '1') then PrSv_DdrWrAddrHig_s <= "00000" & "000"; else end if;
            when others => PrSv_DdrWrAddrHig_s <= (others => '0');
        end case;
        end if;
    end process;

    CpSl_DdrWrCmdEn_o   <= PrSl_DdrWrCmdEn_s;
    CpSv_DdrWrCmdAddr_o <= PrSv_DdrWrAddrHig_s & PrSv_DdrWrAddrMid_s & PrSv_DdrWrAddrLow_s;
    CpSl_DdrWrDataEn_o  <= PrSl_FifoRen_s;
    CpSv_DdrWrTimeSlot_o<= PrSv_DdrWrAddrHig_s( 2 downto 0);

end arch_M_DviIf;