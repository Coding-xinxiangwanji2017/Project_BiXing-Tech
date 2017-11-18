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
-- ��    Ȩ  :  BiXing-Tech
-- �ļ�����  :  M_CmparVol.vhd
-- ��    ��  :  Zhang Wenjun
-- ��    ��  :  wenjunzhang@bixing-tech.com
-- У    ��  :
-- ��������  :  2017/07/10
-- ���ܼ���  :  compare voltage,ADS1108 capture voltage(��150mv)
-- �汾����  :  0.1
-- �޸���ʷ  :  1. Initial, Zhang Wenjun, 2017/07/10
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity M_CmparVol is
    port (
        --------------------------------
        -- Reset and Clock
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      : in  std_logic;                        -- 100MHz Clock,single

        --------------------------------
        -- Receive Standard Voltage
        --------------------------------
        CpSl_VolDVld_i                  : in  std_logic;                        -- Voltage Parallel data valid
        CpSv_VolData_i                  : in  std_logic_vector(71 downto 0);    -- Voltage Parallel data

        --------------------------------
        -- Receive FPGA Type
        --------------------------------
        CpSl_FpgaVld_i                  : in  std_logic;                        -- FPGA Style Valid

        --------------------------------
        -- Current Compare Reault
        --------------------------------
        CpSl_CmpInd_i                   : in  std_logic;                        -- Compare Current Result
        
        --------------------------------
        -- ADC Voltage Interface
        --------------------------------
        CpSl_AdcSclk_o                  : out std_logic;                        -- ADC Clock
        CpSl_AdcCS_o                    : out std_logic;                        -- ADC CS_U122
        CpSl_AdcCS1_o                   : out std_logic;                        -- ADC CS_U123
        CpSl_AdcConfigData_o            : out std_logic;                        -- ADC Configuration Data
        CpSl_AdcData_i                  : in  std_logic;                        -- U122 & U123 Chip ADC Transfer Data

        --------------------------------
        -- Compare Voltage Result
        --------------------------------
        CpSv_RelayVol_o                 : out std_logic_vector( 3 downto 0);    -- Control voltage Relay(5V/3.3V/2.5V/1.5V)
        CpSv_VoltageResult_o            : out std_logic_vector( 6 downto 0);    -- Compare Voltage for current used
        CpSl_CmpVolVld_o                : out std_logic;                        -- Copmare Voltage Valid
        CpSv_CmpVolData_o               : out std_logic_vector(10 downto 0)     -- Copmare Voltage Valid Data
    );
end M_CmparVol;

