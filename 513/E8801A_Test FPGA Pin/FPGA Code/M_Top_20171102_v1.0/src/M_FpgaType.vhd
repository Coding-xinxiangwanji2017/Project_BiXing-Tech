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
-- �ļ�����  :  M_FpgaType.vhd
-- ��    ��  :  Zhang wenjun
-- ��    ��  :  zheng-jianfeng@139.com
-- У    ��  :  
-- ��������  :  2017/06/30
-- ���ܼ���  :  Automatic Identification FPGA Type
-- �汾����  :  0.1
-- �޸���ʷ  :  1. Initial, Zhang wenjun, 2017/06/30
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity M_FpgaType is
    port (
        --------------------------------
        -- Reset and Clock
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      : in  std_logic;                        -- 100MHz clock

        --------------------------------
        -- GPIO 
        --------------------------------
        CpSv_Gpio_i                     : in  std_logic_vector(2 downto 0);      -- GPIO

        --------------------------------
        -- FPGA Style
        --------------------------------
        CpSl_FpgaVld_o                  : out std_logic;                        -- FPGA Style Valid
        CpSv_FpgaType_o                 : out std_logic_vector(7 downto 0)      -- FPGA Style
    );
end M_FpgaType;

architecture arch_M_FpgaType of M_FpgaType is
    ----------------------------------------------------------------------------
    -- constant declaration
    ----------------------------------------------------------------------------
    -- conatant_Cnt
    constant PrSv_Cnt500ms_c            : std_logic_vector(27 downto 0) := x"2FAF07F";   -- Test Count 500ms
    constant PrSv_Cnt1s_c               : std_logic_vector(27 downto 0) := x"5F5E0FF";   -- Test Count 1s
    constant PrSv_Cnt50ms_c             : std_logic_vector(23 downto 0) := x"4C4B3F";   -- Test Conut 50ms
    constant PrSv_Cnt51ms_c             : std_logic_vector(23 downto 0) := x"4DD1DF";   -- Test Conut_51ms

    -- Board ID
    constant PrSv_SelfCheck_c           : std_logic_vector(7 downto 0 ) := x"C1";    -- Self Check board
    constant PrSv_AX1000Bod_c           : std_logic_vector(7 downto 0 ) := x"C2";    -- AX1000 Test board
    constant PrSv_AX500Bod_c            : std_logic_vector(7 downto 0 ) := x"C3";    -- AX500 Test board
    constant PrSv_A54SBod_c             : std_logic_vector(7 downto 0 ) := x"C4";    -- A54S Test board

    ----------------------------------------------------------------------------
    -- component declaration
    ----------------------------------------------------------------------------

    ----------------------------------------------------------------------------
    -- signal declaration
    ----------------------------------------------------------------------------
    signal PrSv_FpgaType_s              : std_logic_vector( 7 downto 0);        -- FPGA TYPR
    signal PrSv_GpioDly1_s              : std_logic_vector( 2 downto 0);        -- GPIO Dly1
    signal PrSv_GpioDly2_s              : std_logic_vector( 2 downto 0);        -- GPIO Dly2
    signal PrSv_GpioCheckCnt_s          : std_logic_vector(27 downto 0);        -- GPIO Check
    signal PrSv_GpioCheckNum_s          : std_logic_vector(27 downto 0);        -- GPIO Check
    signal PrSl_CheckDVld_s             : std_logic;                            -- Check output
    signal PrSv_TestCnt_s               : std_logic_vector(23 downto 0);        -- Test Cnt

