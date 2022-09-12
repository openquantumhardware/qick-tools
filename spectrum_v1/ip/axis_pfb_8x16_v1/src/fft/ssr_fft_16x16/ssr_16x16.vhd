-- Generated from Simulink block ssr_16x16/Vector FFT/Scalar2Vector
library IEEE;
use IEEE.std_logic_1164.all;
library xil_defaultlib;
use xil_defaultlib.conv_pkg.all;
entity ssr_16x16_scalar2vector is
  port (
    i : in std_logic_vector( 864-1 downto 0 );
    o_1 : out std_logic_vector( 54-1 downto 0 );
    o_2 : out std_logic_vector( 54-1 downto 0 );
    o_3 : out std_logic_vector( 54-1 downto 0 );
    o_4 : out std_logic_vector( 54-1 downto 0 );
    o_5 : out std_logic_vector( 54-1 downto 0 );
    o_6 : out std_logic_vector( 54-1 downto 0 );
    o_7 : out std_logic_vector( 54-1 downto 0 );
    o_8 : out std_logic_vector( 54-1 downto 0 );
    o_9 : out std_logic_vector( 54-1 downto 0 );
    o_10 : out std_logic_vector( 54-1 downto 0 );
    o_11 : out std_logic_vector( 54-1 downto 0 );
    o_12 : out std_logic_vector( 54-1 downto 0 );
    o_13 : out std_logic_vector( 54-1 downto 0 );
    o_14 : out std_logic_vector( 54-1 downto 0 );
    o_15 : out std_logic_vector( 54-1 downto 0 );
    o_16 : out std_logic_vector( 54-1 downto 0 )
  );
end ssr_16x16_scalar2vector;
architecture structural of ssr_16x16_scalar2vector is 
  signal slice0_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice2_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice4_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice5_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice1_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice6_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice7_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice3_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice10_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice15_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice9_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice11_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice8_y_net : std_logic_vector( 54-1 downto 0 );
  signal test_systolicfft_vhdl_black_box_o_net : std_logic_vector( 864-1 downto 0 );
  signal slice13_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice12_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice14_y_net : std_logic_vector( 54-1 downto 0 );
begin
  o_1 <= slice0_y_net;
  o_2 <= slice1_y_net;
  o_3 <= slice2_y_net;
  o_4 <= slice3_y_net;
  o_5 <= slice4_y_net;
  o_6 <= slice5_y_net;
  o_7 <= slice6_y_net;
  o_8 <= slice7_y_net;
  o_9 <= slice8_y_net;
  o_10 <= slice9_y_net;
  o_11 <= slice10_y_net;
  o_12 <= slice11_y_net;
  o_13 <= slice12_y_net;
  o_14 <= slice13_y_net;
  o_15 <= slice14_y_net;
  o_16 <= slice15_y_net;
  test_systolicfft_vhdl_black_box_o_net <= i;
  slice0 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 0,
    new_msb => 53,
    x_width => 864,
    y_width => 54
  )
  port map (
    x => test_systolicfft_vhdl_black_box_o_net,
    y => slice0_y_net
  );
  slice1 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 54,
    new_msb => 107,
    x_width => 864,
    y_width => 54
  )
  port map (
    x => test_systolicfft_vhdl_black_box_o_net,
    y => slice1_y_net
  );
  slice2 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 108,
    new_msb => 161,
    x_width => 864,
    y_width => 54
  )
  port map (
    x => test_systolicfft_vhdl_black_box_o_net,
    y => slice2_y_net
  );
  slice3 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 162,
    new_msb => 215,
    x_width => 864,
    y_width => 54
  )
  port map (
    x => test_systolicfft_vhdl_black_box_o_net,
    y => slice3_y_net
  );
  slice4 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 216,
    new_msb => 269,
    x_width => 864,
    y_width => 54
  )
  port map (
    x => test_systolicfft_vhdl_black_box_o_net,
    y => slice4_y_net
  );
  slice5 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 270,
    new_msb => 323,
    x_width => 864,
    y_width => 54
  )
  port map (
    x => test_systolicfft_vhdl_black_box_o_net,
    y => slice5_y_net
  );
  slice6 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 324,
    new_msb => 377,
    x_width => 864,
    y_width => 54
  )
  port map (
    x => test_systolicfft_vhdl_black_box_o_net,
    y => slice6_y_net
  );
  slice7 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 378,
    new_msb => 431,
    x_width => 864,
    y_width => 54
  )
  port map (
    x => test_systolicfft_vhdl_black_box_o_net,
    y => slice7_y_net
  );
  slice8 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 432,
    new_msb => 485,
    x_width => 864,
    y_width => 54
  )
  port map (
    x => test_systolicfft_vhdl_black_box_o_net,
    y => slice8_y_net
  );
  slice9 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 486,
    new_msb => 539,
    x_width => 864,
    y_width => 54
  )
  port map (
    x => test_systolicfft_vhdl_black_box_o_net,
    y => slice9_y_net
  );
  slice10 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 540,
    new_msb => 593,
    x_width => 864,
    y_width => 54
  )
  port map (
    x => test_systolicfft_vhdl_black_box_o_net,
    y => slice10_y_net
  );
  slice11 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 594,
    new_msb => 647,
    x_width => 864,
    y_width => 54
  )
  port map (
    x => test_systolicfft_vhdl_black_box_o_net,
    y => slice11_y_net
  );
  slice12 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 648,
    new_msb => 701,
    x_width => 864,
    y_width => 54
  )
  port map (
    x => test_systolicfft_vhdl_black_box_o_net,
    y => slice12_y_net
  );
  slice13 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 702,
    new_msb => 755,
    x_width => 864,
    y_width => 54
  )
  port map (
    x => test_systolicfft_vhdl_black_box_o_net,
    y => slice13_y_net
  );
  slice14 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 756,
    new_msb => 809,
    x_width => 864,
    y_width => 54
  )
  port map (
    x => test_systolicfft_vhdl_black_box_o_net,
    y => slice14_y_net
  );
  slice15 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 810,
    new_msb => 863,
    x_width => 864,
    y_width => 54
  )
  port map (
    x => test_systolicfft_vhdl_black_box_o_net,
    y => slice15_y_net
  );
end structural;
-- Generated from Simulink block ssr_16x16/Vector FFT/Vector Concat
library IEEE;
use IEEE.std_logic_1164.all;
library xil_defaultlib;
use xil_defaultlib.conv_pkg.all;
entity ssr_16x16_vector_concat is
  port (
    hi_1 : in std_logic_vector( 16-1 downto 0 );
    lo_1 : in std_logic_vector( 16-1 downto 0 );
    hi_2 : in std_logic_vector( 16-1 downto 0 );
    hi_3 : in std_logic_vector( 16-1 downto 0 );
    hi_4 : in std_logic_vector( 16-1 downto 0 );
    hi_5 : in std_logic_vector( 16-1 downto 0 );
    hi_6 : in std_logic_vector( 16-1 downto 0 );
    hi_7 : in std_logic_vector( 16-1 downto 0 );
    hi_8 : in std_logic_vector( 16-1 downto 0 );
    hi_9 : in std_logic_vector( 16-1 downto 0 );
    hi_10 : in std_logic_vector( 16-1 downto 0 );
    hi_11 : in std_logic_vector( 16-1 downto 0 );
    hi_12 : in std_logic_vector( 16-1 downto 0 );
    hi_13 : in std_logic_vector( 16-1 downto 0 );
    hi_14 : in std_logic_vector( 16-1 downto 0 );
    hi_15 : in std_logic_vector( 16-1 downto 0 );
    hi_16 : in std_logic_vector( 16-1 downto 0 );
    lo_2 : in std_logic_vector( 16-1 downto 0 );
    lo_3 : in std_logic_vector( 16-1 downto 0 );
    lo_4 : in std_logic_vector( 16-1 downto 0 );
    lo_5 : in std_logic_vector( 16-1 downto 0 );
    lo_6 : in std_logic_vector( 16-1 downto 0 );
    lo_7 : in std_logic_vector( 16-1 downto 0 );
    lo_8 : in std_logic_vector( 16-1 downto 0 );
    lo_9 : in std_logic_vector( 16-1 downto 0 );
    lo_10 : in std_logic_vector( 16-1 downto 0 );
    lo_11 : in std_logic_vector( 16-1 downto 0 );
    lo_12 : in std_logic_vector( 16-1 downto 0 );
    lo_13 : in std_logic_vector( 16-1 downto 0 );
    lo_14 : in std_logic_vector( 16-1 downto 0 );
    lo_15 : in std_logic_vector( 16-1 downto 0 );
    lo_16 : in std_logic_vector( 16-1 downto 0 );
    out_1 : out std_logic_vector( 32-1 downto 0 );
    out_2 : out std_logic_vector( 32-1 downto 0 );
    out_3 : out std_logic_vector( 32-1 downto 0 );
    out_4 : out std_logic_vector( 32-1 downto 0 );
    out_5 : out std_logic_vector( 32-1 downto 0 );
    out_6 : out std_logic_vector( 32-1 downto 0 );
    out_7 : out std_logic_vector( 32-1 downto 0 );
    out_8 : out std_logic_vector( 32-1 downto 0 );
    out_9 : out std_logic_vector( 32-1 downto 0 );
    out_10 : out std_logic_vector( 32-1 downto 0 );
    out_11 : out std_logic_vector( 32-1 downto 0 );
    out_12 : out std_logic_vector( 32-1 downto 0 );
    out_13 : out std_logic_vector( 32-1 downto 0 );
    out_14 : out std_logic_vector( 32-1 downto 0 );
    out_15 : out std_logic_vector( 32-1 downto 0 );
    out_16 : out std_logic_vector( 32-1 downto 0 )
  );
end ssr_16x16_vector_concat;
architecture structural of ssr_16x16_vector_concat is 
  signal reinterpret13_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret14_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret15_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal concat5_y_net : std_logic_vector( 32-1 downto 0 );
  signal concat2_y_net : std_logic_vector( 32-1 downto 0 );
  signal concat3_y_net : std_logic_vector( 32-1 downto 0 );
  signal concat0_y_net : std_logic_vector( 32-1 downto 0 );
  signal concat1_y_net : std_logic_vector( 32-1 downto 0 );
  signal concat4_y_net : std_logic_vector( 32-1 downto 0 );
  signal concat15_y_net : std_logic_vector( 32-1 downto 0 );
  signal reinterpret14_output_port_net_x0 : std_logic_vector( 16-1 downto 0 );
  signal reinterpret6_output_port_net_x0 : std_logic_vector( 16-1 downto 0 );
  signal concat6_y_net : std_logic_vector( 32-1 downto 0 );
  signal reinterpret12_output_port_net_x0 : std_logic_vector( 16-1 downto 0 );
  signal reinterpret15_output_port_net_x0 : std_logic_vector( 16-1 downto 0 );
  signal reinterpret1_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret2_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret3_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret3_output_port_net_x0 : std_logic_vector( 16-1 downto 0 );
  signal reinterpret4_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret4_output_port_net_x0 : std_logic_vector( 16-1 downto 0 );
  signal concat9_y_net : std_logic_vector( 32-1 downto 0 );
  signal reinterpret2_output_port_net_x0 : std_logic_vector( 16-1 downto 0 );
  signal concat11_y_net : std_logic_vector( 32-1 downto 0 );
  signal reinterpret0_output_port_net_x0 : std_logic_vector( 16-1 downto 0 );
  signal reinterpret7_output_port_net_x0 : std_logic_vector( 16-1 downto 0 );
  signal reinterpret9_output_port_net_x0 : std_logic_vector( 16-1 downto 0 );
  signal reinterpret11_output_port_net_x0 : std_logic_vector( 16-1 downto 0 );
  signal concat12_y_net : std_logic_vector( 32-1 downto 0 );
  signal concat13_y_net : std_logic_vector( 32-1 downto 0 );
  signal reinterpret0_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret8_output_port_net_x0 : std_logic_vector( 16-1 downto 0 );
  signal concat8_y_net : std_logic_vector( 32-1 downto 0 );
  signal concat10_y_net : std_logic_vector( 32-1 downto 0 );
  signal reinterpret13_output_port_net_x0 : std_logic_vector( 16-1 downto 0 );
  signal reinterpret1_output_port_net_x0 : std_logic_vector( 16-1 downto 0 );
  signal concat14_y_net : std_logic_vector( 32-1 downto 0 );
  signal reinterpret5_output_port_net_x0 : std_logic_vector( 16-1 downto 0 );
  signal concat7_y_net : std_logic_vector( 32-1 downto 0 );
  signal reinterpret10_output_port_net_x0 : std_logic_vector( 16-1 downto 0 );
  signal reinterpret6_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret5_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret7_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret8_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret9_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret10_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret11_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret12_output_port_net : std_logic_vector( 16-1 downto 0 );
begin
  out_1 <= concat0_y_net;
  out_2 <= concat1_y_net;
  out_3 <= concat2_y_net;
  out_4 <= concat3_y_net;
  out_5 <= concat4_y_net;
  out_6 <= concat5_y_net;
  out_7 <= concat6_y_net;
  out_8 <= concat7_y_net;
  out_9 <= concat8_y_net;
  out_10 <= concat9_y_net;
  out_11 <= concat10_y_net;
  out_12 <= concat11_y_net;
  out_13 <= concat12_y_net;
  out_14 <= concat13_y_net;
  out_15 <= concat14_y_net;
  out_16 <= concat15_y_net;
  reinterpret0_output_port_net_x0 <= hi_1;
  reinterpret0_output_port_net <= lo_1;
  reinterpret1_output_port_net_x0 <= hi_2;
  reinterpret2_output_port_net_x0 <= hi_3;
  reinterpret3_output_port_net_x0 <= hi_4;
  reinterpret4_output_port_net_x0 <= hi_5;
  reinterpret5_output_port_net_x0 <= hi_6;
  reinterpret6_output_port_net_x0 <= hi_7;
  reinterpret7_output_port_net_x0 <= hi_8;
  reinterpret8_output_port_net_x0 <= hi_9;
  reinterpret9_output_port_net_x0 <= hi_10;
  reinterpret10_output_port_net_x0 <= hi_11;
  reinterpret11_output_port_net_x0 <= hi_12;
  reinterpret12_output_port_net_x0 <= hi_13;
  reinterpret13_output_port_net_x0 <= hi_14;
  reinterpret14_output_port_net_x0 <= hi_15;
  reinterpret15_output_port_net_x0 <= hi_16;
  reinterpret1_output_port_net <= lo_2;
  reinterpret2_output_port_net <= lo_3;
  reinterpret3_output_port_net <= lo_4;
  reinterpret4_output_port_net <= lo_5;
  reinterpret5_output_port_net <= lo_6;
  reinterpret6_output_port_net <= lo_7;
  reinterpret7_output_port_net <= lo_8;
  reinterpret8_output_port_net <= lo_9;
  reinterpret9_output_port_net <= lo_10;
  reinterpret10_output_port_net <= lo_11;
  reinterpret11_output_port_net <= lo_12;
  reinterpret12_output_port_net <= lo_13;
  reinterpret13_output_port_net <= lo_14;
  reinterpret14_output_port_net <= lo_15;
  reinterpret15_output_port_net <= lo_16;
  concat0 : entity xil_defaultlib.sysgen_concat_1df6aec277 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    in0 => reinterpret0_output_port_net_x0,
    in1 => reinterpret0_output_port_net,
    y => concat0_y_net
  );
  concat1 : entity xil_defaultlib.sysgen_concat_1df6aec277 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    in0 => reinterpret1_output_port_net_x0,
    in1 => reinterpret1_output_port_net,
    y => concat1_y_net
  );
  concat2 : entity xil_defaultlib.sysgen_concat_1df6aec277 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    in0 => reinterpret2_output_port_net_x0,
    in1 => reinterpret2_output_port_net,
    y => concat2_y_net
  );
  concat3 : entity xil_defaultlib.sysgen_concat_1df6aec277 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    in0 => reinterpret3_output_port_net_x0,
    in1 => reinterpret3_output_port_net,
    y => concat3_y_net
  );
  concat4 : entity xil_defaultlib.sysgen_concat_1df6aec277 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    in0 => reinterpret4_output_port_net_x0,
    in1 => reinterpret4_output_port_net,
    y => concat4_y_net
  );
  concat5 : entity xil_defaultlib.sysgen_concat_1df6aec277 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    in0 => reinterpret5_output_port_net_x0,
    in1 => reinterpret5_output_port_net,
    y => concat5_y_net
  );
  concat6 : entity xil_defaultlib.sysgen_concat_1df6aec277 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    in0 => reinterpret6_output_port_net_x0,
    in1 => reinterpret6_output_port_net,
    y => concat6_y_net
  );
  concat7 : entity xil_defaultlib.sysgen_concat_1df6aec277 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    in0 => reinterpret7_output_port_net_x0,
    in1 => reinterpret7_output_port_net,
    y => concat7_y_net
  );
  concat8 : entity xil_defaultlib.sysgen_concat_1df6aec277 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    in0 => reinterpret8_output_port_net_x0,
    in1 => reinterpret8_output_port_net,
    y => concat8_y_net
  );
  concat9 : entity xil_defaultlib.sysgen_concat_1df6aec277 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    in0 => reinterpret9_output_port_net_x0,
    in1 => reinterpret9_output_port_net,
    y => concat9_y_net
  );
  concat10 : entity xil_defaultlib.sysgen_concat_1df6aec277 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    in0 => reinterpret10_output_port_net_x0,
    in1 => reinterpret10_output_port_net,
    y => concat10_y_net
  );
  concat11 : entity xil_defaultlib.sysgen_concat_1df6aec277 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    in0 => reinterpret11_output_port_net_x0,
    in1 => reinterpret11_output_port_net,
    y => concat11_y_net
  );
  concat12 : entity xil_defaultlib.sysgen_concat_1df6aec277 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    in0 => reinterpret12_output_port_net_x0,
    in1 => reinterpret12_output_port_net,
    y => concat12_y_net
  );
  concat13 : entity xil_defaultlib.sysgen_concat_1df6aec277 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    in0 => reinterpret13_output_port_net_x0,
    in1 => reinterpret13_output_port_net,
    y => concat13_y_net
  );
  concat14 : entity xil_defaultlib.sysgen_concat_1df6aec277 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    in0 => reinterpret14_output_port_net_x0,
    in1 => reinterpret14_output_port_net,
    y => concat14_y_net
  );
  concat15 : entity xil_defaultlib.sysgen_concat_1df6aec277 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    in0 => reinterpret15_output_port_net_x0,
    in1 => reinterpret15_output_port_net,
    y => concat15_y_net
  );
