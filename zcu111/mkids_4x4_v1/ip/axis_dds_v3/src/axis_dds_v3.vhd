library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

-- This block integrates the TDM-muxed DDS.
-- Multi-lane expects IQ to be interleaved between channels.
--
-- Q[L-1] I[L-1] .. Q[1] I[1] Q[0] I[0].
--
entity axis_dds_v3 is
    Generic
    (
		-- Number of Lanes.
		L	: Integer := 4;

		-- Number of Channels.
		NCH	: Integer := 16

    );
	Port 
	( 
		-- AXI Slave I/F.
		s_axi_aclk		: in std_logic;
		s_axi_aresetn	: in std_logic;

		-- Write Address Channel.
		s_axi_awaddr	: in std_logic_vector(5 downto 0);
		s_axi_awprot	: in std_logic_vector(2 downto 0);
		s_axi_awvalid	: in std_logic;
		s_axi_awready	: out std_logic;

		-- Write Data Channel.
		s_axi_wdata		: in std_logic_vector(31 downto 0);
		s_axi_wstrb		: in std_logic_vector(3 downto 0);
		s_axi_wvalid	: in std_logic;
		s_axi_wready	: out std_logic;

		-- Write Response Channel.
		s_axi_bresp		: out std_logic_vector(1 downto 0);
		s_axi_bvalid	: out std_logic;
		s_axi_bready	: in std_logic;

		-- Read Address Channel.
		s_axi_araddr	: in std_logic_vector(5 downto 0);
		s_axi_arprot	: in std_logic_vector(2 downto 0);
		s_axi_arvalid	: in std_logic;
		s_axi_arready	: out std_logic;

		-- Read Data Channel.
		s_axi_rdata		: out std_logic_vector(31 downto 0);
		s_axi_rresp		: out std_logic_vector(1 downto 0);
		s_axi_rvalid	: out std_logic;
		s_axi_rready	: in std_logic;

		-- Reset and clock of AXIS I/Fs.
		aresetn			: in std_logic;
		aclk			: in std_logic;

		-- Master AXIS I/F for output data.
		m_axis_tdata	: out std_logic_vector(32*L-1 downto 0);
		m_axis_tlast	: out std_logic;
		m_axis_tvalid	: out std_logic
	);
end axis_dds_v3;

architecture rtl of axis_dds_v3 is

-- Number of bits of memory address map.
constant NCH_LOG2 		: Integer := Integer(ceil(log2(real(NCH))));

-- AXI Slave.
component axi_slv is
	Generic 
	(
		DATA_WIDTH	: integer	:= 32;
		ADDR_WIDTH	: integer	:= 6
	);
	Port 
	(
		aclk				: in std_logic;
		aresetn				: in std_logic;

		-- Write Address Channel.
		awaddr				: in std_logic_vector(ADDR_WIDTH-1 downto 0);
		awprot				: in std_logic_vector(2 downto 0);
		awvalid				: in std_logic;
		awready				: out std_logic;

		-- Write Data Channel.
		wdata				: in std_logic_vector(DATA_WIDTH-1 downto 0);
		wstrb				: in std_logic_vector((DATA_WIDTH/8)-1 downto 0);
		wvalid				: in std_logic;
		wready				: out std_logic;

		-- Write Response Channel.
		bresp				: out std_logic_vector(1 downto 0);
		bvalid				: out std_logic;
		bready				: in std_logic;

		-- Read Address Channel.
		araddr				: in std_logic_vector(ADDR_WIDTH-1 downto 0);
		arprot				: in std_logic_vector(2 downto 0);
		arvalid				: in std_logic;
		arready				: out std_logic;

		-- Read Data Channel.
		rdata				: out std_logic_vector(DATA_WIDTH-1 downto 0);
		rresp				: out std_logic_vector(1 downto 0);
		rvalid				: out std_logic;
		rready				: in std_logic;

		-- Registers.
		ADDR_NCHAN_REG		: out std_logic_vector (31 downto 0);
		ADDR_PINC_REG		: out std_logic_vector (31 downto 0);
		ADDR_PHASE_REG		: out std_logic_vector (31 downto 0);
		ADDR_GAIN_REG		: out std_logic_vector (31 downto 0);
		ADDR_CFG_REG		: out std_logic_vector (31 downto 0);
		ADDR_WE_REG			: out std_logic;
		DDS_SYNC_REG		: out std_logic
	);
