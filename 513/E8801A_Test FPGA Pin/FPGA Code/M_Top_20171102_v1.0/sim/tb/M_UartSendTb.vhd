library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity M_UartSendTb is
end M_UartSendTb;

architecture arch_M_UartSendTb of M_UartSendTb is
    ------------------------------------
    -- constant declaration
    ------------------------------------
    constant PrSv_VolData_c             : std_logic_vector(110 downto 0) := '1'&x"88"&'0'&'1'&x"13"&'0'&'1'&x"E4"&'0'&'1'&x"0C"&'0'
                                                                            &'1'&x"C4"&'0'&'1'&x"09"&'0'&'1'&x"DC"&'0'&'1'&x"05"&'0'
                                                                            &'1'&x"C1"&'0'&'1'&x"4A"&'0'&'1'&x"A5"&'0'&'1';
                                                                            
    constant PrSv_CurtData_o            : std_logic_vector(110 downto 0) := '1'&x"FE"&'0'&'1'&x"EF"&'0'&'1'&x"FE"&'0'&'1'&x"EF"&'0'
                                                                            &'1'&x"C4"&'0'&'1'&x"00"&'0'&'1'&x"FE"&'0'&'1'&x"EF"&'0'
                                                                            &'1'&x"C1"&'0'&'1'&x"B4"&'0'&'1'&x"A5"&'0'&'1';
    
    constant PrSv_JtagData_o            : std_logic_vector( 50 downto 0) := '1'&x"CC"&'0'&'1'&x"BB"&'0'&'1'&x"AA"&'0'&'1'&x"DD"&'0'&'1'&x"A5"&'0'&'1'; 
    
    constant PrSv_CmdData_o             : std_logic_vector( 50 downto 0) := '1'&x"AA"&'0'&'1'&x"00"&'0'&'1'&x"00"&'0'&'1'&x"AA"&'0'&'1'&x"A5"&'0'&'1'; 
                                                                                                                                                   
                                                                            
    ------------------------------------
    -- component declaration
    ------------------------------------
    component M_UartSend is port (
        --------------------------------
        -- Reset and Clock
        --------------------------------
        CpSl_Rst_i                      : in  std_logic;                        -- Reset, Active low
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
        -- Uart Tx Data
        --------------------------------
        CpSl_TxD_o                      : out std_logic                         -- Transfer Data
    );
    end component;
    
    ----------------------------------------------------------------------------
    --signal declaration
    ----------------------------------------------------------------------------
    signal CpSl_Rst_iN                  : std_logic;
    signal CpSl_Clk_i                   : std_logic;
    signal CpSl_FpgaVld_i               : std_logic;                        -- FPGA Style Valid
    signal CpSv_FpgaType_i              : std_logic_vector(7 downto 0);     -- FPGA Style
    signal CpSl_RstVld_i                : std_logic;                        -- Test FPGA Reset Valid      
    signal CpSl_CmpVolVld_i             : std_logic;                        -- Copmare Voltage Valid
    signal CpSv_CmpVolData_i            : std_logic_vector(10 downto 0);    -- Copmare Voltage Valid Data
    signal CpSl_CmpCurtVld_i            : std_logic;                        -- Compare Current Valid
    signal CpSv_CmpCurtData_i           : std_logic_vector(10 downto 0);    -- Compare Current Valid Data
    signal CpSl_TxD_o                   : std_logic;                        -- Transfer Data

    ----------------------------------------------------------------------------
    --constant declaration
    ----------------------------------------------------------------------------

begin
    ----------------------------------------------------------------------------
    --component map
    ----------------------------------------------------------------------------
    U_M_UartSend : M_UartSend port map(
        --------------------------------
        -- Reset and Clock
        --------------------------------
        CpSl_Rst_i                      => CpSl_Rst_iN                          , -- Reset, Active low
        CpSl_Clk_i                      => CpSl_Clk_i                           , -- 100MHz Clock

        --------------------------------
        -- FPGA Type
        --------------------------------
        CpSl_FpgaVld_i                  => CpSl_FpgaVld_i                       , -- FPGA Style Valid
        CpSv_FpgaType_i                 => CpSv_FpgaType_i                      , -- FPGA Style

        --------------------------------
        -- Test FPGA Reset/Vol/Current
        --------------------------------
        CpSl_RstVld_i                   => CpSl_RstVld_i                        , -- Test FPGA Reset Valid      
        CpSl_CmpVolVld_i                => CpSl_CmpVolVld_i                     , -- Copmare Voltage Valid
        CpSv_CmpVolData_i               => CpSv_CmpVolData_i                    , -- Copmare Voltage Valid Data
        CpSl_CmpCurtVld_i               => CpSl_CmpCurtVld_i                    , -- Compare Current Valid
        CpSv_CmpCurtData_i              => CpSv_CmpCurtData_i                   , -- Compare Current Valid Data

        --------------------------------
        -- Uart Tx Data
        --------------------------------
        CpSl_TxD_o                      => CpSl_TxD_o                             -- Transfer Data
    );
    
    ----------------------------------------------------------------------------
    -- Rst & Clk
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

    ------------------------------------
    -- FPGA Type
    ------------------------------------
    process begin
        CpSl_FpgaVld_i <= '0';
        wait for 200 ns;
        CpSl_FpgaVld_i <= '1';
        wait for 400 ns;
        CpSl_FpgaVld_i <= '0';
        wait;
    end process;
    
    CpSv_FpgaType_i <= x"C1";
    
    ------------------------------------
    -- CpSl_RstVld_i
    ------------------------------------
    process begin
        CpSl_RstVld_i <= '0';
        wait for 600 us;
        CpSl_RstVld_i <= '1';
        wait for 601 us;
        CpSl_RstVld_i <= '0';
        wait;
    end process;
    
    ------------------------------------
    -- CpSl_CmpVolVld_i
    ------------------------------------
    process begin
        CpSl_CmpVolVld_i <= '0';
        wait for 1000 us;
        CpSl_CmpVolVld_i <= '1';
        wait for 1001 us;
        CpSl_CmpVolVld_i <= '0';
        wait;
    end process;
    
    CpSv_CmpVolData_i <= "00100000101";
    
    ------------------------------------
    -- CpSl_CmpCurtVld_i
    ------------------------------------
    process begin
        CpSl_CmpCurtVld_i <= '0';
        wait for 1400 us;
        CpSl_CmpCurtVld_i <= '1';
        wait for 1401 us;
        CpSl_CmpCurtVld_i <= '0';
        wait;
    end process;
    
    CpSv_CmpCurtData_i <= "00100001010";
    
    
    
end arch_M_UartSendTb;