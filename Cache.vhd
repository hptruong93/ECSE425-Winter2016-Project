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
port (
			clk 	: in STD_LOGIC;
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
	STALL, STALL2,
	IDLE,
	PREFETCHING,
	FETCHING
	);
signal current_state : state;
signal loading_address : NATURAL;

signal cached_data : CACHE_DATA_TYPE;
signal cached_tags : CACHE_TAG_TYPE;

signal fifo_data : FIFO_DATA_TYPE;
signal lru_data : LRU_DATA_TYPE;

begin
	synced_clock : process(clk, reset)

-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
		variable rand : INTEGER := 27; --this is the seed for the random function.
		variable cached_value : REGISTER_VALUE;
		variable cache_hit : BOOLEAN;

-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
		PROCEDURE get_cached_value(signal real_address : in NATURAL) IS
			variable currently_cached : REGISTER_VALUE;

			variable address : NATURAL;
			variable slot_number : NATURAL;
			variable index : NATURAL;

			variable tag : REGISTER_VALUE;
			variable cached_tag : TAG_VALUE;

		BEGIN
			address := real_address / 4;
			case( CACHE_ASSOCIATIVITY ) is
				when ONE_WAY_ASSOCIATIVITY =>
					slot_number := address mod CACHE_SIZE_IN_WORD;
					tag := STD_LOGIC_VECTOR(TO_UNSIGNED(address, tag'length) srl CACHE_SIZE_BIT_COUNT);

					currently_cached := cached_data(slot_number);
					cached_tag := cached_tags(slot_number);

					if ((tag = cached_tag) and (currently_cached /= INVALID_DATA)) then
						cached_value := currently_cached;
						cache_hit := TRUE;
					else
						cached_value := X_BYTE_32;
						cache_hit := FALSE;
					end if;
				when TWO_WAY_ASSOCIATIVITY =>
					slot_number := 2 * (address mod (CACHE_SIZE_IN_WORD / 2));
					tag := STD_LOGIC_VECTOR(TO_UNSIGNED(address, tag'length));

					cached_value := X_BYTE_32;
					cache_hit := FALSE;

					for index in 0 to 1 loop
						currently_cached := cached_data(slot_number + index);
						cached_tag := cached_tags(slot_number + index);

						if ((tag = cached_tag) and (currently_cached /= INVALID_DATA)) then
							--SHOW("CACHE: Tag is and cached_tag is " & INTEGER'image(index) & INTEGER'image(TO_INTEGER(UNSIGNED(tag))) & INTEGER'image(TO_INTEGER(UNSIGNED(cached_tag))));
							--SHOW_LOVE("currently_cached ", currently_cached);
							cached_value := currently_cached;
							cache_hit := TRUE;
						end if;
					end loop;
				when FOUR_WAY_ASSOCIATIVITY =>
					slot_number := 4 * (address mod (CACHE_SIZE_IN_WORD / 4));
					tag := STD_LOGIC_VECTOR(TO_UNSIGNED(address, tag'length));

					cached_value := X_BYTE_32;
					cache_hit := FALSE;

					for index in 0 to 3 loop
						currently_cached := cached_data(slot_number + index);
						cached_tag := cached_tags(slot_number + index);

						if ((tag = cached_tag) and (currently_cached /= INVALID_DATA)) then
							--SHOW("CACHE: Tag is and cached_tag is " & INTEGER'image(index) & INTEGER'image(TO_INTEGER(UNSIGNED(tag))) & INTEGER'image(TO_INTEGER(UNSIGNED(cached_tag))));
							--SHOW_LOVE("currently_cached ", currently_cached);
							cached_value := currently_cached;
							cache_hit := TRUE;
						end if;
					end loop;
				when FULL_ASSOCIATIVITY =>
					--SHOW("CACHE Reading address " & INTEGER'image(address));
					tag := STD_LOGIC_VECTOR(TO_UNSIGNED(address, tag'length));
					cache_hit := FALSE;

					for i in cached_data'range loop
						currently_cached := cached_data(i);
						cached_tag := cached_tags(i);

						if ((tag = cached_tag) and (currently_cached /= INVALID_DATA)) then
							cached_value := currently_cached;
							cache_hit := TRUE;
						end if;
					end loop;
				when others =>
					cached_value := X_BYTE_32;
					cache_hit := FALSE;
			end case ;
		END get_cached_value;
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
		PROCEDURE lru_replace_on_miss(variable tag : in TAG_VALUE ; signal retrieved_value : REGISTER_VALUE;
												variable start_lru_index : NATURAL; variable end_lru_index : NATURAL) IS --end is inclusive
			variable unused_index : NATURAL;
			variable all_used : STD_LOGIC;
		BEGIN
			all_used := '1';

			for i in end_lru_index downto start_lru_index loop
				if lru_data(i) = '0' then
					--SHOW("CACHE REPLACE Unused at " & INTEGER'image(i));
					unused_index := i;
					all_used := '0';
				end if;
			end loop;

			if all_used = '1' then --all are used. Set everything to 0
				--SHOW("CACHE REPLACEMENT_BIT_PLRU ALL USED");
				rand := RAND_RANGE(rand, end_lru_index - start_lru_index);
				unused_index := start_lru_index + rand;
				lru_data <= (others => '0');
			end if;

			--SHOW("CACHE REPLACE Writing back at " & INTEGER'image(unused_index));
			cached_data(unused_index) <= retrieved_value;
			cached_tags(unused_index) <= tag;
			lru_data(unused_index) <= '1';
		END lru_replace_on_miss;
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
		PROCEDURE cache_miss_callback(signal real_address : in NATURAL; signal retrieved_value : REGISTER_VALUE) IS
			variable address : NATURAL;
			variable slot_number : NATURAL;
			variable index : NATURAL;
			variable unused_index : NATURAL;
			variable all_used : STD_LOGIC;
			variable tag : TAG_VALUE;

			variable start_lru_index, end_lru_index : NATURAL;
		BEGIN
			address := real_address / 4;
			case( CACHE_ASSOCIATIVITY ) is
				when ONE_WAY_ASSOCIATIVITY =>
					slot_number := address mod CACHE_SIZE_IN_WORD;
					tag := STD_LOGIC_VECTOR(TO_UNSIGNED(address, tag'length) srl CACHE_SIZE_BIT_COUNT);

					cached_data(slot_number) <= retrieved_value;
					cached_tags(slot_number) <= tag;
				when TWO_WAY_ASSOCIATIVITY =>
					slot_number := 2 * (address mod (CACHE_SIZE_IN_WORD / 2));
					tag := STD_LOGIC_VECTOR(TO_UNSIGNED(address, tag'length));
					case( REPLACEMENT_STRATEGY ) is
						when REPLACEMENT_RANDOM =>
							rand := RAND_RANGE(rand, 2);
							index := rand;

							cached_data(slot_number + index) <= retrieved_value;
							cached_tags(slot_number + index) <= tag;
						when REPLACEMENT_BIT_PLRU =>
							start_lru_index := slot_number;
							end_lru_index := slot_number + 1;
							lru_replace_on_miss(tag, retrieved_value, start_lru_index, end_lru_index);
						when others =>
					end case;
				when FOUR_WAY_ASSOCIATIVITY =>
					slot_number := 4 * (address mod (CACHE_SIZE_IN_WORD / 4));
					tag := STD_LOGIC_VECTOR(TO_UNSIGNED(address, tag'length));
					case( REPLACEMENT_STRATEGY ) is
						when REPLACEMENT_RANDOM =>
							rand := RAND_RANGE(rand, 4);
							index := rand;

							cached_data(slot_number + index) <= retrieved_value;
							cached_tags(slot_number + index) <= tag;
						when REPLACEMENT_BIT_PLRU =>
							start_lru_index := slot_number;
							end_lru_index := slot_number + 3;
							lru_replace_on_miss(tag, retrieved_value, start_lru_index, end_lru_index);
						when others =>
					end case;
				when FULL_ASSOCIATIVITY =>
					tag := STD_LOGIC_VECTOR(TO_UNSIGNED(address, tag'length));
					case( REPLACEMENT_STRATEGY ) is
						when REPLACEMENT_RANDOM =>
							rand := RAND_RANGE(rand, CACHE_SIZE_IN_WORD);
							slot_number := rand;

							--SHOW("CACHE Replacement to slot " & INTEGER'image(slot_number), "at address " & INTEGER'image(address));

							cached_data(slot_number) <= retrieved_value;
							cached_tags(slot_number) <= tag;
						when REPLACEMENT_BIT_PLRU =>
							start_lru_index := 0;
							end_lru_index := CACHE_SIZE_IN_WORD-1;
							lru_replace_on_miss(tag, retrieved_value, start_lru_index, end_lru_index);
						when REPLACEMENT_FIFO =>

						when others =>
					end case ;
				when others =>
			end case;
		END cache_miss_callback;
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
		PROCEDURE lru_mark_on_hit(variable tag : TAG_VALUE; variable start_lru_index : NATURAL; variable end_lru_index : NATURAL) IS
		BEGIN
			for i in start_lru_index to end_lru_index loop
				if cached_tags(i) = tag then
					--SHOW("CACHE MARK ON HIT AT " & INTEGER'image(i));
					lru_data(i) <= '1';
				end if;
			end loop;
		END lru_mark_on_hit;
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
		PROCEDURE cache_hit_callback(signal address : in NATURAL) IS
			variable tag : TAG_VALUE;
			variable slot_number : NATURAL;
			variable start_lru_index, end_lru_index : NATURAL;
		BEGIN
			case( REPLACEMENT_STRATEGY ) is
				when REPLACEMENT_BIT_PLRU =>
					case( CACHE_ASSOCIATIVITY ) is
						when TWO_WAY_ASSOCIATIVITY =>
							slot_number := 2 * (address mod (CACHE_SIZE_IN_WORD / 2));
							tag := STD_LOGIC_VECTOR(TO_UNSIGNED(address, tag'length));

							start_lru_index := slot_number;
							end_lru_index := slot_number + 1;
							lru_mark_on_hit(tag, start_lru_index, end_lru_index);
						when FOUR_WAY_ASSOCIATIVITY =>
							slot_number := 4 * (address mod (CACHE_SIZE_IN_WORD / 4));
							tag := STD_LOGIC_VECTOR(TO_UNSIGNED(address, tag'length));

							start_lru_index := slot_number;
							end_lru_index := slot_number + 3;
							lru_mark_on_hit(tag, start_lru_index, end_lru_index);
						when FULL_ASSOCIATIVITY =>
							tag := STD_LOGIC_VECTOR(TO_UNSIGNED(address, tag'length));
							start_lru_index := 0;
							end_lru_index := CACHE_SIZE_IN_WORD-1;
							lru_mark_on_hit(tag, start_lru_index, end_lru_index);
						when others =>
					end case ;
				when REPLACEMENT_FIFO =>
					case( CACHE_ASSOCIATIVITY ) is
						when FULL_ASSOCIATIVITY =>

						when others =>
					end case ;

				when others =>
			end case;
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
				fifo_data(i) <= CACHE_SIZE_IN_WORD;
			end loop;

			lru_data <= (others => '0');
		elsif (clk'event) then
			case( current_state ) is
				when STALL =>
					--This state is present to accommodate the fact that the client (i.e. instructi0on fetch) operates on rising edge
					--Therefore we must stall at least half a clock cycle so that the client can react to our
					SHOW("CACHE STALLING");
					current_state <= IDLE;
					do_read <= '0';
					is_cache_busy <= '0';
				when STALL2 =>
					SHOW("CACHE STALLING 2");
					current_state <= STALL;
					do_read <= '0';
					is_cache_busy <= '0';
				when IDLE =>
					do_read <= '0';
					is_cache_busy <= '0';

					if cache_read = '1' then
						get_cached_value(mem_address);
						if not CACHE_ENABLED then
							SHOW("WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING: CACHE DISABLED!");
						end if;

						if cache_hit and CACHE_ENABLED then -- cache hit, return the value
							SHOW_LOVE("CACHE hit at address " & INTEGER'image(mem_address), "Returning value ", cached_value);
							cache_hit_callback(mem_address);
							cache_output <= cached_value;
							if clk = '0' then
								--If clk is falling edge then we should wait stall for half a clock cycle so that
								-- instruction fetch can react to our output and provide new request at rising edge
								current_state <= STALL;
							else
								--Instruction fetch is only sensitive to rising edge,
								--meaning that it can only place a request on rising edge. Therefore
								--our processing always starts at falling edge. Consequently, a cache hit at rising edge is impossible.
								current_state <= IDLE;
							end if;
						else --cache miss, read from memory
							SHOW("CACHE missed. Reading from memory " & INTEGER'image(mem_address));
							is_cache_busy <= '1';
							do_read <= '1';
							load_address <= mem_address;
							loading_address <= mem_address;
							current_state <= PREFETCHING;
						end if;
					else
						--SHOW("CACHE IDLING");
						current_state <= IDLE;
					end if;
				when PREFETCHING =>
					--We have this stage because the underlying layer (i.e. memory arbiter) actually needs a complete clock cycle to
					--response (i.e. set busy to high) in case of two requests from port 1 and port 2 happening at the same time

					--This is also reasonable even if the underlying layer (i.e. memory arbiter) can response in half clock cycle since
					--main memory is rising edge sensitive only anyways (i.e. minimum time taken to fetch something from memory is 1 clock cycle)
					current_state <= FETCHING;
				when FETCHING =>
					--SHOW("CACHE FETCHING");
					if is_mem_busy = '0' then --mem finish loading. Return the value
						SHOW_LOVE("CACHE RETURNING FROM MEMORY AT ADDRESS " & INTEGER'image(mem_address), "WITH DATA", mem_data);
						cache_miss_callback(loading_address, mem_data);
						cache_output <= mem_data;
						is_cache_busy <= '0';
						current_state <= STALL2;
					else --keep waiting for mem
						if cache_read = '0' then --client cancels read
							do_read <= '0';
							current_state <= IDLE;
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
