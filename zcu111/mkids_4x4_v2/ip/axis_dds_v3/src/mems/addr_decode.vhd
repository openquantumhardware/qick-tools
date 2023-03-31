library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity addr_decode is
    Generic
    (
		-- Number of Lanes.
		L	: Integer := 4
    );
	Port 
	( 
		-- Reset and clock.
		rstn   		: in std_logic;
		clk			: in std_logic;

		-- Outputs.
		nchan		: out std_logic_vector (31 downto 0);
		pinc		: out std_logic_vector (31 downto 0);
		phase		: out std_logic_vector (31 downto 0);
		gain		: out std_logic_vector (31 downto 0);
		cfg			: out std_logic_vector (31 downto 0);
		we			: out std_logic_vector (L-1 downto 0);

		-- Registers.
		NCHAN_REG	: in std_logic_vector (31 downto 0);
		PINC_REG	: in std_logic_vector (31 downto 0);
		PHASE_REG	: in std_logic_vector (31 downto 0);
		GAIN_REG	: in std_logic_vector (31 downto 0);
		CFG_REG		: in std_logic_vector (31 downto 0);
		WE_REG		: in std_logic
	);
end addr_decode;

architecture rtl of addr_decode is

-- Number of bits of L.
constant L_LOG2 	: Integer := Integer(ceil(log2(real(L))));

-- Zeros to extend address high.
signal zeros		: std_logic_vector (L_LOG2-1 downto 0) := (others => '0');

-- Lower address for lane decoding.
signal addr_low_i	: std_logic_vector (L_LOG2-1 downto 0);
signal addr_low_r	: std_logic_vector (L_LOG2-1 downto 0);

-- Internal nchan signal.
signal nchan_i		: std_logic_vector (31 downto 0);
signal nchan_r		: std_logic_vector (31 downto 0);

-- Internal pinc signal.
signal pinc_i		: std_logic_vector (31 downto 0);
signal pinc_r		: std_logic_vector (31 downto 0);

-- Internal phase signal.
signal phase_i		: std_logic_vector (31 downto 0);
signal phase_r		: std_logic_vector (31 downto 0);

-- Internal gain signal.
signal gain_i		: std_logic_vector (31 downto 0);
signal gain_r		: std_logic_vector (31 downto 0);

-- Internal cfg signal.
signal cfg_i		: std_logic_vector (31 downto 0);
signal cfg_r		: std_logic_vector (31 downto 0);

-- Internal muxed write enable.
signal we_i			: std_logic_vector (L-1 downto 0);
signal we_r			: std_logic_vector (L-1 downto 0);

begin

-- Registers.
process (clk)
begin
	if ( rising_edge(clk) ) then
		if ( rstn = '0' ) then
			addr_low_r	<= (others => '0');
			nchan_r		<= (others => '0');
			pinc_r		<= (others => '0');
			phase_r		<= (others => '0');
			gain_r		<= (others => '0');
			cfg_r		<= (others => '0');
			we_r		<= (others => '0');
		else
			addr_low_r	<= addr_low_i;
			nchan_r		<= nchan_i;
			pinc_r		<= pinc_i;
			phase_r		<= phase_i;
			gain_r		<= gain_i;
			cfg_r		<= cfg_i;
			we_r		<= we_i;
		end if;
	end if;
end process;

-- Address decoding.
addr_low_i 	<= NCHAN_REG (L_LOG2-1 downto 0);
nchan_i 	<= zeros & NCHAN_REG (31 downto L_LOG2);

-- Phase increment.
pinc_i		<= PINC_REG;

-- Initial phase.
phase_i		<= PHASE_REG;

-- Gain.
gain_i		<= GAIN_REG;

-- Cfg.
cfg_i		<= CFG_REG;

GEN_we: for I in 0 to L-1 generate
	-- Internal muxed write enable.
	we_i(I)	<= 	WE_REG when addr_low_i = std_logic_vector(to_unsigned(I,addr_low_i'length)) else
				'0';
end generate GEN_we;

-- Assign outputs.
nchan	<= nchan_r;
pinc	<= pinc_r;
phase	<= phase_r;
gain	<= gain_r;
cfg		<= cfg_r;
we		<= we_r;

end rtl;

