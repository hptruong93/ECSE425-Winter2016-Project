
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.register_array.all;
use work.ForwardingUtil.all;

entity Forwarding is
port (
			clk : in STD_LOGIC;

			previous_destinations : previous_destination_array;
			previous_sources : previous_source_arrray;

			alu_buffered_output : in previous_alu_array;
			mem_output : in STD_LOGIC_VECTOR(32-1 downto 0);

			data1_decoder : in SIGNED(32-1 downto 0);
			data2_decoder : in SIGNED(32-1 downto 0);

			data1_register : in STD_LOGIC_VECTOR(5-1 downto 0);
			data2_register : in STD_LOGIC_VECTOR(5-1 downto 0);

			alu_source1 : out SIGNED(32-1 downto 0);
			alu_source2 : out SIGNED(32-1 downto 0)
	);
end Forwarding;

architecture behavioral of Forwarding is

signal source1_result : INTEGER := 0;
signal source2_result : INTEGER := 0;
signal debug1 : STD_LOGIC;

begin
	--Since the alu_buffered_output is not yet updated at this stage (recall that this unit is between Decode and ALU), the alu_buffered_output will be one cycle behind.
	--Therefore, alu_buffered_output(n) will be forwarded to the previous_destinations(n - 1)
	alu_source1 <= alu_buffered_output(1) when ((previous_destinations(1) = data1_register) and (previous_destinations(1) /= "00000") and (previous_sources(1) = FORWARD_SOURCE_ALU)) else
						--alu_buffered_output(1) when ((previous_destinations(0) = data1_register) and (previous_destinations(0) /= "00000") and (previous_sources(0) = FORWARD_SOURCE_ALU)) else
						SIGNED(mem_output) when ((previous_destinations(1) = data1_register) and (previous_destinations(1) /= "00000") and (previous_sources(1) = FORWARD_SOURCE_MEM)) else
						data1_decoder;

	alu_source2 <= alu_buffered_output(1) when ((previous_destinations(1) = data2_register) and (previous_destinations(1) /= "00000") and (previous_sources(1) = FORWARD_SOURCE_ALU)) else
						--alu_buffered_output(1) when ((previous_destinations(0) = data2_register) and (previous_destinations(0) /= "00000") and (previous_sources(0) = FORWARD_SOURCE_ALU)) else
						SIGNED(mem_output) when ((previous_destinations(1) = data2_register) and (previous_destinations(1) /= "00000") and (previous_sources(1) = FORWARD_SOURCE_MEM)) else
						data2_decoder;

	--Testing
	--source1_result <= 6 when ((previous_destinations(1) = data1_register) and (previous_destinations(1) /= "00000") and (previous_sources(1) = FORWARD_SOURCE_ALU)) else
	--					7 when ((previous_destinations(0) = data1_register) and (previous_destinations(0) /= "00000") and (previous_sources(0) = FORWARD_SOURCE_ALU)) else
	--					8 when ((previous_destinations(0) = data1_register) and (previous_destinations(0) /= "00000") and (previous_sources(0) = FORWARD_SOURCE_MEM)) else
	--					9;

	--source2_result <= 6 when ((previous_destinations(1) = data2_register) and (previous_destinations(1) /= "00000") and (previous_sources(1) = FORWARD_SOURCE_ALU)) else
	--					7 when ((previous_destinations(0) = data2_register) and (previous_destinations(0) /= "00000") and (previous_sources(0) = FORWARD_SOURCE_ALU)) else
	--					8 when ((previous_destinations(0) = data2_register) and (previous_destinations(0) /= "00000") and (previous_sources(0) = FORWARD_SOURCE_MEM)) else
	--					9;

	--debug1 <= '1' when (previous_destinations(0) = data2_register) and (previous_destinations(0) /= "00000") and (previous_sources(0) = FORWARD_SOURCE_ALU) else '0';

	synced_clock : process(clk)
	begin
		if (clk'event and clk = '0') then
			--SHOW("Source 1 result is " & INTEGER'image(source1_result));
			--SHOW("FORWARDING: Source 1 reg is " & INTEGER'image(TO_INTEGER(UNSIGNED(data1_register))));

			----SHOW("FORWARDING: Source 2 result is " & INTEGER'image(source2_result));
			--SHOW("FORWARDING: Source 2 reg is " & INTEGER'image(TO_INTEGER(UNSIGNED(data2_register))));

			--SHOW("FORWARDING: ++++++Destinations are " & INTEGER'image(TO_INTEGER(UNSIGNED(previous_destinations(0)))) & INTEGER'image(TO_INTEGER(UNSIGNED(previous_destinations(1)))) & INTEGER'image(TO_INTEGER(UNSIGNED(previous_destinations(2)))));
			--SHOW("FORWARDING: ++++++Sources are " & STD_LOGIC'image(previous_sources(0)) & STD_LOGIC'image(previous_sources(1)) & STD_LOGIC'image(previous_sources(2)));
			--SHOW("FORWARDING: =====ALUs are " & INTEGER'image(TO_INTEGER(SIGNED(alu_buffered_output(0)))) & INTEGER'image(TO_INTEGER(SIGNED(alu_buffered_output(1)))) & INTEGER'image(TO_INTEGER(SIGNED(alu_buffered_output(2)))));

			--if ((previous_destinations(0) = data2_register) and (previous_destinations(0) /= "00000") and (previous_sources(0) = FORWARD_SOURCE_ALU)) then
			--	SHOW("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
			--end if;
		end if;
	end process ; -- synced_clock

end architecture;