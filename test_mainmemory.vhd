LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use work.register_array.all;
use ieee.numeric_std_unsigned.all;


ENTITY mainmemory_tb IS
END mainmemory_tb;

ARCHITECTURE behaviour OF mainmemory_tb IS

SIGNAL clk, reset: STD_LOGIC := '0';
CONSTANT clk_period : time := 1 ns;

COMPONENT Main_Memory IS
				port (
						clk : in std_logic;
						address : in integer;
						Word_Byte: in std_logic; -- when '1' you are interacting with the memory in word otherwise in byte
						we : in std_logic;
						wr_done:out std_logic; --indicates that the write operation has been done.
						re :in std_logic;
						rd_ready: out std_logic; --indicates that the read data is ready at the output.
						data : inout std_logic_vector((4*8)-1 downto 0);
						initialize: in std_logic;
						dump: in std_logic
				);
end COMPONENT;

signal address : integer;
signal Word_Byte: std_logic; -- when '1' you are interacting with the memory in word otherwise in byte
signal we : std_logic;
signal wr_done: std_logic; --indicates that the write operation has been done.
signal re : std_logic;
signal rd_ready: std_logic; --indicates that the read data is ready at the output.
signal data : std_logic_vector((4*8)-1 downto 0);
signal initialize: std_logic;
signal dump: std_logic;

signal count : std_logic := '0';

