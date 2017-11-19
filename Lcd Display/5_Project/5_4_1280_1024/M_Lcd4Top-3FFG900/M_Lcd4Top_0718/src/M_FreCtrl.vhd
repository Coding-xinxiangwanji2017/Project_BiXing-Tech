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
-- 设    计  :  zhang wen jun
-- 邮    件  :
-- 校    对  :
-- 设计日期  :  2016/3/2
-- 功能简述  :  Choice Refresh Rate
-- 版本序号  :  0.1
-- 修改历史  :  1. Initial, zhang wen jun, 2016/3/2
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
        CpSl_Rst_iN                     : in  std_logic;                       --Rst, active low
        CpSl_Clk_i                      : in  std_logic;                       --Clk, 100Mhz

        --------------------------------
        --Dvi
        --------------------------------
        CpSl_Dvi0Scdt_i                 : in  std_logic;                        --Dvi0 Scdt
        CpSl_Dvi1Scdt_i                 : in  std_logic;                        --Dvi1 Scdt
        CpSl_Dvi0Vsync_i                : in  std_logic;                        --Dvi0 Vsync

        --------------------------------
        -- Select Clk Dvi enable
        --------------------------------
        CpSl_ClkSel_o                   : out std_logic;                        -- Select Clk signal
        CpSl_DviEn_o                    : out std_logic;                        -- Dvi input enable

        --------------------------------
        --Frequence Choice & Led(3 downto 0)
        --------------------------------
        CpSl_LCD_Double_o		        : out  std_logic;
        CpSv_FreChoice_o                : out  std_logic_vector( 2 downto 0);   --Choice frequence
        CpSv_FreLed_o                   : out  std_logic_vector( 3 downto 0)    --led
    );
end M_FreCtrl;

architecture arch_M_FreCtrl of M_FreCtrl is
    ----------------------------------------------------------------------------
    --constant declaration
    ----------------------------------------------------------------------------
    constant PrSv_Ref200Hz_c            : std_logic_vector(2 downto 0) := "100"; -- 200Hz
    constant PrSv_Ref100Hz_c            : std_logic_vector(2 downto 0) := "011"; -- 100Hz
    constant PrSv_Ref60Hz_c             : std_logic_vector(2 downto 0) := "010"; -- 60Hz
    constant PrSv_Ref50Hz_c             : std_logic_vector(2 downto 0) := "001"; -- 50Hz

    ----------------------------------------------------------------------------
    --signal declaration
    ----------------------------------------------------------------------------
    signal PrSv_1HzCnt_s                : std_logic_vector(26 downto 0);        --x"5F5_E0FF" is 99,999,999
    signal PrSv_VsyncTrigCnt_s          : std_logic_vector( 7 downto 0);        --Dvi0 Vsync Trig Cnt
    signal PrSl_VsyncTrig_s             : std_logic;                            --Dvi0 Vsync Trig
    signal PrSl_RisFlage_s              : std_logic;                            --Ris flage 1s
    signal PrSl_FalFlage_s              : std_logic;                            --Fal flage 1s
    signal PrSv_StateVld_s              : std_logic_vector(1 downto 0);         --Scde1 Scdt0
    signal PrSl_VsyncDly1_s             : std_logic;                            --Dly 1 Clk
    signal PrSl_VsyncDly2_s             : std_logic;                            --Dly 2 Clk
    signal PrSl_VsyncDly3_s             : std_logic;                            --Dly 3 Clk
    signal PrSv_FreChoice_s             : std_logic_vector( 2 downto 0);        --frequence choice
    signal PrSv_FreLed_s                : std_logic_vector( 3 downto 0);        --led
    signal PrSl_ClkSel_s                : std_logic;                            -- Select Clk
    signal PrSl_LCD_Double_s            : std_logic;                            -- Lcd Double signal

