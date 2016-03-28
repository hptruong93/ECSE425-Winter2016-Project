--SIGNED to INTEGER
INTEGER'image(TO_INTEGER(address));

--SIGNED to STD_LOGIC_VECTOR
STD_LOGIC_VECTOR(address);

--STD_LOGIC_VECTOR to INTEGER
INTEGER'image(TO_INTEGER(UNSIGNED(address)));
INTEGER'image(TO_INTEGER(SIGNED(address)));

--INTEGER to STD_LOGIC_VECTOR
STD_LOGIC_VECTOR(TO_UNSIGNED(my_int, my_slv'length));

--print the array
STD_LOGIC'image(data1(31)) & STD_LOGIC'image(data1(30)) & STD_LOGIC'image(data1(29)) & STD_LOGIC'image(data1(28)) & STD_LOGIC'image(data1(27)) & STD_LOGIC'image(data1(26)) & STD_LOGIC'image(data1(25)) & STD_LOGIC'image(data1(24)) & STD_LOGIC'image(data1(23)) & STD_LOGIC'image(data1(22)) & STD_LOGIC'image(data1(21)) & STD_LOGIC'image(data1(20)) & STD_LOGIC'image(data1(19)) & STD_LOGIC'image(data1(18)) & STD_LOGIC'image(data1(17)) & STD_LOGIC'image(data1(16)) & STD_LOGIC'image(data1(15)) & STD_LOGIC'image(data1(14)) & STD_LOGIC'image(data1(13)) & STD_LOGIC'image(data1(12)) & STD_LOGIC'image(data1(11)) & STD_LOGIC'image(data1(10)) & STD_LOGIC'image(data1(9)) & STD_LOGIC'image(data1(8)) & STD_LOGIC'image(data1(7)) & STD_LOGIC'image(data1(6)) & STD_LOGIC'image(data1(5)) & STD_LOGIC'image(data1(4)) & STD_LOGIC'image(data1(3)) & STD_LOGIC'image(data1(2)) & STD_LOGIC'image(data1(1)) & STD_LOGIC'image(data1(0));

--for loop
for i in previous_destinations'range loop
	previous_destinations(i) <= "00000";
	previous_sources(i) <= '0';
end loop;