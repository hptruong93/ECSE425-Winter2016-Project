library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.register_array.all;
use work.ForwardingUtil.all;
use work.StallUtil.all;

entity Decoder is
port (	clk 	: in STD_LOGIC;
			reset : in STD_LOGIC;
			instruction : in STD_LOGIC_VECTOR(32-1 downto 0);

			pc_reg : in STD_LOGIC_VECTOR(32-1 downto 0);
			registers : in register_array;

			operation : out STD_LOGIC_VECTOR(6-1 downto 0);
			mem_writeback_register : out STD_LOGIC_VECTOR(5-1 downto 0); --sEND to memstage or writeback
			-- for store, this represents the register that we're storing. For load, this represents the register getting the value from memory.
			signal_to_mem : out STD_LOGIC_VECTOR(3-1 downto 0); --sEND to mem stage
			writeback_source : out STD_LOGIC_VECTOR(3-1 downto 0); --sEND to writeback
			branch_signal : out STD_LOGIC_VECTOR(2-1 downto 0); --sEND to branch
			branch_address : out STD_LOGIC_VECTOR(32-1 downto 0);

			data1 : out STD_LOGIC_VECTOR(32-1 downto 0); --sEND to ALU
			data2 : out STD_LOGIC_VECTOR(32-1 downto 0); --sEND to ALU

			do_stall : out STD_LOGIC;

			--Forwarding
			data1_register : out STD_LOGIC_VECTOR(5-1 downto 0); --sEND to ALU
			data2_register : out STD_LOGIC_VECTOR(5-1 downto 0); --sEND to ALU

			previous_destinations_output : out previous_destination_array;
			previous_sources_output : out previous_source_arrray
	);
END Decoder;

architecture behavioral of Decoder is

signal previous_destinations : previous_destination_array; --biggest index is latest
signal previous_sources : previous_source_arrray; --biggest index is latest

signal ZERO_REGISTER : REGISTER_INDEX := (others => '0');

signal op_code, funct : STD_LOGIC_VECTOR(6-1 downto 0);
signal rs, rt, rd : REGISTER_INDEX;
signal sa : STD_LOGIC_VECTOR(5-1 downto 0);
signal immediate : STD_LOGIC_VECTOR(16-1 downto 0);
signal target : STD_LOGIC_VECTOR(26-1 downto 0);