architecture arch_M_CmparVol of M_CmparVol is
    ----------------------------------------------------------------------------
    -- constant declaration
    ----------------------------------------------------------------------------
    ------------------------------------
    -- Voltage_5V  : Adc_v = PC_V*1000/3
    -- Voltage_3v3 : Adc_v = PC_V*500
    -- Voltage_2V5 : Adc_v = PC_V*500
    -- Voltage_1V5 : Adc_v = PC_V*500
    ------------------------------------
    -- Board Indication
    constant PrSv_SelfFpga_c            : std_logic_vector( 2 downto 0) := "001";   -- Self Check Board
    constant PrSv_A1000Fpga_c           : std_logic_vector( 2 downto 0) := "010";   -- A1000 Board
    constant PrSv_A500Fpga_c            : std_logic_vector( 2 downto 0) := "011";   -- A500 Board
    constant PrSv_A54SFpga0_c           : std_logic_vector( 2 downto 0) := "100";   -- A54S Board Test first Vcc
    constant PrSv_A54SFpga1_c           : std_logic_vector( 2 downto 0) := "101";   -- A54S Board Test Second Vcc

    -- Board Head
    constant PrSv_SelfFpgaHead_c        : std_logic_vector( 7 downto 0) := x"C1";   -- Self Check Board Head
    constant PrSv_A1000FpgaHead_c       : std_logic_vector( 7 downto 0) := x"C2";   -- A1000 Board Head
    constant PrSv_A500FpgaHead_c        : std_logic_vector( 7 downto 0) := x"C3";   -- A500 Board Head
    constant PrSv_A54SFpgaHead_c        : std_logic_vector( 7 downto 0) := x"C4";   -- A54S Board Head

    -- Vcc ---> Test Board (5V/3V3/2V5/1V5)
    constant PrSv_VccError_c            : std_logic_vector( 3 downto 0) := "0000";  -- Test Vcc Error
    constant PrSv_SelfFpgaVcc_c         : std_logic_vector( 3 downto 0) := "1111";  -- Self Check Board Vcc
    constant PrSv_A1000FpgaVcc_c        : std_logic_vector( 3 downto 0) := "0101";  -- A1000 Board Vcc
    constant PrSv_A500FpgaVcc_c         : std_logic_vector( 3 downto 0) := "0101";  -- A500 Board Vcc
    constant PrSv_A54SFpga0Vcc_c        : std_logic_vector( 3 downto 0) := "0110";  -- A54S Board Test first Vcc
    constant PrSv_A54SFpga1Vcc_c        : std_logic_vector( 3 downto 0) := "1010";  -- A54S Board Test Second Vcc

    -- ADC Configure Data
    constant PrSv_ConfigRedCmd_c        : std_logic_vector(15 downto 0) := x"0000"; -- Read Command
    constant PrSv_Config5V_c            : std_logic_vector(15 downto 0) := x"F58B"; -- ADC_5V (U123)
    constant PrSv_Config3V3_c           : std_logic_vector(15 downto 0) := x"D58B"; -- ADC_3V3(122)
    constant PrSv_Config2V5_c           : std_logic_vector(15 downto 0) := x"F58B"; -- ADC_2V5(122)
    constant PrSv_Config1V5_c           : std_logic_vector(15 downto 0) := x"E58B"; -- ADC_1V5(122)

    -- Relay Start Count
    constant PrSv_Cnt1us_c              : std_logic_vector( 7 downto 0) := x"63";   -- 1us

    -- Voltage Range
    constant PrSv_VolRang_c             : std_logic_vector(15 downto 0) := x"0096";  -- 150mv

    -- ADC constant
    constant PrSv_AdcVolStartCap_c      : std_logic_vector(27 downto 0) := x"2FAF07F"; -- MPS Start 500 ms
    constant PrSv_AdcVolRelay_c         : std_logic_vector(19 downto 0) := x"F423F"; -- ADC Voltage Ctrl Relay Delay 10 ms
    constant PrSv_AdcStart_c            : std_logic_vector(15 downto 0) := x"1381"; -- ADC Start Count 50 us
    constant PrSv_AdcWait_c             : std_logic_vector(15 downto 0) := x"03E7"; -- ADC wait count 10 us
    constant PrSv_AdcStop_c             : std_logic_vector(15 downto 0) := x"1381"; -- ADC Stop count 50 us

    ----------------------------------------------------------------------------
    -- signal declaration
    ----------------------------------------------------------------------------
    -- Voltage Base Data
    signal PrSv_Head_s                  : std_logic_vector( 7 downto 0);        -- Recive FPGA Type
    signal PrSv_Vol5v_s                 : std_logic_vector(15 downto 0);        -- Recive Voltage 5V
    signal PrSv_Vol3v3_s                : std_logic_vector(15 downto 0);        -- Recive Voltage 3V3
    signal PrSv_Vol2v5_s                : std_logic_vector(15 downto 0);        -- Recive Voltage 2V5
    signal PrSv_Vol1v5_s                : std_logic_vector(15 downto 0);        -- Recive Voltage 1V5

    signal PrSl_VolDVldDly1_s           : std_logic;                            -- Delay CpSl_VolDVld_i 1 Clk
    signal PrSl_VolDVldDly2_s           : std_logic;                            -- Delay CpSl_VolDVld_i 2 Clk
    signal PrSl_VolDVldDly3_s           : std_logic;                            -- Delay CpSl_VolDVld_i 3 Clk
    signal PrSl_VolDVldTrig_s           : std_logic;                            -- Delay CpSl_VolDVld_i Trig
    signal PrSl_VolDataDly1_s           : std_logic_vector(71 downto 0);        -- Delay CpSl_VolData_i 1 Clk
    signal PrSl_VolDataDly2_s           : std_logic_vector(71 downto 0);        -- Delay CpSl_VolData_i 2 Clk
    signal PrSv_AdcVolStartCap_s        : std_logic_vector(27 downto 0);        -- MPS Voltage time 
    signal PrSl_AdcVolCapTrig_s         : std_logic;                            -- ADC Start Trig

    -- ADC State machine
    signal PrSv_CapVolNum_s             : std_logic_vector( 2 downto 0);        -- Capture Adc Voltage Number
    signal PrSl_FpgaVldDly1_s           : std_logic;                            -- Delay CpSl_FpgaVld_i 1 Clk
    signal PrSl_FpgaVldDly2_s           : std_logic;                            -- Delay CpSl_FpgaVld_i 2 Clk
    signal PrSl_FpgaVldDly3_s           : std_logic;                            -- Delay CpSl_FpgaVld_i 3 Clk
    signal PrSl_FpgaVldTrig_s           : std_logic;                            -- Delay CpSl_FpgaVld_i Trig
    signal PrSv_AdcState_s              : std_logic_vector( 3 downto 0);        -- ADC State
    signal PrSv_AdcStart_s              : std_logic_vector(15 downto 0);        -- ADC Start Count
    signal PrSv_AdcConfigEnd_s          : std_logic_vector(15 downto 0);        -- ADC Confige End
    signal PrSv_AdcRst_s                : std_logic_vector(15 downto 0);        -- ADC Reset SPI interface
    signal PrSv_AdcWait_s               : std_logic_vector(15 downto 0);        -- ADC Wait Count
    signal PrSv_AdcStop_s               : std_logic_vector(15 downto 0);        -- ADC Stop Count
    signal PrSv_AdcEnd_s                : std_logic_vector(15 downto 0);        -- ADC Single Capture End
    signal PrSv_AdcConfigNum_s          : std_logic_vector( 4 downto 0);        -- ADC Config Num
    signal PrSv_AdcConfigCmdNum_s       : std_logic_vector( 4 downto 0);        -- ADC Config Command Data
    signal PrSv_AdcRecNum_s             : std_logic_vector( 4 downto 0);        -- ADC Receive Num
    signal PrSl_AdcSclk_s               : std_logic;                            -- ADC Sclk
    signal PrSl_AdcSclkNum_s            : std_logic_vector( 7 downto 0);        -- ADC Sclk Num
    signal PrSv_AdcConfigData_s         : std_logic_vector(15 downto 0);        -- ADC Config Data
    signal PrSl_AdcConfig_s             : std_logic;                            -- Adc Config
    signal PrSl_AdcConfigCmd_s          : std_logic;                            -- Adc Config Command
    signal PrSv_AdcDin_s                : std_logic_vector(15 downto 0);        -- ADC Transfer Data(U122 Chip)
    signal PrSv_AdcDin1_s               : std_logic_vector(15 downto 0);        -- ADC Transfer Data(U123 Chip)
    signal PrSv_Adc5V_s                 : std_logic_vector(15 downto 0);        -- ADC Capture 5V
    signal PrSv_Adc3V3_s                : std_logic_vector(15 downto 0);        -- ADC Capture 3V3
    signal PrSv_Adc2V5_s                : std_logic_vector(15 downto 0);        -- ADC Capture 2V5
    signal PrSv_Adc1V5_s                : std_logic_vector(15 downto 0);        -- ADC Capture 1V5

    -- Control Voltage Relay
    signal PrSv_TestBoard_s             : std_logic_vector( 2 downto 0);        -- Indication Test Board
    signal PrSv_CmpState_s              : std_logic_vector( 2 downto 0);        -- Voltage Compare State
    signal PrSv_Cnt1us_s                : std_logic_vector( 7 downto 0);        -- Count 1us
    signal PrSv_AdcVolRelay_s           : std_logic_vector(19 downto 0);        -- Send Compare Voltage to PC
    signal PrSv_RelayVol_s              : std_logic_vector( 3 downto 0);        -- Control Voltage Relay
    signal PrSv_CmpVolResult_s          : std_logic_vector( 3 downto 0);        -- Compare Voltage Data
    signal PrSv_VoltageResult_s         : std_logic_vector( 3 downto 0);        -- Compare Voltage for Current used

