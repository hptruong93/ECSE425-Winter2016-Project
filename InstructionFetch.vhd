
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

begin
	--instruction <= data;
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

	begin
		if reset = '1' then
			instruction <= (others => '0');
			current_state <= FIRST_CONTACT;
			address <= program_counter;
			pc_reg <= (others => '0');
			last_instruction <= (others => '0');
		elsif (rising_edge(clk)) then
			if do_stall = '1' then
				SHOW("InstructionFetch STALLING");
				instruction <= last_instruction;
			else
				pc_reg <= program_counter;
				instruction <= (others => '0');
				SHOW("Fetching " & INTEGER'image(TO_INTEGER(UNSIGNED(program_counter))));

				case( current_state ) is
					when FIRST_CONTACT =>
						do_read <= '1';
						is_busy <= '1';
						current_state <= FETCHING;
					when FETCHING =>
						SHOW("IS fetching");
						case( branch_signal ) is
							when BRANCH_NOT =>
								if is_mem_busy = '0' then
									SHOW("GOT FETCH " & INTEGER'image(TO_INTEGER(UNSIGNED(program_counter))) & STD_LOGIC'image(data(31)) & STD_LOGIC'image(data(30)) & STD_LOGIC'image(data(29)) & STD_LOGIC'image(data(28)) & STD_LOGIC'image(data(27)) & STD_LOGIC'image(data(26)) & STD_LOGIC'image(data(25)) & STD_LOGIC'image(data(24)) & STD_LOGIC'image(data(23)) & STD_LOGIC'image(data(22)) & STD_LOGIC'image(data(21)) & STD_LOGIC'image(data(20)) & STD_LOGIC'image(data(19)) & STD_LOGIC'image(data(18)) & STD_LOGIC'image(data(17)) & STD_LOGIC'image(data(16)) & STD_LOGIC'image(data(15)) & STD_LOGIC'image(data(14)) & STD_LOGIC'image(data(13)) & STD_LOGIC'image(data(12)) & STD_LOGIC'image(data(11)) & STD_LOGIC'image(data(10)) & STD_LOGIC'image(data(9)) & STD_LOGIC'image(data(8)) & STD_LOGIC'image(data(7)) & STD_LOGIC'image(data(6)) & STD_LOGIC'image(data(5)) & STD_LOGIC'image(data(4)) & STD_LOGIC'image(data(3)) & STD_LOGIC'image(data(2)) & STD_LOGIC'image(data(1)) & STD_LOGIC'image(data(0)));
									program_counter <= program_counter + 4;
									address <= program_counter + 4;
									do_read <= '1';
									is_busy <= '0';
									update_instruction(data);
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
						SHOW("Did INSTRUCTION_RECEIVED");
						--In this state, it is guaranteed (?) that is_mem_busy is low, since we just lower read request from previous state
						case( branch_signal ) is
							when BRANCH_NOT =>
								do_read <= '1';
								is_busy <= '1';
								current_state <= FETCHING;
							when BRANCH_ALWAYS =>
								SHOW("Leaving for BRANCH");
								do_read <= '0';
								is_busy <= '1';
								address <= branch_address;
								program_counter <= branch_address;
								current_state <= FETCH_BRANCH_SET;
							when others =>
						end case;
					when BRANCHED_INSTRUCTION_RECEIVED =>
						SHOW("Did BRANCHED_INSTRUCTION_RECEIVED");
						--In this state, it is guaranteed (?) that is_mem_busy is low, since we just lower read request from previous state
						do_read <= '1';
						is_busy <= '1';
						current_state <= FETCHING;
					when FETCH_BRANCH_SET =>
						SHOW("<><><><><><><><><><><>><><><><><><><><>><><><><<><> Doing BRANCH");
						do_read <= '1';
						is_busy <= '1';
						current_state <= FETCH_BRANCH;
					when FETCH_BRANCH =>
						SHOW("Fetching branch");
						if is_mem_busy = '0' then
							SHOW("GOT BRANCH FETCH " & INTEGER'image(TO_INTEGER(UNSIGNED(program_counter))) & STD_LOGIC'image(data(31)) & STD_LOGIC'image(data(30)) & STD_LOGIC'image(data(29)) & STD_LOGIC'image(data(28)) & STD_LOGIC'image(data(27)) & STD_LOGIC'image(data(26)) & STD_LOGIC'image(data(25)) & STD_LOGIC'image(data(24)) & STD_LOGIC'image(data(23)) & STD_LOGIC'image(data(22)) & STD_LOGIC'image(data(21)) & STD_LOGIC'image(data(20)) & STD_LOGIC'image(data(19)) & STD_LOGIC'image(data(18)) & STD_LOGIC'image(data(17)) & STD_LOGIC'image(data(16)) & STD_LOGIC'image(data(15)) & STD_LOGIC'image(data(14)) & STD_LOGIC'image(data(13)) & STD_LOGIC'image(data(12)) & STD_LOGIC'image(data(11)) & STD_LOGIC'image(data(10)) & STD_LOGIC'image(data(9)) & STD_LOGIC'image(data(8)) & STD_LOGIC'image(data(7)) & STD_LOGIC'image(data(6)) & STD_LOGIC'image(data(5)) & STD_LOGIC'image(data(4)) & STD_LOGIC'image(data(3)) & STD_LOGIC'image(data(2)) & STD_LOGIC'image(data(1)) & STD_LOGIC'image(data(0)));
							program_counter <= program_counter + 4;
							address <= program_counter + 4;
							do_read <= '0';
							is_busy <= '0';
							update_instruction(data);
							last_instruction <= data;
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
	end process;


end behavioral;
