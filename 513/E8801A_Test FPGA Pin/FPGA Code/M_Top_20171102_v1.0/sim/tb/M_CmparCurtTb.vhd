library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity M_CmparCurtTb is
end M_CmparCurtTb;

architecture arch_M_CmparCurtTb of M_CmparCurtTb is
    ------------------------------------
    -- constant declaration
    ------------------------------------
    constant PrSv_VolData_c             : std_logic_vector(110 downto 0) := '1'&x"88"&'0'&'1'&x"13"&'0'&'1'&x"E4"&'0'&'1'&x"0C"&'0'
                                                                            &'1'&x"C4"&'0'&'1'&x"09"&'0'&'1'&x"DC"&'0'&'1'&x"05"&'0'
                                                                            &'1'&x"C1"&'0'&'1'&x"4A"&'0'&'1'&x"A5"&'0'&'1';

    ------------------------------------
    -- component declaration
    ------------------------------------
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
        CpSl_CmpCurtVld_o               : out std_logic;                        -- Copmare Valid
        CpSv_CmpCurtData_o              : out std_logic_vector( 6 downto 0)     -- Copmare Valid Data
    );
    end component;
    
    ----------------------------------------------------------------------------
    --signal declaration
    ----------------------------------------------------------------------------
    signal CpSl_Rst_iN                  : std_logic;                            -- Reset, active low  
    signal CpSl_Clk_i                   : std_logic;                            -- 100MHz Clock,single
    signal CpSl_CurtDvld_i              : std_logic;                            -- Parallel Voltage data valid   
    signal CpSv_CurtData_i              : std_logic_vector(71 downto 0);        -- Parallel Voltage data         
    signal CpSl_CmpVolVld_i             : std_logic;                            -- Copmare Voltage Valid        
    signal CpSv_VoltageResult_i         : std_logic_vector( 6 downto 0);        -- Copmare Voltage Valid Data   
    signal CpSl_RstVld_i                : std_logic;                            -- FPGA Reset Valid 
    signal CpSv_VadjCtrl_o              : std_logic_vector( 2 downto 0);        -- Control Vadj Relay   
    signal CpSv_RelayEn_o               : std_logic_vector( 2 downto 0);        -- F_En Voltage         
    signal CpSl_CurtAdcClk_o            : std_logic;                            -- ADC Clock                
    signal CpSl_CurtAdcCS_o             : std_logic;                            -- ADC CS                   
    signal CpSl_CurtAdcConfigData_o     : std_logic;                            -- ADC Configuration Data   
    signal CpSl_CurtAdcData_i           : std_logic;                            -- ADC Transfer Data           
    signal CpSl_CmpCurtVld_o            : std_logic;                            -- Copmare Valid         
    signal CpSv_CmpCurtData_o           : std_logic_vector( 6 downto 0);        -- Copmare Valid Data    
    
    ----------------------------------------------------------------------------
    --constant declaration
    ----------------------------------------------------------------------------

begin
    ----------------------------------------------------------------------------
    --component map
    ----------------------------------------------------------------------------
    U_M_CmparCurt : M_CmparCurt port map(
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     => CpSl_Rst_iN                          , -- Reset, active low
        CpSl_Clk_i                      => CpSl_Clk_i                           , -- 100MHz Clock,single
                                                                                 
        --------------------------------                                         
        -- FPGA Standard Current                                                 
        --------------------------------                                         
        CpSl_CurtDvld_i                 => CpSl_CurtDvld_i                      , -- Parallel Voltage data valid
        CpSv_CurtData_i                 => CpSv_CurtData_i                      , -- Parallel Voltage data
                                                                                  
        --------------------------------                                          
        -- Compare Voltage Result                                                 
        --------------------------------                                          
        CpSl_CmpVolVld_i                => CpSl_CmpVolVld_i                     , -- Copmare Voltage Valid
        CpSv_VoltageResult_i            => CpSv_VoltageResult_i                 , -- Copmare Voltage Valid Data
                                                                                  
        --------------------------------                                          
        -- Test FPGA Reset Valid                                                  
        --------------------------------                                          
        CpSl_RstVld_i                   => CpSl_RstVld_i                        , -- FPGA Reset Valid
                                                                                  
        --------------------------------                                          
        -- Control Relay Voltage                                                  
        --------------------------------                                          
        CpSv_VadjCtrl_o                 => CpSv_VadjCtrl_o                      , -- Control Vadj Relay
        CpSv_RelayEn_o                  => CpSv_RelayEn_o                       , -- F_En Voltage
                                                                                  
        --------------------------------                                          
        -- ADC Current Interface                                                  
        --------------------------------                                          
        CpSl_CurtAdcClk_o               => CpSl_CurtAdcClk_o                    , -- ADC Clock
        CpSl_CurtAdcCS_o                => CpSl_CurtAdcCS_o                     , -- ADC CS
        CpSl_CurtAdcConfigData_o        => CpSl_CurtAdcConfigData_o             , -- ADC Configuration Data
        CpSl_CurtAdcData_i              => CpSl_CurtAdcData_i                   , -- ADC Transfer Data
                                                                                  
        --------------------------------                                          
        -- Compare Current Result                                                 
        --------------------------------                                          
        CpSl_CmpCurtVld_o               => CpSl_CmpCurtVld_o                    , -- Copmare Valid
        CpSv_CmpCurtData_o              => CpSv_CmpCurtData_o                     -- Copmare Valid Data
    );
    
    ----------------------------------------------------------------------------
    -- Rst & Clk
    ----------------------------------------------------------------------------
    process begin
        CpSl_Rst_iN <= '0';
        wait for 100 ns;
        CpSl_Rst_iN <= '1';
        wait;
    end process;

    process begin
        CpSl_Clk_i <= '0';
        wait for 5 ns;
        CpSl_Clk_i <= '1';
        wait for 5 ns;
    end process;

    ------------------------------------
    -- CpSl_CmpVolVld_i
    ------------------------------------
    process begin
        CpSl_CmpVolVld_i <= '0';
        wait for 1 us;
        CpSl_CmpVolVld_i <= '1';
        wait for 2 us;
        CpSl_CmpVolVld_i <= '0';
        wait;
    end process;
    CpSv_VoltageResult_i <= "0100101";
    
    ------------------------------------
    -- CpSl_RstVld_i
    ------------------------------------
    process begin
        CpSl_RstVld_i <= '0';
        wait for 3 us;
        CpSl_RstVld_i <= '1';
        wait for 4 us;
        CpSl_RstVld_i <= '0';
        wait;
    end process;
    
    ------------------------------------
    -- CpSl_CurtDvld_i
    ------------------------------------
    process begin
        CpSl_CurtDvld_i <= '0';
        wait for 5 us;
        CpSl_CurtDvld_i <= '1';
        wait for 6 us;
        CpSl_CurtDvld_i <= '0';
        wait;
    end process;
    
    CpSv_CurtData_i <= x"C200640064EFFE0064";

    ------------------------------------
    -- CpSl_CurtAdcData_i
    ------------------------------------
    process begin
        CpSl_CurtAdcData_i <= '1';
        wait for 50070 us;
        CpSl_CurtAdcData_i <= '0';
        wait for 900 ns;
        CpSl_CurtAdcData_i <= '1';
        wait for 17 us;
        CpSl_CurtAdcData_i <= '0';
        wait;
    end process;
    
end arch_M_CmparCurtTb;