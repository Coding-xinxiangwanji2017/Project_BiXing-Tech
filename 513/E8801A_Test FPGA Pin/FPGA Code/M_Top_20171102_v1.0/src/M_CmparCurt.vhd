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
-- �ļ�����  :  M_CmparCurt.vhd
-- ��    ��  :  Zhang Wenjun
-- ��    ��  :  wenjunzhang@bixing-tech.com
-- У    ��  :  
-- ��������  :  2017/07/10
-- ���ܼ���  :  compare current,ADS1108 capture current
-- �汾����  :  0.1
-- �޸���ʷ  :  1. Initial, Zhang Wenjun, 2017/07/10
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity M_CmparCurt is
    port (
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      : in  std_logic;                        -- 100MHz Clock,single

        --------------------------------
        -- FPGA Standard Current
        --------------------------------
        CpSl_CurtDvld_i                 : in  std_logic;                        -- Parallel Voltage data valid
        CpSv_CurtData_i                 : in  std_logic_vector(71 downto 0);    -- Parallel Voltage data

        --------------------------------
        -- Compare Voltage Result
        --------------------------------
        CpSl_CmpVolVld_i                : in  std_logic;                        -- Copmare Voltage Valid
        CpSv_VoltageResult_i            : in  std_logic_vector( 6 downto 0);    -- Copmare Voltage Valid Data
        
        --------------------------------
        -- Test FPGA Reset Valid/JTAG
        --------------------------------
        CpSl_JtagDvld_i                 : in  std_logic;                        -- Parallel JTAG data valid
        CpSl_RstVld_i                   : in  std_logic;                        -- FPGA Reset Valid
        
        --------------------------------
        -- Control Relay Voltage
        --------------------------------
        CpSv_VadjCtrl_o                 : out std_logic_vector( 2 downto 0);    -- Control Vadj Relay
        CpSv_RelayEn_o                  : out std_logic_vector( 2 downto 0);    -- F_En Voltage

        --------------------------------
        -- ADC Current Interface
        --------------------------------
        CpSl_CurtAdcClk_o               : out std_logic;                        -- ADC Clock
        CpSl_CurtAdcCS_o                : out std_logic;                        -- ADC CS
        CpSl_CurtAdcConfigData_o        : out std_logic;                        -- ADC Configuration Data
        CpSl_CurtAdcData_i              : in  std_logic;                        -- ADC Transfer Data

        --------------------------------
        -- Compare Current Result
        --------------------------------
        CpSl_CmpInd_o                   : out std_logic;                        -- Compare Current Result
        CpSl_CmpCurtVld_o               : out std_logic;                        -- Copmare Valid
        CpSv_CmpCurtData_o              : out std_logic_vector(10 downto 0)     -- Copmare Valid Data
    );
end M_CmparCurt;

