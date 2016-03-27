--SIGNED to INTEGER
INTEGER'image(TO_INTEGER(address));

--SIGNED to std_logic_vector
STD_LOGIC_VECTOR(address);

--std_logic_vector to INTEGER
INTEGER'image(TO_INTEGER(UNSIGNED(address)));
INTEGER'image(TO_INTEGER(SIGNED(address)));

--print the array
SIGNED'image(data1(31)) & SIGNED'image(data1(30)) & SIGNED'image(data1(29)) & SIGNED'image(data1(28)) & SIGNED'image(data1(27)) & SIGNED'image(data1(26)) & SIGNED'image(data1(25)) & SIGNED'image(data1(24)) & SIGNED'image(data1(23)) & SIGNED'image(data1(22)) & SIGNED'image(data1(21)) & SIGNED'image(data1(20)) & SIGNED'image(data1(19)) & SIGNED'image(data1(18)) & SIGNED'image(data1(17)) & SIGNED'image(data1(16)) & SIGNED'image(data1(15)) & SIGNED'image(data1(14)) & SIGNED'image(data1(13)) & SIGNED'image(data1(12)) & SIGNED'image(data1(11)) & SIGNED'image(data1(10)) & SIGNED'image(data1(9)) & SIGNED'image(data1(8)) & SIGNED'image(data1(7)) & SIGNED'image(data1(6)) & SIGNED'image(data1(5)) & SIGNED'image(data1(4)) & SIGNED'image(data1(3)) & SIGNED'image(data1(2)) & SIGNED'image(data1(1)) & SIGNED'image(data1(0));