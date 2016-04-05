library IEEE;
USE ieee.STD_LOGIC_1164.all;
USE ieee.numeric_std.all;
USE work.register_array.all;

PACKAGE ForwardingUtil is
	TYPE previous_alu_array is array(0 to 2) of SIGNED(32-1 downto 0);
	TYPE previous_destination_array is array(0 to 2) of STD_LOGIC_VECTOR(5-1 downto 0);
	TYPE previous_source_arrray is array(0 to 2) of STD_LOGIC;

	CONSTANT FORWARD_SOURCE_ALU : STD_LOGIC := '0';
	CONSTANT FORWARD_SOURCE_MEM : STD_LOGIC := '1';

END ForwardingUtil;
