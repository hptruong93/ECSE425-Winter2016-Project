LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use work.register_array.all;
use ieee.numeric_std_unsigned.all;


ENTITY memarbiter_tb IS
END memarbiter_tb;
 
ARCHITECTURE behaviour OF memarbiter_tb IS
 
SIGNAL clk, reset: STD_LOGIC := '0';
CONSTANT clk_period : time := 1 ns;

CONSTANT DUMMY_32_ZERO :    signed(32-1 downto 0) := "00000000000000000000000000000000";
CONSTANT DUMMY_32_ONE :     signed(32-1 downto 0) := "01010110101011010010100010010010";
CONSTANT DUMMY_32_TWO :     signed(32-1 downto 0) := "00100100110101010110110101100101";
CONSTANT DUMMY_32_THREE :   signed(32-1 downto 0) := "11010110101001000011110101010101";

COMPONENT memory_arbiter IS
				port (
						clk  : in STD_LOGIC;
						reset : in STD_LOGIC;
					
						Word_Byte   : in STD_LOGIC;

						--Memory port #1
						addr1   : in NATURAL;
						data1_in    : in STD_LOGIC_VECTOR(32-1 downto 0);
						data1_out   : out STD_LOGIC_VECTOR(32-1 downto 0);
						re1     : in STD_LOGIC;
						we1     : in STD_LOGIC;
						busy1 : out STD_LOGIC;

						--Memory port #2
						addr2   : in NATURAL;
						data2_in    : in STD_LOGIC_VECTOR(32-1 downto 0);
						data2_out   : out STD_LOGIC_VECTOR(32-1 downto 0);
						re2     : in STD_LOGIC;
						we2     : in STD_LOGIC;
						busy2 : out STD_LOGIC
				);
end COMPONENT;

signal Word_Byte	: STD_LOGIC;

--Memory port #1
signal addr1        : NATURAL;
signal data1_in     : STD_LOGIC_VECTOR(32-1 downto 0);
signal data1_out    : STD_LOGIC_VECTOR(32-1 downto 0);
signal re1          : STD_LOGIC;
signal we1          : STD_LOGIC;
signal busy1        : STD_LOGIC;

--Memory port #2
signal addr2        : NATURAL;
signal data2_in     : STD_LOGIC_VECTOR(32-1 downto 0);
signal data2_out    : STD_LOGIC_VECTOR(32-1 downto 0);
signal re2          : STD_LOGIC;
signal we2          : STD_LOGIC;
signal busy2        : STD_LOGIC;
 

BEGIN
	test_bench: memory_arbiter PORT MAP (
					clk  => clk,
					reset => reset,
			  
					Word_Byte   => Word_Byte,

					--Memory port 1
					addr1       => addr1,
					data1_in    => data1_in,
					data1_out   => data1_out,
					re1         => re1,
					we1         => we1,
					busy1       => busy1,

					--Memory port 2
					addr2       => addr2,
					data2_in    => data2_in,
					data2_out   => data2_out,
					re2         => re2,
					we2         => we2,
					busy2       => busy2 
				);
 
	 --clock process
	clk_process : PROCESS
	BEGIN
		clk <= '1';
		WAIT FOR clk_period/2;
		clk <= '0';
		WAIT FOR clk_period/2;
	END PROCESS;
   
 
	--TODO: Thoroughly test the crap
	stim_process: PROCESS
	BEGIN
		WAIT FOR 1 * clk_period; --So clk starts at 1

		reset <= '1';
		WAIT FOR 1 * clk_period;
		reset <= '0';
		WAIT FOR 1 * clk_period;

		Word_Byte <= '1';
		REPORT "Read next word from file";
		--addr1 <= 0;
		--re1 <= '1';
		--we1 <= '0';
		--re2 <= '0';
		--we2 <= '0';

		--WAIT FOR 1 * clk_period;
		--ASSERT (busy1 = '1') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> busy /= 1" SEVERITY ERROR;

		--while (busy1 = '1') loop
		--    WAIT FOR 1 * clk_period;
		--end loop;
		
		--addr1 <= 0;
		--re1 <= '0';
		--we1 <= '0';
		--re2 <= '0';
		--we2 <= '0';


		--WAIT FOR 1 * clk_period;
		--REPORT "first read value is " & integer'image(to_integer(signed(data1_out)));

		REPORT "Now write to mem";
		--data1_in <= "00000000000000000000011011000001"; --1729
		data1_in <=   "00000000000000000000000000000011";
		addr1 <= 4;
		re1 <= '0';
		we1 <= '1';
		re2 <= '0';
		we2 <= '0';

		WAIT FOR 1 * clk_period;
		while (busy1 = '1') loop
			WAIT FOR 1 * clk_period;
		end loop;

		Word_Byte <= '1';
		addr1 <= 4;
		re1 <= '1';
		we1 <= '0';
		re2 <= '0';
		we2 <= '0';

		WAIT FOR 1 * clk_period;
		while (busy1 = '1') loop
			WAIT FOR 1 * clk_period;
		end loop;

		REPORT "read back value is " & integer'image(to_integer(signed(data1_out)));

		ASSERT (data1_out = "00000000000000000000000000000011") REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  incorrect data1_out" SEVERITY ERROR;
		



		REPORT "#####################################################End test";
	END PROCESS;
END;