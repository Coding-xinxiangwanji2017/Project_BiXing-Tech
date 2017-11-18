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
-- 文件名称  :  M_UartTop.vhd
-- 设    计  :  Zhang Wenjun
-- 邮    件  :  wenjunzhang@bixing-tech.com
-- 校    对  :  
-- 设计日期  :  2017/07/10
-- 功能简述  :  Uart receive & Send Data
--              Send Compare FpgaType/voltage/Current to PC 
-- 版本序号  :  0.1
-- 修改历史  :  1. Initial, Zhang Wenjun, 2017/07/10
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity M_UartTop is
    port (
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
end M_UartTop;

architecture arch_M_UartTop of M_UartTop is
    ----------------------------------------------------------------------------
    -- constant declaration
    ----------------------------------------------------------------------------
    
    ----------------------------------------------------------------------------
    -- component declaration
    ----------------------------------------------------------------------------
    component M_UartRecvTop is port (
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      : in  std_logic;                        -- 100MHz clock

        --------------------------------
        -- Uart Receive Interface 
        --------------------------------
        CpSl_RxD_i                      : in  std_logic;                        -- Receive data

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
    
    component M_UartSend is port (
        --------------------------------
        -- Reset and Clock
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, Active low
        CpSl_Clk_i                      : in  std_logic;                        -- 100MHz Clock

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
        -- Uart Tx Data
        --------------------------------
        CpSl_TxD_o                      : out std_logic                         -- Transfer Data
    );
    end component;
    ----------------------------------------------------------------------------
    -- signal declaration
    ----------------------------------------------------------------------------

begin
    ----------------------------------------------------------------------------
    -- component map declaration
    ----------------------------------------------------------------------------
    U_M_UartRecvTop : M_UartRecvTop port map (
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     => CpSl_Rst_iN                          , -- Reset, active low
        CpSl_Clk_i                      => CpSl_Clk_i                           , -- 100MHz Clock,single
        --------------------------------
        -- Uart Receive Interface 
        --------------------------------
        CpSl_RxD_i                      => CpSl_RxD_i                           , -- Receive data

        --------------------------------
        -- Vol/Curt/Cmd output
        --------------------------------
        CpSl_VolDvld_o                  => CpSl_VolDvld_o                       , -- Parallel Voltage data valid
        CpSv_VolData_o                  => CpSv_VolData_o                       , -- Parallel Voltage data
        CpSl_CurtDvld_o                 => CpSl_CurtDvld_o                      , -- Parallel Current data valid
        CpSv_CurtData_o                 => CpSv_CurtData_o                      , -- Parallel Current data
        CpSl_JtagDvld_o                 => CpSl_JtagDvld_o                      , -- Parallel JTAG data valid
        CpSv_JtagData_o                 => CpSv_JtagData_o                      , -- Parallel JTAG data
        CpSl_TestDvld_o                 => CpSl_TestDvld_o                      , -- Parallel Test_Cmd data valid
        CpSv_TestData_o                 => CpSv_TestData_o                        -- Parallel Test_Cmd data
    );
    
    U_M_UartSend : M_UartSend port map (
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     => CpSl_Rst_iN                          , -- Reset, active low
        CpSl_Clk_i                      => CpSl_Clk_i                           , -- 100MHz Clock,single
        
        --------------------------------
        -- FPGA Type
        --------------------------------
        CpSl_FpgaVld_i                  => CpSl_FpgaVld_i                       , -- FPGA Style Valid
        CpSv_FpgaType_i                 => CpSv_FpgaType_i                      , -- FPGA Style

        --------------------------------
        -- Test FPGA Reset/Voltage/Current
        --------------------------------
        CpSl_RstVld_i                   => CpSl_RstVld_i                        , -- Test Fpga Reset
        CpSl_CmpVolVld_i                => CpSl_CmpVolVld_i                     , -- Copmare Voltage Valid
        CpSv_CmpVolData_i               => CpSv_CmpVolData_i                    , -- Copmare Voltage Valid Data
        CpSl_CmpCurtVld_i               => CpSl_CmpCurtVld_i                    , -- Compare Current Valid
        CpSv_CmpCurtData_i              => CpSv_CmpCurtData_i                   , -- Compare Current Valid Data

        --------------------------------
        -- Parallel Command Indicator
        --------------------------------
        CpSl_TestDvld_i                 => CpSl_TestDvld_i                      , -- Parallel Test_Cmd data valid
        CpSv_TestData_i                 => CpSv_TestData_i                      , -- Parallel Test_Cmd data

        --------------------------------
        -- Uart Tx Data
        --------------------------------
        CpSl_TxD_o                      => CpSl_TxD_o                            -- Transfer Data
    );

end arch_M_UartTop;