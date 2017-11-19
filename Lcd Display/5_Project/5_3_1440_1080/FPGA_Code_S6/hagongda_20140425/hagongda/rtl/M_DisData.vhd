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
-- 文件名称  :  M_DisData.vhd
-- 设    计  :  LIU Hai 
-- 邮    件  :  zheng-jianfeng@139.com
-- 校    对  :  
-- 设计日期  :  2014/03/25
-- 功能简述  :  LCD display data generator
-- 版本序号  :  0.1
-- 修改历史  :  1. Initial, LIU Hai, 2014/03/25
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity M_DisData is
    port (
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      : in  std_logic;                        -- Clock

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
end M_DisData;

architecture arch_M_DisData of M_DisData is
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
    signal PrSl_DisDvld_s               : std_logic;
    signal PrSv_DataCnt_s               : std_logic_vector( 7 downto 0);
    signal PrSl_Vsync_s                 : std_logic;
    signal PrSv_FrameCnt_s              : std_logic_vector( 7 downto 0);

begin
    ----------------------------------------------------------------------------
    -- 
    ----------------------------------------------------------------------------
    -- H counter
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_HCnt_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSv_HCnt_s = 532) then
                PrSv_HCnt_s <= (others => '0');
            else
                PrSv_HCnt_s <= PrSv_HCnt_s + '1';
            end if;
        end if;
    end process;

    -- V counter
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_VCnt_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSv_HCnt_s = 532) then
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
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            CpSl_Hsync_o <= '0';
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSv_HCnt_s = 0) then
                CpSl_Hsync_o <= '1';
            else
                CpSl_Hsync_o <= '0';
            end if;
        end if;
    end process;

    -- V Sync
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_Vsync_s <= '0';
        elsif rising_edge(CpSl_Clk_i) then
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

    --
    CpSl_Vsync_o <= PrSl_Vsync_s;

    ----------------------------------------------------------------------------
    -- 
    ----------------------------------------------------------------------------
    -- Display data valid
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_FrameCnt_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSl_Vsync_s = '1') then
                if (PrSv_FrameCnt_s = 199) then
                    PrSv_FrameCnt_s <= (others => '0');
                else
                    PrSv_FrameCnt_s <= PrSv_FrameCnt_s + '1';
                end if;
            else -- hold
            end if;
        end if;
    end process;

    -- Display data valid
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_DisDvld_s <= '0';
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSv_HCnt_s = 107) then
                PrSl_DisDvld_s <= '1';
            elsif (PrSv_HCnt_s = 467) then
                PrSl_DisDvld_s <= '0';
            else -- hold
            end if;
        end if;
    end process;

    -- Data counter
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_DataCnt_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSl_DisDvld_s = '1') then
                PrSv_DataCnt_s <= PrSv_DataCnt_s + '1';
            else
                PrSv_DataCnt_s <= (others => '0');
            end if;
        end if;
    end process;
    
    -- Red color
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            CpSv_Red0_o <= (others => '0');
            CpSv_Red1_o <= (others => '0');
            CpSv_Red2_o <= (others => '0');
            CpSv_Red3_o <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSv_FrameCnt_s(0) = '1') then
                CpSv_Red0_o <= (others => '0');
                CpSv_Red1_o <= (others => '0');
                CpSv_Red2_o <= (others => '0');
                CpSv_Red3_o <= (others => '0');
            else
                CpSv_Red0_o <= (others => '1');
                CpSv_Red1_o <= (others => '1');
                CpSv_Red2_o <= (others => '1');
                CpSv_Red3_o <= (others => '1');
--                if (PrSv_VCnt_s  =  47  or PrSv_VCnt_s  =   1) then
--                    CpSv_Red0_o <= (others => '1');
--                    CpSv_Red1_o <= (others => '1');
--                    CpSv_Red2_o <= (others => '1');
--                    CpSv_Red3_o <= (others => '1');
--                else
--                    if (PrSv_HCnt_s  = 108  or PrSv_HCnt_s  = 467) then
--                        CpSv_Red0_o <= (others => '1');
--                        CpSv_Red1_o <= (others => '1');
--                        CpSv_Red2_o <= (others => '1');
--                        CpSv_Red3_o <= (others => '1');
--                    elsif (PrSv_HCnt_s >= 108 and PrSv_HCnt_s <= 467) then
--                        CpSv_Red0_o <= PrSv_DataCnt_s & x"0";
--                        CpSv_Red1_o <= PrSv_DataCnt_s & x"0";
--                        CpSv_Red2_o <= PrSv_DataCnt_s & x"0";
--                        CpSv_Red3_o <= PrSv_DataCnt_s & x"0";
--                    else
--                        CpSv_Red0_o <= (others => '0');
--                        CpSv_Red1_o <= (others => '0');
--                        CpSv_Red2_o <= (others => '0');
--                        CpSv_Red3_o <= (others => '0');
--                    end if;
--                end if;
            end if;
        end if;
    end process;

end arch_M_DisData;