end structural;
-- Generated from Simulink block ssr_16x16/Vector FFT/Vector Delay
library IEEE;
use IEEE.std_logic_1164.all;
library xil_defaultlib;
use xil_defaultlib.conv_pkg.all;
entity ssr_16x16_vector_delay is
  port (
    d_1 : in std_logic_vector( 32-1 downto 0 );
    d_2 : in std_logic_vector( 32-1 downto 0 );
    d_3 : in std_logic_vector( 32-1 downto 0 );
    d_4 : in std_logic_vector( 32-1 downto 0 );
    d_5 : in std_logic_vector( 32-1 downto 0 );
    d_6 : in std_logic_vector( 32-1 downto 0 );
    d_7 : in std_logic_vector( 32-1 downto 0 );
    d_8 : in std_logic_vector( 32-1 downto 0 );
    d_9 : in std_logic_vector( 32-1 downto 0 );
    d_10 : in std_logic_vector( 32-1 downto 0 );
    d_11 : in std_logic_vector( 32-1 downto 0 );
    d_12 : in std_logic_vector( 32-1 downto 0 );
    d_13 : in std_logic_vector( 32-1 downto 0 );
    d_14 : in std_logic_vector( 32-1 downto 0 );
    d_15 : in std_logic_vector( 32-1 downto 0 );
    d_16 : in std_logic_vector( 32-1 downto 0 );
    clk_1 : in std_logic;
    ce_1 : in std_logic;
    q_1 : out std_logic_vector( 32-1 downto 0 );
    q_2 : out std_logic_vector( 32-1 downto 0 );
    q_3 : out std_logic_vector( 32-1 downto 0 );
    q_4 : out std_logic_vector( 32-1 downto 0 );
    q_5 : out std_logic_vector( 32-1 downto 0 );
    q_6 : out std_logic_vector( 32-1 downto 0 );
    q_7 : out std_logic_vector( 32-1 downto 0 );
    q_8 : out std_logic_vector( 32-1 downto 0 );
    q_9 : out std_logic_vector( 32-1 downto 0 );
    q_10 : out std_logic_vector( 32-1 downto 0 );
    q_11 : out std_logic_vector( 32-1 downto 0 );
    q_12 : out std_logic_vector( 32-1 downto 0 );
    q_13 : out std_logic_vector( 32-1 downto 0 );
    q_14 : out std_logic_vector( 32-1 downto 0 );
    q_15 : out std_logic_vector( 32-1 downto 0 );
    q_16 : out std_logic_vector( 32-1 downto 0 )
  );
end ssr_16x16_vector_delay;
architecture structural of ssr_16x16_vector_delay is 
  signal delay0_q_net : std_logic_vector( 32-1 downto 0 );
  signal delay7_q_net : std_logic_vector( 32-1 downto 0 );
  signal delay3_q_net : std_logic_vector( 32-1 downto 0 );
  signal delay4_q_net : std_logic_vector( 32-1 downto 0 );
  signal delay5_q_net : std_logic_vector( 32-1 downto 0 );
  signal delay1_q_net : std_logic_vector( 32-1 downto 0 );
  signal delay8_q_net : std_logic_vector( 32-1 downto 0 );
  signal delay10_q_net : std_logic_vector( 32-1 downto 0 );
  signal delay9_q_net : std_logic_vector( 32-1 downto 0 );
  signal delay2_q_net : std_logic_vector( 32-1 downto 0 );
  signal delay6_q_net : std_logic_vector( 32-1 downto 0 );
  signal delay11_q_net : std_logic_vector( 32-1 downto 0 );
  signal concat13_y_net : std_logic_vector( 32-1 downto 0 );
  signal ce_net : std_logic;
  signal delay15_q_net : std_logic_vector( 32-1 downto 0 );
  signal concat6_y_net : std_logic_vector( 32-1 downto 0 );
  signal concat12_y_net : std_logic_vector( 32-1 downto 0 );
  signal concat0_y_net : std_logic_vector( 32-1 downto 0 );
  signal concat7_y_net : std_logic_vector( 32-1 downto 0 );
  signal concat15_y_net : std_logic_vector( 32-1 downto 0 );
  signal clk_net : std_logic;
  signal concat5_y_net : std_logic_vector( 32-1 downto 0 );
  signal concat14_y_net : std_logic_vector( 32-1 downto 0 );
  signal concat4_y_net : std_logic_vector( 32-1 downto 0 );
  signal concat9_y_net : std_logic_vector( 32-1 downto 0 );
  signal concat3_y_net : std_logic_vector( 32-1 downto 0 );
  signal concat2_y_net : std_logic_vector( 32-1 downto 0 );
  signal delay12_q_net : std_logic_vector( 32-1 downto 0 );
  signal concat10_y_net : std_logic_vector( 32-1 downto 0 );
  signal delay14_q_net : std_logic_vector( 32-1 downto 0 );
  signal concat1_y_net : std_logic_vector( 32-1 downto 0 );
  signal concat8_y_net : std_logic_vector( 32-1 downto 0 );
  signal concat11_y_net : std_logic_vector( 32-1 downto 0 );
  signal delay13_q_net : std_logic_vector( 32-1 downto 0 );
begin
  q_1 <= delay0_q_net;
  q_2 <= delay1_q_net;
  q_3 <= delay2_q_net;
  q_4 <= delay3_q_net;
  q_5 <= delay4_q_net;
  q_6 <= delay5_q_net;
  q_7 <= delay6_q_net;
  q_8 <= delay7_q_net;
  q_9 <= delay8_q_net;
  q_10 <= delay9_q_net;
  q_11 <= delay10_q_net;
  q_12 <= delay11_q_net;
  q_13 <= delay12_q_net;
  q_14 <= delay13_q_net;
  q_15 <= delay14_q_net;
  q_16 <= delay15_q_net;
  concat0_y_net <= d_1;
  concat1_y_net <= d_2;
  concat2_y_net <= d_3;
  concat3_y_net <= d_4;
  concat4_y_net <= d_5;
  concat5_y_net <= d_6;
  concat6_y_net <= d_7;
  concat7_y_net <= d_8;
  concat8_y_net <= d_9;
  concat9_y_net <= d_10;
  concat10_y_net <= d_11;
  concat11_y_net <= d_12;
  concat12_y_net <= d_13;
  concat13_y_net <= d_14;
  concat14_y_net <= d_15;
  concat15_y_net <= d_16;
  clk_net <= clk_1;
  ce_net <= ce_1;
  delay0 : entity xil_defaultlib.ssr_16x16_xldelay 
  generic map (
    latency => 4,
    reg_retiming => 0,
    reset => 0,
    width => 32
  )
  port map (
    en => '1',
    rst => '0',
    d => concat0_y_net,
    clk => clk_net,
    ce => ce_net,
    q => delay0_q_net
  );
  delay1 : entity xil_defaultlib.ssr_16x16_xldelay 
  generic map (
    latency => 4,
    reg_retiming => 0,
    reset => 0,
    width => 32
  )
  port map (
    en => '1',
    rst => '0',
    d => concat1_y_net,
    clk => clk_net,
    ce => ce_net,
    q => delay1_q_net
  );
  delay2 : entity xil_defaultlib.ssr_16x16_xldelay 
  generic map (
    latency => 4,
    reg_retiming => 0,
    reset => 0,
    width => 32
  )
  port map (
    en => '1',
    rst => '0',
    d => concat2_y_net,
    clk => clk_net,
    ce => ce_net,
    q => delay2_q_net
  );
  delay3 : entity xil_defaultlib.ssr_16x16_xldelay 
  generic map (
    latency => 4,
    reg_retiming => 0,
    reset => 0,
    width => 32
  )
  port map (
    en => '1',
    rst => '0',
    d => concat3_y_net,
    clk => clk_net,
    ce => ce_net,
    q => delay3_q_net
  );
  delay4 : entity xil_defaultlib.ssr_16x16_xldelay 
  generic map (
    latency => 4,
    reg_retiming => 0,
    reset => 0,
    width => 32
  )
  port map (
    en => '1',
    rst => '0',
    d => concat4_y_net,
    clk => clk_net,
    ce => ce_net,
    q => delay4_q_net
  );
  delay5 : entity xil_defaultlib.ssr_16x16_xldelay 
  generic map (
    latency => 4,
    reg_retiming => 0,
    reset => 0,
    width => 32
  )
  port map (
    en => '1',
    rst => '0',
    d => concat5_y_net,
    clk => clk_net,
    ce => ce_net,
    q => delay5_q_net
  );
  delay6 : entity xil_defaultlib.ssr_16x16_xldelay 
  generic map (
    latency => 4,
    reg_retiming => 0,
    reset => 0,
    width => 32
  )
  port map (
    en => '1',
    rst => '0',
    d => concat6_y_net,
    clk => clk_net,
    ce => ce_net,
    q => delay6_q_net
  );
  delay7 : entity xil_defaultlib.ssr_16x16_xldelay 
  generic map (
    latency => 4,
    reg_retiming => 0,
    reset => 0,
    width => 32
  )
  port map (
    en => '1',
    rst => '0',
    d => concat7_y_net,
    clk => clk_net,
    ce => ce_net,
    q => delay7_q_net
  );
  delay8 : entity xil_defaultlib.ssr_16x16_xldelay 
  generic map (
    latency => 4,
    reg_retiming => 0,
    reset => 0,
    width => 32
  )
  port map (
    en => '1',
    rst => '0',
    d => concat8_y_net,
    clk => clk_net,
    ce => ce_net,
    q => delay8_q_net
  );
  delay9 : entity xil_defaultlib.ssr_16x16_xldelay 
  generic map (
    latency => 4,
    reg_retiming => 0,
    reset => 0,
    width => 32
  )
  port map (
    en => '1',
    rst => '0',
    d => concat9_y_net,
    clk => clk_net,
    ce => ce_net,
    q => delay9_q_net
  );
  delay10 : entity xil_defaultlib.ssr_16x16_xldelay 
  generic map (
    latency => 4,
    reg_retiming => 0,
    reset => 0,
    width => 32
  )
  port map (
    en => '1',
    rst => '0',
    d => concat10_y_net,
    clk => clk_net,
    ce => ce_net,
    q => delay10_q_net
  );
  delay11 : entity xil_defaultlib.ssr_16x16_xldelay 
  generic map (
    latency => 4,
    reg_retiming => 0,
    reset => 0,
    width => 32
  )
  port map (
    en => '1',
    rst => '0',
    d => concat11_y_net,
    clk => clk_net,
    ce => ce_net,
    q => delay11_q_net
  );
  delay12 : entity xil_defaultlib.ssr_16x16_xldelay 
  generic map (
    latency => 4,
    reg_retiming => 0,
    reset => 0,
    width => 32
  )
  port map (
    en => '1',
    rst => '0',
    d => concat12_y_net,
    clk => clk_net,
    ce => ce_net,
    q => delay12_q_net
  );
  delay13 : entity xil_defaultlib.ssr_16x16_xldelay 
  generic map (
    latency => 4,
    reg_retiming => 0,
    reset => 0,
    width => 32
  )
  port map (
    en => '1',
    rst => '0',
    d => concat13_y_net,
    clk => clk_net,
    ce => ce_net,
    q => delay13_q_net
  );
  delay14 : entity xil_defaultlib.ssr_16x16_xldelay 
  generic map (
    latency => 4,
    reg_retiming => 0,
    reset => 0,
    width => 32
  )
  port map (
    en => '1',
    rst => '0',
    d => concat14_y_net,
    clk => clk_net,
    ce => ce_net,
    q => delay14_q_net
  );
  delay15 : entity xil_defaultlib.ssr_16x16_xldelay 
  generic map (
    latency => 4,
    reg_retiming => 0,
    reset => 0,
    width => 32
  )
  port map (
    en => '1',
    rst => '0',
    d => concat15_y_net,
    clk => clk_net,
    ce => ce_net,
    q => delay15_q_net
  );
end structural;
-- Generated from Simulink block ssr_16x16/Vector FFT/Vector Reinterpret
library IEEE;
use IEEE.std_logic_1164.all;
library xil_defaultlib;
use xil_defaultlib.conv_pkg.all;
entity ssr_16x16_vector_reinterpret is
  port (
    in_1 : in std_logic_vector( 16-1 downto 0 );
    in_2 : in std_logic_vector( 16-1 downto 0 );
    in_3 : in std_logic_vector( 16-1 downto 0 );
    in_4 : in std_logic_vector( 16-1 downto 0 );
    in_5 : in std_logic_vector( 16-1 downto 0 );
    in_6 : in std_logic_vector( 16-1 downto 0 );
    in_7 : in std_logic_vector( 16-1 downto 0 );
    in_8 : in std_logic_vector( 16-1 downto 0 );
    in_9 : in std_logic_vector( 16-1 downto 0 );
    in_10 : in std_logic_vector( 16-1 downto 0 );
    in_11 : in std_logic_vector( 16-1 downto 0 );
    in_12 : in std_logic_vector( 16-1 downto 0 );
    in_13 : in std_logic_vector( 16-1 downto 0 );
    in_14 : in std_logic_vector( 16-1 downto 0 );
    in_15 : in std_logic_vector( 16-1 downto 0 );
    in_16 : in std_logic_vector( 16-1 downto 0 );
    out_1 : out std_logic_vector( 16-1 downto 0 );
    out_2 : out std_logic_vector( 16-1 downto 0 );
    out_3 : out std_logic_vector( 16-1 downto 0 );
    out_4 : out std_logic_vector( 16-1 downto 0 );
    out_5 : out std_logic_vector( 16-1 downto 0 );
    out_6 : out std_logic_vector( 16-1 downto 0 );
    out_7 : out std_logic_vector( 16-1 downto 0 );
    out_8 : out std_logic_vector( 16-1 downto 0 );
    out_9 : out std_logic_vector( 16-1 downto 0 );
    out_10 : out std_logic_vector( 16-1 downto 0 );
    out_11 : out std_logic_vector( 16-1 downto 0 );
    out_12 : out std_logic_vector( 16-1 downto 0 );
    out_13 : out std_logic_vector( 16-1 downto 0 );
    out_14 : out std_logic_vector( 16-1 downto 0 );
    out_15 : out std_logic_vector( 16-1 downto 0 );
    out_16 : out std_logic_vector( 16-1 downto 0 )
  );
end ssr_16x16_vector_reinterpret;
architecture structural of ssr_16x16_vector_reinterpret is 
  signal reinterpret12_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret13_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret8_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret3_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret6_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret14_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_2_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret2_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_0_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_5_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_8_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret9_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_6_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret5_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_3_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_4_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_7_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret7_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret15_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret4_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret0_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret11_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_1_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret10_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret1_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_12_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_14_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_13_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_9_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_10_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_11_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_15_net : std_logic_vector( 16-1 downto 0 );
begin
  out_1 <= reinterpret0_output_port_net;
  out_2 <= reinterpret1_output_port_net;
  out_3 <= reinterpret2_output_port_net;
  out_4 <= reinterpret3_output_port_net;
  out_5 <= reinterpret4_output_port_net;
  out_6 <= reinterpret5_output_port_net;
  out_7 <= reinterpret6_output_port_net;
  out_8 <= reinterpret7_output_port_net;
  out_9 <= reinterpret8_output_port_net;
  out_10 <= reinterpret9_output_port_net;
  out_11 <= reinterpret10_output_port_net;
  out_12 <= reinterpret11_output_port_net;
  out_13 <= reinterpret12_output_port_net;
  out_14 <= reinterpret13_output_port_net;
  out_15 <= reinterpret14_output_port_net;
  out_16 <= reinterpret15_output_port_net;
  i_re_0_net <= in_1;
  i_re_1_net <= in_2;
  i_re_2_net <= in_3;
  i_re_3_net <= in_4;
  i_re_4_net <= in_5;
  i_re_5_net <= in_6;
  i_re_6_net <= in_7;
  i_re_7_net <= in_8;
  i_re_8_net <= in_9;
  i_re_9_net <= in_10;
  i_re_10_net <= in_11;
  i_re_11_net <= in_12;
  i_re_12_net <= in_13;
  i_re_13_net <= in_14;
  i_re_14_net <= in_15;
  i_re_15_net <= in_16;
  reinterpret0 : entity xil_defaultlib.sysgen_reinterpret_44fb06feb5 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => i_re_0_net,
    output_port => reinterpret0_output_port_net
  );
  reinterpret1 : entity xil_defaultlib.sysgen_reinterpret_44fb06feb5 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => i_re_1_net,
    output_port => reinterpret1_output_port_net
  );
  reinterpret2 : entity xil_defaultlib.sysgen_reinterpret_44fb06feb5 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => i_re_2_net,
    output_port => reinterpret2_output_port_net
  );
  reinterpret3 : entity xil_defaultlib.sysgen_reinterpret_44fb06feb5 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => i_re_3_net,
    output_port => reinterpret3_output_port_net
  );
  reinterpret4 : entity xil_defaultlib.sysgen_reinterpret_44fb06feb5 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => i_re_4_net,
    output_port => reinterpret4_output_port_net
  );
  reinterpret5 : entity xil_defaultlib.sysgen_reinterpret_44fb06feb5 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => i_re_5_net,
    output_port => reinterpret5_output_port_net
  );
  reinterpret6 : entity xil_defaultlib.sysgen_reinterpret_44fb06feb5 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => i_re_6_net,
    output_port => reinterpret6_output_port_net
  );
  reinterpret7 : entity xil_defaultlib.sysgen_reinterpret_44fb06feb5 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => i_re_7_net,
    output_port => reinterpret7_output_port_net
  );
  reinterpret8 : entity xil_defaultlib.sysgen_reinterpret_44fb06feb5 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => i_re_8_net,
    output_port => reinterpret8_output_port_net
  );
  reinterpret9 : entity xil_defaultlib.sysgen_reinterpret_44fb06feb5 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => i_re_9_net,
    output_port => reinterpret9_output_port_net
  );
  reinterpret10 : entity xil_defaultlib.sysgen_reinterpret_44fb06feb5 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => i_re_10_net,
    output_port => reinterpret10_output_port_net
  );
  reinterpret11 : entity xil_defaultlib.sysgen_reinterpret_44fb06feb5 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => i_re_11_net,
    output_port => reinterpret11_output_port_net
  );
  reinterpret12 : entity xil_defaultlib.sysgen_reinterpret_44fb06feb5 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => i_re_12_net,
    output_port => reinterpret12_output_port_net
  );
  reinterpret13 : entity xil_defaultlib.sysgen_reinterpret_44fb06feb5 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => i_re_13_net,
    output_port => reinterpret13_output_port_net
  );
  reinterpret14 : entity xil_defaultlib.sysgen_reinterpret_44fb06feb5 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => i_re_14_net,
    output_port => reinterpret14_output_port_net
  );
  reinterpret15 : entity xil_defaultlib.sysgen_reinterpret_44fb06feb5 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => i_re_15_net,
    output_port => reinterpret15_output_port_net
  );
