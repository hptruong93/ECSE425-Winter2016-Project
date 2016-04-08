library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.register_array.all;

entity MemStage is
port (	clk 	: in STD_LOGIC;
			reset : in STD_LOGIC;

			mem_address : in SIGNED(32-1 downto 0); -- coming from ALU
			--operation : out STD_LOGIC_VECTOR(6-1 downto 0);
			stored_register : in STD_LOGIC_VECTOR(5-1 downto 0); -- used for store, tells which register to read from.
			registers : in register_array;
			signal_to_mem : in STD_LOGIC_VECTOR(3-1 downto 0);
			is_mem_busy : in STD_LOGIC;

			word_byte: out STD_LOGIC; --  when '1' you are interacting with the memory in word otherwise in byte
			do_read : out STD_LOGIC;
			do_write : out	STD_LOGIC;
			is_busy : out STD_LOGIC;
			address_line : out NATURAl;
			input_data_line : in STD_LOGIC_VECTOR(32-1 downto 0); -- coming from memory arbiter
			output_data_line : out STD_LOGIC_VECTOR(32-1 downto 0); -- sending to memory arbiter
			mem_stage_output : out STD_LOGIC_VECTOR(32-1 downto 0) -- passed onto write back stage
	);
end MemStage;

architecture behavioral of MemStage is

type state is (
	MEM_IGNORE,
	MEM_IGNORE_2,
	MEM_WAIT,
	MEM_ACCESS
	);
signal current_state : state;
signal current_mem_address : SIGNED(32-1 downto 0) := (others => '0'); --Test purpose

