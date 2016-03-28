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
END PACKAGE;

PACKAGE BODY StallUtil IS
	FUNCTION SHOULD_STALL (
			destination_register : in REGISTER_INDEX;
			previous_destinations_output : in previous_destination_array;
			previous_sources_output : in previous_source_arrray
		) RETURN STD_LOGIC is
		VARIABLE result : STD_LOGIC;
	BEGIN
		--Stall if lw, sw, lb, sb are previous instruction and this instruction is dependent on those
		if (destination_register /= "00000" and destination_register = previous_destinations_output(2) and previous_sources_output(2) = FORWARD_SOURCE_MEM) then
			result := '1';
		else
			result := '0';
		end if;

		RETURN result;
	END SHOULD_STALL;
END StallUtil;