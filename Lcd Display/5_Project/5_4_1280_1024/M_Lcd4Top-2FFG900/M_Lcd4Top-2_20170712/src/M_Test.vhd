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
-- 邮    件  :  wenjunzhang@bixing-tech.com
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
        --------------------------------
        -- Refresh Rate : 100Hz, 67Hz
        --------------------------------
        Refresh_Rate    : integer := 100    
    );
    port (
		--------------------------------
        -- Reset & Clock
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Rst, active low
        CpSl_Clk_i                      : in  std_logic;                        -- Clk, 80Mhz

        --------------------------------
        -- Refersh Rate Choice/LcdVsync
        -- VsyncTrtigCnt
        --------------------------------
        CpSl_LcdVsync_i                 : in  std_logic;                        -- Lcd Vsync 
        CpSl_DataVld_i                  : in  std_logic;                        -- 1s Data Valid
        CpSv_FreChoice_i                : in  std_logic_vector(2 downto 0);     -- Frequence Choice
        CpSv_VsyncTrig_i                : in  std_logic_vector(7 downto 0 );    -- VsyncTrig

        --------------------------------
        -- Pulse output
        --------------------------------
        CpSl_Vsync_o                    : out std_logic;                        -- Vsync Pulse
        CpSl_Test_o                     : out std_logic                         -- Test Pulse
    );
end M_Test;

architecture arch_M_Test of M_Test is
    ----------------------------------------------------------------------------
    -- constant declaration
	----------------------------------------------------------------------------
	-- Frequence Choice
    constant PrSv_Ref200Hz_c            : std_logic_vector( 2 downto 0) := "100";       -- 200Hz 
    constant PrSv_Ref100Hz_c            : std_logic_vector( 2 downto 0) := "010";       -- 100Hz
    constant PrSv_Ref67Hz_c             : std_logic_vector( 2 downto 0) := "001";       -- 67Hz

	-- Count
    constant PrSv_SingleCnt_c           : std_logic_vector(26 downto 0):= "100110001001011010000000000"; -- 80_000_000
    constant PrSv_DoubleCnt_c           : std_logic_vector(25 downto 0):= "10011000100101101000000000";  -- 40_000_000
	
    constant PrSv_50nsCnt_c             : std_logic_vector(23 downto 0) := x"0046AB";   -- 226150 ns Cnt
    constant PrSv_1usCnt_c              : std_logic_vector(23 downto 0) := x"0046BF";   -- 226400 ns Cnt
    constant PrSv_5msCnt_c              : std_logic_vector(23 downto 0) := x"0613A9";   -- 4978.125 us Cnt
    constant PrSv_7msCnt_c              : std_logic_vector(23 downto 0) := x"0914B4";   -- 7439.0625 us Cnt  
    constant Prsv_10Mscnt_C             : std_logic_vector(23 downto 0) := x"0C2753";   -- 9956.25 us Cnt
    constant PrSv_14msCnt_c             : std_logic_vector(23 downto 0) := x"122969";   -- 14878.125 us Cnt

    ----------------------------------------------------------------------------
    -- component declaration
	----------------------------------------------------------------------------
    -- Single Trig 
