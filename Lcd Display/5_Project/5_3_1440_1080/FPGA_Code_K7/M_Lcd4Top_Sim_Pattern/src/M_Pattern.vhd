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
-- 文件名称  :  M_Pattern.vhd
-- 设    计  :  zhang wenjun 
-- 邮    件  :  wenjunzhang@bixing-tech.com
-- 校    对  :  
-- 设计日期  :  2016/11/30
-- 功能简述  :  LCD pattern
-- 版本序号  :  0.1
-- 修改历史  :  1. Initial, zhang wenjun, 2016/11/30
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity M_Pattern is
    port (
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      : in  std_logic;                        -- Clock,90MHz

        --------------------------------
        -- Output signals
        --------------------------------
        CpSl_Hsync_o                    : out std_logic;                        -- Hsync
        CpSl_Vsync_o                    : out std_logic;                        -- Vsync
        CpSv_Red0_o                     : out std_logic_vector(11 downto 0);    -- Red0
        CpSv_Red1_o                     : out std_logic_vector(11 downto 0);    -- Red1
        CpSv_Red2_o                     : out std_logic_vector(11 downto 0);    -- Red2
        CpSv_Red3_o                     : out std_logic_vector(11 downto 0);    -- Red3
        CpSv_Green0_o                   : out std_logic_vector(11 downto 0);    -- Green0 
        CpSv_Green1_o                   : out std_logic_vector(11 downto 0);    -- Green1 
        CpSv_Green2_o                   : out std_logic_vector(11 downto 0);    -- Green2 
        CpSv_Green3_o                   : out std_logic_vector(11 downto 0)     -- Green3 
    );
end M_Pattern;

architecture arch_M_Pattern of M_Pattern is
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
            if (PrSv_VCnt_s = 0) then
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

    -- Vsync
    CpSl_Vsync_o <= PrSl_Vsync_s;

    ----------------------------------------------------------------------------
    -- Display data
    ----------------------------------------------------------------------------
    -- Display data valid
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_FrameCnt_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSl_Vsync_s = '1') then
                if (PrSv_FrameCnt_s = 74) then
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
            if (PrSv_HCnt_s = 110) then
                PrSl_DisDvld_s <= '1';
            elsif (PrSv_HCnt_s = 470) then
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
            if (PrSv_FrameCnt_s(1) = '1') then
                CpSv_Red0_o <= (others => '0');
                CpSv_Red1_o <= (others => '0');
                CpSv_Red2_o <= (others => '0');
                CpSv_Red3_o <= (others => '0');
            else
                CpSv_Red0_o <= (others => '1');
                CpSv_Red1_o <= (others => '1');
                CpSv_Red2_o <= (others => '1');
                CpSv_Red3_o <= (others => '1');
--                if (PrSv_VCnt_s  =  36  or PrSv_VCnt_s  = 1116) then
--                    CpSv_Red0_o <= (others => '1');
--                    CpSv_Red1_o <= (others => '1');
--                    CpSv_Red2_o <= (others => '1');
--                    CpSv_Red3_o <= (others => '1');
--                else
--                    if (PrSv_HCnt_s  = 49 or PrSv_HCnt_s  = 529) then
--                        CpSv_Red0_o <= (others => '1');
--                        CpSv_Red1_o <= (others => '1');
--                        CpSv_Red2_o <= (others => '1');
--                        CpSv_Red3_o <= (others => '1');
--                    elsif (PrSv_HCnt_s >= 49 and PrSv_HCnt_s <= 529) then
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
    
    -- Green color
    process (CpSl_Rst_iN, CpSl_Clk_i) begin    
        if (CpSl_Rst_iN = '0') then 
            CpSv_Green0_o <= (others => '0');
            CpSv_Green1_o <= (others => '0');
            CpSv_Green2_o <= (others => '0');
            CpSv_Green3_o <= (others => '0');

        elsif rising_edge(CpSl_Clk_i) then
            if (PrSv_FrameCnt_s(1) = '1') then
                CpSv_Green0_o <= (others => '0');
                CpSv_Green1_o <= (others => '0');
                CpSv_Green2_o <= (others => '0');
                CpSv_Green3_o <= (others => '0');
            else
                CpSv_Green0_o <= (others => '1');
                CpSv_Green1_o <= (others => '1');
                CpSv_Green2_o <= (others => '1');
                CpSv_Green3_o <= (others => '1');
--            if (PrSv_VCnt_s = 36 or PrSv_VCnt_s = 1116) then 
--                CpSv_Green0_o <= (others => '1');     
--                CpSv_Green1_o <= (others => '1');     
--                CpSv_Green2_o <= (others => '1');     
--                CpSv_Green3_o <= (others => '1');   
--            elsif (PrSv_HCnt_s = 49 or PrSv_HCnt_s = 529) then 
--                CpSv_Green0_o <= (others => '1');     
--                CpSv_Green1_o <= (others => '1');     
--                CpSv_Green2_o <= (others => '1');     
--                CpSv_Green3_o <= (others => '1');
--            elsif (PrSv_HCnt_s > 49 and PrSv_HCnt_s < 289
--                    and PrSv_VCnt_s > 36 and PrSv_VCnt_s < 576) then 
--                CpSv_Green0_o <= (others => '1');     
--                CpSv_Green1_o <= (others => '1');     
--                CpSv_Green2_o <= (others => '1');     
--                CpSv_Green3_o <= (others => '1');
--             elsif (PrSv_HCnt_s > 49 and PrSv_HCnt_s < 289
--                    and PrSv_VCnt_s > 576 and PrSv_VCnt_s < 1116) then 
--                CpSv_Green0_o <= (others => '0');     
--                CpSv_Green1_o <= (others => '0');     
--                CpSv_Green2_o <= (others => '0');     
--                CpSv_Green3_o <= (others => '0');
--            elsif (PrSv_HCnt_s > 289 and PrSv_HCnt_s < 529
--                    and PrSv_VCnt_s > 36 and PrSv_VCnt_s < 576) then 
--                CpSv_Green0_o <= (others => '0');     
--                CpSv_Green1_o <= (others => '0');     
--                CpSv_Green2_o <= (others => '0');     
--                CpSv_Green3_o <= (others => '0');
--            elsif (PrSv_HCnt_s > 289 and PrSv_HCnt_s < 529
--                    and PrSv_VCnt_s > 576 and PrSv_VCnt_s < 1116) then 
--                CpSv_Green0_o <= (others => '1');     
--                CpSv_Green1_o <= (others => '1');     
--                CpSv_Green2_o <= (others => '1');     
--                CpSv_Green3_o <= (others => '1');
--            else
--                CpSv_Green0_o <= (others => '0');
--                CpSv_Green1_o <= (others => '0');
--                CpSv_Green2_o <= (others => '0');
--                CpSv_Green3_o <= (others => '0');
--            end if;
            end if;
        end if; 
    end process;  

end arch_M_Pattern;