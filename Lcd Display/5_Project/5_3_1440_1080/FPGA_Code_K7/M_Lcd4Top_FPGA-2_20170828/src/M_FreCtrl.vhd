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
-- ��    Ȩ  :  BiXing Tech
-- �ļ�����  :  M_FreCtrl.vhd
-- ��    ��  :  zhang wenjun
-- ��    ��  :  wenjunzhang@bixing-tech.com
-- У    ��  :
-- �������  :  2017/3/9
-- ���ܼ���  :  Choice Refresh Rate
--              1440*1080@50/60/75/85/100Hz 
-- �汾���  :  0.1
-- �޸���ʷ  :  1. Initial, zhang wenjun, 2017/3/9
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity M_FreCtrl is
    generic (
        --------------------------------
        -- simulation = 0 for simulation 
        -- Choice the the Refrate     
        --------------------------------
        Simulation                      : integer := 1;                         
        Refresh_Rate                    : integer := 100                       
    );
    port (
        --------------------------------
        --Rst & Clk
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                       --Rst, active low
        CpSl_Clk_i                      : in  std_logic;                       --Clk, 100MHz signal 

        --------------------------------
        --Dvi
        --------------------------------
        CpSl_Dvi0Scdt_i                 : in  std_logic;                        --Dvi0 Scdt
        CpSl_Dvi1Scdt_i                 : in  std_logic;                        --Dvi1 Scdt
        CpSl_Dvi0Vsync_i                : in  std_logic;                        --Dvi0 Vsync

        --------------------------------  
        -- Select Clk & Dvi Enable
        --------------------------------
        CpSl_ClkSel_o                   : out std_logic;                        -- Select Clk signal
        CpSl_DviEn_o                    : out std_logic;                        -- Dvi input enable

        --------------------------------
        --Frequence Choice & Led(3 downto 0)
        --------------------------------
        CpSv_VsyncTrigCnt_o             : out std_logic_vector( 7 downto 0);    -- Vsync Trig Cnt
        CpSv_FreChoice_o                : out std_logic_vector( 2 downto 0);    -- Choice frequence
        CpSv_FreLed_o                   : out std_logic_vector( 3 downto 0);    -- Led

        --------------------------------
        --ChipScope 
        --------------------------------
        CpSv_ChipCtrl3_io               : inout std_logic_vector(35 downto 0)   -- in std_logic_vector(35 downto 0); 
    );
end M_FreCtrl;

architecture arch_M_FreCtrl of M_FreCtrl is
    ----------------------------------------------------------------------------
    --constant declaration
    ----------------------------------------------------------------------------
    constant PrSv_2Cnt_c                : std_logic_vector(27 downto 0) := x"0000002"; -- 2
    constant PrSv_99Cnt_c               : std_logic_vector(27 downto 0) := x"5F5E0FD"; -- 89,999,997
    constant PrSv_100MHz_c              : std_logic_vector(27 downto 0) := x"5F5E0FF"; -- 99,999,999
         
    -- 1440_1080
    constant PrSv_Ref100Hz_c            : std_logic_vector( 2 downto 0) := "100";      -- 100Hz
    constant PrSv_Ref85Hz_c             : std_logic_vector( 2 downto 0) := "010";      -- 85Hz
    constant PrSv_Ref75Hz_c             : std_logic_vector( 2 downto 0) := "001";      -- 75Hz
    constant PrSv_Ref60Hz_c             : std_logic_vector( 2 downto 0) := "110";      -- 60Hz
    constant PrSv_Ref50Hz_c             : std_logic_vector( 2 downto 0) := "101";      -- 50Hz


    ----------------------------------------------------------------------------
    --component declaration
    ----------------------------------------------------------------------------
    component M_ila port (
        control                         : inout std_logic_vector(35 downto 0);
        clk                             : in    std_logic;
        trig0                           : in    std_logic_vector(74 downto 0)
    );
    end component;

    ----------------------------------------------------------------------------
    --signal declaration
    ----------------------------------------------------------------------------
    signal PrSv_1HzCnt_s                : std_logic_vector(27 downto 0);        -- 1s Cnt
    signal PrSv_VsyncTrigCnt_s          : std_logic_vector( 7 downto 0);        -- Dvi0 Vsync Trig Cnt
    signal PrSl_VsyncTrig_s             : std_logic;                            -- Dvi0 Vsync Trig
    signal PrSl_RisFlage_s              : std_logic;                            -- Ris flage 1s
    signal PrSl_FalFlage_s              : std_logic;                            -- Fal flage 1s
    signal PrSv_StateVld_s              : std_logic_vector(1 downto 0);         -- Scde1 Scdt0
    signal PrSl_VsyncDly1_s             : std_logic;                            -- Dly 1 Clk
    signal PrSl_VsyncDly2_s             : std_logic;                            -- Dly 2 Clk
    signal PrSl_VsyncDly3_s             : std_logic;                            -- Dly 3 Clk
    signal PrSv_FreChoice_s             : std_logic_vector( 2 downto 0);        -- frequence choice
    signal PrSv_FreLed_s                : std_logic_vector( 3 downto 0);        -- led
    signal PrSl_ClkSel_s                : std_logic;                            -- Select Clk
    
    -- ChipScope
    signal PrSl_FreCtrlClk_s            : std_logic;                            -- ChipScope Ctrl Clk
    signal PrSv_ChipTrig0_s             : std_logic_vector(74 downto 0);        -- ChipScope Trig

