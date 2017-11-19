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
-- 文件名称  :  M_DviSim.vhd
-- 设    计  :  LIU Hai
-- 邮    件  :  zheng-jianfeng@139.com
-- 校    对  :  
-- 设计日期  :  2014/04/09
-- 功能简述  :  DVI simulation
-- 版本序号  :  0.1
-- 修改历史  :  1. Initial, LIU Hai, 2014/04/09
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity M_DviSim is
    port (
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
end M_DviSim;

architecture arch_M_DviSim of M_DviSim is
    ----------------------------------------------------------------------------
    -- constant declaration
    ----------------------------------------------------------------------------

    ----------------------------------------------------------------------------
    -- component declaration
    ----------------------------------------------------------------------------

    ----------------------------------------------------------------------------
    -- signal declaration
    ----------------------------------------------------------------------------
    signal PrSv_HCnt_s                  : std_logic_vector(10 downto 0);
    signal PrSv_VCnt_s                  : std_logic_vector(10 downto 0);
    signal PrSl_DviHsync_s              : std_logic;
    signal PrSl_DviVsync_s              : std_logic;
    signal PrSl_DviDe_s                 : std_logic;

begin
    ----------------------------------------------------------------------------
    -- 
    ----------------------------------------------------------------------------
    -- H counter
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_HCnt_s <= "10111000111"; -- 1479
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSv_HCnt_s = 1479) then
                PrSv_HCnt_s <= (others => '0');
            else
                PrSv_HCnt_s <= PrSv_HCnt_s + '1';
            end if;
        end if;
    end process;

    -- V counter
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_VCnt_s <= "10001001011"; -- 1099
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSv_HCnt_s = 1479) then
                if (PrSv_VCnt_s = 1099) then
                    PrSv_VCnt_s <= (others => '0');
                else
                    PrSv_VCnt_s <= PrSv_VCnt_s + '1';
                end if;
            else -- hold
            end if;
        end if;
    end process;

    -- 
    PrSl_DviVsync_s <= '1' when  (PrSv_VCnt_s >=  1 and PrSv_VCnt_s <=    5) else '0';
    PrSl_DviHsync_s <= '1' when  (PrSv_HCnt_s >=  2 and PrSv_HCnt_s <=   11) else '0';
    PrSl_DviDe_s    <= '1' when ((PrSv_HCnt_s >= 20 and PrSv_HCnt_s <= 1459) and
                                 (PrSv_VCnt_s >= 17 and PrSv_VCnt_s <= 1096)) else '0';

    -- 
    CpSl_DviClk_o   <= CpSl_Clk_i      ;
    CpSl_DviVsync_o <= PrSl_DviVsync_s ;
    CpSl_DviHsync_o <= PrSl_DviHsync_s ;
    CpSl_DviDe_o    <= PrSl_DviDe_s    ;

    process (all) begin
        if (PrSl_DviDe_s = '1') then
            if (PrSv_HCnt_s =  20 or PrSv_HCnt_s = 1459) then
                CpSv_DviR_o <= x"AA";
            else
                CpSv_DviR_o <= x"55";
            end if;
        else
            CpSv_DviR_o <= (others => '0');
        end if;
    end process;

end arch_M_DviSim;