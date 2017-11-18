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
-- 文件名称  :  M_UartRecv.vhd
-- 设    计  :  Xiaopeng Wu
-- 邮    件  :  zheng-jianfeng@139.com
-- 校    对  :  
-- 设计日期  :  2017/03/13
-- 功能简述  :  Top
-- 版本序号  :  0.1
-- 修改历史  :  1. Initial, Xiaopeng Wu, 2017/03/13
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity M_TopTb is
end M_TopTb;

architecture arch_M_TopTb of M_TopTb is
    ----------------------------------------------------------------------------
    -- constant declaration
    ----------------------------------------------------------------------------
    constant CLOCK_PERIOD_40M           : time := 25 ns;
    constant CLOCK_PERIOD_100M          : time := 10 ns;
    constant PrSv_Baud115200_c          : std_logic_vector(15 downto 0) := x"0364"; -- 100M / 115200 = 868
    constant PrSv_VolData_c             : std_logic_vector(110 downto 0) := '1'&x"88"&'0'&'1'&x"13"&'0'&'1'&x"E4"&'0'&'1'&x"0C"&'0'
                                                                            &'1'&x"C4"&'0'&'1'&x"09"&'0'&'1'&x"DC"&'0'&'1'&x"05"&'0'
                                                                            &'1'&x"C1"&'0'&'1'&x"4A"&'0'&'1'&x"A5"&'0'&'1';
                                                                            
    ----------------------------------------------------------------------------
    -- component declaration
    ----------------------------------------------------------------------------
    component M_Top is port (
        --------------------------------
        -- Reset and clock
        --------------------------------
--        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      : in  std_logic;                        -- 40MHz,Single Clock
        
        --------------------------------
        -- GPIO 
        --------------------------------
        CpSv_Gpio_i                    : in  std_logic_vector(2 downto 0);      -- GPIO

        --------------------------------
        -- Uart Interface
        --------------------------------
        CpSl_RxD_i                      : in  std_logic;                        -- Receive data
        CpSl_TxD_o                      : out std_logic;                        -- Transver data
        
        --------------------------------
        -- ADC Voltage Interface
        --------------------------------
        CpSl_AdcSclk_o                  : out std_logic;                        -- ADC Clock
        CpSl_AdcCS_o                    : out std_logic;                        -- ADC CS
        CpSl_AdcConfigData_o            : out std_logic;                        -- ADC Configuration Data
        CpSl_AdcData_i                  : in  std_logic;                        -- ADC Transfer Data
        CpSl_AdcData1_i                 : in  std_logic;                        -- U123 Chip Adc Transfer Data

        --------------------------------
        -- ADC Current Interface
        --------------------------------
        CpSl_CurtAdcClk_o               : out std_logic;                        -- ADC Clock
        CpSl_CurtAdcCS_o                : out std_logic;                        -- ADC CS
        CpSl_CurtAdcConfigData_o        : out std_logic;                        -- ADC Configuration Data
        CpSl_CurtAdcData_i              : in  std_logic;                        -- ADC Transfer Data

        --------------------------------                                                                  
        -- Control Relay Voltage                                                                          
        --------------------------------                                                                  
        CpSv_VadjCtrl_o                 : out std_logic_vector( 2 downto 0);    -- Control Vadj Relay     
        CpSv_RelayEn_o                  : out std_logic_vector( 2 downto 0);    -- F_En Voltage           
        CpSv_RelayVol_o                 : out std_logic_vector( 3 downto 0);    -- Control voltage Relay(5V/3.3V/2.5V/1.5V) 

        --------------------------------
        -- Test FPGA Rst/Pin
        --------------------------------
        CpSl_FpgaRst_o                  : out std_logic;                        -- FPGA Reset
        CpSv_SelectIO_o                 : out std_logic_vector(20 downto 0)     -- Test IO select
    );
    end component;
        
    ----------------------------------------------------------------------------
    -- signal declaration
    ----------------------------------------------------------------------------
    signal CpSl_Clk_i                   : std_logic;
    signal CpSl_RxD_i                   : std_logic;
    signal CpSl_TxD_o                   : std_logic;
    signal CpSv_Gpio_i                  : std_logic_vector(2 downto 0);
    signal CpSl_AdcData_i               : std_logic;
    signal CpSl_AdcData1_i              : std_logic;
    signal CpSl_CurtAdcData_i           : std_logic;