BEGIN
	previous_destinations_output <= previous_destinations;
	previous_sources_output <= previous_sources;

	op_code <= instruction(32-1 downto 26);
	rs <= instruction(25 downto 21);
	rt <= instruction(20 downto 16);
	rd <= instruction(15 downto 11);
	sa <= instruction(10 downto 6);
	funct <= instruction(5 downto 0);
	immediate <= instruction(15 downto 0);
	target <= instruction(25 downto 0);

	synced_clock : process(clk, reset)

		PROCEDURE update_history (--Forwarding logic
				signal register_destination : in REGISTER_INDEX;
				CONSTANT source : in STD_LOGIC;
				signal data1_source : in REGISTER_INDEX;
				signal data2_source : in REGISTER_INDEX
			) is
		BEGIN
			previous_destinations(2) <= register_destination;
			previous_sources(2) <= FORWARD_SOURCE_ALU;
			data1_register <= data1_source;
			data2_register <= data2_source;
		END update_history;

		PROCEDURE stall_decoder is
		BEGIN
			SHOW("Decoder STALLING");
			operation <= "100000"; --add
			data1 <= (others => '0');
			data2 <= (others => '0');
			mem_writeback_register <= (others => '0');
			writeback_source <= NO_WRITE_BACK;

			do_stall <= '1';
			update_history(ZERO_REGISTER, FORWARD_SOURCE_ALU, ZERO_REGISTER, ZERO_REGISTER);
		END stall_decoder;

		IMPURE FUNCTION check_stall(destination_register : in REGISTER_INDEX) RETURN STD_LOGIC is
		BEGIN
			RETURN SHOULD_STALL(destination_register, previous_destinations, previous_sources);
		END check_stall;

	BEGIN
		if reset = '1' then
			for i in previous_destinations'range loop
				previous_destinations(i) <= "00000";
				previous_sources(i) <= '0';
			END loop;
		elsif (rising_edge(clk)) then
			previous_destinations(0) <= previous_destinations(1);
			previous_destinations(1) <= previous_destinations(2);
			previous_sources(0) <= previous_sources(1);
			previous_sources(1) <= previous_sources(2);

			if instruction = STD_LOGIC_VECTOR(ALL_32_ZEROES) then
				stall_decoder;
				do_stall <= '0'; --This will overwrite the value in stall_decoder procedure
			else
				branch_signal <= BRANCH_NOT;
				SHOW("OP code is " & integer'image(to_integer(unsigned(op_code))));

				case( op_code ) is
					when "000000" =>
						operation <= funct;
						mem_writeback_register <= rd;

						case( funct ) is
							when "100000" => --add
								if (check_stall(rd) = '1') then
									stall_decoder;
								else
									update_history(rd, FORWARD_SOURCE_ALU, rs, rt);

									SHOW(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ADD!!! " & integer'image(to_integer(unsigned(rs))) & integer'image(to_integer(unsigned(rt))));
									data1 <= registers(to_integer(unsigned(rs)));
									data2 <= registers(to_integer(unsigned(rt)));
									writeback_source <= ALU_AS_SOURCE;
								end if;
							when "100010" => --sub
								if (check_stall(rd) = '1') then
									stall_decoder;
								else
									update_history(rd, FORWARD_SOURCE_ALU, rs, rt);

									SHOW(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> SUB!!! " & integer'image(to_integer(unsigned(rs))) & integer'image(to_integer(unsigned(rt))));
									data1 <= registers(to_integer(unsigned(rs)));
									data2 <= registers(to_integer(unsigned(rt)));
									writeback_source <= ALU_AS_SOURCE;
								end if;
							when "011000" => --mult
								--Have to stall for three cycle instead of one
								update_history(ZERO_REGISTER, FORWARD_SOURCE_ALU, rs, rt);

								SHOW(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> MULT!!! " & integer'image(to_integer(unsigned(rs))) & integer'image(to_integer(unsigned(rt))));
								data1 <= registers(to_integer(unsigned(rs)));
								data2 <= registers(to_integer(unsigned(rt)));
								writeback_source <= ALU_AS_SOURCE;
							when "011010" => --div
								update_history(ZERO_REGISTER, FORWARD_SOURCE_ALU, rs, rt);

								data1 <= registers(to_integer(unsigned(rs)));
								data2 <= registers(to_integer(unsigned(rt)));
								writeback_source <= ALU_AS_SOURCE;
							when "100100" => --and
								if (check_stall(rd) = '1') then
									stall_decoder;
								else
									update_history(rd, FORWARD_SOURCE_ALU, rs, rt);

									data1 <= registers(to_integer(unsigned(rs)));
									data2 <= registers(to_integer(unsigned(rt)));
									writeback_source <= ALU_AS_SOURCE;
								end if;
							when "100101" => --or
								if (check_stall(rd) = '1') then
									stall_decoder;
								else
									update_history(rd, FORWARD_SOURCE_ALU, rs, rt);

									data1 <= registers(to_integer(unsigned(rs)));
									data2 <= registers(to_integer(unsigned(rt)));
									writeback_source <= ALU_AS_SOURCE;
								end if;
							when "100111" => --nor
								if (check_stall(rd) = '1') then
									stall_decoder;
								else
									update_history(rd, FORWARD_SOURCE_ALU, rs, rt);

									data1 <= registers(to_integer(unsigned(rs)));
									data2 <= registers(to_integer(unsigned(rt)));
									writeback_source <= ALU_AS_SOURCE;
								end if;
							when "100110" => --xor
								if (check_stall(rd) = '1') then
									stall_decoder;
								else
									update_history(rd, FORWARD_SOURCE_ALU, rs, rt);

									data1 <= registers(to_integer(unsigned(rs)));
									data2 <= registers(to_integer(unsigned(rt)));
									writeback_source <= ALU_AS_SOURCE;
								end if;

							--A wild jr appears
							when "001000" => --jr
								if (check_stall(ZERO_REGISTER) = '1') then
									stall_decoder;
								else
									update_history(ZERO_REGISTER, FORWARD_SOURCE_ALU, rs, rt);

									SHOW("Handling a wild jr at register " & integer'image(to_integer(unsigned(rs))));
									operation <= "100000"; --Tell ALU to not do anything
									data1 <= (others => '0');
									data2 <= (others => '0');
									writeback_source <= NO_WRITE_BACK;
									mem_writeback_register <= "00000"; --Don't write back

									branch_signal <= BRANCH_ALWAYS;
									branch_address <= registers(to_integer(unsigned(rs)));
								end if;
	-------------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------SHIFTS OPERATIONS-------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------------------------------
							when "101010" => --slt
								if (check_stall(rd) = '1') then
									stall_decoder;
								else
									update_history(rd, FORWARD_SOURCE_ALU, rs, rt);

									data1 <= registers(to_integer(unsigned(rs)));
									data2 <= registers(to_integer(unsigned(rt)));
									writeback_source <= ALU_AS_SOURCE;
								end if;
							when "000000" => --sll
								if (check_stall(rd) = '1') then
									stall_decoder;
								else
									update_history(rd, FORWARD_SOURCE_ALU, rs, rt);

									data1 <= registers(to_integer(unsigned(rs)));
									data2 <= STD_LOGIC_VECTOR(resize(signed(sa), data2'length));
									writeback_source <= ALU_AS_SOURCE;
								end if;
							when "000010" => --srl
								if (check_stall(rd) = '1') then
									stall_decoder;
								else
									update_history(rd, FORWARD_SOURCE_ALU, rs, rt);

									data1 <= registers(to_integer(unsigned(rs)));
									data2 <= STD_LOGIC_VECTOR(resize(signed(sa), data2'length));
									writeback_source <= ALU_AS_SOURCE;
								end if;
							when "000011" => --sra
								if (check_stall(rd) = '1') then
									stall_decoder;
								else
									update_history(rd, FORWARD_SOURCE_ALU, rs, rt);

									data1 <= registers(to_integer(unsigned(rs)));
									data2 <= STD_LOGIC_VECTOR(resize(signed(sa), data2'length));
									writeback_source <= ALU_AS_SOURCE;
								end if;
							when "010000" => --mfhi
								update_history(rd, FORWARD_SOURCE_ALU, ZERO_REGISTER, ZERO_REGISTER);
								writeback_source <= HI_AS_SOURCE;
							when "010010" => --mflo
								update_history(rd, FORWARD_SOURCE_ALU, ZERO_REGISTER, ZERO_REGISTER);
								writeback_source <= LO_AS_SOURCE;

							when others =>

						END case ;
-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------IMMEDIATE OPERATIONS----------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
					when "001000" => -- addi
						if (check_stall(rt) = '1') then
							stall_decoder;
						else
							update_history(rt, FORWARD_SOURCE_ALU, rs, ZERO_REGISTER);

							SHOW(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ADDI!!! " & integer'image(to_integer(unsigned(rs))) & integer'image(to_integer(signed(immediate))));
							operation <= "100000";
							data1 <= registers(to_integer(unsigned(rs)));
							data2 <= STD_LOGIC_VECTOR(resize(signed(immediate), data2'length));
							mem_writeback_register <= rt;
							writeback_source <= ALU_AS_SOURCE;
						end if;
					when "001010" => -- slti
						if (check_stall(rt) = '1') then
							stall_decoder;
						else
							update_history(rt, FORWARD_SOURCE_ALU, rs, ZERO_REGISTER);

							SHOW("Here slti");
							operation <= "101010";
							data1 <= registers(to_integer(unsigned(rs)));
							data2 <= STD_LOGIC_VECTOR(resize(signed(immediate), data2'length));
							mem_writeback_register <= rt;
							writeback_source <= ALU_AS_SOURCE;
						end if;
					when "001100" => -- andi
						if (check_stall(rt) = '1') then
							stall_decoder;
						else
							update_history(rt, FORWARD_SOURCE_ALU, rs, ZERO_REGISTER);

							SHOW("Here andi");
							operation <= "100100";
							data1 <= registers(to_integer(unsigned(rs)));
							data2 <= STD_LOGIC_VECTOR(resize(signed(immediate), data2'length));
							mem_writeback_register <= rt;
							writeback_source <= ALU_AS_SOURCE;
						end if;
					when "001101" => -- ori
						if (check_stall(rt) = '1') then
							stall_decoder;
						else
							update_history(rt, FORWARD_SOURCE_ALU, rs, ZERO_REGISTER);

							SHOW("Here ori");
							operation <= "100101";
							data1 <= registers(to_integer(unsigned(rs)));
							data2 <= STD_LOGIC_VECTOR(resize(signed(immediate), data2'length));
							mem_writeback_register <= rt;
							writeback_source <= ALU_AS_SOURCE;
						end if;
					when "001110" => -- xori
						if (check_stall(rt) = '1') then
							stall_decoder;
						else
							update_history(rt, FORWARD_SOURCE_ALU, rs, ZERO_REGISTER);

							SHOW("Here xori");
							operation <= "100110";
							data1 <= registers(to_integer(unsigned(rs)));
							data2 <= STD_LOGIC_VECTOR(resize(signed(immediate), data2'length));
							mem_writeback_register <= rt;
							writeback_source <= ALU_AS_SOURCE;
						end if;

-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------MEMORY OPERATIONS-------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
					when "001111" => --lui --We shift the immediate value by 16 using the ALU
						update_history(rt, FORWARD_SOURCE_ALU, ZERO_REGISTER, ZERO_REGISTER);

						SHOW("Here lui");
						operation <= "000000"; --sll
						data1	<= STD_LOGIC_VECTOR(resize(signed(immediate), data1'length));
						data2	<= STD_LOGIC_VECTOR(to_unsigned(16, data2'length));
						mem_writeback_register <= rt;
						writeback_source <= ALU_AS_SOURCE;
					when "100011" => --lw
						update_history(rt, FORWARD_SOURCE_MEM, rs, ZERO_REGISTER);

						SHOW("Here lw");
						operation <= "100000"; --add
						data1	<= registers(to_integer(unsigned(rs)));
						data2	<= STD_LOGIC_VECTOR(resize(signed(immediate), data2'length));
						mem_writeback_register <= rt;
						writeback_source <= MEM_AS_SOURCE;
						signal_to_mem <= LOAD_WORD;
					when "101011" => --sw
						update_history(ZERO_REGISTER, FORWARD_SOURCE_MEM, rs, ZERO_REGISTER);

						SHOW("Here sw");
						operation <= "100000"; --add
						data1	<= registers(to_integer(unsigned(rs)));
						data2	<= STD_LOGIC_VECTOR(resize(signed(immediate), data2'length));
						mem_writeback_register <= rt; --Don't write back
						writeback_source <= NO_WRITE_BACK;
						signal_to_mem <= STORE_WORD;
					when "100000" => --lb
						update_history(rt, FORWARD_SOURCE_MEM, rs, ZERO_REGISTER);

						SHOW("Here lb");
						operation <= "100000"; --add
						data1	<= registers(to_integer(unsigned(rs)));
						data2	<= STD_LOGIC_VECTOR(resize(signed(immediate), data2'length));
						mem_writeback_register <= rt;
						writeback_source <= MEM_AS_SOURCE;
						signal_to_mem <= LOAD_BYTE;
					when "101000" => --sb
						update_history(ZERO_REGISTER, FORWARD_SOURCE_MEM, rs, ZERO_REGISTER);

						SHOW("Here sb");
						operation <= "100000"; --add
						data1	<= registers(to_integer(unsigned(rs)));
						data2	<= STD_LOGIC_VECTOR(resize(signed(immediate), data2'length));
						mem_writeback_register <= rt; --Don't write back
						writeback_source <= NO_WRITE_BACK;
						signal_to_mem <= STORE_BYTE;
-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------BRANCH AND JUMPS--------------------------------------------------------------------
-----------------------------------------------Assume resolved in Decode-----------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
					when "000100" => --beq
						--Stall here until result is forwarded actually
						update_history(ZERO_REGISTER, FORWARD_SOURCE_ALU, rs, rt);

						SHOW("Here beq");
						operation <= "100000"; --Tell ALU to not do anything
						data1 <= (others => '0');
						data2 <= (others => '0');
						writeback_source <= NO_WRITE_BACK;
						mem_writeback_register <= "00000"; --Don't write back

						if registers(to_integer(unsigned(rs))) = registers(to_integer(unsigned(rt))) then --Do branch
							branch_signal <= BRANCH_ALWAYS;
							branch_address <= std_logic_vector(resize(unsigned(immediate), branch_address'length));
						else
							branch_signal <= BRANCH_NOT;
						end if;
					when "000101" => --bne
						--Stall here until result is forwarded actually
						update_history(ZERO_REGISTER, FORWARD_SOURCE_ALU, rs, rt);

						SHOW("Here bne");
						operation <= "100000"; --Tell ALU to not do anything
						data1 <= (others => '0');
						data2 <= (others => '0');
						writeback_source <= NO_WRITE_BACK;
						mem_writeback_register <= "00000"; --Don't write back

						if registers(to_integer(unsigned(rs))) /= registers(to_integer(unsigned(rt))) then --Do branch
							branch_signal <= BRANCH_ALWAYS;
							branch_address <= std_logic_vector(resize(unsigned(immediate), branch_address'length));
						else
							branch_signal <= BRANCH_NOT;
						end if;
					when "000010" => --j
						update_history(ZERO_REGISTER, FORWARD_SOURCE_ALU, ZERO_REGISTER, ZERO_REGISTER);

						SHOW("--------------------------------------------------------Here j");
						operation <= "100000"; --Tell ALU to not do anything
						data1 <= (others => '0');
						data2 <= (others => '0');
						writeback_source <= NO_WRITE_BACK;
						mem_writeback_register <= "00000"; --Don't write back
						branch_signal <= BRANCH_ALWAYS;
						branch_address <= std_logic_vector(resize(unsigned(target), branch_address'length));
					when "000011" => --jal --> $31 = $PC + 8, jump
						update_history(ZERO_REGISTER, FORWARD_SOURCE_ALU, ZERO_REGISTER, ZERO_REGISTER);

						SHOW("Here jal");
						--The address in $ra is really PC+8. The instruction immediately following the jal instruction is in the "branch delay slot"
						operation <= "100000"; --add
						data1	<= pc_reg;
						data2	<= STD_LOGIC_VECTOR(to_unsigned(8, data2'length));
						mem_writeback_register <= "11111"; --$31 = $PC + 8
						writeback_source <= ALU_AS_SOURCE;
						branch_signal <= BRANCH_ALWAYS;
						branch_address <= std_logic_vector(resize(unsigned(target), branch_address'length));
					--when => --jr (see above)
					when others =>

				END case ;
			end if ;
		end if;
	END process ; -- synced_clock


END behavioral;
