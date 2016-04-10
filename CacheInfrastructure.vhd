
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.numeric_std_unsigned.all;
use IEEE.MATH_REAL.ALL;
use work.register_array.all;

PACKAGE cache_infrastructure IS
	CONSTANT CACHE_ENABLED : BOOLEAN := TRUE;

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
	CONSTANT CACHE_SIZE_IN_WORD : NATURAL := 128; --always a power of 2
	CONSTANT CACHE_SIZE_BIT_COUNT : NATURAL := INTEGER(TRUNC(LOG2(REAL(CACHE_SIZE_IN_WORD)))); --number of bits of cache size in word

	subtype LRU_DATA_TYPE IS STD_LOGIC_VECTOR(CACHE_SIZE_IN_WORD-1 downto 0);
	type FIFO_DATA_TYPE IS array(0 to CACHE_SIZE_IN_WORD) of NATURAL;

	subtype TAG_VALUE_ONE_WAY_ASSOCIATIVE IS STD_LOGIC_VECTOR(32-CACHE_SIZE_BIT_COUNT-1 downto 0);
	subtype TAG_VALUE_TWO_WAY_ASSOCIATIVE IS STD_LOGIC_VECTOR(32-1 downto 0);
	subtype TAG_VALUE_FOUR_WAY_ASSOCIATIVE IS STD_LOGIC_VECTOR(32-1 downto 0);
	subtype TAG_VALUE_FULLY_ASSOCIATIVE IS STD_LOGIC_VECTOR(32-1 downto 0);

	subtype TAG_VALUE IS TAG_VALUE_FULLY_ASSOCIATIVE; --remember to change CACHE_ASSOCIATIVITY
	type CACHE_DATA_TYPE IS array(0 to CACHE_SIZE_IN_WORD) of REGISTER_VALUE;
	type CACHE_TAG_TYPE IS array(0 to CACHE_SIZE_IN_WORD) of TAG_VALUE;

	CONSTANT INVALID_DATA : REGISTER_VALUE := (others => '1');

	subtype CACHE_REPLACEMENT_STRATEGY IS STD_LOGIC_VECTOR(2-1 downto 0);
	subtype CACHE_ASSOCIATIVITY_TYPE IS STD_LOGIC_VECTOR(2-1 downto 0);

	CONSTANT REPLACEMENT_RANDOM : CACHE_REPLACEMENT_STRATEGY := "00";
	CONSTANT REPLACEMENT_BIT_PLRU : CACHE_REPLACEMENT_STRATEGY := "01"; --see https://en.wikipedia.org/wiki/Pseudo-LRU
	CONSTANT REPLACEMENT_FIFO : CACHE_REPLACEMENT_STRATEGY := "10";

	CONSTANT ONE_WAY_ASSOCIATIVITY : CACHE_ASSOCIATIVITY_TYPE := "00";
	CONSTANT TWO_WAY_ASSOCIATIVITY : CACHE_ASSOCIATIVITY_TYPE := "01";
	CONSTANT FOUR_WAY_ASSOCIATIVITY : CACHE_ASSOCIATIVITY_TYPE := "10";
	CONSTANT FULL_ASSOCIATIVITY : CACHE_ASSOCIATIVITY_TYPE := "11";
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

	CONSTANT CACHE_ASSOCIATIVITY : CACHE_ASSOCIATIVITY_TYPE := FULL_ASSOCIATIVITY; --remember to change subtype TAG_VALUE
	CONSTANT REPLACEMENT_STRATEGY : CACHE_REPLACEMENT_STRATEGY := REPLACEMENT_BIT_PLRU;

	FUNCTION RAND_RANGE(previous : IN INTEGER; CONSTANT max : IN INTEGER) return INTEGER;
END cache_infrastructure ; -- cache_infrastructure

PACKAGE BODY cache_infrastructure IS
	FUNCTION RAND_RANGE(previous : IN INTEGER; CONSTANT max : IN INTEGER) RETURN INTEGER IS
		variable next_value : UNSIGNED(64-1 downto 0);
	BEGIN
		next_value := TO_UNSIGNED(previous, 32) * 1103515245 + 12345;
		SHOW("RAND " & INTEGER'image(previous), "--> " & INTEGER'image(TO_INTEGER(next_value) mod max), "with max " & INTEGER'image(max));
		--return TO_INTEGER(next_value / 65536) mod max;
		return TO_INTEGER(next_value) mod max;
	END RAND_RANGE;
END cache_infrastructure;