begin
    U_M_Top : M_Top port map(
        --------------------------------
        -- Reset and clock
        --------------------------------
--        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      => CpSl_Clk_i                           , --  in  std_logic;                        -- 40MHz,Single Clock

        --------------------------------=> -------------------------            , -- 
        -- GPIO                         => -- GPIO                              , -- 
        --------------------------------=> -------------------------            , -- 
        CpSv_Gpio_i                     => CpSv_Gpio_i                          , -- in  std_logic_vector(2 downto 0);      -- GPIO

        --------------------------------=> -------------------------            , -- 
        -- Uart Interface               => -- Uart Interface                    , -- 
        --------------------------------=> -------------------------            , -- 
        CpSl_RxD_i                      => CpSl_RxD_i                           , --  in  std_logic;                        -- Receive data
        CpSl_TxD_o                      => CpSl_TxD_o                           , --  out std_logic;                        -- Transver data

        --------------------------------=> -------------------------            , -- 
        -- ADC Voltage Interface        => -- ADC Voltage Interface             , -- 
        --------------------------------=> -------------------------            , -- 
        CpSl_AdcSclk_o                  => open                                  , --  out std_logic;                        -- ADC Clock
        CpSl_AdcCS_o                    => open                                  , --  out std_logic;                        -- ADC CS
        CpSl_AdcConfigData_o            => open                                  , --  out std_logic;                        -- ADC Configuration Data
        CpSl_AdcData_i                  => CpSl_AdcData_i                       , --  in  std_logic;                        -- ADC Transfer Data
        CpSl_AdcData1_i                 => CpSl_AdcData1_i                      , --  in  std_logic;                        -- U123 Chip Adc Transfer Data

        --------------------------------=> -------------------------            , -- 
        -- ADC Current Interface        => -- ADC Current Interface             , -- 
        --------------------------------=> -------------------------            , -- 
        CpSl_CurtAdcClk_o               => open                                 , --  out std_logic;                        -- ADC Clock
        CpSl_CurtAdcCS_o                => open                                 , --  out std_logic;                        -- ADC CS
        CpSl_CurtAdcConfigData_o        => open                                 , --  out std_logic;                        -- ADC Configuration Data
        CpSl_CurtAdcData_i              => CpSl_CurtAdcData_i                   , --  in  std_logic;                        -- ADC Transfer Data

        --------------------------------=> -------------------------            , --                                                                  
        -- Control Relay Voltage        => -- Control Relay Voltage             , --                                                                  
        --------------------------------=> -------------------------            , --                                                                  
        CpSv_VadjCtrl_o                 => open                                 , --  out std_logic_vector( 2 downto 0);    -- Control Vadj Relay     
        CpSv_RelayEn_o                  => open                                 , --  out std_logic_vector( 2 downto 0);    -- F_En Voltage           
        CpSv_RelayVol_o                 => open                                 , --  out std_logic_vector( 3 downto 0);    -- Control voltage Relay(5V/3.3V/2.5V/1.5V) 

        --------------------------------=> -------------------------            , -- 
        -- Test FPGA Rst/Pin            => -- Test FPGA Rst/Pin                 , -- 
        --------------------------------=> -------------------------            , -- 
        CpSl_FpgaRst_o                  => open                                 , --  out std_logic;                        -- FPGA Reset
        CpSv_SelectIO_o                 => open                                   --  out std_logic_vector(20 downto 0)     -- Test IO select
    );
        
    ------------------------------------
    -- Rst & Clk
    ------------------------------------
--    process begin
--        CpSl_Rst_iN <= '0';
--        wait for 100 ns;
--        CpSl_Rst_iN <= '1';
--        wait;
--    end process;

    process begin
        CpSl_Clk_i <= '0';
        wait for 5 ns;
        CpSl_Clk_i <= '1';
        wait for 5 ns;
    end process;
    
    process 
        variable i : integer range 0 to 110 := 0;
    begin
        for i in 0 to 110 loop
            CpSl_RxD_i <= PrSv_VolData_c(i);
--            CpSl_RxD_i <= PrSv_CmdData_o(i);
            wait for 8680 ns;
        end loop;
    end process;
    
    CpSv_Gpio_i         <= "101";
    CpSl_AdcData_i      <= '0';
    CpSl_AdcData1_i     <= '0';
    CpSl_CurtAdcData_i  <= '0';
    
end arch_M_TopTb;