begin
    ----------------------------------------------------------------------------
    -- Mian Area
    ----------------------------------------------------------------------------
    -- Latch CpSl_VolDVld_i
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_VolDVldDly1_s <= '0';
            PrSl_VolDVldDly2_s <= '0';
            PrSl_VolDVldDly3_s <= '0';
        elsif rising_edge(CpSl_Clk_i) then
            PrSl_VolDVldDly1_s <= CpSl_VolDVld_i;
            PrSl_VolDVldDly2_s <= PrSl_VolDVldDly1_s;
            PrSl_VolDVldDly3_s <= PrSl_VolDVldDly2_s;
        end if;
    end process;
    -- Rising edge of CpSl_VolDVld_i
    PrSl_VolDVldTrig_s <= PrSl_VolDVldDly2_s and (not PrSl_VolDVldDly3_s);

    -- Delay CpSv_VolData_i
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_VolDataDly1_s <= (others => '0');
            PrSl_VolDataDly2_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            PrSl_VolDataDly1_s <= CpSv_VolData_i;
            PrSl_VolDataDly2_s <= PrSl_VolDataDly1_s;
        end if;
    end process;

    -- Receive Voltage data
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_Head_s     <= (others => '0');
            PrSv_Vol5v_s    <= (others => '0');
            PrSv_Vol3v3_s   <= (others => '0');
            PrSv_Vol2v5_s   <= (others => '0');
            PrSv_Vol1v5_s   <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSl_VolDVldTrig_s = '1') then
                PrSv_Head_s     <= PrSl_VolDataDly2_s(71 downto 64);
                PrSv_Vol5v_s    <= PrSl_VolDataDly2_s(63 downto 48);
                PrSv_Vol3v3_s   <= PrSl_VolDataDly2_s(47 downto 32);
                PrSv_Vol2v5_s   <= PrSl_VolDataDly2_s(31 downto 16);
                PrSv_Vol1v5_s   <= PrSl_VolDataDly2_s(15 downto  0);
            else -- hold
            end if;
        end if;
    end process;

    -- Latch CpSl_FpgaVld_i
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_FpgaVldDly1_s <= '0';
            PrSl_FpgaVldDly2_s <= '0';
            PrSl_FpgaVldDly3_s <= '0';
        elsif rising_edge(CpSl_Clk_i) then
            PrSl_FpgaVldDly1_s <= CpSl_FpgaVld_i;
            PrSl_FpgaVldDly2_s <= PrSl_FpgaVldDly1_s;
            PrSl_FpgaVldDly3_s <= PrSl_FpgaVldDly2_s;
        end if;
    end process;

    -- Rising edge of CpSl_FpgaVld_i
    PrSl_FpgaVldTrig_s <= PrSl_FpgaVldDly2_s and (not PrSl_FpgaVldDly3_s);

    -- PrSv_AdcVolStartCap_s
    process (CpSl_Rst_iN, CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            PrSv_AdcVolStartCap_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then 
            if (PrSl_FpgaVldTrig_s = '1') then 
                PrSv_AdcVolStartCap_s <= (others => '0');
            elsif (PrSv_AdcVolStartCap_s = PrSv_AdcVolStartCap_c) then 
                PrSv_AdcVolStartCap_s <= PrSv_AdcVolStartCap_c;
--                PrSv_AdcVolStartCap_s <= (others => '0');
            else
                PrSv_AdcVolStartCap_s <= PrSv_AdcVolStartCap_s + '1';
            end if;
        end if;
    end process;
    
    -- PrSl_AdcVolCapTrig_s
    process (CpSl_Rst_iN, CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            PrSl_AdcVolCapTrig_s <= '0';
        elsif rising_edge(CpSl_Clk_i) then 
            if (PrSv_AdcVolStartCap_s = PrSv_AdcVolStartCap_c - 10) then 
                PrSl_AdcVolCapTrig_s <= '1';
            elsif (PrSv_AdcVolStartCap_s = PrSv_AdcVolStartCap_c - 1) then 
                PrSl_AdcVolCapTrig_s <= '0';
            else -- hold
            end if;
        end if;
    end process;

    -- ADC Capture Num
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_CapVolNum_s <= "000";
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSl_FpgaVldTrig_s = '1') then
                PrSv_CapVolNum_s <= "000";
            elsif (PrSv_AdcState_s = "1001" and PrSv_AdcStop_s = PrSv_AdcStop_c - 10) then
                PrSv_CapVolNum_s <= PrSv_CapVolNum_s + '1';
            else -- hold
            end if;
        end if;
    end process;

    -- ADC Config Data
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_AdcConfigData_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
        case PrSv_CapVolNum_s is
            when "000" => -- Config 5v
                if (PrSv_AdcState_s = "0001") then 
					     PrSv_AdcConfigData_s <= PrSv_ConfigRedCmd_c;
--                    PrSv_AdcConfigData_s <= PrSv_Config5V_c;
                elsif (PrSv_AdcState_s = "0011") then 
                    PrSv_AdcConfigData_s <= PrSv_Config5V_c;
                else -- hold
                end if;
            when "001" => -- Config 3V3
                if (PrSv_AdcState_s = "0001") then 
					     PrSv_AdcConfigData_s <= PrSv_ConfigRedCmd_c;
--                    PrSv_AdcConfigData_s <= PrSv_Config3V3_c;
                elsif (PrSv_AdcState_s = "0011") then 
                    PrSv_AdcConfigData_s <= PrSv_Config3V3_c;
                else -- hold
                end if;
            when "010" => -- Config 2V5
                if (PrSv_AdcState_s = "0001") then 
					     PrSv_AdcConfigData_s <= PrSv_ConfigRedCmd_c;
--                    PrSv_AdcConfigData_s <= PrSv_Config2V5_c;
                elsif (PrSv_AdcState_s = "0011") then 
                    PrSv_AdcConfigData_s <= PrSv_Config2V5_c;
                else -- hold
                end if;
            when "011" => -- Config 1V5
                if (PrSv_AdcState_s = "0001") then 
					     PrSv_AdcConfigData_s <= PrSv_ConfigRedCmd_c;
--                    PrSv_AdcConfigData_s <= PrSv_Config1V5_c;
                elsif (PrSv_AdcState_s = "0011") then 
                    PrSv_AdcConfigData_s <= PrSv_Config1V5_c;
                else -- hold
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
            when "0000" => -- Adc State Idle
                if (PrSl_AdcVolCapTrig_s = '1') then
                    PrSv_AdcState_s <= "0001";
                else -- hold
                end if;

            when "0001" => -- ADC Start (50 us)
                if (PrSv_AdcStart_s = PrSv_AdcStart_c) then
                    PrSv_AdcState_s <= "0010";
                else -- hold
                end if;

            when "0010" => -- ADC Config Data
                if (PrSv_AdcConfigNum_s = 16 and PrSl_AdcSclkNum_s = 99) then
                    PrSv_AdcState_s <= "0011";
                else
                end if;

            when "0011" =>  -- ADC Confige End
                if (PrSv_AdcConfigEnd_s = PrSv_AdcStart_c) then
					PrSv_AdcState_s <= "0100";
                else -- hold
                end if;

            when "0100" => -- Config Read Command
                if (PrSv_AdcConfigCmdNum_s = 16 and PrSl_AdcSclkNum_s = 99) then 
                    PrSv_AdcState_s <= "0101";
                else -- hold
                end if;
                
            when "0101" => -- ADC Reset SPI interface
                if (PrSv_AdcRst_s = PrSv_AdcWait_c) then
                    PrSv_AdcState_s <= "0110";
                else -- hold
                end if;

            when "0110" => -- wait ADC Ready
                if (CpSl_AdcData_i = '0') then
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

            when "1001" => -- ADS1018 End (50us)
                if (PrSv_AdcStop_s = PrSv_AdcStop_c) then
                    PrSv_AdcState_s <= "1010";
                else
                end if;

            when "1010" => -- Capture End
                if (PrSv_CapVolNum_s = 4) then
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
                PrSv_AdcState_s <= "0000";
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
                if (PrSv_AdcEnd_s = PrSv_AdcStop_c) then
                    PrSv_AdcEnd_s <= (others => '0');
                else
                    PrSv_AdcEnd_s <= PrSv_AdcEnd_s + '1';
                end if;
            else
                PrSv_AdcEnd_s <= (others => '0');
            end if;
        end if;
    end process;

    -- ADC_CS(U122)
    -- ADC_CS1(U123)
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            CpSl_AdcCS_o <= '1';
             CpSl_AdcCS1_o <= '1';
         elsif rising_edge(CpSl_Clk_i) then
             if (PrSv_AdcState_s = "0001" and PrSv_CapVolNum_s = 0) then
                 CpSl_AdcCS_o <= '1';
                 CpSl_AdcCS1_o <= '0';
             elsif (PrSv_AdcState_s = "0001" and PrSv_CapVolNum_s /= 0) then
                 CpSl_AdcCS_o <= '0';
                 CpSl_AdcCS1_o <= '1';
             elsif (PrSv_AdcState_s = "1010") then
                 CpSl_AdcCS_o <= '1';
                 CpSl_AdcCS1_o <= '1';
             else -- hold
             end if;
        end if;
    end process;

    -- ADC Sclk
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
    -- ADC Clock
    CpSl_AdcSclk_o <= PrSl_AdcSclk_s;

    -- PrSv_AdcConfigNum_s
    process (CpSl_Rst_iN, PrSl_AdcSclk_s) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_AdcConfigNum_s <= (others => '0');
        elsif rising_edge(PrSl_AdcSclk_s) then
            if (PrSv_AdcState_s = "0010") then
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

    -- Configure Data
    process (CpSl_Rst_iN, PrSl_AdcSclk_s) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_AdcConfig_s <= '0';
        elsif rising_edge(PrSl_AdcSclk_s) then
            if (PrSv_AdcState_s = "0010") then
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

    -- PrSv_AdcConfigCmdNum_s
    process (CpSl_Rst_iN, PrSl_AdcSclk_s) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_AdcConfigCmdNum_s <= (others => '0');
        elsif rising_edge(PrSl_AdcSclk_s) then
            if (PrSv_AdcState_s = "0100") then
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

    -- Configure Data
    process (CpSl_Rst_iN, PrSl_AdcSclk_s) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_AdcConfigCmd_s <= '0';
        elsif rising_edge(PrSl_AdcSclk_s) then
            if (PrSv_AdcState_s = "0100") then
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

    -- CpSl_AdcConfigData_o
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            CpSl_AdcConfigData_o <= '0';
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSv_AdcState_s = "0010") then
                CpSl_AdcConfigData_o <= PrSl_AdcConfig_s;
            elsif (PrSv_AdcState_s = "0100") then
                CpSl_AdcConfigData_o <= PrSl_AdcConfigCmd_s;
            else
                CpSl_AdcConfigData_o <= '0';
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

    -- U122 & U123 ADC Data 
    process (CpSl_Rst_iN,CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_AdcDin_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSv_AdcState_s = "1000" and PrSl_AdcSclkNum_s = 74) then
                PrSv_AdcDin_s <= PrSv_AdcDin_s(14 downto 0) & CpSl_AdcData_i;
            else
            end if;
        end if;
    end process;


    -- Adc End Data
    process (CpSl_Rst_iN,CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_Adc5V_s    <= (others => '0');
            PrSv_Adc3V3_s   <= (others => '0');
            PrSv_Adc2V5_s   <= (others => '0');
            PrSv_Adc1V5_s   <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            case PrSv_CapVolNum_s is
            when "000" =>  -- Capture 5v Voltage
                if (PrSv_AdcState_s = "1001" and PrSv_AdcStop_s = PrSv_AdcStop_c - 50) then
                    PrSv_Adc5V_s <= x"0" & PrSv_AdcDin_s(15 downto 4);
                else
                end if;

            when "001" => -- Capture 3V3 Voltage
                if (PrSv_AdcState_s = "1001" and PrSv_AdcStop_s = PrSv_AdcStop_c - 50) then
                    PrSv_Adc3V3_s <= x"0" & PrSv_AdcDin_s(15 downto 4);
                else
                end if;

            when "010" =>  -- Capture 2.5V Voltage
                if (PrSv_AdcState_s = "1001" and PrSv_AdcStop_s = PrSv_AdcStop_c - 50) then
                    PrSv_Adc2V5_s <= x"0" & PrSv_AdcDin_s(15 downto 4);
                else
                end if;

            when "011" =>  -- Capture 1V5 Voltage
                if (PrSv_AdcState_s = "1001" and PrSv_AdcStop_s = PrSv_AdcStop_c - 50) then
                    PrSv_Adc1V5_s <= x"0" & '0' & PrSv_AdcDin_s(15 downto 5);
                else
                end if;

            when others =>
                PrSv_Adc5V_s    <= PrSv_Adc5V_s  ;
                PrSv_Adc3V3_s   <= PrSv_Adc3V3_s ;
                PrSv_Adc2V5_s   <= PrSv_Adc2V5_s ;
                PrSv_Adc1V5_s   <= PrSv_Adc1V5_s ;
        end case;
        end if;
    end process;

    -- Compare Voltage
    process (CpSl_Rst_iN,CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_CmpState_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
        case PrSv_CmpState_s is
            when "000" => -- Receive UART Voltage 
                if (PrSl_VolDVldTrig_s = '1') then
                    PrSv_CmpState_s <= "001";
                else
                end if;
            when "001" => -- Capture Voltage End
                if (PrSv_CapVolNum_s = 4) then
                    PrSv_CmpState_s <= "010";
                else
                end if;
            when "010" => -- Compare Voltage
                if (PrSv_Cnt1us_s = PrSv_Cnt1us_c) then
                    PrSv_CmpState_s <= "100";
                else
                end if;
            when "100" => -- Send to PC 
                if (PrSv_AdcVolRelay_s = PrSv_AdcVolRelay_c) then 
                    PrSv_CmpState_s <= (others => '0');
                else
                end if;
            when others =>
                PrSv_CmpState_s <= (others => '0');

        end case;
        end if;
    end process;

    -- Compare Voltage/Generate Compare Result
    process (CpSl_Rst_iN,CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_Cnt1us_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSv_CmpState_s = "010") then
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

    -- PrSv_AdcVolRelay_s
    process (CpSl_Rst_iN,CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_AdcVolRelay_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSv_CmpState_s = "100") then
                if (PrSv_AdcVolRelay_s = PrSv_AdcVolRelay_c) then
                    PrSv_AdcVolRelay_s <= (others => '0');
                else
                    PrSv_AdcVolRelay_s <= PrSv_AdcVolRelay_s + '1';
                end if;
            else
                PrSv_AdcVolRelay_s <= (others => '0');
            end if;
        end if;
    end process;

    -- Head Indication
    process (CpSl_Rst_iN,CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_TestBoard_s <= "000";
        elsif rising_edge(CpSl_Clk_i) then
        case PrSv_Head_s is
            when PrSv_SelfFpgaHead_c  => PrSv_TestBoard_s <= PrSv_SelfFpga_c;
            when PrSv_A1000FpgaHead_c => PrSv_TestBoard_s <= PrSv_A1000Fpga_c;
            when PrSv_A500FpgaHead_c  => PrSv_TestBoard_s <= PrSv_A500Fpga_c;
            when PrSv_A54SFpgaHead_c  =>
                if (PrSv_Vol5v_s = x"EFFE" and PrSv_Vol1v5_s = x"EFFE") then
                    PrSv_TestBoard_s <= PrSv_A54SFpga0_c;
                else
                    PrSv_TestBoard_s <= PrSv_A54SFpga1_c;
                end if;

            when others =>
                PrSv_TestBoard_s <= "000";
        end case;
        end if;
    end process;

    -- Compare Voltage
    process (CpSl_Rst_iN,CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_RelayVol_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            case PrSv_TestBoard_s is
                when "001" => -- Self Board
                    if (PrSv_CmpState_s = "010" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 65) then
                        -- 5V
                        if (PrSv_Adc5V_s > PrSv_Vol5v_s - PrSv_VolRang_c and
                            PrSv_Adc5V_s < PrSv_Vol5v_s + PrSv_VolRang_c) then
                            PrSv_RelayVol_s(3) <= '1';
                        else
                            PrSv_RelayVol_s(3) <= '0';
                        end if;
                    elsif (PrSv_CmpState_s = "010" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 64) then
                        -- 3V3
                        if (PrSv_Adc3V3_s > PrSv_Vol3v3_s - PrSv_VolRang_c and
                            PrSv_Adc3V3_s < PrSv_Vol3v3_s + PrSv_VolRang_c) then
                            PrSv_RelayVol_s(2) <= '1';
                        else
                            PrSv_RelayVol_s(2) <= '0';
                        end if;
                    elsif (PrSv_CmpState_s = "010" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 63) then
                        -- 2V5
                        if (PrSv_Adc2V5_s > PrSv_Vol2V5_s - PrSv_VolRang_c and
                            PrSv_Adc2V5_s < PrSv_Vol2V5_s + PrSv_VolRang_c) then
                            PrSv_RelayVol_s(1) <= '1';
                        else
                            PrSv_RelayVol_s(1) <= '0';
                        end if;
                    elsif (PrSv_CmpState_s = "010" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 62) then
                        -- 1V5
                        if (PrSv_Adc1V5_s > PrSv_Vol1V5_s - PrSv_VolRang_c and
                            PrSv_Adc1V5_s < PrSv_Vol1V5_s + PrSv_VolRang_c) then
                            PrSv_RelayVol_s(0) <= '1';
                        else
                            PrSv_RelayVol_s(0) <= '0';
                        end if;
                    else -- hold
                    end if;

                when "010" => -- A1000
                    if (PrSv_CmpState_s = "010" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 65) then
                        -- 5V
                        PrSv_RelayVol_s(3) <= '0';
                    elsif (PrSv_CmpState_s = "010" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 64) then
                        -- 3V3
                        if (PrSv_Adc3V3_s > PrSv_Vol3v3_s - PrSv_VolRang_c and
                            PrSv_Adc3V3_s < PrSv_Vol3v3_s + PrSv_VolRang_c) then
                            PrSv_RelayVol_s(2) <= '1';
                        else
                            PrSv_RelayVol_s(2) <= '0';
                        end if;
                    elsif (PrSv_CmpState_s = "010" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 63) then
                        -- 2V5
                        PrSv_RelayVol_s(1) <= '0';
                    elsif (PrSv_CmpState_s = "010" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 62) then
                        -- 1V5
                        if (PrSv_Adc1V5_s > PrSv_Vol1V5_s - PrSv_VolRang_c and
                            PrSv_Adc1V5_s < PrSv_Vol1V5_s + PrSv_VolRang_c) then
                            PrSv_RelayVol_s(0) <= '1';
                        else
                            PrSv_RelayVol_s(0) <= '0';
                        end if;
                    else -- hold
                    end if;

                when "011" => -- A500
                    if (PrSv_CmpState_s = "010" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 65) then
                        -- 5V
                        PrSv_RelayVol_s(3) <= '0';
                    elsif (PrSv_CmpState_s = "010" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 64) then
                        -- 3V3
                        if (PrSv_Adc3V3_s > PrSv_Vol3v3_s - PrSv_VolRang_c and
                            PrSv_Adc3V3_s < PrSv_Vol3v3_s + PrSv_VolRang_c) then
                            PrSv_RelayVol_s(2) <= '1';
                        else
                            PrSv_RelayVol_s(2) <= '0';
                        end if;
                    elsif (PrSv_CmpState_s = "010" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 63) then
                        -- 2V5
                        PrSv_RelayVol_s(1) <= '0';
                    elsif (PrSv_CmpState_s = "010" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 62) then
                        -- 1V5
                        if (PrSv_Adc1V5_s > PrSv_Vol1V5_s - PrSv_VolRang_c and
                            PrSv_Adc1V5_s < PrSv_Vol1V5_s + PrSv_VolRang_c) then
                            PrSv_RelayVol_s(0) <= '1';
                        else
                            PrSv_RelayVol_s(0) <= '0';
                        end if;
                    else -- hold
                    end if;

                when "100" => -- A54S_1
                    if (PrSv_CmpState_s = "010" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 65) then
                        -- 5V
                        PrSv_RelayVol_s(3) <= '0';
                    elsif (PrSv_CmpState_s = "010" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 64) then
                        -- 3V3
                        if (PrSv_Adc3V3_s > PrSv_Vol3v3_s - PrSv_VolRang_c and
                            PrSv_Adc3V3_s < PrSv_Vol3v3_s + PrSv_VolRang_c) then
                            PrSv_RelayVol_s(2) <= '1';
                        else
                            PrSv_RelayVol_s(2) <= '0';
                        end if;
                    elsif (PrSv_CmpState_s = "010" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 63) then
                        -- 2V5
                        if (PrSv_Adc2V5_s > PrSv_Vol2V5_s - PrSv_VolRang_c and
                            PrSv_Adc2V5_s < PrSv_Vol2V5_s + PrSv_VolRang_c) then
                            PrSv_RelayVol_s(1) <= '1';
                        else
                            PrSv_RelayVol_s(1) <= '0';
                        end if;
                    elsif (PrSv_CmpState_s = "010" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 62) then
                        -- 1V5
                        PrSv_RelayVol_s(0) <= '0';
                    else -- hold
                    end if;

                when "101" => -- A54S_2
                    if (PrSv_CmpState_s = "010" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 65) then
                        -- 5V
                        if (PrSv_Adc5V_s > PrSv_Vol5v_s - PrSv_VolRang_c and
                            PrSv_Adc5V_s < PrSv_Vol5v_s + PrSv_VolRang_c) then
                            PrSv_RelayVol_s(3) <= '1';
                        else
                            PrSv_RelayVol_s(3) <= '0';
                        end if;
                    elsif (PrSv_CmpState_s = "010" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 64) then
                        -- 3V3
                        PrSv_RelayVol_s(2) <= '0';
                    elsif (PrSv_CmpState_s = "010" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 63) then
                        -- 2V5
                        if (PrSv_Adc2V5_s > PrSv_Vol2V5_s - PrSv_VolRang_c and
                            PrSv_Adc2V5_s < PrSv_Vol2V5_s + PrSv_VolRang_c) then
                            PrSv_RelayVol_s(1) <= '1';
                        else
                            PrSv_RelayVol_s(1) <= '0';
                        end if;
                    elsif (PrSv_CmpState_s = "010" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 62) then
                        -- 1V5
                        PrSv_RelayVol_s(0) <= '0';
                    else -- hold
                    end if;

                when others => PrSv_RelayVol_s <= (others => '0');
            end case;
        end if;
    end process;

    -- Compare Result
    process (CpSl_Rst_iN,CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_CmpVolResult_s <= (others => '0');
            PrSv_VoltageResult_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
        case PrSv_TestBoard_s is
            when "001" => -- SelfBoard
                if (PrSv_CmpState_s = "010" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 55) then
                    if (PrSv_RelayVol_s = PrSv_SelfFpgaVcc_c) then
                        PrSv_CmpVolResult_s <= PrSv_SelfFpgaVcc_c;
                        PrSv_VoltageResult_s <= PrSv_SelfFpgaVcc_c;
                    else
                        PrSv_CmpVolResult_s <= PrSv_RelayVol_s;
                        PrSv_VoltageResult_s <= PrSv_VccError_c;
                    end if;
                else
                end if;
            when "010" => -- A1000
                if (PrSv_CmpState_s = "010" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 55) then
                    if (PrSv_RelayVol_s = PrSv_A1000FpgaVcc_c) then
                        PrSv_CmpVolResult_s <= PrSv_A1000FpgaVcc_c;
                        PrSv_VoltageResult_s <= PrSv_A1000FpgaVcc_c;
                    else
                        PrSv_CmpVolResult_s <= PrSv_RelayVol_s;
                        PrSv_VoltageResult_s <= PrSv_VccError_c;
                    end if;
                else
                end if;
            when "011" => -- A500
                if (PrSv_CmpState_s = "010" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 55) then
                    if (PrSv_RelayVol_s = PrSv_A500FpgaVcc_c) then
                        PrSv_CmpVolResult_s <= PrSv_A500FpgaVcc_c;
                        PrSv_VoltageResult_s <= PrSv_A500FpgaVcc_c;
                    else
                        PrSv_CmpVolResult_s <= PrSv_RelayVol_s;
                        PrSv_VoltageResult_s <= PrSv_VccError_c;
                    end if;
                else
                end if;
            when "100" => -- A54S_1
                if (PrSv_CmpState_s = "010" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 55) then
                    if (PrSv_RelayVol_s = PrSv_A54SFpga0Vcc_c) then
                        PrSv_CmpVolResult_s <= PrSv_A54SFpga0Vcc_c;
                        PrSv_VoltageResult_s <= PrSv_A54SFpga0Vcc_c;
                    else
                        PrSv_CmpVolResult_s <= PrSv_RelayVol_s;
                        PrSv_VoltageResult_s <= PrSv_VccError_c;
                    end if;
                else
                end if;
            when "101" => -- A54S_2
                if (PrSv_CmpState_s = "010" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 55) then
                    if (PrSv_RelayVol_s = PrSv_A54SFpga1Vcc_c) then
                        PrSv_CmpVolResult_s <= PrSv_A54SFpga1Vcc_c;
                        PrSv_VoltageResult_s <= PrSv_A54SFpga1Vcc_c;
                    else
                        PrSv_CmpVolResult_s <= PrSv_RelayVol_s;
                        PrSv_VoltageResult_s <= PrSv_VccError_c;
                    end if;
                else
                end if;
            when others => 
                PrSv_CmpVolResult_s <= (others => '0');
                PrSv_VoltageResult_s <= (others => '0');
        end case;
        end if;
    end process;

    -- Relay Voltage
    process (CpSl_Rst_iN,CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            CpSv_RelayVol_o <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSl_FpgaVldTrig_s = '1') then
                CpSv_RelayVol_o <= (others => '1');
            elsif (PrSv_CmpState_s = "010" and PrSv_Cnt1us_s = PrSv_Cnt1us_c - 49) then
                CpSv_RelayVol_o <= PrSv_VoltageResult_s;
            elsif (CpSl_CmpInd_i = '1') then 
                CpSv_RelayVol_o <= (others => '0');
            else -- hold
            end if;
        end if;
    end process;

    -- Valid & Voltage Data & Voltage Result
    process (CpSl_Rst_iN,CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            CpSl_CmpVolVld_o <= '0';
        elsif rising_edge(CpSl_Clk_i) then
            if(PrSv_CmpState_s = "100" and PrSv_AdcVolRelay_s = PrSv_AdcVolRelay_c) then
                CpSl_CmpVolVld_o <= '1';
            else
                CpSl_CmpVolVld_o <= '0';
            end if;
        end if;
    end process;


    process (CpSl_Rst_iN,CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            CpSv_VoltageResult_o <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            if(PrSv_CmpState_s = "100" and PrSv_AdcVolRelay_s = PrSv_AdcVolRelay_c) then
                CpSv_VoltageResult_o <= PrSv_TestBoard_s & PrSv_VoltageResult_s;
            else
            end if;
        end if;
    end process;

    process (CpSl_Rst_iN,CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            CpSv_CmpVolData_o <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            if(PrSv_CmpState_s = "100" and PrSv_AdcVolRelay_s = PrSv_AdcVolRelay_c) then
                CpSv_CmpVolData_o <= PrSv_TestBoard_s & x"0" & PrSv_CmpVolResult_s;
            else
            end if;
        end if;
    end process;

end arch_M_CmparVol;