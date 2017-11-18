library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity M_FpgaTypeTb is
end M_FpgaTypeTb;

architecture arch_M_FpgaTypeTb of M_FpgaTypeTb is
    ------------------------------------
    -- constant declaration
    ------------------------------------
    constant PrSv_VolData_c             : std_logic_vector(110 downto 0) := '1'&x"88"&'0'&'1'&x"13"&'0'&'1'&x"E4"&'0'&'1'&x"0C"&'0'
                                                                            &'1'&x"C4"&'0'&'1'&x"09"&'0'&'1'&x"DC"&'0'&'1'&x"05"&'0'
                                                                            &'1'&x"C1"&'0'&'1'&x"4A"&'0'&'1'&x"A5"&'0'&'1';
    ------------------------------------
    -- component declaration
    ------------------------------------
    component M_FpgaType is port (
        --------------------------------
        -- Reset and Clock
        --------------------------------
        CpSl_Rst_iN                     : in  std_logic;                        -- Reset, active low
        CpSl_Clk_i                      : in  std_logic;                        -- 100MHz clock

        --------------------------------
        -- GPIO 
        --------------------------------
        CpSv_Gpio_i                    : in  std_logic_vector(2 downto 0);      -- GPIO

        --------------------------------
        -- FPGA Style
        --------------------------------
        CpSl_FpgaVld_o                  : out std_logic;                        -- FPGA Style Valid
        CpSv_FpgaType_o                 : out std_logic_vector(7 downto 0)      -- FPGA Style
    );
    end component;
    
    ----------------------------------------------------------------------------
    --signal declaration
    ----------------------------------------------------------------------------
    signal CpSl_Rst_iN                  : std_logic;
    signal CpSl_Clk_i                   : std_logic;
    signal CpSv_Gpio_i                  : std_logic_vector(2 downto 0);
    signal CpSl_FpgaVld_o               : std_logic;
    signal CpSv_FpgaType_o              : std_logic_vector(7 downto 0);
    
    ----------------------------------------------------------------------------
    --constant declaration
    ----------------------------------------------------------------------------

begin
    ----------------------------------------------------------------------------
    --component map
    ----------------------------------------------------------------------------
    U_M_FpgaType : M_FpgaType  port map(
        --------------------------------
        -- Reset and Clock
        --------------------------------
        CpSl_Rst_iN                     => CpSl_Rst_iN                          ,-- Reset, active low
        CpSl_Clk_i                      => CpSl_Clk_i                           ,-- 100MHz clock
                                                                                
        --------------------------------                                        
        -- GPIO                                                                 
        --------------------------------                                        
        CpSv_Gpio_i                     => CpSv_Gpio_i                          , -- GPIO

        -------------------------------- 
        -- FPGA Style                    
        -------------------------------- 
        CpSl_FpgaVld_o                  => CpSl_FpgaVld_o                       , -- FPGA Style Valid
        CpSv_FpgaType_o                 => CpSv_FpgaType_o                        -- FPGA Style
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
    
    CpSv_Gpio_i <= "001";

--    process 
--        varibale i : from 0 to 110 := '0';
--    begin
--        CpSl_RxD_i <= PrSv_VolData_c(i);
--        wait for 8680;
--        i <= i + '1';
--    end process;    
end arch_M_FpgaTypeTb;