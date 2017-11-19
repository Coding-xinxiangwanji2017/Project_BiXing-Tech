-- file: M_HSelectIO_exdes.vhd
-- (c) Copyright 2009 - 2011 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.

------------------------------------------------------------------------------
-- SelectIO wizard example design
------------------------------------------------------------------------------
-- This example design instantiates the IO circuitry
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_misc.and_reduce;

library unisim;
use unisim.vcomponents.all;

entity M_HSelectIO_exdes is
generic (
  -- width of the data for the system
  sys_w      : integer := 15;
  -- width of the data for the device
  dev_w      : integer := 105
);
port (
  PATTERN_COMPLETED_OUT     : out   std_logic_vector (1 downto 0);
  -- From the system into the device
  DATA_IN_FROM_PINS_P      : in    std_logic_vector(sys_w-1 downto 0);
  DATA_IN_FROM_PINS_N      : in    std_logic_vector(sys_w-1 downto 0);
  DATA_OUT_TO_PINS_P         : out   std_logic_vector(sys_w-1 downto 0);
  DATA_OUT_TO_PINS_N         : out   std_logic_vector(sys_w-1 downto 0);

  CLK_IN                   : in    std_logic;
  CLK_RESET                : in    std_logic;
  IO_RESET                 : in    std_logic);
end M_HSelectIO_exdes;

architecture xilinx of M_HSelectIO_exdes is

component M_HSelectIO is
generic
 (-- width of the data for the system
  sys_w       : integer := 15;
  -- width of the data for the device
  dev_w       : integer := 105);
port
 (
  -- From the device out to the system
  DATA_OUT_FROM_DEVICE    : in    std_logic_vector(dev_w-1 downto 0);
  DATA_OUT_TO_PINS_P      : out   std_logic_vector(sys_w-1 downto 0);
  DATA_OUT_TO_PINS_N      : out   std_logic_vector(sys_w-1 downto 0);

-- Clock and reset signals
  CLK_IN                  : in    std_logic;                    -- Fast clock from PLL/MMCM 
  CLK_DIV_IN              : in    std_logic;                    -- Slow clock from PLL/MMCM
  LOCKED_IN               : in    std_logic;
  LOCKED_OUT              : out   std_logic;
  IO_RESET                : in    std_logic);                   -- Reset signal for IO circuit
