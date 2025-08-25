library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity axis_buffer is
    Generic
    (
		-- Address map of memory.
		N				: Integer := 8;
		-- Data width.
		B				: Integer := 16
    );
	Port
	(
		-- AXI-Lite Slave I/F.
		s_axi_aclk	 	: in std_logic;
		s_axi_aresetn	: in std_logic;

		s_axi_awaddr	: in std_logic_vector(7 downto 0);
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

		s_axi_araddr	: in std_logic_vector(7 downto 0);
		s_axi_arprot	: in std_logic_vector(2 downto 0);
		s_axi_arvalid	: in std_logic;
		s_axi_arready	: out std_logic;

		s_axi_rdata	 	: out std_logic_vector(31 downto 0);
		s_axi_rresp	 	: out std_logic_vector(1 downto 0);
		s_axi_rvalid	: out std_logic;
		s_axi_rready	: in std_logic;

        -- AXI Stream Slave I/F.
        s_axis_aclk	   	: in std_logic;
		s_axis_aresetn 	: in std_logic;        
		s_axis_tready	: out std_logic;
		s_axis_tdata	: in std_logic_vector(B-1 downto 0);
		s_axis_tstrb	: in std_logic_vector(B/8-1 downto 0);
		s_axis_tlast	: in std_logic;
		s_axis_tvalid	: in std_logic;
        
        -- AXI Stream Master I/F.
        m_axis_aclk	   	: in std_logic;
		m_axis_aresetn 	: in std_logic;        
        m_axis_tvalid  	: out std_logic;
		m_axis_tdata	: out std_logic_vector(B-1 downto 0);
		m_axis_tstrb 	: out std_logic_vector(B/8-1 downto 0);
		m_axis_tlast	: out std_logic;
		m_axis_tready	: in std_logic;

		-- Trigger.
		trigger			: in std_logic
	);
end axis_buffer;

architecture rtl of axis_buffer is

-- AXI-Lite Slave.
component axi_slv is
	Generic 
	(
		DATA_WIDTH	: integer	:= 32;
		ADDR_WIDTH	: integer	:= 8
	);
	Port 
	(
		aclk			: in std_logic;
		aresetn			: in std_logic;

		-- Write Address Channel.
		awaddr			: in std_logic_vector(ADDR_WIDTH-1 downto 0);
		awprot			: in std_logic_vector(2 downto 0);
		awvalid			: in std_logic;
		awready			: out std_logic;

		-- Write Data Channel.
		wdata			: in std_logic_vector(DATA_WIDTH-1 downto 0);
		wstrb			: in std_logic_vector((DATA_WIDTH/8)-1 downto 0);
		wvalid			: in std_logic;
		wready			: out std_logic;

		-- Write Response Channel.
		bresp			: out std_logic_vector(1 downto 0);
		bvalid			: out std_logic;
		bready			: in std_logic;

		-- Read Address Channel.
		araddr			: in std_logic_vector(ADDR_WIDTH-1 downto 0);
		arprot			: in std_logic_vector(2 downto 0);
		arvalid			: in std_logic;
		arready			: out std_logic;

		-- Read Data Channel.
		rdata			: out std_logic_vector(DATA_WIDTH-1 downto 0);
		rresp			: out std_logic_vector(1 downto 0);
		rvalid			: out std_logic;
		rready			: in std_logic;

		-- Output registers.
		DW_CAPTURE_REG	: out std_logic;
		DR_START_REG	: out std_logic
	);
end component;

-- buffer_rw.
component buffer_rw is
    Generic
    (
		-- Address map of memory.
		N				: Integer := 8;
		-- Data width.
		B				: Integer := 16
    );
    Port
    (
        -- AXI Stream Slave I/F.
        s_axis_aclk	    	: in std_logic;
		s_axis_aresetn  	: in std_logic;        
		s_axis_tready		: out std_logic;
		s_axis_tdata		: in std_logic_vector(B-1 downto 0);
		s_axis_tstrb		: in std_logic_vector(B/8-1 downto 0);
		s_axis_tlast		: in std_logic;
		s_axis_tvalid		: in std_logic;
        
        -- AXI Stream Master I/F.
        m_axis_aclk	    	: in std_logic;
		m_axis_aresetn  	: in std_logic;        
        m_axis_tvalid   	: out std_logic;
		m_axis_tdata		: out std_logic_vector(B-1 downto 0);
		m_axis_tstrb  		: out std_logic_vector(B/8-1 downto 0);
		m_axis_tlast		: out std_logic;
		m_axis_tready		: in std_logic;
        
		-- Trigger.
		trigger				: in std_logic;
		
        -- Registers.
		DW_CAPTURE_REG		: in std_logic;
		DR_START_REG		: in std_logic
		
    );
end component;

-- Output registers.
signal DW_CAPTURE_REG	: std_logic;
signal DR_START_REG		: std_logic;

begin

-- AXI-Lite Slave.
axi_slv_i : axi_slv
	Port map
	(
		aclk			=> s_axi_aclk	 	,
		aresetn			=> s_axi_aresetn	,

		-- Write Address Channel.
		awaddr			=> s_axi_awaddr		,
		awprot			=> s_axi_awprot		,
		awvalid			=> s_axi_awvalid	,
		awready			=> s_axi_awready	,

		-- Write Data Channel.
		wdata			=> s_axi_wdata	 	,
		wstrb			=> s_axi_wstrb	 	,
		wvalid			=> s_axi_wvalid		,
		wready			=> s_axi_wready		,

		-- Write Response Channel.
		bresp			=> s_axi_bresp	 	,
		bvalid			=> s_axi_bvalid		,
		bready			=> s_axi_bready		,

		-- Read Address Channel.
		araddr			=> s_axi_araddr		,
		arprot			=> s_axi_arprot		,
		arvalid			=> s_axi_arvalid	,
		arready			=> s_axi_arready	,

		-- Read Data Channel.
		rdata			=> s_axi_rdata	 	,
		rresp			=> s_axi_rresp	 	,
		rvalid			=> s_axi_rvalid		,
		rready			=> s_axi_rready		,

		-- Output registers.
		DW_CAPTURE_REG	=> DW_CAPTURE_REG	,
		DR_START_REG	=> DR_START_REG
	);

-- buffer_rw.
buffer_rw_i : buffer_rw
    Generic map
    (
		-- Address map of memory.
		N	=> N	,
		-- Data width.
		B	=> B
    )
    Port map
    (
        -- AXI Stream Slave I/F.
        s_axis_aclk	    	=> s_axis_aclk		,
		s_axis_aresetn  	=> s_axis_aresetn	,
		s_axis_tready		=> s_axis_tready	,
		s_axis_tdata		=> s_axis_tdata		,
		s_axis_tstrb		=> s_axis_tstrb		,
		s_axis_tlast		=> s_axis_tlast		,
		s_axis_tvalid		=> s_axis_tvalid	,
        
        -- AXI Stream Master I/F.
        m_axis_aclk	    	=> m_axis_aclk	   	,
		m_axis_aresetn  	=> m_axis_aresetn 	,
        m_axis_tvalid   	=> m_axis_tvalid  	,
		m_axis_tdata		=> m_axis_tdata		,
		m_axis_tstrb  		=> m_axis_tstrb 	,
		m_axis_tlast		=> m_axis_tlast		,
		m_axis_tready		=> m_axis_tready	,
        
		-- Trigger.
		trigger				=> trigger			,
		
        -- Registers.
		DW_CAPTURE_REG		=> DW_CAPTURE_REG	,
		DR_START_REG		=> DR_START_REG
    );

end rtl;

