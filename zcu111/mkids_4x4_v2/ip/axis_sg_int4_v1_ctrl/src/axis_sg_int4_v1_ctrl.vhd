library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity axis_sg_int4_v1_ctrl is
	Port 
	( 
		-- AXI Slave I/F for configuration.
		s_axi_aclk		: in std_logic;
		s_axi_aresetn	: in std_logic;

		s_axi_awaddr	: in std_logic_vector(5 downto 0);
		s_axi_awprot	: in std_logic_vector(2 downto 0);
		s_axi_awvalid	: in std_logic;
		s_axi_awready	: out std_logic;

		s_axi_wdata		: in std_logic_vector(31 downto 0);
		s_axi_wstrb		: in std_logic_vector(3 downto 0);
		s_axi_wvalid	: in std_logic;
		s_axi_wready	: out std_logic;

		s_axi_bresp		: out std_logic_vector(1 downto 0);
		s_axi_bvalid	: out std_logic;
		s_axi_bready	: in std_logic;

		s_axi_araddr	: in std_logic_vector(5 downto 0);
		s_axi_arprot	: in std_logic_vector(2 downto 0);
		s_axi_arvalid	: in std_logic;
		s_axi_arready	: out std_logic;

		s_axi_rdata		: out std_logic_vector(31 downto 0);
		s_axi_rresp		: out std_logic_vector(1 downto 0);
		s_axi_rvalid	: out std_logic;
		s_axi_rready	: in std_logic;

		-- AXIS Master for output data.
		m_axis_aresetn	: in std_logic;
		m_axis_aclk		: in std_logic;
		m_axis_tvalid	: out std_logic;
		m_axis_tready	: in std_logic;
		m_axis_tdata	: out std_logic_vector(87 downto 0)
	);
end axis_sg_int4_v1_ctrl;

architecture rtl of axis_sg_int4_v1_ctrl is

-- AXI Slave.
component axi_slv is
	Generic 
	(
		DATA_WIDTH	: integer	:= 32;
		ADDR_WIDTH	: integer	:= 6
	);
	Port 
	(
		aclk		: in std_logic;
		aresetn		: in std_logic;

		-- Write Address Channel.
		awaddr		: in std_logic_vector(ADDR_WIDTH-1 downto 0);
		awprot		: in std_logic_vector(2 downto 0);
		awvalid		: in std_logic;
		awready		: out std_logic;

		-- Write Data Channel.
		wdata		: in std_logic_vector(DATA_WIDTH-1 downto 0);
		wstrb		: in std_logic_vector((DATA_WIDTH/8)-1 downto 0);
		wvalid		: in std_logic;
		wready		: out std_logic;

		-- Write Response Channel.
		bresp		: out std_logic_vector(1 downto 0);
		bvalid		: out std_logic;
		bready		: in std_logic;

		-- Read Address Channel.
		araddr		: in std_logic_vector(ADDR_WIDTH-1 downto 0);
		arprot		: in std_logic_vector(2 downto 0);
		arvalid		: in std_logic;
		arready		: out std_logic;

		-- Read Data Channel.
		rdata		: out std_logic_vector(DATA_WIDTH-1 downto 0);
		rresp		: out std_logic_vector(1 downto 0);
		rvalid		: out std_logic;
		rready		: in std_logic;

		-- Registers.
		FREQ_REG	: out std_logic_vector (15 downto 0);
		PHASE_REG	: out std_logic_vector (15 downto 0);
		ADDR_REG  	: out std_logic_vector (15 downto 0);
		GAIN_REG	: out std_logic_vector (15 downto 0);
		NSAMP_REG	: out std_logic_vector (15 downto 0);
		OUTSEL_REG	: out std_logic_vector (1 downto 0);
		MODE_REG	: out std_logic;
		WE_REG		: out std_logic
	);
end component;

-- Write control.
component write_ctrl is
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
end component;

-- Registers.
signal FREQ_REG		: std_logic_vector (15 downto 0);
signal PHASE_REG	: std_logic_vector (15 downto 0);
signal ADDR_REG  	: std_logic_vector (15 downto 0);
signal GAIN_REG		: std_logic_vector (15 downto 0);
signal NSAMP_REG	: std_logic_vector (15 downto 0);
signal OUTSEL_REG	: std_logic_vector (1 downto 0);
signal MODE_REG		: std_logic;
signal WE_REG		: std_logic;


begin

-- AXI Slave.
axi_slv_i : axi_slv
	Port map
	(
		aclk		=> s_axi_aclk	 	,
		aresetn		=> s_axi_aresetn	,

		-- Write Address Channel.
		awaddr		=> s_axi_awaddr 	,
		awprot		=> s_axi_awprot 	,
		awvalid		=> s_axi_awvalid	,
		awready		=> s_axi_awready	,

		-- Write Data Channel.
		wdata		=> s_axi_wdata		,
		wstrb		=> s_axi_wstrb		,
		wvalid		=> s_axi_wvalid	    ,
		wready		=> s_axi_wready		,

		-- Write Response Channel.
		bresp		=> s_axi_bresp		,
		bvalid		=> s_axi_bvalid		,
		bready		=> s_axi_bready		,

		-- Read Address Channel.
		araddr		=> s_axi_araddr 	,
		arprot		=> s_axi_arprot 	,
		arvalid		=> s_axi_arvalid	,
		arready		=> s_axi_arready	,

		-- Read Data Channel.
		rdata		=> s_axi_rdata		,
		rresp		=> s_axi_rresp		,
		rvalid		=> s_axi_rvalid		,
		rready		=> s_axi_rready		,

		-- Registers.
		FREQ_REG	=> FREQ_REG			,
		PHASE_REG	=> PHASE_REG		,
		ADDR_REG  	=> ADDR_REG  		,
		GAIN_REG	=> GAIN_REG			,
		NSAMP_REG	=> NSAMP_REG		,
		OUTSEL_REG	=> OUTSEL_REG		,
		MODE_REG	=> MODE_REG			,
		WE_REG		=> WE_REG
	);

-- Write control.
write_ctrl_i : write_ctrl
	Port map
	( 
		-- Reset and clodk.
		clk				=> m_axis_aclk		,
		rstn			=> m_axis_aresetn	,

		-- AXIS Master for output data.
		m_axis_tvalid	=> m_axis_tvalid	,
		m_axis_tready	=> m_axis_tready	,
		m_axis_tdata	=> m_axis_tdata		,

		-- Registers.
		FREQ_REG		=> FREQ_REG			,
		PHASE_REG		=> PHASE_REG		,
		ADDR_REG  		=> ADDR_REG  		,
		GAIN_REG		=> GAIN_REG			,
		NSAMP_REG		=> NSAMP_REG		,
		OUTSEL_REG		=> OUTSEL_REG		,
		MODE_REG		=> MODE_REG			,
		WE_REG			=> WE_REG
	);

end rtl;

