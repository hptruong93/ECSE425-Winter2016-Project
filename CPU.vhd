library IEEE;
USE ieee.STD_LOGIC_1164.all;
USE ieee.numeric_std.all;

package register_array is
	type register_array is array(0 to 31) of STD_LOGIC_VECTOR(32-1 downto 0);

	--Decoder to write back
	CONSTANT LO_AS_SOURCE : STD_LOGIC_VECTOR(3-1 downto 0) := "000";
	CONSTANT HI_AS_SOURCE : STD_LOGIC_VECTOR(3-1 downto 0) := "001";
	CONSTANT ALU_AS_SOURCE : STD_LOGIC_VECTOR(3-1 downto 0) := "010";
	CONSTANT MEM_AS_SOURCE : STD_LOGIC_VECTOR(3-1 downto 0) := "011";
	CONSTANT MEM_BYTE_AS_SOURCE : STD_LOGIC_VECTOR(3-1 downto 0) := "100";
	CONSTANT NO_WRITE_BACK : STD_LOGIC_VECTOR(3-1 downto 0) := "101";
	
	--Decoder to mem
	CONSTANT LOAD_WORD : STD_LOGIC_VECTOR(3-1 downto 0) := "000";
	CONSTANT STORE_WORD : STD_LOGIC_VECTOR(3-1 downto 0) := "001";
	CONSTANT LOAD_BYTE : STD_LOGIC_VECTOR(3-1 downto 0) := "010";
	CONSTANT STORE_BYTE : STD_LOGIC_VECTOR(3-1 downto 0) := "011";
	CONSTANT MEM_IDLE : STD_LOGIC_VECTOR(3-1 downto 0) := "111";

	--Decoder to branch
	CONSTANT BRANCH_NOT : STD_LOGIC_VECTOR(2-1 downto 0) := "00";
	CONSTANT BRANCH_IF_ZERO : STD_LOGIC_VECTOR(2-1 downto 0) := "01";
	CONSTANT BRANCH_IF_NOT_ZERO : STD_LOGIC_VECTOR(2-1 downto 0) := "10";
	CONSTANT BRANCH_ALWAYS : STD_LOGIC_VECTOR(2-1 downto 0) := "11";

	CONSTANT DUMMY_32_ZERO :    SIGNED(32-1 downto 0) := "00000000000000000000000000000000";
	CONSTANT DUMMY_32_ONE :     SIGNED(32-1 downto 0) := "01010110101011010010100010010010";
	CONSTANT DUMMY_32_TWO :     SIGNED(32-1 downto 0) := "00100100110101010110110101100101";
	CONSTANT DUMMY_32_THREE :   SIGNED(32-1 downto 0) := "11010110101001000011110101010101";

	CONSTANT ZERO_BYTE_32 :		 STD_LOGIC_VECTOR(32-1 downto 0) := "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	CONSTANT FIRST_BYTE_32 :	 STD_LOGIC_VECTOR(32-1 downto 0) := "ZZZZZZZZZZZZZZZZZZZZZZZZ00000100";
	CONSTANT SECOND_BYTE_32 :	 STD_LOGIC_VECTOR(32-1 downto 0) := "ZZZZZZZZZZZZZZZZ00000110ZZZZZZZZ";
	CONSTANT THIRD_BYTE_32 :	 STD_LOGIC_VECTOR(32-1 downto 0) := "ZZZZZZZZ00001101ZZZZZZZZZZZZZZZZ";
	CONSTANT FOURTH_BYTE_32 :	 STD_LOGIC_VECTOR(32-1 downto 0) := "00011001ZZZZZZZZZZZZZZZZZZZZZZZZ";
end register_array;