begin
	synced_clock : process(clk, reset)

		PROCEDURE go_to_mem_access(previous_signal_to_mem : in STD_LOGIC_VECTOR(3-1 downto 0)) IS
		BEGIN
			current_state <= MEM_ACCESS;
		END go_to_mem_access;

	begin
		if reset = '1' then
			current_state <= MEM_WAIT;
		elsif (rising_edge(clk)) then
			current_state <= current_state;
			do_read <= '0';
			do_write <= '0';

			case( current_state ) is
				when MEM_WAIT =>
					case( signal_to_mem ) is
						when LOAD_WORD =>
							is_busy <= '1';

							if (is_mem_busy = '0') then
								SHOW("MEM LOAD WORD WAIT WITH ADDRESS " & integer'image(to_integer(mem_address)));
								word_byte <= '1'; -- interact with mem in word
								do_read <= '1';
								address_line <= to_integer(mem_address); -- where to load from
								current_mem_address <= mem_address;

								go_to_mem_access(LOAD_WORD);
							end if;
						when STORE_WORD =>
							is_busy <= '1';

							if (is_mem_busy = '0') then
								SHOW_LOVE("MEM STORE_WORD WAIT WITH ADDRESS " & INTEGER'image(TO_INTEGER(mem_address)), " AND DATA " & INTEGER'image(to_integer(unsigned(stored_register))), registers(to_integer(unsigned(stored_register))));
								word_byte <= '1'; -- interact with mem in word
								address_line <= to_integer(mem_address);  -- where to store
								output_data_line <= registers(to_integer(unsigned(stored_register)));
								do_write <= '1';
								current_mem_address <= mem_address;

								go_to_mem_access(STORE_WORD);
							end if;
						when LOAD_BYTE =>
							is_busy <= '1';

							if (is_mem_busy = '0') then
								word_byte <= '0'; -- interact with mem in byte
								do_read <= '1';
								address_line <= to_integer(mem_address);  -- where to load from

								go_to_mem_access(LOAD_BYTE);
							end if;
						when STORE_BYTE =>
							is_busy <= '1';
							if (is_mem_busy = '0') then
								word_byte <= '0'; -- interact with mem in byte
								output_data_line <= registers(to_integer(unsigned(stored_register)));
								do_write <= '1';
								address_line <= to_integer(mem_address);  -- where to store

								go_to_mem_access(STORE_BYTE);
							end if;
						when MEM_IDLE =>
							SHOW("MEM IDLE IN MEM_WAIT");
							current_state <= MEM_WAIT;
						when others =>
					end case ;
				when MEM_ACCESS =>
					case( signal_to_mem ) is
						when LOAD_WORD =>
							if (is_mem_busy = '0') then
								SHOW_LOVE("MEM finish LOAD with value ", input_data_line);
								is_busy <= '0';
								mem_stage_output <= input_data_line;
								current_state <= MEM_IGNORE_2;
							else
								do_read <= '1';
							end if;
						when STORE_WORD =>
							SHOW("MemStage MEM_ACCESS STORE");
							if (is_mem_busy = '0') then
								SHOW("MEM finish STORE_WORD into value " & INTEGER'image(TO_INTEGER(current_mem_address)));
								is_busy <= '0';
								current_state <= MEM_IGNORE_2;
							else
								do_write <= '1';
							end if;
						when LOAD_BYTE =>
							if (is_mem_busy = '0') then
								is_busy <= '0';

								if input_data_line(7) = '1' then --sign extended
									mem_stage_output(31 downto 8) <= "111111111111111111111111";
								else
									mem_stage_output(31 downto 8) <= "000000000000000000000000";
								end if;
								mem_stage_output(7 downto 0) <= input_data_line(7 downto 0);
								current_state <= MEM_IGNORE_2;
							else
								do_read <= '1';
							end if;
						when STORE_BYTE =>
							if (is_mem_busy = '0') then
								is_busy <= '0';
								current_state <= MEM_IGNORE_2;
							else
								do_write <= '1';
							end if;
						when MEM_IDLE =>
							SHOW("MEM IDLE IN MEM_ACCESS");
							current_state <= MEM_WAIT;
						when others =>
					end case ;
				when MEM_IGNORE =>
					is_busy <= '0';
					SHOW("MEM IGNORE");
					current_state <= MEM_WAIT;
				when MEM_IGNORE_2 =>
					is_busy <= '0';
					SHOW("MEM IGNORE 2");
					current_state <= MEM_IGNORE;
				when others =>
			end case ;

			--case( signal_to_mem ) is
			--	when LOAD_WORD =>
			--		case( current_state ) is
			--			when MEM_WAIT =>
			--				SHOW("MEM LOAD WORD WAIT WITH ADDRESS " & integer'image(to_integer(mem_address)));
			--				is_busy <= '1';
			--				if (is_mem_busy = '0') then
			--					--SHOW("ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc initiating LOAD");
			--					word_byte <= '1'; -- interact with mem in word
			--					do_read <= '1';
			--					address_line <= to_integer(mem_address); -- where to load from
			--					current_mem_address <= mem_address;
			--					current_state <= MEM_ACCESS;
			--				end if;
			--			when MEM_ACCESS =>
			--				--SHOW("MEM STATE IS ACCESS");
			--				if (is_mem_busy = '0') then
			--					SHOW_LOVE("MEM finish LOAD with value ", input_data_line);
			--					is_busy <= '0';
			--					mem_stage_output <= input_data_line;
			--					current_state <= MEM_IGNORE;
			--				else
			--					do_read <= '1';
			--				end if;
			--			when MEM_IGNORE => --Enter this stage after mem operation to wait for decode to change its signal
			--				current_state <= MEM_WAIT;
			--		end case ;

			--	when STORE_WORD =>
			--		--SHOW("ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc STORE_WORD");
			--		case( current_state ) is
			--			when MEM_WAIT =>
			--				is_busy <= '1';

			--				if (is_mem_busy = '0') then
			--					SHOW_LOVE("MEM STORE_WORD WAIT WITH ADDRESS " & INTEGER'image(TO_INTEGER(mem_address)), " AND DATA " & INTEGER'image(to_integer(unsigned(stored_register))), registers(to_integer(unsigned(stored_register))));
			--					word_byte <= '1'; -- interact with mem in word
			--					address_line <= to_integer(mem_address);  -- where to store
			--					output_data_line <= registers(to_integer(unsigned(stored_register)));
			--					do_write <= '1';
			--					current_mem_address <= mem_address;
			--					current_state <= MEM_ACCESS;
			--				end if;
			--			when MEM_ACCESS =>
			--				if (is_mem_busy = '0') then
			--					SHOW("MEM finish STORE_WORD into value " & INTEGER'image(TO_INTEGER(current_mem_address)));
			--					is_busy <= '0';
			--					current_state <= MEM_IGNORE;
			--				else
			--					do_write <= '1';
			--				end if;
			--			when MEM_IGNORE => --Enter this stage after mem operation to wait for decode to change its signal
			--				current_state <= MEM_WAIT;
			--		end case;
			--	when LOAD_BYTE =>
			--		case( current_state ) is
			--			when MEM_WAIT =>
			--				is_busy <= '1';
			--				if (is_mem_busy = '0') then
			--					word_byte <= '0'; -- interact with mem in byte
			--					do_read <= '1';
			--					address_line <= to_integer(mem_address);  -- where to load from
			--					current_state <= MEM_ACCESS;
			--				end if;
			--			when MEM_ACCESS =>
			--				if (is_mem_busy = '0') then
			--					is_busy <= '0';

			--					if input_data_line(7) = '1' then --sign extended
			--						mem_stage_output(31 downto 8) <= "111111111111111111111111";
			--					else
			--						mem_stage_output(31 downto 8) <= "000000000000000000000000";
			--					end if;
			--					mem_stage_output(7 downto 0) <= input_data_line(7 downto 0);
			--					current_state <= MEM_IGNORE;
			--				end if;
			--			when MEM_IGNORE => --Enter this stage after mem operation to wait for decode to change its signal
			--				current_state <= MEM_WAIT;
			--		end case;
			--	when STORE_BYTE => -- preserve all words. TODO
			--		case( current_state ) is
			--			when MEM_WAIT =>
			--				is_busy <= '1';
			--				if (is_mem_busy = '0') then
			--					word_byte <= '0'; -- interact with mem in byte
			--					output_data_line <= registers(to_integer(unsigned(stored_register)));
			--					do_write <= '1';
			--					address_line <= to_integer(mem_address);  -- where to store
			--					current_state <= MEM_ACCESS;
			--				end if;
			--			when MEM_ACCESS =>
			--				if (is_mem_busy = '0') then
			--					is_busy <= '0';
			--					current_state <= MEM_IGNORE;
			--				end if;
			--			when MEM_IGNORE => --Enter this stage after mem operation to wait for decode to change its signal
			--				current_state <= MEM_WAIT;
			--		end case;
			--	when MEM_IDLE =>
			--		is_busy <= '0';
			--		SHOW("MEM IDLE");
			--		current_state <= MEM_WAIT;
			--	when others =>

			--end case ;
		end if;
	end process ; -- synced_clock


end behavioral;
