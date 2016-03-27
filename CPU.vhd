library IEEE;
USE ieee.STD_LOGIC_1164.all;
USE ieee.numeric_std.all;
USE std.textio.all;

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

	CONSTANT ALL_32_ZEROES :    SIGNED(32-1 downto 0) := "00000000000000000000000000000000";
	CONSTANT DUMMY_32_ONE :     SIGNED(32-1 downto 0) := "01010110101011010010100010010010";
	CONSTANT DUMMY_32_TWO :     SIGNED(32-1 downto 0) := "00100100110101010110110101100101";
	CONSTANT DUMMY_32_THREE :   SIGNED(32-1 downto 0) := "11010110101001000011110101010101";

	CONSTANT ZERO_BYTE_32 :		 STD_LOGIC_VECTOR(32-1 downto 0) := "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	CONSTANT FIRST_BYTE_32 :	 STD_LOGIC_VECTOR(32-1 downto 0) := "ZZZZZZZZZZZZZZZZZZZZZZZZ00000100";
	CONSTANT SECOND_BYTE_32 :	 STD_LOGIC_VECTOR(32-1 downto 0) := "ZZZZZZZZZZZZZZZZ00000110ZZZZZZZZ";
	CONSTANT THIRD_BYTE_32 :	 STD_LOGIC_VECTOR(32-1 downto 0) := "ZZZZZZZZ00001101ZZZZZZZZZZZZZZZZ";
	CONSTANT FOURTH_BYTE_32 :	 STD_LOGIC_VECTOR(32-1 downto 0) := "00011001ZZZZZZZZZZZZZZZZZZZZZZZZ";

	procedure SHOW (msg : IN String);
	procedure SHOW_TWO (msg1 : IN String; msg2 : IN String);
	procedure SHOW_LOVE (msg : IN String; data : IN STD_LOGIC_VECTOR(32-1 downto 0));
	
end register_array;

package body register_array is	
	procedure SHOW (msg : IN String) is
		variable my_line : line;
	begin
		write(my_line, string("" & time'image(now)));
		write(my_line, string'(" --> "));
		write(my_line, msg);
		writeline(OUTPUT, my_line);
	end SHOW;

	procedure SHOW_TWO (msg1 : IN String; msg2 : IN String) is
		variable my_line : line;
	begin
		write(my_line, string("" & time'image(now)));
		write(my_line, string'(" --> "));
		write(my_line, msg1);
		write(my_line, string'(" "));
		write(my_line, msg2);
		writeline(OUTPUT, my_line);
	end SHOW_TWO;

	procedure SHOW_LOVE (msg : IN String; data : IN STD_LOGIC_VECTOR(32-1 downto 0)) is
		variable my_line : line;
	begin
		write(my_line, string("" & time'image(now)));
		write(my_line, string'(" --> "));
		write(my_line, msg);
		write(my_line, string'(" --> " & STD_LOGIC'image(data(31)) & STD_LOGIC'image(data(30)) & STD_LOGIC'image(data(29)) & STD_LOGIC'image(data(28)) & STD_LOGIC'image(data(27)) & STD_LOGIC'image(data(26)) & STD_LOGIC'image(data(25)) & STD_LOGIC'image(data(24)) & STD_LOGIC'image(data(23)) & STD_LOGIC'image(data(22)) & STD_LOGIC'image(data(21)) & STD_LOGIC'image(data(20)) & STD_LOGIC'image(data(19)) & STD_LOGIC'image(data(18)) & STD_LOGIC'image(data(17)) & STD_LOGIC'image(data(16)) & STD_LOGIC'image(data(15)) & STD_LOGIC'image(data(14)) & STD_LOGIC'image(data(13)) & STD_LOGIC'image(data(12)) & STD_LOGIC'image(data(11)) & STD_LOGIC'image(data(10)) & STD_LOGIC'image(data(9)) & STD_LOGIC'image(data(8)) & STD_LOGIC'image(data(7)) & STD_LOGIC'image(data(6)) & STD_LOGIC'image(data(5)) & STD_LOGIC'image(data(4)) & STD_LOGIC'image(data(3)) & STD_LOGIC'image(data(2)) & STD_LOGIC'image(data(1)) & STD_LOGIC'image(data(0))));
		writeline(OUTPUT, my_line);
	end SHOW_LOVE;
end register_array;
