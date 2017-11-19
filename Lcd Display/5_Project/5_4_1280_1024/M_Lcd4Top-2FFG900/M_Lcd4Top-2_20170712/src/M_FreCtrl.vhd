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
-- 文件名称  :  M_FreCtrl.vhd
-- 设    计  :  Zhang Wenjun
-- 邮    件  :  wenjunzhang@bixing-tech.com
-- 校    对  :
-- 设计日期  :  2016/3/2
-- 功能简述  :  Choice Refresh Rate
-- 版本序号  :  0.1
-- 修改历史  :  1. Initial, Zhang Wenjun, 2016/3/2
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity M_FreCtrl is
    port (
        --------------------------------
        --Rst & Clk
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                       -- Reset active low
        CpSl_Clk_i                      : in  std_logic;                       -- Clock 80Mhz,single

        --------------------------------
        --Dvi
        --------------------------------
        CpSl_Dvi0Scdt_i                 : in  std_logic;                        -- Dvi0 Scdt
        CpSl_Dvi1Scdt_i                 : in  std_logic;                        -- Dvi1 Scdt
        CpSl_DviVsync_i                 : in  std_logic;                        -- Int/Ext Vsync
                 
        --------------------------------
        --Frequence Choice & Led(3 downto 0)
        --------------------------------
        CpSl_DataVld_o                  : out std_logic;                        -- 1s Valid Data
        CpSv_VsyncTrig_o                : out std_logic_vector( 7 downto 0);    -- Vsync Trig Cnt
        CpSl_ClkSel_o                   : out std_logic;                        -- Selcet Clock 
        CpSv_FreChoice_o                : out std_logic_vector( 2 downto 0);    -- Choice frequence
        CpSv_FreLed_o                   : out std_logic_vector( 3 downto 0)     -- led

        --------------------------------
        -- ChipScope
        --------------------------------
--        CpSv_ChipCtrl3_io               : inout std_logic_vector(35 downto 0)   -- ChipScope control3   
    );
end M_FreCtrl;

architecture arch_M_FreCtrl of M_FreCtrl is
    ----------------------------------------------------------------------------
    --constant declaration
	----------------------------------------------------------------------------
    constant PrSv_2Cnt_c                : std_logic_vector(27 downto 0) := x"0000002";  -- 2
    constant PrSv_FslCnt_c              : std_logic_vector(27 downto 0) := x"4C4B3FD";  -- 79_999_997
    constant PrSv_1sCnt_c               : std_logic_vector(27 downto 0) := x"4C4B3FF";  -- 79_999_999
	
    constant PrSv_Ref200Hz_c            : std_logic_vector( 2 downto 0) := "100";       -- 200Hz 
    constant PrSv_Ref100Hz_c            : std_logic_vector( 2 downto 0) := "010";       -- 100Hz
    constant PrSv_Ref67Hz_c             : std_logic_vector( 2 downto 0) := "001";       -- 67Hz
    
    ------------------------------------
    -- Component declaration
    ------------------------------------
--    component M_ila port (
--        control                         : inout std_logic_vector(35 downto 0);
--        clk                             : in    std_logic;
--        trig0                           : in    std_logic_vector(63 downto 0)
--    );
--    end component;

	----------------------------------------------------------------------------
    --signal declaration
    ----------------------------------------------------------------------------
    signal PrSv_1HzCnt_s                : std_logic_vector(27 downto 0);        -- x"4C4B3FF" is 79,999,999
    signal PrSv_VsyncTrigCnt_s          : std_logic_vector( 7 downto 0);        -- Vsync Trig Cnt
    signal PrSl_VsyncTrig_s             : std_logic;                            -- Vsync Trig  
    signal PrSl_RisFlage_s              : std_logic;                            -- Rising flage 1s
    signal PrSl_FalFlage_s              : std_logic;                            -- Falling flage 1s
    signal PrSv_StateVld_s              : std_logic_vector(1 downto 0);         -- Scde1 Scdt0
    signal PrSl_VsyncDly1_s             : std_logic;                            -- Dly 1 Clk
    signal PrSl_VsyncDly2_s             : std_logic;                            -- Dly 2 Clk
    signal PrSl_VsyncDly3_s             : std_logic;                            -- Dly 3 Clk
    signal PrSv_FreChoice_s             : std_logic_vector( 2 downto 0);        -- frequence choice
    signal PrSv_FreLed_s                : std_logic_vector( 3 downto 0);        -- led
    signal PrSl_ClkSel_s                : std_logic;                            -- Select Clk

	--------------------------------  
    -- ChipScope                      
    --------------------------------  
    signal PrSv_ChipTrig_s              : std_logic_vector(63 downto 0);        -- ChipScopeTrig 
 
