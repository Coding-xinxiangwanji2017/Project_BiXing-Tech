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
-- �ļ�����  :  M_CmdParse.vhd
-- ��    ��  :  Zhang wenjun
-- ��    ��  :  zheng-jianfeng@139.com
-- У    ��  :  
-- ��������  :  2017/06/30
-- ���ܼ���  :  Control the FPGA test Pins
-- �汾����  :  0.1
-- �޸���ʷ  :  1. Initial, Zhang wenjun, 2017/06/30
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity M_CmdParse is
    port (
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      : in  std_logic;                        -- 100MHz clock

        --------------------------------
        -- JTAG/Test Valid
        --------------------------------
        CpSl_JtagDvld_i                 : in  std_logic;                        -- Parallel JTAG data valid
        CpSv_JtagData_i                 : in  std_logic_vector(23 downto 0);    -- Parallel JTAG data
        CpSl_TestDvld_i                 : in  std_logic;                        -- Parallel Test_Cmd data valid
        CpSv_TestData_i                 : in  std_logic_vector(23 downto 0);    -- Parallel Test_Cmd data

        --------------------------------
        -- Reset/Test Pin
        --------------------------------
        CpSl_RstVld_o                   : out std_logic;                        -- FPGA Reset Valid
        CpSl_FpgaRst_o                  : out std_logic;                        -- FPGA Reset Single
        CpSv_SelectIO_o                 : out std_logic_vector(17 downto 0)     -- Test IO select
    );
end M_CmdParse;

architecture arch_M_CmdParse of M_CmdParse is
    ----------------------------------------------------------------------------
    -- constant declaration
    ----------------------------------------------------------------------------
    -- 10000000
    constant PrSv_FpgaRst_c             : std_logic_vector(23 downto 0) := x"98967F";   -- 100ms
    constant PrSv_JtagSucc_c            : std_logic_vector(23 downto 0) := x"AABBCC";   -- Download Successful
    constant PrSv_JtagFail_c            : std_logic_vector(23 downto 0) := x"AABBEE";   -- Download Failed

    ----------------------------------------------------------------------------
    -- component declaration
    ----------------------------------------------------------------------------

    ----------------------------------------------------------------------------
    -- signal declaration
    ----------------------------------------------------------------------------
    signal PrSv_JtagRstEndCnt_s         : std_logic_vector( 3 downto 0);        -- JTAG Reset End 
    signal PrSv_JtagState_s             : std_logic_vector( 1 downto 0);        -- JTAG State
    signal PrSv_JtagRstCnt_s            : std_logic_vector(23 downto 0);        -- JTAG Reset Count
    signal PrSv_SelectIO_s              : std_logic_vector(20 downto 0);        -- Test Pin

begin
    ----------------------------------------------------------------------------
    -- Main Area
    ----------------------------------------------------------------------------
    -- FPGA Reset
    process (CpSl_Rst_iN, CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            PrSv_JtagState_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then 
        case PrSv_JtagState_s is
            when "00" => 
                if (CpSl_JtagDvld_i = '1' and CpSv_JtagData_i = PrSv_JtagSucc_c) then
                    PrSv_JtagState_s <= "01";
                elsif (CpSl_JtagDvld_i = '1' and CpSv_JtagData_i = PrSv_JtagFail_c) then
                    PrSv_JtagState_s <= "00";
                else -- hold
                end if;
            when "01" => 
                if (PrSv_JtagRstCnt_s = PrSv_FpgaRst_c) then 
                    PrSv_JtagState_s <= "10";
                else 
                end if;
            when "10" => 
				if (PrSv_JtagRstEndCnt_s = 10) then 
				    PrSv_JtagState_s <= "00";
				else --- hold
				end if;
            when others => PrSv_JtagState_s <= "00";
        end case;
        end if;
    end process;

    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
             PrSv_JtagRstCnt_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then 
            if (PrSv_JtagState_s = "01") then
                if (PrSv_JtagRstCnt_s = PrSv_FpgaRst_c) then
                    PrSv_JtagRstCnt_s <= (others => '0');
                else
                    PrSv_JtagRstCnt_s <= PrSv_JtagRstCnt_s + '1';
                end if;
            else
                PrSv_JtagRstCnt_s <= (others => '0');
            end if;
        end if;
    end process;
	
	-- JTAG Reset End
	process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
             PrSv_JtagRstEndCnt_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then 
            if (PrSv_JtagState_s = "10") then
                if (PrSv_JtagRstEndCnt_s = 10) then
                    PrSv_JtagRstEndCnt_s <= (others => '0');
                else
                    PrSv_JtagRstEndCnt_s <= PrSv_JtagRstEndCnt_s + '1';
                end if;
            else
                PrSv_JtagRstEndCnt_s <= (others => '0');
            end if;
        end if;
    end process;
    
    -- CpSl_RstVld_o
    process (CpSl_Rst_iN, CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            CpSl_RstVld_o <= '0';
        elsif rising_edge(CpSl_Clk_i) then 
            if (PrSv_JtagState_s = "10") then
                CpSl_RstVld_o <= '1';
            else
                CpSl_RstVld_o <= '0';
            end if; 
        end if;
    end process;
    
    -- CpSl_FpgaRst_o
    process (CpSl_Rst_iN, CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            CpSl_FpgaRst_o <= '1';
        elsif rising_edge(CpSl_Clk_i) then 
            if (PrSv_JtagState_s = "01") then
                CpSl_FpgaRst_o <= '0';
            else
                CpSl_FpgaRst_o <= '1';
            end if; 
        end if;
    end process;
    
    -- Test FPGA Pins
    process (CpSl_Rst_iN, CpSl_Clk_i) begin 
        if (CpSl_Rst_iN = '0') then 
            CpSv_SelectIO_o <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then 
            if (CpSl_TestDvld_i = '1') then
                CpSv_SelectIO_o <= CpSv_TestData_i(17 downto 0);
            else
            end if;
        end if;
    end process;

end arch_M_CmdParse;