end structural;
-- Generated from Simulink block ssr_16x16/Vector FFT/Vector Reinterpret1
library IEEE;
use IEEE.std_logic_1164.all;
library xil_defaultlib;
use xil_defaultlib.conv_pkg.all;
entity ssr_16x16_vector_reinterpret1 is
  port (
    in_1 : in std_logic_vector( 16-1 downto 0 );
    in_2 : in std_logic_vector( 16-1 downto 0 );
    in_3 : in std_logic_vector( 16-1 downto 0 );
    in_4 : in std_logic_vector( 16-1 downto 0 );
    in_5 : in std_logic_vector( 16-1 downto 0 );
    in_6 : in std_logic_vector( 16-1 downto 0 );
    in_7 : in std_logic_vector( 16-1 downto 0 );
    in_8 : in std_logic_vector( 16-1 downto 0 );
    in_9 : in std_logic_vector( 16-1 downto 0 );
    in_10 : in std_logic_vector( 16-1 downto 0 );
    in_11 : in std_logic_vector( 16-1 downto 0 );
    in_12 : in std_logic_vector( 16-1 downto 0 );
    in_13 : in std_logic_vector( 16-1 downto 0 );
    in_14 : in std_logic_vector( 16-1 downto 0 );
    in_15 : in std_logic_vector( 16-1 downto 0 );
    in_16 : in std_logic_vector( 16-1 downto 0 );
    out_1 : out std_logic_vector( 16-1 downto 0 );
    out_2 : out std_logic_vector( 16-1 downto 0 );
    out_3 : out std_logic_vector( 16-1 downto 0 );
    out_4 : out std_logic_vector( 16-1 downto 0 );
    out_5 : out std_logic_vector( 16-1 downto 0 );
    out_6 : out std_logic_vector( 16-1 downto 0 );
    out_7 : out std_logic_vector( 16-1 downto 0 );
    out_8 : out std_logic_vector( 16-1 downto 0 );
    out_9 : out std_logic_vector( 16-1 downto 0 );
    out_10 : out std_logic_vector( 16-1 downto 0 );
    out_11 : out std_logic_vector( 16-1 downto 0 );
    out_12 : out std_logic_vector( 16-1 downto 0 );
    out_13 : out std_logic_vector( 16-1 downto 0 );
    out_14 : out std_logic_vector( 16-1 downto 0 );
    out_15 : out std_logic_vector( 16-1 downto 0 );
    out_16 : out std_logic_vector( 16-1 downto 0 )
  );
end ssr_16x16_vector_reinterpret1;
architecture structural of ssr_16x16_vector_reinterpret1 is 
  signal reinterpret6_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret7_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret10_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret12_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret13_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret15_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret8_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_0_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret11_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret9_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret4_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret2_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret14_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret3_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret1_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret5_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret0_output_port_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_10_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_4_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_14_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_8_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_9_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_12_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_5_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_15_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_6_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_1_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_11_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_7_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_3_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_13_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_2_net : std_logic_vector( 16-1 downto 0 );
begin
  out_1 <= reinterpret0_output_port_net;
  out_2 <= reinterpret1_output_port_net;
  out_3 <= reinterpret2_output_port_net;
  out_4 <= reinterpret3_output_port_net;
  out_5 <= reinterpret4_output_port_net;
  out_6 <= reinterpret5_output_port_net;
  out_7 <= reinterpret6_output_port_net;
  out_8 <= reinterpret7_output_port_net;
  out_9 <= reinterpret8_output_port_net;
  out_10 <= reinterpret9_output_port_net;
  out_11 <= reinterpret10_output_port_net;
  out_12 <= reinterpret11_output_port_net;
  out_13 <= reinterpret12_output_port_net;
  out_14 <= reinterpret13_output_port_net;
  out_15 <= reinterpret14_output_port_net;
  out_16 <= reinterpret15_output_port_net;
  i_im_0_net <= in_1;
  i_im_1_net <= in_2;
  i_im_2_net <= in_3;
  i_im_3_net <= in_4;
  i_im_4_net <= in_5;
  i_im_5_net <= in_6;
  i_im_6_net <= in_7;
  i_im_7_net <= in_8;
  i_im_8_net <= in_9;
  i_im_9_net <= in_10;
  i_im_10_net <= in_11;
  i_im_11_net <= in_12;
  i_im_12_net <= in_13;
  i_im_13_net <= in_14;
  i_im_14_net <= in_15;
  i_im_15_net <= in_16;
  reinterpret0 : entity xil_defaultlib.sysgen_reinterpret_44fb06feb5 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => i_im_0_net,
    output_port => reinterpret0_output_port_net
  );
  reinterpret1 : entity xil_defaultlib.sysgen_reinterpret_44fb06feb5 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => i_im_1_net,
    output_port => reinterpret1_output_port_net
  );
  reinterpret2 : entity xil_defaultlib.sysgen_reinterpret_44fb06feb5 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => i_im_2_net,
    output_port => reinterpret2_output_port_net
  );
  reinterpret3 : entity xil_defaultlib.sysgen_reinterpret_44fb06feb5 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => i_im_3_net,
    output_port => reinterpret3_output_port_net
  );
  reinterpret4 : entity xil_defaultlib.sysgen_reinterpret_44fb06feb5 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => i_im_4_net,
    output_port => reinterpret4_output_port_net
  );
  reinterpret5 : entity xil_defaultlib.sysgen_reinterpret_44fb06feb5 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => i_im_5_net,
    output_port => reinterpret5_output_port_net
  );
  reinterpret6 : entity xil_defaultlib.sysgen_reinterpret_44fb06feb5 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => i_im_6_net,
    output_port => reinterpret6_output_port_net
  );
  reinterpret7 : entity xil_defaultlib.sysgen_reinterpret_44fb06feb5 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => i_im_7_net,
    output_port => reinterpret7_output_port_net
  );
  reinterpret8 : entity xil_defaultlib.sysgen_reinterpret_44fb06feb5 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => i_im_8_net,
    output_port => reinterpret8_output_port_net
  );
  reinterpret9 : entity xil_defaultlib.sysgen_reinterpret_44fb06feb5 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => i_im_9_net,
    output_port => reinterpret9_output_port_net
  );
  reinterpret10 : entity xil_defaultlib.sysgen_reinterpret_44fb06feb5 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => i_im_10_net,
    output_port => reinterpret10_output_port_net
  );
  reinterpret11 : entity xil_defaultlib.sysgen_reinterpret_44fb06feb5 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => i_im_11_net,
    output_port => reinterpret11_output_port_net
  );
  reinterpret12 : entity xil_defaultlib.sysgen_reinterpret_44fb06feb5 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => i_im_12_net,
    output_port => reinterpret12_output_port_net
  );
  reinterpret13 : entity xil_defaultlib.sysgen_reinterpret_44fb06feb5 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => i_im_13_net,
    output_port => reinterpret13_output_port_net
  );
  reinterpret14 : entity xil_defaultlib.sysgen_reinterpret_44fb06feb5 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => i_im_14_net,
    output_port => reinterpret14_output_port_net
  );
  reinterpret15 : entity xil_defaultlib.sysgen_reinterpret_44fb06feb5 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => i_im_15_net,
    output_port => reinterpret15_output_port_net
  );
end structural;
-- Generated from Simulink block ssr_16x16/Vector FFT/Vector Reinterpret2
library IEEE;
use IEEE.std_logic_1164.all;
library xil_defaultlib;
use xil_defaultlib.conv_pkg.all;
entity ssr_16x16_vector_reinterpret2 is
  port (
    in_1 : in std_logic_vector( 27-1 downto 0 );
    in_2 : in std_logic_vector( 27-1 downto 0 );
    in_3 : in std_logic_vector( 27-1 downto 0 );
    in_4 : in std_logic_vector( 27-1 downto 0 );
    in_5 : in std_logic_vector( 27-1 downto 0 );
    in_6 : in std_logic_vector( 27-1 downto 0 );
    in_7 : in std_logic_vector( 27-1 downto 0 );
    in_8 : in std_logic_vector( 27-1 downto 0 );
    in_9 : in std_logic_vector( 27-1 downto 0 );
    in_10 : in std_logic_vector( 27-1 downto 0 );
    in_11 : in std_logic_vector( 27-1 downto 0 );
    in_12 : in std_logic_vector( 27-1 downto 0 );
    in_13 : in std_logic_vector( 27-1 downto 0 );
    in_14 : in std_logic_vector( 27-1 downto 0 );
    in_15 : in std_logic_vector( 27-1 downto 0 );
    in_16 : in std_logic_vector( 27-1 downto 0 );
    out_1 : out std_logic_vector( 27-1 downto 0 );
    out_2 : out std_logic_vector( 27-1 downto 0 );
    out_3 : out std_logic_vector( 27-1 downto 0 );
    out_4 : out std_logic_vector( 27-1 downto 0 );
    out_5 : out std_logic_vector( 27-1 downto 0 );
    out_6 : out std_logic_vector( 27-1 downto 0 );
    out_7 : out std_logic_vector( 27-1 downto 0 );
    out_8 : out std_logic_vector( 27-1 downto 0 );
    out_9 : out std_logic_vector( 27-1 downto 0 );
    out_10 : out std_logic_vector( 27-1 downto 0 );
    out_11 : out std_logic_vector( 27-1 downto 0 );
    out_12 : out std_logic_vector( 27-1 downto 0 );
    out_13 : out std_logic_vector( 27-1 downto 0 );
    out_14 : out std_logic_vector( 27-1 downto 0 );
    out_15 : out std_logic_vector( 27-1 downto 0 );
    out_16 : out std_logic_vector( 27-1 downto 0 )
  );
end ssr_16x16_vector_reinterpret2;
architecture structural of ssr_16x16_vector_reinterpret2 is 
  signal reinterpret3_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret4_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret2_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret0_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret1_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret5_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret6_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret7_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret10_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal slice7_y_net : std_logic_vector( 27-1 downto 0 );
  signal slice4_y_net : std_logic_vector( 27-1 downto 0 );
  signal slice12_y_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret13_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal slice10_y_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret12_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal slice8_y_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret11_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal slice2_y_net : std_logic_vector( 27-1 downto 0 );
  signal slice9_y_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret14_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal slice0_y_net : std_logic_vector( 27-1 downto 0 );
  signal slice11_y_net : std_logic_vector( 27-1 downto 0 );
  signal slice13_y_net : std_logic_vector( 27-1 downto 0 );
  signal slice1_y_net : std_logic_vector( 27-1 downto 0 );
  signal slice15_y_net : std_logic_vector( 27-1 downto 0 );
  signal slice3_y_net : std_logic_vector( 27-1 downto 0 );
  signal slice5_y_net : std_logic_vector( 27-1 downto 0 );
  signal slice6_y_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret9_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal slice14_y_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret8_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret15_output_port_net : std_logic_vector( 27-1 downto 0 );
begin
  out_1 <= reinterpret0_output_port_net;
  out_2 <= reinterpret1_output_port_net;
  out_3 <= reinterpret2_output_port_net;
  out_4 <= reinterpret3_output_port_net;
  out_5 <= reinterpret4_output_port_net;
  out_6 <= reinterpret5_output_port_net;
  out_7 <= reinterpret6_output_port_net;
  out_8 <= reinterpret7_output_port_net;
  out_9 <= reinterpret8_output_port_net;
  out_10 <= reinterpret9_output_port_net;
  out_11 <= reinterpret10_output_port_net;
  out_12 <= reinterpret11_output_port_net;
  out_13 <= reinterpret12_output_port_net;
  out_14 <= reinterpret13_output_port_net;
  out_15 <= reinterpret14_output_port_net;
  out_16 <= reinterpret15_output_port_net;
  slice0_y_net <= in_1;
  slice1_y_net <= in_2;
  slice2_y_net <= in_3;
  slice3_y_net <= in_4;
  slice4_y_net <= in_5;
  slice5_y_net <= in_6;
  slice6_y_net <= in_7;
  slice7_y_net <= in_8;
  slice8_y_net <= in_9;
  slice9_y_net <= in_10;
  slice10_y_net <= in_11;
  slice11_y_net <= in_12;
  slice12_y_net <= in_13;
  slice13_y_net <= in_14;
  slice14_y_net <= in_15;
  slice15_y_net <= in_16;
  reinterpret0 : entity xil_defaultlib.sysgen_reinterpret_8b6893c9f7 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => slice0_y_net,
    output_port => reinterpret0_output_port_net
  );
  reinterpret1 : entity xil_defaultlib.sysgen_reinterpret_8b6893c9f7 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => slice1_y_net,
    output_port => reinterpret1_output_port_net
  );
  reinterpret2 : entity xil_defaultlib.sysgen_reinterpret_8b6893c9f7 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => slice2_y_net,
    output_port => reinterpret2_output_port_net
  );
  reinterpret3 : entity xil_defaultlib.sysgen_reinterpret_8b6893c9f7 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => slice3_y_net,
    output_port => reinterpret3_output_port_net
  );
  reinterpret4 : entity xil_defaultlib.sysgen_reinterpret_8b6893c9f7 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => slice4_y_net,
    output_port => reinterpret4_output_port_net
  );
  reinterpret5 : entity xil_defaultlib.sysgen_reinterpret_8b6893c9f7 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => slice5_y_net,
    output_port => reinterpret5_output_port_net
  );
  reinterpret6 : entity xil_defaultlib.sysgen_reinterpret_8b6893c9f7 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => slice6_y_net,
    output_port => reinterpret6_output_port_net
  );
  reinterpret7 : entity xil_defaultlib.sysgen_reinterpret_8b6893c9f7 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => slice7_y_net,
    output_port => reinterpret7_output_port_net
  );
  reinterpret8 : entity xil_defaultlib.sysgen_reinterpret_8b6893c9f7 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => slice8_y_net,
    output_port => reinterpret8_output_port_net
  );
  reinterpret9 : entity xil_defaultlib.sysgen_reinterpret_8b6893c9f7 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => slice9_y_net,
    output_port => reinterpret9_output_port_net
  );
  reinterpret10 : entity xil_defaultlib.sysgen_reinterpret_8b6893c9f7 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => slice10_y_net,
    output_port => reinterpret10_output_port_net
  );
  reinterpret11 : entity xil_defaultlib.sysgen_reinterpret_8b6893c9f7 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => slice11_y_net,
    output_port => reinterpret11_output_port_net
  );
  reinterpret12 : entity xil_defaultlib.sysgen_reinterpret_8b6893c9f7 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => slice12_y_net,
    output_port => reinterpret12_output_port_net
  );
  reinterpret13 : entity xil_defaultlib.sysgen_reinterpret_8b6893c9f7 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => slice13_y_net,
    output_port => reinterpret13_output_port_net
  );
  reinterpret14 : entity xil_defaultlib.sysgen_reinterpret_8b6893c9f7 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => slice14_y_net,
    output_port => reinterpret14_output_port_net
  );
  reinterpret15 : entity xil_defaultlib.sysgen_reinterpret_8b6893c9f7 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => slice15_y_net,
    output_port => reinterpret15_output_port_net
  );
end structural;
-- Generated from Simulink block ssr_16x16/Vector FFT/Vector Reinterpret3
library IEEE;
use IEEE.std_logic_1164.all;
library xil_defaultlib;
use xil_defaultlib.conv_pkg.all;
entity ssr_16x16_vector_reinterpret3 is
  port (
    in_1 : in std_logic_vector( 27-1 downto 0 );
    in_2 : in std_logic_vector( 27-1 downto 0 );
    in_3 : in std_logic_vector( 27-1 downto 0 );
    in_4 : in std_logic_vector( 27-1 downto 0 );
    in_5 : in std_logic_vector( 27-1 downto 0 );
    in_6 : in std_logic_vector( 27-1 downto 0 );
    in_7 : in std_logic_vector( 27-1 downto 0 );
    in_8 : in std_logic_vector( 27-1 downto 0 );
    in_9 : in std_logic_vector( 27-1 downto 0 );
    in_10 : in std_logic_vector( 27-1 downto 0 );
    in_11 : in std_logic_vector( 27-1 downto 0 );
    in_12 : in std_logic_vector( 27-1 downto 0 );
    in_13 : in std_logic_vector( 27-1 downto 0 );
    in_14 : in std_logic_vector( 27-1 downto 0 );
    in_15 : in std_logic_vector( 27-1 downto 0 );
    in_16 : in std_logic_vector( 27-1 downto 0 );
    out_1 : out std_logic_vector( 27-1 downto 0 );
    out_2 : out std_logic_vector( 27-1 downto 0 );
    out_3 : out std_logic_vector( 27-1 downto 0 );
    out_4 : out std_logic_vector( 27-1 downto 0 );
    out_5 : out std_logic_vector( 27-1 downto 0 );
    out_6 : out std_logic_vector( 27-1 downto 0 );
    out_7 : out std_logic_vector( 27-1 downto 0 );
    out_8 : out std_logic_vector( 27-1 downto 0 );
    out_9 : out std_logic_vector( 27-1 downto 0 );
    out_10 : out std_logic_vector( 27-1 downto 0 );
    out_11 : out std_logic_vector( 27-1 downto 0 );
    out_12 : out std_logic_vector( 27-1 downto 0 );
    out_13 : out std_logic_vector( 27-1 downto 0 );
    out_14 : out std_logic_vector( 27-1 downto 0 );
    out_15 : out std_logic_vector( 27-1 downto 0 );
    out_16 : out std_logic_vector( 27-1 downto 0 )
  );