end component;

-- Address decode block.
component addr_decode is
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
end component;

-- TDM-muxed DDS.
component dds_top
	Generic
	(
		-- Number of channels.
		NCH : Integer := 16
	);
	Port
	(
		-- Reset and clock.
		rstn		: in std_logic;
		clk			: in std_logic;

		-- Memory interface.
		mem_addr	: out std_logic_vector (15 downto 0);
		mem_do		: in std_logic_vector (63 downto 0);

		-- Output data.
		dout		: out std_logic_vector (31 downto 0);
		dout_last	: out std_logic;
		dout_valid	: out std_logic;

		-- Registers.
		SYNC_REG	: in std_logic
	);
end component;

-- Dual-port BRAM memory.
component bram_dp is
    Generic (
        -- Memory address size.
        N       : Integer := 16;
        -- Data width.
        B       : Integer := 16
    );
    Port ( 
        clka    : in STD_LOGIC;
        clkb    : in STD_LOGIC;
        ena     : in STD_LOGIC;
        enb     : in STD_LOGIC;
        wea     : in STD_LOGIC;
        web     : in STD_LOGIC;
        addra   : in STD_LOGIC_VECTOR (N-1 downto 0);
        addrb   : in STD_LOGIC_VECTOR (N-1 downto 0);
        dia     : in STD_LOGIC_VECTOR (B-1 downto 0);
        dib     : in STD_LOGIC_VECTOR (B-1 downto 0);
        doa     : out STD_LOGIC_VECTOR (B-1 downto 0);
        dob     : out STD_LOGIC_VECTOR (B-1 downto 0)
    );
end component;


-- Registers.
signal ADDR_NCHAN_REG	: std_logic_vector (31 downto 0);
signal ADDR_PINC_REG	: std_logic_vector (31 downto 0);
signal ADDR_PHASE_REG	: std_logic_vector (31 downto 0);
signal ADDR_GAIN_REG	: std_logic_vector (31 downto 0);
signal ADDR_CFG_REG		: std_logic_vector (31 downto 0);
signal ADDR_WE_REG		: std_logic;
signal DDS_SYNC_REG		: std_logic;

-- Internal decoded signals.
signal nchan_i			: std_logic_vector (31 downto 0);
signal pinc_i			: std_logic_vector (31 downto 0);
signal phase_i			: std_logic_vector (31 downto 0);
signal gain_i			: std_logic_vector (31 downto 0);
signal cfg_i			: std_logic_vector (31 downto 0);
signal we_i				: std_logic_vector (L-1 downto 0);

-- Memory address signals.
signal mem_addra		: std_logic_vector (NCH_LOG2-1 downto 0);
signal mem_dia			: std_logic_vector (63 downto 0);

type mem_addr_v_type is array (L-1 downto 0) of std_logic_vector (NCH_LOG2-1 downto 0);
type mem_addr_pad_v_type is array (L-1 downto 0) of std_logic_vector (15 downto 0);
type mem_data_v_type is array (L-1 downto 0) of std_logic_vector (63 downto 0);
signal mem_addrb		: mem_addr_v_type;
signal mem_addrb_pad	: mem_addr_pad_v_type;
signal mem_dob			: mem_data_v_type;

-- Internal m_axis_* signals.
signal m_axis_tvalid_i		: std_logic_vector (L-1 downto 0);
signal m_axis_tlast_i		: std_logic_vector (L-1 downto 0);

type data_v_type is array (L-1 downto 0) of std_logic_vector (31 downto 0);
signal data_in_v			: data_v_type;
signal data_out_v			: data_v_type;

begin

