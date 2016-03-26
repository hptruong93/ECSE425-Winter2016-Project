
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
			mem_writeback_register : in STD_LOGIC_VECTOR(5-1 downto 0); --sent from decoder

			
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
	--registers(to_integer(unsigned(mem_writeback_register))) <= STD_LOGIC_VECTOR(destination_reg);

	synced_clock : process(clk, reset)
	begin
		if reset = '1' then
			registers(0) <= (others => '0');
			registers(1) <= (others => '0');
			registers(2) <= (others => '0');
			registers(3) <= (others => '0');
			registers(4) <= (others => '0');
			registers(5) <= (others => '0');
			registers(6) <= (others => '0');
			registers(10) <= (others => '0');
			registers(11) <= (others => '0');
			registers(12) <= (others => '0');
			registers(13) <= (others => '0');
			registers(14) <= (others => '0');
			registers(15) <= (others => '0');
			registers(16) <= (others => '0');
			registers(17) <= (others => '0');
			registers(18) <= (others => '0');
			registers(19) <= (others => '0');
			registers(20) <= (others => '0');
			registers(21) <= (others => '0');
			registers(22) <= (others => '0');
			registers(23) <= (others => '0');
			registers(24) <= (others => '0');
			registers(25) <= (others => '0');
			registers(26) <= (others => '0');
			registers(27) <= (others => '0');
			registers(28) <= (others => '0');
			registers(29) <= (others => '0');
			registers(30) <= (others => '0');
			registers(31) <= (others => '0');
			current_state <= IDLE;
		elsif (rising_edge(clk)) then
			current_state <= current_state;

			case( current_state ) is
				when IDLE =>
					case( writeback_source ) is
						when LO_AS_SOURCE =>
							registers(to_integer(unsigned(mem_writeback_register))) <= STD_LOGIC_VECTOR(lo_reg);
						when HI_AS_SOURCE =>
							registers(to_integer(unsigned(mem_writeback_register))) <= STD_LOGIC_VECTOR(hi_reg);
						when ALU_AS_SOURCE =>
							REPORT "Here Justin Bieber " & integer'image(to_integer(signed(alu_output)));
							REPORT "Here Kanye West " & integer'image(to_integer(unsigned(mem_writeback_register)));
							registers(to_integer(unsigned(mem_writeback_register))) <= STD_LOGIC_VECTOR(alu_output);
						when MEM_AS_SOURCE | MEM_BYTE_AS_SOURCE =>
							if mem_stage_busy = '0' then
								registers(to_integer(unsigned(mem_writeback_register))) <= STD_LOGIC_VECTOR(signed(mem_stage_output));
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