end ssr_16x16_vector_reinterpret3;
architecture structural of ssr_16x16_vector_reinterpret3 is 
  signal slice15_y_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret0_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret7_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret15_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal slice8_y_net : std_logic_vector( 27-1 downto 0 );
  signal slice3_y_net : std_logic_vector( 27-1 downto 0 );
  signal slice11_y_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret4_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret6_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal slice9_y_net : std_logic_vector( 27-1 downto 0 );
  signal slice13_y_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret3_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal slice1_y_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret12_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal slice0_y_net : std_logic_vector( 27-1 downto 0 );
  signal slice2_y_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret2_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal slice4_y_net : std_logic_vector( 27-1 downto 0 );
  signal slice5_y_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret1_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret14_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret8_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret11_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal slice6_y_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret5_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret9_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret10_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal slice12_y_net : std_logic_vector( 27-1 downto 0 );
  signal slice10_y_net : std_logic_vector( 27-1 downto 0 );
  signal slice14_y_net : std_logic_vector( 27-1 downto 0 );
  signal slice7_y_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret13_output_port_net : std_logic_vector( 27-1 downto 0 );
begin
  out_1 <= reinterpret0_output_port_net;
  out_2 <= reinterpret1_output_port_net;
  out_3 <= reinterpret2_output_port_net;
  out_4 <= reinterpret3_output_port_net;
  out_5 <= reinterpret4_output_port_net;
  out_6 <= reinterpret5_output_port_net;
  out_7 <= reinterpret6_output_port_net;
  out_8 <= reinterpret7_output_port_net;
  out_9 <= reinterpret8_output_port_net;
  out_10 <= reinterpret9_output_port_net;
  out_11 <= reinterpret10_output_port_net;
  out_12 <= reinterpret11_output_port_net;
  out_13 <= reinterpret12_output_port_net;
  out_14 <= reinterpret13_output_port_net;
  out_15 <= reinterpret14_output_port_net;
  out_16 <= reinterpret15_output_port_net;
  slice0_y_net <= in_1;
  slice1_y_net <= in_2;
  slice2_y_net <= in_3;
  slice3_y_net <= in_4;
  slice4_y_net <= in_5;
  slice5_y_net <= in_6;
  slice6_y_net <= in_7;
  slice7_y_net <= in_8;
  slice8_y_net <= in_9;
  slice9_y_net <= in_10;
  slice10_y_net <= in_11;
  slice11_y_net <= in_12;
  slice12_y_net <= in_13;
  slice13_y_net <= in_14;
  slice14_y_net <= in_15;
  slice15_y_net <= in_16;
  reinterpret0 : entity xil_defaultlib.sysgen_reinterpret_8b6893c9f7 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => slice0_y_net,
    output_port => reinterpret0_output_port_net
  );
  reinterpret1 : entity xil_defaultlib.sysgen_reinterpret_8b6893c9f7 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => slice1_y_net,
    output_port => reinterpret1_output_port_net
  );
  reinterpret2 : entity xil_defaultlib.sysgen_reinterpret_8b6893c9f7 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => slice2_y_net,
    output_port => reinterpret2_output_port_net
  );
  reinterpret3 : entity xil_defaultlib.sysgen_reinterpret_8b6893c9f7 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => slice3_y_net,
    output_port => reinterpret3_output_port_net
  );
  reinterpret4 : entity xil_defaultlib.sysgen_reinterpret_8b6893c9f7 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => slice4_y_net,
    output_port => reinterpret4_output_port_net
  );
  reinterpret5 : entity xil_defaultlib.sysgen_reinterpret_8b6893c9f7 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => slice5_y_net,
    output_port => reinterpret5_output_port_net
  );
  reinterpret6 : entity xil_defaultlib.sysgen_reinterpret_8b6893c9f7 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => slice6_y_net,
    output_port => reinterpret6_output_port_net
  );
  reinterpret7 : entity xil_defaultlib.sysgen_reinterpret_8b6893c9f7 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => slice7_y_net,
    output_port => reinterpret7_output_port_net
  );
  reinterpret8 : entity xil_defaultlib.sysgen_reinterpret_8b6893c9f7 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => slice8_y_net,
    output_port => reinterpret8_output_port_net
  );
  reinterpret9 : entity xil_defaultlib.sysgen_reinterpret_8b6893c9f7 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => slice9_y_net,
    output_port => reinterpret9_output_port_net
  );
  reinterpret10 : entity xil_defaultlib.sysgen_reinterpret_8b6893c9f7 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => slice10_y_net,
    output_port => reinterpret10_output_port_net
  );
  reinterpret11 : entity xil_defaultlib.sysgen_reinterpret_8b6893c9f7 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => slice11_y_net,
    output_port => reinterpret11_output_port_net
  );
  reinterpret12 : entity xil_defaultlib.sysgen_reinterpret_8b6893c9f7 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => slice12_y_net,
    output_port => reinterpret12_output_port_net
  );
  reinterpret13 : entity xil_defaultlib.sysgen_reinterpret_8b6893c9f7 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => slice13_y_net,
    output_port => reinterpret13_output_port_net
  );
  reinterpret14 : entity xil_defaultlib.sysgen_reinterpret_8b6893c9f7 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => slice14_y_net,
    output_port => reinterpret14_output_port_net
  );
  reinterpret15 : entity xil_defaultlib.sysgen_reinterpret_8b6893c9f7 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    input_port => slice15_y_net,
    output_port => reinterpret15_output_port_net
  );
end structural;
-- Generated from Simulink block ssr_16x16/Vector FFT/Vector Slice Im
library IEEE;
use IEEE.std_logic_1164.all;
library xil_defaultlib;
use xil_defaultlib.conv_pkg.all;
entity ssr_16x16_vector_slice_im is
  port (
    in_1 : in std_logic_vector( 54-1 downto 0 );
    in_2 : in std_logic_vector( 54-1 downto 0 );
    in_3 : in std_logic_vector( 54-1 downto 0 );
    in_4 : in std_logic_vector( 54-1 downto 0 );
    in_5 : in std_logic_vector( 54-1 downto 0 );
    in_6 : in std_logic_vector( 54-1 downto 0 );
    in_7 : in std_logic_vector( 54-1 downto 0 );
    in_8 : in std_logic_vector( 54-1 downto 0 );
    in_9 : in std_logic_vector( 54-1 downto 0 );
    in_10 : in std_logic_vector( 54-1 downto 0 );
    in_11 : in std_logic_vector( 54-1 downto 0 );
    in_12 : in std_logic_vector( 54-1 downto 0 );
    in_13 : in std_logic_vector( 54-1 downto 0 );
    in_14 : in std_logic_vector( 54-1 downto 0 );
    in_15 : in std_logic_vector( 54-1 downto 0 );
    in_16 : in std_logic_vector( 54-1 downto 0 );
    out_1 : out std_logic_vector( 27-1 downto 0 );
    out_2 : out std_logic_vector( 27-1 downto 0 );
    out_3 : out std_logic_vector( 27-1 downto 0 );
    out_4 : out std_logic_vector( 27-1 downto 0 );
    out_5 : out std_logic_vector( 27-1 downto 0 );
    out_6 : out std_logic_vector( 27-1 downto 0 );
    out_7 : out std_logic_vector( 27-1 downto 0 );
    out_8 : out std_logic_vector( 27-1 downto 0 );
    out_9 : out std_logic_vector( 27-1 downto 0 );
    out_10 : out std_logic_vector( 27-1 downto 0 );
    out_11 : out std_logic_vector( 27-1 downto 0 );
    out_12 : out std_logic_vector( 27-1 downto 0 );
    out_13 : out std_logic_vector( 27-1 downto 0 );
    out_14 : out std_logic_vector( 27-1 downto 0 );
    out_15 : out std_logic_vector( 27-1 downto 0 );
    out_16 : out std_logic_vector( 27-1 downto 0 )
  );
end ssr_16x16_vector_slice_im;
architecture structural of ssr_16x16_vector_slice_im is 
  signal slice5_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice4_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice9_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice12_y_net : std_logic_vector( 27-1 downto 0 );
  signal slice2_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice11_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice1_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice0_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice3_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice6_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice1_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice3_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice10_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice14_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice4_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice15_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice2_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice0_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice7_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice5_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice8_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice6_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice13_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice12_y_net_x0 : std_logic_vector( 54-1 downto 0 );
  signal slice14_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice11_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice13_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice15_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice8_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice9_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice7_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice10_y_net : std_logic_vector( 54-1 downto 0 );
begin
  out_1 <= slice0_y_net_x0;
  out_2 <= slice1_y_net_x0;
  out_3 <= slice2_y_net_x0;
  out_4 <= slice3_y_net_x0;
  out_5 <= slice4_y_net_x0;
  out_6 <= slice5_y_net_x0;
  out_7 <= slice6_y_net_x0;
  out_8 <= slice7_y_net_x0;
  out_9 <= slice8_y_net_x0;
  out_10 <= slice9_y_net_x0;
  out_11 <= slice10_y_net_x0;
  out_12 <= slice11_y_net_x0;
  out_13 <= slice12_y_net;
  out_14 <= slice13_y_net_x0;
  out_15 <= slice14_y_net_x0;
  out_16 <= slice15_y_net_x0;
  slice0_y_net <= in_1;
  slice1_y_net <= in_2;
  slice2_y_net <= in_3;
  slice3_y_net <= in_4;
  slice4_y_net <= in_5;
  slice5_y_net <= in_6;
  slice6_y_net <= in_7;
  slice7_y_net <= in_8;
  slice8_y_net <= in_9;
  slice9_y_net <= in_10;
  slice10_y_net <= in_11;
  slice11_y_net <= in_12;
  slice12_y_net_x0 <= in_13;
  slice13_y_net <= in_14;
  slice14_y_net <= in_15;
  slice15_y_net <= in_16;
  slice0 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 27,
    new_msb => 53,
    x_width => 54,
    y_width => 27
  )
  port map (
    x => slice0_y_net,
    y => slice0_y_net_x0
  );
  slice1 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 27,
    new_msb => 53,
    x_width => 54,
    y_width => 27
  )
  port map (
    x => slice1_y_net,
    y => slice1_y_net_x0
  );
  slice2 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 27,
    new_msb => 53,
    x_width => 54,
    y_width => 27
  )
  port map (
    x => slice2_y_net,
    y => slice2_y_net_x0
  );
  slice3 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 27,
    new_msb => 53,
    x_width => 54,
    y_width => 27
  )
  port map (
    x => slice3_y_net,
    y => slice3_y_net_x0
  );
  slice4 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 27,
    new_msb => 53,
    x_width => 54,
    y_width => 27
  )
  port map (
    x => slice4_y_net,
    y => slice4_y_net_x0
  );
  slice5 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 27,
    new_msb => 53,
    x_width => 54,
    y_width => 27
  )
  port map (
    x => slice5_y_net,
    y => slice5_y_net_x0
  );
  slice6 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 27,
    new_msb => 53,
    x_width => 54,
    y_width => 27
  )
  port map (
    x => slice6_y_net,
    y => slice6_y_net_x0
  );
  slice7 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 27,
    new_msb => 53,
    x_width => 54,
    y_width => 27
  )
  port map (
    x => slice7_y_net,
    y => slice7_y_net_x0
  );
  slice8 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 27,
    new_msb => 53,
    x_width => 54,
    y_width => 27
  )
  port map (
    x => slice8_y_net,
    y => slice8_y_net_x0
  );
  slice9 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 27,
    new_msb => 53,
    x_width => 54,
    y_width => 27
  )
  port map (
    x => slice9_y_net,
    y => slice9_y_net_x0
  );
  slice10 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 27,
    new_msb => 53,
    x_width => 54,
    y_width => 27
  )
  port map (
    x => slice10_y_net,
    y => slice10_y_net_x0
  );
  slice11 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 27,
    new_msb => 53,
    x_width => 54,
    y_width => 27
  )
  port map (
    x => slice11_y_net,
    y => slice11_y_net_x0
  );
  slice12 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 27,
    new_msb => 53,
    x_width => 54,
    y_width => 27
  )
  port map (
    x => slice12_y_net_x0,
    y => slice12_y_net
  );
  slice13 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 27,
    new_msb => 53,
    x_width => 54,
    y_width => 27
  )
  port map (
    x => slice13_y_net,
    y => slice13_y_net_x0
  );
  slice14 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 27,
    new_msb => 53,
    x_width => 54,
    y_width => 27
  )
  port map (
    x => slice14_y_net,
    y => slice14_y_net_x0
  );
  slice15 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 27,
    new_msb => 53,
    x_width => 54,
    y_width => 27
  )
  port map (
    x => slice15_y_net,
    y => slice15_y_net_x0
  );
end structural;
-- Generated from Simulink block ssr_16x16/Vector FFT/Vector Slice Re
library IEEE;
use IEEE.std_logic_1164.all;
library xil_defaultlib;
use xil_defaultlib.conv_pkg.all;
entity ssr_16x16_vector_slice_re is
  port (
    in_1 : in std_logic_vector( 54-1 downto 0 );
    in_2 : in std_logic_vector( 54-1 downto 0 );
    in_3 : in std_logic_vector( 54-1 downto 0 );
    in_4 : in std_logic_vector( 54-1 downto 0 );
    in_5 : in std_logic_vector( 54-1 downto 0 );
    in_6 : in std_logic_vector( 54-1 downto 0 );
    in_7 : in std_logic_vector( 54-1 downto 0 );
    in_8 : in std_logic_vector( 54-1 downto 0 );
    in_9 : in std_logic_vector( 54-1 downto 0 );
    in_10 : in std_logic_vector( 54-1 downto 0 );
    in_11 : in std_logic_vector( 54-1 downto 0 );
    in_12 : in std_logic_vector( 54-1 downto 0 );
    in_13 : in std_logic_vector( 54-1 downto 0 );
    in_14 : in std_logic_vector( 54-1 downto 0 );
    in_15 : in std_logic_vector( 54-1 downto 0 );
    in_16 : in std_logic_vector( 54-1 downto 0 );
    out_1 : out std_logic_vector( 27-1 downto 0 );
    out_2 : out std_logic_vector( 27-1 downto 0 );
    out_3 : out std_logic_vector( 27-1 downto 0 );
    out_4 : out std_logic_vector( 27-1 downto 0 );
    out_5 : out std_logic_vector( 27-1 downto 0 );
    out_6 : out std_logic_vector( 27-1 downto 0 );
    out_7 : out std_logic_vector( 27-1 downto 0 );
    out_8 : out std_logic_vector( 27-1 downto 0 );
    out_9 : out std_logic_vector( 27-1 downto 0 );
    out_10 : out std_logic_vector( 27-1 downto 0 );
    out_11 : out std_logic_vector( 27-1 downto 0 );
    out_12 : out std_logic_vector( 27-1 downto 0 );
    out_13 : out std_logic_vector( 27-1 downto 0 );
    out_14 : out std_logic_vector( 27-1 downto 0 );
    out_15 : out std_logic_vector( 27-1 downto 0 );
    out_16 : out std_logic_vector( 27-1 downto 0 )
  );
end ssr_16x16_vector_slice_re;
architecture structural of ssr_16x16_vector_slice_re is 
  signal slice1_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice0_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice3_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice4_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice5_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice6_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice2_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice3_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice15_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice2_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice4_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice12_y_net : std_logic_vector( 27-1 downto 0 );
  signal slice11_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice9_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice8_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice7_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice7_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice9_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice5_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice13_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice11_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice10_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice13_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice14_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice0_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice1_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice6_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice12_y_net_x0 : std_logic_vector( 54-1 downto 0 );
  signal slice8_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice14_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice15_y_net : std_logic_vector( 54-1 downto 0 );
  signal slice10_y_net_x0 : std_logic_vector( 27-1 downto 0 );
