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
-- 文件名称  :  M_Test.vhd
-- 设    计  :  zhang wen jun
-- 邮    件  :
-- 校    对  :
-- 设计日期  :  2016/3/2
-- 功能简述  :
-- 版本序号  :  0.1
-- 修改历史  :  1. Initial, zhang wen jun, 2016/3/2
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity M_Test is
    generic (
    ------------------------------------
    -- Referesh_Rate
    -- 200hz 100hz 60hz 50hz
    ------------------------------------
        Referesh_Rate                   : integer := 200
    );
    port (
        --------------------------------
        --Rst & Clk
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Rst, active low
        CpSl_Clk_i                      : in  std_logic;                        -- Clk, 80Mhz

        -- test signal
        CpSl_Test_o                     : out std_logic                         -- Test Pulse
    );
end M_Test;

architecture arch_M_Test of M_Test is
    ----------------------------------------------------------------------------
    --constant declaration
	----------------------------------------------------------------------------
    constant PrSv_1msCnt_c              : std_logic_vector(23 downto 0):= x"013880"; -- 1ms Cnt
    constant PrSv_2msCnt_c              : std_logic_vector(23 downto 0):= x"027100"; -- 2ms Cnt
    constant PrSv_5msCnt_c              : std_logic_vector(23 downto 0):= x"061A80"; -- 5ms Cnt
    constant PrSv_10msCnt_c             : std_logic_vector(23 downto 0):= x"0C3500"; -- 10ms Cnt
    constant PrSv_16msCnt_c             : std_logic_vector(23 downto 0):= x"145833"; -- 16.67ms Cnt
    constant PrSv_20msCnt_c             : std_logic_vector(23 downto 0):= x"186A00"; -- 20ms Cnt

    ----------------------------------------------------------------------------
    --signal declaration
    ----------------------------------------------------------------------------
    signal PrSv_5msCnt_s                : std_logic_vector(23 downto 0);                   -- Cnt 5msC
    signal PrSv_10msCnt_s               : std_logic_vector(23 downto 0);                   -- Cnt 10ms
    signal PrSv_16msCnt_s               : std_logic_vector(23 downto 0);                   -- Cnt 16ms
    signal PrSv_20msCnt_s               : std_logic_vector(23 downto 0);                   -- Cnt 20ms
    signal PrSv_Cnt_s                   : std_logic_vector(23 downto 0);                   -- Cnt 5msC
    signal PrSv_TextCnt_s               : std_logic_vector(23 downto 0);                   -- Cnt for Test Pluse
    signal PrSl_Trig1ms_s               : std_logic;
    signal PrSl_Trig2ms_s               : std_logic;

begin
    -- generate refresh Cnt
    -- 200Hz
    generate_200Hz_refresh : if (Referesh_Rate = 200) generate
        PrSv_TextCnt_s <= PrSv_5msCnt_s;
    end generate generate_200Hz_refresh;
    
    -- 100Hz
    generate_100Hz_refresh : if (Referesh_Rate = 200) generate
        PrSv_TextCnt_s <= PrSv_10msCnt_s;
    end generate generate_100Hz_refresh;

     -- 60Hz
    generate_60Hz_refresh : if (Referesh_Rate = 200) generate
        PrSv_TextCnt_s <= PrSv_16msCnt_s;
    end generate generate_60Hz_refresh;
    
     -- 50Hz
    generate_50Hz_refresh : if (Referesh_Rate = 200) generate
        PrSv_TextCnt_s <= PrSv_20msCnt_s;
    end generate generate_50Hz_refresh;

    --Refresh Cnt
    process (CpSl_Rst_iN,CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_Cnt_s <= (others => '0');
        elsif rising_edge (CpSl_Clk_i) then
            if (PrSv_Cnt_s = PrSv_TextCnt_s) then
                PrSv_Cnt_s <= (others => '0');
            else
                PrSv_Cnt_s <= PrSv_Cnt_s + '1';
            end if;
        end if;
    end process;


    -- 1ms Trig
    process (CpSl_Rst_iN,CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_Trig1ms_s <= '0';
        elsif rising_edge (CpSl_Clk_i) then
            if (PrSv_Cnt_s = PrSv_1msCnt_c) then
                PrSl_Trig1ms_s <= '1';
            else
                PrSl_Trig1ms_s <= '0';
            end if;
        end if;
    end process;

     -- 2ms Trig
    process (CpSl_Rst_iN,CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_Trig2ms_s <= '0';
        elsif rising_edge (CpSl_Clk_i) then
            if (PrSv_Cnt_s = PrSv_2msCnt_c) then
                PrSl_Trig2ms_s <= '1';
            else
                PrSl_Trig2ms_s <= '0';
            end if;
        end if;
    end process;


    -- 1ms high
    process (CpSl_Rst_iN,CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            CpSl_Test_o <= '0';
        elsif rising_edge (CpSl_Clk_i) then
            if (PrSl_Trig1ms_s = '1') then
                CpSl_Test_o <= '1';
            elsif (PrSl_Trig2ms_s = '1')
                CpSl_Test_o <= '0';
            end if;
        end if;
    end process;

end arch_M_Test;