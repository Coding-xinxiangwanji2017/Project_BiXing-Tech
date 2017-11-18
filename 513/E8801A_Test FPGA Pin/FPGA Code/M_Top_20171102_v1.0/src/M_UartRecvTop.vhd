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
-- 文件名称  :  M_UartRecvTop.vhd
-- 设    计  :  Zhang Wenjun
-- 邮    件  :  wenjunzhang@bixing-tech.com
-- 校    对  :  
-- 设计日期  :  2017/07/10
-- 功能简述  :  Uart receive, transfer to parallel data
--              Receive voltage/Current/JTAG_cmd/Test Pins_cmd 
-- 版本序号  :  0.1
-- 修改历史  :  1. Initial, Zhang Wenjun, 2017/07/10
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity M_UartRecvTop is
    port (
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
        CpSl_TestDvld_o                 : out std_logic;                        -- Parallel Tesst_Cmd data valid
        CpSv_TestData_o                 : out std_logic_vector(23 downto 0)     -- Parallel Test_Cmd data
    );
end M_UartRecvTop;

architecture arch_M_UartRecvTop of M_UartRecvTop is
    ----------------------------------------------------------------------------
    -- constant declaration
    ----------------------------------------------------------------------------
    
    ----------------------------------------------------------------------------
    -- component declaration
    ----------------------------------------------------------------------------
    component M_RecvVol is port (
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      : in  std_logic;                        -- 100MHz Clock,single

        --------------------------------
        -- Uart Receive Interface
        --------------------------------
        CpSl_RxD_i                      : in  std_logic;                        -- Receive Voltage Data

        --------------------------------
        -- Parallel Voltage Indicator
        --------------------------------
        CpSl_VolDvld_o                  : out std_logic;                        -- Parallel Voltage data valid
        CpSv_VolData_o                  : out std_logic_vector(71 downto 0)     -- Parallel Voltage data
    );
    end component;
        
    component M_RecvCurt is port (
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      : in  std_logic;                        -- 100MHz Clock,single

        --------------------------------
        -- Uart Receive Interface
        --------------------------------
        CpSl_RxD_i                      : in  std_logic;                        -- Receive Current Data

        --------------------------------
        -- Parallel Current Indicator
        --------------------------------
        CpSl_CurtDvld_o                 : out std_logic;                        -- Parallel Current data valid
        CpSv_CurtData_o                 : out std_logic_vector(71 downto 0)     -- Parallel Current data
    );
    end component;
    
    component M_RecvCmd is port (
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      : in  std_logic;                        -- 100MHz Clock,single

        --------------------------------
        -- Uart Receive Interface
        --------------------------------
        CpSl_RxD_i                      : in  std_logic;                        -- Receive Command Data

        --------------------------------
        -- Parallel Command Indicator
        --------------------------------
        CpSl_JtagDvld_o                 : out std_logic;                        -- Parallel JTAG data valid
        CpSv_JtagData_o                 : out std_logic_vector(23 downto 0);    -- Parallel JTAG data
        CpSl_TestDvld_o                 : out std_logic;                        -- Parallel Test_Cmd data valid
        CpSv_TestData_o                 : out std_logic_vector(23 downto 0)     -- Parallel Test_Cmd data
    );
    end component;

    ----------------------------------------------------------------------------
    -- signal declaration
    ----------------------------------------------------------------------------
    
begin
    ----------------------------------------------------------------------------
    -- component map declaration
    ----------------------------------------------------------------------------
    U_M_RecvVol : M_RecvVol port map (
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     => CpSl_Rst_iN                          , -- Reset, active low
        CpSl_Clk_i                      => CpSl_Clk_i                           , -- 100MHz Clock,single

        --------------------------------
        -- Uart Receive Interface
        --------------------------------
        CpSl_RxD_i                      => CpSl_RxD_i                           , -- in  std_logic

        --------------------------------
        -- Parallel Voltage Indicator
        --------------------------------
        CpSl_VolDvld_o                  => CpSl_VolDvld_o                       , -- out std_logic
        CpSv_VolData_o                  => CpSv_VolData_o                         -- out std_logic_vector(71 downto 0)
    );
    
    U_M_RecvCurt : M_RecvCurt port map (
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     => CpSl_Rst_iN                          , -- Reset, active low
        CpSl_Clk_i                      => CpSl_Clk_i                           , -- 100MHz Clock,single

        --------------------------------
        -- Uart Receive Interface
        --------------------------------
        CpSl_RxD_i                      => CpSl_RxD_i                           , -- in  std_logic

        --------------------------------
        -- Parallel Current Indicator
        --------------------------------
        CpSl_CurtDvld_o                 => CpSl_CurtDvld_o                      , -- out std_logic                     
        CpSv_CurtData_o                 => CpSv_CurtData_o                        -- out std_logic_vector(71 downto 0) 
    );
    
    U_M_RecvCmd : M_RecvCmd port map (
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     => CpSl_Rst_iN                          , -- Reset, active low
        CpSl_Clk_i                      => CpSl_Clk_i                           , -- 100MHz Clock,single
                                                                                
        --------------------------------                                        
        -- Uart Receive Interface                                               
        --------------------------------                                        
        CpSl_RxD_i                      => CpSl_RxD_i                           , -- in  std_logic

        --------------------------------
        -- Parallel Command Indicator
        --------------------------------
        CpSl_JtagDvld_o                 => CpSl_JtagDvld_o                      , -- out std_logic                      
        CpSv_JtagData_o                 => CpSv_JtagData_o                      , -- out std_logic_vector(23 downto 0)  
        CpSl_TestDvld_o                 => CpSl_TestDvld_o                      , -- out std_logic                      
        CpSv_TestData_o                 => CpSv_TestData_o                        -- out std_logic_vector(23 downto 0)  
    );

end arch_M_UartRecvTop;