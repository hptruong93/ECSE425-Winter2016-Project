
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.register_array.all;

entity WriteBack is
port (	clk 	: in STD_LOGIC;
			reset : in STD_LOGIC;
			
			lo_reg : in signed (32-1 downto 0);
			hi_reg : in signed (32-1 downto 0);

			writeback_source : in STD_LOGIC_VECTOR(3-1 downto 0); --sent from decoder
			alu_output : in signed(32-1 downto 0);
			mem_stage_busy : in STD_LOGIC;
			mem_stage_output : in STD_LOGIC_VECTOR(32-1 downto 0);
			mem_writeback_register : in STD_LOGIC_VECTOR(5-1 downto 0); --sent fromm decoder

			
			registers : out register_array
	);
end WriteBack;

architecture behavioral of WriteBack is

type state is (
	IDLE,
	MEM_WAIT
	);
signal current_state : state;

signal destination_reg : signed(32-1 downto 0);

begin
	synced_clock : process(clk, reset)
	begin
		if reset = '1' then
			
		elsif (rising_edge(clk)) then
			registers(to_integer(unsigned(mem_writeback_register))) <= STD_LOGIC_VECTOR(destination_reg);
			current_state <= current_state;

			case( current_state ) is
				when IDLE =>
					case( writeback_source ) is
						when LO_AS_SOURCE =>
							destination_reg <= lo_reg;
						when HI_AS_SOURCE =>
							destination_reg <= hi_reg;
						when ALU_AS_SOURCE =>
							destination_reg <= alu_output;
						when MEM_AS_SOURCE | MEM_BYTE_AS_SOURCE =>
							if mem_stage_busy = '0' then
								destination_reg <= signed(mem_stage_output);
							else
								current_state <= MEM_WAIT;
							end if;
						when NO_WRITE_BACK =>
						when others =>
					end case ;

				when MEM_WAIT =>
					if mem_stage_busy = '0' then
						current_state <= IDLE;
					end if;

				when others =>
			
			end case ;

		end if;
	end process ; -- synced_clock
	

end behavioral;
