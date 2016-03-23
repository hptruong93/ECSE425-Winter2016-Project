
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.register_array.all;

entity MemStage is
port (	clk 	: in STD_LOGIC;
			reset : in STD_LOGIC;
			

			mem_address : in SIGNED(32-1 downto 0); -- coming from ALU
			--operation : out STD_LOGIC_VECTOR(6-1 downto 0);
			mem_writeback_register : in STD_LOGIC_VECTOR(5-1 downto 0); -- used for store, tells which register to read from.
			registers : in register_array;
			signal_to_mem : in STD_LOGIC_VECTOR(3-1 downto 0);

			is_mem_busy : in STD_LOGIC;
			do_read : out STD_LOGIC;
			do_write : out	STD_LOGIC;
			is_busy : out STD_LOGIC;
			data_line : inout STD_LOGIC_VECTOR(32-1 downto 0)
	);
end MemStage;

architecture behavioral of MemStage is

type state is (
	MEM_WAIT,
	MEM_ACCESS
	);
signal current_state : state;

begin
	synced_clock : process(clk, reset)
	begin
		if reset = '1' then
			
		elsif (rising_edge(clk)) then
			current_state <= current_state;
			do_read <= '0';
			do_write <= '0';

			case( signal_to_mem ) is
				when LOAD_WORD =>
					case( current_state ) is
						when MEM_WAIT =>
							if (is_mem_busy = '0') then
								do_read <= '1';
								is_busy <= '1';
								current_state <= MEM_ACCESS;
							end if;
						when MEM_ACCESS =>
							if (is_mem_busy = '0') then
								is_busy <= '0';
								current_state <= MEM_WAIT;
							end if;
					end case ;

				when STORE_WORD =>
					case( current_state ) is
						when MEM_WAIT =>
							if (is_mem_busy = '0') then
								do_write <= '1';
								is_busy <= '1';
								current_state <= MEM_ACCESS;
							end if;
						when MEM_ACCESS =>
							if (is_mem_busy = '0') then
								is_busy <= '0';
								current_state <= MEM_WAIT;
							end if;
					end case;
				when LOAD_BYTE =>
					case( current_state ) is
						when MEM_WAIT =>
							if (is_mem_busy = '0') then
								do_write <= '1';
								is_busy <= '1';
								current_state <= MEM_ACCESS;
							end if;
						when MEM_ACCESS =>
							if (is_mem_busy = '0') then
								is_busy <= '0';

								if data_line(7) = '1' then
									data_line(31 downto 8) <= "111111111111111111111111";
								else
									data_line(31 downto 8) <= "000000000000000000000000";
								end if;
								data_line(31) <= data_line(7);
								current_state <= MEM_WAIT;
							end if;
					end case;
				when STORE_BYTE => --TODO: Do we overwrite
					case( current_state ) is
						when MEM_WAIT =>
							if (is_mem_busy = '0') then
								do_write <= '1';
								is_busy <= '1';
								current_state <= MEM_ACCESS;
							end if;
						when MEM_ACCESS =>
							if (is_mem_busy = '0') then
								is_busy <= '0';
								current_state <= MEM_WAIT;
							end if;
					end case;
				when MEM_IDLE =>
					current_state <= MEM_WAIT;
				when others =>
			
			end case ;
		end if;
	end process ; -- synced_clock
	

end behavioral;
