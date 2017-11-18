library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity M_CmparVolTb is
end M_CmparVolTb;

architecture arch_M_CmparVolTb of M_CmparVolTb is
    ------------------------------------
    -- constant declaration
    ------------------------------------
    constant PrSv_VolData_c             : std_logic_vector(110 downto 0) := '1'&x"88"&'0'&'1'&x"13"&'0'&'1'&x"E4"&'0'&'1'&x"0C"&'0'
                                                                            &'1'&x"C4"&'0'&'1'&x"09"&'0'&'1'&x"DC"&'0'&'1'&x"05"&'0'
                                                                            &'1'&x"C1"&'0'&'1'&x"4A"&'0'&'1'&x"A5"&'0'&'1';

    ------------------------------------
    -- component declaration
    ------------------------------------
    component M_CmparVol is port (
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
        -- ADC Voltage Interface
        --------------------------------
        CpSl_AdcSclk_o                  : out std_logic;                        -- ADC Clock
        CpSl_AdcCS_o                    : out std_logic;                        -- ADC CS
        CpSl_AdcConfigData_o            : out std_logic;                        -- ADC Configuration Data
        CpSl_AdcData_i                  : in  std_logic;                        -- ADC Transfer Data

        --------------------------------
        -- Compare Voltage Result
        --------------------------------
        CpSv_RelayVol_o                 : out std_logic_vector( 3 downto 0);    -- Control voltage Relay(5V/3.3V/2.5V/1.5V)
        CpSl_CmpVolVld_o                : out std_logic;                        -- Copmare Voltage Valid
        CpSv_CmpVolData_o               : out std_logic_vector(10 downto 0)     -- Copmare Voltage Valid Data
    );
    end component;
    
    ----------------------------------------------------------------------------
    --signal declaration
    ----------------------------------------------------------------------------
    signal CpSl_Rst_iN                  : std_logic;
    signal CpSl_Clk_i                   : std_logic;
    signal CpSl_VolDVld_i               : std_logic;                        -- Voltage Parallel data valid                 
    signal CpSv_VolData_i               : std_logic_vector(71 downto 0);    -- Voltage Parallel data            
    signal CpSl_FpgaVld_i               : std_logic;                        -- FPGA Style Valid
    signal CpSl_AdcSclk_o               : std_logic;                        -- ADC Clock                 
    signal CpSl_AdcCS_o                 : std_logic;                        -- ADC CS                
    signal CpSl_AdcConfigData_o         : std_logic;                        -- ADC Configuration Data
    signal CpSl_AdcData_i               : std_logic;                        -- ADC Transfer Data     
    signal CpSv_RelayVol_o              : std_logic_vector( 3 downto 0);    -- Control voltage Relay(5V/3.3V/2.5V/1.5V) 
    signal CpSl_CmpVolVld_o             : std_logic;                        -- Copmare Voltage Valid                    
    signal CpSv_CmpVolData_o            : std_logic_vector(10 downto 0);    -- Copmare Voltage Valid Data               

    ----------------------------------------------------------------------------
    --constant declaration
    ----------------------------------------------------------------------------

begin
    ----------------------------------------------------------------------------
    --component map
    ----------------------------------------------------------------------------
    U_M_CmparVol : M_CmparVol port map(
        --------------------------------
        -- Reset and Clock
        --------------------------------
        CpSl_Rst_iN                     => CpSl_Rst_iN                          , -- Reset, Active low
        CpSl_Clk_i                      => CpSl_Clk_i                           , -- 100MHz Clock

        --------------------------------
        -- Receive Standard Voltage 
        --------------------------------
        CpSl_VolDVld_i                  => CpSl_VolDVld_i                       , -- Voltage Parallel data valid
        CpSv_VolData_i                  => CpSv_VolData_i                       , -- Voltage Parallel data

        --------------------------------
        -- Receive FPGA Type
        --------------------------------
        CpSl_FpgaVld_i                  => CpSl_FpgaVld_i                       , -- FPGA Style Valid

        --------------------------------
        -- ADC Voltage Interface
        --------------------------------
        CpSl_AdcSclk_o                  => CpSl_AdcSclk_o                       , -- ADC Clock
        CpSl_AdcCS_o                    => CpSl_AdcCS_o                         , -- ADC CS
        CpSl_AdcConfigData_o            => CpSl_AdcConfigData_o                 , -- ADC Configuration Data
        CpSl_AdcData_i                  => CpSl_AdcData_i                       , -- ADC Transfer Data

        --------------------------------
        -- Compare Voltage Result
        --------------------------------
        CpSv_RelayVol_o                 => CpSv_RelayVol_o                      , -- Control voltage Relay(5V/3.3V/2.5V/1.5V)
        CpSl_CmpVolVld_o                => CpSl_CmpVolVld_o                     , -- Copmare Voltage Valid
        CpSv_CmpVolData_o               => CpSv_CmpVolData_o                      -- Copmare Voltage Valid Data
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
    -- CpSl_FpgaVld_i
    ------------------------------------
    process begin
        CpSl_FpgaVld_i <= '0';
        wait for 400 ns;
        CpSl_FpgaVld_i <= '1';
        wait for 500 ns;
        CpSl_FpgaVld_i <= '0';
        wait;
    end process;
    
    
    ------------------------------------
    -- CpSl_VolDVld_i
    ------------------------------------
    process begin
        CpSl_VolDVld_i <= '0';
        wait for 520 us;
        CpSl_VolDVld_i <= '1';
        wait for 530 us;
        CpSl_VolDVld_i <= '0';
        wait;
    end process;
    
    CpSv_VolData_i <= x"C2EFFE044AEFFE01F3";
    
    ------------------------------------
    -- CpSl_AdcData_i
    ------------------------------------
    process begin
        CpSl_AdcData_i <= '1';
        wait for 66000 ns;
        CpSl_AdcData_i <= '0';
        wait for 8100 ns;
        CpSl_AdcData_i <= '1';
        wait for 16000 ns;
        CpSl_AdcData_i <= '0';
        wait for 50000 ns;
        CpSl_AdcData_i <= '1';
        wait for 66000 ns;
        CpSl_AdcData_i <= '0';
        wait for 8100 ns;
        CpSl_AdcData_i <= '1';
        wait for 16000 ns;
        CpSl_AdcData_i <= '0';
        wait;
    end process;
    
end arch_M_CmparVolTb;