end component;

   constant num_serial_bits  : integer := dev_w/sys_w;
   signal unused             : std_logic;
   signal clkin1             : std_logic;
   signal count_out          : std_logic_vector (num_serial_bits-1 downto 0);
   signal local_counter      : std_logic_vector(num_serial_bits-1 downto 0);
   signal count_out1         : std_logic_vector (num_serial_bits-1 downto 0);
   signal count_out2         : std_logic_vector (num_serial_bits-1 downto 0);
   signal pat_out            : std_logic_vector (num_serial_bits-1 downto 0);
   signal pattern_completed    : std_logic_vector (1 downto 0) := "00";
   signal clk_in_int_inv       : std_logic;
   signal clk_in_int_inv_c     : std_logic;
   signal clk_div_int               : std_logic;
   signal clk_in_int_buf            : std_logic;
            -- connection between ram and io circuit
   signal data_in_to_device         : std_logic_vector(dev_w-1 downto 0);
   signal data_in_to_device_int2    : std_logic_vector(dev_w-1 downto 0);
   signal data_in_to_device_int3    : std_logic_vector(dev_w-1 downto 0);

   signal data_out_from_device : std_logic_vector(dev_w-1 downto 0);

    type serdarr is array (0 to 7) of std_logic_vector(sys_w-1 downto 0);
   signal serdesstrobe             : std_logic;
   signal iserdes_q                : serdarr := (( others => (others => '0')));
   signal icascade                 : std_logic_vector(sys_w-1 downto 0);

   signal data_out_from_device_q    : std_logic_vector(dev_w-1 downto 0) ;
   signal data_in_from_pins_int     : std_logic_vector(sys_w-1 downto 0);
   signal data_in_to_device_int     : std_logic_vector(dev_w-1 downto 0);
   signal tristate_predelay         : std_logic_vector(sys_w-1 downto 0);
   signal data_out_to_pins_int      : std_logic_vector(sys_w-1 downto 0);
   signal data_out_to_pins_predelay : std_logic_vector(sys_w-1 downto 0);
   constant clock_enable            : std_logic := '1';

   signal clkfbout             : std_logic;
   signal clkfbout_buf         : std_logic;
   signal clk_in_pll           : std_logic;
   signal clk_in_pll1          : std_logic;
   signal locked_in            : std_logic;
   signal locked_out           : std_logic;
   signal clk_div_in_int       : std_logic;
   signal clk_div_in           : std_logic;
   signal rst_sync      : std_logic;
   signal rst_sync_int  : std_logic;
   signal rst_sync_int1 : std_logic;
   signal rst_sync_int2 : std_logic;
   signal rst_sync_int3 : std_logic;
   signal rst_sync_int4 : std_logic;
   signal rst_sync_int5 : std_logic;
   signal rst_sync_int6 : std_logic;
   signal bitslip       : std_logic := '0';
   signal bitslip_int   : std_logic := '0';
   signal equal         : std_logic := '0';
   signal equal1        : std_logic := '0';
   signal count_out3    : std_logic_vector(2 downto 0);
   signal start_count   : std_logic := '0';
   signal start_check   : std_logic := '0';
   signal bit_count     : std_logic_vector (2 downto 0);
   type delay_arr is array (0 to sys_w -1) of std_logic_vector(num_serial_bits-1 downto 0);
   signal data_delay_int1 : delay_arr;
   signal data_delay_int2 : delay_arr;
   signal data_delay     : delay_arr; 
   signal slave_shiftout          : std_logic_vector(sys_w-1 downto 0);

   attribute KEEP : string;
   attribute KEEP of clk_div_in_int : signal is "TRUE";



