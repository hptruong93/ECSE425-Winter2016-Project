LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use work.register_array.all;


ENTITY writeback_tb IS
END writeback_tb;

ARCHITECTURE behaviour OF writeback_tb IS

SIGNAL clk, reset: STD_LOGIC := '0';
CONSTANT clk_period : time := 1 ns;

CONSTANT DUMMY_32_ONE : 	signed(32-1 downto 0) := "01010110101011010010100010010010";
CONSTANT DUMMY_32_TWO : 	signed(32-1 downto 0) := "00100100110101010110110101100101";
CONSTANT DUMMY_32_THREE : 	signed(32-1 downto 0) := "11010110101001000011110101010101";

COMPONENT WriteBack IS
	port (	clk 	: in STD_LOGIC;
				reset : in STD_LOGIC;
				
				lo_reg : in signed (32-1 downto 0);
				hi_reg : in signed (32-1 downto 0);

				writeback_source : in STD_LOGIC_VECTOR(3-1 downto 0); --sent from decoder
				alu_output : in signed(32-1 downto 0);
				mem_stage_busy : in STD_LOGIC;
				mem_stage_output : in STD_LOGIC_VECTOR(32-1 downto 0);
				mem_writeback_register : in STD_LOGIC_VECTOR(5-1 downto 0); --sent fromm decoder

				
				registers : out register_array
		);
end COMPONENT;

signal lo_reg : signed (32-1 downto 0);
signal hi_reg : signed (32-1 downto 0);

signal writeback_source : STD_LOGIC_VECTOR(3-1 downto 0); --sent from decoder
signal alu_output : signed(32-1 downto 0);
signal mem_stage_busy : STD_LOGIC;
signal mem_stage_output : STD_LOGIC_VECTOR(32-1 downto 0);
signal mem_writeback_register : STD_LOGIC_VECTOR(5-1 downto 0); --sent fromm decoder
signal registers : register_array;



BEGIN
	test_bench: WriteBack	
			PORT MAP(
				clk => clk,
				reset => reset,
				lo_reg => lo_reg,
				hi_reg => hi_reg,
				writeback_source => writeback_source,
				alu_output => alu_output,
				mem_stage_busy =>  mem_stage_busy,
				mem_stage_output => mem_stage_output,
				mem_writeback_register => mem_writeback_register,
				registers => registers
			);

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
		WAIT FOR 1 * clk_period; --clock high first

		reset <= '1';
		WAIT FOR 1 * clk_period;
		reset	<= '0';
		WAIT FOR 1 * clk_period;

		REPORT "Write from LO_AS_SOURCE";
		writeback_source <= LO_AS_SOURCE;
		lo_reg <= DUMMY_32_ONE;
		mem_writeback_register <= "11111";
		WAIT FOR 1 * clk_period;
		ASSERT (registers(31) = STD_LOGIC_VECTOR(DUMMY_32_ONE)) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN LO_AS_SOURCE" SEVERITY ERROR;

		REPORT "Write from HI_AS_SOURCE";
		writeback_source <= HI_AS_SOURCE;
		hi_reg <= DUMMY_32_TWO;
		mem_writeback_register <= "11111";
		WAIT FOR 1 * clk_period;
		ASSERT (registers(31) = STD_LOGIC_VECTOR(DUMMY_32_TWO)) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN HI_AS_SOURCE" SEVERITY ERROR;

		REPORT "Write from ALU_AS_SOURCE";
		writeback_source <= ALU_AS_SOURCE;
		alu_output <= DUMMY_32_THREE;
		mem_writeback_register <= "11111";
		WAIT FOR 1 * clk_period;
		ASSERT (registers(31) = STD_LOGIC_VECTOR(DUMMY_32_THREE)) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN ALU_AS_SOURCE" SEVERITY ERROR;

------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
		REPORT "Write from MEM_AS_SOURCE not busy";
		writeback_source <= MEM_AS_SOURCE;
		mem_stage_output <= STD_LOGIC_VECTOR(DUMMY_32_TWO);
		mem_writeback_register <= "11111";
		mem_stage_busy <= '0';
		WAIT FOR 1 * clk_period;
		ASSERT (registers(31) = STD_LOGIC_VECTOR(DUMMY_32_TWO)) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN MEM_AS_SOURCE" SEVERITY ERROR;

		REPORT "Write from MEM_AS_SOURCE busy";
		mem_stage_output <= STD_LOGIC_VECTOR(DUMMY_32_ONE);
		mem_stage_busy <= '1';
		WAIT FOR 1 * clk_period;
		ASSERT (registers(31) = STD_LOGIC_VECTOR(DUMMY_32_TWO)) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN MEM_AS_SOURCE" SEVERITY ERROR;

		REPORT "Write from MEM_AS_SOURCE not busy";
		mem_stage_output <= STD_LOGIC_VECTOR(DUMMY_32_TWO);
		mem_stage_busy <= '0';
		WAIT FOR 1 * clk_period;
		ASSERT (registers(31) = STD_LOGIC_VECTOR(DUMMY_32_TWO)) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN MEM_AS_SOURCE" SEVERITY ERROR;

------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
		REPORT "Write from MEM_BYTE_AS_SOURCE not busy";
		writeback_source <= MEM_BYTE_AS_SOURCE;
		mem_stage_output <= STD_LOGIC_VECTOR(DUMMY_32_THREE);
		mem_writeback_register <= "11111";
		mem_stage_busy <= '0';
		WAIT FOR 1 * clk_period;
		ASSERT (registers(31) = STD_LOGIC_VECTOR(DUMMY_32_THREE)) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN MEM_BYTE_AS_SOURCE" SEVERITY ERROR;

		REPORT "Write from MEM_BYTE_AS_SOURCE busy";
		mem_stage_output <= STD_LOGIC_VECTOR(DUMMY_32_ONE);
		mem_stage_busy <= '1';
		WAIT FOR 1 * clk_period;
		ASSERT (registers(31) = STD_LOGIC_VECTOR(DUMMY_32_THREE)) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN MEM_BYTE_AS_SOURCE" SEVERITY ERROR;

		REPORT "Write from MEM_BYTE_AS_SOURCE not busy";
		mem_stage_output <= STD_LOGIC_VECTOR(DUMMY_32_THREE);
		mem_stage_busy <= '0';
		WAIT FOR 1 * clk_period;
		ASSERT (registers(31) = STD_LOGIC_VECTOR(DUMMY_32_THREE)) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN MEM_BYTE_AS_SOURCE" SEVERITY ERROR;

------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------

		REPORT "Write from MEM_BYTE_AS_SOURCE not busy";
		writeback_source <= NO_WRITE_BACK;
		alu_output <= DUMMY_32_THREE;
		mem_writeback_register <= "11111";
		WAIT FOR 1 * clk_period;
		ASSERT (registers(31) = STD_LOGIC_VECTOR(DUMMY_32_THREE)) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN MEM_BYTE_AS_SOURCE" SEVERITY ERROR;
	END PROCESS;
END;