begin
    ------------------------------------
    -- Component map
    ------------------------------------
--    U_M_ila_3 : M_ila port map (
--        control                         => CpSv_ChipCtrl3_io                    ,
--        clk                             => CpSl_Clk_i                           ,
--        trig0                           => PrSv_ChipTrig_s
--    );
--    PrSv_ChipTrig_s(           0)       <= PrSl_FalFlage_s                      ;
--    PrSv_ChipTrig_s( 8 downto  1)       <= PrSv_VsyncTrigCnt_s                  ;
--    PrSv_ChipTrig_s(10 downto  9)       <= PrSv_StateVld_s                      ;
--    PrSv_ChipTrig_s(13 downto 11)       <= PrSv_FreChoice_s                     ;
--    PrSv_ChipTrig_s(          14)       <= PrSl_ClkSel_s                        ;
--    PrSv_ChipTrig_s(          15)       <= PrSl_VsyncTrig_s                     ;
--    PrSv_ChipTrig_s(63 downto 16)       <= (others => '0')                      ;     

    ----------------------------------------------------------------------------
    -- Flage  x"4C4B3FF" = 79,999,999 
    ----------------------------------------------------------------------------
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_1HzCnt_s <= (others => '0');
        elsif rising_edge (CpSl_Clk_i) then
            if (PrSv_1HzCnt_s = PrSv_1sCnt_c) then
                PrSv_1HzCnt_s <= (others => '0');
            else
                PrSv_1HzCnt_s <= PrSv_1HzCnt_s + '1';
            end if;
        end if;
    end process;

    -- Rising_edge Trig
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_RisFlage_s <= '0';
        elsif rising_edge (CpSl_Clk_i) then
            if (PrSv_1HzCnt_s = 0) then 
                PrSl_RisFlage_s <= '0';
            elsif (PrSv_1HzCnt_s = PrSv_2Cnt_c) then
                PrSl_RisFlage_s <= '1';
            else --hold
            end if;
        end if;
    end process;

    -- Falling_edge Trig
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_FalFlage_s <= '0';
        elsif rising_edge (CpSl_Clk_i) then
            if (PrSv_1HzCnt_s = PrSv_FslCnt_c) then 
                PrSl_FalFlage_s <= '1';
            elsif (PrSv_1HzCnt_s = PrSv_1sCnt_c) then
                PrSl_FalFlage_s <= '0';
            else --hold
            end if;
        end if;
    end process;
    
    ----------------------------------------------------------------------------
    -- Delay DviVsync
    ----------------------------------------------------------------------------
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_VsyncDly1_s <= '0';
            PrSl_VsyncDly2_s <= '0';
            PrSl_VsyncDly3_s <= '0';
        elsif rising_edge(CpSl_Clk_i) then
            PrSl_VsyncDly1_s <= CpSl_DviVsync_i;
            PrSl_VsyncDly2_s <= PrSl_VsyncDly1_s;
            PrSl_VsyncDly3_s <= PrSl_VsyncDly2_s;
        end if;
    end process;

    -- Vsync Falling Trig
    PrSl_VsyncTrig_s <= (not PrSl_VsyncDly2_s) and PrSl_VsyncDly3_s;

    --Trig Cnt
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_VsyncTrigCnt_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSl_RisFlage_s = '1') then
                if (PrSl_VsyncTrig_s = '1') then
                    PrSv_VsyncTrigCnt_s <= PrSv_VsyncTrigCnt_s + '1';
                else --hold
                end if;
            else
                PrSv_VsyncTrigCnt_s <= (others => '0');
            end if;
        end if;
    end process;
    
    -- CpSv_VsyncTrig_o
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            CpSv_VsyncTrig_o <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSl_FalFlage_s = '1') then
                CpSv_VsyncTrig_o <= PrSv_VsyncTrigCnt_s;
            else --hold
            end if;
         end if;
    end process;
    
    -- CpSl_DataVld_o
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            CpSl_DataVld_o <= '0';
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSl_FalFlage_s = '1') then
                CpSl_DataVld_o <= '1';
            else
                CpSl_DataVld_o <= '0';
            end if;
         end if;
    end process;
    
    --Dvi0Scdt  DviScdt1
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_StateVld_s <= "00";
        elsif rising_edge(CpSl_Clk_i) then
            if (CpSl_Dvi0Scdt_i = '1') then
                if (CpSl_Dvi1Scdt_i = '1') then
                	PrSv_StateVld_s <= "01";
                else
                	PrSv_StateVld_s <= "10";
                end if;
            else
            	PrSv_StateVld_s <= (others => '0');
            end if;
         end if;
    end process;        	
    
    ------------------------------------
    --Choice Frequence
    --Secect Clk
    ------------------------------------
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_FreChoice_s 	<= (others => '0');	
            PrSv_FreLed_s 	  	<= (others => '1');
            PrSl_ClkSel_s       <= '0';
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSv_StateVld_s = "01") then 
                if (PrSl_FalFlage_s = '1') then               
                    PrSv_FreChoice_s 	<= PrSv_Ref200Hz_c;
                    PrSv_FreLed_s 		<= "0000";
                    PrSl_ClkSel_s       <= '0';
                else --hold
                end if;                  
            elsif (PrSv_StateVld_s = "10") then
                if (PrSl_FalFlage_s = '1') then 
                    -- RefRate 100Hz 
                    if (PrSv_VsyncTrigCnt_s >= 90 and PrSv_VsyncTrigCnt_s <= 110) then
                        PrSv_FreChoice_s 	<= PrSv_Ref100Hz_c;
                        PrSv_FreLed_s 		<= "0111";
                        PrSl_ClkSel_s       <= '1';
	        		    
                    elsif (PrSv_VsyncTrigCnt_s >= 60 and PrSv_VsyncTrigCnt_s <= 75) then
                        -- RefRate 67Hz 
	        		    -- 67Hz的刷新频率低于80Hz,会产生LCD屏幕闪烁,通过倍频的方式解决
	        		    PrSv_FreChoice_s 	<= PrSv_Ref67Hz_c;								
                        PrSv_FreLed_s 		<= "1011";
                        PrSl_ClkSel_s       <= '0';
	        	        
                    else --hold
                    end if;
                else --hold
                end if;
            else
            	PrSv_FreChoice_s 	<= (others => '0');	
                PrSv_FreLed_s 	  	<= (others => '1');
                PrSl_ClkSel_s       <= '0';
            end if;
        end if;
    end process;

    --refresh rate
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
        	CpSv_FreChoice_o 	<= (others => '0');
        	CpSv_FreLed_o 		<= (others => '1');
            CpSl_ClkSel_o       <= '0';
        elsif rising_edge(CpSl_Clk_i) then
        	CpSv_FreChoice_o 	<= PrSv_FreChoice_s;
        	CpSv_FreLed_o 		<= PrSv_FreLed_s;
        	CpSl_ClkSel_o   	<= PrSl_ClkSel_s;
        end if;
    end process;
    	   
end arch_M_FreCtrl;
