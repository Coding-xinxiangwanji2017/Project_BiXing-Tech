library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity M_FreCtrl_TB is
end M_FreCtrl_TB;

architecture arch_M_FreCtrl_TB of M_FreCtrl_TB is

    ------------------------------------
    --component declaration
    ------------------------------------
    component M_FreCtrl port(
        --------------------------------
        --Rst & Clk
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                       --Rst, active low
        CpSl_Clk_i                      : in  std_logic;                       --Clk, 100Mhz

        --------------------------------
        --Dvi
        --------------------------------
        CpSl_Dvi0Scdt_i                 : in  std_logic;                        --Dvi0 Scdt
        CpSl_Dvi1Scdt_i                 : in  std_logic;                        --Dvi1 Scdt
        CpSl_Dvi0Vsync_i                : in  std_logic;                        --Dvi0 Vsync

        --------------------------------
        --Frequence Choice
        --------------------------------
        CpSv_FreChoice_o                : out  std_logic_vector(11 downto 0)    --Choice frequence
    );
    end component;

    ----------------------------------------------------------------------------
    --signal declaration
    ----------------------------------------------------------------------------
    signal CpSl_Rst_iN                  : std_logic;
    signal CpSl_Clk_i                   : std_logic;
    signal CpSl_Dvi0Scdt_i              : std_logic;
    signal CpSl_Dvi1Scdt_i              : std_logic;
    signal CpSl_Dvi0Vsync_i             : std_logic;
    signal CpSv_FreChoice_o             : std_logic_vector(11 downto 0);
    
    ----------------------------------------------------------------------------
    --constant declaration
    ----------------------------------------------------------------------------

begin
    ----------------------------------------------------------------------------
    --component map
    ----------------------------------------------------------------------------
    U_M_FreCtrl : M_FreCtrl port map (
        CpSl_Rst_iN                     => CpSl_Rst_iN,
        CpSl_Clk_i                      => CpSl_Clk_i,
        CpSl_Dvi0Scdt_i                 => CpSl_Dvi0Scdt_i,
        CpSl_Dvi1Scdt_i                 => CpSl_Dvi1Scdt_i,
        CpSl_Dvi0Vsync_i                => CpSl_Dvi0Vsync_i,
        CpSv_FreChoice_o                => CpSv_FreChoice_o
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
    --CpSl_Dvi0Scdt_i/CpSl_Dvi01Scdt_i/CpSl_Dvi0Vsync_i 
    ----------------------------------------------------------------------------
    --CpSl_Dvi0Scdt_i
    process begin 
        CpSl_Dvi0Scdt_i <= '0';
        wait for 2000000 ns;
        CpSl_Dvi0Scdt_i <= '1';
        wait;
    end process;
    
    --CpSl_Dvi1Scdt_i
    process begin 
        CpSl_Dvi1Scdt_i <= '0';
        wait for 2000000 ns;
        CpSl_Dvi1Scdt_i <= '1';
        wait for 1000000000 ns;
        CpSl_Dvi1Scdt_i <= '0';
        wait;
    end process;
    
    --CpSl_Dvi0Vsync_i/100/60/50
    process 
    variable i : integer range 0 to 99 := 0;
    variable j : integer range 0 to 79 := 0;
    variable k : integer range 0 to 59 := 0;
    begin
        CpSl_Dvi0Vsync_i <= '0';
        wait for 2000000 ns;
        
        for i in 0 to 99 loop 
            CpSl_Dvi0Vsync_i <= '1';
            wait for 9999990 ns;
            CpSl_Dvi0Vsync_i <= '0';
            wait for 10 ns;
        end loop;
        
        
        for j in 0 to 79 loop 
            CpSl_Dvi0Vsync_i <= '1';
            wait for 15999984 ns;
            CpSl_Dvi0Vsync_i <= '0';
            wait for 16 ns;
        end loop;
        
        for k in 0 to 59 loop 
            CpSl_Dvi0Vsync_i <= '1';
            wait for 19999980 ns;
            CpSl_Dvi0Vsync_i <= '0';
            wait for 20 ns;
        end loop;
         
    end process;

end arch_M_FreCtrl_TB;