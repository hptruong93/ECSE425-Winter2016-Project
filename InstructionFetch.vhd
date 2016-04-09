------------------------------------------------------------------------------------------
-----This file implements the logic for Instruction Fetch stage of the pipelined processor
-----The instruction fetch operates using the following logic:----------------------------
--------Continuously fetches new instruction from memory----------------------------------
--------If a branch signal is detected (from decoder), cancel the current fetch and-------
------------switches to fetching the new instruction at the branch target-----------------
--------Once instruction is fetched, lower the busy signal for one cycle, but still keep--
------------the read request signal high to fetch the next instruction--------------------
------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.register_array.all;
use ieee.numeric_std_unsigned.all;

entity InstructionFetch is
port (	clk 	: in STD_LOGIC;
			reset : in STD_LOGIC;

			branch_signal : in  STD_LOGIC_VECTOR(2-1 downto 0);
			branch_address : in STD_LOGIC_VECTOR(32-1 downto 0); --from decoder
			data : in STD_LOGIC_VECTOR(32-1 downto 0); --from memory

			do_stall : in STD_LOGIC;
			is_mem_busy : in STD_LOGIC;

			pc_reg : out STD_LOGIC_VECTOR(32-1 downto 0); --send to decoder
			do_read : out STD_LOGIC;
			address : out STD_LOGIC_VECTOR(32-1 downto 0); --address to fetch the next instruction
			is_busy : out STD_LOGIC; --if waiting for memory
			instruction : out STD_LOGIC_VECTOR(32-1 downto 0) --instruction send to decoder
	);
end InstructionFetch;

architecture behavioral of InstructionFetch is

type state is (
	FIRST_CONTACT,
	FETCHING,
	INSTRUCTION_RECEIVED,
	BRANCHED_INSTRUCTION_RECEIVED,
	FETCH_BRANCH_SET,
	FETCH_BRANCH
	);
signal current_state : state;

signal program_counter : STD_LOGIC_VECTOR(32-1 downto 0)  := (others => '0');
signal last_instruction : STD_LOGIC_VECTOR(32-1 downto 0);
signal was_stalled : STD_LOGIC;
signal just_fetched : STD_LOGIC;

begin
	synced_clock : process(clk, reset)
		PROCEDURE update_instruction(signal new_instruction : STD_LOGIC_VECTOR(32-1 downto 0)) IS
		BEGIN
			if (new_instruction = Z_BYTE_32) then
				instruction <= (others => '0');
				last_instruction <= (others => '0');
			else
				instruction <= new_instruction;
				last_instruction <= new_instruction;
			end if;
		END update_instruction;

		PROCEDURE got_fetch IS
		BEGIN

			SHOW_LOVE("GOT FETCH " & INTEGER'image(TO_INTEGER(UNSIGNED(program_counter))), data);
			update_instruction(data);
			do_read <= '1';

			--if was_stalled = '0' then
			program_counter <= program_counter + 4;
			address <= program_counter + 4;
			update_instruction(data);
			--else
			--	SHOW("InstructionFetch refetch due to stall " & INTEGER'image(TO_INTEGER(UNSIGNED(program_counter))));
			--	program_counter <= program_counter;
			--	address <= program_counter;

			--	instruction <= data;
			--	last_instruction <= (others => '0');
			--end if;

			is_busy <= '0';
		END got_fetch;

	begin
		if reset = '1' then
			instruction <= (others => '0');
			current_state <= FIRST_CONTACT;
			address <= program_counter;
			pc_reg <= (others => '0');
			last_instruction <= (others => '0');

			was_stalled <= '0';
		elsif (rising_edge(clk)) then
			if do_stall = '1' then
				SHOW("InstructionFetch STALLING");
				instruction <= (others => '0');
				was_stalled <= '1';

				if is_mem_busy = '0' then --a new instruction has been fetched
					just_fetched <= '1';
				end if;
			else
				was_stalled <= '0';
				just_fetched <= '0';
				pc_reg <= program_counter;
				instruction <= (others => '0');
				if was_stalled = '1' and branch_signal /= BRANCH_ALWAYS then
					if just_fetched = '1' then
						--This is for actual stall.
						--When there is a branch, there is no need to reissue because the previous instruction is incorrect anyways
						SHOW("InstructionFetch issuing last instruction since a new instruction has been fetched");
						instruction <= last_instruction;
					else
						SHOW("InstructionFetch issuing no op for last instruction since no new instruction has been fetched");
						instruction <= (others => '0');
					end if;
				else
					last_instruction <= (others => '0');
					case( current_state ) is
						when FIRST_CONTACT =>
							do_read <= '1';
							is_busy <= '1';
							current_state <= FETCHING;
						when FETCHING =>
							SHOW("InstructionFetch FETCHING " & INTEGER'image(TO_INTEGER(UNSIGNED(program_counter))));
							case( branch_signal ) is
								when BRANCH_NOT =>
									if is_mem_busy = '0' then
										got_fetch;
										current_state <= INSTRUCTION_RECEIVED;
									else
										do_read <= '1';
										is_busy <= '1';
										current_state <= FETCHING;
									end if;
								when BRANCH_ALWAYS =>
									is_busy <= '1';
									do_read <= '0'; -- assume is_mem_busy is going to be clear next clock cycle
									address <= branch_address;
									program_counter <= branch_address;
									current_state <= FETCH_BRANCH_SET;
								when others =>
							end case;
						when INSTRUCTION_RECEIVED =>
							SHOW("InstructionFetch INSTRUCTION_RECEIVED " & INTEGER'image(TO_INTEGER(UNSIGNED(program_counter))));
							case( branch_signal ) is
								when BRANCH_NOT =>
									if is_mem_busy = '0' then
										got_fetch;
										current_state <= INSTRUCTION_RECEIVED;
									else
										do_read <= '1';
										is_busy <= '1';
										current_state <= FETCHING;
									end if;
								when BRANCH_ALWAYS =>
									SHOW("InstructionFetch Leaving for BRANCH");
									do_read <= '0';
									is_busy <= '1';
									address <= branch_address;
									program_counter <= branch_address;
									current_state <= FETCH_BRANCH_SET;
								when others =>
							end case;
						when BRANCHED_INSTRUCTION_RECEIVED =>
							SHOW("InstructionFetch BRANCHED_INSTRUCTION_RECEIVED " & INTEGER'image(TO_INTEGER(UNSIGNED(program_counter))));
							if is_mem_busy = '0' then
								got_fetch;
								current_state <= FETCHING;
							else
								do_read <= '1';
								is_busy <= '1';
								current_state <= FETCHING;
							end if;
						when FETCH_BRANCH_SET =>
							SHOW("InstructionFetch Doing BRANCH " & INTEGER'image(TO_INTEGER(UNSIGNED(program_counter))));
							do_read <= '1';
							is_busy <= '1';
							current_state <= FETCH_BRANCH;
						when FETCH_BRANCH =>
							SHOW("InstructionFetch Fetching branch " & INTEGER'image(TO_INTEGER(UNSIGNED(program_counter))));
							if is_mem_busy = '0' then
								got_fetch;
								current_state <= BRANCHED_INSTRUCTION_RECEIVED;
							else
								do_read <= '1';
								is_busy <= '1';
								current_state <= FETCH_BRANCH;
							end if;
						when others =>
					end case ;
				end if;
			end if;
		end if;
	end process;


end behavioral;
