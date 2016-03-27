
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

			alu_output : in SIGNED(32-1 downto 0);
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

begin
	alu_source1 <= alu_output when ((previous_destinations(1) = data1_register) and (previous_destinations(1) /= "00000") and (previous_sources(1) = FORWARD_SOURCE_ALU)) else
						SIGNED(mem_output) when ((previous_destinations(0) = data1_register) and (previous_destinations(0) /= "00000") and (previous_sources(0) = FORWARD_SOURCE_MEM)) else
						data1_decoder;

	alu_source2 <= alu_output when ((previous_destinations(1) = data2_register) and (previous_destinations(1) /= "00000") and (previous_sources(1) = FORWARD_SOURCE_ALU)) else
						SIGNED(mem_output) when ((previous_destinations(0) = data2_register) and (previous_destinations(0) /= "00000") and (previous_sources(0) = FORWARD_SOURCE_MEM)) else
						data2_decoder;

	source1_result <= 6 when ((previous_destinations(1) = data1_register) and (previous_destinations(1) /= "00000") and (previous_sources(1) = FORWARD_SOURCE_ALU)) else
						7 when ((previous_destinations(0) = data1_register) and (previous_destinations(0) /= "00000") and (previous_sources(0) = FORWARD_SOURCE_MEM)) else
						8;
	source2_result <= 6 when ((previous_destinations(1) = data1_register) and (previous_destinations(1) /= "00000") and (previous_sources(1) = FORWARD_SOURCE_ALU)) else
						7 when ((previous_destinations(0) = data1_register) and (previous_destinations(0) /= "00000") and (previous_sources(0) = FORWARD_SOURCE_MEM)) else
						8;


	synced_clock : process(clk)
	begin
		if (rising_edge(clk)) then
			SHOW("Source 1 result is " & INTEGER'image(source1_result));
			SHOW("Source 1 reg is " & INTEGER'image(TO_INTEGER(UNSIGNED(data1_register))));
			SHOW("Preivous 1 reg is " & INTEGER'image(TO_INTEGER(UNSIGNED(previous_destinations(1)))));

			SHOW("Source 2 result is " & INTEGER'image(source2_result));
			SHOW("Source 2 reg is " & INTEGER'image(TO_INTEGER(UNSIGNED(data2_register))));
			SHOW("Preivous 2 reg is " & INTEGER'image(TO_INTEGER(UNSIGNED(previous_destinations(1)))));
		end if;
	end process ; -- synced_clock

end architecture;