begin
  out_1 <= slice0_y_net_x0;
  out_2 <= slice1_y_net_x0;
  out_3 <= slice2_y_net_x0;
  out_4 <= slice3_y_net_x0;
  out_5 <= slice4_y_net_x0;
  out_6 <= slice5_y_net_x0;
  out_7 <= slice6_y_net_x0;
  out_8 <= slice7_y_net_x0;
  out_9 <= slice8_y_net_x0;
  out_10 <= slice9_y_net_x0;
  out_11 <= slice10_y_net_x0;
  out_12 <= slice11_y_net_x0;
  out_13 <= slice12_y_net;
  out_14 <= slice13_y_net_x0;
  out_15 <= slice14_y_net_x0;
  out_16 <= slice15_y_net_x0;
  slice0_y_net <= in_1;
  slice1_y_net <= in_2;
  slice2_y_net <= in_3;
  slice3_y_net <= in_4;
  slice4_y_net <= in_5;
  slice5_y_net <= in_6;
  slice6_y_net <= in_7;
  slice7_y_net <= in_8;
  slice8_y_net <= in_9;
  slice9_y_net <= in_10;
  slice10_y_net <= in_11;
  slice11_y_net <= in_12;
  slice12_y_net_x0 <= in_13;
  slice13_y_net <= in_14;
  slice14_y_net <= in_15;
  slice15_y_net <= in_16;
  slice0 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 0,
    new_msb => 26,
    x_width => 54,
    y_width => 27
  )
  port map (
    x => slice0_y_net,
    y => slice0_y_net_x0
  );
  slice1 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 0,
    new_msb => 26,
    x_width => 54,
    y_width => 27
  )
  port map (
    x => slice1_y_net,
    y => slice1_y_net_x0
  );
  slice2 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 0,
    new_msb => 26,
    x_width => 54,
    y_width => 27
  )
  port map (
    x => slice2_y_net,
    y => slice2_y_net_x0
  );
  slice3 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 0,
    new_msb => 26,
    x_width => 54,
    y_width => 27
  )
  port map (
    x => slice3_y_net,
    y => slice3_y_net_x0
  );
  slice4 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 0,
    new_msb => 26,
    x_width => 54,
    y_width => 27
  )
  port map (
    x => slice4_y_net,
    y => slice4_y_net_x0
  );
  slice5 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 0,
    new_msb => 26,
    x_width => 54,
    y_width => 27
  )
  port map (
    x => slice5_y_net,
    y => slice5_y_net_x0
  );
  slice6 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 0,
    new_msb => 26,
    x_width => 54,
    y_width => 27
  )
  port map (
    x => slice6_y_net,
    y => slice6_y_net_x0
  );
  slice7 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 0,
    new_msb => 26,
    x_width => 54,
    y_width => 27
  )
  port map (
    x => slice7_y_net,
    y => slice7_y_net_x0
  );
  slice8 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 0,
    new_msb => 26,
    x_width => 54,
    y_width => 27
  )
  port map (
    x => slice8_y_net,
    y => slice8_y_net_x0
  );
  slice9 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 0,
    new_msb => 26,
    x_width => 54,
    y_width => 27
  )
  port map (
    x => slice9_y_net,
    y => slice9_y_net_x0
  );
  slice10 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 0,
    new_msb => 26,
    x_width => 54,
    y_width => 27
  )
  port map (
    x => slice10_y_net,
    y => slice10_y_net_x0
  );
  slice11 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 0,
    new_msb => 26,
    x_width => 54,
    y_width => 27
  )
  port map (
    x => slice11_y_net,
    y => slice11_y_net_x0
  );
  slice12 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 0,
    new_msb => 26,
    x_width => 54,
    y_width => 27
  )
  port map (
    x => slice12_y_net_x0,
    y => slice12_y_net
  );
  slice13 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 0,
    new_msb => 26,
    x_width => 54,
    y_width => 27
  )
  port map (
    x => slice13_y_net,
    y => slice13_y_net_x0
  );
  slice14 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 0,
    new_msb => 26,
    x_width => 54,
    y_width => 27
  )
  port map (
    x => slice14_y_net,
    y => slice14_y_net_x0
  );
  slice15 : entity xil_defaultlib.ssr_16x16_xlslice 
  generic map (
    new_lsb => 0,
    new_msb => 26,
    x_width => 54,
    y_width => 27
  )
  port map (
    x => slice15_y_net,
    y => slice15_y_net_x0
  );
end structural;
-- Generated from Simulink block ssr_16x16/Vector FFT/Vector2Scalar
library IEEE;
use IEEE.std_logic_1164.all;
library xil_defaultlib;
use xil_defaultlib.conv_pkg.all;
entity ssr_16x16_vector2scalar is
  port (
    i_1 : in std_logic_vector( 32-1 downto 0 );
    i_2 : in std_logic_vector( 32-1 downto 0 );
    i_3 : in std_logic_vector( 32-1 downto 0 );
    i_4 : in std_logic_vector( 32-1 downto 0 );
    i_5 : in std_logic_vector( 32-1 downto 0 );
    i_6 : in std_logic_vector( 32-1 downto 0 );
    i_7 : in std_logic_vector( 32-1 downto 0 );
    i_8 : in std_logic_vector( 32-1 downto 0 );
    i_9 : in std_logic_vector( 32-1 downto 0 );
    i_10 : in std_logic_vector( 32-1 downto 0 );
    i_11 : in std_logic_vector( 32-1 downto 0 );
    i_12 : in std_logic_vector( 32-1 downto 0 );
    i_13 : in std_logic_vector( 32-1 downto 0 );
    i_14 : in std_logic_vector( 32-1 downto 0 );
    i_15 : in std_logic_vector( 32-1 downto 0 );
    i_16 : in std_logic_vector( 32-1 downto 0 );
    o : out std_logic_vector( 512-1 downto 0 )
  );
end ssr_16x16_vector2scalar;
architecture structural of ssr_16x16_vector2scalar is 
  signal delay3_q_net : std_logic_vector( 32-1 downto 0 );
  signal delay14_q_net : std_logic_vector( 32-1 downto 0 );
  signal delay11_q_net : std_logic_vector( 32-1 downto 0 );
  signal delay1_q_net : std_logic_vector( 32-1 downto 0 );
  signal delay9_q_net : std_logic_vector( 32-1 downto 0 );
  signal delay12_q_net : std_logic_vector( 32-1 downto 0 );
  signal delay6_q_net : std_logic_vector( 32-1 downto 0 );
  signal delay0_q_net : std_logic_vector( 32-1 downto 0 );
  signal delay2_q_net : std_logic_vector( 32-1 downto 0 );
  signal delay4_q_net : std_logic_vector( 32-1 downto 0 );
  signal delay8_q_net : std_logic_vector( 32-1 downto 0 );
  signal concat1_y_net : std_logic_vector( 512-1 downto 0 );
  signal delay5_q_net : std_logic_vector( 32-1 downto 0 );
  signal delay7_q_net : std_logic_vector( 32-1 downto 0 );
  signal delay10_q_net : std_logic_vector( 32-1 downto 0 );
  signal delay13_q_net : std_logic_vector( 32-1 downto 0 );
  signal delay15_q_net : std_logic_vector( 32-1 downto 0 );
begin
  o <= concat1_y_net;
  delay0_q_net <= i_1;
  delay1_q_net <= i_2;
  delay2_q_net <= i_3;
  delay3_q_net <= i_4;
  delay4_q_net <= i_5;
  delay5_q_net <= i_6;
  delay6_q_net <= i_7;
  delay7_q_net <= i_8;
  delay8_q_net <= i_9;
  delay9_q_net <= i_10;
  delay10_q_net <= i_11;
  delay11_q_net <= i_12;
  delay12_q_net <= i_13;
  delay13_q_net <= i_14;
  delay14_q_net <= i_15;
  delay15_q_net <= i_16;
  concat1 : entity xil_defaultlib.sysgen_concat_207a0960b2 
  port map (
    clk => '0',
    ce => '0',
    clr => '0',
    in0 => delay15_q_net,
    in1 => delay14_q_net,
    in2 => delay13_q_net,
    in3 => delay12_q_net,
    in4 => delay11_q_net,
    in5 => delay10_q_net,
    in6 => delay9_q_net,
    in7 => delay8_q_net,
    in8 => delay7_q_net,
    in9 => delay6_q_net,
    in10 => delay5_q_net,
    in11 => delay4_q_net,
    in12 => delay3_q_net,
    in13 => delay2_q_net,
    in14 => delay1_q_net,
    in15 => delay0_q_net,
    y => concat1_y_net
  );
end structural;
-- Generated from Simulink block ssr_16x16/Vector FFT
library IEEE;
use IEEE.std_logic_1164.all;
library xil_defaultlib;
use xil_defaultlib.conv_pkg.all;
entity ssr_16x16_vector_fft is
  port (
    i_re_1 : in std_logic_vector( 16-1 downto 0 );
    i_im_1 : in std_logic_vector( 16-1 downto 0 );
    vi : in std_logic_vector( 1-1 downto 0 );
    si : in std_logic_vector( 4-1 downto 0 );
    i_re_2 : in std_logic_vector( 16-1 downto 0 );
    i_re_3 : in std_logic_vector( 16-1 downto 0 );
    i_re_4 : in std_logic_vector( 16-1 downto 0 );
    i_re_5 : in std_logic_vector( 16-1 downto 0 );
    i_re_6 : in std_logic_vector( 16-1 downto 0 );
    i_re_7 : in std_logic_vector( 16-1 downto 0 );
    i_re_8 : in std_logic_vector( 16-1 downto 0 );
    i_re_9 : in std_logic_vector( 16-1 downto 0 );
    i_re_10 : in std_logic_vector( 16-1 downto 0 );
    i_re_11 : in std_logic_vector( 16-1 downto 0 );
    i_re_12 : in std_logic_vector( 16-1 downto 0 );
    i_re_13 : in std_logic_vector( 16-1 downto 0 );
    i_re_14 : in std_logic_vector( 16-1 downto 0 );
    i_re_15 : in std_logic_vector( 16-1 downto 0 );
    i_re_16 : in std_logic_vector( 16-1 downto 0 );
    i_im_2 : in std_logic_vector( 16-1 downto 0 );
    i_im_3 : in std_logic_vector( 16-1 downto 0 );
    i_im_4 : in std_logic_vector( 16-1 downto 0 );
    i_im_5 : in std_logic_vector( 16-1 downto 0 );
    i_im_6 : in std_logic_vector( 16-1 downto 0 );
    i_im_7 : in std_logic_vector( 16-1 downto 0 );
    i_im_8 : in std_logic_vector( 16-1 downto 0 );
    i_im_9 : in std_logic_vector( 16-1 downto 0 );
    i_im_10 : in std_logic_vector( 16-1 downto 0 );
    i_im_11 : in std_logic_vector( 16-1 downto 0 );
    i_im_12 : in std_logic_vector( 16-1 downto 0 );
    i_im_13 : in std_logic_vector( 16-1 downto 0 );
    i_im_14 : in std_logic_vector( 16-1 downto 0 );
    i_im_15 : in std_logic_vector( 16-1 downto 0 );
    i_im_16 : in std_logic_vector( 16-1 downto 0 );
    clk_1 : in std_logic;
    ce_1 : in std_logic;
    o_re_1 : out std_logic_vector( 27-1 downto 0 );
    o_im_1 : out std_logic_vector( 27-1 downto 0 );
    vo : out std_logic;
    so : out std_logic_vector( 4-1 downto 0 );
    o_re_2 : out std_logic_vector( 27-1 downto 0 );
    o_re_3 : out std_logic_vector( 27-1 downto 0 );
    o_re_4 : out std_logic_vector( 27-1 downto 0 );
    o_re_5 : out std_logic_vector( 27-1 downto 0 );
    o_re_6 : out std_logic_vector( 27-1 downto 0 );
    o_re_7 : out std_logic_vector( 27-1 downto 0 );
    o_re_8 : out std_logic_vector( 27-1 downto 0 );
    o_re_9 : out std_logic_vector( 27-1 downto 0 );
    o_re_10 : out std_logic_vector( 27-1 downto 0 );
    o_re_11 : out std_logic_vector( 27-1 downto 0 );
    o_re_12 : out std_logic_vector( 27-1 downto 0 );
    o_re_13 : out std_logic_vector( 27-1 downto 0 );
    o_re_14 : out std_logic_vector( 27-1 downto 0 );
    o_re_15 : out std_logic_vector( 27-1 downto 0 );
    o_re_16 : out std_logic_vector( 27-1 downto 0 );
    o_im_2 : out std_logic_vector( 27-1 downto 0 );
    o_im_3 : out std_logic_vector( 27-1 downto 0 );
    o_im_4 : out std_logic_vector( 27-1 downto 0 );
    o_im_5 : out std_logic_vector( 27-1 downto 0 );
    o_im_6 : out std_logic_vector( 27-1 downto 0 );
    o_im_7 : out std_logic_vector( 27-1 downto 0 );
    o_im_8 : out std_logic_vector( 27-1 downto 0 );
    o_im_9 : out std_logic_vector( 27-1 downto 0 );
    o_im_10 : out std_logic_vector( 27-1 downto 0 );
    o_im_11 : out std_logic_vector( 27-1 downto 0 );
    o_im_12 : out std_logic_vector( 27-1 downto 0 );
    o_im_13 : out std_logic_vector( 27-1 downto 0 );
    o_im_14 : out std_logic_vector( 27-1 downto 0 );
    o_im_15 : out std_logic_vector( 27-1 downto 0 );
    o_im_16 : out std_logic_vector( 27-1 downto 0 )
  );
end ssr_16x16_vector_fft;
architecture structural of ssr_16x16_vector_fft is 
  signal slice7_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice8_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice12_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice15_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal concat1_y_net : std_logic_vector( 512-1 downto 0 );
  signal delay1_q_net_x0 : std_logic_vector( 4-1 downto 0 );
  signal slice10_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice13_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice9_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice14_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice11_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal delay_q_net : std_logic_vector( 1-1 downto 0 );
  signal reinterpret2_output_port_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal reinterpret8_output_port_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal reinterpret9_output_port_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal reinterpret7_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret15_output_port_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal reinterpret3_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal test_systolicfft_vhdl_black_box_so_net : std_logic_vector( 4-1 downto 0 );
  signal reinterpret12_output_port_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal reinterpret4_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret7_output_port_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal reinterpret8_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret14_output_port_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal reinterpret4_output_port_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal reinterpret13_output_port_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal reinterpret0_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret3_output_port_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal reinterpret0_output_port_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal reinterpret5_output_port_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal reinterpret6_output_port_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal reinterpret11_output_port_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal reinterpret1_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret10_output_port_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal test_systolicfft_vhdl_black_box_vo_net : std_logic;
  signal reinterpret1_output_port_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal reinterpret5_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret6_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret2_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal i_im_0_net : std_logic_vector( 16-1 downto 0 );
  signal i_scale_net : std_logic_vector( 4-1 downto 0 );
  signal reinterpret14_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal i_re_4_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_0_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_12_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_5_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_6_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_10_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret13_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal i_valid_net : std_logic_vector( 1-1 downto 0 );
  signal i_re_11_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_2_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_6_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_3_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_13_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_9_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_7_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_2_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_15_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_4_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret12_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal i_im_1_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_8_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret9_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal i_re_1_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_5_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret10_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret11_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret15_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal i_re_14_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_3_net : std_logic_vector( 16-1 downto 0 );
  signal clk_net : std_logic;
  signal slice0_y_net_x1 : std_logic_vector( 54-1 downto 0 );
  signal slice11_y_net_x1 : std_logic_vector( 54-1 downto 0 );
  signal slice15_y_net_x1 : std_logic_vector( 54-1 downto 0 );
  signal concat2_y_net : std_logic_vector( 32-1 downto 0 );
  signal concat7_y_net : std_logic_vector( 32-1 downto 0 );
  signal i_im_9_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_15_net : std_logic_vector( 16-1 downto 0 );
  signal concat6_y_net : std_logic_vector( 32-1 downto 0 );
  signal concat8_y_net : std_logic_vector( 32-1 downto 0 );
  signal slice7_y_net_x1 : std_logic_vector( 54-1 downto 0 );
  signal concat9_y_net : std_logic_vector( 32-1 downto 0 );
  signal slice5_y_net_x1 : std_logic_vector( 54-1 downto 0 );
  signal slice13_y_net_x1 : std_logic_vector( 54-1 downto 0 );
  signal concat13_y_net : std_logic_vector( 32-1 downto 0 );
  signal reinterpret3_output_port_net_x1 : std_logic_vector( 16-1 downto 0 );
  signal concat3_y_net : std_logic_vector( 32-1 downto 0 );
  signal reinterpret1_output_port_net_x1 : std_logic_vector( 16-1 downto 0 );
  signal i_im_10_net : std_logic_vector( 16-1 downto 0 );
  signal slice12_y_net_x1 : std_logic_vector( 54-1 downto 0 );
  signal reinterpret0_output_port_net_x2 : std_logic_vector( 16-1 downto 0 );
  signal slice1_y_net_x1 : std_logic_vector( 54-1 downto 0 );
  signal reinterpret4_output_port_net_x1 : std_logic_vector( 16-1 downto 0 );
  signal slice10_y_net_x1 : std_logic_vector( 54-1 downto 0 );
  signal concat11_y_net : std_logic_vector( 32-1 downto 0 );
  signal reinterpret0_output_port_net_x1 : std_logic_vector( 16-1 downto 0 );
  signal slice8_y_net_x1 : std_logic_vector( 54-1 downto 0 );
  signal i_im_13_net : std_logic_vector( 16-1 downto 0 );
  signal concat1_y_net_x0 : std_logic_vector( 32-1 downto 0 );
  signal concat10_y_net : std_logic_vector( 32-1 downto 0 );
  signal slice6_y_net_x1 : std_logic_vector( 54-1 downto 0 );
  signal slice3_y_net_x1 : std_logic_vector( 54-1 downto 0 );
  signal concat14_y_net : std_logic_vector( 32-1 downto 0 );
  signal reinterpret6_output_port_net_x1 : std_logic_vector( 16-1 downto 0 );
  signal concat0_y_net : std_logic_vector( 32-1 downto 0 );
  signal slice14_y_net_x1 : std_logic_vector( 54-1 downto 0 );
  signal concat4_y_net : std_logic_vector( 32-1 downto 0 );
  signal i_im_12_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_7_net : std_logic_vector( 16-1 downto 0 );
  signal slice2_y_net_x1 : std_logic_vector( 54-1 downto 0 );
  signal concat12_y_net : std_logic_vector( 32-1 downto 0 );
  signal i_im_8_net : std_logic_vector( 16-1 downto 0 );
  signal concat15_y_net : std_logic_vector( 32-1 downto 0 );
  signal i_im_14_net : std_logic_vector( 16-1 downto 0 );
  signal concat5_y_net : std_logic_vector( 32-1 downto 0 );
  signal reinterpret2_output_port_net_x1 : std_logic_vector( 16-1 downto 0 );
  signal reinterpret5_output_port_net_x1 : std_logic_vector( 16-1 downto 0 );
  signal slice9_y_net_x1 : std_logic_vector( 54-1 downto 0 );
  signal test_systolicfft_vhdl_black_box_o_net : std_logic_vector( 864-1 downto 0 );
  signal reinterpret7_output_port_net_x1 : std_logic_vector( 16-1 downto 0 );
  signal i_im_11_net : std_logic_vector( 16-1 downto 0 );
  signal slice4_y_net_x1 : std_logic_vector( 54-1 downto 0 );
  signal ce_net : std_logic;
  signal delay11_q_net : std_logic_vector( 32-1 downto 0 );
  signal slice5_y_net : std_logic_vector( 27-1 downto 0 );
  signal slice3_y_net : std_logic_vector( 27-1 downto 0 );
  signal slice13_y_net : std_logic_vector( 27-1 downto 0 );
  signal slice2_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal reinterpret11_output_port_net_x1 : std_logic_vector( 16-1 downto 0 );
  signal delay7_q_net : std_logic_vector( 32-1 downto 0 );
  signal slice2_y_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret12_output_port_net_x1 : std_logic_vector( 16-1 downto 0 );
  signal delay15_q_net : std_logic_vector( 32-1 downto 0 );
  signal slice4_y_net : std_logic_vector( 27-1 downto 0 );
  signal slice7_y_net : std_logic_vector( 27-1 downto 0 );
  signal slice3_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal delay13_q_net : std_logic_vector( 32-1 downto 0 );
  signal slice5_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice6_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice14_y_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret8_output_port_net_x2 : std_logic_vector( 16-1 downto 0 );
  signal reinterpret9_output_port_net_x1 : std_logic_vector( 16-1 downto 0 );
  signal reinterpret5_output_port_net_x2 : std_logic_vector( 16-1 downto 0 );
  signal reinterpret14_output_port_net_x2 : std_logic_vector( 16-1 downto 0 );
  signal delay2_q_net : std_logic_vector( 32-1 downto 0 );
  signal delay14_q_net : std_logic_vector( 32-1 downto 0 );
  signal delay6_q_net : std_logic_vector( 32-1 downto 0 );
  signal slice0_y_net : std_logic_vector( 27-1 downto 0 );
  signal slice11_y_net : std_logic_vector( 27-1 downto 0 );
  signal slice15_y_net : std_logic_vector( 27-1 downto 0 );
  signal slice0_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal slice1_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal delay10_q_net : std_logic_vector( 32-1 downto 0 );
  signal slice4_y_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal reinterpret8_output_port_net_x1 : std_logic_vector( 16-1 downto 0 );
  signal reinterpret2_output_port_net_x2 : std_logic_vector( 16-1 downto 0 );
  signal reinterpret15_output_port_net_x1 : std_logic_vector( 16-1 downto 0 );
  signal reinterpret9_output_port_net_x2 : std_logic_vector( 16-1 downto 0 );
  signal reinterpret13_output_port_net_x2 : std_logic_vector( 16-1 downto 0 );
  signal delay5_q_net : std_logic_vector( 32-1 downto 0 );
  signal delay8_q_net : std_logic_vector( 32-1 downto 0 );
  signal delay12_q_net : std_logic_vector( 32-1 downto 0 );
  signal reinterpret13_output_port_net_x1 : std_logic_vector( 16-1 downto 0 );
  signal delay1_q_net : std_logic_vector( 32-1 downto 0 );
  signal delay3_q_net : std_logic_vector( 32-1 downto 0 );
  signal slice1_y_net : std_logic_vector( 27-1 downto 0 );
  signal delay4_q_net : std_logic_vector( 32-1 downto 0 );
  signal reinterpret6_output_port_net_x2 : std_logic_vector( 16-1 downto 0 );
  signal reinterpret12_output_port_net_x2 : std_logic_vector( 16-1 downto 0 );
  signal reinterpret10_output_port_net_x1 : std_logic_vector( 16-1 downto 0 );
  signal reinterpret3_output_port_net_x2 : std_logic_vector( 16-1 downto 0 );
  signal delay0_q_net : std_logic_vector( 32-1 downto 0 );
  signal delay9_q_net : std_logic_vector( 32-1 downto 0 );
  signal reinterpret7_output_port_net_x2 : std_logic_vector( 16-1 downto 0 );
  signal reinterpret10_output_port_net_x2 : std_logic_vector( 16-1 downto 0 );
  signal slice6_y_net : std_logic_vector( 27-1 downto 0 );
  signal slice8_y_net : std_logic_vector( 27-1 downto 0 );
  signal slice10_y_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret14_output_port_net_x1 : std_logic_vector( 16-1 downto 0 );
  signal reinterpret15_output_port_net_x2 : std_logic_vector( 16-1 downto 0 );
  signal slice9_y_net : std_logic_vector( 27-1 downto 0 );
  signal slice12_y_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret1_output_port_net_x2 : std_logic_vector( 16-1 downto 0 );
  signal reinterpret4_output_port_net_x2 : std_logic_vector( 16-1 downto 0 );
  signal reinterpret11_output_port_net_x2 : std_logic_vector( 16-1 downto 0 );
