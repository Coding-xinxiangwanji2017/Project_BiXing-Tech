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
-- 功能简述  :  100Hz/85Hz/75Hz/60Hz/50Hz
-- 版本序号  :  0.1
-- 修改历史  :  1. Initial, zhang wen jun, 2016/3/2
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity M_Test is
    generic (
        Simulation                      : integer := 1
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
        CpSl_LcdVsync_i                 : in  std_logic;                        -- Lcd Vsync 
        CpSv_FreChoice_i                : in  std_logic_vector(2 downto 0);     -- FreChoice
        CpSv_VsyncTrig_i                : in  std_logic_vector(7 downto 0 );    -- VsyncTrig
            
        --------------------------------
        -- Pulse output
        --------------------------------
        CpSl_Vsync_o                    : out std_logic                         -- Vsync
    );
end M_Test;

architecture arch_M_Test of M_Test is 
    ----------------------------------------------------------------------------
    --constant declaration
    ----------------------------------------------------------------------------
    -- FreChoice                                       
    constant PrSv_Ref100Hz_c            : std_logic_vector( 2 downto 0) := "100";      -- 100Hz
    constant PrSv_Ref85Hz_c             : std_logic_vector( 2 downto 0) := "010";      -- 85Hz
    constant PrSv_Ref75Hz_c             : std_logic_vector( 2 downto 0) := "001";      -- 75Hz
    constant PrSv_Ref60Hz_c             : std_logic_vector( 2 downto 0) := "110";      -- 60Hz
    constant PrSv_Ref50Hz_c             : std_logic_vector( 2 downto 0) := "101";      -- 50Hz
    
    -- Cnt
    constant PrSv_10usCnt_c             : std_logic_vector(19 downto 0):= x"003E7"; -- 10us Cnt
    constant PrSv_50usCnt_c             : std_logic_vector(19 downto 0):= x"01387"; -- 50us Cnt
    constant PrSv_90usCnt_c             : std_logic_vector(19 downto 0):= x"02327"; -- 90us Cnt

    constant PrSv_5msCnt_c              : std_logic_vector(19 downto 0):= x"8F9CA"; -- 5.88ms Cnt
    constant PrSv_6msCnt_c              : std_logic_vector(19 downto 0):= x"A2C29"; -- 6.66ms Cnt
    constant PrSv_8msCnt_c              : std_logic_vector(19 downto 0):= x"CB734"; -- 8.33ms Cnt
    constant PrSv_10msCnt_c             : std_logic_vector(19 downto 0):= x"F423F"; -- 10ms Cnt  
                                                                                               
    ----------------------------------------------------------------------------
    --signal declaration
    ----------------------------------------------------------------------------
    signal PrSl_50usTrig_s              : std_logic;                            -- 50us Trig
    signal PrSl_90usTrig_s              : std_logic;                            -- 90us Trig
    signal PrSv_Cnt_s                   : std_logic_vector(19 downto 0);        -- Cnt
    signal PrSv_TestCnt_s               : std_logic_vector(19 downto 0);        -- Generate Cnt
    signal PrSv_FreChoiceDly1_s         : std_logic_vector( 2 downto 0);        -- Delay CpSv_FreChoice_i 1 Clk
    signal PrSv_FreChoiceDly2_s         : std_logic_vector( 2 downto 0);        -- Delay CpSv_FreChoice_i 2 Clk

begin
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
                when PrSv_Ref100Hz_c =>  -- 100Hz 
                    PrSv_TestCnt_s <= PrSv_10msCnt_c;
                
                when PrSv_Ref85Hz_c =>  -- 85Hz 
                    PrSv_TestCnt_s <= PrSv_5msCnt_c;
                
                when PrSv_Ref75Hz_c =>  -- 75Hz 
                    PrSv_TestCnt_s <= PrSv_6msCnt_c;
                    
                when PrSv_Ref60Hz_c =>  -- 60Hz 
                    PrSv_TestCnt_s <= PrSv_8msCnt_c;
                
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
    
    Sim_Trig : if (Simulation = 0) generate  
    -- 10us Trig
    process (CpSl_Rst_iN,CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            PrSl_50usTrig_s <= '0';
        elsif rising_edge (CpSl_Clk_i) then 
            if (PrSv_Cnt_s = PrSv_10usCnt_c) then
                PrSl_50usTrig_s <= '1';
            else
                PrSl_50usTrig_s <= '0';
            end if;
        end if;
    end process;
    
    -- 50us Trig
    process (CpSl_Rst_iN,CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            PrSl_90usTrig_s <= '0';
        elsif rising_edge (CpSl_Clk_i) then 
            if (PrSv_Cnt_s = PrSv_50usCnt_c) then
                PrSl_90usTrig_s <= '1';
            else
                PrSl_90usTrig_s <= '0';
            end if;
        end if;
    end process;
    end generate Sim_Trig;
    
    Real_Trig : if (Simulation = 1) generate  
    -- 50us Trig
    process (CpSl_Rst_iN,CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            PrSl_50usTrig_s <= '0';
        elsif rising_edge (CpSl_Clk_i) then 
            if (PrSv_Cnt_s = PrSv_50usCnt_c) then
                PrSl_50usTrig_s <= '1';
            else
                PrSl_50usTrig_s <= '0';
            end if;
        end if;
    end process;
    
    -- 90us Trig
    process (CpSl_Rst_iN,CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            PrSl_90usTrig_s <= '0';
        elsif rising_edge (CpSl_Clk_i) then 
            if (PrSv_Cnt_s = PrSv_90usCnt_c) then
                PrSl_90usTrig_s <= '1';
            else
                PrSl_90usTrig_s <= '0';
            end if;
        end if;
    end process;
    end generate Real_Trig;
    
    -- Text Pulse
    process (CpSl_Rst_iN,CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            CpSl_Vsync_o <= '0';
        elsif rising_edge (CpSl_Clk_i) then 
            if (PrSl_50usTrig_s = '1') then
                CpSl_Vsync_o <= '1';
            elsif (PrSl_90usTrig_s = '1') then 
                CpSl_Vsync_o <= '0';
            else --hold
            end if;
        end if;
    end process;
    
end arch_M_Test;