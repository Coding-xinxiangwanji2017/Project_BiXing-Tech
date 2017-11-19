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
-- 文件名称  :  M_LcdVsync.vhd
-- 设    计  :  Zhang Wenjun
-- 邮    件  :  wenjuzhang@bixing-tech.com
-- 校    对  :
-- 设计日期  :  2016/06/29
-- 功能简述  :  Choice Vsync to Lcd output data
-- 版本序号  :  0.1
-- 修改历史  :  1. Initial, Zhang Wenjun, 2016/06/29
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity M_LcdVsync is
    port (
		--------------------------------
		-- clock & reset
		--------------------------------
		CpSl_Rst_iN                     :  in std_logic;                        -- Resxt active low
		CpSl_Clk_i                      :  in std_logic;                        -- Clock 80MHz,single
		
		--------------------------------
		-- Vsync input
		--------------------------------
		--CpSl_ChoiceVsync_i = '1' Choice ExtVsync；
        --CpSl_ChoiceVsync_i = '0' Choice IntVsync；
        CpSl_ChoiceVsync_i              :  in std_logic;                        -- Choice Ext or Int Vsync
		CpSl_ExtVsync_i                 :  in std_logic;                        -- Ext vsync
		CpSl_IntVsync_i                 :  in std_logic;                        -- int Vsync

		--------------------------------
		-- Vsync output
		--------------------------------
		CpSl_LcdVsync_o                 :  out std_logic;                       -- Choice Vsync
		CpSl_ExtVld_o                   :  out std_logic;                       -- Ext:'1' Int:'0'
		--------------------------------
		-- ChipScope
		--------------------------------
		CpSv_ChipCtrl3_io               : inout std_logic_vector(35 downto 0)   -- ChipScope control3   
	);
end M_LcdVsync;

architecture arch_M_LcdVsync of M_LcdVsync is
	----------------------------------------------------------------------------
    -- constant declaration
    ----------------------------------------------------------------------------
        
    ------------------------------------
    -- Component declaration
    ------------------------------------
    component M_ila port (
        control                         : inout std_logic_vector(35 downto 0);
        clk                             : in    std_logic;
        trig0                           : in    std_logic_vector(63 downto 0)
    );
    end component;
        
    ----------------------------------------------------------------------------
    -- signal declaration
    ----------------------------------------------------------------------------
    --Row Trig
    signal PrSl_ExtRowTrig_s            : std_logic;                            -- Ext Vsync Trig
    signal PrSl_ExtRowTrigDly1_s        : std_logic;                            -- Ext Vsync Trig Dly1
    signal PrSl_ExtRowTrigDly2_s        : std_logic;                            -- Ext Vsync Trig Dly2
    signal PrSl_ExtRowTrigDly3_s        : std_logic;                            -- Ext Vsync Trig Dly3
    signal PrSl_ExtVsync_s              : std_logic;                            -- Ext Vsync Trig
    
    -- PrSl_ExtVld_s = '1' choice ExtVsync 
    -- PrSl_ExtVld_s = '0' choice IntVsync
    signal PrSl_ExtVld_s                : std_logic;                            -- Ext Valid

    signal PrSl_ExtVsyncDly1_s          : std_logic;                            -- Dly1
    signal PrSl_ExtVsyncDly2_s          : std_logic;                            -- Dly2
    signal PrSl_ExtVsyncDly3_s          : std_logic;                            -- Dly3
    signal PrSl_IntVsyncDly1_s          : std_logic;                            -- Dly1
    signal PrSl_IntVsyncDly2_s          : std_logic;                            -- Dly2
    signal PrSl_IntVsyncDly3_s          : std_logic;                            -- Dly3
    
    --------------------------------  
    -- ChipScope                      
    --------------------------------  
    signal PrSv_Trig_s                  : std_logic_vector(63 downto 0);        -- Trig 

begin
    ------------------------------------
    -- Component map
    ------------------------------------
    U_M_ila_3 : M_ila port map (
        control                         => CpSv_ChipCtrl3_io                    ,
        clk                             => CpSl_Clk_i                           ,
        trig0                           => PrSv_Trig_s
    );
    PrSv_Trig_s(          0)            <= CpSl_ChoiceVsync_i                   ;
    PrSv_Trig_s(          1)            <= CpSl_ExtVsync_i                      ;
    PrSv_Trig_s(          2)            <= CpSl_IntVsync_i                      ;
    PrSv_Trig_s(          3)            <= '0'                                  ;
    PrSv_Trig_s(          4)            <= PrSl_ExtVld_s                        ;
    PrSv_Trig_s(63 downto 5)            <= (others => '0')                      ;     

    ------------------------------------      
    --Dly CpSl_ExtVsync_i
    ------------------------------------
     process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_ExtVsyncDly1_s <= '0';
            PrSl_ExtVsyncDly2_s <= '0';
            PrSl_ExtVsyncDly3_s <= '0';
        elsif rising_edge(CpSl_Clk_i) then
            PrSl_ExtVsyncDly1_s <= CpSl_ExtVsync_i;
            PrSl_ExtVsyncDly2_s <= PrSl_ExtVsyncDly1_s;
            PrSl_ExtVsyncDly3_s <= PrSl_ExtVsyncDly2_s;
        end if;
    end process;
    
    -- Row ExtTrig
    PrSl_ExtRowTrig_s <= (PrSl_ExtVsyncDly2_s and not PrSl_ExtVsyncDly3_s);
    
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_ExtRowTrigDly1_s <= '0';
            PrSl_ExtRowTrigDly2_s <= '0';
            PrSl_ExtRowTrigDly3_s <= '0';
        elsif rising_edge(CpSl_Clk_i) then
            PrSl_ExtRowTrigDly1_s <= PrSl_ExtRowTrig_s;
            PrSl_ExtRowTrigDly2_s <= PrSl_ExtRowTrigDly1_s;
            PrSl_ExtRowTrigDly3_s <= PrSl_ExtRowTrigDly2_s;
        end if;
    end process;
    --output Extsync
    PrSl_ExtVsync_s <= (PrSl_ExtRowTrig_s or PrSl_ExtRowTrigDly1_s 
    	                 or PrSl_ExtRowTrigDly2_s or PrSl_ExtRowTrigDly3_s);
    
    --ExtVsync Valid
    process (CpSl_Rst_iN, CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            PrSl_ExtVld_s <= '0';
        elsif rising_edge (CpSl_Clk_i) then
            if (CpSl_ChoiceVsync_i = '1') then 
                PrSl_ExtVld_s <= '1';
            elsif (CpSl_ChoiceVsync_i = '0') then 
                PrSl_ExtVld_s <= '0';
            end if;
        end if;
    end process;
    -- output indication
    CpSl_ExtVld_o <= PrSl_ExtVld_s;

    -- Choice ExtVsync or IntVsync
    -- Generate LcdVsync
--    CpSl_LcdVsync_o <= PrSl_ExtVsync_s when CpSl_ChoiceVsync_i = '1' else CpSl_IntVsync_i;
    CpSl_LcdVsync_o <= CpSl_IntVsync_i;
    
end arch_M_LcdVsync;