begin
  o_re_1 <= reinterpret0_output_port_net_x0;
  o_im_1 <= reinterpret0_output_port_net;
  vo <= test_systolicfft_vhdl_black_box_vo_net;
  so <= test_systolicfft_vhdl_black_box_so_net;
  o_re_2 <= reinterpret1_output_port_net_x0;
  o_re_3 <= reinterpret2_output_port_net_x0;
  o_re_4 <= reinterpret3_output_port_net_x0;
  o_re_5 <= reinterpret4_output_port_net_x0;
  o_re_6 <= reinterpret5_output_port_net_x0;
  o_re_7 <= reinterpret6_output_port_net_x0;
  o_re_8 <= reinterpret7_output_port_net_x0;
  o_re_9 <= reinterpret8_output_port_net_x0;
  o_re_10 <= reinterpret9_output_port_net_x0;
  o_re_11 <= reinterpret10_output_port_net_x0;
  o_re_12 <= reinterpret11_output_port_net_x0;
  o_re_13 <= reinterpret12_output_port_net_x0;
  o_re_14 <= reinterpret13_output_port_net_x0;
  o_re_15 <= reinterpret14_output_port_net_x0;
  o_re_16 <= reinterpret15_output_port_net_x0;
  o_im_2 <= reinterpret1_output_port_net;
  o_im_3 <= reinterpret2_output_port_net;
  o_im_4 <= reinterpret3_output_port_net;
  o_im_5 <= reinterpret4_output_port_net;
  o_im_6 <= reinterpret5_output_port_net;
  o_im_7 <= reinterpret6_output_port_net;
  o_im_8 <= reinterpret7_output_port_net;
  o_im_9 <= reinterpret8_output_port_net;
  o_im_10 <= reinterpret9_output_port_net;
  o_im_11 <= reinterpret10_output_port_net;
  o_im_12 <= reinterpret11_output_port_net;
  o_im_13 <= reinterpret12_output_port_net;
  o_im_14 <= reinterpret13_output_port_net;
  o_im_15 <= reinterpret14_output_port_net;
  o_im_16 <= reinterpret15_output_port_net;
  i_re_0_net <= i_re_1;
  i_im_0_net <= i_im_1;
  i_valid_net <= vi;
  i_scale_net <= si;
  i_re_1_net <= i_re_2;
  i_re_2_net <= i_re_3;
  i_re_3_net <= i_re_4;
  i_re_4_net <= i_re_5;
  i_re_5_net <= i_re_6;
  i_re_6_net <= i_re_7;
  i_re_7_net <= i_re_8;
  i_re_8_net <= i_re_9;
  i_re_9_net <= i_re_10;
  i_re_10_net <= i_re_11;
  i_re_11_net <= i_re_12;
  i_re_12_net <= i_re_13;
  i_re_13_net <= i_re_14;
  i_re_14_net <= i_re_15;
  i_re_15_net <= i_re_16;
  i_im_1_net <= i_im_2;
  i_im_2_net <= i_im_3;
  i_im_3_net <= i_im_4;
  i_im_4_net <= i_im_5;
  i_im_5_net <= i_im_6;
  i_im_6_net <= i_im_7;
  i_im_7_net <= i_im_8;
  i_im_8_net <= i_im_9;
  i_im_9_net <= i_im_10;
  i_im_10_net <= i_im_11;
  i_im_11_net <= i_im_12;
  i_im_12_net <= i_im_13;
  i_im_13_net <= i_im_14;
  i_im_14_net <= i_im_15;
  i_im_15_net <= i_im_16;
  clk_net <= clk_1;
  ce_net <= ce_1;
  scalar2vector : entity xil_defaultlib.ssr_16x16_scalar2vector 
  port map (
    i => test_systolicfft_vhdl_black_box_o_net,
    o_1 => slice0_y_net_x1,
    o_2 => slice1_y_net_x1,
    o_3 => slice2_y_net_x1,
    o_4 => slice3_y_net_x1,
    o_5 => slice4_y_net_x1,
    o_6 => slice5_y_net_x1,
    o_7 => slice6_y_net_x1,
    o_8 => slice7_y_net_x1,
    o_9 => slice8_y_net_x1,
    o_10 => slice9_y_net_x1,
    o_11 => slice10_y_net_x1,
    o_12 => slice11_y_net_x1,
    o_13 => slice12_y_net_x1,
    o_14 => slice13_y_net_x1,
    o_15 => slice14_y_net_x1,
    o_16 => slice15_y_net_x1
  );
  vector_concat : entity xil_defaultlib.ssr_16x16_vector_concat 
  port map (
    hi_1 => reinterpret0_output_port_net_x1,
    lo_1 => reinterpret0_output_port_net_x2,
    hi_2 => reinterpret1_output_port_net_x1,
    hi_3 => reinterpret2_output_port_net_x1,
    hi_4 => reinterpret3_output_port_net_x1,
    hi_5 => reinterpret4_output_port_net_x1,
    hi_6 => reinterpret5_output_port_net_x1,
    hi_7 => reinterpret6_output_port_net_x1,
    hi_8 => reinterpret7_output_port_net_x1,
    hi_9 => reinterpret8_output_port_net_x1,
    hi_10 => reinterpret9_output_port_net_x1,
    hi_11 => reinterpret10_output_port_net_x1,
    hi_12 => reinterpret11_output_port_net_x1,
    hi_13 => reinterpret12_output_port_net_x1,
    hi_14 => reinterpret13_output_port_net_x1,
    hi_15 => reinterpret14_output_port_net_x1,
    hi_16 => reinterpret15_output_port_net_x1,
    lo_2 => reinterpret1_output_port_net_x2,
    lo_3 => reinterpret2_output_port_net_x2,
    lo_4 => reinterpret3_output_port_net_x2,
    lo_5 => reinterpret4_output_port_net_x2,
    lo_6 => reinterpret5_output_port_net_x2,
    lo_7 => reinterpret6_output_port_net_x2,
    lo_8 => reinterpret7_output_port_net_x2,
    lo_9 => reinterpret8_output_port_net_x2,
    lo_10 => reinterpret9_output_port_net_x2,
    lo_11 => reinterpret10_output_port_net_x2,
    lo_12 => reinterpret11_output_port_net_x2,
    lo_13 => reinterpret12_output_port_net_x2,
    lo_14 => reinterpret13_output_port_net_x2,
    lo_15 => reinterpret14_output_port_net_x2,
    lo_16 => reinterpret15_output_port_net_x2,
    out_1 => concat0_y_net,
    out_2 => concat1_y_net_x0,
    out_3 => concat2_y_net,
    out_4 => concat3_y_net,
    out_5 => concat4_y_net,
    out_6 => concat5_y_net,
    out_7 => concat6_y_net,
    out_8 => concat7_y_net,
    out_9 => concat8_y_net,
    out_10 => concat9_y_net,
    out_11 => concat10_y_net,
    out_12 => concat11_y_net,
    out_13 => concat12_y_net,
    out_14 => concat13_y_net,
    out_15 => concat14_y_net,
    out_16 => concat15_y_net
  );
  vector_delay : entity xil_defaultlib.ssr_16x16_vector_delay 
  port map (
    d_1 => concat0_y_net,
    d_2 => concat1_y_net_x0,
    d_3 => concat2_y_net,
    d_4 => concat3_y_net,
    d_5 => concat4_y_net,
    d_6 => concat5_y_net,
    d_7 => concat6_y_net,
    d_8 => concat7_y_net,
    d_9 => concat8_y_net,
    d_10 => concat9_y_net,
    d_11 => concat10_y_net,
    d_12 => concat11_y_net,
    d_13 => concat12_y_net,
    d_14 => concat13_y_net,
    d_15 => concat14_y_net,
    d_16 => concat15_y_net,
    clk_1 => clk_net,
    ce_1 => ce_net,
    q_1 => delay0_q_net,
    q_2 => delay1_q_net,
    q_3 => delay2_q_net,
    q_4 => delay3_q_net,
    q_5 => delay4_q_net,
    q_6 => delay5_q_net,
    q_7 => delay6_q_net,
    q_8 => delay7_q_net,
    q_9 => delay8_q_net,
    q_10 => delay9_q_net,
    q_11 => delay10_q_net,
    q_12 => delay11_q_net,
    q_13 => delay12_q_net,
    q_14 => delay13_q_net,
    q_15 => delay14_q_net,
    q_16 => delay15_q_net
  );
  vector_reinterpret : entity xil_defaultlib.ssr_16x16_vector_reinterpret 
  port map (
    in_1 => i_re_0_net,
    in_2 => i_re_1_net,
    in_3 => i_re_2_net,
    in_4 => i_re_3_net,
    in_5 => i_re_4_net,
    in_6 => i_re_5_net,
    in_7 => i_re_6_net,
    in_8 => i_re_7_net,
    in_9 => i_re_8_net,
    in_10 => i_re_9_net,
    in_11 => i_re_10_net,
    in_12 => i_re_11_net,
    in_13 => i_re_12_net,
    in_14 => i_re_13_net,
    in_15 => i_re_14_net,
    in_16 => i_re_15_net,
    out_1 => reinterpret0_output_port_net_x2,
    out_2 => reinterpret1_output_port_net_x2,
    out_3 => reinterpret2_output_port_net_x2,
    out_4 => reinterpret3_output_port_net_x2,
    out_5 => reinterpret4_output_port_net_x2,
    out_6 => reinterpret5_output_port_net_x2,
    out_7 => reinterpret6_output_port_net_x2,
    out_8 => reinterpret7_output_port_net_x2,
    out_9 => reinterpret8_output_port_net_x2,
    out_10 => reinterpret9_output_port_net_x2,
    out_11 => reinterpret10_output_port_net_x2,
    out_12 => reinterpret11_output_port_net_x2,
    out_13 => reinterpret12_output_port_net_x2,
    out_14 => reinterpret13_output_port_net_x2,
    out_15 => reinterpret14_output_port_net_x2,
    out_16 => reinterpret15_output_port_net_x2
  );
  vector_reinterpret1 : entity xil_defaultlib.ssr_16x16_vector_reinterpret1 
  port map (
    in_1 => i_im_0_net,
    in_2 => i_im_1_net,
    in_3 => i_im_2_net,
    in_4 => i_im_3_net,
    in_5 => i_im_4_net,
    in_6 => i_im_5_net,
    in_7 => i_im_6_net,
    in_8 => i_im_7_net,
    in_9 => i_im_8_net,
    in_10 => i_im_9_net,
    in_11 => i_im_10_net,
    in_12 => i_im_11_net,
    in_13 => i_im_12_net,
    in_14 => i_im_13_net,
    in_15 => i_im_14_net,
    in_16 => i_im_15_net,
    out_1 => reinterpret0_output_port_net_x1,
    out_2 => reinterpret1_output_port_net_x1,
    out_3 => reinterpret2_output_port_net_x1,
    out_4 => reinterpret3_output_port_net_x1,
    out_5 => reinterpret4_output_port_net_x1,
    out_6 => reinterpret5_output_port_net_x1,
    out_7 => reinterpret6_output_port_net_x1,
    out_8 => reinterpret7_output_port_net_x1,
    out_9 => reinterpret8_output_port_net_x1,
    out_10 => reinterpret9_output_port_net_x1,
    out_11 => reinterpret10_output_port_net_x1,
    out_12 => reinterpret11_output_port_net_x1,
    out_13 => reinterpret12_output_port_net_x1,
    out_14 => reinterpret13_output_port_net_x1,
    out_15 => reinterpret14_output_port_net_x1,
    out_16 => reinterpret15_output_port_net_x1
  );
  vector_reinterpret2 : entity xil_defaultlib.ssr_16x16_vector_reinterpret2 
  port map (
    in_1 => slice0_y_net,
    in_2 => slice1_y_net,
    in_3 => slice2_y_net,
    in_4 => slice3_y_net,
    in_5 => slice4_y_net,
    in_6 => slice5_y_net,
    in_7 => slice6_y_net,
    in_8 => slice7_y_net,
    in_9 => slice8_y_net,
    in_10 => slice9_y_net,
    in_11 => slice10_y_net,
    in_12 => slice11_y_net,
    in_13 => slice12_y_net,
    in_14 => slice13_y_net,
    in_15 => slice14_y_net,
    in_16 => slice15_y_net,
    out_1 => reinterpret0_output_port_net_x0,
    out_2 => reinterpret1_output_port_net_x0,
    out_3 => reinterpret2_output_port_net_x0,
    out_4 => reinterpret3_output_port_net_x0,
    out_5 => reinterpret4_output_port_net_x0,
    out_6 => reinterpret5_output_port_net_x0,
    out_7 => reinterpret6_output_port_net_x0,
    out_8 => reinterpret7_output_port_net_x0,
    out_9 => reinterpret8_output_port_net_x0,
    out_10 => reinterpret9_output_port_net_x0,
    out_11 => reinterpret10_output_port_net_x0,
    out_12 => reinterpret11_output_port_net_x0,
    out_13 => reinterpret12_output_port_net_x0,
    out_14 => reinterpret13_output_port_net_x0,
    out_15 => reinterpret14_output_port_net_x0,
    out_16 => reinterpret15_output_port_net_x0
  );
  vector_reinterpret3 : entity xil_defaultlib.ssr_16x16_vector_reinterpret3 
  port map (
    in_1 => slice0_y_net_x0,
    in_2 => slice1_y_net_x0,
    in_3 => slice2_y_net_x0,
    in_4 => slice3_y_net_x0,
    in_5 => slice4_y_net_x0,
    in_6 => slice5_y_net_x0,
    in_7 => slice6_y_net_x0,
    in_8 => slice7_y_net_x0,
    in_9 => slice8_y_net_x0,
    in_10 => slice9_y_net_x0,
    in_11 => slice10_y_net_x0,
    in_12 => slice11_y_net_x0,
    in_13 => slice12_y_net_x0,
    in_14 => slice13_y_net_x0,
    in_15 => slice14_y_net_x0,
    in_16 => slice15_y_net_x0,
    out_1 => reinterpret0_output_port_net,
    out_2 => reinterpret1_output_port_net,
    out_3 => reinterpret2_output_port_net,
    out_4 => reinterpret3_output_port_net,
    out_5 => reinterpret4_output_port_net,
    out_6 => reinterpret5_output_port_net,
    out_7 => reinterpret6_output_port_net,
    out_8 => reinterpret7_output_port_net,
    out_9 => reinterpret8_output_port_net,
    out_10 => reinterpret9_output_port_net,
    out_11 => reinterpret10_output_port_net,
    out_12 => reinterpret11_output_port_net,
    out_13 => reinterpret12_output_port_net,
    out_14 => reinterpret13_output_port_net,
    out_15 => reinterpret14_output_port_net,
    out_16 => reinterpret15_output_port_net
  );
  vector_slice_im : entity xil_defaultlib.ssr_16x16_vector_slice_im 
  port map (
    in_1 => slice0_y_net_x1,
    in_2 => slice1_y_net_x1,
    in_3 => slice2_y_net_x1,
    in_4 => slice3_y_net_x1,
    in_5 => slice4_y_net_x1,
    in_6 => slice5_y_net_x1,
    in_7 => slice6_y_net_x1,
    in_8 => slice7_y_net_x1,
    in_9 => slice8_y_net_x1,
    in_10 => slice9_y_net_x1,
    in_11 => slice10_y_net_x1,
    in_12 => slice11_y_net_x1,
    in_13 => slice12_y_net_x1,
    in_14 => slice13_y_net_x1,
    in_15 => slice14_y_net_x1,
    in_16 => slice15_y_net_x1,
    out_1 => slice0_y_net_x0,
    out_2 => slice1_y_net_x0,
    out_3 => slice2_y_net_x0,
    out_4 => slice3_y_net_x0,
    out_5 => slice4_y_net_x0,
    out_6 => slice5_y_net_x0,
    out_7 => slice6_y_net_x0,
    out_8 => slice7_y_net_x0,
    out_9 => slice8_y_net_x0,
    out_10 => slice9_y_net_x0,
    out_11 => slice10_y_net_x0,
    out_12 => slice11_y_net_x0,
    out_13 => slice12_y_net_x0,
    out_14 => slice13_y_net_x0,
    out_15 => slice14_y_net_x0,
    out_16 => slice15_y_net_x0
  );
  vector_slice_re : entity xil_defaultlib.ssr_16x16_vector_slice_re 
  port map (
    in_1 => slice0_y_net_x1,
    in_2 => slice1_y_net_x1,
    in_3 => slice2_y_net_x1,
    in_4 => slice3_y_net_x1,
    in_5 => slice4_y_net_x1,
    in_6 => slice5_y_net_x1,
    in_7 => slice6_y_net_x1,
    in_8 => slice7_y_net_x1,
    in_9 => slice8_y_net_x1,
    in_10 => slice9_y_net_x1,
    in_11 => slice10_y_net_x1,
    in_12 => slice11_y_net_x1,
    in_13 => slice12_y_net_x1,
    in_14 => slice13_y_net_x1,
    in_15 => slice14_y_net_x1,
    in_16 => slice15_y_net_x1,
    out_1 => slice0_y_net,
    out_2 => slice1_y_net,
    out_3 => slice2_y_net,
    out_4 => slice3_y_net,
    out_5 => slice4_y_net,
    out_6 => slice5_y_net,
    out_7 => slice6_y_net,
    out_8 => slice7_y_net,
    out_9 => slice8_y_net,
    out_10 => slice9_y_net,
    out_11 => slice10_y_net,
    out_12 => slice11_y_net,
    out_13 => slice12_y_net,
    out_14 => slice13_y_net,
    out_15 => slice14_y_net,
    out_16 => slice15_y_net
  );
  vector2scalar : entity xil_defaultlib.ssr_16x16_vector2scalar 
  port map (
    i_1 => delay0_q_net,
    i_2 => delay1_q_net,
    i_3 => delay2_q_net,
    i_4 => delay3_q_net,
    i_5 => delay4_q_net,
    i_6 => delay5_q_net,
    i_7 => delay6_q_net,
    i_8 => delay7_q_net,
    i_9 => delay8_q_net,
    i_10 => delay9_q_net,
    i_11 => delay10_q_net,
    i_12 => delay11_q_net,
    i_13 => delay12_q_net,
    i_14 => delay13_q_net,
    i_15 => delay14_q_net,
    i_16 => delay15_q_net,
    o => concat1_y_net
  );
  delay : entity xil_defaultlib.ssr_16x16_xldelay 
  generic map (
    latency => 4,
    reg_retiming => 0,
    reset => 0,
    width => 1
  )
  port map (
    en => '1',
    rst => '0',
    d => i_valid_net,
    clk => clk_net,
    ce => ce_net,
    q => delay_q_net
  );
  delay1 : entity xil_defaultlib.ssr_16x16_xldelay 
  generic map (
    latency => 4,
    reg_retiming => 0,
    reset => 0,
    width => 4
  )
  port map (
    en => '1',
    rst => '0',
    d => i_scale_net,
    clk => clk_net,
    ce => ce_net,
    q => delay1_q_net_x0
  );
  test_systolicfft_vhdl_black_box : entity xil_defaultlib.WRAPPER_VECTOR_FFT_a515bebe10164f5321a08af5f4e8e30f 
  generic map (
    BRAM_THRESHOLD => 258,
    DSP48E => 2,
    I_high => -2,
    I_low => -17,
    L2N => 4,
    N => 16,
    O_high => 9,
    O_low => -17,
    SSR => 16,
    W_high => 1,
    W_low => -17
  )
  port map (
    i => concat1_y_net,
    vi => delay_q_net(0),
    si => delay1_q_net_x0,
    CLK => clk_net,
    CE => ce_net,
    o => test_systolicfft_vhdl_black_box_o_net,
    vo => test_systolicfft_vhdl_black_box_vo_net,
    so => test_systolicfft_vhdl_black_box_so_net
  );