-- AXI Slave.
axi_slv_i : axi_slv
	Port map
	(
		aclk				=> s_axi_aclk	 		,
		aresetn				=> s_axi_aresetn		,

		-- Write Address Channel.
		awaddr				=> s_axi_awaddr 		,
		awprot				=> s_axi_awprot 		,
		awvalid				=> s_axi_awvalid		,
		awready				=> s_axi_awready		,

		-- Write Data Channel.
		wdata				=> s_axi_wdata	 		,
		wstrb				=> s_axi_wstrb	 		,
		wvalid				=> s_axi_wvalid 		,
		wready				=> s_axi_wready 		,

		-- Write Response Channel.
		bresp				=> s_axi_bresp			,
		bvalid				=> s_axi_bvalid			,
		bready				=> s_axi_bready			,

		-- Read Address Channel.
		araddr				=> s_axi_araddr 		,
		arprot				=> s_axi_arprot 		,
		arvalid				=> s_axi_arvalid		,
		arready				=> s_axi_arready		,

		-- Read Data Channel.
		rdata				=> s_axi_rdata 			,
		rresp				=> s_axi_rresp 			,
		rvalid				=> s_axi_rvalid			,
		rready				=> s_axi_rready			,

		-- Registers.
		ADDR_NCHAN_REG		=> ADDR_NCHAN_REG		,
		ADDR_PINC_REG		=> ADDR_PINC_REG		,
		ADDR_PHASE_REG		=> ADDR_PHASE_REG		,
		ADDR_GAIN_REG		=> ADDR_GAIN_REG		,
		ADDR_CFG_REG		=> ADDR_CFG_REG			,
		ADDR_WE_REG			=> ADDR_WE_REG			,
		DDS_SYNC_REG		=> DDS_SYNC_REG
	);

-- Address decode block.
addr_decode_i : addr_decode
    Generic map
    (
		-- Number of Lanes.
		L	=> L
    )
	Port map
	( 
		-- Reset and clock.
		rstn   		=> s_axi_aresetn	,
		clk			=> s_axi_aclk		,

		-- Outputs.
		nchan		=> nchan_i			,
		pinc		=> pinc_i			,
		phase		=> phase_i			,
		gain		=> gain_i			,
		cfg			=> cfg_i			,
		we			=> we_i				,

		-- Registers.
		NCHAN_REG	=> ADDR_NCHAN_REG	,
		PINC_REG	=> ADDR_PINC_REG	,
		PHASE_REG	=> ADDR_PHASE_REG	,
		GAIN_REG	=> ADDR_GAIN_REG	,
		CFG_REG		=> ADDR_CFG_REG		,
		WE_REG		=> ADDR_WE_REG
	);

-- Memory address/data.
mem_addra	<= nchan_i(NCH_LOG2-1 downto 0);
mem_dia		<= cfg_i(15 downto 0) & gain_i(15 downto 0) & phase_i(15 downto 0) & pinc_i(15 downto 0);

-- Generate.
GEN_lane: FOR I in 0 to L-1 generate

	begin
	-- Output data.
	m_axis_tdata((I+1)*32-1 downto I*32) <= data_out_v(I);
	
	-- TDM-muxed DDS + CIC block.
	dds_i : dds_top
		Generic map
		(
			-- Number of channels.
			NCH => NCH
		)
		Port map
		(
			-- Reset and clock.
			rstn		=> aresetn				,
			clk			=> aclk					,
	
			-- Memory interface.
			mem_addr	=> mem_addrb_pad(I)		,
			mem_do		=> mem_dob(I)			,
	
			-- Output data.
			dout		=> data_out_v(I)		,
			dout_last	=> m_axis_tlast_i(I)	,
			dout_valid	=> m_axis_tvalid_i(I)	,
	
			-- Registers.
			SYNC_REG	=> DDS_SYNC_REG	
		);

	-- Dual-port, dual-clock bram.
	bram_i : bram_dp
	    Generic map (
	        -- Memory address size.
	        N       => NCH_LOG2	,
	        -- Data width.
	        B       => 64
	    )
	    Port map ( 
	        clka    => s_axi_aclk		,
	        clkb    => aclk				,
	        ena     => '1'				,
	        enb     => '1'				,
	        wea     => we_i(I)			,
	        web     => '0'				,
	        addra   => mem_addra		,
	        addrb   => mem_addrb(I)		,
	        dia     => mem_dia			,
	        dib     => (others => '0')	,
	        doa     => open				,
	        dob     => mem_dob(I)
	    );

		-- Memory address.
		mem_addrb(I)	<= mem_addrb_pad(I)(NCH_LOG2-1 downto 0);
end generate GEN_lane;

-- Assign outputs.
m_axis_tlast	<= m_axis_tlast_i(0);
m_axis_tvalid	<= m_axis_tvalid_i(0);

end rtl;

