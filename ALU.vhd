
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;



entity ALU is
port (	clk 	: in STD_LOGIC;
			reset : in STD_LOGIC;
			
			data1	:	in signed(32-1 downto 0);
			data2	:	in signed(32-1 downto 0);

			operation : in STD_LOGIC_VECTOR(6-1 downto 0);
			lo_reg : out signed (32-1 downto 0);
			hi_reg : out signed (32-1 downto 0);
			result : out signed(32-1 downto 0)
	);
end ALU;

architecture behavioral of ALU is

signal mult_result : signed (64-1 downto 0);
--signal data1_extended, data2_extended, result_extended : signed(33-1 downto 0);

begin

	synced_clock : process(clk, reset)
	begin
		if reset = '1' then
			
		elsif (rising_edge(clk)) then
			case( operation ) is
				when "100000" => --add
					REPORT "Here 23" & STD_LOGIC'image(data1(31));
					REPORT "Adding shit 29 " & integer'image(to_integer(data1));
					REPORT "Adding another shit 29 " & integer'image(to_integer(data2));
					result <= data1 + data2;
				when "100010" => --sub
					result <= data1 - data2; --Add overflow
				when "011000" => --mult
					mult_result <= data1 * data2;
					hi_reg <= mult_result(64-1 downto 32);
					lo_reg <= mult_result(32-1 downto 0);
				when "011010" => --div
					lo_reg <= data1 / data2;
					hi_reg <= data1 mod data2;
				when "101010" => --slt
					if data1 < data2 then
						result <= to_signed(1, 32);
					end if;
				when "100100" => --and
					result <= data1 and data2;
				when "100101" => --or
					result <= data1 or data2;
				when "100111" => --nor
					result <= data1 nor data2;
				when "100110" => --xor
					result <= data1 xor data2;
				when "000000" => --sll
					result <= data1 sll to_integer(data2);
				when "000010" => --srl
					result <= data1 srl to_integer(data2);
				when "000011" => --sra
					result <= shift_right(data1, to_integer(data2));
				when others =>
			end case ;
		end if;
	end process ; -- synced_clock
	

end behavioral;
