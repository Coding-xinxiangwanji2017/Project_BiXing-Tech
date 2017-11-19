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
-- 文件名称  :  M_Sim.vhd
-- 设    计  :  zhang wenjun
-- 邮    件  :  wenjunzhang@bixing-tech.com
-- 校    对  :
-- 设计日期  :  2017/03/11
-- 功能简述  :  
-- 版本序号  :  0.1
-- 修改历史  :  1. Initial, zhang wenjun, 2017/03/11
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

entity M_Sim is 
end M_Sim;

architecture arch_M_Sim of M_Sim is 
    ----------------------------------------------------------------------------
    -- Constant declaration
    ----------------------------------------------------------------------------
    constant Refresh_Rate               : integer := 100;
    constant Simulation                 : integer := 0;
    constant Use_ChipScope              : integer := 0;

    ----------------------------------------------------------------------------
    -- Component declaration
    ----------------------------------------------------------------------------
    component M_Pattern port(
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      : in  std_logic;                        -- Clock,90MHz

        --------------------------------
        -- Output signals
        --------------------------------
        CpSl_Hsync_o                    : out std_logic;                        -- Hsync
        CpSl_Vsync_o                    : out std_logic;                        -- Vsync
        CpSv_Red0_o                     : out std_logic_vector(11 downto 0);    -- Red0
        CpSv_Red1_o                     : out std_logic_vector(11 downto 0);    -- Red1
        CpSv_Red2_o                     : out std_logic_vector(11 downto 0);    -- Red2
        CpSv_Red3_o                     : out std_logic_vector(11 downto 0);    -- Red3
        CpSv_Green0_o                   : out std_logic_vector(11 downto 0);    -- Green0 
        CpSv_Green1_o                   : out std_logic_vector(11 downto 0);    -- Green1 
        CpSv_Green2_o                   : out std_logic_vector(11 downto 0);    -- Green2 
        CpSv_Green3_o                   : out std_logic_vector(11 downto 0)     -- Green3 
    );
    end component;
    
    ----------------------------------------------------------------------------
    -- signal declaration
    ----------------------------------------------------------------------------
    signal CpSl_Rst_iN                  : std_logic;                            -- Reset, active low
    signal CpSl_Clk_i                   : std_logic;                            -- Clock 90MHz, single
    signal CpSl_Hsync_o                 : std_logic;                            -- Hysnc
    signal CpSl_Vsync_o                 : std_logic;                            -- Vysnc
    signal CpSv_Red0_o                  : std_logic_vector(11 downto 0);        -- Red
    signal CpSv_Red1_o                  : std_logic_vector(11 downto 0);        -- Red
    signal CpSv_Red2_o                  : std_logic_vector(11 downto 0);        -- Red
    signal CpSv_Red3_o                  : std_logic_vector(11 downto 0);        -- Red
    signal CpSv_Green0_o                : std_logic_vector(11 downto 0);        -- Green
    signal CpSv_Green1_o                : std_logic_vector(11 downto 0);        -- Green
    signal CpSv_Green2_o                : std_logic_vector(11 downto 0);        -- Green
    signal CpSv_Green3_o                : std_logic_vector(11 downto 0);        -- Green
    
begin   
    ------------------------------------
    -- Compoonent map
    ------------------------------------
    U_M_Pattern_0 : M_Pattern
    port map (
        CpSl_Rst_iN                     => CpSl_Rst_iN                          ,          
        CpSl_Clk_i                      => CpSl_Clk_i                           ,          
        CpSl_Hsync_o                    => CpSl_Hsync_o                         ,          
        CpSl_Vsync_o                    => CpSl_Vsync_o                         ,          
        CpSv_Red0_o                     => CpSv_Red0_o                          ,          
        CpSv_Red1_o                     => CpSv_Red1_o                          ,          
        CpSv_Red2_o                     => CpSv_Red2_o                          ,          
        CpSv_Red3_o                     => CpSv_Red3_o                          ,          
        CpSv_Green0_o                   => CpSv_Green0_o                        ,          
        CpSv_Green1_o                   => CpSv_Green1_o                        ,          
        CpSv_Green2_o                   => CpSv_Green2_o                        ,          
        CpSv_Green3_o                   => CpSv_Green3_o                               
    ); 
    
    ------------------------------------
    -- Sim Reset & Clock
    ------------------------------------
    process
    begin 
        CpSl_Rst_iN <= '0';
        wait for 11.1 ns;
        CpSl_Rst_iN <= '1';
        wait;
    end process;
    
    process
    begin 
        CpSl_Clk_i <= '0';
        wait for 5.55 ns;
        CpSl_Clk_i <= '1';
        wait for 5.55 ns;
    end process;
    
    
end arch_M_Sim;