--Instruction cache
--Used for instruction fetch stage of the pipeline.
--Configurable parameters:
--	1) cache size (in word)
--	2) associativity (1-way (direct map), 2-way, 4-way, fully associativity)
--	3) Replacement strategy (LRU, FIFO, random)

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.numeric_std_unsigned.all;
use work.register_array.all;
use work.cache_infrastructure.all;

entity Cache is
port (		clk 	: in STD_LOGIC;
			reset : in STD_LOGIC;

			mem_data : in REGISTER_VALUE; --from memory

			cache_read : in STD_LOGIC;
			is_mem_busy : in STD_LOGIC;
			mem_address : in NATURAL; --input from instruction fetch. Always read

			do_read : out STD_LOGIC;
			load_address : out NATURAL; --address to send to memory arbiter
			is_cache_busy : out STD_LOGIC;
			cache_output : out REGISTER_VALUE
	);
end Cache;

architecture behavioral of Cache is

type state is (
	STALL,
	IDLE,
	FETCHING
	);
signal current_state : state;
signal cached_data : CACHE_DATA_TYPE;
signal cached_tags : CACHE_TAG_TYPE;

begin
	synced_clock : process(clk, reset)

-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
		variable cached_value : REGISTER_VALUE;
		variable cache_hit : BOOLEAN;

-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
		PROCEDURE get_cached_value(signal address : in NATURAL) IS
			variable currently_cached : REGISTER_VALUE;
			variable slot_number : NATURAL;
			variable tag : REGISTER_VALUE;
			variable temp_tag : TAG_VALUE;
		BEGIN
			case( CACHE_ASSOCIATIVITY ) is
				when ONE_WAY_ASSOCIATIVITY =>
					slot_number := address mod CACHE_SIZE_IN_WORD;
					tag := STD_LOGIC_VECTOR(TO_UNSIGNED(address, tag'length) srl CACHE_SIZE_BIT_COUNT);

					currently_cached := cached_data(slot_number);
					temp_tag := cached_tags(slot_number);

					SHOW("CACHE: Tag is and temp tag is " & integer'image(slot_number) & INTEGER'image(TO_INTEGER(UNSIGNED(tag))) & INTEGER'image(TO_INTEGER(UNSIGNED(tag))));
					SHOW_LOVE("currently_cached ", currently_cached);

					if ((tag = temp_tag) and (currently_cached /= INVALID_DATA)) then
						cached_value := currently_cached;
						cache_hit := TRUE;
					else
						cached_value := X_BYTE_32;
						cache_hit := FALSE;
					end if;
				when others =>
					cached_value := X_BYTE_32;
					cache_hit := FALSE;
			end case ;
		END get_cached_value;
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
		PROCEDURE cache_miss_callback(signal address : in NATURAL; signal retrieved_value : REGISTER_VALUE) IS
			variable slot_number : NATURAL;
			variable tag : TAG_VALUE;
		BEGIN
			case( CACHE_ASSOCIATIVITY ) is
				when ONE_WAY_ASSOCIATIVITY =>
					slot_number := address mod CACHE_SIZE_IN_WORD;
					tag := STD_LOGIC_VECTOR(TO_UNSIGNED(address, tag'length) srl CACHE_SIZE_BIT_COUNT);

					cached_data(slot_number) <= retrieved_value;
					cached_tags(slot_number) <= tag;
				when others =>
			end case;
		END cache_miss_callback;
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
		PROCEDURE cache_hit_callback(signal address : in NATURAL) IS
		BEGIN
		END cache_hit_callback;
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
	begin
		if reset = '1' then
			load_address <= 0;
			current_state <= IDLE;

			for i in cached_data'range loop
				cached_data(i) <= (others => '1');
				cached_tags(i) <= (others => '1');
			end loop;
		elsif (clk'event) then
		--elsif (rising_edge(clk)) then
			case( current_state ) is
				when STALL =>
					SHOW("CACHE STALLING");
					current_state <= IDLE;
					do_read <= '0';
					is_cache_busy <= '0';
				when IDLE =>
					do_read <= '0';
					is_cache_busy <= '0';

					if cache_read = '1' then
						get_cached_value(mem_address);
						if cache_hit then -- cache hit, return the value
							SHOW_LOVE("CACHE hit. Returning value ", cached_value);
							cache_hit_callback(mem_address);
							cache_output <= cached_value;
							current_state <= STALL;
						else --cache miss, read from memory
							SHOW("CACHE missed. Reading from memory");
							is_cache_busy <= '1';
							do_read <= '1';
							load_address <= mem_address;
							current_state <= FETCHING;
						end if;
					else
						SHOW("CACHE IDLING");
						current_state <= IDLE;
					end if;
				when FETCHING =>
					SHOW("CACHE FETCHING");
					if is_mem_busy = '0' then --mem finish loading. Return the value
						SHOW("CACHE RETURNING FROM MEMORY");
						cache_miss_callback(mem_address, mem_data);
						cache_output <= mem_data;
						current_state <= IDLE;
					else --keep waiting for mem
						if cache_read = '0' then --client cancels read
							do_read <= '0';
							current_state <= STALL;
							is_cache_busy <= '0';
						else
							do_read <= '1';
							is_cache_busy <= '1';
							current_state <= FETCHING;
						end if;
					end if;
			end case ;
		end if;
	end process;


end behavioral;
