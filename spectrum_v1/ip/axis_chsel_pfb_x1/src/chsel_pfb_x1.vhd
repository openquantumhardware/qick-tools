library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity chsel_pfb_x1 is
	Generic
	(
		-- Number of bits.
		B	: Integer := 16;
		-- FFT Size.
		N	: Integer := 4
	);
	Port
	(
		-- Clock and reset.
		aclk			: in std_logic;
		aresetn			: in std_logic;

		-- AXIS Slave I/F.
		s_axis_tdata	: in std_logic_vector (2*B*N-1 downto 0);
		s_axis_tuser	: in std_logic_vector (15 downto 0);
		s_axis_tlast	: in std_logic;
		s_axis_tvalid	: in std_logic;
		s_axis_tready	: out std_logic;

		-- AXIS Master I/F.
		m_axis_tdata	: out std_logic_vector(2*B-1 downto 0);
		m_axis_tuser	: out std_logic_vector (15 downto 0);
		m_axis_tlast	: out std_logic;
		m_axis_tvalid	: out std_logic;

		-- Registers.
		CHID_REG		: in std_logic_vector (31 downto 0)
	);
end chsel_pfb_x1;

architecture rtl of chsel_pfb_x1 is

-- Number of bits of N.
constant N_LOG2	: Integer := Integer(ceil(log2(real(N))));

-- Channel id.
signal chid_i	: unsigned (N_LOG2-1 downto 0);

-- Array of input samples.
type vect_t is array (N-1 downto 0) of std_logic_vector (B-1 downto 0);
signal di_vi 	: vect_t;
signal di_vq 	: vect_t;

-- Mux for data.
signal dout_mux	: std_logic_vector (2*B-1 downto 0);

-- Pipe registers.
signal din_r	: std_logic_vector (2*B*N-1 downto 0);
signal user_r	: std_logic_vector (15 downto 0);
signal user_rr	: std_logic_vector (15 downto 0);
signal last_r	: std_logic;
signal last_rr	: std_logic;
signal dout_r	: std_logic_vector (2*B-1 downto 0);
signal valid_r	: std_logic;
signal valid_rr	: std_logic;

begin

process ( aclk )
begin
	if ( rising_edge( aclk ) ) then
		if ( aresetn = '0' ) then
			-- Pipe registers.
			din_r		<= (others => '0');
			user_r		<= (others => '0');
			user_rr		<= (others => '0');
			last_r		<= '0';
			last_rr		<= '0';
			dout_r		<= (others => '0');
			valid_r		<= '0';
			valid_rr	<= '0';
		else
			-- Pipe registers.
			din_r		<= s_axis_tdata;
			user_r		<= s_axis_tuser;
			user_rr		<= user_r;
			last_r		<= s_axis_tlast;
			last_rr		<= last_r;
			dout_r		<= dout_mux;
			valid_r		<= s_axis_tvalid;
			valid_rr	<= valid_r;
		end if;
	end if;	
end process;

-- Slice CHID_REG.
chid_i	<= unsigned(CHID_REG(N_LOG2-1 downto 0));

-- Array of input samples.
GEN_SLICE: for I in 0 to N-1 generate
	di_vi(I) <= din_r	(I*2*B+B-1 		downto I*2*B	);
	di_vq(I) <= din_r	(I*2*B+2*B-1	downto I*2*B+B	);
end generate GEN_SLICE;

-- Mux for data/last.
dout_mux 	<= di_vq(to_integer(chid_i)) & di_vi(to_integer(chid_i));

-- Assign outputs.
s_axis_tready	<= '1';

m_axis_tdata	<= dout_r;
m_axis_tuser	<= user_rr;
m_axis_tlast	<= last_rr;
m_axis_tvalid	<= valid_rr;

end rtl;

