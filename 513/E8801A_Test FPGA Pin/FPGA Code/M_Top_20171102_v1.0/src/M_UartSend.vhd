--------------------------------------------------------------------------------
--        *****************          *****************
--                        **        **
--            ***          **      **           **
--           *   *          **    **           * *
--          *     *          **  **              *
--          *     *           ****               *
--          *     *          **  **              *
--           *   *          **    **             *
--            ***          **      **          *****
--                        **        **
--        *****************          *****************
--------------------------------------------------------------------------------
--Com     :  BiXing Tech
--Text    :  M_UartSend.vhd
--Per     :  zhangwenjun
--E-mail  :  wenjunzhang@bixing-tech.com
--Data    :  2016/8/17
--Cust    :  Uart Receive, transfer to parallel data
--Int     :  0.1
--IntTime :  1. Initial, zhangwenjun, 2016/8/17
--RS232   :  start signal : '0'; stop  signal : '1';
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity M_UartSend is
    port (
        --------------------------------
        -- Reset and Clock
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, Active low
        CpSl_Clk_i                      : in  std_logic;                        -- 100MHz Clock

        --------------------------------
        -- FPGA Type
        --------------------------------
        CpSl_FpgaVld_i                  : in  std_logic;                        -- FPGA Style Valid
        CpSv_FpgaType_i                 : in  std_logic_vector(7 downto 0);     -- FPGA Style

        --------------------------------
        -- Test FPGA Reset/Voltage/Current
        --------------------------------
        CpSl_RstVld_i                   : in  std_logic;                        -- Test FPGA Reset Valid      
        CpSl_CmpVolVld_i                : in  std_logic;                        -- Copmare Voltage Valid
        CpSv_CmpVolData_i               : in  std_logic_vector(10 downto 0);    -- Copmare Voltage Valid Data
        CpSl_CmpCurtVld_i               : in  std_logic;                        -- Compare Current Valid
        CpSv_CmpCurtData_i              : in  std_logic_vector(10 downto 0);    -- Compare Current Valid Data

        --------------------------------
        -- Parallel Command Indicator
        --------------------------------
        CpSl_TestDvld_i                 : in  std_logic;                        -- Parallel Test_Cmd data valid
        CpSv_TestData_i                 : in  std_logic_vector(23 downto 0);    -- Parallel Test_Cmd data

        --------------------------------
        -- Uart Tx Data
        --------------------------------
        CpSl_TxD_o                      : out std_logic                         -- Transfer Data
    );
end M_UartSend;

