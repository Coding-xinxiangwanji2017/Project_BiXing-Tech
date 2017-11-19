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
-- 文件名称  :  M_CtrlInd.vhd
-- 设    计  :  Zhang Wenjun
-- 邮    件  :  wenjunzhang@bixing-tech.com
-- 校    对  :  
-- 设计日期  :  2017/05/16
-- 功能简述  :  Control and indicate signal
-- 版本序号  :  0.1
-- 修改历史  :  1. Initial, Zhang Wenjun, 2017/05/16
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity M_CtrlInd is
    port (
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      : in  std_logic;                        -- Clock, 100MHz

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
end M_CtrlInd;

architecture arch_M_CtrlInd of M_CtrlInd is
    ----------------------------------------------------------------------------
    -- constant declaration
    ----------------------------------------------------------------------------

    ----------------------------------------------------------------------------
    -- component declaration
    ----------------------------------------------------------------------------

    ----------------------------------------------------------------------------
    -- signal declaration
    ----------------------------------------------------------------------------
    signal PrSl_PortSel_s               : std_logic;                            -- Port select inner
    signal PrSl_IntVsyncDly1_s          : std_logic;                            -- Internal vsync delay 1 clk
    signal PrSl_IntVsyncDly2_s          : std_logic;                            -- Internal vsync delay 2 clk
    signal PrSl_IntVsyncDly3_s          : std_logic;                            -- Internal vsync delay 3 clk
    signal PrSl_ExtVsyncDly1_s          : std_logic;                            -- External vsync delay 1 clk
    signal PrSl_ExtVsyncDly2_s          : std_logic;                            -- External vsync delay 2 clk
    signal PrSl_ExtVsyncDly3_s          : std_logic;                            -- External vsync delay 3 clk
    signal PrSl_ExtVsyncDly4_s          : std_logic;                            -- External vsync delay 4 clk
    signal PrSl_IntVsync_s              : std_logic;                            -- Internal vsync
    signal PrSv_FilterCnt_s             : std_logic_vector(19 downto 0);        -- Filter counter
    signal PrSl_FilterVsync_s           : std_logic;                            -- Filter vsync
    signal PrSl_ExtVsync_s              : std_logic;                            -- External vsync
    signal PrSl_VsyncCtrl_s             : std_logic;                            -- Vsync control
    signal PrSv_ExtVldCnt_s             : std_logic_vector(23 downto 0);        -- Ext. Vsync valid counter

begin
    ----------------------------------------------------------------------------
    -- Port select inner
    ----------------------------------------------------------------------------
    -- port A "0";
    -- port B "1";
    process (CpSl_Rst_iN, CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then
            PrSl_PortSel_s <= '0';
        elsif rising_edge (CpSl_Clk_i) then 
            if (CpSl_PortSel_i = '1') then 
                PrSl_PortSel_s <= '1';
            else
                PrSl_PortSel_s <= '0';
            end if;
        end if;
    end process;
    
    -- A/B 
    CpSl_PortSel_o <= PrSl_PortSel_s;

    -- Delay CpSl_IntVsync_i 3 Clk
    -- Delay CpSl_ExtVsync_i 4 clk
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_IntVsyncDly1_s <= '0';
            PrSl_IntVsyncDly2_s <= '0';
            PrSl_IntVsyncDly3_s <= '0';

            PrSl_ExtVsyncDly1_s <= '0';
            PrSl_ExtVsyncDly2_s <= '0';
            PrSl_ExtVsyncDly3_s <= '0';
            PrSl_ExtVsyncDly4_s <= '0';
        elsif rising_edge(CpSl_Clk_i) then
            PrSl_IntVsyncDly1_s <= CpSl_IntVsync_i    ;
            PrSl_IntVsyncDly2_s <= PrSl_IntVsyncDly1_s;
            PrSl_IntVsyncDly3_s <= PrSl_IntVsyncDly2_s;

            PrSl_ExtVsyncDly1_s <= CpSl_ExtVsync_i    ;
            PrSl_ExtVsyncDly2_s <= PrSl_ExtVsyncDly1_s;
            PrSl_ExtVsyncDly3_s <= PrSl_ExtVsyncDly2_s;
            PrSl_ExtVsyncDly4_s <= PrSl_ExtVsyncDly3_s;
        end if;
    end process;

    -- Internal Vsync(Int Vsync Rising Trig)
    PrSl_IntVsync_s <= PrSl_IntVsyncDly2_s and (not PrSl_IntVsyncDly3_s);
    
    -- Filter counter
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_FilterCnt_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSl_ExtVsyncDly2_s = '1' and PrSl_ExtVsyncDly3_s = '0') then
                PrSv_FilterCnt_s <= (others => '0');
            elsif (PrSv_FilterCnt_s(19) /= '1' or PrSv_FilterCnt_s(16) /= '1') then
                PrSv_FilterCnt_s <= PrSv_FilterCnt_s + '1';
            else -- hold
            end if;
        end if;
    end process;

    -- Filter Vsync
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_FilterVsync_s <= '0';
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSl_ExtVsyncDly2_s = '1' and PrSl_ExtVsyncDly3_s = '0') then
                if (PrSv_FilterCnt_s(19) = '1' and PrSv_FilterCnt_s(16) = '1') then
                    PrSl_FilterVsync_s <= '1';
                else
                    PrSl_FilterVsync_s <= '0';
                end if;
            else -- hold
            end if;
        end if;
    end process;
    
    -- External Vsync
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_ExtVsync_s <= '0';
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSl_FilterVsync_s = '1') then
                PrSl_ExtVsync_s <= PrSl_ExtVsyncDly3_s and (not PrSl_ExtVsyncDly4_s);
            else -- hold
            end if;
        end if;
    end process;

    -- Vsync control
    PrSl_VsyncCtrl_s <= PrSl_ExtVsync_s when CpSl_ExtVsyncInd_i = '1' else PrSl_IntVsync_s;

    -- Ext. Vsync valid counter
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_ExtVldCnt_s <= (others => '1');
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSl_ExtVsyncDly2_s = '1' and PrSl_ExtVsyncDly3_s = '0') then
                PrSv_ExtVldCnt_s <= (others => '0');
            elsif (PrSv_ExtVldCnt_s = x"FFFFFF") then
                PrSv_ExtVldCnt_s <= PrSv_ExtVldCnt_s;
            else
                PrSv_ExtVldCnt_s <= PrSv_ExtVldCnt_s + '1';
            end if;
        end if;
    end process;

    -- Output
    CpSl_ExtVsyncVld_o <= '1' when PrSv_ExtVldCnt_s /= x"FFFFFF" else '0';
    CpSl_VsyncCtrl_o   <= PrSl_VsyncCtrl_s  ;

end arch_M_CtrlInd;