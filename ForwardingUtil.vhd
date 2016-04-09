library IEEE;
USE ieee.STD_LOGIC_1164.all;
USE ieee.numeric_std.all;
USE work.register_array.all;

PACKAGE ForwardingUtil is
	SUBTYPE FORWARD_SOURCE_TYPE IS STD_LOGIC_VECTOR(2-1 downto 0);
	TYPE previous_alu_array is array(0 to 2) of SIGNED(32-1 downto 0);
	TYPE previous_destination_array is array(0 to 2) of STD_LOGIC_VECTOR(5-1 downto 0);
	TYPE previous_source_arrray is array(0 to 2) of FORWARD_SOURCE_TYPE;

	CONSTANT FORWARD_SOURCE_LO : FORWARD_SOURCE_TYPE := "00";
	CONSTANT FORWARD_SOURCE_HI : FORWARD_SOURCE_TYPE := "01";
	CONSTANT FORWARD_SOURCE_ALU : FORWARD_SOURCE_TYPE := "10";
	CONSTANT FORWARD_SOURCE_MEM : FORWARD_SOURCE_TYPE := "11";

END ForwardingUtil;