begin
    ----------------------------------------------------------------------------
    -- Main Area
    ----------------------------------------------------------------------------
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then 
            PrSv_GpioCheckCnt_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then 
            if (PrSv_GpioCheckCnt_s = PrSv_Cnt1s_c) then 
                PrSv_GpioCheckCnt_s <= PrSv_Cnt1s_c;
            else
                PrSv_GpioCheckCnt_s <= PrSv_GpioCheckCnt_s + '1';
            end if;
        end if;
    end process;
    
    -- PrSv_GpioCheckNum_s
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_GpioCheckNum_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSv_GpioCheckCnt_s = PrSv_Cnt1s_c) then 
                if (PrSv_GpioCheckNum_s = PrSv_Cnt1s_c) then 
                    PrSv_GpioCheckNum_s <= (others => '0');
                else
                    PrSv_GpioCheckNum_s <= PrSv_GpioCheckNum_s + '1';
                end if;
            else
                PrSv_GpioCheckNum_s <= (others => '0');
            end if;
        end if;
    end process;
    
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_GpioDly1_s <= (others => '0');
            PrSv_GpioDly2_s <= (others => '1');
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSv_GpioCheckCnt_s = PrSv_Cnt1s_c) then 
                if (PrSv_GpioCheckNum_s = PrSv_Cnt500ms_c) then 
                    PrSv_GpioDly1_s <= CpSv_Gpio_i;
                elsif (PrSv_GpioCheckNum_s = PrSv_Cnt1s_c) then 
                    PrSv_GpioDly2_s <= CpSv_Gpio_i;
                else -- hold
                end if;
            else
                PrSv_GpioDly1_s <= (others => '0');
                PrSv_GpioDly2_s <= (others => '1');
            end if;
        end if;
    end process;
    
    -- Check Out
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
           PrSl_CheckDVld_s <= '0';
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSv_GpioCheckCnt_s = PrSv_Cnt1s_c) then 
                if (PrSv_GpioDly2_s = PrSv_GpioDly1_s) then
                    PrSl_CheckDVld_s <= '1';
                else
                    PrSl_CheckDVld_s <= '0';
                end if;
            else
                PrSl_CheckDVld_s <= '0';
            end if;
        end if;
    end process;
    
    
    -- Generate Count
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_TestCnt_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSl_CheckDVld_s = '1') then 
                if (PrSv_TestCnt_s = PrSv_Cnt51ms_c) then 
                    PrSv_TestCnt_s <= PrSv_Cnt51ms_c;
                else
                    PrSv_TestCnt_s <= PrSv_TestCnt_s + '1';
                end if;
            else
                PrSv_TestCnt_s <= (others => '0');
            end if;
        end if;
    end process;
    
    -- FPGA Style
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_FpgaType_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSl_CheckDVld_s = '1') then 
                if (PrSv_TestCnt_s = PrSv_Cnt50ms_c) then 
                    case PrSv_GpioDly2_s is
                        when "110" =>  -- Self Check Board
                            PrSv_FpgaType_s <= PrSv_SelfCheck_c;

                        when "101" => -- A1000 FPGA
                            PrSv_FpgaType_s <= PrSv_AX1000Bod_c;
                
                        when "111" =>  -- A500 FPGA
                            PrSv_FpgaType_s <= PrSv_AX500Bod_c;
                
                        when "011" => -- A54S FPGA
                            PrSv_FpgaType_s <= PrSv_A54SBod_c;
                
                        when others => 
                            PrSv_FpgaType_s <= (others => '0');
                    end case;
                else -- hold
                end if;
            else
                PrSv_FpgaType_s <= (others => '0');
            end if;
        end if;
    end process;
    
    -- FPGA Valid
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            CpSl_FpgaVld_o <= '0';
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSl_CheckDVld_s = '1') then 
                if (PrSv_TestCnt_s = PrSv_Cnt51ms_c - 100) then 
                    CpSl_FpgaVld_o <= '1';
                elsif (PrSv_TestCnt_s = PrSv_Cnt51ms_c) then 
                    CpSl_FpgaVld_o <= '0';
                else -- hold
                end if;
            else
                CpSl_FpgaVld_o <= '0';
            end if;
        end if;
    end process;
    
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            CpSv_FpgaType_o <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSl_CheckDVld_s = '1') then 
                if (PrSv_TestCnt_s = PrSv_Cnt51ms_c - 100) then 
                    CpSv_FpgaType_o <= PrSv_FpgaType_s;
                else -- hold
                end if;
            else
                CpSv_FpgaType_o <= (others => '0');
            end if;
        end if;
    end process;

end arch_M_FpgaType;