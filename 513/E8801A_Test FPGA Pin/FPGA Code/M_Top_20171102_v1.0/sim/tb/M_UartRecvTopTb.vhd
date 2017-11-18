library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity M_UartRecvTopTb is
end M_UartRecvTopTb;

architecture arch_M_UartRecvTopTb of M_UartRecvTopTb is
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
    component M_UartRecvTop is port (
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      : in  std_logic;                        -- 100MHz clock

        --------------------------------
        -- Uart Receive Interface 
        --------------------------------
        CpSl_RxD_i                      : in  std_logic;                        -- Receive data

        --------------------------------
        -- Vol/Curt/Cmd output
        --------------------------------
        CpSl_VolDvld_o                  : out std_logic;                        -- Parallel Voltage data valid
        CpSv_VolData_o                  : out std_logic_vector(71 downto 0);    -- Parallel Voltage data
        CpSl_CurtDvld_o                 : out std_logic;                        -- Parallel Current data valid
        CpSv_CurtData_o                 : out std_logic_vector(71 downto 0);    -- Parallel Current data
        CpSl_JtagDvld_o                 : out std_logic;                        -- Parallel JTAG data valid
        CpSv_JtagData_o                 : out std_logic_vector(23 downto 0);    -- Parallel JTAG data
        CpSl_TestDvld_o                 : out std_logic;                        -- Parallel Test_Cmd data valid
        CpSv_TestData_o                 : out std_logic_vector(23 downto 0)     -- Parallel Test_Cmd data
    );
    end component;
    
    ----------------------------------------------------------------------------
    --signal declaration
    ----------------------------------------------------------------------------
    signal CpSl_Rst_iN                  : std_logic;
    signal CpSl_Clk_i                   : std_logic;
    signal CpSl_RxD_i                   : std_logic;
    signal CpSl_VolDvld_o               : std_logic;                        -- Parallel Voltage data valid         
    signal CpSv_VolData_o               : std_logic_vector(71 downto 0);    -- Parallel Voltage data       
    signal CpSl_CurtDvld_o              : std_logic;                        -- Parallel Current data valid 
    signal CpSv_CurtData_o              : std_logic_vector(71 downto 0);    -- Parallel Current data       
    signal CpSl_JtagDvld_o              : std_logic;                        -- Parallel JTAG data valid    
    signal CpSv_JtagData_o              : std_logic_vector(23 downto 0);    -- Parallel JTAG data          
    signal CpSl_TestDvld_o              : std_logic;                        -- Parallel Test_Cmd data valid
    signal CpSv_TestData_o              : std_logic_vector(23 downto 0);    -- Parallel Test_Cmd data      

    signal PrSv_LongData_s              : std_logic_vector(71 downto 0);    -- Voltage & Current Data
    signal PrSv_CommandData_s           : std_logic_vector(23 downto 0);    -- JTAG & Test Pin Data
    ----------------------------------------------------------------------------
    --constant declaration
    ----------------------------------------------------------------------------

begin
    ----------------------------------------------------------------------------
    --component map
    ----------------------------------------------------------------------------
    U_M_UartRecvTop : M_UartRecvTop port map(
        --------------------------------
        -- Reset and clock
        --------------------------------
        CpSl_Rst_iN                     => CpSl_Rst_iN                          , -- Reset, active low
        CpSl_Clk_i                      => CpSl_Clk_i                           , -- 100MHz clock
                                                                                
        --------------------------------                                        
        -- Uart Receive Interface                                              
        --------------------------------                                        
        CpSl_RxD_i                      => CpSl_RxD_i                           , -- Receive data
                                                                                
        --------------------------------
        -- Vol/Curt/Cmd output                                                 
        --------------------------------                                       
        CpSl_VolDvld_o                  => CpSl_VolDvld_o                       , -- Parallel Voltage data valid
        CpSv_VolData_o                  => CpSv_VolData_o                       , -- Parallel Voltage data
        CpSl_CurtDvld_o                 => CpSl_CurtDvld_o                      , -- Parallel Current data valid
        CpSv_CurtData_o                 => CpSv_CurtData_o                      , -- Parallel Current data
        CpSl_JtagDvld_o                 => CpSl_JtagDvld_o                      , -- Parallel JTAG data valid
        CpSv_JtagData_o                 => CpSv_JtagData_o                      , -- Parallel JTAG data
        CpSl_TestDvld_o                 => CpSl_TestDvld_o                      , -- Parallel Test_Cmd data valid
        CpSv_TestData_o                 => CpSv_TestData_o                        -- Parallel Test_Cmd data
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


    process 
        variable i : integer range 0 to 50 := 0;
    begin
        for i in 0 to 50 loop
--            CpSl_RxD_i <= PrSv_VolData_c(i);
            CpSl_RxD_i <= PrSv_CmdData_o(i);
            wait for 8680 ns;
        end loop;
    end process;
end arch_M_UartRecvTopTb;