end structural;
-- Generated from Simulink block ssr_16x16/i_im
library IEEE;
use IEEE.std_logic_1164.all;
library xil_defaultlib;
use xil_defaultlib.conv_pkg.all;
entity ssr_16x16_i_im is
  port (
    i_im_0 : in std_logic_vector( 16-1 downto 0 );
    i_im_1 : in std_logic_vector( 16-1 downto 0 );
    i_im_2 : in std_logic_vector( 16-1 downto 0 );
    i_im_3 : in std_logic_vector( 16-1 downto 0 );
    i_im_4 : in std_logic_vector( 16-1 downto 0 );
    i_im_5 : in std_logic_vector( 16-1 downto 0 );
    i_im_6 : in std_logic_vector( 16-1 downto 0 );
    i_im_7 : in std_logic_vector( 16-1 downto 0 );
    i_im_8 : in std_logic_vector( 16-1 downto 0 );
    i_im_9 : in std_logic_vector( 16-1 downto 0 );
    i_im_10 : in std_logic_vector( 16-1 downto 0 );
    i_im_11 : in std_logic_vector( 16-1 downto 0 );
    i_im_12 : in std_logic_vector( 16-1 downto 0 );
    i_im_13 : in std_logic_vector( 16-1 downto 0 );
    i_im_14 : in std_logic_vector( 16-1 downto 0 );
    i_im_15 : in std_logic_vector( 16-1 downto 0 )
  );
end ssr_16x16_i_im;
architecture structural of ssr_16x16_i_im is 
  signal i_im_6_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_11_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_12_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_4_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_13_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_5_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_7_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_1_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_2_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_3_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_8_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_9_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_10_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_14_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_0_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_15_net : std_logic_vector( 16-1 downto 0 );
begin
  i_im_0_net <= i_im_0;
  i_im_1_net <= i_im_1;
  i_im_2_net <= i_im_2;
  i_im_3_net <= i_im_3;
  i_im_4_net <= i_im_4;
  i_im_5_net <= i_im_5;
  i_im_6_net <= i_im_6;
  i_im_7_net <= i_im_7;
  i_im_8_net <= i_im_8;
  i_im_9_net <= i_im_9;
  i_im_10_net <= i_im_10;
  i_im_11_net <= i_im_11;
  i_im_12_net <= i_im_12;
  i_im_13_net <= i_im_13;
  i_im_14_net <= i_im_14;
  i_im_15_net <= i_im_15;
end structural;
-- Generated from Simulink block ssr_16x16/i_re
library IEEE;
use IEEE.std_logic_1164.all;
library xil_defaultlib;
use xil_defaultlib.conv_pkg.all;
entity ssr_16x16_i_re is
  port (
    i_re_0 : in std_logic_vector( 16-1 downto 0 );
    i_re_1 : in std_logic_vector( 16-1 downto 0 );
    i_re_2 : in std_logic_vector( 16-1 downto 0 );
    i_re_3 : in std_logic_vector( 16-1 downto 0 );
    i_re_4 : in std_logic_vector( 16-1 downto 0 );
    i_re_5 : in std_logic_vector( 16-1 downto 0 );
    i_re_6 : in std_logic_vector( 16-1 downto 0 );
    i_re_7 : in std_logic_vector( 16-1 downto 0 );
    i_re_8 : in std_logic_vector( 16-1 downto 0 );
    i_re_9 : in std_logic_vector( 16-1 downto 0 );
    i_re_10 : in std_logic_vector( 16-1 downto 0 );
    i_re_11 : in std_logic_vector( 16-1 downto 0 );
    i_re_12 : in std_logic_vector( 16-1 downto 0 );
    i_re_13 : in std_logic_vector( 16-1 downto 0 );
    i_re_14 : in std_logic_vector( 16-1 downto 0 );
    i_re_15 : in std_logic_vector( 16-1 downto 0 )
  );
end ssr_16x16_i_re;
architecture structural of ssr_16x16_i_re is 
  signal i_re_4_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_1_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_10_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_9_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_11_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_12_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_15_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_0_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_3_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_6_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_5_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_2_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_14_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_8_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_13_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_7_net : std_logic_vector( 16-1 downto 0 );
begin
  i_re_0_net <= i_re_0;
  i_re_1_net <= i_re_1;
  i_re_2_net <= i_re_2;
  i_re_3_net <= i_re_3;
  i_re_4_net <= i_re_4;
  i_re_5_net <= i_re_5;
  i_re_6_net <= i_re_6;
  i_re_7_net <= i_re_7;
  i_re_8_net <= i_re_8;
  i_re_9_net <= i_re_9;
  i_re_10_net <= i_re_10;
  i_re_11_net <= i_re_11;
  i_re_12_net <= i_re_12;
  i_re_13_net <= i_re_13;
  i_re_14_net <= i_re_14;
  i_re_15_net <= i_re_15;
end structural;
-- Generated from Simulink block ssr_16x16_struct
library IEEE;
use IEEE.std_logic_1164.all;
library xil_defaultlib;
use xil_defaultlib.conv_pkg.all;
entity ssr_16x16_struct is
  port (
    i_scale : in std_logic_vector( 4-1 downto 0 );
    i_valid : in std_logic_vector( 1-1 downto 0 );
    i_im_0 : in std_logic_vector( 16-1 downto 0 );
    i_im_1 : in std_logic_vector( 16-1 downto 0 );
    i_im_2 : in std_logic_vector( 16-1 downto 0 );
    i_im_3 : in std_logic_vector( 16-1 downto 0 );
    i_im_4 : in std_logic_vector( 16-1 downto 0 );
    i_im_5 : in std_logic_vector( 16-1 downto 0 );
    i_im_6 : in std_logic_vector( 16-1 downto 0 );
    i_im_7 : in std_logic_vector( 16-1 downto 0 );
    i_im_8 : in std_logic_vector( 16-1 downto 0 );
    i_im_9 : in std_logic_vector( 16-1 downto 0 );
    i_im_10 : in std_logic_vector( 16-1 downto 0 );
    i_im_11 : in std_logic_vector( 16-1 downto 0 );
    i_im_12 : in std_logic_vector( 16-1 downto 0 );
    i_im_13 : in std_logic_vector( 16-1 downto 0 );
    i_im_14 : in std_logic_vector( 16-1 downto 0 );
    i_im_15 : in std_logic_vector( 16-1 downto 0 );
    i_re_0 : in std_logic_vector( 16-1 downto 0 );
    i_re_1 : in std_logic_vector( 16-1 downto 0 );
    i_re_2 : in std_logic_vector( 16-1 downto 0 );
    i_re_3 : in std_logic_vector( 16-1 downto 0 );
    i_re_4 : in std_logic_vector( 16-1 downto 0 );
    i_re_5 : in std_logic_vector( 16-1 downto 0 );
    i_re_6 : in std_logic_vector( 16-1 downto 0 );
    i_re_7 : in std_logic_vector( 16-1 downto 0 );
    i_re_8 : in std_logic_vector( 16-1 downto 0 );
    i_re_9 : in std_logic_vector( 16-1 downto 0 );
    i_re_10 : in std_logic_vector( 16-1 downto 0 );
    i_re_11 : in std_logic_vector( 16-1 downto 0 );
    i_re_12 : in std_logic_vector( 16-1 downto 0 );
    i_re_13 : in std_logic_vector( 16-1 downto 0 );
    i_re_14 : in std_logic_vector( 16-1 downto 0 );
    i_re_15 : in std_logic_vector( 16-1 downto 0 );
    clk_1 : in std_logic;
    ce_1 : in std_logic;
    o_scale : out std_logic_vector( 4-1 downto 0 );
    o_valid : out std_logic_vector( 1-1 downto 0 );
    o_im_0 : out std_logic_vector( 27-1 downto 0 );
    o_im_1 : out std_logic_vector( 27-1 downto 0 );
    o_im_2 : out std_logic_vector( 27-1 downto 0 );
    o_im_3 : out std_logic_vector( 27-1 downto 0 );
    o_im_4 : out std_logic_vector( 27-1 downto 0 );
    o_im_5 : out std_logic_vector( 27-1 downto 0 );
    o_im_6 : out std_logic_vector( 27-1 downto 0 );
    o_im_7 : out std_logic_vector( 27-1 downto 0 );
    o_im_8 : out std_logic_vector( 27-1 downto 0 );
    o_im_9 : out std_logic_vector( 27-1 downto 0 );
    o_im_10 : out std_logic_vector( 27-1 downto 0 );
    o_im_11 : out std_logic_vector( 27-1 downto 0 );
    o_im_12 : out std_logic_vector( 27-1 downto 0 );
    o_im_13 : out std_logic_vector( 27-1 downto 0 );
    o_im_14 : out std_logic_vector( 27-1 downto 0 );
    o_im_15 : out std_logic_vector( 27-1 downto 0 );
    o_re_0 : out std_logic_vector( 27-1 downto 0 );
    o_re_1 : out std_logic_vector( 27-1 downto 0 );
    o_re_2 : out std_logic_vector( 27-1 downto 0 );
    o_re_3 : out std_logic_vector( 27-1 downto 0 );
    o_re_4 : out std_logic_vector( 27-1 downto 0 );
    o_re_5 : out std_logic_vector( 27-1 downto 0 );
    o_re_6 : out std_logic_vector( 27-1 downto 0 );
    o_re_7 : out std_logic_vector( 27-1 downto 0 );
    o_re_8 : out std_logic_vector( 27-1 downto 0 );
    o_re_9 : out std_logic_vector( 27-1 downto 0 );
    o_re_10 : out std_logic_vector( 27-1 downto 0 );
    o_re_11 : out std_logic_vector( 27-1 downto 0 );
    o_re_12 : out std_logic_vector( 27-1 downto 0 );
    o_re_13 : out std_logic_vector( 27-1 downto 0 );
    o_re_14 : out std_logic_vector( 27-1 downto 0 );
    o_re_15 : out std_logic_vector( 27-1 downto 0 )
  );
end ssr_16x16_struct;
architecture structural of ssr_16x16_struct is 
  signal i_im_6_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_7_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_8_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_9_net : std_logic_vector( 16-1 downto 0 );
  signal i_scale_net : std_logic_vector( 4-1 downto 0 );
  signal i_im_0_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_4_net : std_logic_vector( 16-1 downto 0 );
  signal test_systolicfft_vhdl_black_box_vo_net : std_logic_vector( 1-1 downto 0 );
  signal test_systolicfft_vhdl_black_box_so_net : std_logic_vector( 4-1 downto 0 );
  signal i_im_3_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_1_net : std_logic_vector( 16-1 downto 0 );
  signal i_valid_net : std_logic_vector( 1-1 downto 0 );
  signal i_im_2_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_5_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_11_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_1_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_8_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_9_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_15_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_3_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret5_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal i_re_2_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret6_output_port_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal i_im_10_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret0_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal i_re_6_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret4_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret8_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret1_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret9_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret7_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal i_im_12_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_14_net : std_logic_vector( 16-1 downto 0 );
  signal i_im_13_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_11_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_0_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_5_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_7_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_12_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret3_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal i_re_13_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_14_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_4_net : std_logic_vector( 16-1 downto 0 );
  signal i_re_10_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret2_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal i_im_15_net : std_logic_vector( 16-1 downto 0 );
  signal reinterpret9_output_port_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal reinterpret10_output_port_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal clk_net : std_logic;
  signal reinterpret15_output_port_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal reinterpret12_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret4_output_port_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal reinterpret5_output_port_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal reinterpret6_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret14_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret2_output_port_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal reinterpret11_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret3_output_port_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal reinterpret7_output_port_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal reinterpret12_output_port_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal reinterpret15_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret8_output_port_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal reinterpret0_output_port_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal reinterpret11_output_port_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal reinterpret13_output_port_net : std_logic_vector( 27-1 downto 0 );
  signal reinterpret1_output_port_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal reinterpret14_output_port_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal ce_net : std_logic;
  signal reinterpret13_output_port_net_x0 : std_logic_vector( 27-1 downto 0 );
  signal reinterpret10_output_port_net : std_logic_vector( 27-1 downto 0 );
