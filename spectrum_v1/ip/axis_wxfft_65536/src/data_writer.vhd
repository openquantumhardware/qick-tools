library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.MATH_REAL.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_writer is
    Generic
    (
        -- Memory size.
        N   : Integer := 16;
        -- Data width.
        B   : Integer := 16
    );
    Port
    (
        rstn            : in STD_LOGIC;
        clk             : in STD_LOGIC;
        
        -- AXI Stream I/F.
        s_axis_tready	: out std_logic;
		s_axis_tdata	: in std_logic_vector(B-1 downto 0);				
		s_axis_tvalid	: in std_logic;
		
		-- Memory I/F.
		mem_en          : out std_logic;
		mem_we          : out std_logic;
		mem_addr        : out std_logic_vector (N-1 downto 0);
		mem_di          : out std_logic_vector (B-1 downto 0);
		
		-- Registers.
		ADDR_REG  		: in std_logic_vector (31 downto 0);
		WE_REG			: in std_logic 
    );
end data_writer;

architecture rtl of data_writer is

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
type fsm_state is ( INIT_ST			,
                    READ_ADDR_ST	,
                    RW_TDATA_ST		);
signal state : fsm_state;

signal read_addr_state	: std_logic;
signal rw_tdata_state	: std_logic;

-- WE_REG_resync.
signal WE_REG_resync	: std_logic;

-- mem_we.
signal we_i				: std_logic;
signal we_r				: std_logic;
signal we_rr			: std_logic;
signal we_rrr			: std_logic;

-- Axis registers.
signal tdata_r	    	: std_logic_vector(B-1 downto 0);
signal tdata_rr	    	: std_logic_vector(B-1 downto 0);				
signal tdata_rrr    	: std_logic_vector(B-1 downto 0);
signal tvalid_r     	: std_logic;
signal tvalid_rr    	: std_logic;
signal tvalid_rrr   	: std_logic;

-- Counter.
signal cnt    			: unsigned (N-1 downto 0);
signal cnt_r  			: unsigned (N-1 downto 0);
signal cnt_rr  			: unsigned (N-1 downto 0);
signal cnt_rrr  		: unsigned (N-1 downto 0);

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

process (clk)
begin
	if ( rising_edge(clk) ) then
    	if (rstn = '0') then
			-- mem_we.
			we_r		<= '0';
			we_rr		<= '0';
			we_rrr		<= '0';

    	    -- Axis registers.
    	    tdata_r     <= (others => '0');				
    	    tdata_rr    <= (others => '0');
    	    tdata_rrr   <= (others => '0');
    	    tvalid_r    <= '0';
    	    tvalid_rr   <= '0';
    	    tvalid_rrr  <= '0';
    	            
    	    -- Counter.
    	    cnt   		<= (others => '0');
    	    cnt_r 		<= (others => '0');
    	    cnt_rr 		<= (others => '0');
    	    cnt_rrr		<= (others => '0');
    	else
			-- mem_we.
			we_r		<= we_i;
			we_rr		<= we_r;
			we_rrr		<= we_rr;

    	    -- Axis registers.
    	    tdata_r     	<= s_axis_tdata;				
    	    tdata_rr    	<= tdata_r;
    	    tdata_rrr   	<= tdata_rr;
    	    tvalid_r    	<= s_axis_tvalid;
    	    tvalid_rr   	<= tvalid_r;
    	    tvalid_rrr  	<= tvalid_rr;
    	    
    	    -- Counter.
    	    if ( read_addr_state = '1') then
    	        cnt <= to_unsigned(to_integer(unsigned(ADDR_REG)),cnt'length);            
    	    elsif ( rw_tdata_state = '1' and s_axis_tvalid = '1' ) then
    	        cnt <= cnt + 1;
    	    end if;
    	    cnt_r	<= cnt;
    	    cnt_rr 	<= cnt_r;
    	    cnt_rrr <= cnt_rr;
    	    
    	end if;
	end if;
end process;

-- mem_we.
we_i <= rw_tdata_state and s_axis_tvalid;

-- Finite state machine.
process (clk)
begin
	if ( rising_edge(clk) ) then
		if ( rstn = '0' ) then
			state <= INIT_ST;
		else
			case state is
				when INIT_ST =>
					if ( WE_REG_resync = '1' ) then
						state <= READ_ADDR_ST;
					end if;

				when READ_ADDR_ST =>
            		state <= RW_TDATA_ST;

				when RW_TDATA_ST =>
            		if ( WE_REG_resync = '0') then
						state <= INIT_ST;
					else
            			state <= RW_TDATA_ST;
					end if;

			end case;
		end if;
	end if;
end process;

-- Output logic.
process (state)
begin
read_addr_state	<= '0';
rw_tdata_state	<= '0';
    case state is
        when INIT_ST    =>
            
        when READ_ADDR_ST =>
            read_addr_state	<= '1';
                                           
        when RW_TDATA_ST =>
            rw_tdata_state	<= '1';
        
    end case;
end process;

-- Assign output.
s_axis_tready   <= rw_tdata_state;

mem_en          <= '1';
mem_we          <= we_rrr;
mem_addr        <= std_logic_vector(cnt_rrr); 
mem_di          <= tdata_rrr;

end rtl;

