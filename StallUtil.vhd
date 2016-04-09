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
		SHOW("STALL: PREVIOUSES ARE " & INTEGER'image(TO_INTEGER(UNSIGNED(previous_sources_output(0)))),
											""	& INTEGER'image(TO_INTEGER(UNSIGNED(previous_sources_output(1)))),
											""	& INTEGER'image(TO_INTEGER(UNSIGNED(previous_sources_output(2)))));

		--Stall if lw, sw, lb, sb are previous instruction and this instruction is dependent on those
		if previous_sources_output(2) = FORWARD_SOURCE_MEM then
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
		SHOW("STALL BRANCH: PREVIOUSES ARE " & INTEGER'image(TO_INTEGER(UNSIGNED(previous_sources_output(0)))),
											""	& INTEGER'image(TO_INTEGER(UNSIGNED(previous_sources_output(1)))),
											""	& INTEGER'image(TO_INTEGER(UNSIGNED(previous_sources_output(2)))));
		SHOW("STALL BRANCH: Destinations are " & INTEGER'image(TO_INTEGER(UNSIGNED(destination_register_1))), " and " & INTEGER'image(TO_INTEGER(UNSIGNED(destination_register_2))));

		--Stall if destination_register_1 or destination_register_2 is the destination of the instruction right before us
		if (destination_register_1 /= "00000" and destination_register_1 = previous_destinations_output(2) and previous_sources_output(2) = FORWARD_SOURCE_ALU) or
			(destination_register_2 /= "00000" and destination_register_2 = previous_destinations_output(2) and previous_sources_output(2) = FORWARD_SOURCE_ALU) then
			SHOW("STALL: DECODER STALL DUE TO BRANCH. Dependency at 2.");
			result := '1';
		elsif (destination_register_1 /= "00000" and destination_register_1 = previous_destinations_output(1) and previous_sources_output(1) = FORWARD_SOURCE_ALU) or
			(destination_register_2 /= "00000" and destination_register_2 = previous_destinations_output(1) and previous_sources_output(1) = FORWARD_SOURCE_ALU) then
			SHOW("STALL: DECODER STALL DUE TO BRANCH. Dependency at 1.");
			result := '1';
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		------------------------------------------Special cases for lo and hi registers----------------------------------------------------------------------
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		elsif (destination_register_1 /= "00000" and destination_register_1 = previous_destinations_output(2) and previous_sources_output(2) = FORWARD_SOURCE_HI) or
			(destination_register_2 /= "00000" and destination_register_2 = previous_destinations_output(2) and previous_sources_output(2) = FORWARD_SOURCE_HI) then
			SHOW("STALL: DECODER STALL DUE TO BRANCH. Dependency at 2.");
			result := '1';
		elsif (destination_register_1 /= "00000" and destination_register_1 = previous_destinations_output(1) and previous_sources_output(1) = FORWARD_SOURCE_HI) or
			(destination_register_2 /= "00000" and destination_register_2 = previous_destinations_output(1) and previous_sources_output(1) = FORWARD_SOURCE_HI) then
			SHOW("STALL: DECODER STALL DUE TO BRANCH. Dependency at 1.");
			result := '1';
		elsif (destination_register_1 /= "00000" and destination_register_1 = previous_destinations_output(2) and previous_sources_output(2) = FORWARD_SOURCE_LO) or
			(destination_register_2 /= "00000" and destination_register_2 = previous_destinations_output(2) and previous_sources_output(2) = FORWARD_SOURCE_LO) then
			SHOW("STALL: DECODER STALL DUE TO BRANCH. Dependency at 2.");
			result := '1';
		elsif (destination_register_1 /= "00000" and destination_register_1 = previous_destinations_output(1) and previous_sources_output(1) = FORWARD_SOURCE_LO) or
			(destination_register_2 /= "00000" and destination_register_2 = previous_destinations_output(1) and previous_sources_output(1) = FORWARD_SOURCE_LO) then
			SHOW("STALL: DECODER STALL DUE TO BRANCH. Dependency at 1.");
			result := '1';
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		--elsif (destination_register_1 /= "00000" and destination_register_1 = previous_destinations_output(0) and previous_sources_output(0) = FORWARD_SOURCE_ALU) or
		--	(destination_register_2 /= "00000" and destination_register_2 = previous_destinations_output(0) and previous_sources_output(0) = FORWARD_SOURCE_ALU) then
		--	result := '1';
		else
			SHOW("STALL: DECODER NOT STALL DUE TO BRANCH");
			result := '0';
		end if;

		RETURN result;
	END SHOULD_STALL_BRANCH;
END StallUtil;