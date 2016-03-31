library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.register_array.all;
use work.ForwardingUtil.all;

PACKAGE StallUtil is
	FUNCTION SHOULD_STALL (
			destination_register : in REGISTER_INDEX;
			previous_destinations_output : in previous_destination_array;
			previous_sources_output : in previous_source_arrray
		) RETURN STD_LOGIC;

	FUNCTION SHOULD_STALL_BRANCH (
			destination_register_1 : in REGISTER_INDEX;
			destination_register_2 : in REGISTER_INDEX;
			previous_destinations_output : in previous_destination_array;
			previous_sources_output : in previous_source_arrray
		) RETURN STD_LOGIC;
END PACKAGE;

PACKAGE BODY StallUtil IS
	FUNCTION SHOULD_STALL (
			destination_register : in REGISTER_INDEX;
			previous_destinations_output : in previous_destination_array;
			previous_sources_output : in previous_source_arrray
		) RETURN STD_LOGIC is
		VARIABLE result : STD_LOGIC;
	BEGIN
		SHOW("STALL PREVIOUSES ARE " & STD_LOGIC'IMAGE(previous_sources_output(2)) & STD_LOGIC'IMAGE(previous_sources_output(1)) & STD_LOGIC'IMAGE(previous_sources_output(0)));
		SHOW("STALL REGVIOUSES ARE " & INTEGER'image(TO_INTEGER(UNSIGNED(previous_destinations_output(2)))) & INTEGER'image(TO_INTEGER(UNSIGNED(previous_destinations_output(1)))) & INTEGER'image(TO_INTEGER(UNSIGNED(previous_destinations_output(0)))));

		--Stall if lw, sw, lb, sb are previous instruction and this instruction is dependent on those
		if (destination_register /= "00000" and destination_register = previous_destinations_output(2) and previous_sources_output(2) = FORWARD_SOURCE_MEM) then
			result := '1';
		elsif previous_sources_output(1) = FORWARD_SOURCE_MEM then
			result := '1';
		else
			result := '0';
		end if;

		RETURN result;
	END SHOULD_STALL;

	FUNCTION SHOULD_STALL_BRANCH (
			destination_register_1 : in REGISTER_INDEX;
			destination_register_2 : in REGISTER_INDEX;
			previous_destinations_output : in previous_destination_array;
			previous_sources_output : in previous_source_arrray
		) RETURN STD_LOGIC is
		VARIABLE result : STD_LOGIC;
	BEGIN
		SHOW("STALL PREVIOUSES ARE " & STD_LOGIC'IMAGE(previous_sources_output(2)) & STD_LOGIC'IMAGE(previous_sources_output(1)) & STD_LOGIC'IMAGE(previous_sources_output(0)));
		SHOW("STALL REGVIOUSES ARE " & INTEGER'image(TO_INTEGER(UNSIGNED(previous_destinations_output(2)))) & INTEGER'image(TO_INTEGER(UNSIGNED(previous_destinations_output(1)))) & INTEGER'image(TO_INTEGER(UNSIGNED(previous_destinations_output(0)))));

		--Stall if destination_register_1 or destination_register_2 is the destination of the instruction right before us
		if (destination_register_1 /= "00000" and destination_register_1 = previous_destinations_output(1) and previous_sources_output(1) = FORWARD_SOURCE_ALU) or
			(destination_register_2 /= "00000" and destination_register_2 = previous_destinations_output(1) and previous_sources_output(1) = FORWARD_SOURCE_ALU) then
			SHOW("DECODER STALL DUE TO BRANCH");
			result := '1';
		elsif (destination_register_1 /= "00000" and destination_register_1 = previous_destinations_output(0) and previous_sources_output(0) = FORWARD_SOURCE_ALU) or
			(destination_register_2 /= "00000" and destination_register_2 = previous_destinations_output(0) and previous_sources_output(0) = FORWARD_SOURCE_ALU) then
			result := '1';
		else
			SHOW("DECODER NOT STALL DUE TO BRANCH");
			result := '0';
		end if;

		RETURN result;
	END SHOULD_STALL_BRANCH;
END StallUtil;