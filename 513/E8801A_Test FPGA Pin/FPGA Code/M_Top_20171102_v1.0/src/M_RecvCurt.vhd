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
-- 文件名称  :  M_RecvCurt.vhd
-- 设    计  :  Zhang Wenjun
-- 邮    件  :  wenjunzhang@bixing-tech.com
-- 校    对  :  
-- 设计日期  :  2017/07/10
-- 功能简述  :  Uart receive, transfer to parallel data
--              Receive Current command
-- 版本序号  :  0.1
-- 修改历史  :  1. Initial, Zhang Wenjun, 2017/07/10
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity M_RecvCurt is
    port (
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
end M_RecvCurt;

architecture arch_M_RecvCurt of M_RecvCurt is 
    ----------------------------------------------------------------------------
    -- constant declaration
    ----------------------------------------------------------------------------
    constant PrSv_Baud115200_c          : std_logic_vector(15 downto 0) := x"0364"; -- 868
    constant PrSv_Half115200_c          : std_logic_vector(15 downto 0) := x"01B2"; -- 434
    
    ----------------------------------------------------------------------------
    -- component declaration
    ----------------------------------------------------------------------------
    
    ----------------------------------------------------------------------------
    -- signal declaration
    ----------------------------------------------------------------------------
    signal PrSl_RxDDly1_s               : std_logic;                            -- Delay 1 CpSl_RxD_i
    signal PrSl_RxDDly2_s               : std_logic;                            -- Delay 2 CpSl_RxD_i
    signal PrSl_RxDDly3_s               : std_logic;                            -- Delay 3 CpSl_RxD_i
    signal PrSl_RxDFallEdge_s           : std_logic;                            -- Falling edge of CpSl_RxD_i
    signal PrSv_BaudCnt_s               : std_logic_vector(15 downto 0);        -- Baud counter
    signal PrSl_CapEn_s                 : std_logic;                            -- Capture enable
    signal PrSv_NumCnt_s                : std_logic_vector( 3 downto 0);        -- Number of a parallel data
    signal PrSv_RxShifter_s             : std_logic_vector( 7 downto 0);        -- Shift register for Parallel data
    signal PrSv_RecvState_s             : std_logic_vector( 2 downto 0);        -- Uart receive data state
    signal PrSl_RxPalDvld_s             : std_logic;                            -- Parallel data valid
    signal PrSv_RxPalData_s             : std_logic_vector( 7 downto 0);        -- Parallel data
    signal PrSv_FrameStrate_s           : std_logic_vector( 2 downto 0);        -- Frame state
    signal PrSv_CurtCmdCnt              : std_logic_vector( 3 downto 0);        -- Current Command count
    signal PrSv_CurtPallData            : std_logic_vector(71 downto 0);        -- Current parallel data   
    
begin
    ----------------------------------------------------------------------------
    -- Receive serial data
    ----------------------------------------------------------------------------
    -- Latch CpSl_RxD_i
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_RxDDly1_s <= '1';
            PrSl_RxDDly2_s <= '1';
            PrSl_RxDDly3_s <= '1';
        elsif rising_edge(CpSl_Clk_i) then
            PrSl_RxDDly1_s <= CpSl_RxD_i    ;
            PrSl_RxDDly2_s <= PrSl_RxDDly1_s;
            PrSl_RxDDly3_s <= PrSl_RxDDly2_s;
        end if;
    end process;

    -- Falling edge of CpSl_RxD_i
    PrSl_RxDFallEdge_s <= (not PrSl_RxDDly2_s) and PrSl_RxDDly3_s;

    -- Baud counter
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_BaudCnt_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSv_RecvState_s /= "000") then
                if (PrSv_BaudCnt_s = PrSv_Baud115200_c) then -- Baud 115200
                    PrSv_BaudCnt_s <= (others => '0');
                else
                    PrSv_BaudCnt_s <= PrSv_BaudCnt_s + '1';
                end if;
            else
                PrSv_BaudCnt_s <= (others => '0');
            end if;
        end if;
    end process;

    -- Data capture enable
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_CapEn_s <= '0';
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSv_BaudCnt_s = PrSv_Half115200_c) then -- Baud 115200
                PrSl_CapEn_s <= '1';
            else
                PrSl_CapEn_s <= '0';
            end if;
        end if;
    end process;

    -- uart State machine
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_RecvState_s <= "000";
        elsif rising_edge(CpSl_Clk_i) then
            case PrSv_RecvState_s is
            when "000" =>
                if (PrSl_RxDFallEdge_s = '1') then
                    PrSv_RecvState_s <= "001";
                else -- hold
                end if;
            when "001" =>
                if (PrSl_CapEn_s = '1' and CpSl_RxD_i = '0') then
                    PrSv_RecvState_s <= "010";
                else -- hold
                end if;
            when "010" =>
                if (PrSl_CapEn_s = '1' and PrSv_NumCnt_s = "1000") then
                    PrSv_RecvState_s <= "100";
                else -- hold
                end if;
            when "100" =>
                if (PrSl_CapEn_s = '1' and CpSl_RxD_i = '1') then
                    PrSv_RecvState_s <= "000";
                else -- hold
                end if;
            when others =>
                PrSv_RecvState_s <= "000";
            end case;
        end if;
    end process;

    -- Counter for number of bits in a frame
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_NumCnt_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSl_CapEn_s = '1') then
                if (PrSv_NumCnt_s = "1001") then
                    PrSv_NumCnt_s <= (others => '0');
                else
                    PrSv_NumCnt_s <= PrSv_NumCnt_s + '1';
                end if;
            else -- hold
            end if;
        end if;
    end process;

    -- PrSv_RxShifter_s
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_RxShifter_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSv_RecvState_s(1) = '1' and PrSl_CapEn_s = '1') then
                PrSv_RxShifter_s <= CpSl_Rxd_i & PrSv_RxShifter_s( 7 downto 1);
            else -- hold
            end if;
        end if;
    end process;

    ------------------------------------
    -- 8bit parallel
    ------------------------------------
    -- 8bit data valid
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_RxPalDvld_s <= '0';
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSv_RecvState_s(2) = '1' and PrSl_CapEn_s = '1' and CpSl_RxD_i = '1') then
                PrSl_RxPalDvld_s <= '1';
            else
                PrSl_RxPalDvld_s <= '0';
            end if;
        end if;
    end process;

    -- Parallel 8bit data
    PrSv_RxPalData_s <= PrSv_RxShifter_s;
    
    ------------------------------------
    -- Frame head : "A5"
    -- Current Indicator : "B4"
    -- Current data : 72 bits
    ------------------------------------
    -- Frame State machine 
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then 
            PrSv_FrameStrate_s <= "000";
        elsif rising_edge(CpSl_Clk_i) then 
            case PrSv_FrameStrate_s is
            when "000" => -- Frame Head
                if (PrSl_RxPalDvld_s = '1' and PrSv_RxPalData_s = x"A5") then 
                    PrSv_FrameStrate_s <= "001";
                else -- hold
                end if;
                    
            when "001" => -- Current indicator
                if (PrSl_RxPalDvld_s = '1' and PrSv_RxPalData_s = x"B4") then 
                    PrSv_FrameStrate_s <= "010";
                else
                end if;
                    
            when "010" => -- Current Number
                if (PrSl_RxPalDvld_s = '1' and PrSv_CurtCmdCnt = 9) then 
                    PrSv_FrameStrate_s <= "011";
                else -- hold
                end if;
                    
            when "011" => -- Freame End
