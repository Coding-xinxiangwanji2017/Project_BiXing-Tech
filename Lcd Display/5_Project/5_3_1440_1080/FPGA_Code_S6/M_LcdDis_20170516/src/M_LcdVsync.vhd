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
-- 文件名称  :  M_LcdVsync.vhd
-- 设    计  :  Zhang wen jun
-- 邮    件  :  wenjunzhang@bixing-tech.com
-- 校    对  :
-- 设计日期  :  2016/03/02
-- 功能简述  :  Generate Lcd Vsync, 100Hz/85Hz/60Hz/50Hz
-- 版本序号  :  0.1
-- 修改历史  :  1. Initial, zhang wen jun, 2016/03/02
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

entity M_LcdVsync is
    generic (
        Simulation                      : string := "FALSE"
    );
    port (
        --------------------------------
        -- Rst & Clk
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Rst, active low
        CpSl_Clk_i                      : in  std_logic;                        -- Clk, 100Mhz signal

        --------------------------------
        -- Refersh Rate Choice
        --------------------------------
        CpSv_FreChoice_i                : in std_logic_vector(2 downto 0);      -- Frequence Choice
        CpSv_VsyncTrigCnt_i             : in std_logic_vector(7 downto 0);      -- Vsync Count

        --------------------------------
        -- Lcd Vsync
        --------------------------------
        CpSl_LcdVsync_o                 : out std_logic                         -- Lcd Vsync
    );
end M_LcdVsync;

architecture arch_M_LcdVsync of M_LcdVsync is
    ----------------------------------------------------------------------------
    --constant declaration
    ----------------------------------------------------------------------------
    ------------------------------------
    -- Frequence Choice
    -- 1440_1080
    ------------------------------------
    constant PrSv_Ext100Hz_c            : std_logic_vector( 2 downto 0) := "110"; -- Ext 100Hz
    constant PrSv_Ext50Hz_c             : std_logic_vector( 2 downto 0) := "101"; -- Ext 50Hz
    constant PrSv_Ref100Hz_c            : std_logic_vector( 2 downto 0) := "100"; -- Int 100Hz
    constant PrSv_Ref85Hz_c             : std_logic_vector( 2 downto 0) := "011"; -- Int 85Hz
    constant PrSv_Ref60Hz_c             : std_logic_vector( 2 downto 0) := "010"; -- Int 60Hz
    constant PrSv_Ref50Hz_c             : std_logic_vector( 2 downto 0) := "001"; -- Int 50Hz

    ------------------------------------
    -- Count
    ------------------------------------
    constant PrSv_Ext100HzCnt_c         : std_logic_vector(26 downto 0):= "101111101011110000100000000"; --100000000
    constant PrSv_Ext50HzCnt_c          : std_logic_vector(25 downto 0):= "10111110101111000010000000";  --50000000

    constant PrSv_1msCnt_c              : std_logic_vector(19 downto 0):= x"00004"; -- 4
    constant PrSv_2msCnt_c              : std_logic_vector(19 downto 0):= x"0001D"; -- 29
    constant PrSv_100usCnt_c            : std_logic_vector(19 downto 0):= x"0270F"; -- 9999

    constant PrSv_10msCnt_c             : std_logic_vector(19 downto 0):= x"F423F"; -- 999999
    constant PrSv_11msCnt_c             : std_logic_vector(19 downto 0):= x"8F9CA"; -- 588234
    constant PrSv_16msCnt_c             : std_logic_vector(19 downto 0):= x"CB734"; -- 833332
    constant PrSv_20msCnt_c             : std_logic_vector(19 downto 0):= x"F423F"; -- 999999

    ----------------------------------------------------------------------------
    -- compoment declaration
    ----------------------------------------------------------------------------
    -- Ext 100Hz  
    component M_100HzDivider port (
        rfd                             : out STD_LOGIC; 
        clk                             : in  STD_LOGIC := 'X'; 
        dividend                        : in  STD_LOGIC_VECTOR (26 downto 0); 
        quotient                        : out STD_LOGIC_VECTOR (26 downto 0); 
        divisor                         : in  STD_LOGIC_VECTOR ( 7 downto 0); 
        fractional                      : out STD_LOGIC_VECTOR ( 7 downto 0) 
    );
    end component;

    -- Ext 50Hz
    component M_50HzDivider port (
        rfd                             : out STD_LOGIC; 
        clk                             : in  STD_LOGIC := 'X'; 
        dividend                        : in  STD_LOGIC_VECTOR (25 downto 0); 
        quotient                        : out STD_LOGIC_VECTOR (25 downto 0); 
        divisor                         : in  STD_LOGIC_VECTOR ( 7 downto 0); 
        fractional                      : out STD_LOGIC_VECTOR ( 7 downto 0) 
    );
    end component;

    ----------------------------------------------------------------------------
    -- signal declaration
    ----------------------------------------------------------------------------
    -- Count
    signal PrSl_1msTrig_s               : std_logic;                            -- 1ms Trig
    signal PrSl_2msTrig_s               : std_logic;                            -- 2ms Trig
    signal PrSv_Cnt_s                   : std_logic_vector(19 downto 0);        -- Count
    signal PrSv_TestCnt_s               : std_logic_vector(19 downto 0);        -- Generate Cnt
    signal PrSv_FreChoiceDly1_s         : std_logic_vector( 2 downto 0);        -- Delay CpSv_FreChoice_i 1 Clk
    signal PrSv_FreChoiceDly2_s         : std_logic_vector( 2 downto 0);        -- Delay CpSv_FreChoice_i 2 Clk
        
    -- Ext 100Hz/50Hz Divider
    signal PrSv_Ext100HzDiv_s           : std_logic_vector( 7 downto 0);        -- Ext 100Hz Divider
    signal PrSv_Ext100HzQut_s           : std_logic_vector(26 downto 0);        -- Ext 100Hz Quotient
    signal PrSv_Ext50HzDiv_s            : std_logic_vector( 7 downto 0);        -- Ext 50Hz Divider  
    signal PrSv_Ext50HzQut_s            : std_logic_vector(25 downto 0);        -- Ext 50Hz Quotient 

