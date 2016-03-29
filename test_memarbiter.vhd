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

signal count : std_logic := '0';

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
		if count = '0' then count <= '1';
		WAIT FOR 1 * clk_period; --So clk starts at 1

		reset <= '1';
		WAIT FOR 1 * clk_period;
		reset <= '0';
		WAIT FOR 1 * clk_period;

		we2 <= '0';
		re2 <= '0';

		REPORT "Read next word from file";

		Word_Byte <= '1';
		we1 <= '0';
		re1 <= '1';
		addr1 <= 0;
		data1_in <= Z_BYTE_32;

		WAIT FOR 1 * clk_period;
		while (busy1 = '1') loop
			WAIT FOR 1 * clk_period;
		end loop;

		REPORT "FULL WORD IS " & STD_LOGIC'image(data1_out(31)) & STD_LOGIC'image(data1_out(30)) & STD_LOGIC'image(data1_out(29)) & STD_LOGIC'image(data1_out(28)) & STD_LOGIC'image(data1_out(27)) & STD_LOGIC'image(data1_out(26)) & STD_LOGIC'image(data1_out(25)) & STD_LOGIC'image(data1_out(24)) & STD_LOGIC'image(data1_out(23)) & STD_LOGIC'image(data1_out(22)) & STD_LOGIC'image(data1_out(21)) & STD_LOGIC'image(data1_out(20)) & STD_LOGIC'image(data1_out(19)) & STD_LOGIC'image(data1_out(18)) & STD_LOGIC'image(data1_out(17)) & STD_LOGIC'image(data1_out(16)) & STD_LOGIC'image(data1_out(15)) & STD_LOGIC'image(data1_out(14)) & STD_LOGIC'image(data1_out(13)) & STD_LOGIC'image(data1_out(12)) & STD_LOGIC'image(data1_out(11)) & STD_LOGIC'image(data1_out(10)) & STD_LOGIC'image(data1_out(9)) & STD_LOGIC'image(data1_out(8)) & STD_LOGIC'image(data1_out(7)) & STD_LOGIC'image(data1_out(6)) & STD_LOGIC'image(data1_out(5)) & STD_LOGIC'image(data1_out(4)) & STD_LOGIC'image(data1_out(3)) & STD_LOGIC'image(data1_out(2)) & STD_LOGIC'image(data1_out(1)) & STD_LOGIC'image(data1_out(0));

		Word_Byte <= '0';
		we1 <= '0';
		re1 <= '1';
		addr1 <= 0;
		data1_in <= Z_BYTE_32;

		WAIT FOR 1 * clk_period;
		while (busy1 = '1') loop
			WAIT FOR 1 * clk_period;
		end loop;

		REPORT "1ST BYTE IS" & STD_LOGIC'image(data1_out(31)) & STD_LOGIC'image(data1_out(30)) & STD_LOGIC'image(data1_out(29)) & STD_LOGIC'image(data1_out(28)) & STD_LOGIC'image(data1_out(27)) & STD_LOGIC'image(data1_out(26)) & STD_LOGIC'image(data1_out(25)) & STD_LOGIC'image(data1_out(24)) & STD_LOGIC'image(data1_out(23)) & STD_LOGIC'image(data1_out(22)) & STD_LOGIC'image(data1_out(21)) & STD_LOGIC'image(data1_out(20)) & STD_LOGIC'image(data1_out(19)) & STD_LOGIC'image(data1_out(18)) & STD_LOGIC'image(data1_out(17)) & STD_LOGIC'image(data1_out(16)) & STD_LOGIC'image(data1_out(15)) & STD_LOGIC'image(data1_out(14)) & STD_LOGIC'image(data1_out(13)) & STD_LOGIC'image(data1_out(12)) & STD_LOGIC'image(data1_out(11)) & STD_LOGIC'image(data1_out(10)) & STD_LOGIC'image(data1_out(9)) & STD_LOGIC'image(data1_out(8)) & STD_LOGIC'image(data1_out(7)) & STD_LOGIC'image(data1_out(6)) & STD_LOGIC'image(data1_out(5)) & STD_LOGIC'image(data1_out(4)) & STD_LOGIC'image(data1_out(3)) & STD_LOGIC'image(data1_out(2)) & STD_LOGIC'image(data1_out(1)) & STD_LOGIC'image(data1_out(0));

		we1 <= '0';
		re1 <= '0';
		WAIT FOR 1 * clk_period;

		Word_Byte <= '0';
		we1 <= '0';
		re1 <= '1';
		addr1 <= 1;
		data1_in <= Z_BYTE_32;

		WAIT FOR 1 * clk_period;
		while (busy1 = '1') loop
			WAIT FOR 1 * clk_period;
		end loop;

		REPORT "2ND BYTE is " & STD_LOGIC'image(data1_out(31)) & STD_LOGIC'image(data1_out(30)) & STD_LOGIC'image(data1_out(29)) & STD_LOGIC'image(data1_out(28)) & STD_LOGIC'image(data1_out(27)) & STD_LOGIC'image(data1_out(26)) & STD_LOGIC'image(data1_out(25)) & STD_LOGIC'image(data1_out(24)) & STD_LOGIC'image(data1_out(23)) & STD_LOGIC'image(data1_out(22)) & STD_LOGIC'image(data1_out(21)) & STD_LOGIC'image(data1_out(20)) & STD_LOGIC'image(data1_out(19)) & STD_LOGIC'image(data1_out(18)) & STD_LOGIC'image(data1_out(17)) & STD_LOGIC'image(data1_out(16)) & STD_LOGIC'image(data1_out(15)) & STD_LOGIC'image(data1_out(14)) & STD_LOGIC'image(data1_out(13)) & STD_LOGIC'image(data1_out(12)) & STD_LOGIC'image(data1_out(11)) & STD_LOGIC'image(data1_out(10)) & STD_LOGIC'image(data1_out(9)) & STD_LOGIC'image(data1_out(8)) & STD_LOGIC'image(data1_out(7)) & STD_LOGIC'image(data1_out(6)) & STD_LOGIC'image(data1_out(5)) & STD_LOGIC'image(data1_out(4)) & STD_LOGIC'image(data1_out(3)) & STD_LOGIC'image(data1_out(2)) & STD_LOGIC'image(data1_out(1)) & STD_LOGIC'image(data1_out(0));
		we1 <= '0';
		re1 <= '0';
		WAIT FOR 1 * clk_period;

		Word_Byte <= '0';
		we1 <= '0';
		re1 <= '1';
		addr1 <= 2;
		data1_in <= Z_BYTE_32;

		WAIT FOR 1 * clk_period;
		while (busy1 = '1') loop
			WAIT FOR 1 * clk_period;
		end loop;

		REPORT "3RD BYTE is " & STD_LOGIC'image(data1_out(31)) & STD_LOGIC'image(data1_out(30)) & STD_LOGIC'image(data1_out(29)) & STD_LOGIC'image(data1_out(28)) & STD_LOGIC'image(data1_out(27)) & STD_LOGIC'image(data1_out(26)) & STD_LOGIC'image(data1_out(25)) & STD_LOGIC'image(data1_out(24)) & STD_LOGIC'image(data1_out(23)) & STD_LOGIC'image(data1_out(22)) & STD_LOGIC'image(data1_out(21)) & STD_LOGIC'image(data1_out(20)) & STD_LOGIC'image(data1_out(19)) & STD_LOGIC'image(data1_out(18)) & STD_LOGIC'image(data1_out(17)) & STD_LOGIC'image(data1_out(16)) & STD_LOGIC'image(data1_out(15)) & STD_LOGIC'image(data1_out(14)) & STD_LOGIC'image(data1_out(13)) & STD_LOGIC'image(data1_out(12)) & STD_LOGIC'image(data1_out(11)) & STD_LOGIC'image(data1_out(10)) & STD_LOGIC'image(data1_out(9)) & STD_LOGIC'image(data1_out(8)) & STD_LOGIC'image(data1_out(7)) & STD_LOGIC'image(data1_out(6)) & STD_LOGIC'image(data1_out(5)) & STD_LOGIC'image(data1_out(4)) & STD_LOGIC'image(data1_out(3)) & STD_LOGIC'image(data1_out(2)) & STD_LOGIC'image(data1_out(1)) & STD_LOGIC'image(data1_out(0));
		we1 <= '0';
		re1 <= '0';
		WAIT FOR 1 * clk_period;

		Word_Byte <= '0';
		we1 <= '0';
		re1 <= '1';
		addr1 <= 3;
		data1_in <= Z_BYTE_32;

		WAIT FOR 1 * clk_period;
		while (busy1 = '1') loop
			WAIT FOR 1 * clk_period;
		end loop;

		REPORT "4TH BYTE is " & STD_LOGIC'image(data1_out(31)) & STD_LOGIC'image(data1_out(30)) & STD_LOGIC'image(data1_out(29)) & STD_LOGIC'image(data1_out(28)) & STD_LOGIC'image(data1_out(27)) & STD_LOGIC'image(data1_out(26)) & STD_LOGIC'image(data1_out(25)) & STD_LOGIC'image(data1_out(24)) & STD_LOGIC'image(data1_out(23)) & STD_LOGIC'image(data1_out(22)) & STD_LOGIC'image(data1_out(21)) & STD_LOGIC'image(data1_out(20)) & STD_LOGIC'image(data1_out(19)) & STD_LOGIC'image(data1_out(18)) & STD_LOGIC'image(data1_out(17)) & STD_LOGIC'image(data1_out(16)) & STD_LOGIC'image(data1_out(15)) & STD_LOGIC'image(data1_out(14)) & STD_LOGIC'image(data1_out(13)) & STD_LOGIC'image(data1_out(12)) & STD_LOGIC'image(data1_out(11)) & STD_LOGIC'image(data1_out(10)) & STD_LOGIC'image(data1_out(9)) & STD_LOGIC'image(data1_out(8)) & STD_LOGIC'image(data1_out(7)) & STD_LOGIC'image(data1_out(6)) & STD_LOGIC'image(data1_out(5)) & STD_LOGIC'image(data1_out(4)) & STD_LOGIC'image(data1_out(3)) & STD_LOGIC'image(data1_out(2)) & STD_LOGIC'image(data1_out(1)) & STD_LOGIC'image(data1_out(0));
		we1 <= '0';
		re1 <= '0';
		WAIT FOR 1 * clk_period;
