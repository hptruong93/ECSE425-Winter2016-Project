
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.numeric_std_unsigned.all;
use work.register_array.all;

PACKAGE cache_infrastructure IS
	CONSTANT CACHE_SIZE_IN_WORD : NATURAL := 128;
	CONSTANT CACHE_SIZE_BIT_COUNT : NATURAL := 7;

	subtype TAG_VALUE IS STD_LOGIC_VECTOR(32-CACHE_SIZE_BIT_COUNT-1 downto 0);
	type CACHE_DATA_TYPE IS array(0 to CACHE_SIZE_IN_WORD) of REGISTER_VALUE;
	type CACHE_TAG_TYPE IS array(0 to CACHE_SIZE_IN_WORD) of TAG_VALUE;

	CONSTANT INVALID_DATA : REGISTER_VALUE := (others => '1');

	subtype CACHE_REPLACEMENT_STRATEGY IS STD_LOGIC_VECTOR(2-1 downto 0);
	subtype CACHE_ASSOCIATIVITY_TYPE IS STD_LOGIC_VECTOR(2-1 downto 0);


	CONSTANT REPLACEMENT_RANDOM : CACHE_REPLACEMENT_STRATEGY := "00";
	CONSTANT REPLACEMENT_LRU : CACHE_REPLACEMENT_STRATEGY := "01";
	CONSTANT REPLACEMENT_FIFO : CACHE_REPLACEMENT_STRATEGY := "10";

	CONSTANT ONE_WAY_ASSOCIATIVITY : CACHE_ASSOCIATIVITY_TYPE := "00";
	CONSTANT TWO_WAY_ASSOCIATIVITY : CACHE_ASSOCIATIVITY_TYPE := "01";
	CONSTANT FOUR_WAY_ASSOCIATIVITY : CACHE_ASSOCIATIVITY_TYPE := "10";
	CONSTANT FULL_ASSOCIATIVITY : CACHE_ASSOCIATIVITY_TYPE := "11";
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

	CONSTANT CACHE_ASSOCIATIVITY : CACHE_ASSOCIATIVITY_TYPE := ONE_WAY_ASSOCIATIVITY;
	CONSTANT REPLACEMENT_STRATEGY : CACHE_REPLACEMENT_STRATEGY := REPLACEMENT_RANDOM;
END cache_infrastructure ; -- cache_infrastructure