architecture arch_M_CmparCurt of M_CmparCurt is 
    ----------------------------------------------------------------------------
    -- constant declaration
    ----------------------------------------------------------------------------
    ------------------------------------
    -- JTAG 
    ------------------------------------
    constant PrSv_JtagSucc_c            : std_logic_vector(23 downto 0) := x"AABBCC";   -- Download Successful
    constant PrSv_JtagFail_c            : std_logic_vector(23 downto 0) := x"AABBEE";   -- Download Failed

    ------------------------------------
    -- Current : Adc_A = PC_A*1000
    ------------------------------------
    -- Board Indication
    constant PrSv_SelfFpga_c            : std_logic_vector( 2 downto 0) := "001";   -- Self Check Board
    constant PrSv_A1000Fpga_c           : std_logic_vector( 2 downto 0) := "010";   -- A1000 Board
    constant PrSv_A500Fpga_c            : std_logic_vector( 2 downto 0) := "011";   -- A500 Board
    constant PrSv_A54SFpga0_c           : std_logic_vector( 2 downto 0) := "100";   -- A54S Board Test first Current
    constant PrSv_A54SFpga1_c           : std_logic_vector( 2 downto 0) := "101";   -- A54S Board Test Second Current
    
    -- Relay Control
    constant PrSv_SelfRelay_c           : std_logic_vector( 5 downto 0) := "000100";   -- Self Check Board
    constant PrSv_A1000Relay_c          : std_logic_vector( 5 downto 0) := "101101";   -- A1000 Board
    constant PrSv_A500Relay_c           : std_logic_vector( 5 downto 0) := "101101";   -- A500 Board
    constant PrSv_A54S0Relay_c          : std_logic_vector( 5 downto 0) := "101010";   -- A54S Board first Current
    constant PrSv_A54S1Relay_c          : std_logic_vector( 5 downto 0) := "001010";   -- A54S Board Second Current

    -- Vcc Ctrl ---> Test Board (Vadj/3V3/2V5/1V5)
    constant PrSv_VccError_c            : std_logic_vector( 3 downto 0) := "0000";  -- Test Vcc Error
    constant PrSv_SelfFpgaVcc_c         : std_logic_vector( 3 downto 0) := "0100";  -- Self Check Board 
    constant PrSv_A1000FpgaVcc_c        : std_logic_vector( 3 downto 0) := "1101";  -- A1000 Board 
    constant PrSv_A500FpgaVcc_c         : std_logic_vector( 3 downto 0) := "1101";  -- A500 Board 
    constant PrSv_A54SFpga0Vcc_c        : std_logic_vector( 3 downto 0) := "1010";  -- A54S Board Test first
    constant PrSv_A54SFpga1Vcc_c        : std_logic_vector( 3 downto 0) := "1010";  -- A54S Board Test Second

    -- ADC Configure Data
    constant PrSv_ConfigCmd_c           : std_logic_vector(15 downto 0) := x"0000"; -- ADC Config Commmand
    constant PrSv_ConfigVadj_c          : std_logic_vector(15 downto 0) := x"F7CB"; -- ADC_Vadj_A
    constant PrSv_Config3V3_c           : std_logic_vector(15 downto 0) := x"E7CB"; -- ADC_3V3_A
    constant PrSv_Config2V5_c           : std_logic_vector(15 downto 0) := x"C7CB"; -- ADC_2V5_A
    constant PrSv_Config1V5_c           : std_logic_vector(15 downto 0) := x"D7CB"; -- ADC_1V5_A

    -- Current Range
    constant PrSv_CurtRang_c            : std_logic_vector(15 downto 0) := x"001D";  -- 15mA

    -- ADC constant
    constant PrSv_CurtCapCycle_c        : std_logic_vector(23 downto 0) := x"16E35F"; -- Current Capture Cycle 15 ms
    constant PrSv_CurtCmpCnt_c          : std_logic_vector(23 downto 0) := x"071AAF"; -- Current Compare 5ms
    constant PrSv_Cnt1us_c              : std_logic_vector( 7 downto 0) := x"63";    -- Capture Current 1us
    constant PrSv_AdcStart_c            : std_logic_vector(15 downto 0) := x"1381"; -- ADC Start Count 50 us 
    constant PrSv_AdcWait_c             : std_logic_vector(15 downto 0) := x"03E7"; -- ADC wait count 10 us
    constant PrSv_AdcStop_c             : std_logic_vector(15 downto 0) := x"1381"; -- ADC Stop count 50 us

    ----------------------------------------------------------------------------
    -- signal declaration
    ----------------------------------------------------------------------------
    -- Control Voltage
    signal PrSv_VolHead_s               : std_logic_vector( 2 downto 0);        -- Voltage Head
    signal PrSv_VolResult_s             : std_logic_vector( 3 downto 0);        -- Voltage Result
    signal PrSv_RelayCnt_s              : std_logic_vector(23 downto 0);        -- Relay Cnt
    signal PrSv_CtrlRelay_s             : std_logic_vector( 5 downto 0);        -- Control Relay
    
    -- Current Base Data 
    signal PrSv_Head_s                  : std_logic_vector( 7 downto 0);        -- Recive FPGA Type
    signal PrSv_CurtVadj_s              : std_logic_vector(15 downto 0);        -- Recive Current Vadj_A
    signal PrSv_Curt3v3_s               : std_logic_vector(15 downto 0);        -- Recive Current 3V3_A 
    signal PrSv_Curt2v5_s               : std_logic_vector(15 downto 0);        -- Recive Current 2V5_A 
    signal PrSv_Curt1v5_s               : std_logic_vector(15 downto 0);        -- Recive Current 1V5_A 

    -- Capture Valid
    signal PrSl_CurtCapVld_s            : std_logic;                            -- ADC Current Valid
    signal PrSl_CurtCapTrig_s           : std_logic;                            -- ADC Current Capture Trig
    signal PrSl_CurtCmptrig_s           : std_logic;                            -- Current Commpare Trig
    signal PrSv_CurtCapCycle_s          : std_logic_vector(23 downto 0);        -- Current Capture Cycle

    -- ADC State Machine
    signal PrSl_VoltageVldDly1_s        : std_logic;                            -- Delay PrSl_CmpVolVldTrig_s 1 Clk
    signal PrSl_VoltageVldDly2_s        : std_logic;                            -- Delay PrSl_CmpVolVldTrig_s 2 Clk
    signal PrSv_CapCurtNum_s            : std_logic_vector( 2 downto 0);        -- Capture Adc Voltage Number
    signal PrSl_CmpVolVldDly1_s         : std_logic;                            -- Delay CpSl_CmpVolVld_i 1 Clk
    signal PrSl_CmpVolVldDly2_s         : std_logic;                            -- Delay CpSl_CmpVolVld_i 2 Clk
    signal PrSl_CmpVolVldDly3_s         : std_logic;                            -- Delay CpSl_CmpVolVld_i 3 Clk
    signal PrSl_CmpVolVldTrig_s         : std_logic;                            -- Delay CpSl_CmpVolVld_i Trig
    signal PrSv_AdcState_s              : std_logic_vector( 3 downto 0);        -- ADC State 
    signal PrSv_AdcStart_s              : std_logic_vector(15 downto 0);        -- ADC Start Count
    signal PrSv_AdcConfigEnd_s          : std_logic_vector(15 downto 0);        -- ADC Config End
    signal PrSv_AdcRst_s                : std_logic_vector(15 downto 0);        -- ADC Reset Count
    signal PrSv_AdcWait_s               : std_logic_vector(15 downto 0);        -- ADC Wait Count
    signal PrSv_AdcStop_s               : std_logic_vector(15 downto 0);        -- ADC Stop Count
    signal PrSv_AdcEnd_s                : std_logic_vector(15 downto 0);        -- ADC End Count
    signal PrSv_AdcConfigCmdNum_s       : std_logic_vector( 4 downto 0);        -- ADC Config Command Num
    signal PrSv_AdcConfigNum_s          : std_logic_vector( 4 downto 0);        -- ADC Config Num
    signal PrSv_AdcRecNum_s             : std_logic_vector( 4 downto 0);        -- ADC Receive Num
    signal PrSl_AdcSclk_s               : std_logic;                            -- ADC Sclk
    signal PrSl_AdcSclkNum_s            : std_logic_vector( 7 downto 0);        -- ADC Sclk Num
    signal PrSv_AdcConfigData_s         : std_logic_vector(15 downto 0);        -- ADC Config Data
    signal PrSl_AdcConfig_s             : std_logic;                            -- ADC Config
    signal PrSl_AdcConfigCmd_s          : std_logic;                            -- ADC Config Command
    signal PrSv_AdcDin_s                : std_logic_vector(15 downto 0);        -- ADC Transfer Data
    signal PrSv_AdcCurtVadj_s           : std_logic_vector(11 downto 0);        -- ADC Capture Vadj_A
    signal PrSv_AdcCurt3V3_s            : std_logic_vector(11 downto 0);        -- ADC Capture 3V3_A 
    signal PrSv_AdcCurt2V5_s            : std_logic_vector(11 downto 0);        -- ADC Capture 2V5_A 
    signal PrSv_AdcCurt1V5_s            : std_logic_vector(11 downto 0);        -- ADC Capture 1V5_A 

    -- Compare State Machine
    signal PrSv_TestBoard_s             : std_logic_vector( 2 downto 0);        -- Indication Test Board
    signal PrSv_CmpState_s              : std_logic_vector( 2 downto 0);        -- Current Compare State
    signal PrSv_CmpInd_s                : std_logic;                            -- Compare Right Indication
    signal PrSl_CmpIndTrig_s            : std_logic;                            -- Compare Right Indication Trig
    signal PrSv_CmpIndCnt_s             : std_logic_vector( 7 downto 0);        -- Compare Right Indication Count
    signal PrSv_Cnt1us_s                : std_logic_vector( 7 downto 0);        -- Count 1us
    signal PrSv_CurtResult_s            : std_logic_vector( 3 downto 0);        -- Current Compare Result 
    signal PrSv_CmpCurtResult_s         : std_logic_vector( 3 downto 0);        -- Compare Current Result 
    signal PrSv_CurtData_s              : std_logic_vector( 3 downto 0);        -- Compare Current Data
    