BEGIN
	test_bench: Main_Memory PORT MAP (
					clk  => clk,

					address  => 	address ,
					Word_Byte => 	Word_Byte,
					we  =>			we ,
					wr_done => 		wr_done,
					re  =>			re ,
					rd_ready => 	rd_ready,
					data  =>			data ,
					initialize => 	initialize,
					dump => 			dump
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

		initialize <= '1';
		WAIT FOR 1 * clk_period;

		initialize <= '0';
		--WAIT FOR 1 * clk_period;

		REPORT "Read next word from file";
		Word_Byte <= '1';
		we <= '0';
		re <= '1';
		address <= 0;
		data <= Z_BYTE_32;

		WAIT FOR 1 * clk_period;
		while (rd_ready = '0') loop
			WAIT FOR 1 * clk_period;
		end loop;

		REPORT "FULL WORD IS " & STD_LOGIC'image(data(31)) & STD_LOGIC'image(data(30)) & STD_LOGIC'image(data(29)) & STD_LOGIC'image(data(28)) & STD_LOGIC'image(data(27)) & STD_LOGIC'image(data(26)) & STD_LOGIC'image(data(25)) & STD_LOGIC'image(data(24)) & STD_LOGIC'image(data(23)) & STD_LOGIC'image(data(22)) & STD_LOGIC'image(data(21)) & STD_LOGIC'image(data(20)) & STD_LOGIC'image(data(19)) & STD_LOGIC'image(data(18)) & STD_LOGIC'image(data(17)) & STD_LOGIC'image(data(16)) & STD_LOGIC'image(data(15)) & STD_LOGIC'image(data(14)) & STD_LOGIC'image(data(13)) & STD_LOGIC'image(data(12)) & STD_LOGIC'image(data(11)) & STD_LOGIC'image(data(10)) & STD_LOGIC'image(data(9)) & STD_LOGIC'image(data(8)) & STD_LOGIC'image(data(7)) & STD_LOGIC'image(data(6)) & STD_LOGIC'image(data(5)) & STD_LOGIC'image(data(4)) & STD_LOGIC'image(data(3)) & STD_LOGIC'image(data(2)) & STD_LOGIC'image(data(1)) & STD_LOGIC'image(data(0));

		Word_Byte <= '1';
		we <= '0';
		re <= '1';
		address <= 0;
		data <= Z_BYTE_32;

		WAIT FOR 1 * clk_period;
		while (rd_ready = '0') loop
			WAIT FOR 1 * clk_period;
		end loop;

		REPORT "1st BYTE IS " & STD_LOGIC'image(data(31)) & STD_LOGIC'image(data(30)) & STD_LOGIC'image(data(29)) & STD_LOGIC'image(data(28)) & STD_LOGIC'image(data(27)) & STD_LOGIC'image(data(26)) & STD_LOGIC'image(data(25)) & STD_LOGIC'image(data(24)) & STD_LOGIC'image(data(23)) & STD_LOGIC'image(data(22)) & STD_LOGIC'image(data(21)) & STD_LOGIC'image(data(20)) & STD_LOGIC'image(data(19)) & STD_LOGIC'image(data(18)) & STD_LOGIC'image(data(17)) & STD_LOGIC'image(data(16)) & STD_LOGIC'image(data(15)) & STD_LOGIC'image(data(14)) & STD_LOGIC'image(data(13)) & STD_LOGIC'image(data(12)) & STD_LOGIC'image(data(11)) & STD_LOGIC'image(data(10)) & STD_LOGIC'image(data(9)) & STD_LOGIC'image(data(8)) & STD_LOGIC'image(data(7)) & STD_LOGIC'image(data(6)) & STD_LOGIC'image(data(5)) & STD_LOGIC'image(data(4)) & STD_LOGIC'image(data(3)) & STD_LOGIC'image(data(2)) & STD_LOGIC'image(data(1)) & STD_LOGIC'image(data(0));

		we <= '0';
		re <= '0';
		WAIT FOR 1 * clk_period;

		Word_Byte <= '1';
		we <= '0';
		re <= '1';
		address <= 4;
		data <= Z_BYTE_32;

		WAIT FOR 1 * clk_period;
		while (rd_ready = '0') loop
			WAIT FOR 1 * clk_period;
		end loop;

		REPORT "2nd IS " & STD_LOGIC'image(data(31)) & STD_LOGIC'image(data(30)) & STD_LOGIC'image(data(29)) & STD_LOGIC'image(data(28)) & STD_LOGIC'image(data(27)) & STD_LOGIC'image(data(26)) & STD_LOGIC'image(data(25)) & STD_LOGIC'image(data(24)) & STD_LOGIC'image(data(23)) & STD_LOGIC'image(data(22)) & STD_LOGIC'image(data(21)) & STD_LOGIC'image(data(20)) & STD_LOGIC'image(data(19)) & STD_LOGIC'image(data(18)) & STD_LOGIC'image(data(17)) & STD_LOGIC'image(data(16)) & STD_LOGIC'image(data(15)) & STD_LOGIC'image(data(14)) & STD_LOGIC'image(data(13)) & STD_LOGIC'image(data(12)) & STD_LOGIC'image(data(11)) & STD_LOGIC'image(data(10)) & STD_LOGIC'image(data(9)) & STD_LOGIC'image(data(8)) & STD_LOGIC'image(data(7)) & STD_LOGIC'image(data(6)) & STD_LOGIC'image(data(5)) & STD_LOGIC'image(data(4)) & STD_LOGIC'image(data(3)) & STD_LOGIC'image(data(2)) & STD_LOGIC'image(data(1)) & STD_LOGIC'image(data(0));

		we <= '0';
		re <= '0';
		WAIT FOR 1 * clk_period;

		Word_Byte <= '1';
		we <= '0';
		re <= '1';
		address <= 8;
		data <= Z_BYTE_32;

		WAIT FOR 1 * clk_period;
		while (rd_ready = '0') loop
			WAIT FOR 1 * clk_period;
		end loop;

		REPORT "3rd IS " & STD_LOGIC'image(data(31)) & STD_LOGIC'image(data(30)) & STD_LOGIC'image(data(29)) & STD_LOGIC'image(data(28)) & STD_LOGIC'image(data(27)) & STD_LOGIC'image(data(26)) & STD_LOGIC'image(data(25)) & STD_LOGIC'image(data(24)) & STD_LOGIC'image(data(23)) & STD_LOGIC'image(data(22)) & STD_LOGIC'image(data(21)) & STD_LOGIC'image(data(20)) & STD_LOGIC'image(data(19)) & STD_LOGIC'image(data(18)) & STD_LOGIC'image(data(17)) & STD_LOGIC'image(data(16)) & STD_LOGIC'image(data(15)) & STD_LOGIC'image(data(14)) & STD_LOGIC'image(data(13)) & STD_LOGIC'image(data(12)) & STD_LOGIC'image(data(11)) & STD_LOGIC'image(data(10)) & STD_LOGIC'image(data(9)) & STD_LOGIC'image(data(8)) & STD_LOGIC'image(data(7)) & STD_LOGIC'image(data(6)) & STD_LOGIC'image(data(5)) & STD_LOGIC'image(data(4)) & STD_LOGIC'image(data(3)) & STD_LOGIC'image(data(2)) & STD_LOGIC'image(data(1)) & STD_LOGIC'image(data(0));

		we <= '0';
		re <= '0';
		WAIT FOR 1 * clk_period;

		Word_Byte <= '0';
		we <= '0';
		re <= '1';
		address <= 3;
		data <= Z_BYTE_32;

		WAIT FOR 1 * clk_period;
		while (rd_ready = '0') loop
			WAIT FOR 1 * clk_period;
		end loop;

		REPORT "4th IS " & STD_LOGIC'image(data(31)) & STD_LOGIC'image(data(30)) & STD_LOGIC'image(data(29)) & STD_LOGIC'image(data(28)) & STD_LOGIC'image(data(27)) & STD_LOGIC'image(data(26)) & STD_LOGIC'image(data(25)) & STD_LOGIC'image(data(24)) & STD_LOGIC'image(data(23)) & STD_LOGIC'image(data(22)) & STD_LOGIC'image(data(21)) & STD_LOGIC'image(data(20)) & STD_LOGIC'image(data(19)) & STD_LOGIC'image(data(18)) & STD_LOGIC'image(data(17)) & STD_LOGIC'image(data(16)) & STD_LOGIC'image(data(15)) & STD_LOGIC'image(data(14)) & STD_LOGIC'image(data(13)) & STD_LOGIC'image(data(12)) & STD_LOGIC'image(data(11)) & STD_LOGIC'image(data(10)) & STD_LOGIC'image(data(9)) & STD_LOGIC'image(data(8)) & STD_LOGIC'image(data(7)) & STD_LOGIC'image(data(6)) & STD_LOGIC'image(data(5)) & STD_LOGIC'image(data(4)) & STD_LOGIC'image(data(3)) & STD_LOGIC'image(data(2)) & STD_LOGIC'image(data(1)) & STD_LOGIC'image(data(0));

		we <= '0';
		re <= '0';
		WAIT FOR 1 * clk_period;
-------------------------------------------------------------------------------------------
		Word_Byte <= '0';
		we <= '1';
		re <= '0';
		address <= 3;
		WAIT FOR 1 * clk_period;
		data <= FIRST_BYTE_32;

		WAIT FOR 1 * clk_period;
		while (wr_done = '0') loop
			WAIT FOR 1 * clk_period;
		end loop;

		we <= '0';
		re <= '0';
		WAIT FOR 1 * clk_period;

-------------------------------------------------------------------------------------------
		Word_Byte <= '0';
		we <= '1';
		re <= '0';

		address <= 1;
		WAIT FOR 1 * clk_period;
		data <= FIRST_BYTE_32;

		WAIT FOR 1 * clk_period;
		while (wr_done = '0') loop
			WAIT FOR 1 * clk_period;
		end loop;

---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------

		Word_Byte <= '0';
		we <= '1';
		re <= '0';
		address <= 0;
		--WAIT FOR 1 * clk_period;
		data <= FIRST_BYTE_32;

		WAIT FOR 1 * clk_period;
		while (wr_done = '0') loop
			WAIT FOR 1 * clk_period;
		end loop;

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

		Word_Byte <= '1';
		we <= '0';
		re <= '1';
		address <= 0;
		data <= Z_BYTE_32;
		WAIT FOR 1 * clk_period;
		while (rd_ready = '0') loop
			WAIT FOR 1 * clk_period;
		end loop;

		REPORT "WRITTEN IS " & STD_LOGIC'image(data(31)) & STD_LOGIC'image(data(30)) & STD_LOGIC'image(data(29)) & STD_LOGIC'image(data(28)) & STD_LOGIC'image(data(27)) & STD_LOGIC'image(data(26)) & STD_LOGIC'image(data(25)) & STD_LOGIC'image(data(24)) & STD_LOGIC'image(data(23)) & STD_LOGIC'image(data(22)) & STD_LOGIC'image(data(21)) & STD_LOGIC'image(data(20)) & STD_LOGIC'image(data(19)) & STD_LOGIC'image(data(18)) & STD_LOGIC'image(data(17)) & STD_LOGIC'image(data(16)) & STD_LOGIC'image(data(15)) & STD_LOGIC'image(data(14)) & STD_LOGIC'image(data(13)) & STD_LOGIC'image(data(12)) & STD_LOGIC'image(data(11)) & STD_LOGIC'image(data(10)) & STD_LOGIC'image(data(9)) & STD_LOGIC'image(data(8)) & STD_LOGIC'image(data(7)) & STD_LOGIC'image(data(6)) & STD_LOGIC'image(data(5)) & STD_LOGIC'image(data(4)) & STD_LOGIC'image(data(3)) & STD_LOGIC'image(data(2)) & STD_LOGIC'image(data(1)) & STD_LOGIC'image(data(0));

		--we <= '0';
		--re <= '0';
		--WAIT FOR 1 * clk_period;




		REPORT "#####################################################End test";
		else
			count <= '1';
			WAIT FOR 100 * clk_period;
		end if;
	END PROCESS;
END;