begin

    --flage  x"5F5E0FF" = 99,999,999
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_1HzCnt_s <= (others => '0');
        elsif rising_edge (CpSl_Clk_i) then
            if (PrSv_1HzCnt_s = x"5F5E0FF") then
                PrSv_1HzCnt_s <= (others => '0');
            else
                PrSv_1HzCnt_s <= PrSv_1HzCnt_s + '1';
            end if;
        end if;
    end process;

    --Ris Fall  Flage
    PrSl_RisFlage_s <= '0' when (PrSv_1HzCnt_s <= x"01") else '1';
    PrSl_FalFlage_s <= '0' when (PrSv_1HzCnt_s <= x"5F5E0FD") else '1';

    --Delay DviVsync
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_VsyncDly1_s <= '0';
            PrSl_VsyncDly2_s <= '0';
            PrSl_VsyncDly3_s <= '0';
        elsif rising_edge(CpSl_Clk_i) then
            PrSl_VsyncDly1_s <= CpSl_Dvi0Vsync_i;
            PrSl_VsyncDly2_s <= PrSl_VsyncDly1_s;
            PrSl_VsyncDly3_s <= PrSl_VsyncDly2_s;
        end if;
    end process;

    --Vsync Falling Trig
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

    --Dvi0Scdt  DviScdt1
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
    	if (CpSl_Rst_iN = '0') then
            PrSv_StateVld_s <= (others => '0');
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

    -- DVI input indication
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            CpSl_DviEn_o <= '0';
        elsif rising_edge(CpSl_Clk_i) then
            if (CpSl_Dvi1Scdt_i = '1' or CpSl_Dvi0Scdt_i = '1') then
                CpSl_DviEn_o <= '1';
            else
                CpSl_DviEn_o <= '0';
            end if;
        end if;
    end process;

    --Choice Frequence
    --Secect Clk
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_FreChoice_s   <= (others => '0');
            PrSv_FreLed_s      <= (others => '1');
	     	PrSl_LCD_Double_s  <= '0';
            PrSl_ClkSel_s      <= '1';
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSv_StateVld_s <= "01") then
                if (PrSl_FalFlage_s = '1') then
                    PrSv_FreChoice_s   <= PrSv_Ref200Hz_c;
                    PrSv_FreLed_s      <= "0111";
                    PrSl_ClkSel_s      <= '0';
		     		PrSl_LCD_Double_s  <= '0';
                else --hold
                end if;

            elsif (PrSv_StateVld_s <= "10") then
                if (PrSl_FalFlage_s = '1') then
                    if (PrSv_VsyncTrigCnt_s >= 90 and PrSv_VsyncTrigCnt_s <= 105) then
                        PrSv_FreChoice_s   <= PrSv_Ref100Hz_c;
                        PrSv_FreLed_s      <= "1011";
                        PrSl_ClkSel_s      <= '1';
			 			PrSl_LCD_Double_s  <= '0';

                    -- when reference rate < 80hz ,Lcd Rate must double Dvi rate
                    -- 60Hz
                    elsif (PrSv_VsyncTrigCnt_s >= 56 and PrSv_VsyncTrigCnt_s <= 64) then
                        PrSv_FreChoice_s   <= PrSv_Ref60Hz_c;
                        PrSv_FreLed_s      <= "1101";
                        PrSl_ClkSel_s      <= '1';
			 			PrSl_LCD_Double_s  <= '1';

                    -- 50Hz
                    elsif (PrSv_VsyncTrigCnt_s >= 40 and PrSv_VsyncTrigCnt_s <= 53) then
                        PrSv_FreChoice_s   <= PrSv_Ref50Hz_c;
                        PrSv_FreLed_s      <= "1110";
                        PrSl_ClkSel_s      <= '1';
					 	PrSl_LCD_Double_s  <= '1';
                    else --hold
                    end if;
                else --hold
                end if;
            else
            	PrSv_FreChoice_s   <= (others => '0');
                PrSv_FreLed_s      <= (others => '1');
                PrSl_ClkSel_s      <= '1';
		        PrSl_LCD_Double_s  <= '0';
            end if;
        end if;
    end process;

    --refresh rate
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
        	CpSv_FreChoice_o 	<= (others => '0');
        	CpSv_FreLed_o 		<= (others => '1');
        	CpSl_LCD_Double_o   <= '0';
        	CpSl_ClkSel_o       <= '1';
        elsif rising_edge(CpSl_Clk_i) then
        	CpSv_FreChoice_o 	<= PrSv_FreChoice_s;
        	CpSv_FreLed_o 		<= PrSv_FreLed_s;
        	CpSl_LCD_Double_o	<= PrSl_LCD_Double_s;
        	CpSl_ClkSel_o       <= PrSl_ClkSel_s;
        end if;
    end process;

end arch_M_FreCtrl;
