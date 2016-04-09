library IEEE;
USE ieee.STD_LOGIC_1164.all;
USE ieee.numeric_std.all;
USE std.textio.all;

PACKAGE register_array IS
	type register_array IS array(0 to 31) of STD_LOGIC_VECTOR(32-1 downto 0);
	subtype REGISTER_VALUE IS STD_LOGIC_VECTOR(32-1 downto 0);
	subtype REGISTER_INDEX IS STD_LOGIC_VECTOR(5-1 downto 0);
	subtype MEMORY_OPERATION IS STD_LOGIC_VECTOR(3-1 downto 0);

	--Decoder to write back
	CONSTANT LO_AS_SOURCE : STD_LOGIC_VECTOR(3-1 downto 0) := "000";
	CONSTANT HI_AS_SOURCE : STD_LOGIC_VECTOR(3-1 downto 0) := "001";
	CONSTANT ALU_AS_SOURCE : STD_LOGIC_VECTOR(3-1 downto 0) := "010";
	CONSTANT MEM_AS_SOURCE : STD_LOGIC_VECTOR(3-1 downto 0) := "011";
	CONSTANT MEM_BYTE_AS_SOURCE : STD_LOGIC_VECTOR(3-1 downto 0) := "100";
	CONSTANT NO_WRITE_BACK : STD_LOGIC_VECTOR(3-1 downto 0) := "101";

	--Decoder to mem
	CONSTANT LOAD_WORD : MEMORY_OPERATION := "000";
	CONSTANT STORE_WORD : MEMORY_OPERATION := "001";
	CONSTANT LOAD_BYTE : MEMORY_OPERATION := "010";
	CONSTANT STORE_BYTE : MEMORY_OPERATION := "011";
	CONSTANT MEM_IDLE : MEMORY_OPERATION := "111";

	--Decoder to branch
	CONSTANT BRANCH_NOT : STD_LOGIC_VECTOR(2-1 downto 0) := "00";
	CONSTANT BRANCH_IF_ZERO : STD_LOGIC_VECTOR(2-1 downto 0) := "01";
	CONSTANT BRANCH_IF_NOT_ZERO : STD_LOGIC_VECTOR(2-1 downto 0) := "10";
	CONSTANT BRANCH_ALWAYS : STD_LOGIC_VECTOR(2-1 downto 0) := "11";

	CONSTANT ALL_32_ZEROES :    SIGNED(32-1 downto 0) := "00000000000000000000000000000000";
	CONSTANT DUMMY_32_ONE :     SIGNED(32-1 downto 0) := "01010110101011010010100010010010";
	CONSTANT DUMMY_32_TWO :     SIGNED(32-1 downto 0) := "00100100110101010110110101100101";
	CONSTANT DUMMY_32_THREE :   SIGNED(32-1 downto 0) := "11010110101001000011110101010101";

	CONSTANT MINUS_BYTE_32 :	 REGISTER_VALUE := "--------------------------------";
	CONSTANT X_BYTE_32 :         REGISTER_VALUE := "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
	CONSTANT U_BYTE_32 :         REGISTER_VALUE := "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU";
	CONSTANT Z_BYTE_32 :		 REGISTER_VALUE := "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	CONSTANT FIRST_BYTE_32 :	 REGISTER_VALUE := "ZZZZZZZZZZZZZZZZZZZZZZZZ00000100";
	CONSTANT SECOND_BYTE_32 :	 REGISTER_VALUE := "ZZZZZZZZZZZZZZZZ00000110ZZZZZZZZ";
	CONSTANT THIRD_BYTE_32 :	 REGISTER_VALUE := "ZZZZZZZZ00001101ZZZZZZZZZZZZZZZZ";
	CONSTANT FOURTH_BYTE_32 :	 REGISTER_VALUE := "00011001ZZZZZZZZZZZZZZZZZZZZZZZZ";

	PROCEDURE SHOW (msg : IN String);
	PROCEDURE SHOW (msg1 : IN String; msg2 : IN String);
	PROCEDURE SHOW_TWO (msg1 : IN String; msg2 : IN String);
	PROCEDURE SHOW (msg1 : IN String; msg2 : IN String; msg3 : IN String);

	PROCEDURE SHOW_LOVE (msg : IN String; data : IN STD_LOGIC_VECTOR(32-1 downto 0));
	PROCEDURE SHOW_LOVE (msg1 : IN String; msg2 : IN String; data : IN STD_LOGIC_VECTOR(32-1 downto 0));
	PROCEDURE SHOW_LOVE (msg1 : IN String; msg2 : IN String; msg3 : IN String; data : IN STD_LOGIC_VECTOR(32-1 downto 0));

