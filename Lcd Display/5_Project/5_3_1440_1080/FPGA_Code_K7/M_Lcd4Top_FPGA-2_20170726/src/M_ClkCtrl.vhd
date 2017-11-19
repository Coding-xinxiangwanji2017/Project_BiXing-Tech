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
-- �ļ�����  :  M_ClkCtrl.vhd
-- ��    ��  :  zhang wenjun
-- ��    ��  :  wenjunzhang@bixing-tech.com
-- У    ��  :
-- �������  :  2017/3/9
-- ���ܼ���  :  Colck Control
-- �汾���  :  0.1
-- �޸���ʷ  :  1. Initial, zhang wenjun, 2017/3/9
-- ��������  �� Choice the Clock 
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
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      : in  std_logic;                        -- Clock 100MHz, Signal
        
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
    component M_ClkPll port(
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
    
    component M_FreClkPll port(
        --------------------------------
        -- Clock in & Reset
        --------------------------------
        CLK_IN1           : in     std_logic;
        RESET             : in     std_logic;
        --------------------------------
        -- Clock out & Locked
        --------------------------------
        CLK_OUT1          : out    std_logic;
        LOCKED            : out    std_logic
    );
    end component;
    
    
    ----------------------------------------------------------------------------
    -- signal declaration
    ----------------------------------------------------------------------------
    -- Pll Clk
    signal PrSl_RstPll_s                : std_logic;                            -- Pll Reset
    signal PrSl_ClkBufg_s               : std_logic;                            -- Bufg Clock
    signal PrSl_Clk75M_s                : std_logic;                            -- Colck 75MHz
    signal PrSl_Clk105M_s               : std_logic;                            -- Colck 105MHz
    signal PrSl_Clk525M_s               : std_logic;                            -- Colck 525MHz
    signal PrSl_Clk735M_s               : std_logic;                            -- Colck 735MHz
    signal PrSl_PllLock_s               : std_logic;                            -- Clk Pll Lock
    signal PrSl_ClkPllLock_s            : std_logic;                            -- Clk Pll Locked
    signal PrSl_ClkFmc_s                : std_logic;                            -- Clk Fmc
    signal PrSl_ClkLcd_s                : std_logic;                            -- Clk Lcd
    signal PrSl_PllLocked_s             : std_logic;                            -- Pll Locked 
    signal PrSl_ClkFre_s                : std_logic;                            -- Frequence Clk
    signal PrSl_FrePllLocked_s          : std_logic;                            -- Frequence Clk Locked
    
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
    -- CLk_In1  ��100MHz 
    -- clk_out1 : 75MHz
    -- clk_out2 : 525MHz 
    ------------------------------------
    U_M_ClkPll_0 : M_ClkPll port map (
        reset                           => PrSl_RstPll_s                        , -- in  std_logic;
        clk_in1                         => PrSl_ClkBufg_s                       , -- in  std_logic;
        clk_out1                        => PrSl_Clk75M_s                        , -- out std_logic;
        clk_out2                        => PrSl_Clk525M_s                       , -- out std_logic;
        locked                          => PrSl_PllLock_s                         -- out std_logic
    );
    
    ------------------------------------
    -- Clock
    -- CLk_In1  ��100MHz 
    -- clk_out1 : 105MHz
    -- clk_out2 : 735MHz
    ------------------------------------
    U_M_CtrlClkPll_0 : M_CtrlClkPll port map (
        reset                           => PrSl_RstPll_s                        , -- in  std_logic;
        clk_in1                         => PrSl_ClkBufg_s                       , -- in  std_logic;
        clk_out1                        => PrSl_Clk105M_s                       , -- out std_logic;
        clk_out2                        => PrSl_Clk735M_s                       , -- out std_logic;
        locked                          => PrSl_ClkPllLock_s                      -- out std_logic
    );
    
    ------------------------------------
    -- Clock
    -- CLk_In1  ��100MHz 
    -- clk_out1 : 100MHz
    ------------------------------------
    U_M_FreClkPll_0 : M_FreClkPll port map (
        reset                           => PrSl_RstPll_s                        , -- in  std_logic;
        clk_in1                         => PrSl_ClkBufg_s                       , -- in  std_logic;
        clk_out1                        => PrSl_ClkFre_s                        , -- out std_logic;
        locked                          => PrSl_FrePllLocked_s                    -- out std_logic;
    );
    
    -- Pll Locked
    PrSl_PllLocked_s <= '1' when (PrSl_PllLock_s = '1' and PrSl_ClkPllLock_s = '1' and PrSl_FrePllLocked_s = '1') 
                            else '0';
    
    ------------------------------------
    -- BUFGMUX 
    -- S =  '0'   : O => I0 
    -- S =  '1'   : O => I1
    -- S = others : O => '0'
    -- Choice 75MHz/105MHz
    ------------------------------------
    U_BUFGMUX_0 : BUFGMUX
    port map (
        O  => PrSl_ClkLcd_s,    -- 1-bit output: Clock output
        I0 => PrSl_Clk105M_s,   -- 1-bit input: Clock input (S=0)
        I1 => PrSl_Clk75M_s,    -- 1-bit input: Clock input (S=1)
        S  => CpSl_ClkSel_i     -- 1-bit input: Clock select
    );
    
    ------------------------------------
    -- BUFGMUX 
    -- S = '0' : O => I0 
    -- S = '1' : O => I1
    -- Choice 525MHz/735MHz
    ------------------------------------
    U_BUFGMUX_1 : BUFGMUX
    port map (
        O  => PrSl_ClkFmc_s,    -- 1-bit output: Clock output
        I0 => PrSl_Clk735M_s,   -- 1-bit input: Clock input (S=0)
        I1 => PrSl_Clk525M_s,   -- 1-bit input: Clock input (S=1)
        S  => CpSl_ClkSel_i     -- 1-bit input: Clock select
    );
    
    ------------------------------------
    -- ouput signal 
    ------------------------------------
    CpSl_PllLocked_o <= PrSl_PllLocked_s;
    CpSl_ClkFmc_o    <= PrSl_ClkFmc_s;
    CpSl_ClkLcd_o    <= PrSl_ClkLcd_s;
    CpSl_ClkFre_o    <= PrSl_ClkFre_s;


end arch_M_ClkCtrl;    