---------------------------------------------------------------------------------------------
		Word_Byte <= '0';
		we1 <= '1';
		re1 <= '0';
		addr1 <= 3;
		WAIT FOR 1 * clk_period;
		data1_in <= FIRST_BYTE_32;

		WAIT FOR 1 * clk_period;
		while (busy1 = '1') loop
			WAIT FOR 1 * clk_period;
		end loop;

		we1 <= '0';
		re1 <= '0';
		WAIT FOR 1 * clk_period;

---------------------------------------------------------------------------------------------
		Word_Byte <= '0';
		we1 <= '1';
		re1 <= '0';

		addr1 <= 1;
		WAIT FOR 1 * clk_period;
		data1_in <= FIRST_BYTE_32;

		WAIT FOR 1 * clk_period;
		while (busy1 = '1') loop
			WAIT FOR 1 * clk_period;
		end loop;

		we1 <= '0';
		re1 <= '0';
		WAIT FOR 1 * clk_period;

-----------------------------------------------------------------------------------------------
		Word_Byte <= '0';
		we1 <= '1';
		re1 <= '0';
		addr1 <= 0;
		data1_in <= FIRST_BYTE_32;

		WAIT FOR 1 * clk_period;
		while (busy1 = '1') loop
			WAIT FOR 1 * clk_period;
		end loop;

		we1 <= '0';
		re1 <= '0';
		WAIT FOR 1 * clk_period;
		REPORT "Done writing.";
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------

		Word_Byte <= '1';
		we1 <= '0';
		re1 <= '1';
		addr1 <= 0;
		data1_in <= Z_BYTE_32;

		WAIT FOR 1 * clk_period;
		while (busy1 = '1') loop
			WAIT FOR 1 * clk_period;
		end loop;

		REPORT "DATA WRITTEN IS" & STD_LOGIC'image(data1_out(31)) & STD_LOGIC'image(data1_out(30)) & STD_LOGIC'image(data1_out(29)) & STD_LOGIC'image(data1_out(28)) & STD_LOGIC'image(data1_out(27)) & STD_LOGIC'image(data1_out(26)) & STD_LOGIC'image(data1_out(25)) & STD_LOGIC'image(data1_out(24)) & STD_LOGIC'image(data1_out(23)) & STD_LOGIC'image(data1_out(22)) & STD_LOGIC'image(data1_out(21)) & STD_LOGIC'image(data1_out(20)) & STD_LOGIC'image(data1_out(19)) & STD_LOGIC'image(data1_out(18)) & STD_LOGIC'image(data1_out(17)) & STD_LOGIC'image(data1_out(16)) & STD_LOGIC'image(data1_out(15)) & STD_LOGIC'image(data1_out(14)) & STD_LOGIC'image(data1_out(13)) & STD_LOGIC'image(data1_out(12)) & STD_LOGIC'image(data1_out(11)) & STD_LOGIC'image(data1_out(10)) & STD_LOGIC'image(data1_out(9)) & STD_LOGIC'image(data1_out(8)) & STD_LOGIC'image(data1_out(7)) & STD_LOGIC'image(data1_out(6)) & STD_LOGIC'image(data1_out(5)) & STD_LOGIC'image(data1_out(4)) & STD_LOGIC'image(data1_out(3)) & STD_LOGIC'image(data1_out(2)) & STD_LOGIC'image(data1_out(1)) & STD_LOGIC'image(data1_out(0));
		WAIT FOR 1 * clk_period;


		REPORT "#####################################################End test";
		else
			count <= '1';
			WAIT FOR 100 * clk_period;
		end if;
	END PROCESS;
END;