architecture arch_M_UartSend of M_UartSend is
    ----------------------------------------------------------------------------
    -- constant declaration
    ----------------------------------------------------------------------------
    constant PrSv_Baud115200_c          : std_logic_vector(11 downto 0) := x"363";  -- 100M / 115200 = 868
    constant PrSv_Half115200_c          : std_logic_vector(11 downto 0) := x"1B1";  -- 434
    
    constant PrSv_FpgaHead_c            : std_logic_vector(15 downto 0) := x"A5BB"; -- FPGA Frame Head
    constant PrSv_CmpVolHead_c          : std_logic_vector(15 downto 0) := x"A5A8"; -- Compare Voltage Frame Head
    constant PrSv_ComCurtHead_c         : std_logic_vector(15 downto 0) := x"A550"; -- Compare Current Frame Head
    constant PrSv_TestFpgaRst_c         : std_logic_vector(23 downto 0) := x"A54AA3";   -- Compare Current Frame Head
    ----------------------------------------------------------------------------
    -- signal declaration
    ----------------------------------------------------------------------------
    -- Fpga Valid
    signal PrSl_FpgaVldDly1_s           : std_logic;                            -- CpSl_FpgaVld_i Dly 1 Clk
    signal PrSl_FpgaVldDly2_s           : std_logic;                            -- CpSl_FpgaVld_i Dly 2 Clk
    signal PrSl_FpgaVldDly3_s           : std_logic;                            -- CpSl_FpgaVld_i Dly 3 Clk
    signal PrSl_FpgaVldTrig_s           : std_logic;                            -- CpSl_FpgaVld_i Rowing Trig
    
    -- CpSl_RstVld_i
    signal PrSl_TestFpgaRstDly1_s       : std_logic;                            -- CpSl_RstVld_i Dly 1 Clk   
    signal PrSl_TestFpgaRstDly2_s       : std_logic;                            -- CpSl_RstVld_i Dly 2 Clk   
    signal PrSl_TestFpgaRstDly3_s       : std_logic;                            -- CpSl_RstVld_i Dly 3 Clk   
    signal PrSl_TestFpgaRstTrig_s       : std_logic;                            -- CpSl_RstVld_i Rowing Trig 
    
    -- Cmpare Voltage Valid
    signal PrSl_CmpVolVldDly1_s         : std_logic;                            -- CpSl_CmpVolVld_i Dly 1 Clk
    signal PrSl_CmpVolVldDly2_s         : std_logic;                            -- CpSl_CmpVolVld_i Dly 2 Clk
    signal PrSl_CmpVolVldDly3_s         : std_logic;                            -- CpSl_CmpVolVld_i Dly 3 Clk
    signal PrSl_CmpVolVldTrig_s         : std_logic;                            -- CpSl_CmpareVld_i Rowing Trig
    
    -- Cmpare Current Valid
    signal PrSl_CmpCurtDly1_s           : std_logic;                            -- CpSl_CmpCurtVld_i Dly 1 Clk
    signal PrSl_CmpCurtDly2_s           : std_logic;                            -- CpSl_CmpCurtVld_i Dly 2 Clk
    signal PrSl_CmpCurtDly3_s           : std_logic;                            -- CpSl_CmpCurtVld_i Dly 3 Clk
    signal PrSl_CmpCurtTrig_s           : std_logic;                            -- CpSl_CmpCurtVld_i Rowing Trig
    
    signal PrSv_TxFrameData_s           : std_logic_vector(23 downto 0);        -- Uart Frame Data 
    
    ------------------------------------
    -- Uart Tx signal
    ------------------------------------
    signal PrSv_BaudCnt_s               : std_logic_vector(11 downto 0);        -- Baud Cnt
    signal PrSv_TxDataState_s           : std_logic_vector( 2 downto 0);        -- Tx Data State
    signal PrSv_TxFrameCnt_s            : std_logic_vector( 2 downto 0);        -- Tx Frame Count 
    signal PrSv_TxData_s                : std_logic_vector( 7 downto 0);        -- Tx Data
    signal PrSl_TxHeadEn_s              : std_logic;                            -- Tx Hend Enable
    signal PrSl_TxTrig_s                : std_logic;                            -- Tx Trig
    signal PrSv_TxTrigCnt_s             : std_logic_vector( 3 downto 0);        -- Tx Trig Count

begin
    ----------------------------------------------------------------------------
    --uart tx data (24bit)
    ----------------------------------------------------------------------------
    ------------------------------------
    -- Signal Trig
    ------------------------------------
    -- CpSl_FpgaVld_i
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_FpgaVldDly1_s <= '0';
            PrSl_FpgaVldDly2_s <= '0';
            PrSl_FpgaVldDly3_s <= '0';
        elsif rising_edge(CpSl_Clk_i) then
            PrSl_FpgaVldDly1_s <= CpSl_FpgaVld_i;
            PrSl_FpgaVldDly2_s <= PrSl_FpgaVldDly1_s;
            PrSl_FpgaVldDly3_s <= PrSl_FpgaVldDly2_s;
        end if;
    end process;
    -- Compare Rowing Trig
    PrSl_FpgaVldTrig_s <= PrSl_FpgaVldDly2_s and (not PrSl_FpgaVldDly3_s);
        
    -- CpSl_RstVld_i
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_TestFpgaRstDly1_s <= '0';
            PrSl_TestFpgaRstDly2_s <= '0';
            PrSl_TestFpgaRstDly3_s <= '0';
        elsif rising_edge(CpSl_Clk_i) then
            PrSl_TestFpgaRstDly1_s <= CpSl_RstVld_i;
            PrSl_TestFpgaRstDly2_s <= PrSl_TestFpgaRstDly1_s;
            PrSl_TestFpgaRstDly3_s <= PrSl_TestFpgaRstDly2_s;
        end if;
    end process;
    -- Test FPGA Trig
    PrSl_TestFpgaRstTrig_s <= PrSl_TestFpgaRstDly2_s and (not PrSl_TestFpgaRstDly3_s);
    
    -- CpSl_CmpVolVld_i
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_CmpVolVldDly1_s <= '0';
            PrSl_CmpVolVldDly2_s <= '0';
            PrSl_CmpVolVldDly3_s <= '0';
        elsif rising_edge(CpSl_Clk_i) then
            PrSl_CmpVolVldDly1_s <= CpSl_CmpVolVld_i;
            PrSl_CmpVolVldDly2_s <= PrSl_CmpVolVldDly1_s;
            PrSl_CmpVolVldDly3_s <= PrSl_CmpVolVldDly2_s;
        end if;
    end process;
    -- Compare Voltage Trig
    PrSl_CmpVolVldTrig_s <= PrSl_CmpVolVldDly2_s and (not PrSl_CmpVolVldDly3_s);
    
    -- CpSl_CmpCurtVld_i
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_CmpCurtDly1_s <= '0';
            PrSl_CmpCurtDly2_s <= '0';
            PrSl_CmpCurtDly3_s <= '0';
        elsif rising_edge(CpSl_Clk_i) then
            PrSl_CmpCurtDly1_s <= CpSl_CmpCurtVld_i;
            PrSl_CmpCurtDly2_s <= PrSl_CmpCurtDly1_s;
            PrSl_CmpCurtDly3_s <= PrSl_CmpCurtDly2_s;
        end if;                  
    end process;
    -- Compare Rowing Trig
    PrSl_CmpCurtTrig_s <= PrSl_CmpCurtDly2_s and (not PrSl_CmpCurtDly3_s);
    
    -- CpSl_TestDvld_i
