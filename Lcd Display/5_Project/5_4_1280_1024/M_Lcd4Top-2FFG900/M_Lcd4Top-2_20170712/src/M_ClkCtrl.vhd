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
-- 文件名称  :  M_ClkCtrl.vhd
-- 设    计  :  zhang wenjun
-- 邮    件  :  wenjunzhang@bixing-tech.com
-- 校    对  :
-- 设计日期  :  2017/3/9
-- 功能简述  :  Colck Control
-- 版本序号  :  0.1
-- 修改历史  :  1. Initial, zhang wenjun, 2017/3/9
-- 功能描述  ： Choice the Clock 
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

entity M_ClkCtrl is 
    port (
        --------------------------------
        -- Clk & Reset
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset active low
        CpSl_Clk_i                      : in  std_logic;                        -- Clock 80MHz, Singal
        
        --------------------------------
        -- Choice Clk
        --------------------------------
        CpSl_ClkSel_i                   : in  std_logic;                        -- Choice Clock
        
        --------------------------------
        -- Clk out
        --------------------------------
        CpSl_ClkFmc_o                   : out std_logic;                        -- Clock Fmc
        CpSl_ClkLcd_o                   : out std_logic;                        -- Clock Lcd
        CpSl_ClkFre_o                   : out std_logic;                        -- Clock FreCtrl
        CpSl_PllLocked_o                : out std_logic                         -- Clock Pll Locked 
    );
end M_ClkCtrl;

architecture arch_M_ClkCtrl of M_ClkCtrl is
    ----------------------------------------------------------------------------
    -- constant declaration
    ----------------------------------------------------------------------------

    ----------------------------------------------------------------------------
    -- component declaration
    ----------------------------------------------------------------------------
    component M_ClkPll port (
        --------------------------------
        -- Clock in & Reset
        --------------------------------
        reset                           : in  std_logic;
        clk_in1                         : in  std_logic;
        
        --------------------------------
        -- Clock out & Locked
        --------------------------------
        clk_out1                        : out std_logic;
        clk_out2                        : out std_logic;
        clk_out3                        : out std_logic;
        locked                          : out std_logic
    );
    end component;

--    component M_ClkPll port(
--        --------------------------------
--        -- Clock in & Reset
--        --------------------------------
--        CLK_IN1           : in     std_logic;
--        RESET             : in     std_logic;
--        --------------------------------
--        -- Clock out & Locked
--        --------------------------------
--        CLK_OUT1          : out    std_logic;
--        CLK_OUT2          : out    std_logic;
--        LOCKED            : out    std_logic
--    );
--    end component;
    
    component M_CtrlClkPll port(
       --------------------------------
        -- Clock in & Reset
        --------------------------------
        CLK_IN1           : in     std_logic;
        RESET             : in     std_logic;
        --------------------------------
        -- Clock out & Locked
        --------------------------------
        CLK_OUT1          : out    std_logic;
        CLK_OUT2          : out    std_logic;
        LOCKED            : out    std_logic
    );
    end component;
    
--    component M_FreClkPll port(
--        --------------------------------
--        -- Clock in & Reset
--        --------------------------------
--        CLK_IN1           : in     std_logic;
--        RESET             : in     std_logic;
--        --------------------------------
--        -- Clock out & Locked
--        --------------------------------
--        CLK_OUT1          : out    std_logic;
--        LOCKED            : out    std_logic
--    );
--    end component;
    
    
    ----------------------------------------------------------------------------
    -- signal declaration
    ----------------------------------------------------------------------------
    -- Pll Clk
    signal PrSl_RstPll_s                : std_logic;                            -- Pll Reset
    signal PrSl_ClkBufg_s               : std_logic;                            -- Bufg Clock
    signal PrSl_Clk80M_s                : std_logic;                            -- Colck 80MHz
    signal PrSl_Clk120M_s               : std_logic;                            -- Colck 120MHz
    signal PrSl_Clk560M_s               : std_logic;                            -- Colck 560MHz
    signal PrSl_Clk840M_s               : std_logic;                            -- Colck 840MHz
    signal PrSl_PllLock_s               : std_logic;                            -- Clk Pll Lock
    signal PrSl_ClkPllLock_s            : std_logic;                            -- Clk Pll Locked
    signal PrSl_ClkFmc_s                : std_logic;                            -- Clk Fmc
    signal PrSl_ClkLcd_s                : std_logic;                            -- Clk Lcd
    signal PrSl_PllLocked_s             : std_logic;                            -- Pll Locked 
    signal PrSl_ClkFre_s                : std_logic;                            -- Frequence Clk
    
