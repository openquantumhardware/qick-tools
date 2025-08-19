library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity buffer_rw is
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
end buffer_rw;

architecture rtl of buffer_rw is

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

-- Memory.
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

-- Data writer.
  component data_writer is
    Generic
    (
    -- Address map of memory.
      N				: Integer := 8;
    -- Data width.
      B				: Integer := 16
    );
    Port
    (
      rstn            : in std_logic;
      clk             : in std_logic;

        -- AXI Stream I/F.
      s_axis_tready	: out std_logic;
      s_axis_tdata	: in std_logic_vector(B-1 downto 0);				
      s_axis_tlast	: in std_logic;
      s_axis_tvalid	: in std_logic;

    -- Memory I/F.
      mem_en          : out std_logic;
      mem_we          : out std_logic;
      mem_addr        : out std_logic_vector (N-1 downto 0);
      mem_di          : out std_logic_vector (B-1 downto 0);

    -- Trigger.
      trigger			: in std_logic;

    -- Registers.
      CAPTURE_REG		: in std_logic
    );
  end component;

-- Data reader.
  component data_reader is
    Generic
    (
    -- Address map of memory.
      N				: Integer := 8;
    -- Data width.
      B				: Integer := 16
    );
    Port
    (
        -- Reset and clock.
      rstn        		: in std_logic;
      clk         		: in std_logic;

        -- Memory I/F.
      mem_en      		: out std_logic;
      mem_we      		: out std_logic;
      mem_addr    		: out std_logic_vector (N-1 downto 0);
      mem_dout    		: in std_logic_vector (B-1 downto 0);        

        -- Data out.
      dout        		: out std_logic_vector (B-1 downto 0);
      dready      		: in std_logic;
      dvalid      		: out std_logic;
      dlast               : out std_logic;

    -- Registers.
      START_REG			: in std_logic
    );
  end component;

-- Re-sync trigger and registers.
  signal trigger_resync		: std_logic;
  signal DW_CAPTURE_REG_resync: std_logic;
  signal DR_START_REG_resync	: std_logic;

-- Memory signals.
  signal ena     	: std_logic;
  signal wea     	: std_logic;
  signal addra   	: std_logic_vector (N-1 downto 0);
  signal dia     	: std_logic_vector (B-1 downto 0);
  signal doa     	: std_logic_vector (B-1 downto 0);

  signal enb     	: std_logic;
  signal web     	: std_logic;
  signal addrb   	: std_logic_vector (N-1 downto 0);
  signal dib     	: std_logic_vector (B-1 downto 0);
  signal dob		: std_logic_vector (B-1 downto 0);

begin

-- trigger_resync.
  trigger_resync_i :  synchronizer_n
  generic map (
                N	=> 2
              )
  port map (
             rstn	 	=> s_axis_aresetn,
             clk 		=> s_axis_aclk,
             data_in		=> trigger,
             data_out	=> trigger_resync
           );

-- DW_CAPTURE_REG_resync.
  DW_CAPTURE_REG_resync_i :  synchronizer_n
  generic map (
                N	=> 2
              )
  port map (
             rstn	 	=> s_axis_aresetn,
             clk 		=> s_axis_aclk,
             data_in		=> DW_CAPTURE_REG,
             data_out	=> DW_CAPTURE_REG_resync
           );

-- DR_START_REG_resync.
  DR_START_REG_resync_i :  synchronizer_n
  generic map (
                N	=> 2
              )
  port map (
             rstn	 	=> m_axis_aresetn,
             clk 		=> m_axis_aclk,
             data_in		=> DR_START_REG,
             data_out	=> DR_START_REG_resync
           );

-- Data writer.
  data_writer_i : data_writer
  Generic map
  (
    -- Address map of memory.
    N	=> N	,
    -- Data width.
    B	=> B
  )
  Port map
  (
    rstn            => s_axis_aresetn 	,
    clk             => s_axis_aclk		,

        -- AXI Stream I/F.
    s_axis_tready	=> s_axis_tready	,
    s_axis_tdata	=> s_axis_tdata		,
    s_axis_tlast	=> s_axis_tlast		,
    s_axis_tvalid	=> s_axis_tvalid	,

    -- Memory I/F.
    mem_en          => ena				,
    mem_we          => wea				,
    mem_addr        => addra			,
    mem_di          => dia				,

    -- Trigger.
    trigger			=> trigger_resync	,

    -- Registers.
    CAPTURE_REG		=> DW_CAPTURE_REG_resync
  );

-- Data reader.
  data_reader_i : data_reader
  Generic map
  (
    -- Address map of memory.
    N	=> N	,
    -- Data width.
    B	=> B
  )
  Port map
  (
        -- Reset and clock.
    rstn        		=> m_axis_aresetn	,
    clk         		=> m_axis_aclk		,

        -- Memory I/F.
    mem_en      		=> enb				,
    mem_we      		=> web				,
    mem_addr    		=> addrb			,
    mem_dout    		=> dob				,

        -- Data out.
    dout        		=> m_axis_tdata		,
    dready      		=> m_axis_tready	,
    dvalid      		=> m_axis_tvalid	,
    dlast               => m_axis_tlast		,

    -- Registers.
    START_REG			=> DR_START_REG_resync
  );

-- Memory.
  mem_i : bram_dp
  Generic map (
        -- Memory address size.
                N       => N	,
        -- Data width.
                B       => B
              )
  Port map ( 
             clka    => s_axis_aclk	,
             clkb    => m_axis_aclk	,
             ena     => ena			,
             enb     => enb			,
             wea     => wea			,
             web     => web			,
             addra   => addra		,
             addrb   => addrb		,
             dia     => dia			,
             dib     => dib			,
             doa     => doa			,
             dob     => dob
           );

-- Assign outputs.
  m_axis_tstrb <= (others => '1');

end rtl;

