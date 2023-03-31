library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity write_ctrl is
	Port 
	( 
		-- Reset and clodk.
		clk				: in std_logic;
		rstn			: in std_logic;

		-- AXIS Master for output data.
		m_axis_tvalid	: out std_logic;
		m_axis_tready	: in std_logic;
		m_axis_tdata	: out std_logic_vector(87 downto 0);

		-- Registers.
		FREQ_REG		: in std_logic_vector (15 downto 0);
		PHASE_REG		: in std_logic_vector (15 downto 0);
		ADDR_REG  		: in std_logic_vector (15 downto 0);
		GAIN_REG		: in std_logic_vector (15 downto 0);
		NSAMP_REG		: in std_logic_vector (15 downto 0);
		OUTSEL_REG		: in std_logic_vector (1 downto 0);
		MODE_REG		: in std_logic;
		WE_REG			: in std_logic
	);
end write_ctrl;

architecture rtl of write_ctrl is

-- Synchronizer.
component synchronizer_n is 
	generic (
		N : Integer := 2
	);
	port (
		rstn	    : in std_logic;
		clk 		: in std_logic;
		data_in		: in std_logic;
		data_out	: out std_logic
	);
end component;

-- State machine.
type fsm_state is ( INIT_ST	,
                    READ_ST	,
                    WRITE_ST,
					END_ST	);
signal state : fsm_state;

-- State signals.
signal read_state		: std_logic;
signal write_state		: std_logic;

-- Synced signals.
signal WE_REG_resync	: std_logic;

-- Registers.
signal freq_r			: std_logic_vector (15 downto 0);
signal phase_r			: std_logic_vector (15 downto 0);
signal addr_r			: std_logic_vector (15 downto 0);
signal gain_r			: std_logic_vector (15 downto 0);
signal nsamp_r			: std_logic_vector (15 downto 0);
signal outsel_r			: std_logic_vector (1 downto 0);
signal mode_r			: std_logic;
signal zeros5_r			: std_logic_vector (4 downto 0);

begin

-- WE_REG_resync
WE_REG_resync_i : synchronizer_n
	generic map (
		N => 2
	)
	port map (
		rstn	    => rstn				,
		clk 		=> clk				,
		data_in		=> WE_REG			,
		data_out	=> WE_REG_resync
	);

-- Registers.
process (clk)
begin
	if ( rising_edge(clk) ) then
		if ( rstn = '0' ) then
			-- Registers.
			freq_r		<= (others => '0');
			phase_r		<= (others => '0');
			addr_r		<= (others => '0');
			gain_r		<= (others => '0');
			nsamp_r		<= (others => '0');
			outsel_r	<= (others => '0');
			mode_r		<= '0';
			zeros5_r	<= (others => '0');

			-- State register.
			state <= INIT_ST;
		else
			-- Registers.
			if ( read_state = '1' ) then
				freq_r		<= FREQ_REG;
				phase_r		<= PHASE_REG;
				addr_r		<= ADDR_REG;
				gain_r		<= GAIN_REG;
				nsamp_r		<= NSAMP_REG;
				outsel_r	<= OUTSEL_REG;
				mode_r		<= MODE_REG;
			end if;

			-- State register.
			case (state) is
				when INIT_ST =>
					if ( WE_REG_resync = '1' ) then
						state <= READ_ST;
					end if;

				when READ_ST =>
					state <= WRITE_ST;

				when WRITE_ST =>
					if ( m_axis_tready = '1' ) then
						state <= END_ST;
					end if;

				when END_ST =>
					if ( WE_REG_resync = '0' ) then
						state <= INIT_ST;
					end if;

			end case;
		end if;
	end if;
end process;

-- Output logic.
process (state)
begin
read_state	<= '0';
write_state	<= '0';
	case (state) is
		when INIT_ST =>
	
		when READ_ST =>
			read_state	<= '1';
	
		when WRITE_ST =>
			write_state	<= '1';
	
		when END_ST =>
	end case;
end process;

-- Assign outputs.
m_axis_tvalid	<= write_state;
m_axis_tdata	<=	zeros5_r 	&
					mode_r 		& 
					outsel_r 	&
					nsamp_r		& 
					gain_r		& 
					addr_r		&
					phase_r		&
					freq_r;

end rtl;

