LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

ENTITY fsm_tb IS
END fsm_tb;

ARCHITECTURE behaviour OF fsm_tb IS

SIGNAL clk, reset: STD_LOGIC := '0';
CONSTANT clk_period : time := 1 ns;

COMPONENT ALU IS
	port (	clk 	: in STD_LOGIC;
			reset : in STD_LOGIC;
			
			data1	:	in signed(32-1 downto 0);
			data2	:	in signed(32-1 downto 0);

			operation : in STD_LOGIC_VECTOR(6-1 downto 0);
			overflow : out STD_LOGIC;
			result : out signed(32-1 downto 0)
	);
end COMPONENT;

signal data1_test : signed(32-1 downto 0);
signal data2_test : signed(32-1 downto 0);
signal operation : STD_LOGIC_VECTOR(6-1 downto 0);
signal overflow : STD_LOGIC;
signal result : signed(32-1 downto 0);

BEGIN
	test_bench: ALU	PORT MAP(clk, reset, data1_test, data2_test, operation, overflow, result);

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
		WAIT FOR 1 * clk_period;
		REPORT "YOLO";
	END PROCESS;
END;