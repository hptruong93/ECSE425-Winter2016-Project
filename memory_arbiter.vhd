library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

use work.memory_arbiter_lib.all;

-- Do not modify the port map of this structure
entity memory_arbiter is
port (clk 	: in STD_LOGIC;
			reset : in STD_LOGIC;
			
			--Memory port #1
			addr1	: in NATURAL;
			data1	:	inout STD_LOGIC_VECTOR(MEM_DATA_WIDTH-1 downto 0);
			re1		: in STD_LOGIC;
			we1		: in STD_LOGIC;
			busy1 : out STD_LOGIC;
			
			--Memory port #2
			addr2	: in NATURAL;
			data2	:	inout STD_LOGIC_VECTOR(MEM_DATA_WIDTH-1 downto 0);
			re2		: in STD_LOGIC;
			we2		: in STD_LOGIC;
			busy2 : out STD_LOGIC
	);
end memory_arbiter;

architecture behavioral of memory_arbiter is

	TYPE state IS (IDLE, READ_FIRST, WRITE_FIRST, READ_SECOND, WRITE_SECOND);

	--Main memory signals
	--Use these internal signals to interact with the main memory
	SIGNAL mm_address       : NATURAL                                       := 0;
	SIGNAL mm_we            : STD_LOGIC                                     := '0';
	SIGNAL mm_wr_done       : STD_LOGIC                                     := '0';
	SIGNAL mm_re            : STD_LOGIC                                     := '0';
	SIGNAL mm_rd_ready      : STD_LOGIC                                     := '0';
	SIGNAL mm_data          : STD_LOGIC_VECTOR(MEM_DATA_WIDTH-1 downto 0)   := (others => 'Z');
	SIGNAL mm_initialize    : STD_LOGIC                                     := '0';

	SIGNAL current_state : state;

begin

	--Instantiation of the main memory component (DO NOT MODIFY)
	main_memory : ENTITY work.Main_Memory
			GENERIC MAP (
				Num_Bytes_in_Word	=> NUM_BYTES_IN_WORD,
				Num_Bits_in_Byte 	=> NUM_BITS_IN_BYTE,
				Read_Delay        => 3, 
				Write_Delay       => 3
			)
			PORT MAP (
				clk					=> clk,
				address     => mm_address,
				Word_Byte   => '1',
				we          => mm_we,
				wr_done     => mm_wr_done,
				re          => mm_re,
				rd_ready    => mm_rd_ready,
				data        => mm_data,
				initialize  => mm_initialize,
				dump        => '0'
			);

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
	process(clk, reset, addr1, addr2, re1, we1, re2, we2, data1, data2)
	begin
		if reset = '1' then
			current_state <= IDLE;  --default state on reset.
			busy1 <= '0';
			busy2 <= '0';

			mm_initialize <= '1';
		elsif (rising_edge(clk)) then
			mm_initialize <= '0';
			case current_state is
				when IDLE =>
					--REPORT "IDLE";
					--REPORT "re1 is" & std_logic'image(re1);
					--REPORT "we1 is" & std_logic'image(we1);
					--REPORT "re2 is" & std_logic'image(re2);
					--REPORT "we2 is" & std_logic'image(we2);
					--REPORT "******************************************************************";
					if re1 = '1' then
						--REPORT "Going to READ_FIRST";
						current_state <= READ_FIRST;
						busy1 <= '1';
						mm_address <= addr1;
						mm_re <= '1';

						if (re2 = '1') or (we2 = '1') then
							busy2 <= '1';
						else
							busy2 <= '0';
						end if;
					elsif we1 = '1' then
						current_state <= WRITE_FIRST;
						busy1 <= '1';
						mm_address <= addr1;
						mm_we <= '1';
						mm_data <= data1;

						if (re2 = '1') or (we2 = '1') then
							busy2 <= '1';
						else
							busy2 <= '0';
						end if;
					elsif re2 = '1' then
						current_state <= READ_SECOND;
						busy2 <= '1';
						mm_address <= addr2;
						mm_re <= '1';
					elsif we2 = '1' then
						--REPORT "Going to WRITE_SECOND";
						current_state <= WRITE_SECOND;
						busy2 <= '1';
						mm_address <= addr2;
						mm_we <= '1';
						mm_data <= data2;
					else
						--REPORT "Maybe next timee";
						current_state <= IDLE;
						busy1 <= '0';
						busy2 <= '0';
						mm_we <= '0';
						mm_re <= '0';
						data1 <= (others => 'Z');
						data2 <= (others => 'Z');
					end if;
				when READ_FIRST =>
					--REPORT "READ_FIRST";
					if mm_rd_ready = '1' then
						current_state <= IDLE;
						busy1 <= '0';
						mm_re <= '0';
						data1 <= mm_data;
					else
						current_state <= READ_FIRST;
					end if;

					if (re2 = '1') or (we2 = '1') then
						busy2 <= '1';
					else
						busy2 <= '0';
					end if;
				when WRITE_FIRST =>
					--REPORT "WRITE_FIRST";
					if mm_wr_done = '1' then
						current_state <= IDLE;
						data1 <= mm_data;
						mm_we <= '0';
						busy1 <= '0';
					else
						current_state <= WRITE_FIRST;
					end if;

					if (re2 = '1') or (we2 = '1') then
						busy2 <= '1';
					else
						busy2 <= '0';
					end if;
				when READ_SECOND =>
					if mm_rd_ready = '1' then
						current_state <= IDLE;
						busy2 <= '0';
						mm_re <= '0';
						data2 <= mm_data;
					else
						current_state <= READ_SECOND;
					end if;

					if (re1 = '1') or (we1 = '1') then
						busy1 <= '1';
					else
						busy1 <= '0';
					end if;
				when WRITE_SECOND =>
					--REPORT "WRITE_SECOND";
					if mm_wr_done = '1' then
						current_state <= IDLE;
						data2 <= mm_data;
						mm_we <= '0';
						busy2 <= '0';
					else
						current_state <= WRITE_SECOND;
					end if;

					if (re1 = '1') or (we1 = '1') then
						busy1 <= '1';
					else
						busy1 <= '0';
					end if;
			end case;
		end if;

		
	end process;

end behavioral;