--    process (CpSl_Rst_iN, CpSl_Clk_i) begin
--        if (CpSl_Rst_iN = '0') then
--            PrSl_TestDvldDly1_s <= '0';
--            PrSl_TestDvldDly2_s <= '0';
--            PrSl_TestDvldDly3_s <= '0';
--        elsif rising_edge(CpSl_Clk_i) then
--            PrSl_TestDvldDly1_s <= CpSl_TestDvld_i;
--            PrSl_TestDvldDly2_s <= PrSl_TestDvldDly1_s;
--            PrSl_TestDvldDly3_s <= PrSl_TestDvldDly2_s;
--        end if;                  
--    end process;
--    -- Compare Rowing Trig
--    PrSl_TestDvldTrig_s <= PrSl_TestDvldDly2_s and (not PrSl_TestDvldDly3_s);

    -- PrSv_TxFrameData_s 
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_TxFrameData_s <= (others => '1');
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSl_FpgaVldTrig_s = '1') then 
                PrSv_TxFrameData_s <= PrSv_FpgaHead_c & CpSv_FpgaType_i;
            elsif (PrSl_TestFpgaRstTrig_s = '1') then 
                PrSv_TxFrameData_s <= PrSv_TestFpgaRst_c;
            elsif (PrSl_CmpVolVldTrig_s = '1') then
                PrSv_TxFrameData_s <= PrSv_CmpVolHead_c(15 downto 3) & CpSv_CmpVolData_i;
            elsif (PrSl_CmpCurtTrig_s = '1') then 
                PrSv_TxFrameData_s <= PrSv_ComCurtHead_c(15 downto 3) & CpSv_CmpCurtData_i;
            elsif (CpSl_TestDvld_i = '1') then 
                PrSv_TxFrameData_s <= CpSv_TestData_i; 
            else -- hold
            end if;
        end if;
    end process;
    
    ------------------------------------
    -- Usrt Tx Data State
    ------------------------------------
    -- Baud counter
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_BaudCnt_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSv_TxDataState_s /= "000") then
                if (PrSv_BaudCnt_s = PrSv_Baud115200_c) then
                    PrSv_BaudCnt_s <= (others => '0');
                else
                    PrSv_BaudCnt_s <= PrSv_BaudCnt_s + '1';
                end if;
            else
                PrSv_BaudCnt_s <= (others => '0');
            end if;
        end if;
    end process;

    -- Uart Tx Trig
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_TxTrig_s <= '0';
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSv_TxDataState_s /= "000") then
                if (PrSv_BaudCnt_s = PrSv_Half115200_c) then
                    PrSl_TxTrig_s <= '1';
                else
                    PrSl_TxTrig_s <= '0';
                end if;
            else
                PrSl_TxTrig_s <= '0';
            end if;
        end if;
    end process;

    -- Uart Tx Trig Cnt
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_TxTrigCnt_s <= "0000";
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSv_TxDataState_s /= "000") then
                if (PrSl_TxTrig_s = '1') then
                    if (PrSv_TxTrigCnt_s = "1001") then
                        PrSv_TxTrigCnt_s <= "0000";
                    else
                        PrSv_TxTrigCnt_s <= PrSv_TxTrigCnt_s + '1';
                    end if;
                end if;
            else
                PrSv_TxTrigCnt_s <= "0000";
            end if;
        end if;
    end process;
    
    -- Send Data State
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_TxDataState_s <= "000";
        elsif rising_edge(CpSl_Clk_i) then
            case PrSv_TxDataState_s is
            when "000" => -- Start 
                if (PrSl_FpgaVldTrig_s = '1' or PrSl_TestFpgaRstTrig_s = '1'
                    or PrSl_CmpVolVldTrig_s = '1' or PrSl_CmpCurtTrig_s = '1'
                    or CpSl_TestDvld_i = '1') then
                    PrSv_TxDataState_s <= "001";
                else
                end if;

            when "001" => -- '0'
                if (PrSl_TxTrig_s = '1' and PrSv_TxTrigCnt_s = "0000") then
                    PrSv_TxDataState_s <= "010";
                else
                end if;

            when "010" => -- 8 bit
                if (PrSl_TxTrig_s = '1' and PrSv_TxTrigCnt_s = "1000") then
                    PrSv_TxDataState_s <= "100";
                else
                end if;
                    
            when "100" => -- '1'
                if (PrSl_TxTrig_s = '1' and PrSv_TxTrigCnt_s = "1001") then
                    PrSv_TxDataState_s <= "101";
                else
                end if;

            when "101" => -- 8bit*3 = 24
                if (PrSv_TxFrameCnt_s = "011") then
                    PrSv_TxDataState_s <= "000";
                else
                    PrSv_TxDataState_s <= "001";
                end if;
                
            when others =>
                PrSv_TxDataState_s <= "000";
            end case;
        end if;
    end process;

    --24 bits Data Control signal
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_TxFrameCnt_s <= "000";
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSv_TxDataState_s = "100" and PrSl_TxTrig_s = '1' and PrSv_TxTrigCnt_s = "1001") then
                PrSv_TxFrameCnt_s <= PrSv_TxFrameCnt_s + '1';
            elsif (PrSv_TxDataState_s = "101" and PrSv_TxFrameCnt_s = "011") then
                PrSv_TxFrameCnt_s <= "000";
            else -- hold 
            end if;
        end if;
    end process;

    -- 24bits to 8Bit*3
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSl_TxHeadEn_s <= '0';
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSl_FpgaVldTrig_s = '1' or PrSl_TestFpgaRstTrig_s = '1'
                or PrSl_CmpVolVldTrig_s = '1' or PrSl_CmpCurtTrig_s = '1' or CpSl_TestDvld_i = '1') then
                PrSl_TxHeadEn_s <= '1';
            elsif (PrSv_TxFrameCnt_s = "011") then
                PrSl_TxHeadEn_s <= '0';
            else
            end if;
       end if;
    end process;

    -- Control TxData
    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then
            PrSv_TxData_s <= (others => '0');
        elsif rising_edge(CpSl_Clk_i) then
            if (PrSl_TxHeadEn_s = '1') then
            case PrSv_TxFrameCnt_s is
                when "000"  => PrSv_TxData_s <= PrSv_TxFrameData_s(23 downto 16);
                when "001"  => PrSv_TxData_s <= PrSv_TxFrameData_s(15 downto  8);
                when "010"  => PrSv_TxData_s <= PrSv_TxFrameData_s( 7 downto  0);
                when others => PrSv_TxData_s <= (others => '0');
            end case;
            else -- hold
            end if;
        end if;
    end process;

    process (CpSl_Rst_iN, CpSl_Clk_i) begin
        if (CpSl_Rst_iN = '0') then 
            CpSl_TxD_o <= '1';
        elsif rising_edge(CpSl_Clk_i) then 
            if (PrSv_TxDataState_s = "001" and PrSl_TxTrig_s = '1') then 
                CpSl_TxD_o <= '0';
            elsif (PrSv_TxDataState_s = "010" and PrSl_TxTrig_s = '1') then
                case PrSv_TxTrigCnt_s is
                    when "0001" => CpSl_TxD_o <= PrSv_TxData_s(0);
                    when "0010" => CpSl_TxD_o <= PrSv_TxData_s(1);
                    when "0011" => CpSl_TxD_o <= PrSv_TxData_s(2);
                    when "0100" => CpSl_TxD_o <= PrSv_TxData_s(3);
                    when "0101" => CpSl_TxD_o <= PrSv_TxData_s(4);
                    when "0110" => CpSl_TxD_o <= PrSv_TxData_s(5);
                    when "0111" => CpSl_TxD_o <= PrSv_TxData_s(6);
                    when "1000" => CpSl_TxD_o <= PrSv_TxData_s(7);
                    when others => CpSl_TxD_o <= '1';
                end case;
            elsif (PrSv_TxDataState_s = "100" and PrSl_TxTrig_s = '1') then 
                CpSl_TxD_o <= '1';
            else
            end if;
        end if;
    end process;


end arch_M_UartSend;