--                if (PrSv_BaudCnt_s = PrSv_Half115200_c + 19) then
--                    PrSv_FrameStrate_s <= "000";
--                else --hold
--                end if;
                PrSv_FrameStrate_s <= "000";

            when others =>
                PrSv_FrameStrate_s <= "000";
                
            end case;
        end if;
    end process;
    
    -- Current Command count
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then 
            PrSv_CurtCmdCnt <= (others => '0');
        elsif rising_edge (CpSl_Clk_i) then 
            if (PrSv_FrameStrate_s = "010") then
                if (PrSl_RxPalDvld_s = '1') then
                    PrSv_CurtCmdCnt <= PrSv_CurtCmdCnt + '1';
                else -- hold
                end if;
            else 
               PrSv_CurtCmdCnt <= (others => '0'); 
            end if;
        end if;
    end process;
    
    -- Volatge Parallel data
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_CurtPallData <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSv_FrameStrate_s = "010") then
                if (PrSl_RxPalDvld_s = '1') then
                case PrSv_CurtCmdCnt is 
                    when "0000"     => PrSv_CurtPallData(71 downto 64) <= PrSv_RxPalData_s;
                    when "0001"     => PrSv_CurtPallData(63 downto 56) <= PrSv_RxPalData_s;
                    when "0010"     => PrSv_CurtPallData(55 downto 48) <= PrSv_RxPalData_s;
                    when "0011"     => PrSv_CurtPallData(47 downto 40) <= PrSv_RxPalData_s;
                    when "0100"     => PrSv_CurtPallData(39 downto 32) <= PrSv_RxPalData_s;
                    when "0101"     => PrSv_CurtPallData(31 downto 24) <= PrSv_RxPalData_s;
                    when "0110"     => PrSv_CurtPallData(23 downto 16) <= PrSv_RxPalData_s;
                    when "0111"     => PrSv_CurtPallData(15 downto  8) <= PrSv_RxPalData_s;
                    when "1000"     => PrSv_CurtPallData( 7 downto  0) <= PrSv_RxPalData_s;
                    when others     => PrSv_CurtPallData               <= PrSv_CurtPallData;
                end case;
                else -- hold
                end if;
            else
                PrSv_CurtPallData <= (others => '0');
            end if;
        end if;
    end process;

    -- Current output
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            CpSl_CurtDvld_o <= '0';
            CpSv_CurtData_o <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSv_FrameStrate_s = "011") then
                CpSl_CurtDvld_o <= '1';
                CpSv_CurtData_o <= PrSv_CurtPallData;
            else
                CpSl_CurtDvld_o <= '0';
                CpSv_CurtData_o <= PrSv_CurtPallData;
            end if;
        end if;
    end process;
    
end arch_M_RecvCurt;