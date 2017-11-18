library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity M_CmdParseTb is
end M_CmdParseTb;

architecture arch_M_CmdParseTb of M_CmdParseTb is
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
    component M_CmdParse is port (
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
        CpSl_FpgaRst_o                  : out std_logic;                        -- FPGA Reset
        CpSv_SelectIO_o                 : out std_logic_vector(20 downto 0)     -- Test IO select
    );
    end component;
    
    ----------------------------------------------------------------------------
    --signal declaration
    ----------------------------------------------------------------------------
    signal CpSl_Rst_iN                  : std_logic;
    signal CpSl_Clk_i                   : std_logic;
    signal CpSl_JtagDvld_i              : std_logic;                        -- Parallel JTAG data valid    
    signal CpSv_JtagData_i              : std_logic_vector(23 downto 0);    -- Parallel JTAG data          
    signal CpSl_TestDvld_i              : std_logic;                        -- Parallel Test_Cmd data valid     
    signal CpSv_TestData_i              : std_logic_vector(23 downto 0);    -- Parallel Test_Cmd data      
    signal CpSl_RstVld_o                : std_logic;                        -- FPGA Reset Valid
    signal CpSl_FpgaRst_o               : std_logic;                        -- FPGA Reset      
    signal CpSv_SelectIO_o              : std_logic_vector(20 downto 0);    -- Test IO select  

    ----------------------------------------------------------------------------
    --constant declaration
    ----------------------------------------------------------------------------

begin
    ----------------------------------------------------------------------------
    --component map
    ----------------------------------------------------------------------------
    U_M_CmdParse : M_CmdParse port map(
        --------------------------------
        -- Reset and Clock
        --------------------------------
        CpSl_Rst_iN                     => CpSl_Rst_iN                          , -- Reset, Active low
        CpSl_Clk_i                      => CpSl_Clk_i                           , -- 100MHz Clock

        -------------------------------- 
        -- JTAG/Test Valid               
        -------------------------------- 
        CpSl_JtagDvld_i                 => CpSl_JtagDvld_i                      , -- Parallel JTAG data valid
        CpSv_JtagData_i                 => CpSv_JtagData_i                      , -- Parallel JTAG data
        CpSl_TestDvld_i                 => CpSl_TestDvld_i                      , -- Parallel Test_Cmd data valid
        CpSv_TestData_i                 => CpSv_TestData_i                      , -- Parallel Test_Cmd data
                                        
        -------------------------------- 
        -- Reset/Test Pin                
        -------------------------------- 
        CpSl_RstVld_o                   => CpSl_RstVld_o                        , -- FPGA Reset Valid
        CpSl_FpgaRst_o                  => CpSl_FpgaRst_o                       , -- FPGA Reset
        CpSv_SelectIO_o                 => CpSv_SelectIO_o                        -- Test IO select
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
    -- CpSl_JtagDvld_i
    ------------------------------------
    process begin
        CpSl_JtagDvld_i <= '0';
        wait for 200 ns;
        CpSl_JtagDvld_i <= '1';
        wait for 250 ns;
        CpSl_JtagDvld_i <= '0';
        wait;
    end process;
    
    CpSv_JtagData_i <= x"AABBCC";
    
    ------------------------------------
    -- CpSl_TestDvld_i
    ------------------------------------
    process begin
        CpSl_TestDvld_i <= '0';
        wait for 600 us;
        CpSl_TestDvld_i <= '1';
        wait for 601 us;
        CpSl_TestDvld_i <= '0';
        wait;
    end process;
    
    CpSv_TestData_i <= x"FAADEB";
    
end arch_M_CmdParseTb;