END register_array;

PACKAGE BODY register_array IS
	PROCEDURE SHOW (msg : IN String) is
		VARIABLE my_line : line;
	BEGIN
		write(my_line, string("" & time'image(now)));
		write(my_line, string'(" --> "));
		write(my_line, msg);
		writeline(OUTPUT, my_line);
	END SHOW;

	PROCEDURE SHOW (msg1 : IN String; msg2 : IN String) is
		VARIABLE my_line : line;
	BEGIN
		write(my_line, string("" & time'image(now)));
		write(my_line, string'(" --> "));
		write(my_line, msg1);
		write(my_line, string'(" "));
		write(my_line, msg2);
		writeline(OUTPUT, my_line);
	END SHOW;

	PROCEDURE SHOW (msg1 : IN String; msg2 : IN String; msg3 : IN String) is
		VARIABLE my_line : line;
	BEGIN
		write(my_line, string("" & time'image(now)));
		write(my_line, string'(" --> "));
		write(my_line, msg1);
		write(my_line, string'(" "));
		write(my_line, msg2);
		write(my_line, string'(" "));
		write(my_line, msg3);
		writeline(OUTPUT, my_line);
	END SHOW;

	PROCEDURE SHOW_TWO (msg1 : IN String; msg2 : IN String) is
		VARIABLE my_line : line;
	BEGIN
		write(my_line, string("" & time'image(now)));
		write(my_line, string'(" --> "));
		write(my_line, msg1);
		write(my_line, string'(" "));
		write(my_line, msg2);
		writeline(OUTPUT, my_line);
	END SHOW_TWO;

	PROCEDURE SHOW_LOVE (msg : IN String; data : IN REGISTER_VALUE) is
		VARIABLE my_line : line;
	BEGIN
		write(my_line, string("" & time'image(now)));
		write(my_line, string'(" --> "));
		write(my_line, msg);
		write(my_line, string'(" --> " & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(31)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(30)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(29)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(28)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(27)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(26)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(25)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(24)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(23)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(22)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(21)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(20)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(19)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(18)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(17)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(16)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(15)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(14)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(13)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(12)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(11)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(10)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(9)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(8)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(7)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(6)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(5)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(4)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(3)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(2)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(1)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(0))))));
		writeline(OUTPUT, my_line);
	END SHOW_LOVE;

	PROCEDURE SHOW_LOVE (msg1 : IN String; msg2 : IN String; data : IN REGISTER_VALUE) is
		VARIABLE my_line : line;
	BEGIN
		write(my_line, string("" & time'image(now)));
		write(my_line, string'(" --> "));
		write(my_line, msg1);
		write(my_line, string'(" "));
		write(my_line, msg2);
		write(my_line, string'(" --> " & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(31)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(30)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(29)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(28)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(27)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(26)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(25)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(24)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(23)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(22)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(21)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(20)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(19)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(18)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(17)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(16)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(15)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(14)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(13)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(12)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(11)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(10)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(9)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(8)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(7)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(6)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(5)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(4)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(3)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(2)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(1)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(0))))));
		writeline(OUTPUT, my_line);
	END SHOW_LOVE;

	PROCEDURE SHOW_LOVE (msg1 : IN String; msg2 : IN String; msg3 : IN String; data : IN REGISTER_VALUE) is
		VARIABLE my_line : line;
	BEGIN
		write(my_line, string("" & time'image(now)));
		write(my_line, string'(" --> "));
		write(my_line, msg1);
		write(my_line, string'(" "));
		write(my_line, msg2);
		write(my_line, string'(" "));
		write(my_line, msg3);
		write(my_line, string'(" --> " & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(31)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(30)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(29)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(28)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(27)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(26)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(25)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(24)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(23)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(22)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(21)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(20)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(19)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(18)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(17)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(16)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(15)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(14)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(13)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(12)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(11)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(10)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(9)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(8)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(7)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(6)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(5)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(4)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(3)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(2)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(1)))) & INTEGER'image(TO_INTEGER(UNSIGNED'("" & data(0))))));
		writeline(OUTPUT, my_line);
	END SHOW_LOVE;
END register_array;