begin
    ----------------------------------------------------------------------------
    -- Mian Area
    ----------------------------------------------------------------------------
    -- Receive Current data
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_Head_s     <= (others => '0');
            PrSv_CurtVadj_s <= (others => '0');
            PrSv_Curt3v3_s  <= (others => '0');
            PrSv_Curt2v5_s  <= (others => '0');
            PrSv_Curt1v5_s  <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then 
            if (CpSl_CurtDvld_i = '1') then 
                PrSv_Head_s     <= CpSv_CurtData_i(71 downto 64);
                PrSv_CurtVadj_s <= CpSv_CurtData_i(63 downto 48);
                PrSv_Curt3v3_s  <= CpSv_CurtData_i(47 downto 32);
                PrSv_Curt2v5_s  <= CpSv_CurtData_i(31 downto 16);
                PrSv_Curt1v5_s  <= CpSv_CurtData_i(15 downto  0);
            else -- hold
            end if;
        end if;
    end process;
    
    -- Latch CpSl_CmpVolVld_i
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_CmpVolVldDly1_s <= '0';
            PrSl_CmpVolVldDly2_s <= '0';
            PrSl_CmpVolVldDly3_s <= '0';
        elsif rising_edge(CpSl_Clk_i) then
            PrSl_CmpVolVldDly1_s <= CpSl_CmpVolVld_i;
            PrSl_CmpVolVldDly2_s <= PrSl_CmpVolVldDly1_s;
            PrSl_CmpVolVldDly3_s <= PrSl_CmpVolVldDly2_s;
        end if;
    end process;

    -- Rising edge of CpSl_CmpVolVld_i
    PrSl_CmpVolVldTrig_s <= PrSl_CmpVolVldDly2_s and (not PrSl_CmpVolVldDly3_s);

    -- Delay PrSl_CmpVolVldTrig_s
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then 
            PrSl_VoltageVldDly1_s <= '0';
            PrSl_VoltageVldDly2_s <= '0';
        elsif rising_edge(CpSl_Clk_i) then 
            PrSl_VoltageVldDly1_s <= PrSl_CmpVolVldTrig_s;
            PrSl_VoltageVldDly2_s <= PrSl_VoltageVldDly1_s;
        end if;
    end process;
    
    -- CpSv_VoltageResult_i
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then 
            PrSv_VolHead_s      <= (others => '0');
            PrSv_VolResult_s    <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then 
            if (PrSl_CmpVolVldTrig_s = '1') then 
                PrSv_VolHead_s      <= CpSv_VoltageResult_i(6 downto 4);
                PrSv_VolResult_s    <= CpSv_VoltageResult_i(3 downto 0);
            else
            end if;
        end if;
    end process; 

    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then 
            PrSv_CtrlRelay_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then 
            if (PrSv_VolResult_s /= "0000") then 
                case PrSv_VolHead_s is 
                    when PrSv_SelfFpga_c  => PrSv_CtrlRelay_s <= PrSv_SelfRelay_c;
                    when PrSv_A1000Fpga_c => PrSv_CtrlRelay_s <= PrSv_A1000Relay_c;
                    when PrSv_A500Fpga_c  => PrSv_CtrlRelay_s <= PrSv_A500Relay_c;
                    when PrSv_A54SFpga0_c => PrSv_CtrlRelay_s <= PrSv_A54S0Relay_c;
                    when PrSv_A54SFpga1_c => PrSv_CtrlRelay_s <= PrSv_A54S1Relay_c;
                    when others           => PrSv_CtrlRelay_s <= (others => '0');
                end case;
            else
                PrSv_CtrlRelay_s <= (others => '0');
            end if;
        end if;
    end process; 
    --Vadj/Vol Ctlr
    CpSv_VadjCtrl_o <= PrSv_CtrlRelay_s(5 downto 3);
    CpSv_RelayEn_o  <= PrSv_CtrlRelay_s(2 downto 0);

    ------------------------------------
    -- ADC Current State 
    ------------------------------------
    -- PrSl_CurtCapVld_s
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then 
            PrSl_CurtCapVld_s <= '0';
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSl_VoltageVldDly2_s = '1' and PrSv_VolResult_s /= PrSv_VccError_c) then
                PrSl_CurtCapVld_s <= '1';
            elsif (PrSl_VoltageVldDly2_s = '1' and PrSv_VolResult_s = PrSv_VccError_c) then 
                 PrSl_CurtCapVld_s <= '0';
            elsif (CpSl_JtagDvld_i = '1') then
                PrSl_CurtCapVld_s <= '0'; 
            elsif (CpSl_RstVld_i = '1') then
                PrSl_CurtCapVld_s <= '1';
            else --hold
            end if;
        end if;
    end process;

    -- PrSv_CurtCapCycle_s
    process (CpSl_Rst_iN, CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            PrSv_CurtCapCycle_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i)then 
            if (PrSl_CurtCapVld_s = '1') then 
                if (PrSv_CurtCapCycle_s = PrSv_CurtCapCycle_c) then 
                    PrSv_CurtCapCycle_s <= (others => '0');
                else
                    PrSv_CurtCapCycle_s <= PrSv_CurtCapCycle_s + '1';
                end if;
            else
                PrSv_CurtCapCycle_s <= (others => '0');
            end if;
        end if;
    end process;
    
    -- PrSl_CurtCapTrig_s
    process (CpSl_Rst_iN, CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            PrSl_CurtCapTrig_s <= '0';
        elsif rising_edge(CpSl_Clk_i)then 
            if (PrSl_CurtCapVld_s = '1') then 
                if (PrSv_CurtCapCycle_s = PrSv_CurtCapCycle_c) then 
                    PrSl_CurtCapTrig_s <= '1';
                else 
                    PrSl_CurtCapTrig_s <= '0';
                end if;
            else 
                PrSl_CurtCapTrig_s <= '0';
            end if;
        end if;
    end process; 

    -- PrSl_CurtCmptrig_s
    process (CpSl_Rst_iN, CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            PrSl_CurtCmptrig_s <= '0';
        elsif rising_edge(CpSl_Clk_i)then 
            if (PrSl_CurtCapVld_s = '1') then
                if (PrSv_CurtCapCycle_s = PrSv_CurtCmpCnt_c) then 
                    PrSl_CurtCmptrig_s <= '1';
                else
                    PrSl_CurtCmptrig_s <= '0';
                end if;
            else 
                PrSl_CurtCmptrig_s <= '0';
            end if;
        end if;
    end process; 

    -- ADC Capture Num
    process (CpSl_Rst_iN, CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            PrSv_CapCurtNum_s <= "000";
        elsif rising_edge(CpSl_Clk_i) then 
--            if (PrSl_CmpVolVldTrig_s = '1') then 
            if (PrSl_CurtCapTrig_s = '1') then 
                PrSv_CapCurtNum_s <= "000";
            elsif (PrSv_AdcState_s = "1001" and PrSv_AdcStop_s = PrSv_AdcStop_c - 10) then
                PrSv_CapCurtNum_s <= PrSv_CapCurtNum_s + '1';
            elsif (PrSv_CapCurtNum_s = "100") then
                PrSv_CapCurtNum_s <= "100";
            else -- hold
            end if;
        end if;
    end process;

    -- ADC Config Data 
    process (CpSl_Rst_iN, CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            PrSv_AdcConfigData_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then 
        case PrSv_CapCurtNum_s is 
            when "000" => -- Config Vadj
                if (PrSv_AdcState_s = "0001") then 
--                    PrSv_AdcConfigData_s <= PrSv_ConfigCmd_c;
                    PrSv_AdcConfigData_s <= PrSv_ConfigVadj_C;
                elsif (PrSv_AdcState_s = "0011") then 
                    PrSv_AdcConfigData_s <= PrSv_ConfigVadj_C;
                end if;

            when "001" => -- Config 3V3
                if (PrSv_AdcState_s = "0001") then 
                    PrSv_AdcConfigData_s <= PrSv_Config3V3_c;
                elsif (PrSv_AdcState_s = "0011") then 
                    PrSv_AdcConfigData_s <= PrSv_Config3V3_c;
                end if;
            when "010" => -- Config 2V5
                if (PrSv_AdcState_s = "0001") then 
                    PrSv_AdcConfigData_s <= PrSv_Config2V5_c;
                elsif (PrSv_AdcState_s = "0011") then 
                    PrSv_AdcConfigData_s <= PrSv_Config2V5_c;
                end if;
            when "011" => -- Config 1V5
                if (PrSv_AdcState_s = "0001") then 
                    PrSv_AdcConfigData_s <= PrSv_Config1V5_c;
                elsif (PrSv_AdcState_s = "0011") then 
                    PrSv_AdcConfigData_s <= PrSv_Config1V5_c;
                end if;
            when others => 
                PrSv_AdcConfigData_s <= (others => '0');
        end case;
        end if;
    end process;

    -- ADC State Machine
    process (CpSl_Rst_iN, CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then
            PrSv_AdcState_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
        case PrSv_AdcState_s is 
            when "0000" => -- ADC Current Start Trig
                if (PrSl_CurtCapTrig_s = '1') then 
                    PrSv_AdcState_s <= "0001";
                else
                end if;
                
            when "0001" => -- ADC Start
                if (PrSv_AdcStart_s = PrSv_AdcStart_c) then 
                    PrSv_AdcState_s <= "0010";
                else -- hold
                end if;
                    
            when "0010" => -- ADC Config Command Data
                if (PrSv_AdcConfigCmdNum_s = 16 and PrSl_AdcSclkNum_s = 99) then 
                    PrSv_AdcState_s <= "0011";
                else
                end if;

            when "0011" =>  -- ADC Confige End
                if (PrSv_AdcConfigEnd_s = PrSv_AdcStart_c) then
					PrSv_AdcState_s <= "0100";
                else -- hold
                end if;

            when "0100" => -- Config Reg data
                if (PrSv_AdcConfigNum_s = 16 and PrSl_AdcSclkNum_s = 99) then 
                    PrSv_AdcState_s <= "0101";
                else -- hold
                end if;
                
            when "0101" => -- ADC Reset SPI interface
                if (PrSv_AdcRst_s = PrSv_AdcWait_c) then
                    PrSv_AdcState_s <= "0110";
                else -- hold
                end if;

            when "0110" => -- wait ADC Ready
                if (CpSl_CurtAdcData_i = '0') then 
                    PrSv_AdcState_s <= "0111";
                else
                end if;
                    
            when "0111" => -- Wait 8us 
                if (PrSv_AdcWait_s = PrSv_AdcWait_c) then 
                    PrSv_AdcState_s <= "1000";
                else 
                end if;
                    
            when "1000" => -- ADS1018 Data 
                if (PrSv_AdcRecNum_s = 16 and PrSl_AdcSclkNum_s = 99) then 
                    PrSv_AdcState_s <= "1001";
                else 
                end if;

            when "1001" => -- ADS1018 Stop 
                if (PrSv_AdcStop_s = PrSv_AdcStop_c) then 
                    PrSv_AdcState_s <= "1010";
                else 
                end if;

            when "1010" => -- ADS1018 End
                if (PrSv_CapCurtNum_s = 4) then
                    PrSv_AdcState_s <= "0000";
                else
                    PrSv_AdcState_s <= "1011";
                end if;

            when "1011" => -- Delay CS High
                if (PrSv_AdcEnd_s = PrSv_AdcWait_c) then
                    PrSv_AdcState_s <= "0001";
                else
                end if;
            
            when others =>
                PrSv_AdcState_s <= (others => '0');

        end case;
        end if;
    end process;
    
    
    -- ADS1018 Capture Voltage 
    -- PrSv_AdcStart_s
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then 
            PrSv_AdcStart_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then 
            if (PrSv_AdcState_s = "0001") then
                if (PrSv_AdcStart_s = PrSv_AdcStart_c) then 
                    PrSv_AdcStart_s <= (others => '0');
                else
                    PrSv_AdcStart_s <= PrSv_AdcStart_s + '1';
                end if;
            else
                PrSv_AdcStart_s <= (others => '0');
            end if;
        end if;
    end process;
    
    -- PrSv_AdcConfigEnd_s
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then 
            PrSv_AdcConfigEnd_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then 
            if (PrSv_AdcState_s = "0011") then
                if (PrSv_AdcConfigEnd_s = PrSv_AdcStart_c) then 
                    PrSv_AdcConfigEnd_s <= (others => '0');
                else
                    PrSv_AdcConfigEnd_s <= PrSv_AdcConfigEnd_s + '1';
                end if;
            else
                PrSv_AdcConfigEnd_s <= (others => '0');
            end if;
        end if;
    end process;
    
    -- PrSv_AdcRst_s
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then 
            PrSv_AdcRst_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then 
            if (PrSv_AdcState_s = "0101") then
                if (PrSv_AdcRst_s = PrSv_AdcWait_c) then 
                    PrSv_AdcRst_s <= (others => '0');
                else
                    PrSv_AdcRst_s <= PrSv_AdcRst_s + '1';
                end if;
            else
                PrSv_AdcRst_s <= (others => '0');
            end if;
        end if;
    end process;
    
    -- PrSv_AdcWait_s
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then 
            PrSv_AdcWait_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then 
            if (PrSv_AdcState_s = "0111") then
                if (PrSv_AdcWait_s = PrSv_AdcWait_c) then 
                    PrSv_AdcWait_s <= (others => '0');
                else
                    PrSv_AdcWait_s <= PrSv_AdcWait_s + '1';
                end if;
            else
                PrSv_AdcWait_s <= (others => '0');
            end if;
        end if;
    end process;
    
    -- PrSv_AdcStop_s
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then 
            PrSv_AdcStop_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then 
            if (PrSv_AdcState_s = "1001") then
                if (PrSv_AdcStop_s = PrSv_AdcStop_c) then 
                    PrSv_AdcStop_s <= (others => '0');
                else
                    PrSv_AdcStop_s <= PrSv_AdcStop_s + '1';
                end if;
            else
                PrSv_AdcStop_s <= (others => '0');
            end if;
        end if;
    end process;
    
    -- PrSv_AdcEnd_s
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then 
            PrSv_AdcEnd_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then 
            if (PrSv_AdcState_s = "1011") then
                if (PrSv_AdcEnd_s = PrSv_AdcWait_c) then 
                    PrSv_AdcEnd_s <= (others => '0');
                else
                    PrSv_AdcEnd_s <= PrSv_AdcEnd_s + '1';
                end if;
            else
                PrSv_AdcEnd_s <= (others => '0');
            end if;
        end if;
    end process;
    
    -- CpSl_CurtAdcCS_o
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            CpSl_CurtAdcCS_o <= '1';
         elsif rising_edge(CpSl_Clk_i) then
            if (PrSv_AdcState_s = "0001") then
                CpSl_CurtAdcCS_o <= '0';
            elsif (PrSv_AdcState_s = "1010") then
                CpSl_CurtAdcCS_o <= '1';
            else -- hold
            end if;
        end if;
    end process;

    -- ADC CpSl_CurtAdcClk_o
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then 
            PrSl_AdcSclkNum_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then 
            if (PrSv_AdcState_s = "0010" or PrSv_AdcState_s = "0100" or PrSv_AdcState_s = "1000") then 
                if (PrSl_AdcSclkNum_s = 99) then 
                    PrSl_AdcSclkNum_s <= (others => '0');
                else 
                    PrSl_AdcSclkNum_s <= PrSl_AdcSclkNum_s + '1';
                end if;
            else 
                PrSl_AdcSclkNum_s <= (others => '0');
            end if;
        end if;
    end process; 
    
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then 
            PrSl_AdcSclk_s <= '0';
        elsif rising_edge(CpSl_Clk_i) then 
            if (PrSv_AdcState_s = "0010" or PrSv_AdcState_s = "0100" or PrSv_AdcState_s = "1000") then 
                if (PrSl_AdcSclkNum_s = 50) then 
                    PrSl_AdcSclk_s <= '1';
                elsif (PrSl_AdcSclkNum_s = 99) then 
                    PrSl_AdcSclk_s <= '0';
                else -- hold
                end if;
            else 
                PrSl_AdcSclk_s <= '0';
            end if;
        end if;
    end process; 
    -- CpSl_CurtAdcClk_o
    CpSl_CurtAdcClk_o <= PrSl_AdcSclk_s;

    -- PrSv_AdcConfigCmdNum_s
    process (CpSl_Rst_iN, PrSl_AdcSclk_s) begin
        if (CpSl_Rst_iN = '0') then 
            PrSv_AdcConfigCmdNum_s <= (others => '0');
        elsif rising_edge(PrSl_AdcSclk_s) then 
            if (PrSv_AdcState_s = "0010") then
                if (PrSv_AdcConfigCmdNum_s = 16) then 
                    PrSv_AdcConfigCmdNum_s <= (others => '0');
                else
                    PrSv_AdcConfigCmdNum_s <= PrSv_AdcConfigCmdNum_s + '1';
                end if;
            else
                PrSv_AdcConfigCmdNum_s <= (others => '0');
            end if;
        end if;
    end process;
    
    process (CpSl_Rst_iN, PrSl_AdcSclk_s) begin 
        if (CpSl_Rst_iN = '0') then 
            PrSl_AdcConfigCmd_s <= '0';
        elsif rising_edge(PrSl_AdcSclk_s) then
            if (PrSv_AdcState_s = "0010") then 
                case PrSv_AdcConfigCmdNum_s is 
                    when "00000" => PrSl_AdcConfigCmd_s <= PrSv_AdcConfigData_s(15);
                    when "00001" => PrSl_AdcConfigCmd_s <= PrSv_AdcConfigData_s(14);
                    when "00010" => PrSl_AdcConfigCmd_s <= PrSv_AdcConfigData_s(13);
                    when "00011" => PrSl_AdcConfigCmd_s <= PrSv_AdcConfigData_s(12);    
                    when "00100" => PrSl_AdcConfigCmd_s <= PrSv_AdcConfigData_s(11);
                    when "00101" => PrSl_AdcConfigCmd_s <= PrSv_AdcConfigData_s(10);
                    when "00110" => PrSl_AdcConfigCmd_s <= PrSv_AdcConfigData_s(9);
                    when "00111" => PrSl_AdcConfigCmd_s <= PrSv_AdcConfigData_s(8);
                    when "01000" => PrSl_AdcConfigCmd_s <= PrSv_AdcConfigData_s(7);    
                    when "01001" => PrSl_AdcConfigCmd_s <= PrSv_AdcConfigData_s(6);
                    when "01010" => PrSl_AdcConfigCmd_s <= PrSv_AdcConfigData_s(5);
                    when "01011" => PrSl_AdcConfigCmd_s <= PrSv_AdcConfigData_s(4);
                    when "01100" => PrSl_AdcConfigCmd_s <= PrSv_AdcConfigData_s(3);
                    when "01101" => PrSl_AdcConfigCmd_s <= PrSv_AdcConfigData_s(2);    
                    when "01110" => PrSl_AdcConfigCmd_s <= PrSv_AdcConfigData_s(1);    
                    when "01111" => PrSl_AdcConfigCmd_s <= PrSv_AdcConfigData_s(0);
                    when  others => PrSl_AdcConfigCmd_s <= '0';
                end case;
            else
                PrSl_AdcConfigCmd_s <= '0';
            end if;
        end if;
    end process;

    -- PrSv_AdcConfigNum_s
    process (CpSl_Rst_iN, PrSl_AdcSclk_s) begin
        if (CpSl_Rst_iN = '0') then 
            PrSv_AdcConfigNum_s <= (others => '0');
        elsif rising_edge(PrSl_AdcSclk_s) then 
            if (PrSv_AdcState_s = "0100") then
                if (PrSv_AdcConfigNum_s = 16) then 
                    PrSv_AdcConfigNum_s <= (others => '0');
                else
                    PrSv_AdcConfigNum_s <= PrSv_AdcConfigNum_s + '1';
                end if;
            else
                PrSv_AdcConfigNum_s <= (others => '0');
            end if;
        end if;
    end process;
    
    process (CpSl_Rst_iN, PrSl_AdcSclk_s) begin 
        if (CpSl_Rst_iN = '0') then 
            PrSl_AdcConfig_s <= '0';
        elsif rising_edge(PrSl_AdcSclk_s) then
            if (PrSv_AdcState_s = "0100") then 
                case PrSv_AdcConfigNum_s is 
                    when "00000" => PrSl_AdcConfig_s <= PrSv_AdcConfigData_s(15);
                    when "00001" => PrSl_AdcConfig_s <= PrSv_AdcConfigData_s(14);
                    when "00010" => PrSl_AdcConfig_s <= PrSv_AdcConfigData_s(13);
                    when "00011" => PrSl_AdcConfig_s <= PrSv_AdcConfigData_s(12);    
                    when "00100" => PrSl_AdcConfig_s <= PrSv_AdcConfigData_s(11);
                    when "00101" => PrSl_AdcConfig_s <= PrSv_AdcConfigData_s(10);
                    when "00110" => PrSl_AdcConfig_s <= PrSv_AdcConfigData_s(9);
                    when "00111" => PrSl_AdcConfig_s <= PrSv_AdcConfigData_s(8);
                    when "01000" => PrSl_AdcConfig_s <= PrSv_AdcConfigData_s(7);    
                    when "01001" => PrSl_AdcConfig_s <= PrSv_AdcConfigData_s(6);
                    when "01010" => PrSl_AdcConfig_s <= PrSv_AdcConfigData_s(5);
                    when "01011" => PrSl_AdcConfig_s <= PrSv_AdcConfigData_s(4);
                    when "01100" => PrSl_AdcConfig_s <= PrSv_AdcConfigData_s(3);
                    when "01101" => PrSl_AdcConfig_s <= PrSv_AdcConfigData_s(2);    
                    when "01110" => PrSl_AdcConfig_s <= PrSv_AdcConfigData_s(1);    
                    when "01111" => PrSl_AdcConfig_s <= PrSv_AdcConfigData_s(0);
                    when  others => PrSl_AdcConfig_s <= '0';
                end case;
            else
                PrSl_AdcConfig_s <= '0';
            end if;
        end if;
    end process;
    
    -- CpSl_AdcConfigData_o
    process (CpSl_Rst_iN, CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            CpSl_CurtAdcConfigData_o <= '0';
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSv_AdcState_s = "0010") then 
                CpSl_CurtAdcConfigData_o <= PrSl_AdcConfigCmd_s;
            elsif (PrSv_AdcState_s = "0100") then 
                CpSl_CurtAdcConfigData_o <= PrSl_AdcConfig_s;
            else
                CpSl_CurtAdcConfigData_o <= '0';
            end if;
        end if;
    end process;
    
    -- Ready Data
    process (CpSl_Rst_iN,PrSl_AdcSclk_s) begin 
        if (CpSl_Rst_iN = '0') then
             PrSv_AdcRecNum_s <= (others => '0');
        elsif rising_edge(PrSl_AdcSclk_s) then 
            if (PrSv_AdcState_s = "1000") then 
                if (PrSv_AdcRecNum_s = 16) then
                    PrSv_AdcRecNum_s <= (others => '0');
                else
                    PrSv_AdcRecNum_s <= PrSv_AdcRecNum_s + '1'; 
                end if;
            else
                PrSv_AdcRecNum_s <= (others => '0');
            end if;
        end if;
    end process;
    
    -- ADC Data 
    process (CpSl_Rst_iN,CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then
            PrSv_AdcDin_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSv_AdcState_s = "1000" and PrSl_AdcSclkNum_s = 74) then 
                PrSv_AdcDin_s <= PrSv_AdcDin_s(14 downto 0) & CpSl_CurtAdcData_i;
            else
            end if;
        end if; 
    end process;
    
    -- Adc End Data
    process (CpSl_Rst_iN,CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then 
            PrSv_AdcCurtVadj_s  <= (others => '0');
            PrSv_AdcCurt3V3_s   <= (others => '0');                
            PrSv_AdcCurt2V5_s   <= (others => '0');             
            PrSv_AdcCurt1V5_s   <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then 
            case PrSv_CapCurtNum_s is 
            when "000" => -- Capture Vadj_A
                if (PrSv_AdcState_s = "1001" and PrSv_AdcStop_s = PrSv_AdcStop_c - 50) then 
                    PrSv_AdcCurtVadj_s <= PrSv_AdcDin_s(15 downto 4);
                else
                end if;
                    
            when "001" => -- Capture 3V3_A
                if (PrSv_AdcState_s = "1001" and PrSv_AdcStop_s = PrSv_AdcStop_c - 50) then 
                    PrSv_AdcCurt3V3_s <= PrSv_AdcDin_s(15 downto 4);
                else
                end if;
                    
            when "010" => -- Capture 2V5_A
                if (PrSv_AdcState_s = "1001" and PrSv_AdcStop_s = PrSv_AdcStop_c - 50) then 
                    PrSv_AdcCurt2V5_s <= PrSv_AdcDin_s(15 downto 4);
                else
                end if;

            when "011" => -- Capture 1V5_A
                if (PrSv_AdcState_s = "1001" and PrSv_AdcStop_s = PrSv_AdcStop_c - 50) then 
                    PrSv_AdcCurt1V5_s <= PrSv_AdcDin_s(15 downto 4);
                else
                end if;

            when others => 
                PrSv_AdcCurtVadj_s  <= PrSv_AdcCurtVadj_s;
                PrSv_AdcCurt3V3_s   <= PrSv_AdcCurt3V3_s ;                
                PrSv_AdcCurt2V5_s   <= PrSv_AdcCurt2V5_s ;             
                PrSv_AdcCurt1V5_s   <= PrSv_AdcCurt1V5_s ;
        end case;
        end if;
    end process;

    ------------------------------------
    -- Compare Current 
    ------------------------------------
    process (CpSl_Rst_iN,CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then
            PrSv_CmpState_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then 
        case PrSv_CmpState_s is 
            when "000" => -- Current Data
                if (CpSl_CurtDvld_i = '1') then 
                    PrSv_CmpState_s <= "001";
                else 
                end if;

            when "001" => -- Compare Trig
                if (PrSl_CurtCmptrig_s = '1') then 
                    PrSv_CmpState_s <= "010";
                else --hold
                end if;

            when "010" => -- ADC Cpature Data End
                if (PrSv_CapCurtNum_s = 4) then 
                    PrSv_CmpState_s <= "011";
                else
                end if;
                    
            when "011" => -- Compare Current
                if (PrSv_Cnt1us_s = PrSv_Cnt1us_c) then 
                    PrSv_CmpState_s <= "100";
                else
                end if;
            when "100" => -- Current CyCle
                if (PrSv_CurtData_s /= PrSv_VccError_c) then 
                    PrSv_CmpState_s <= "110";
                else
                    PrSv_CmpState_s <= "101";
                end if;
                    
            when "101" => -- Ccompare error
                PrSv_CmpState_s <= "000";
                
            when "110" => -- Ccompare right
                PrSv_CmpState_s <= "001";
                
            when others => 
                PrSv_CmpState_s <= (others => '0');        
                
        end case;
        end if;
    end process;

    -- 1us
    process (CpSl_Rst_iN,CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then 
            PrSv_Cnt1us_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSv_CmpState_s = "011") then 
                if (PrSv_Cnt1us_s = PrSv_Cnt1us_c) then 
                    PrSv_Cnt1us_s <= (others => '0');
                else 
                    PrSv_Cnt1us_s <= PrSv_Cnt1us_s + '1';
                end if;
            else
                PrSv_Cnt1us_s <= (others => '0');
            end if;
        end if;
    end process;
    
    -- Head Indication
    process (CpSl_Rst_iN,CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then 
            PrSv_TestBoard_s <= "000";
        elsif rising_edge(CpSl_Clk_i) then
        case PrSv_Head_s is 
            when x"C1" => 
                PrSv_TestBoard_s <= PrSv_SelfFpga_c;
            when x"C2" => 
                PrSv_TestBoard_s <= PrSv_A1000Fpga_c;
            when x"C3" => 
                PrSv_TestBoard_s <= PrSv_A500Fpga_c;
            when x"C4" => 
                if (PrSv_Curt3v3_s = x"EFFE" and PrSv_Curt1v5_s = x"EFFE") then 
                    PrSv_TestBoard_s <= PrSv_A54SFpga0_c;
                elsif (PrSv_Curt3v3_s = x"CDDC" and PrSv_Curt1v5_s = x"CDDC") then 
                    PrSv_TestBoard_s <= PrSv_A54SFpga1_c;
                end if;

            when others => 
                PrSv_TestBoard_s <= "000";
        end case;
        end if;
    end process;
    
    -- Compare Current
    process (CpSl_Rst_iN,CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then
            PrSv_CurtResult_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then 
            case PrSv_TestBoard_s is 
                when "001" => -- Self Board
                    if (PrSv_CmpState_s = "011" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 59) then 
                        -- 3V3
                        if (PrSv_AdcCurt3V3_s > 0 and
                            PrSv_AdcCurt3V3_s < PrSv_Curt3v3_s + PrSv_CurtRang_c) then 
                            PrSv_CurtResult_s(2) <= '1';
                        else
                            PrSv_CurtResult_s(2) <= '0';
                        end if;
                            PrSv_CurtResult_s(3) <= '0';
                            PrSv_CurtResult_s(1) <= '0';
                            PrSv_CurtResult_s(0) <= '0';
                    else
                    end if;
                when "010" => -- A1000
                    if (PrSv_CmpState_s = "011" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 59) then 
                        -- Vadj
                        if (PrSv_AdcCurtVadj_s > 0 and
                            PrSv_AdcCurtVadj_s < PrSv_CurtVadj_s + PrSv_CurtRang_c) then 
                            PrSv_CurtResult_s(3) <= '1';
                        else
                            PrSv_CurtResult_s(3) <= '0';
                        end if;
                            
                        -- 3V3
                        if (PrSv_AdcCurt3V3_s > 0 and
                            PrSv_AdcCurt3V3_s < PrSv_Curt3v3_s + PrSv_CurtRang_c) then 
                            PrSv_CurtResult_s(2) <= '1';
                        else
                            PrSv_CurtResult_s(2) <= '0';
                        end if;
                        
                        -- 1V5
                        if (PrSv_AdcCurt1V5_s > 0 and
                            PrSv_AdcCurt1V5_s < PrSv_Curt1v5_s + PrSv_CurtRang_c) then 
                            PrSv_CurtResult_s(0) <= '1';
                        else
                            PrSv_CurtResult_s(0) <= '0';
                        end if;
                            PrSv_CurtResult_s(1) <= '0';
                    else
                    end if;
                when "011" => -- A500
                    if (PrSv_CmpState_s = "011" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 59) then 
                        -- Vadj
                        if (PrSv_AdcCurtVadj_s > 0 and
                            PrSv_AdcCurtVadj_s < PrSv_CurtVadj_s + PrSv_CurtRang_c) then 
                            PrSv_CurtResult_s(3) <= '1';
                        else
                            PrSv_CurtResult_s(3) <= '0';
                        end if;
                            
                        -- 3V3
                        if (PrSv_AdcCurt3V3_s > 0 and
                            PrSv_AdcCurt3V3_s < PrSv_Curt3v3_s + PrSv_CurtRang_c) then 
                            PrSv_CurtResult_s(2) <= '1';
                        else
                            PrSv_CurtResult_s(2) <= '0';
                        end if;
                        
                        -- 1V5
                        if (PrSv_AdcCurt1V5_s > 0 and
                            PrSv_AdcCurt1V5_s < PrSv_Curt1v5_s + PrSv_CurtRang_c) then 
                            PrSv_CurtResult_s(0) <= '1';
                        else
                            PrSv_CurtResult_s(0) <= '0';
                        end if;
                            PrSv_CurtResult_s(1) <= '0';
                    else
                    end if;
                when "100" => -- A54S_0
                    if (PrSv_CmpState_s = "011" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 59) then 
                        -- Vadj
                        if (PrSv_AdcCurtVadj_s > 0 and
                            PrSv_AdcCurtVadj_s < PrSv_CurtVadj_s + PrSv_CurtRang_c) then 
                            PrSv_CurtResult_s(3) <= '1';
                        else
                            PrSv_CurtResult_s(3) <= '0';
                        end if;
                        
                        -- 2V5
                        if (PrSv_AdcCurt2V5_s > 0 and
                            PrSv_AdcCurt2V5_s < PrSv_Curt2v5_s + PrSv_CurtRang_c) then 
                            PrSv_CurtResult_s(1) <= '1';
                        else
                            PrSv_CurtResult_s(1) <= '0';
                        end if;
                            PrSv_CurtResult_s(2) <= '0';
                            PrSv_CurtResult_s(0) <= '0';
                    else
                    end if;
                when "101" => -- A54S_1
                    if (PrSv_CmpState_s = "011" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 59) then 
                        -- Vadj
                        if (PrSv_AdcCurtVadj_s > 0 and
                            PrSv_AdcCurtVadj_s < PrSv_CurtVadj_s + PrSv_CurtRang_c) then 
                            PrSv_CurtResult_s(3) <= '1';
                        else
                            PrSv_CurtResult_s(3) <= '0';
                        end if;
                        
                        -- 2V5
                        if (PrSv_AdcCurt2V5_s > 0 and
                            PrSv_AdcCurt2V5_s < PrSv_Curt2v5_s + PrSv_CurtRang_c) then 
                            PrSv_CurtResult_s(1) <= '1';
                        else
                            PrSv_CurtResult_s(1) <= '0';
                        end if;
                            PrSv_CurtResult_s(2) <= '0';
                            PrSv_CurtResult_s(0) <= '0';
                    else
                    end if;
                when others => PrSv_CurtResult_s <= (others => '0');
            end case;
        end if;
    end process;
    
    -- Compare Current Result
    process (CpSl_Rst_iN,CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_CmpCurtResult_s <= (others => '0');
            PrSv_CurtData_s     <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then 
        case PrSv_TestBoard_s is
            when "001" => -- SelfBoard
                if (PrSv_CmpState_s = "011" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 55) then 
                    if (PrSv_CurtResult_s = PrSv_SelfFpgaVcc_c) then 
                        PrSv_CmpCurtResult_s <= PrSv_SelfFpgaVcc_c;
                        PrSv_CurtData_s     <= PrSv_SelfFpgaVcc_c;
                    else
                        PrSv_CmpCurtResult_s <= PrSv_CurtResult_s;
                        PrSv_CurtData_s     <= PrSv_VccError_c;
                    end if;
                else
                end if;
            when "010" => -- A1000
                if (PrSv_CmpState_s = "011" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 55) then 
                    if (PrSv_CurtResult_s = PrSv_A1000FpgaVcc_c) then 
                        PrSv_CmpCurtResult_s <= PrSv_A1000FpgaVcc_c;
                        PrSv_CurtData_s     <= PrSv_A1000FpgaVcc_c;
                    else
                        PrSv_CmpCurtResult_s <= PrSv_CurtResult_s;
                        PrSv_CurtData_s     <= PrSv_VccError_c;
                    end if;
                else
                end if;
            when "011" => -- A500
                if (PrSv_CmpState_s = "011" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 55) then 
                    if (PrSv_CurtResult_s = PrSv_A500FpgaVcc_c) then 
                        PrSv_CmpCurtResult_s <= PrSv_A500FpgaVcc_c;
                        PrSv_CurtData_s     <= PrSv_A500FpgaVcc_c;
                    else
                        PrSv_CmpCurtResult_s <= PrSv_CurtResult_s;
                        PrSv_CurtData_s     <= PrSv_VccError_c;
                    end if;
                else
                end if;
            when "100" => -- A54S_0
                if (PrSv_CmpState_s = "011" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 55) then 
                    if (PrSv_CurtResult_s = PrSv_A54SFpga0Vcc_c) then 
                        PrSv_CmpCurtResult_s <= PrSv_A54SFpga0Vcc_c;
                        PrSv_CurtData_s     <= PrSv_A54SFpga0Vcc_c;
                    else
                        PrSv_CmpCurtResult_s <= PrSv_CurtResult_s;
                        PrSv_CurtData_s     <= PrSv_VccError_c;
                    end if;
                else
                end if;
            when "101" => -- A54S_1
                if (PrSv_CmpState_s = "011" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 55) then 
                    if (PrSv_CurtResult_s = PrSv_A54SFpga1Vcc_c) then 
                        PrSv_CmpCurtResult_s <= PrSv_A54SFpga1Vcc_c;
                        PrSv_CurtData_s     <= PrSv_A54SFpga1Vcc_c;
                    else
                        PrSv_CmpCurtResult_s <= PrSv_CurtResult_s;
                        PrSv_CurtData_s     <= PrSv_VccError_c;
                    end if;
                else
                end if;
            when others => 
                PrSv_CmpCurtResult_s <= (others => '0');
                PrSv_CurtData_s     <= (others => '0');
        end case;
        end if;
    end process;
    
    -- Generate right Indication
    process (CpSl_Rst_iN,CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            PrSv_CmpInd_s <= '0';
        elsif rising_edge(CpSl_Clk_i) then 
            if (PrSv_CmpState_s = "101") then 
                PrSv_CmpInd_s <= '0';
            elsif (PrSv_CmpState_s = "110") then 
                PrSv_CmpInd_s <= '1';
            else --hold
            end if;
        end if;
    end process;

    -- PrSv_CmpIndCnt_s
    process (CpSl_Rst_iN,CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            PrSv_CmpIndCnt_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            if (CpSl_CurtDvld_i = '1') then 
                PrSv_CmpIndCnt_s <= (others => '0');
            elsif (PrSv_CmpInd_s = '1') then 
                if (PrSv_CmpIndCnt_s = PrSv_Cnt1us_c) then 
                    PrSv_CmpIndCnt_s <= PrSv_Cnt1us_c;
                else
                    PrSv_CmpIndCnt_s <= PrSv_CmpIndCnt_s + '1';
                end if;
            else
                PrSv_CmpIndCnt_s <= (others => '0');
            end if;
        end if;
    end process;
    
    -- PrSl_CmpIndTrig_s
    process (CpSl_Rst_iN,CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            PrSl_CmpIndTrig_s <= '0';
        elsif rising_edge(CpSl_Clk_i) then 
            if (PrSv_CmpInd_s = '1') then 
                if (PrSv_CmpIndCnt_s = PrSv_Cnt1us_c - 10) then 
                    PrSl_CmpIndTrig_s <= '1';
                else
                    PrSl_CmpIndTrig_s <= '0';
                end if;
            else
                PrSl_CmpIndTrig_s <= '0';
            end if;
        end if;
    end process;
    
    -- CpSl_CmpInd_o
    process (CpSl_Rst_iN,CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            CpSl_CmpInd_o <= '0';
        elsif rising_edge(CpSl_Clk_i) then
            if(PrSv_CmpState_s = "101") then 
               CpSl_CmpInd_o <= '1';
            else
                CpSl_CmpInd_o <= '0';
            end if;
        end if;
    end process;
    
    -- Valid & Voltage Data
    process (CpSl_Rst_iN,CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            CpSl_CmpCurtVld_o <= '0';
        elsif rising_edge(CpSl_Clk_i) then 
            if(PrSv_CmpState_s = "101") then 
                CpSl_CmpCurtVld_o <= '1';
            elsif (PrSl_CmpIndTrig_s = '1') then 
                CpSl_CmpCurtVld_o <= '1';
            else
                CpSl_CmpCurtVld_o <= '0';
            end if;
        end if;
    end process;
    
    process (CpSl_Rst_iN,CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            CpSv_CmpCurtData_o <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            if(PrSv_CmpState_s = "101") then 
                CpSv_CmpCurtData_o <= PrSv_TestBoard_s & x"0" & PrSv_CmpCurtResult_s;
            elsif (PrSl_CmpIndTrig_s = '1') then 
                CpSv_CmpCurtData_o <= PrSv_TestBoard_s & x"0" & PrSv_CmpCurtResult_s;
            else
            end if;
        end if;
    end process;

end arch_M_CmparCurt;