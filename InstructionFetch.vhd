
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.register_array.all;
use ieee.numeric_std_unsigned.all;

entity InstructionFetch is
port (	clk 	: in STD_LOGIC;
			reset : in STD_LOGIC;

			branch_signal : in  STD_LOGIC_VECTOR(2-1 downto 0);
			branch_address : in STD_LOGIC_VECTOR(32-1 downto 0); --from decoder and ALU
			data : in STD_LOGIC_VECTOR(32-1 downto 0); --from memory

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
	FETCH_BRANCH_SET,
	FETCH_BRANCH
	);
signal current_state : state;

signal program_counter : STD_LOGIC_VECTOR(32-1 downto 0);

begin
	--instruction <= data;
	synced_clock : process(clk, reset)
	begin
		if reset = '1' then
			instruction <= (others => '0');
			current_state <= FIRST_CONTACT;
			address <= program_counter;
			pc_reg <= (others => '0');
		elsif (rising_edge(clk)) then
			pc_reg <= program_counter;
			case( current_state ) is
				when FIRST_CONTACT =>
					do_read <= '1';
					is_busy <= '1';
					current_state <= FETCHING;
				when FETCHING =>
					case( branch_signal ) is
						when BRANCH_NOT =>
							if is_mem_busy = '0' then
								program_counter <= program_counter + 4;
								address <= program_counter + 4;
								do_read <= '1';
								is_busy <= '0';
								instruction <= data;
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
					--In this state, it is guaranteed (?) that is_mem_busy is low, since we just issued the 
					case( branch_signal ) is
						when BRANCH_NOT =>
							do_read <= '1';
							is_busy <= '1';
							current_state <= FETCHING;
						when BRANCH_ALWAYS =>
							do_read <= '0';
							is_busy <= '1';
							address <= branch_address;
							program_counter <= branch_address;
							current_state <= FETCH_BRANCH_SET;
						when others =>
					end case;
				when FETCH_BRANCH_SET =>
					do_read <= '1';
					is_busy <= '1';
					current_state <= FETCH_BRANCH;
				when FETCH_BRANCH =>
					if is_mem_busy = '0' then
						program_counter <= program_counter + 4;
						address <= program_counter + 4;
						do_read <= '1';
						instruction <= data;
						is_busy <= '0';
						current_state <= INSTRUCTION_RECEIVED;
					else
						do_read <= '1';
						is_busy <= '1';
						current_state <= FETCH_BRANCH;
					end if;
				when others =>
			end case ;
		end if;
	end process;
	

end behavioral;