begin
    ----------------------------------------------------------------------------
    -- ChipScope M_ila
    ----------------------------------------------------------------------------
    -- FreCtrl
    PrSl_FreCtrlClk_s <= CpSl_Clk_i;
    
    U_M_ila_3 : M_ila port map (
        control                         => CpSv_ChipCtrl3_io                    ,
        clk                             => PrSl_FreCtrlClk_s                    ,
        trig0                           => PrSv_ChipTrig0_s
    );

    PrSv_ChipTrig0_s(           0)      <= PrSl_FalFlage_s;
    PrSv_ChipTrig0_s( 8 downto  1)      <= PrSv_VsyncTrigCnt_s;
    PrSv_ChipTrig0_s(10 downto  9)      <= PrSv_StateVld_s;
    PrSv_ChipTrig0_s(13 downto 11)      <= PrSv_FreChoice_s;
    PrSv_ChipTrig0_s(74 downto 14)      <= (others => '0');
     
    ----------------------------------------------------------------------------
    -- 1s Domain
    ----------------------------------------------------------------------------
    --flage 1s Cnt
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_1HzCnt_s <= (others => '0');
        elsif rising_edge (CpSl_Clk_i) then
            if (PrSv_1HzCnt_s = PrSv_100MHz_c) then
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
            if (PrSv_1HzCnt_s = PrSv_99Cnt_c) then 
                PrSl_FalFlage_s <= '1';
            elsif (PrSv_1HzCnt_s = PrSv_100MHz_c) then
                PrSl_FalFlage_s <= '0';
            else --hold
            end if;
        end if;
    end process;
    
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
    
    -- CpSv_VsyncTrigCnt_o
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            CpSv_VsyncTrigCnt_o <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSl_FalFlage_s = '1') then
                CpSv_VsyncTrigCnt_o <= PrSv_VsyncTrigCnt_s;
            else -- hold
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

    ------------------------------------
    -- Choice Frequence & Clk                   
    ------------------------------------
    -- Sim_Data
    Sim_Data : if (Simulation = 0) generate
        CpSv_FreChoice_o <= PrSv_Ref100Hz_c; 
        CpSv_FreLed_o    <= "0011";          
        CpSl_ClkSel_o    <= '0';             
    end generate Sim_Data;
    
    -- Real_Data
    Real_Data : if (Simulation = 1) generate 
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_FreChoice_s <= (others => '0');
            PrSv_FreLed_s    <= (others => '1');
            PrSl_ClkSel_s    <= '1';

        elsif rising_edge(CpSl_Clk_i) then
            if (PrSv_StateVld_s = "01") then
                if (PrSl_FalFlage_s = '1') then 
                    -- 100Hz 
                    if (PrSv_VsyncTrigCnt_s >= 91 and PrSv_VsyncTrigCnt_s <= 105) then 
                        PrSv_FreChoice_s <= PrSv_Ref100Hz_c;
                        PrSv_FreLed_s    <= "0011";
                        PrSl_ClkSel_s    <= '1';
                        
                    -- 85Hz
                    elsif (PrSv_VsyncTrigCnt_s >= 80 and PrSv_VsyncTrigCnt_s <= 90) then 
                        PrSv_FreChoice_s <= PrSv_Ref85Hz_c;
                        PrSv_FreLed_s    <= "0111";
                        PrSl_ClkSel_s    <= '0';
                        
                    -- when reference rate < 80Hz ,Lcd Rate must double Dvi rate
                    --75Hz 
                    elsif (PrSv_VsyncTrigCnt_s >= 70 and PrSv_VsyncTrigCnt_s <= 80) then
                        PrSv_FreChoice_s <= PrSv_Ref75Hz_c;
                        PrSv_FreLed_s    <= "1011";
                        PrSl_ClkSel_s    <= '0';
                    
                    -- 60Hz
                    elsif (PrSv_VsyncTrigCnt_s >= 56 and PrSv_VsyncTrigCnt_s <= 65) then
                        PrSv_FreChoice_s <= PrSv_Ref60Hz_c;
                        PrSv_FreLed_s    <= "1101";
                        PrSl_ClkSel_s    <= '1';

                    -- 50Hz
                    elsif (PrSv_VsyncTrigCnt_s >= 40 and PrSv_VsyncTrigCnt_s <= 55) then
                        PrSv_FreChoice_s <= PrSv_Ref50Hz_c;
                        PrSv_FreLed_s    <= "1110";
                        PrSl_ClkSel_s    <= '1';
                        
                    else -- hold 
                    end if;
                else -- hold
                end if;

            elsif (PrSv_StateVld_s = "10") then
                if (PrSl_FalFlage_s = '1') then
                    PrSv_FreChoice_s <= (others => '0');
                    PrSv_FreLed_s    <= (others => '1');
                    PrSl_ClkSel_s    <= '0';
                    
                else --hold
                end if;
                    
            else
               PrSv_FreChoice_s <= (others => '0');
               PrSv_FreLed_s    <= (others => '1');
               PrSl_ClkSel_s    <= '1';
                
            end if;
        end if;
    end process;
    
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            CpSv_FreChoice_o <= (others => '0');
            CpSv_FreLed_o    <= (others => '1');
            CpSl_ClkSel_o    <= '1';
            
        elsif rising_edge(CpSl_Clk_i) then
            CpSv_FreChoice_o <= PrSv_FreChoice_s;
            CpSv_FreLed_o    <= PrSv_FreLed_s;
            CpSl_ClkSel_o    <= PrSl_ClkSel_s;

        end if;
    end process;
    end generate Real_Data;

    
end arch_M_FreCtrl;