begin
    ------------------------------------
    -- Reset 
    ------------------------------------
    PrSl_RstPll_s <= not CpSl_Rst_iN;
    
    ------------------------------------
    -- Bufg 
    ------------------------------------
    IBUFG_inst : IBUFG
    generic map (
        IBUF_LOW_PWR => TRUE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
        IOSTANDARD => "DEFAULT"
    )
    port map (
        O => PrSl_ClkBufg_s, -- Clock buffer output
        I => CpSl_Clk_i   -- Clock buffer input (connect directly to top-level port)
    );
    
    ------------------------------------
    -- Clock
    -- CLk_In1  : 100MHz 
    -- clk_out1 : 560MHz
    -- clk_out2 : 80MHz 
    -- clk_out3 : 80MHz
    ------------------------------------
    U_M_ClkPll_0 : M_ClkPll port map (
        reset                           => PrSl_RstPll_s                        , -- in  std_logic;
        clk_in1                         => PrSl_ClkBufg_s                       , -- in  std_logic;
        clk_out1                        => PrSl_Clk560M_s                       , -- out std_logic;
        clk_out2                        => PrSl_Clk80M_s                        , -- out std_logic;
        clk_out3                        => PrSl_ClkFre_s                        , -- out std_logic;
        locked                          => PrSl_PllLock_s                         -- out std_logic
    );
    
    ------------------------------------
    -- Clock
    -- CLk_In1  : 100MHz 
    -- clk_out1 : 120MHz
    -- clk_out2 : 840MHz
    ------------------------------------
    U_M_CtrlClkPll_0 : M_CtrlClkPll port map (
        reset                           => PrSl_RstPll_s                        , -- in  std_logic;
        clk_in1                         => PrSl_ClkBufg_s                       , -- in  std_logic;
        clk_out1                        => PrSl_Clk120M_s                       , -- out std_logic;
        clk_out2                        => PrSl_Clk840M_s                       , -- out std_logic;
        locked                          => PrSl_ClkPllLock_s                      -- out std_logic
    );
    

    -- Pll Locked
    PrSl_PllLocked_s <= '1' when (PrSl_PllLock_s = '1' and PrSl_ClkPllLock_s = '1') 
                            else '0';
    
    ------------------------------------
    -- BUFGMUX 
    -- S =  '0'   : O => I0 
    -- S =  '1'   : O => I1
    -- S = others : O => '0'
    -- Choice 80MHz/120MHz
    ------------------------------------
    U_BUFGMUX_0 : BUFGMUX
    port map (
        O  => PrSl_ClkLcd_s,            -- 1-bit output: Clock output
        I0 => PrSl_Clk80M_s,            -- 1-bit input: Clock input (S=0)
        I1 => PrSl_Clk120M_s,           -- 1-bit input: Clock input (S=1)
        S  => CpSl_ClkSel_i             -- 1-bit input: Clock select
    );
    
    ------------------------------------
    -- BUFGMUX 
    -- S = '0' : O => I0 
    -- S = '1' : O => I1
    -- Choice 560MHz/840MHz
    ------------------------------------
    U_BUFGMUX_1 : BUFGMUX
    port map (
        O  => PrSl_ClkFmc_s,            -- 1-bit output: Clock output
        I0 => PrSl_Clk560M_s,           -- 1-bit input: Clock input (S=0)
        I1 => PrSl_Clk840M_s,           -- 1-bit input: Clock input (S=1)
        S  => CpSl_ClkSel_i             -- 1-bit input: Clock select
    );
    
    ------------------------------------
    -- ouput signal 
    ------------------------------------
    CpSl_PllLocked_o <= PrSl_PllLocked_s;
    CpSl_ClkFmc_o    <= PrSl_ClkFmc_s;
    CpSl_ClkLcd_o    <= PrSl_ClkLcd_s;
    CpSl_ClkFre_o    <= PrSl_ClkFre_s;


end arch_M_ClkCtrl;    