begin
  i_scale_net <= i_scale;
  i_valid_net <= i_valid;
  o_scale <= test_systolicfft_vhdl_black_box_so_net;
  o_valid <= test_systolicfft_vhdl_black_box_vo_net;
  i_im_0_net <= i_im_0;
  i_im_1_net <= i_im_1;
  i_im_2_net <= i_im_2;
  i_im_3_net <= i_im_3;
  i_im_4_net <= i_im_4;
  i_im_5_net <= i_im_5;
  i_im_6_net <= i_im_6;
  i_im_7_net <= i_im_7;
  i_im_8_net <= i_im_8;
  i_im_9_net <= i_im_9;
  i_im_10_net <= i_im_10;
  i_im_11_net <= i_im_11;
  i_im_12_net <= i_im_12;
  i_im_13_net <= i_im_13;
  i_im_14_net <= i_im_14;
  i_im_15_net <= i_im_15;
  i_re_0_net <= i_re_0;
  i_re_1_net <= i_re_1;
  i_re_2_net <= i_re_2;
  i_re_3_net <= i_re_3;
  i_re_4_net <= i_re_4;
  i_re_5_net <= i_re_5;
  i_re_6_net <= i_re_6;
  i_re_7_net <= i_re_7;
  i_re_8_net <= i_re_8;
  i_re_9_net <= i_re_9;
  i_re_10_net <= i_re_10;
  i_re_11_net <= i_re_11;
  i_re_12_net <= i_re_12;
  i_re_13_net <= i_re_13;
  i_re_14_net <= i_re_14;
  i_re_15_net <= i_re_15;
  o_im_0 <= reinterpret0_output_port_net;
  o_im_1 <= reinterpret1_output_port_net;
  o_im_2 <= reinterpret2_output_port_net;
  o_im_3 <= reinterpret3_output_port_net;
  o_im_4 <= reinterpret4_output_port_net;
  o_im_5 <= reinterpret5_output_port_net;
  o_im_6 <= reinterpret6_output_port_net_x0;
  o_im_7 <= reinterpret7_output_port_net;
  o_im_8 <= reinterpret8_output_port_net;
  o_im_9 <= reinterpret9_output_port_net;
  o_im_10 <= reinterpret10_output_port_net;
  o_im_11 <= reinterpret11_output_port_net;
  o_im_12 <= reinterpret12_output_port_net;
  o_im_13 <= reinterpret13_output_port_net;
  o_im_14 <= reinterpret14_output_port_net;
  o_im_15 <= reinterpret15_output_port_net;
  o_re_0 <= reinterpret0_output_port_net_x0;
  o_re_1 <= reinterpret1_output_port_net_x0;
  o_re_2 <= reinterpret2_output_port_net_x0;
  o_re_3 <= reinterpret3_output_port_net_x0;
  o_re_4 <= reinterpret4_output_port_net_x0;
  o_re_5 <= reinterpret5_output_port_net_x0;
  o_re_6 <= reinterpret6_output_port_net;
  o_re_7 <= reinterpret7_output_port_net_x0;
  o_re_8 <= reinterpret8_output_port_net_x0;
  o_re_9 <= reinterpret9_output_port_net_x0;
  o_re_10 <= reinterpret10_output_port_net_x0;
  o_re_11 <= reinterpret11_output_port_net_x0;
  o_re_12 <= reinterpret12_output_port_net_x0;
  o_re_13 <= reinterpret13_output_port_net_x0;
  o_re_14 <= reinterpret14_output_port_net_x0;
  o_re_15 <= reinterpret15_output_port_net_x0;
  clk_net <= clk_1;
  ce_net <= ce_1;
  vector_fft : entity xil_defaultlib.ssr_16x16_vector_fft 
  port map (
    i_re_1 => i_re_0_net,
    i_im_1 => i_im_0_net,
    vi => i_valid_net,
    si => i_scale_net,
    i_re_2 => i_re_1_net,
    i_re_3 => i_re_2_net,
    i_re_4 => i_re_3_net,
    i_re_5 => i_re_4_net,
    i_re_6 => i_re_5_net,
    i_re_7 => i_re_6_net,
    i_re_8 => i_re_7_net,
    i_re_9 => i_re_8_net,
    i_re_10 => i_re_9_net,
    i_re_11 => i_re_10_net,
    i_re_12 => i_re_11_net,
    i_re_13 => i_re_12_net,
    i_re_14 => i_re_13_net,
    i_re_15 => i_re_14_net,
    i_re_16 => i_re_15_net,
    i_im_2 => i_im_1_net,
    i_im_3 => i_im_2_net,
    i_im_4 => i_im_3_net,
    i_im_5 => i_im_4_net,
    i_im_6 => i_im_5_net,
    i_im_7 => i_im_6_net,
    i_im_8 => i_im_7_net,
    i_im_9 => i_im_8_net,
    i_im_10 => i_im_9_net,
    i_im_11 => i_im_10_net,
    i_im_12 => i_im_11_net,
    i_im_13 => i_im_12_net,
    i_im_14 => i_im_13_net,
    i_im_15 => i_im_14_net,
    i_im_16 => i_im_15_net,
    clk_1 => clk_net,
    ce_1 => ce_net,
    o_re_1 => reinterpret0_output_port_net_x0,
    o_im_1 => reinterpret0_output_port_net,
    vo => test_systolicfft_vhdl_black_box_vo_net(0),
    so => test_systolicfft_vhdl_black_box_so_net,
    o_re_2 => reinterpret1_output_port_net_x0,
    o_re_3 => reinterpret2_output_port_net_x0,
    o_re_4 => reinterpret3_output_port_net_x0,
    o_re_5 => reinterpret4_output_port_net_x0,
    o_re_6 => reinterpret5_output_port_net_x0,
    o_re_7 => reinterpret6_output_port_net,
    o_re_8 => reinterpret7_output_port_net_x0,
    o_re_9 => reinterpret8_output_port_net_x0,
    o_re_10 => reinterpret9_output_port_net_x0,
    o_re_11 => reinterpret10_output_port_net_x0,
    o_re_12 => reinterpret11_output_port_net_x0,
    o_re_13 => reinterpret12_output_port_net_x0,
    o_re_14 => reinterpret13_output_port_net_x0,
    o_re_15 => reinterpret14_output_port_net_x0,
    o_re_16 => reinterpret15_output_port_net_x0,
    o_im_2 => reinterpret1_output_port_net,
    o_im_3 => reinterpret2_output_port_net,
    o_im_4 => reinterpret3_output_port_net,
    o_im_5 => reinterpret4_output_port_net,
    o_im_6 => reinterpret5_output_port_net,
    o_im_7 => reinterpret6_output_port_net_x0,
    o_im_8 => reinterpret7_output_port_net,
    o_im_9 => reinterpret8_output_port_net,
    o_im_10 => reinterpret9_output_port_net,
    o_im_11 => reinterpret10_output_port_net,
    o_im_12 => reinterpret11_output_port_net,
    o_im_13 => reinterpret12_output_port_net,
    o_im_14 => reinterpret13_output_port_net,
    o_im_15 => reinterpret14_output_port_net,
    o_im_16 => reinterpret15_output_port_net
  );
  i_im : entity xil_defaultlib.ssr_16x16_i_im 
  port map (
    i_im_0 => i_im_0_net,
    i_im_1 => i_im_1_net,
    i_im_2 => i_im_2_net,
    i_im_3 => i_im_3_net,
    i_im_4 => i_im_4_net,
    i_im_5 => i_im_5_net,
    i_im_6 => i_im_6_net,
    i_im_7 => i_im_7_net,
    i_im_8 => i_im_8_net,
    i_im_9 => i_im_9_net,
    i_im_10 => i_im_10_net,
    i_im_11 => i_im_11_net,
    i_im_12 => i_im_12_net,
    i_im_13 => i_im_13_net,
    i_im_14 => i_im_14_net,
    i_im_15 => i_im_15_net
  );
  i_re : entity xil_defaultlib.ssr_16x16_i_re 
  port map (
    i_re_0 => i_re_0_net,
    i_re_1 => i_re_1_net,
    i_re_2 => i_re_2_net,
    i_re_3 => i_re_3_net,
    i_re_4 => i_re_4_net,
    i_re_5 => i_re_5_net,
    i_re_6 => i_re_6_net,
    i_re_7 => i_re_7_net,
    i_re_8 => i_re_8_net,
    i_re_9 => i_re_9_net,
    i_re_10 => i_re_10_net,
    i_re_11 => i_re_11_net,
    i_re_12 => i_re_12_net,
    i_re_13 => i_re_13_net,
    i_re_14 => i_re_14_net,
    i_re_15 => i_re_15_net
  );
end structural;
-- Generated from Simulink block 
library IEEE;
use IEEE.std_logic_1164.all;
library xil_defaultlib;
use xil_defaultlib.conv_pkg.all;
entity ssr_16x16_default_clock_driver is
  port (
    ssr_16x16_sysclk : in std_logic;
    ssr_16x16_sysce : in std_logic;
    ssr_16x16_sysclr : in std_logic;
    ssr_16x16_clk1 : out std_logic;
    ssr_16x16_ce1 : out std_logic
  );
end ssr_16x16_default_clock_driver;
architecture structural of ssr_16x16_default_clock_driver is 
begin
  clockdriver : entity xil_defaultlib.xlclockdriver 
  generic map (
    period => 1,
    log_2_period => 1
  )
  port map (
    sysclk => ssr_16x16_sysclk,
    sysce => ssr_16x16_sysce,
    sysclr => ssr_16x16_sysclr,
    clk => ssr_16x16_clk1,
    ce => ssr_16x16_ce1
  );
end structural;
-- Generated from Simulink block 
library IEEE;
use IEEE.std_logic_1164.all;
library xil_defaultlib;
use xil_defaultlib.conv_pkg.all;
entity ssr_16x16 is
  port (
    i_scale : in std_logic_vector( 4-1 downto 0 );
    i_valid : in std_logic_vector( 1-1 downto 0 );
    i_im_0 : in std_logic_vector( 16-1 downto 0 );
    i_im_1 : in std_logic_vector( 16-1 downto 0 );
    i_im_2 : in std_logic_vector( 16-1 downto 0 );
    i_im_3 : in std_logic_vector( 16-1 downto 0 );
    i_im_4 : in std_logic_vector( 16-1 downto 0 );
    i_im_5 : in std_logic_vector( 16-1 downto 0 );
    i_im_6 : in std_logic_vector( 16-1 downto 0 );
    i_im_7 : in std_logic_vector( 16-1 downto 0 );
    i_im_8 : in std_logic_vector( 16-1 downto 0 );
    i_im_9 : in std_logic_vector( 16-1 downto 0 );
    i_im_10 : in std_logic_vector( 16-1 downto 0 );
    i_im_11 : in std_logic_vector( 16-1 downto 0 );
    i_im_12 : in std_logic_vector( 16-1 downto 0 );
    i_im_13 : in std_logic_vector( 16-1 downto 0 );
    i_im_14 : in std_logic_vector( 16-1 downto 0 );
    i_im_15 : in std_logic_vector( 16-1 downto 0 );
    i_re_0 : in std_logic_vector( 16-1 downto 0 );
    i_re_1 : in std_logic_vector( 16-1 downto 0 );
    i_re_2 : in std_logic_vector( 16-1 downto 0 );
    i_re_3 : in std_logic_vector( 16-1 downto 0 );
    i_re_4 : in std_logic_vector( 16-1 downto 0 );
    i_re_5 : in std_logic_vector( 16-1 downto 0 );
    i_re_6 : in std_logic_vector( 16-1 downto 0 );
    i_re_7 : in std_logic_vector( 16-1 downto 0 );
    i_re_8 : in std_logic_vector( 16-1 downto 0 );
    i_re_9 : in std_logic_vector( 16-1 downto 0 );
    i_re_10 : in std_logic_vector( 16-1 downto 0 );
    i_re_11 : in std_logic_vector( 16-1 downto 0 );
    i_re_12 : in std_logic_vector( 16-1 downto 0 );
    i_re_13 : in std_logic_vector( 16-1 downto 0 );
    i_re_14 : in std_logic_vector( 16-1 downto 0 );
    i_re_15 : in std_logic_vector( 16-1 downto 0 );
    clk : in std_logic;
    o_scale : out std_logic_vector( 4-1 downto 0 );
    o_valid : out std_logic_vector( 1-1 downto 0 );
    o_im_0 : out std_logic_vector( 27-1 downto 0 );
    o_im_1 : out std_logic_vector( 27-1 downto 0 );
    o_im_2 : out std_logic_vector( 27-1 downto 0 );
    o_im_3 : out std_logic_vector( 27-1 downto 0 );
    o_im_4 : out std_logic_vector( 27-1 downto 0 );
    o_im_5 : out std_logic_vector( 27-1 downto 0 );
    o_im_6 : out std_logic_vector( 27-1 downto 0 );
    o_im_7 : out std_logic_vector( 27-1 downto 0 );
    o_im_8 : out std_logic_vector( 27-1 downto 0 );
    o_im_9 : out std_logic_vector( 27-1 downto 0 );
    o_im_10 : out std_logic_vector( 27-1 downto 0 );
    o_im_11 : out std_logic_vector( 27-1 downto 0 );
    o_im_12 : out std_logic_vector( 27-1 downto 0 );
    o_im_13 : out std_logic_vector( 27-1 downto 0 );
    o_im_14 : out std_logic_vector( 27-1 downto 0 );
    o_im_15 : out std_logic_vector( 27-1 downto 0 );
    o_re_0 : out std_logic_vector( 27-1 downto 0 );
    o_re_1 : out std_logic_vector( 27-1 downto 0 );
    o_re_2 : out std_logic_vector( 27-1 downto 0 );
    o_re_3 : out std_logic_vector( 27-1 downto 0 );
    o_re_4 : out std_logic_vector( 27-1 downto 0 );
    o_re_5 : out std_logic_vector( 27-1 downto 0 );
    o_re_6 : out std_logic_vector( 27-1 downto 0 );
    o_re_7 : out std_logic_vector( 27-1 downto 0 );
    o_re_8 : out std_logic_vector( 27-1 downto 0 );
    o_re_9 : out std_logic_vector( 27-1 downto 0 );
    o_re_10 : out std_logic_vector( 27-1 downto 0 );
    o_re_11 : out std_logic_vector( 27-1 downto 0 );
    o_re_12 : out std_logic_vector( 27-1 downto 0 );
    o_re_13 : out std_logic_vector( 27-1 downto 0 );
    o_re_14 : out std_logic_vector( 27-1 downto 0 );
    o_re_15 : out std_logic_vector( 27-1 downto 0 )
  );
end ssr_16x16;
architecture structural of ssr_16x16 is 
  attribute core_generation_info : string;
  attribute core_generation_info of structural : architecture is "ssr_16x16,sysgen_core_2019_2,{,compilation=HDL Netlist,block_icon_display=Default,family=zynquplusRFSOC,part=xczu28dr,speed=-2-e,package=ffvg1517,synthesis_language=vhdl,hdl_library=xil_defaultlib,synthesis_strategy=Vivado Synthesis Defaults,implementation_strategy=Vivado Implementation Defaults,testbench=0,interface_doc=0,ce_clr=0,clock_period=10,system_simulink_period=1,waveform_viewer=0,axilite_interface=0,ip_catalog_plugin=0,hwcosim_burst_mode=0,simulation_time=10,blackbox2=1,concat=17,delay=18,reinterpret=64,slice=48,}";
  signal clk_1_net : std_logic;
  signal ce_1_net : std_logic;
begin
  ssr_16x16_default_clock_driver : entity xil_defaultlib.ssr_16x16_default_clock_driver 
  port map (
    ssr_16x16_sysclk => clk,
    ssr_16x16_sysce => '1',
    ssr_16x16_sysclr => '0',
    ssr_16x16_clk1 => clk_1_net,
    ssr_16x16_ce1 => ce_1_net
  );
  ssr_16x16_struct : entity xil_defaultlib.ssr_16x16_struct 
  port map (
    i_scale => i_scale,
    i_valid => i_valid,
    i_im_0 => i_im_0,
    i_im_1 => i_im_1,
    i_im_2 => i_im_2,
    i_im_3 => i_im_3,
    i_im_4 => i_im_4,
    i_im_5 => i_im_5,
    i_im_6 => i_im_6,
    i_im_7 => i_im_7,
    i_im_8 => i_im_8,
    i_im_9 => i_im_9,
    i_im_10 => i_im_10,
    i_im_11 => i_im_11,
    i_im_12 => i_im_12,
    i_im_13 => i_im_13,
    i_im_14 => i_im_14,
    i_im_15 => i_im_15,
    i_re_0 => i_re_0,
    i_re_1 => i_re_1,
    i_re_2 => i_re_2,
    i_re_3 => i_re_3,
    i_re_4 => i_re_4,
    i_re_5 => i_re_5,
    i_re_6 => i_re_6,
    i_re_7 => i_re_7,
    i_re_8 => i_re_8,
    i_re_9 => i_re_9,
    i_re_10 => i_re_10,
    i_re_11 => i_re_11,
    i_re_12 => i_re_12,
    i_re_13 => i_re_13,
    i_re_14 => i_re_14,
    i_re_15 => i_re_15,
    clk_1 => clk_1_net,
    ce_1 => ce_1_net,
    o_scale => o_scale,
    o_valid => o_valid,
    o_im_0 => o_im_0,
    o_im_1 => o_im_1,
    o_im_2 => o_im_2,
    o_im_3 => o_im_3,
    o_im_4 => o_im_4,
    o_im_5 => o_im_5,
    o_im_6 => o_im_6,
    o_im_7 => o_im_7,
    o_im_8 => o_im_8,
    o_im_9 => o_im_9,
    o_im_10 => o_im_10,
    o_im_11 => o_im_11,
    o_im_12 => o_im_12,
    o_im_13 => o_im_13,
    o_im_14 => o_im_14,
    o_im_15 => o_im_15,
    o_re_0 => o_re_0,
    o_re_1 => o_re_1,
    o_re_2 => o_re_2,
    o_re_3 => o_re_3,
    o_re_4 => o_re_4,
    o_re_5 => o_re_5,
    o_re_6 => o_re_6,
    o_re_7 => o_re_7,
    o_re_8 => o_re_8,
    o_re_9 => o_re_9,
    o_re_10 => o_re_10,
    o_re_11 => o_re_11,
    o_re_12 => o_re_12,
    o_re_13 => o_re_13,
    o_re_14 => o_re_14,
    o_re_15 => o_re_15
  );
end structural;
