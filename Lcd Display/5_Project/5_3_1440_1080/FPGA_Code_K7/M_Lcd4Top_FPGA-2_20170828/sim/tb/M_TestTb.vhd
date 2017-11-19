library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity M_TestTb is
end M_TestTb;

architecture arch_M_TestTb of M_TestTb is

    ------------------------------------
    --component declaration
    ------------------------------------
    component M_Test port(
        --------------------------------
        --Rst & Clk
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                       --Rst, active low
        CpSl_Clk_i                      : in  std_logic;                       --Clk, 80Mhz

        --------------------------------
        -- Refersh Rate Choice
        --------------------------------
        CpSl_LcdVsync_i                 : in  std_logic;                        -- Lcd Vsync 
        CpSv_FreChoice_i                : in  std_logic_vector(2 downto 0);     -- FreChoice
        CpSv_VsyncTrig_i                : in  std_logic_vector(7 downto 0 );    -- Vsync Trig

        --------------------------------
        -- Pulse output
        --------------------------------
        CpSl_Vsync_o                    : out std_logic                         -- Vsync Pulse
    );
    end component;

    ----------------------------------------------------------------------------
    --signal declaration
    ----------------------------------------------------------------------------
    signal CpSl_Rst_iN                  : std_logic;
    signal CpSl_Clk_i                   : std_logic;
    signal CpSl_LcdVsync_i              : std_logic;
    signal CpSv_FreChoice_i             : std_logic_vector(2 downto 0);
    signal CpSv_VsyncTrig_i             : std_logic_vector(7 downto 0);
    signal CpSl_Vsync_o                 : std_logic;
    signal CpSl_Test_o                  : std_logic;
    
    ----------------------------------------------------------------------------
    --constant declaration
    ----------------------------------------------------------------------------

begin
    ----------------------------------------------------------------------------
    --component map
    ----------------------------------------------------------------------------
    U_M_Test : M_Test port map (
        CpSl_Rst_iN                     => CpSl_Rst_iN                          ,
        CpSl_Clk_i                      => CpSl_Clk_i                           ,
        CpSl_LcdVsync_i                 => CpSl_LcdVsync_i                      ,
        CpSv_FreChoice_i                => CpSv_FreChoice_i                     ,
        CpSv_VsyncTrig_i                => CpSv_VsyncTrig_i                     ,
        CpSl_Vsync_o                    => CpSl_Vsync_o                         
    );

    ----------------------------------------------------------------------------
    --Rst & Clk
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

    ----------------------------------------------------------------------------
    -- CpSl_LcdVsync_i\CpSv_FreChoice_i
    ----------------------------------------------------------------------------
    -- CpSl_LcdVsync_i
    process begin 
        CpSl_LcdVsync_i <= '0';
        wait for 700 ns;
        CpSl_LcdVsync_i <= '1';
        wait for 14705182 ns;
    end process;    
    
    CpSv_FreChoice_i <= "100";
    CpSv_VsyncTrig_i <= "01000100";
    
end arch_M_TestTb;