--    component M_SingDivider port (
--        rfd                             : out STD_LOGIC; 
--        clk                             : in  STD_LOGIC := 'X'; 
--        dividend                        : in  STD_LOGIC_VECTOR (26 downto 0); 
--        quotient                        : out STD_LOGIC_VECTOR (26 downto 0); 
--        divisor                         : in  STD_LOGIC_VECTOR ( 7 downto 0); 
--        fractional                      : out STD_LOGIC_VECTOR ( 7 downto 0) 
--    );
--    end component;

    -- Double Trig
    component M_DoubleDivider port (
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
    signal PrSl_Test_s                  : std_logic;                                    -- Generate Test Pulse
    signal PrSv_VsyncCnt_s              : std_logic_vector(23 downto 0);                -- Vsync Cnt
    signal PrSv_VsyncNum_s              : std_logic_vector(23 downto 0);                -- Vsync Num
    signal PrSv_TestCnt_s               : std_logic_vector(23 downto 0);                -- Test Cnt 
    signal PrSv_TestNum_s               : std_logic_vector(23 downto 0);                -- Test Num
    signal PrSl_50nsTrig_s              : std_logic;                                    -- 50ns Trig
    signal PrSl_Vsync50nsTrig_s         : std_logic;                                    -- Vsync 50ns Trig
    signal PrSl_1usTrig_s               : std_logic;                                    -- 1us Trig
    signal PrSl_Vsync1usTrig_s          : std_logic;                                    -- Vsync 1us Trig
    signal PrSv_FreChoiceDly1_s         : std_logic_vector( 2 downto 0);                -- Delay FreChoice 1 Clk
    signal PrSv_FreChoiceDly2_s         : std_logic_vector( 2 downto 0);                -- Delay FreChoice 2 Clk
    signal PrSl_LcdVsyncDly1_s          : std_logic;                                    -- Delay CpSl_LcdVsync_i 1 Clk
    signal PrSl_LcdVsyncDly2_s          : std_logic;                                    -- Delay CpSl_LcdVsync_i 2 Clk 
    signal PrSl_LcdVsyncDly3_s          : std_logic;                                    -- Delay CpSl_LcdVsync_i 3 Clk 
    signal PrSl_LcdVsyncTrig_s          : std_logic;                                    -- LcdVsync Rising Trig
    signal PrSv_VsyncState_s            : std_logic_vector( 1 downto 0);                -- LcdVsync State
    signal PrSv_SingleQut_s             : std_logic_vector(26 downto 0);                -- Single Qut
    signal PrSv_DoubleQut_s             : std_logic_vector(25 downto 0);                -- Double Qut
    
begin
    ----------------------------------------------------------------------------
    -- compoment map
    ----------------------------------------------------------------------------
    -- Single Trig 
--    U_M_SingDivider_0 : M_SingDivider port map (
--        rfd                             => open                                 , -- out std_logic;
--        clk                             => CpSl_Clk_i                           , -- in  std_logic;
--        dividend                        => PrSv_SingleCnt_c                     , -- in  std_logic_vector(26 downto 0);
--        quotient                        => PrSv_SingleQut_s                     , -- out std_logic_vector(26 downto 0);
--        divisor                         => CpSv_VsyncTrig_i                     , -- in  std_logic_vector( 7 downto 0);
--        fractional                      => open                                   -- out std_logic_vector( 7 downto 0);
--    );
    
    -- Double Trig 
    U_M_DoubleDivider_0 : M_DoubleDivider port map (
        rfd                             => open                                 , -- out std_logic;
        clk                             => CpSl_Clk_i                           , -- in  std_logic;
        dividend                        => PrSv_DoubleCnt_c                     , -- in  std_logic_vector(25 downto 0);
        quotient                        => PrSv_DoubleQut_s                     , -- out std_logic_vector(25 downto 0);
        divisor                         => CpSv_VsyncTrig_i                     , -- in  std_logic_vector( 7 downto 0);
        fractional                      => open                                   -- out std_logic_vector( 7 downto 0);
    );
    
    ----------------------------------------------------------------------------
    -- Main Area
    ----------------------------------------------------------------------------
    -- Delay CpSl_LcdVsync_i 3 Clk 
    process (CpSl_Rst_iN,CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_LcdVsyncDly1_s <= '0';
            PrSl_LcdVsyncDly2_s <= '0';
            PrSl_LcdVsyncDly3_s <= '0';
        elsif rising_edge(CpSl_Clk_i) then 
            PrSl_LcdVsyncDly1_s <= CpSl_LcdVsync_i;
            PrSl_LcdVsyncDly2_s <= PrSl_LcdVsyncDly1_s;
            PrSl_LcdVsyncDly3_s <= PrSl_LcdVsyncDly2_s;
        end if;
    end process; 
    
    -- Vsync Trig
    PrSl_LcdVsyncTrig_s <= '1' when (PrSl_LcdVsyncDly2_s = '1' and PrSl_LcdVsyncDly3_s = '0') else '0';
    
    -- Delay CpSl_FreChoice_i 2 Clk 
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
            PrSv_TestCnt_s  <= (others => '0');
            PrSv_VsyncCnt_s <= (others => '0');
        elsif rising_edge (CpSl_Clk_i) then 
            case PrSv_FreChoiceDly2_s is 
                when PrSv_Ref200Hz_c =>  -- 200Hz 
                    PrSv_TestCnt_s  <= PrSv_5msCnt_c;
                    PrSv_VsyncCnt_s <= PrSv_5msCnt_c;
                    
                when PrSv_Ref100Hz_c =>  -- 100Hz                     
                    PrSv_TestCnt_s  <= Prsv_10Mscnt_C;
                    PrSv_VsyncCnt_s <= PrSv_DoubleQut_s(23 downto 0);
                    
                when PrSv_Ref67Hz_c =>  -- 67Hz 
                    PrSv_TestCnt_s  <= Prsv_14Mscnt_C;
                    PrSv_VsyncCnt_s <= PrSv_DoubleQut_s(23 downto 0);
                
                when others => 
                    PrSv_TestCnt_s  <= (others => '0');
                    PrSv_VsyncCnt_s <= (others => '0');
                        
            end case;
        end if;
    end process;
    
    -- PrSv_VsyncState_s
    process (CpSl_Rst_iN,CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            PrSv_VsyncState_s <= "00";
        elsif rising_edge (CpSl_Clk_i) then
            case PrSv_VsyncState_s is 
                when  "00" => 
                    if (PrSl_LcdVsyncTrig_s = '1') then 
                        PrSv_VsyncState_s <= "01";
                    else
                        PrSv_VsyncState_s <= "00";
                    end if;
                        
                when "01" => 
                    if (PrSv_TestNum_s = PrSv_TestCnt_s - 1) then 
                        PrSv_VsyncState_s <= "00";
                    else -- hold
                    end if;
                        
                when others => 
                        PrSv_VsyncState_s <= "00";
            end case;
        end if;
    end process;
    
    -- Test Num
    process (CpSl_Rst_iN,CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then
            PrSv_TestNum_s <= (others => '0');
        elsif rising_edge (CpSl_Clk_i) then 
            if (PrSv_VsyncState_s = "01") then
                if (PrSv_TestNum_s = PrSv_TestCnt_s - 1) then 
                    PrSv_TestNum_s <= (others => '0');
                else
                    PrSv_TestNum_s <= PrSv_TestNum_s + '1';
                end if;
            else 
                PrSv_TestNum_s <= (others => '0');
            end if;
        end if;
    end process;
    
    -- Vsync Num
--    process (CpSl_Rst_iN,CpSl_Clk_i) begin 
--        if (CpSl_Rst_iN = '0') then 
--            PrSv_VsyncNum_s <= (others => '0');
--        elsif rising_edge (CpSl_Clk_i) then
--            if (PrSv_VsyncState_s = "01") then
--                if (PrSv_VsyncNum_s = PrSv_VsyncCnt_s - 1) then 
--                    PrSv_VsyncNum_s <= (others => '0');
--                else
--                    PrSv_VsyncNum_s <= PrSv_VsyncNum_s + '1';
--                end if;
--            else
--                PrSv_VsyncNum_s <= (others => '0');
--            end if;
--        end if;
--    end process;
    
    process (CpSl_Rst_iN,CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            PrSv_VsyncNum_s <= (others => '0');
        elsif rising_edge (CpSl_Clk_i) then
            if (PrSl_LcdVsyncTrig_s = '1') then 
                PrSv_VsyncNum_s <= (others => '0');
            elsif (PrSv_VsyncNum_s = PrSv_VsyncCnt_s - 1) then 
                PrSv_VsyncNum_s <= (others => '0');
            else
                PrSv_VsyncNum_s <= PrSv_VsyncNum_s + '1';
            end if;
        end if;
    end process;
    
    -- Test 50ns Trig
    process (CpSl_Rst_iN,CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            PrSl_50nsTrig_s <= '0';
        elsif rising_edge (CpSl_Clk_i) then
            if (PrSv_VsyncState_s = "01") then
                if (PrSv_TestNum_s = PrSv_50nsCnt_c) then
                    PrSl_50nsTrig_s <= '1';
                else
                    PrSl_50nsTrig_s <= '0';
                end if;
            else
                PrSl_50nsTrig_s <= '0';
            end if;
        end if;
    end process;
    
    -- Vsync 50ns Trig
    process (CpSl_Rst_iN,CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            PrSl_Vsync50nsTrig_s <= '0';
        elsif rising_edge (CpSl_Clk_i) then 
            if (PrSv_VsyncNum_s = PrSv_50nsCnt_c) then
                PrSl_Vsync50nsTrig_s <= '1';
            else
                PrSl_Vsync50nsTrig_s <= '0';
            end if;
        end if;
    end process;
    
    -- 1us Trig
    process (CpSl_Rst_iN,CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            PrSl_1usTrig_s <= '0';
        elsif rising_edge (CpSl_Clk_i) then 
            if (PrSv_VsyncState_s = "01") then
                if (PrSv_TestNum_s = PrSv_1usCnt_c) then
                    PrSl_1usTrig_s <= '1';
                else
                    PrSl_1usTrig_s <= '0';
                end if;
            else
                PrSl_1usTrig_s <= '0';
            end if;
        end if;
    end process;
    
    -- Vsync 1us Trig
    process (CpSl_Rst_iN,CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then 
            PrSl_Vsync1usTrig_s <= '0';
        elsif rising_edge (CpSl_Clk_i) then 
            if (PrSv_VsyncNum_s = PrSv_1usCnt_c) then
                PrSl_Vsync1usTrig_s <= '1';
            else
                PrSl_Vsync1usTrig_s <= '0';
            end if;
        end if;
    end process;
    
    -- Text Pulse
    process (CpSl_Rst_iN,CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            PrSl_Test_s <= '0';
        elsif rising_edge (CpSl_Clk_i) then
            if (PrSv_VsyncState_s = "01") then
                if (PrSl_50nsTrig_s = '1') then
                    PrSl_Test_s <= '1';
                elsif (PrSl_1usTrig_s = '1') then 
                    PrSl_Test_s <= '0';
                else --hold
                end if;
            else
                PrSl_Test_s <= '0';
            end if;
        end if;
    end process;
    -- GND
--    CpSl_Test_o <= '0';
    -- Generate Test Pulse
    CpSl_Test_o <= PrSl_Test_s;
    
    -- Vsync Pulse
    process (CpSl_Rst_iN,CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            CpSl_Vsync_o <= '0';
        elsif rising_edge (CpSl_Clk_i) then 
            if (PrSl_Vsync50nsTrig_s = '1') then
                CpSl_Vsync_o <= '1';
            elsif (PrSl_Vsync1usTrig_s = '1') then 
                CpSl_Vsync_o <= '0';
            else --hold
            end if;
        end if;
    end process;
    
end arch_M_Test;