begin
    ----------------------------------------------------------------------------
    -- compoment map
    ----------------------------------------------------------------------------
    -- Ext 100Hz
    U_M_100HzDivider_0 : M_100HzDivider port map (
        rfd                             => open                                 , -- out std_logic;
        clk                             => CpSl_Clk_i                           , -- in  std_logic;
        dividend                        => PrSv_Ext100HzCnt_c                   , -- in  std_logic_vector(26 downto 0);
        quotient                        => PrSv_Ext100HzQut_s                   , -- out std_logic_vector(26 downto 0);
        divisor                         => PrSv_Ext100HzDiv_s                   , -- in  std_logic_vector( 7 downto 0);
        fractional                      => open                                   -- out std_logic_vector( 7 downto 0);
    );
    
    -- Ext 50Hz
    U_M_50HzDivider_0 : M_50HzDivider port map (
        rfd                             => open                                 , -- out std_logic;
        clk                             => CpSl_Clk_i                           , -- in  std_logic;
        dividend                        => PrSv_Ext50HzCnt_c                    , -- in  std_logic_vector(25 downto 0);
        quotient                        => PrSv_Ext50HzQut_s                    , -- out std_logic_vector(25 downto 0);
        divisor                         => PrSv_Ext50HzDiv_s                    , -- in  std_logic_vector( 7 downto 0);
        fractional                      => open                                   -- out std_logic_vector( 7 downto 0);
    );
    
    
    -- Delay PrSv_Refresh_Rate_s
    process (CpSl_Rst_iN,CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_FreChoiceDly1_s <= (others => '0');
            PrSv_FreChoiceDly2_s <= (others => '0');

        elsif rising_edge (CpSl_Clk_i) then
            PrSv_FreChoiceDly1_s <= CpSv_FreChoice_i;
            PrSv_FreChoiceDly2_s <= PrSv_FreChoiceDly1_s;

        end if;
    end process;

    -- Choice Frequence
    process (CpSl_Rst_iN,CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_TestCnt_s <= (others => '0');
        elsif rising_edge (CpSl_Clk_i) then
            case PrSv_FreChoiceDly2_s is
                when PrSv_Ext100Hz_c =>
                    PrSv_Ext100HzDiv_s <= CpSv_VsyncTrigCnt_i;
                    PrSv_TestCnt_s <= PrSv_Ext100HzQut_s(19 downto 0); 

                when PrSv_Ext50Hz_c =>
                    PrSv_Ext50HzDiv_s <= CpSv_VsyncTrigCnt_i;
                    PrSv_TestCnt_s <= PrSv_Ext50HzQut_s(19 downto 0);  

                when PrSv_Ref100Hz_c =>  -- 100Hz
                    PrSv_TestCnt_s <= PrSv_10msCnt_c;

                when PrSv_Ref85Hz_c =>  -- 85Hz
                    PrSv_TestCnt_s <= PrSv_10msCnt_c;

                when PrSv_Ref60Hz_c =>  -- 60Hz
                    PrSv_TestCnt_s <= PrSv_10msCnt_c;

                when PrSv_Ref50Hz_c =>  -- 50Hz
                    PrSv_TestCnt_s <= PrSv_10msCnt_c;

                when others =>
                    PrSv_TestCnt_s <= (others => '0');

            end case;
        end if;
    end process;

    --Cnt
    process (CpSl_Rst_iN,CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_Cnt_s <= (others => '0');
        elsif rising_edge (CpSl_Clk_i) then
            if (PrSv_Cnt_s = PrSv_TestCnt_s) then
                PrSv_Cnt_s <= (others => '0');
            else
                PrSv_Cnt_s <= PrSv_Cnt_s + '1';
            end if;
        end if;
    end process;

    -- 1ms Trig
    process (CpSl_Rst_iN,CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_1msTrig_s <= '0';
        elsif rising_edge (CpSl_Clk_i) then
            if (PrSv_Cnt_s = PrSv_1msCnt_c) then
                PrSl_1msTrig_s <= '1';
            else
                PrSl_1msTrig_s <= '0';
            end if;
        end if;
    end process;

    -- 2ms Trig
    process (CpSl_Rst_iN,CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_2msTrig_s <= '0';
        elsif rising_edge (CpSl_Clk_i) then
            if (PrSv_Cnt_s = PrSv_2msCnt_c) then
                PrSl_2msTrig_s <= '1';
            else
                PrSl_2msTrig_s <= '0';
            end if;
        end if;
    end process;

    -- Text Pulse
    process (CpSl_Rst_iN,CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            CpSl_LcdVsync_o <= '0';
        elsif rising_edge (CpSl_Clk_i) then
            if (PrSl_1msTrig_s = '1') then
                CpSl_LcdVsync_o <= '1';
            elsif (PrSl_2msTrig_s = '1') then
                CpSl_LcdVsync_o <= '0';
            else --hold
            end if;
        end if;
    end process;

end arch_M_LcdVsync;