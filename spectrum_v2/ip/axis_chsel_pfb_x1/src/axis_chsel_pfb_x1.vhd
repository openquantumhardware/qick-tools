library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity axis_chsel_pfb_x1 is
	Generic
	(
		-- Number of bits.
		B	: Integer := 16;
		-- FFT Size.
		N	: Integer := 4
	);
	Port
	(
		-- AXI-Lite Slave I/F.
		s_axi_aclk	 	: in std_logic;
		s_axi_aresetn	: in std_logic;

		s_axi_awaddr	: in std_logic_vector(5 downto 0);
		s_axi_awprot	: in std_logic_vector(2 downto 0);
		s_axi_awvalid	: in std_logic;
		s_axi_awready	: out std_logic;

		s_axi_wdata	 	: in std_logic_vector(31 downto 0);
		s_axi_wstrb	 	: in std_logic_vector(3 downto 0);
		s_axi_wvalid	: in std_logic;
		s_axi_wready	: out std_logic;

		s_axi_bresp	 	: out std_logic_vector(1 downto 0);
		s_axi_bvalid	: out std_logic;
		s_axi_bready	: in std_logic;

		s_axi_araddr	: in std_logic_vector(5 downto 0);
		s_axi_arprot	: in std_logic_vector(2 downto 0);
		s_axi_arvalid	: in std_logic;
		s_axi_arready	: out std_logic;

		s_axi_rdata	 	: out std_logic_vector(31 downto 0);
		s_axi_rresp	 	: out std_logic_vector(1 downto 0);
		s_axi_rvalid	: out std_logic;
		s_axi_rready	: in std_logic;

		-- Clock and reset for s_axis_* and m_axis_*.
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
		m_axis_tvalid	: out std_logic
	);
end axis_chsel_pfb_x1;

architecture rtl of axis_chsel_pfb_x1 is

-- Synchronizer.
component synchronizer is 
	generic (
		NB : Integer := 2
	);
	port (
		i_clk 		: in std_logic;
		i_rstn	  : in std_logic;
		i_async		: in std_logic_vector(NB-1 downto 0);
		o_sync	 : out std_logic_vector(NB-1 downto 0)
	);
end component;

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
		CHID_REG	: out std_logic_vector (31 downto 0)
	);
end component;

-- Channel selection.
component chsel_pfb_x1 is
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
		s_axis_tdata	: in std_logic_vector(2*B*N-1 downto 0);
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
end component;

-- Registers.
signal CHID_REG		: std_logic_vector (31 downto 0);
signal chid_reg_sync		: std_logic_vector (31 downto 0);

begin

-- AXI Slave.
axi_slv_i : axi_slv
	Port map
	(
		aclk		=> s_axi_aclk	 	,
		aresetn		=> s_axi_aresetn	,

		-- Write Address Channel.
		awaddr		=> s_axi_awaddr		,
		awprot		=> s_axi_awprot		,
		awvalid		=> s_axi_awvalid	,
		awready		=> s_axi_awready	,

		-- Write Data Channel.
		wdata		=> s_axi_wdata	 	,
		wstrb		=> s_axi_wstrb	 	,
		wvalid		=> s_axi_wvalid		,
		wready		=> s_axi_wready		,

		-- Write Response Channel.
		bresp		=> s_axi_bresp	 	,
		bvalid		=> s_axi_bvalid		,
		bready		=> s_axi_bready		,

		-- Read Address Channel.
		araddr		=> s_axi_araddr		,
		arprot		=> s_axi_arprot		,
		arvalid		=> s_axi_arvalid	,
		arready		=> s_axi_arready	,

		-- Read Data Channel.
		rdata		=> s_axi_rdata	 	,
		rresp		=> s_axi_rresp	 	,
		rvalid		=> s_axi_rvalid		,
		rready		=> s_axi_rready		,

		-- Registers.
		CHID_REG	=> CHID_REG
	);

-- Synchronizer.
CHID_resync_i : synchronizer
  generic map(NB=>32)
	port map (
		i_rstn	  => aresetn	,
		i_clk 	=> aclk		,
		i_async		=> CHID_REG			,
		o_sync		=> chid_reg_sync
  );

-- Channel selection.
chsel_pfb_x1_i : chsel_pfb_x1
	Generic map
	(
		-- Number of bits.
		B	=> B	,
		-- FFT Size.
		N	=> N
	)
	Port map
	(
		-- Clock and reset.
		aclk			=> aclk				,
		aresetn			=> aresetn			,

		-- AXIS Slave I/F.
		s_axis_tdata	=> s_axis_tdata		,
		s_axis_tuser	=> s_axis_tuser		,
		s_axis_tlast	=> s_axis_tlast		,
		s_axis_tvalid	=> s_axis_tvalid	,
		s_axis_tready	=> s_axis_tready	,

		-- AXIS Master I/F.
		m_axis_tdata	=> m_axis_tdata		,
		m_axis_tuser	=> m_axis_tuser		,
		m_axis_tlast	=> m_axis_tlast		,
		m_axis_tvalid	=> m_axis_tvalid	,

		-- Registers.
		CHID_REG		=> chid_reg_sync
	);

end rtl;

