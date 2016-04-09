
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

			--Testing and observing purpose. Not supposed to expose this
			registers : out register_array
	);
end WriteBack;

architecture behavioral of WriteBack is

type state is (
	IDLE,
	MEM_WAIT
	);
signal current_state : state;

signal destination_reg : STD_LOGIC_VECTOR(5-1 downto 0) := (others => '0');

begin
	synced_clock : process(clk, reset)
	begin
		if reset = '1' then
			registers(0) <= (others => '0');
			registers(1) <= (others => '0');--STD_LOGIC_VECTOR(TO_UNSIGNED(1, 32));
			registers(2) <= (others => '0');--STD_LOGIC_VECTOR(TO_UNSIGNED(2, 32));
			registers(3) <= (others => '0');--STD_LOGIC_VECTOR(TO_UNSIGNED(3, 32));
			registers(4) <= (others => '0');
			registers(5) <= (others => '0');
			registers(6) <= (others => '0');
			registers(7) <= (others => '0');
			registers(8) <= (others => '0');
			registers(9) <= (others => '0');
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
			registers(23) <= (others => '0');--STD_LOGIC_VECTOR(TO_UNSIGNED(23, 32));--(others => '0');
			registers(24) <= (others => '0');--STD_LOGIC_VECTOR(TO_UNSIGNED(24, 32));
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
							--SHOW("WRITE BACK lo as source " & INTEGER'image(TO_INTEGER(UNSIGNED(STD_LOGIC_VECTOR(lo_reg)))), "and mem_writeback_register " & integer'image(to_integer(unsigned(mem_writeback_register))));
							SHOW("WRITE BACK lo as source " & INTEGER'image(TO_INTEGER(UNSIGNED(STD_LOGIC_VECTOR(lo_reg)))), "--> $" & integer'image(to_integer(unsigned(mem_writeback_register))));
							registers(to_integer(unsigned(mem_writeback_register))) <= STD_LOGIC_VECTOR(lo_reg);
						when HI_AS_SOURCE =>
							--SHOW("WRITE BACK high as source " & INTEGER'image(TO_INTEGER(UNSIGNED(STD_LOGIC_VECTOR(hi_reg)))), "and mem_writeback_register " & integer'image(to_integer(unsigned(mem_writeback_register))));
							SHOW("WRITE BACK high as source " & INTEGER'image(TO_INTEGER(UNSIGNED(STD_LOGIC_VECTOR(hi_reg)))), "--> $" & integer'image(to_integer(unsigned(mem_writeback_register))));
							registers(to_integer(unsigned(mem_writeback_register))) <= STD_LOGIC_VECTOR(hi_reg);
						when ALU_AS_SOURCE =>
							--SHOW("WRITE BACK alu output " & integer'image(to_integer(signed(alu_output))), "and mem_writeback_register " & integer'image(to_integer(unsigned(mem_writeback_register))));
							SHOW("WRITE BACK alu as source " & integer'image(to_integer(signed(alu_output))), "--> $" & integer'image(to_integer(unsigned(mem_writeback_register))));
							registers(to_integer(unsigned(mem_writeback_register))) <= STD_LOGIC_VECTOR(alu_output);
						when MEM_AS_SOURCE | MEM_BYTE_AS_SOURCE =>
							--SHOW("WRITE BACK mem output " & integer'image(to_integer(signed(mem_stage_output))), "and mem_writeback_register " & integer'image(to_integer(unsigned(mem_writeback_register))));
							SHOW("WRITE BACK mem as source " & integer'image(to_integer(signed(mem_stage_output))), "--> $" & integer'image(to_integer(unsigned(mem_writeback_register))));

							--At the cycle that write back receives this signal, mem stage is just starting.
							--Therefore there is no way for write back unit to write back at this point. We have to wait for at least
							--one cycle

							--if mem_stage_busy = '0' then
								--registers(to_integer(unsigned(mem_writeback_register))) <= STD_LOGIC_VECTOR(signed(mem_stage_output));
							--else
							destination_reg <= mem_writeback_register;
							current_state <= MEM_WAIT;
							--end if;
						when NO_WRITE_BACK =>
							SHOW("NO WRITE BACK");
						when others =>
							SHOW("WRITE BACK UNKOWN STATE");
					end case ;

				when MEM_WAIT =>
					if mem_stage_busy = '0' then
						current_state <= IDLE;

						if writeback_source /= NO_WRITE_BACK then
							SHOW_LOVE("Writing back the value ", STD_LOGIC_VECTOR(signed(mem_stage_output)));
							SHOW("WRITE BACK FROM MEM TO REGISTER " & integer'image(to_integer(unsigned(destination_reg))));
							registers(to_integer(unsigned(destination_reg))) <= STD_LOGIC_VECTOR(signed(mem_stage_output));
						else
							SHOW("WRITE BACK SKIP BECAUSE OF STORE.");
						end if;
					else
						SHOW("WRITE BACK WAITING FOR MEM");
					end if;

				when others =>

			end case ;

		end if;
	end process ; -- synced_clock


end behavioral;
