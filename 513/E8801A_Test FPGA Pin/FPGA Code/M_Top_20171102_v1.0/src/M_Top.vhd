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
-- 文件名称  :  M_Top.vhd
-- 设    计  :  Zhang Wenjun
-- 邮    件  :  zheng-jianfeng@139.com
-- 校    对  :
-- 设计日期  :  2017/06/13
-- 功能简述  :  Top
-- 版本序号  :  0.1
-- 修改历史  :  1. Initial, Zhang Wenjun, 2017/06/13
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity M_Top is
    port (
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
        CpSl_AdcCS_o                    : out std_logic;                        -- ADC CS_U122
        CpSl_AdcCS1_o                   : out std_logic;                        -- ADC CS_U123
        CpSl_AdcConfigData_o            : out std_logic;                        -- ADC Configuration Data
        CpSl_AdcData_i                  : in  std_logic;                        -- U122 & U123 Chip ADC Transfer Data

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
        CpSv_SelectIO_o                 : out std_logic_vector(17 downto 0)     -- Test IO select
    );
end M_Top;

architecture arch_M_Top of M_Top is
    ----------------------------------------------------------------------------
    -- constant declaration
    ----------------------------------------------------------------------------

    ----------------------------------------------------------------------------
    -- component declaration
    ----------------------------------------------------------------------------
    --------------------------------
    -- in_Clk :40MHz
    -- out_Clk:100MHz
    --------------------------------
    component M_ClkPll is port (
        areset                          : in  std_logic;
        inclk0                          : in  std_logic;
        c0                              : out std_logic;
        locked                          : out std_logic
    );
    end component;

    ------------------------------------
    -- FPGA Type
    ------------------------------------
    component M_FpgaType is port (
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      : in  std_logic;                        -- 100MHz clock

        --------------------------------
        -- GPIO 
        --------------------------------
        CpSv_Gpio_i                     : in  std_logic_vector(2 downto 0);      -- GPIO

        --------------------------------
        -- FPGA Style
        --------------------------------
        CpSl_FpgaVld_o                  : out std_logic;                        -- FPGA Style Valid
        CpSv_FpgaType_o                 : out std_logic_vector(7 downto 0)      -- FPGA Style
    );
    end component;

    ------------------------------------
    -- Uart Rx/Tx
    ------------------------------------
    component M_UartTop is port (
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      : in  std_logic;                        -- 100MHz clock

        --------------------------------
        -- Uart Receive Interface 
        --------------------------------
        CpSl_RxD_i                      : in  std_logic;                        -- Receive Data
        CpSl_TxD_o                      : out std_logic;                        -- Send Data
        
        --------------------------------
        -- FPGA Type
        --------------------------------
        CpSl_FpgaVld_i                  : in  std_logic;                        -- FPGA Style Valid
        CpSv_FpgaType_i                 : in  std_logic_vector(7 downto 0);     -- FPGA Style

        --------------------------------
        -- Test FPGA Reset/Voltage/Current
        --------------------------------
        CpSl_RstVld_i                   : in  std_logic;                        -- Test Fpga Reset
        CpSl_CmpVolVld_i                : in  std_logic;                        -- Copmare Voltage Valid
        CpSv_CmpVolData_i               : in  std_logic_vector(10 downto 0);    -- Copmare Voltage Valid Data
        CpSl_CmpCurtVld_i               : in  std_logic;                        -- Compare Current Valid
        CpSv_CmpCurtData_i              : in  std_logic_vector(10 downto 0);    -- Compare Current Valid Data

        --------------------------------
        -- Parallel Command Indicator
        --------------------------------
        CpSl_TestDvld_i                 : in  std_logic;                        -- Parallel Test_Cmd data valid
        CpSv_TestData_i                 : in  std_logic_vector(23 downto 0);    -- Parallel Test_Cmd data

        --------------------------------
        -- Vol/Curt/Cmd output
        --------------------------------
        CpSl_VolDvld_o                  : out std_logic;                        -- Parallel Voltage data valid
        CpSv_VolData_o                  : out std_logic_vector(71 downto 0);    -- Parallel Voltage data
        CpSl_CurtDvld_o                 : out std_logic;                        -- Parallel Current data valid
        CpSv_CurtData_o                 : out std_logic_vector(71 downto 0);    -- Parallel Current data
        CpSl_JtagDvld_o                 : out std_logic;                        -- Parallel JTAG data valid
        CpSv_JtagData_o                 : out std_logic_vector(23 downto 0);    -- Parallel JTAG data
        CpSl_TestDvld_o                 : out std_logic;                        -- Parallel Test_Cmd data valid
        CpSv_TestData_o                 : out std_logic_vector(23 downto 0)     -- Parallel Test_Cmd data
    );
    end component;

    ------------------------------------
    -- Compare Voltage/Current
    ------------------------------------
    component M_CmparVol is port (
        --------------------------------
        -- Reset and clock
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
    end component;
        
    component M_CmparCurt is port (
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
        -- Test FPGA Reset Valid
        -------------------------------
        CpSl_JtagDvld_i                 : in  std_logic;                        -- Parallel JTAG data valid
        CpSl_RstVld_i                   : in  std_logic;                        -- FOGA Reset Valid
        
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
    end component;

    component M_CmdParse is port (
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      : in  std_logic;                        -- 100MHz clock

        --------------------------------
        -- JTAG/Test Valid
        --------------------------------
        CpSl_JtagDvld_i                 : in  std_logic;                        -- Parallel JTAG data valid
        CpSv_JtagData_i                 : in  std_logic_vector(23 downto 0);    -- Parallel JTAG data
        CpSl_TestDvld_i                 : in  std_logic;                        -- Parallel Test_Cmd data valid
        CpSv_TestData_i                 : in  std_logic_vector(23 downto 0);    -- Parallel Test_Cmd data

        --------------------------------
        -- Reset/Test Pin
        --------------------------------
        CpSl_RstVld_o                   : out std_logic;                        -- FPGA Reset Valid
        CpSl_FpgaRst_o                  : out std_logic;                        -- FPGA Reset
        CpSv_SelectIO_o                 : out std_logic_vector(17 downto 0)     -- Test IO select
    );
    end component;

    ----------------------------------------------------------------------------
    -- signal declaration
    ---------------------------------------------------------------------------- 
    signal PrSl_Clk100M_s               : std_logic;                            -- Clock 100M Single
    signal PrSl_Rst_sN                  : std_logic;                            -- System Reset
    signal PrSl_FpgaVld_s               : std_logic;                            -- FPGA Style Valid
    signal PrSv_FpgaType_s              : std_logic_vector(7 downto 0);         -- FPGA Style      
    signal PrSl_VolDvld_s               : std_logic;                            -- Parallel Voltage data valid  
    signal PrSv_VolData_s               : std_logic_vector(71 downto 0);        -- Parallel Voltage data        
    signal PrSl_CurtDvld_s              : std_logic;                            -- Parallel Current data valid  
    signal PrSv_CurtData_s              : std_logic_vector(71 downto 0);        -- Parallel Current data        
    signal PrSl_JtagDvld_s              : std_logic;                            -- Parallel JTAG data valid     
    signal PrSv_JtagData_s              : std_logic_vector(23 downto 0);        -- Parallel JTAG data           
    signal PrSl_TestDvld_s              : std_logic;                            -- Parallel Test_Cmd data valid 
    signal PrSv_TestData_s              : std_logic_vector(23 downto 0);        -- Parallel Test_Cmd data       
    signal PrSl_RstVld_s                : std_logic;                            -- FPGA Reset Valid    
    signal PrSl_CmpVolVld_s             : std_logic;                            -- Copmare Voltage Valid      
    signal PrSv_CmpVolData_s            : std_logic_vector(10 downto 0);        -- Copmare Voltage Valid Data 
    signal PrSl_CmpInd_s                : std_logic;                            -- Comapre Current Result
    signal PrSl_CmpCurtVld_s            : std_logic;                            -- Compare Current Valid      
    signal PrSv_CmpCurtData_s           : std_logic_vector(10 downto 0);        -- Compare Current Valid Data 
    signal PrSv_VoltageResult_s         : std_logic_vector( 6 downto 0);        -- Compare Voltage for current used
    
begin
    ------------------------------------
    -- Clock
    ------------------------------------
    U_M_ClkPll_0 : M_ClkPll port map(
        areset                          => '0'                                  ,-- std_logic;
        inclk0                          => CpSl_Clk_i                           ,-- std_logic;
        c0                              => PrSl_Clk100M_s                       ,-- std_logic;
        locked                          => PrSl_Rst_sN                           -- std_logic
    );

    ------------------------------------
    -- FPGA Type
    ------------------------------------
    U_M_FpgaType_0 : M_FpgaType port map(
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     => PrSl_Rst_sN                          , -- std_logic;                    -- Reset, active low 
        CpSl_Clk_i                      => PrSl_Clk100M_s                       , -- std_logic;                    -- 100MHz clock      
                                                                                                                  
        --------------------------------                                                                          
        -- GPIO                                                                                                   
        --------------------------------                                                                          
        CpSv_Gpio_i                     => CpSv_Gpio_i                          , -- std_logic_vector(2 downto 0); -- GPIO             
                                                                                  
        --------------------------------                                                                            
        -- FPGA Style                                                                                               
        --------------------------------                                                                            
        CpSl_FpgaVld_o                  => PrSl_FpgaVld_s                       , -- std_logic;                    -- FPGA Style Valid  
        CpSv_FpgaType_o                 => PrSv_FpgaType_s                        -- std_logic_vector(7 downto 0)  -- FPGA Style        
    );

    ------------------------------------
    -- Uart Rx/Tx
    ------------------------------------
    U_M_UartTop_0 : M_UartTop port map(
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     => PrSl_Rst_sN                          , -- std_logic; Reset, active low                
        CpSl_Clk_i                      => PrSl_Clk100M_s                       , -- std_logic; 100MHz clock                     
                                                                                                                                                    
        --------------------------------                                                                                                            
        -- Uart Receive Interface                                                                                                                   
        --------------------------------                                                                                                            
        CpSl_RxD_i                      => CpSl_RxD_i                           , -- std_logic; Receive Data                     
        CpSl_TxD_o                      => CpSl_TxD_o                           , -- std_logic; Send Data                        
                                                                                                                                 
        --------------------------------                                                                                         
        -- FPGA Type                                                                                                             
        --------------------------------                                                                                         
        CpSl_FpgaVld_i                  => PrSl_FpgaVld_s                       , -- std_logic;                    FPGA Style Valid                 
        CpSv_FpgaType_i                 => PrSv_FpgaType_s                      , -- std_logic_vector(7 downto 0); FPGA Style                       
                                                                                                                                 
        --------------------------------                                                                                         
        -- Test FPGA Reset/Vol/Curt                                                                                              
        --------------------------------                                                                                         
        CpSl_RstVld_i                   => PrSl_RstVld_s                        , -- std_logic;                     Test Fpga Reset                  
        CpSl_CmpVolVld_i                => PrSl_CmpVolVld_s                     , -- std_logic;                     Copmare Voltage Valid            
        CpSv_CmpVolData_i               => PrSv_CmpVolData_s                    , -- std_logic_vector(10 downto 0)  Copmare Voltage Valid Data       
        CpSl_CmpCurtVld_i               => PrSl_CmpCurtVld_s                    , -- std_logic;                     Compare Current Valid            
        CpSv_CmpCurtData_i              => PrSv_CmpCurtData_s                   , -- std_logic_vector(10 downto 0); Compare Current Valid Data       
                             
        --------------------------------
        -- Parallel Command Indicator
        --------------------------------
        CpSl_TestDvld_i                 => PrSl_TestDvld_s                      , -- Parallel Test_Cmd data valid
        CpSv_TestData_i                 => PrSv_TestData_s                      , -- Parallel Test_Cmd data
                                                                                                                                 
        --------------------------------                                                                                         
        -- Vol/Curt/Cmd output                                                                                                   
        --------------------------------                                                                                         
        CpSl_VolDvld_o                  => PrSl_VolDvld_s                       , -- std_logic;                     Parallel Voltage data valid      
        CpSv_VolData_o                  => PrSv_VolData_s                       , -- std_logic_vector(71 downto 0); Parallel Voltage data            
        CpSl_CurtDvld_o                 => PrSl_CurtDvld_s                      , -- std_logic;                     Parallel Current data valid      
        CpSv_CurtData_o                 => PrSv_CurtData_s                      , -- std_logic_vector(71 downto 0); Parallel Current data            
        CpSl_JtagDvld_o                 => PrSl_JtagDvld_s                      , -- std_logic;                     Parallel JTAG data valid         
        CpSv_JtagData_o                 => PrSv_JtagData_s                      , -- std_logic_vector(23 downto 0); Parallel JTAG data               
        CpSl_TestDvld_o                 => PrSl_TestDvld_s                      , -- std_logic;                     Parallel Test_Cmd data valid     
        CpSv_TestData_o                 => PrSv_TestData_s                        -- std_logic_vector(23 downto 0)  Parallel Test_Cmd data           
    );

    ------------------------------------
    -- Compare Voltage/Current
    ------------------------------------
    U_M_CmparVol_0 : M_CmparVol port map(
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     => PrSl_Rst_sN                          , -- std_logic;                     Reset, active low                              
        CpSl_Clk_i                      => PrSl_Clk100M_s                       , -- std_logic;                     100MHz Clock,single                            
                                                                                                                                                             
        --------------------------------                                                                                                                     
        -- Receive Standard Voltage                                                                                                                          
        --------------------------------                                                                                                                     
        CpSl_VolDVld_i                  => PrSl_VolDvld_s                       , -- std_logic;                     Voltage Parallel data valid                    
        CpSv_VolData_i                  => PrSv_VolData_s                       , -- std_logic_vector(71 downto 0); Voltage Parallel data                          
                                                                                                                                                             
        --------------------------------                                                                                                                     
        -- Receive FPGA Type                                                                                                                                 
        --------------------------------                                                                                                                     
        CpSl_FpgaVld_i                  => PrSl_FpgaVld_s                       , -- std_logic;                     FPGA Style Valid  
              
        --------------------------------
        -- Current Compare Reault
        --------------------------------
        CpSl_CmpInd_i                   => PrSl_CmpInd_s                        , -- std_logic                      Compare Current Result                       
                                                                                                                                                             
        --------------------------------                                                                                                                     
        -- ADC Interface                                                                                                                                     
        --------------------------------                                                                                                                     
        CpSl_AdcSclk_o                  => CpSl_AdcSclk_o                       , -- std_logic;                     ADC Clock    
        CpSl_AdcCS_o                    => CpSl_AdcCS_o                         , -- std_logic;                     ADC CS_U122
        CpSl_AdcCS1_o                   => CpSl_AdcCS1_o                        , -- std_logic;                     ADC CS_U123
        CpSl_AdcConfigData_o            => CpSl_AdcConfigData_o                 , -- std_logic;                     ADC Configuration Data
        CpSl_AdcData_i                  => CpSl_AdcData_i                       , -- std_logic;                     U122 & U123 Chip ADC Transfer Data
                                          
        --------------------------------                                                                                                                     
        -- Compare Voltage Result                                                                                                                            
        --------------------------------                                                                                                                     
        CpSv_RelayVol_o                 => CpSv_RelayVol_o                      , -- std_logic_vector( 3 downto 0); Control voltage Relay(5V/3.3V/2.5V/1.5V)       
        CpSl_CmpVolVld_o                => PrSl_CmpVolVld_s                     , -- std_logic;                     Copmare Voltage Valid                 
        CpSv_VoltageResult_o            => PrSv_VoltageResult_s                 , -- std_logic_vector( 6 downto 0); Compare Voltage for current used         
        CpSv_CmpVolData_o               => PrSv_CmpVolData_s                      -- std_logic_vector(10 downto 0)  Copmare Voltage Valid Data                     
    );
        
    U_M_CmparCurt_0 : M_CmparCurt port map(
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     => PrSl_Rst_sN                          , -- std_logic;                     Reset, active low                    
        CpSl_Clk_i                      => PrSl_Clk100M_s                       , -- std_logic;                     100MHz Clock,single                  
                                                                                                                                                       
        --------------------------------                                                                                                               
        -- FPGA Standard Current                                                                                                                       
        --------------------------------                                                                                                               
        CpSl_CurtDvld_i                 => PrSl_CurtDvld_s                      , -- std_logic;                     Parallel Voltage data valid          
        CpSv_CurtData_i                 => PrSv_CurtData_s                      , -- std_logic_vector(71 downto 0); Parallel Voltage data                
                                                                                                                                                       
        --------------------------------                                                                                                               
        -- Compare Voltage Result                                                                                                                      
        --------------------------------                                                                                                               
        CpSl_CmpVolVld_i                => PrSl_CmpVolVld_s                     , -- std_logic;                     Copmare Voltage Valid                
        CpSv_VoltageResult_i            => PrSv_VoltageResult_s                 , -- std_logic_vector(6 downto 0)   Compare Voltage for current used      
          
        --------------------------------                                                                                                               
        -- Test FPGA Reset Valid                                                                                                                       
        --------------------------------   
        CpSl_JtagDvld_i                 => PrSl_JtagDvld_s                      , -- std_logic;                     Parallel JTAG data valid                                                                                                            
        CpSl_RstVld_i                   => PrSl_RstVld_s                        , -- std_logic;                     FPGA Reset Valid                     

        --------------------------------                                                                                                  
        -- Control Relay Voltage                                                                                                          
        --------------------------------                                                                                                  
        CpSv_VadjCtrl_o                 => CpSv_VadjCtrl_o                      , -- std_logic_vector( 2 downto 0); Control Vadj Relay                   
        CpSv_RelayEn_o                  => CpSv_RelayEn_o                       , -- std_logic_vector( 2 downto 0); F_En Voltage                         
                                                                                                                                          
        --------------------------------                                                                                                               
        -- ADC Current Interface
        --------------------------------                                                                                                               
        CpSl_CurtAdcClk_o               => CpSl_CurtAdcClk_o                    , -- std_logic;                     ADC Clock                            
        CpSl_CurtAdcCS_o                => CpSl_CurtAdcCS_o                     , -- std_logic;                     ADC CS                               
        CpSl_CurtAdcConfigData_o        => CpSl_CurtAdcConfigData_o             , -- std_logic;                     ADC Configuration Data               
        CpSl_CurtAdcData_i              => CpSl_CurtAdcData_i                   , -- std_logic;                     ADC Transfer Data                    
                                                                                                                                                       
        --------------------------------                                                                                                               
        -- Compare Current Result                                                                                                                      
        --------------------------------
        CpSl_CmpInd_o                   => PrSl_CmpInd_s                        , -- std_logic_vector( 1 downto 0)  Compare Current Result                                                                                                               
        CpSl_CmpCurtVld_o               => PrSl_CmpCurtVld_s                    , -- std_logic;                     Copmare Valid                        
        CpSv_CmpCurtData_o              => PrSv_CmpCurtData_s                     -- std_logic_vector(10 downto 0)  Copmare Valid Data                   
    );                                                                                                                                                 

    U_M_CmdParse_0 : M_CmdParse port map(
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     => PrSl_Rst_sN                          , -- std_logic;                     Reset, active low                     
        CpSl_Clk_i                      => PrSl_Clk100M_s                       , -- std_logic;                     100MHz clock                          
                                                                                                                                                      
        --------------------------------                                                                                                              
        -- JTAG/Test Valid                                                                                                                            
        --------------------------------                                                                                                              
        CpSl_JtagDvld_i                 => PrSl_JtagDvld_s                      , -- std_logic;                     Parallel JTAG data valid              
        CpSv_JtagData_i                 => PrSv_JtagData_s                      , -- std_logic_vector(23 downto 0); Parallel JTAG data                    
        CpSl_TestDvld_i                 => PrSl_TestDvld_s                      , -- std_logic;                     Parallel Test_Cmd data valid          
        CpSv_TestData_i                 => PrSv_TestData_s                      , -- std_logic_vector(23 downto 0); Parallel Test_Cmd data                
                                                                                                                                                      
        --------------------------------                                                                                                              
        -- Reset/Test Pin                                                                                                                             
        --------------------------------                                        
        CpSl_RstVld_o                   => PrSl_RstVld_s                        , -- std_logic;                     FOGA Reset Valid                      
        CpSl_FpgaRst_o                  => CpSl_FpgaRst_o                       , -- std_logic;                     FPGA Reset                            
        CpSv_SelectIO_o                 => CpSv_SelectIO_o                        -- std_logic_vector(17 downto 0)  Test IO select                        
    );                                                                                                                                                

end arch_M_Top;

--------------------------------------------------------------------------------
-- Jesus
--------------------------------------------------------------------------------