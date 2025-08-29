library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_writer is
    Generic
    (
		-- Address map of memory.
		N		: Integer := 8	;

		-- Data width.
		BDATA	: Integer := 16	;

		-- Tuser width.
		BUSER	: Integer := 16
    );
    Port
    (
        rstn		: in std_logic										;
        clk			: in std_logic										;
        
        -- AXI Stream I/F.
		tdata		: in std_logic_vector (BDATA-1 			downto 0)	;				
		tuser		: in std_logic_vector (BUSER-1 			downto 0)	;
		tlast		: in std_logic										;
		tvalid		: in std_logic										;
        tready		: out std_logic										;
		
		-- Memory I/F.
		mem_we      : out std_logic										;
		mem_addr    : out std_logic_vector (N-1 			downto 0)	;
		mem_di      : out std_logic_vector (BDATA+BUSER-1 	downto 0)	;

		-- Start.
		start		: in std_logic										;
		sync		: in std_logic
    );
end entity;

architecture rtl of data_writer is

constant NPOW 	: Integer := 2**N;

-- State machine.
type fsm_state is ( INIT_ST		,
					SYNC_ST		,
                    WRITE_ST	,
                    END_ST		);
signal current_state, next_state : fsm_state;

signal init_state   : std_logic;
signal sync_state	: std_logic;
signal write_state	: std_logic;

signal addr_cnt     : unsigned (N-1 downto 0);

begin
                
-- Registers.
process (clk)
begin
    if (rising_edge(clk)) then
        if ( rstn = '0' ) then
            current_state <= INIT_ST;
        else
            current_state <= next_state;
            
            -- Address counter.
            if ( init_state = '1' ) then
                addr_cnt <= (others => '0');
            else
                if ( write_state  = '1' and tvalid = '1' ) then
                    addr_cnt <= addr_cnt + 1;
                end if; 
            end if;
        end if;
    end if;
end process;

-- Next state logic.
process (current_state, start, sync, addr_cnt, tvalid, tlast)
begin
    case current_state is
        when INIT_ST =>
            if (start = '0') then
                next_state <= INIT_ST;
            else
				if (sync = '0') then
                	next_state <= WRITE_ST;
				else
					next_state <= SYNC_ST;
				end if;
            end if;

		when SYNC_ST =>
			if (tvalid = '0') then
				next_state <= SYNC_ST;
			else
				if (tlast = '0') then
					next_state <= SYNC_ST;
				else
					next_state <= WRITE_ST;
				end if;
			end if;

        when WRITE_ST =>
            if ( addr_cnt < to_unsigned(NPOW-1,addr_cnt'length) ) then
                next_state <= WRITE_ST;
            else
                next_state <= END_ST;
            end if;            
        
        when END_ST =>
            if ( start = '1' ) then
                next_state <= END_ST;
            else
                next_state <= INIT_ST;
            end if;
    end case;
end process;

-- Output logic.
process (current_state)
begin
init_state  <= '0';
sync_state	<= '0';
write_state	<= '0';
    case current_state is
        when INIT_ST =>
            init_state  <= '1';

		when SYNC_ST =>
			sync_state	<= '1';

        when WRITE_ST =>
            write_state	<= '1';
            
        when END_ST =>
                        
    end case;
end process;

-- Assign outputs.
tready 		<= sync_state or write_state;

mem_we      <= write_state and tvalid;
mem_addr    <= std_logic_vector(addr_cnt);
mem_di      <= tuser & tdata;

end rtl;

