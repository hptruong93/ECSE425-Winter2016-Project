LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

ENTITY alu_tb IS
END alu_tb;

ARCHITECTURE behaviour OF alu_tb IS

SIGNAL clk, reset: STD_LOGIC := '0';
CONSTANT clk_period : time := 1 ns;

COMPONENT ALU IS
	port (	clk 	: in STD_LOGIC;
			reset : in STD_LOGIC;
			
			data1	:	in signed(32-1 downto 0);
			data2	:	in signed(32-1 downto 0);

			operation : in STD_LOGIC_VECTOR(6-1 downto 0);
			lo_reg : out signed (32-1 downto 0);
			hi_reg : out signed (32-1 downto 0);
			result : out signed(32-1 downto 0)
			
	);
end COMPONENT;

signal data1_test : signed(32-1 downto 0);
signal data2_test : signed(32-1 downto 0);
signal operation : STD_LOGIC_VECTOR(6-1 downto 0);
signal result, expected_result : signed(32-1 downto 0);
signal expected_hi, expected_lo, lo_reg, hi_reg : signed(32-1 downto 0);


BEGIN
	test_bench: ALU PORT MAP(clk, reset, data1_test, data2_test, operation, lo_reg, hi_reg, result);

	 --clock process
	clk_process : PROCESS
	BEGIN
		clk <= '0';
		WAIT FOR clk_period/2;
		clk <= '1';
		WAIT FOR clk_period/2;
	END PROCESS;
	

	--TODO: Thoroughly test the crap
	stim_process: PROCESS
	BEGIN
		reset <= '1';
		WAIT FOR 1 * clk_period;
		reset	<= '0';

		REPORT "################### 1. Add test: 3 + 2";
		operation <= "100000";
		data1_test <= to_signed(2, 32);
		data2_test <= to_signed(3, 32);
		expected_result <= to_signed(5, 32);
		WAIT FOR 1 * clk_period;
		ASSERT (result = expected_result) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN ADD: positive" SEVERITY ERROR;

		REPORT "################### 2. Add test: -3 - 1";
		operation <= "100000";
		data1_test <= to_signed(-3, 32);
		data2_test <= to_signed(-1, 32);
		expected_result <= to_signed(-4, 32);
		WAIT FOR 1* clk_period;
		ASSERT (result = expected_result) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN ADD: negative" SEVERITY ERROR;

		REPORT "################### 3. Sub test: 17, 5";
		operation <= "100010";
		data1_test <= to_signed(17, 32);
		data2_test <= to_signed(5, 32);
		expected_result <= to_signed(12, 32);
		WAIT FOR 1 * clk_period;
		ASSERT (result = expected_result) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN SUB" SEVERITY ERROR;

		REPORT "################### 4. Mult test: 5, 6";
		operation <= "011000";
		data1_test <= to_signed(5, 32);
		data2_test <= to_signed(6, 32);
		expected_hi <= to_signed(0, 32);
		expected_lo <= to_signed(30, 32);
		WAIT FOR 3 * clk_period;
		ASSERT (lo_reg = expected_lo) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN MUL HI" SEVERITY ERROR;
		ASSERT (hi_reg = expected_hi) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN MUL LO" SEVERITY ERROR;

		REPORT "################### 5. Div test: 300, 50";
		operation <= "011010";
		data1_test <= to_signed(300, 32);
		data2_test <= to_signed(50, 32);
		expected_hi <= to_signed(0, 32);
		expected_lo <= to_signed(6, 32);
		WAIT FOR 3 * clk_period;
		ASSERT (lo_reg = expected_lo) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN DIV HI" SEVERITY ERROR;
		ASSERT (hi_reg = expected_hi) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN DIV LO" SEVERITY ERROR;

		REPORT "################### 6. Div test: 34, 5";
		operation <= "011010";
		data1_test <= to_signed(34, 32);
		data2_test <= to_signed(5, 32);
		expected_hi <= to_signed(4, 32);
		expected_lo <= to_signed(6, 32);
		WAIT FOR 3 * clk_period;
		ASSERT (lo_reg = expected_lo) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN DIV HI" SEVERITY ERROR;
		ASSERT (hi_reg = expected_hi) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN DIV LO" SEVERITY ERROR;

		REPORT "################### 7. XOR test";
		operation <= "100110";
		data1_test <= to_signed(364836, 32);
		data2_test <= to_signed(947376, 32);
		expected_result <= to_signed(779668, 32);
		WAIT FOR 1 * clk_period;
		ASSERT (result = expected_result) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN XOR" SEVERITY ERROR;

		REPORT "################### 8. SHIFT LEFT test";
		operation <= "000000";
		data1_test <= to_signed(40, 32);
		data2_test <= to_signed(1, 32);
		expected_result <= to_signed(80, 32);
		WAIT FOR 1 * clk_period;
		ASSERT (result = expected_result) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN SHIFT LEFT" SEVERITY ERROR;

		REPORT "################### 9. SHIFT RIGHT LOGICAL test";
		operation <= "000010";
		data1_test <= to_signed(40, 32);
		data2_test <= to_signed(1, 32);
		expected_result <= to_signed(20, 32);
		WAIT FOR 1 * clk_period;
		ASSERT (result = expected_result) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN SHIFT RIGHT LOGICAL" SEVERITY ERROR;

		REPORT "################### 10. SHIFT RIGHT ARITHMETIC test";
		operation <= "000011";
		data1_test <= to_signed(40, 32);
		data2_test <= to_signed(1, 32);
		expected_result <= to_signed(20, 32);
		WAIT FOR 1 * clk_period;
		ASSERT (result = expected_result) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN SHIFT RIGHT ARITHMETIC" SEVERITY ERROR;

		REPORT "################### 11. SHIFT RIGHT ARITHMETIC test: Negative";
		operation <= "000011";
		data1_test <= to_signed(-40, 32);
		data2_test <= to_signed(1, 32);
		expected_result <= to_signed(-20, 32);
		WAIT FOR 1 * clk_period;
		ASSERT (result = expected_result) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN SHIFT RIGHT ARITHMETIC" SEVERITY ERROR;
	END PROCESS;
END;