begin

   process (clk_div_in, IO_RESET) begin
     if (IO_RESET = '1') then
       rst_sync <= '1';
       rst_sync_int <= '1';
       rst_sync_int1 <= '1';
       rst_sync_int2 <= '1';
       rst_sync_int3 <= '1';
       rst_sync_int4 <= '1';
       rst_sync_int5 <= '1';
       rst_sync_int6 <= '1';
     elsif (clk_div_in = '1' and clk_div_in'event) then
       rst_sync <= '0';
       rst_sync_int <= rst_sync;
       rst_sync_int1 <= rst_sync_int;
       rst_sync_int2 <= rst_sync_int1;
       rst_sync_int3 <= rst_sync_int2;
       rst_sync_int4 <= rst_sync_int3;
       rst_sync_int5 <= rst_sync_int4;
       rst_sync_int6 <= rst_sync_int5;
     end if;
   end process;



   clkin_in_buf : IBUFG
   port map
     (O => clkin1,
      I => CLK_IN);

   -- set up the fabric PLL_BASE to drive the BUFPLL
   pll_base_inst : PLL_BASE
    generic map (
      BANDWIDTH             => "OPTIMIZED",
      CLK_FEEDBACK          => "CLKFBOUT",
      COMPENSATION          => "SYSTEM_SYNCHRONOUS",
      DIVCLK_DIVIDE         => 1,
      CLKFBOUT_MULT         => 4,
      CLKFBOUT_PHASE        => 0.000,
      CLKOUT0_DIVIDE        => 4,
      CLKOUT0_PHASE         => 0.000,
      CLKOUT0_DUTY_CYCLE    => 0.500,
      CLKOUT2_DIVIDE        => 4*num_serial_bits,
      CLKOUT2_PHASE         => 0.000,
      CLKOUT2_DUTY_CYCLE    => 0.500,
      CLKIN_PERIOD          => 10.0,
      REF_JITTER            => 0.010)
   port map (
     -- Output clocks
      CLKFBOUT              => clkfbout,
      CLKOUT0               => clk_in_pll1,
      CLKOUT1               => open,
      CLKOUT2               => clk_div_in_int,
      CLKOUT3               => open,
      CLKOUT4               => open,
      CLKOUT5               => open,
      -- Status and control signals
      LOCKED                => locked_in,
      RST                   => CLK_RESET,
      -- Input clock control
      CLKFBIN               => clkfbout_buf,
      CLKIN                 => clkin1);

   clkfb_buf : BUFG
    port map (
      O            => clkfbout_buf,
      I            => clkfbout);

   clkd_buf : BUFG
    port map (
      O            => clk_div_in,
      I            => clk_div_in_int);


   clko_buf : BUFG
    port map (
      O            => clk_in_pll,
      I            => clk_in_pll1);



   process(clk_div_in) begin
   if (clk_div_in='1' and clk_div_in'event) then
     if (rst_sync_int6 = '1') then
       equal1 <= '0';
     else
       if (count_out3 = "100") then
          equal1 <= equal;
       else
          equal1 <= equal1;
       end if;
     end if;
    end if;
   end process;


   process(clk_div_in) begin
   if (clk_div_in='1' and clk_div_in'event) then
     if (rst_sync_int6 = '1') then
       count_out3 <= (others => '0');
     elsif (equal = '1' and count_out3 < "100" ) then
       count_out3 <= count_out3 + 1;
     else
       count_out3 <= (others => '0');
     end if;
    end if;
   end process;

   process(clk_div_in) begin
   if (clk_div_in='1' and clk_div_in'event) then
     if (rst_sync_int6 = '1') then
       count_out1 <= (others => '0');
       pat_out <= "1011001";
       count_out1 <= (others => '0');
     elsif locked_in='1' then  
     if equal1='0' then
      pat_out <= "1011001";
       count_out1 <= (others => '0');
    else
       count_out1 <= count_out1 + 1;
     end if;
    end if;
   end if;
  end process;

   process(clk_div_in) begin
   if (clk_div_in='1' and clk_div_in'event) then
     if (rst_sync_int6 = '1') then
       count_out2 <= (others => '0');
     elsif equal1='1' then
       count_out2 <= count_out1;
     else
       count_out2 <= pat_out;
     end if;
    end if;
   end process;   

   process(clk_div_in) begin
   if (clk_div_in='1' and clk_div_in'event) then
     if (rst_sync_int6 = '1') then
       count_out <= (others => '0');
     else
       count_out <= count_out2;
     end if;
    end if;
   end process; 
   


assign:for assg in 0 to num_serial_bits-1 generate begin
pinsss:for pinsss in 0 to sys_w-1 generate begin
   data_out_from_device(pinsss+sys_w*assg) <= count_out(assg);
end generate pinsss;
end generate assign;

   data_delay(0) <=                 data_in_to_device(90) &
                data_in_to_device(75) &
                data_in_to_device(60) &
                data_in_to_device(45) &
                data_in_to_device(30) &
                data_in_to_device(15) &
   data_in_to_device(0);
   data_delay(1) <=                 data_in_to_device(91) &
                data_in_to_device(76) &
                data_in_to_device(61) &
                data_in_to_device(46) &
                data_in_to_device(31) &
                data_in_to_device(16) &
   data_in_to_device(1);
   data_delay(2) <=                 data_in_to_device(92) &
                data_in_to_device(77) &
                data_in_to_device(62) &
                data_in_to_device(47) &
                data_in_to_device(32) &
                data_in_to_device(17) &
   data_in_to_device(2);
   data_delay(3) <=                 data_in_to_device(93) &
                data_in_to_device(78) &
                data_in_to_device(63) &
                data_in_to_device(48) &
                data_in_to_device(33) &
                data_in_to_device(18) &
   data_in_to_device(3);
   data_delay(4) <=                 data_in_to_device(94) &
                data_in_to_device(79) &
                data_in_to_device(64) &
                data_in_to_device(49) &
                data_in_to_device(34) &
                data_in_to_device(19) &
   data_in_to_device(4);
   data_delay(5) <=                 data_in_to_device(95) &
                data_in_to_device(80) &
                data_in_to_device(65) &
                data_in_to_device(50) &
                data_in_to_device(35) &
                data_in_to_device(20) &
   data_in_to_device(5);
   data_delay(6) <=                 data_in_to_device(96) &
                data_in_to_device(81) &
                data_in_to_device(66) &
                data_in_to_device(51) &
                data_in_to_device(36) &
                data_in_to_device(21) &
   data_in_to_device(6);
   data_delay(7) <=                 data_in_to_device(97) &
                data_in_to_device(82) &
                data_in_to_device(67) &
                data_in_to_device(52) &
                data_in_to_device(37) &
                data_in_to_device(22) &
   data_in_to_device(7);
   data_delay(8) <=                 data_in_to_device(98) &
                data_in_to_device(83) &
                data_in_to_device(68) &
                data_in_to_device(53) &
                data_in_to_device(38) &
                data_in_to_device(23) &
   data_in_to_device(8);
   data_delay(9) <=                 data_in_to_device(99) &
                data_in_to_device(84) &
                data_in_to_device(69) &
                data_in_to_device(54) &
                data_in_to_device(39) &
                data_in_to_device(24) &
   data_in_to_device(9);
   data_delay(10) <=                 data_in_to_device(100) &
                data_in_to_device(85) &
                data_in_to_device(70) &
                data_in_to_device(55) &
                data_in_to_device(40) &
                data_in_to_device(25) &
   data_in_to_device(10);
   data_delay(11) <=                 data_in_to_device(101) &
                data_in_to_device(86) &
                data_in_to_device(71) &
                data_in_to_device(56) &
                data_in_to_device(41) &
                data_in_to_device(26) &
   data_in_to_device(11);
   data_delay(12) <=                 data_in_to_device(102) &
                data_in_to_device(87) &
                data_in_to_device(72) &
                data_in_to_device(57) &
                data_in_to_device(42) &
                data_in_to_device(27) &
   data_in_to_device(12);
   data_delay(13) <=                 data_in_to_device(103) &
                data_in_to_device(88) &
                data_in_to_device(73) &
                data_in_to_device(58) &
                data_in_to_device(43) &
                data_in_to_device(28) &
   data_in_to_device(13);
   data_delay(14) <=                 data_in_to_device(104) &
                data_in_to_device(89) &
                data_in_to_device(74) &
                data_in_to_device(59) &
                data_in_to_device(44) &
                data_in_to_device(29) &
   data_in_to_device(14);

   process (clk_div_in) begin
   if (clk_div_in='1' and clk_div_in'event) then
     if (rst_sync_int6 = '1') then
       start_check <= '0';
     else
       if (data_delay(0) /= "0000000") then
 
         start_check <= '1';
       end if;
     end if;
    end if;
   end process;

   process (clk_div_in) begin
   if (clk_div_in='1' and clk_div_in'event) then
     if (rst_sync_int6 = '1') then
       start_count <= '0';
     else
       if (data_delay(0) = "0000001" and equal = '1') then
 
         start_count <= '1';
       end if;
     end if;
    end if;
   end process;

   process (clk_div_in) begin
   if (clk_div_in='1' and clk_div_in'event) then    
     if (rst_sync_int6 = '1') then
       local_counter <= (others =>'0');
     else
       if start_count = '1' then
         local_counter <= local_counter + 1;
       else
         local_counter <= (others =>'0');
       end if;
     end if;
    end if;
   end process;

   process (clk_div_in) begin
   if (clk_div_in='1' and clk_div_in'event) then
     if (rst_sync_int6 = '1') then
       data_delay_int1(0) <= (others => '0');
       data_delay_int2(0) <= (others => '0');
       data_delay_int1(1) <= (others => '0');
       data_delay_int2(1) <= (others => '0');
       data_delay_int1(2) <= (others => '0');
       data_delay_int2(2) <= (others => '0');
       data_delay_int1(3) <= (others => '0');
       data_delay_int2(3) <= (others => '0');
       data_delay_int1(4) <= (others => '0');
       data_delay_int2(4) <= (others => '0');
       data_delay_int1(5) <= (others => '0');
       data_delay_int2(5) <= (others => '0');
       data_delay_int1(6) <= (others => '0');
       data_delay_int2(6) <= (others => '0');
       data_delay_int1(7) <= (others => '0');
       data_delay_int2(7) <= (others => '0');
       data_delay_int1(8) <= (others => '0');
       data_delay_int2(8) <= (others => '0');
       data_delay_int1(9) <= (others => '0');
       data_delay_int2(9) <= (others => '0');
       data_delay_int1(10) <= (others => '0');
       data_delay_int2(10) <= (others => '0');
       data_delay_int1(11) <= (others => '0');
       data_delay_int2(11) <= (others => '0');
       data_delay_int1(12) <= (others => '0');
       data_delay_int2(12) <= (others => '0');
       data_delay_int1(13) <= (others => '0');
       data_delay_int2(13) <= (others => '0');
       data_delay_int1(14) <= (others => '0');
       data_delay_int2(14) <= (others => '0');
     else
       data_delay_int1(0) <= data_delay(0);
       data_delay_int2(0) <= data_delay_int1(0);
       data_delay_int1(1) <= data_delay(1);
       data_delay_int2(1) <= data_delay_int1(1);
       data_delay_int1(2) <= data_delay(2);
       data_delay_int2(2) <= data_delay_int1(2);
       data_delay_int1(3) <= data_delay(3);
       data_delay_int2(3) <= data_delay_int1(3);
       data_delay_int1(4) <= data_delay(4);
       data_delay_int2(4) <= data_delay_int1(4);
       data_delay_int1(5) <= data_delay(5);
       data_delay_int2(5) <= data_delay_int1(5);
       data_delay_int1(6) <= data_delay(6);
       data_delay_int2(6) <= data_delay_int1(6);
       data_delay_int1(7) <= data_delay(7);
       data_delay_int2(7) <= data_delay_int1(7);
       data_delay_int1(8) <= data_delay(8);
       data_delay_int2(8) <= data_delay_int1(8);
       data_delay_int1(9) <= data_delay(9);
       data_delay_int2(9) <= data_delay_int1(9);
       data_delay_int1(10) <= data_delay(10);
       data_delay_int2(10) <= data_delay_int1(10);
       data_delay_int1(11) <= data_delay(11);
       data_delay_int2(11) <= data_delay_int1(11);
       data_delay_int1(12) <= data_delay(12);
       data_delay_int2(12) <= data_delay_int1(12);
       data_delay_int1(13) <= data_delay(13);
       data_delay_int2(13) <= data_delay_int1(13);
       data_delay_int1(14) <= data_delay(14);
       data_delay_int2(14) <= data_delay_int1(14);
     end if;
   end if;
   end process;

   process (clk_div_in) begin
   if (clk_div_in='1' and clk_div_in'event) then
     if rst_sync_int6 = '1' then
       bitslip_int <= '0';
       equal <= '0';
     else
      if (equal = '0' and locked_in = '1' and start_check = '1') then
        if (
      (data_delay(14) = pat_out) and
      (data_delay(13) = pat_out) and
      (data_delay(12) = pat_out) and
      (data_delay(11) = pat_out) and
      (data_delay(10) = pat_out) and
      (data_delay(9) = pat_out) and
      (data_delay(8) = pat_out) and
      (data_delay(7) = pat_out) and
      (data_delay(6) = pat_out) and
      (data_delay(5) = pat_out) and
      (data_delay(4) = pat_out) and
      (data_delay(3) = pat_out) and
      (data_delay(2) = pat_out) and
      (data_delay(1) = pat_out) and
      (data_delay(0) = pat_out)) then 
          bitslip_int <= '0';
          equal <= '1';
        else
          bitslip_int <= '1';
          equal <= '0';
        end if;
      else
        bitslip_int <= '0';
      end if;
     end if;
    end if;
   end process;

   process (clk_div_in) begin
   if (clk_div_in='1' and clk_div_in'event) then
     if (rst_sync_int6 = '1') then
       bitslip <= '0';
       bit_count <= "000";
     else
       bit_count <= bit_count + '1';
         if bit_count = "111" then
           if bitslip_int='1' then
             bitslip <= not(bitslip);
           else
             bitslip <= '0';
           end if;
         else
           bitslip <= '0';
         end if;
      end if;
     end if;
   end process;

   process (clk_div_in) begin
   if (clk_div_in='1' and clk_div_in'event) then
     if equal = '1' then
      if (
        (data_delay_int2(1) = local_counter) and
        (data_delay_int2(2) = local_counter) and
        (data_delay_int2(3) = local_counter) and
        (data_delay_int2(4) = local_counter) and
        (data_delay_int2(5) = local_counter) and
        (data_delay_int2(6) = local_counter) and
        (data_delay_int2(7) = local_counter) and
        (data_delay_int2(8) = local_counter) and
        (data_delay_int2(9) = local_counter) and
        (data_delay_int2(10) = local_counter) and
        (data_delay_int2(11) = local_counter) and
        (data_delay_int2(12) = local_counter) and
        (data_delay_int2(13) = local_counter) and
        (data_delay_int2(14) = local_counter) and
        (data_delay_int2(0) = local_counter)) then
        if (local_counter = "1111111") then
          pattern_completed <= "11";
        -- all over
        else
          pattern_completed <= "01";
          -- bitslip done, data checking in progress
        end if;
     else
          if (start_count = '1') then
             pattern_completed <= "10";
         -- incorrect data
          else
             pattern_completed <= pattern_completed;
          end if;
     end if;
   else
          pattern_completed <= "00";
         -- yet to get bitslip
   end if;
  end if;
 end process;



 
   PATTERN_COMPLETED_OUT <= pattern_completed;
  


   bufpll_inst : BUFPLL
    generic map (
      DIVIDE        => 7)
    port map (
      IOCLK        => clk_in_int_buf,
      LOCK         => locked_out,
      SERDESSTROBE => serdesstrobe,
      GCLK         => clk_div_in,  -- GCLK pin must be driven by BUFG
      LOCKED       => locked_in,
      PLLIN        => clk_in_pll1);





  pins: for pin_count in 0 to sys_w-1 generate
    -- Instantiate the buffers
    ----------------------------------
     ibufds_inst : IBUFDS
       generic map (
         DIFF_TERM  => FALSE,             -- Differential termination
         IOSTANDARD => "LVDS_25")
       port map (
         I          => DATA_IN_FROM_PINS_P  (pin_count),
         IB         => DATA_IN_FROM_PINS_N  (pin_count),
         O          => data_in_from_pins_int(pin_count));

     -- Instantiate the serdes primitive
     ----------------------------------
     -- declare the iserdes
     iserdes2_master : ISERDES2
       generic map (
         BITSLIP_ENABLE =>  TRUE,
         DATA_RATE      => "SDR",
         DATA_WIDTH     => 7,
         INTERFACE_TYPE => "RETIMED",
         SERDES_MODE    => "MASTER")
       port map (
         Q1         => iserdes_q(3)(pin_count),
         Q2         => iserdes_q(2)(pin_count),
         Q3         => iserdes_q(1)(pin_count),
         Q4         => iserdes_q(0)(pin_count),
         SHIFTOUT   => icascade(pin_count),
         INCDEC     => open,
         VALID      => open,
         BITSLIP    => bitslip,
         CE0        => clock_enable,   -- 1-bit Clock enable input
         CLK0       => clk_in_int_buf, -- 1-bit IO Clock network input. Optionally Invertible. This is the primary clock
                                       -- input used when the clock doubler circuit is not engaged (see DATA_RATE
                                       -- attribute).
         CLK1       => '0',
         CLKDIV     => clk_div_in,
         D          => data_in_from_pins_int(pin_count), -- 1-bit Input signal from IOB.
         IOCE       => serdesstrobe,                       -- 1-bit Data strobe signal derived from BUFIO CE. Strobes data capture for
                                                          -- NETWORKING and NETWORKING_PIPELINES alignment modes.

         RST        => IO_RESET,        -- 1-bit Asynchronous reset only.
         SHIFTIN    => '0',


        -- unused connections
         FABRICOUT  => open,
         CFB0       => open,
         CFB1       => open,
         DFB        => open);

     iserdes2_slave : ISERDES2
       generic map (
         BITSLIP_ENABLE => TRUE,
         DATA_RATE      => "SDR",
         DATA_WIDTH     => 7,
         INTERFACE_TYPE => "RETIMED",
         SERDES_MODE    => "SLAVE")
       port map (
        Q1         => iserdes_q(7)(pin_count),
        Q2         => iserdes_q(6)(pin_count),
        Q3         => iserdes_q(5)(pin_count),
        Q4         => iserdes_q(4)(pin_count),
        SHIFTOUT   => open,
        INCDEC     => open,
        VALID      => open,
         BITSLIP    => bitslip,
        CE0        => clock_enable,   -- 1-bit Clock enable input
        CLK0       => clk_in_int_buf, -- 1-bit IO Clock network input. Optionally Invertible. This is the primary clock
                                      -- input used when the clock doubler circuit is not engaged (see DATA_RATE
                                      -- attribute).
        CLK1       => '0',
         CLKDIV     => clk_div_in,
        D          => '0',            -- 1-bit Input signal from IOB.
        IOCE       => serdesstrobe,   -- 1-bit Data strobe signal derived from BUFIO CE. Strobes data capture for
                                      -- NETWORKING and NETWORKING_PIPELINES alignment modes.

        RST        => IO_RESET,       -- 1-bit Asynchronous reset only.
        SHIFTIN    => icascade(pin_count),
        -- unused connections
        FABRICOUT  => open,
        CFB0       => open,
        CFB1       => open,
        DFB        => open);




     -- Concatenate the serdes outputs together. Keep the timesliced
     --   bits together, and placing the earliest bits on the right
     --   ie, if data comes in 0, 1, 2, 3, 4, 5, 6, 7, ...
     --       the output will be 3210, 7654, ...
     -------------------------------------------------------------
     in_slices: for slice_count in 0 to num_serial_bits-1 generate begin
        -- This places the first data in time on the right
        data_in_to_device(slice_count*sys_w+sys_w-1 downto slice_count*sys_w) <=
          iserdes_q(num_serial_bits-slice_count-1);
        -- To place the first data in time on the left, use the
        --   following code, instead
        -- data_in_to_device2(slice_count*sys_w+sys_w-1 downto sys_w) <=
        --   iserdes_q(slice_count);
     end generate in_slices;
  end generate pins;



   -- Instantiate the IO design
   io_inst : M_HSelectIO
   port map
   (
    -- From the drive out to the system
    DATA_OUT_FROM_DEVICE    => data_out_from_device,
    DATA_OUT_TO_PINS_P      => DATA_OUT_TO_PINS_P,
    DATA_OUT_TO_PINS_N      => DATA_OUT_TO_PINS_N,


    CLK_IN                  => clk_in_pll1,
    CLK_DIV_IN              => clk_div_in,
    LOCKED_IN               => locked_in,
    LOCKED_OUT              => locked_out,
    IO_RESET                => rst_sync_int);
end xilinx;
