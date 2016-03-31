import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.nio.charset.Charset;

public class Assembler {

	private static final int EMPTY = Integer.MIN_VALUE;

	private static final int OP_CODE_LENGTH = 6;
	private static final int FUNCTION_LENGTH = 6;
	private static final int SHIFT_AMOUNT_LENGTH = 5;
	private static final int REGISTER_LENGTH = 5;
	private static final int IMMEDIATE_LENGTH = 16;
	private static final int ADDRESS_LENGTH = 26;

	private static final String REGISTER_ZERO = toBinary(0, REGISTER_LENGTH);

	private static String input;
	private static Map<String, Integer> labels = new HashMap<>();
	private static final Set<String> rtype = new HashSet<>(Arrays.asList(new String[]{
			"add", "sub", "slt", "and", "or", "nor", "xor"
	}));

	private static final Set<String> shiftType = new HashSet<>(Arrays.asList(new String[]{
			"sll", "srl", "sra",
	}));

	private static final Set<String> moveType = new HashSet<>(Arrays.asList(new String[]{
			"mfhi", "mflo"
	}));

	private static final Set<String> multType = new HashSet<>(Arrays.asList(new String[]{
			"mult", "div"
	}));

	private static final Set<String> itype = new HashSet<>(Arrays.asList(new String[]{
			"addi", "slti", "andi", "ori", "xori",
	}));

	private static final Set<String> luiType = new HashSet<>(Arrays.asList(new String[]{
			"lui"
	}));

	private static final Set<String> jtype = new HashSet<>(Arrays.asList(new String[]{
			"j", "jal"
	}));

	private static final Set<String> jrType = new HashSet<>(Arrays.asList(new String[]{
			"jr",
	}));

	private static final Set<String> branchType = new HashSet<>(Arrays.asList(new String[]{
			"beq", "bne"
	}));

	private static final Set<String> memType = new HashSet<>(Arrays.asList(new String[]{
			"lw", "sw", "lb", "sb"
	}));

	private static final Map<String, Integer> mapOpCode, mapFunction;
	static {
		mapOpCode = new HashMap<>();
		mapFunction = new HashMap<>();

		mapOpCode.put("add", 0);		mapFunction.put("add", 0x20);
		mapOpCode.put("sub", 0);		mapFunction.put("sub", 0x22);
		mapOpCode.put("slt", 0);		mapFunction.put("slt", 0x2A);
		mapOpCode.put("and", 0);		mapFunction.put("and", 0x24);
		mapOpCode.put("or", 0);			mapFunction.put("or", 0x25);
		mapOpCode.put("nor", 0);		mapFunction.put("nor", 0x27);
		mapOpCode.put("xor", 0);		mapFunction.put("xor", 0x26);
		mapOpCode.put("sll", 0);		mapFunction.put("sll", 0x00);
		mapOpCode.put("srl", 0);		mapFunction.put("srl", 0x02);
		mapOpCode.put("sra", 0);		mapFunction.put("sra", 0x03);

		mapOpCode.put("lb", 0x20);		mapFunction.put("lb", EMPTY);
		mapOpCode.put("sb", 0x28);		mapFunction.put("sb", EMPTY);
		mapOpCode.put("lw", 0x23);		mapFunction.put("lw", EMPTY);
		mapOpCode.put("sw", 0x2B);	 	mapFunction.put("sw", EMPTY);

		mapOpCode.put("addi", 0x08);	mapFunction.put("addi", EMPTY);
		mapOpCode.put("slti", 0x0A);	mapFunction.put("slti", EMPTY);
		mapOpCode.put("andi", 0x0C);	mapFunction.put("andi", EMPTY);
		mapOpCode.put("ori", 0x0D);		mapFunction.put("ori", EMPTY);
		mapOpCode.put("xori", 0x0E);	mapFunction.put("xori", EMPTY);
		mapOpCode.put("lui", 0x0F);		mapFunction.put("lui", EMPTY);


		mapOpCode.put("beq", 0x04);		mapFunction.put("bne", EMPTY);
		mapOpCode.put("bne", 0x05);		mapFunction.put("beq", EMPTY);
		mapOpCode.put("j", 0x02);		mapFunction.put("j", EMPTY);
		mapOpCode.put("jr", 0x00);		mapFunction.put("jr", 0x08);
		mapOpCode.put("jal", 0x03);		mapFunction.put("jal", EMPTY);

		mapOpCode.put("mfhi", 0x00);	mapFunction.put("mfhi", 0x10);
		mapOpCode.put("mflo", 0x00);	mapFunction.put("mflo", 0x12);

		mapOpCode.put("mult", 0x00);	mapFunction.put("mult", 0x18);
		mapOpCode.put("div", 0x00);		mapFunction.put("div", 0x1A);
	}

	public static void main(String[] args) {
		String data = readFromFile(new File("assembler.asm")).toString();
		System.out.println(loopTwice(data).toString());
	}

	public static StringBuffer loopTwice(String input) {
		StringBuffer output = new StringBuffer();
		String[] lines = input.split("\n");
                for (int i = 0; i < lines.length; i++) {
                        String line = lines[i];
                        try {
                                process(i, line, true);
                        } catch (Exception e) {
                                System.out.println("Exception encountered on line " + i);
                                System.out.println(line);
                                throw e;
                        }
                }
				int count = 0;
                for (int i = 0; i < lines.length; i++) {
                        String line = lines[i];
                        try {
                                String kk = process(count, line, false);
									if (kk.isEmpty()) {
										continue;
									}
									count++;

									output.append(kk);
									output.append("\n");
                        } catch (Exception e) {
                                System.out.println("Exception encountered on line " + i);
                                System.out.println(line);
                                throw e;
                        }
                }
		return output;
	}

private	static int n = 0;
	private static String process(int lineNumber, String line, boolean labelingOnly) {
		line = removeComments(line).replace(",", " ").trim();
		if (line.isEmpty()) {
			return "";
		}

		String command, label;
		if (line.contains(":")) {
			String[] split = line.split(":");
			label = split[0];
			command = split.length > 1 ? split[1] : "";
		} else {
			label = "";
			command = line;
		}
		label = label.trim();
		command = command.trim();

		if (labelingOnly && !label.isEmpty()) {
			// System.out.println("Labeling " + label + " on line " + lineNumber);
			labels.put(label, lineNumber);
		}

		if (!labelingOnly && !command.isEmpty()) {
			List<String> split = split(command);
			String result = generate(split);
			return result;
		//System.out.print(n + ": " + result.substring(0,4) + " " + result.substring(4, 8) + " " + result.substring(8, 12) + " " +  result.substring(12, 16) + " " +  result.substring(16, 20) + " " + result.substring(20, 24) + " " + result.substring(24, 28) + " " +  result.substring(28, 32) + "  ----  " + command + "\n");
		//	System.out.println(Integer.parseInt(result, 2));
		//n++;
		}
		return "";
	}

	private static String generate(List<String> command) {
		String result = null;
		String op = command.get(0);
		if (rtype.contains(op)) {
			checkParam(3, command);
			String d = command.get(1);
			String s = command.get(2);
			String t = command.get(3);

			result = toOpCode(op) +
					toReg(s) + toReg(t) + toReg(d) +
					toBinary(0, SHIFT_AMOUNT_LENGTH) +
					toFunction(op);
		} else if (shiftType.contains(op)) {
			checkParam(3, command);
			String d = command.get(1);
			String t = command.get(2);
			String shiftAmount = command.get(3);

			result = toOpCode(op) +
					REGISTER_ZERO + toReg(t) + toReg(d) +
					toBinary(Integer.parseInt(shiftAmount), SHIFT_AMOUNT_LENGTH) +
					toFunction(op);
		} else if (moveType.contains(op)) {
			checkParam(1, command);
			String d = command.get(1);

			result = toOpCode(op) +
					REGISTER_ZERO + REGISTER_ZERO + toReg(d) +
					toBinary(0, SHIFT_AMOUNT_LENGTH) + toFunction(op);
		} else if (multType.contains(op)) {
			checkParam(2, command);
			String s = command.get(1);
			String t = command.get(2);

			result = toOpCode(op) +
					toReg(s) + toReg(t) + REGISTER_ZERO +
					toBinary(0, SHIFT_AMOUNT_LENGTH) + toFunction(op);
		} else if (itype.contains(op)) {
			checkParam(3, command);
			String t = command.get(1);
			String s = command.get(2);
			String immediate = command.get(3);

			result = toOpCode(op) +
					toReg(s) + toReg(t) +
					toImmediate(immediate);
		} else if (luiType.contains(op)) {
			checkParam(2, command);
			String t = command.get(1);
			String immediate = command.get(2);

			result = toOpCode(op) + REGISTER_ZERO + toReg(t) +
					toImmediate(immediate);
		} else if (jtype.contains(op)) {
			checkParam(1, command);
			String label = command.get(1);

			result = toOpCode(op) + toBinary(getLabelAddress(label), ADDRESS_LENGTH);
		} else if (jrType.contains(op)) {
			checkParam(1, command);
			String s = command.get(1);

			result = toOpCode(op) +
					toReg(s) + REGISTER_ZERO + REGISTER_ZERO +
					toBinary(0, SHIFT_AMOUNT_LENGTH) + toFunction(op);
		} else if (branchType.contains(op)) {
			checkParam(3, command);
			String t = command.get(1);
			String s = command.get(2);
			String label = command.get(3);

			result = toOpCode(op) + toReg(s) + toReg(t) + toImmediate(getLabelAddress(label));
		} else if (memType.contains(op)) {
			checkParam(2, command);
			String t = command.get(1);
			String s = command.get(2);
			String [] offsetAddress =  toOffsetAddress(s);
			//System.out.println("Address is " + toReg(t));
			result = toOpCode(op) +  offsetAddress[0]  +  toReg(t) + offsetAddress[1] ;
		} else {
			throw new IllegalArgumentException("Op code not found " + op);
		}

		return result;
	}

/********************************************************************************************/
/**********************************Helper functions******************************************/
/********************************************************************************************/

	/**
	 * Split a line into multiple parts. Separated my one or many consecutive space/tabs
	 * @param line line to split
	 * @return list of parts split from the input
	 */
	private static List<String> split(String line) {
		List<String> part = new ArrayList<>();
		StringBuilder current = new StringBuilder();
		int index = 0;
		while (true) {
			if (index >= line.length()) {
				break;
			}

			char c = line.charAt(index);
			if (c == ' ' || c == '\t') {
				if (current.length() > 0) {
					part.add(current.toString());
					current = new StringBuilder();
				}
			} else {
				current.append(c);
			}

			index++;
		}
		if (current.length() > 0) {
			part.add(current.toString());
		}

		return part;
	}

	private static String removeComments(String input) {
		int index = input.indexOf('#');
		if (index == -1) {
			return input;
		}
		return input.substring(0, index);
	}

	/**
	 * Assume first instruction starts at 0x00.
	 * Each instruction is 32 bits = 4 bytes
	 * @param name name of the label
	 * @return the address at which the label is at
	 */
	private static int getLabelAddress(String name) {
                Integer line = labels.get(name);
                if (line != null) {
			return 4 * labels.get(name);
		} else {
			return 4 * Integer.parseInt(name);
		}
	}

	private static String toImmediate(int immediate) {
		return toBinary(immediate, IMMEDIATE_LENGTH);
	}

	private static String toImmediate(String immediate) {
		if (!immediate.startsWith("0x")) {
			return toImmediate(Integer.parseInt(immediate));
		} else {
			return toImmediate(Integer.parseInt(immediate.substring(2), 16));
		}
	}

	private static String[] toOffsetAddress(String offsetAddress) {
		String[] split = offsetAddress.split("\\(");
		int offset = Integer.parseInt(split[0]);
		String reg = split[1].substring(0, split[1].length() - 1);
		reg = toReg(reg);

		return new String[]{reg, toBinary(offset, IMMEDIATE_LENGTH)};
	}

	private static String toReg(String regName) {
		if (!regName.startsWith("$")) {
			throw new IllegalArgumentException("No $");
		}

		int i = 0;
		for (i = 0; i < regName.length(); i++) {
			if (regName.charAt(i) <= '9' && regName.charAt(i) >= '0') {
				break;
			}
		}

		return toBinary(Integer.parseInt(regName.substring(i)), REGISTER_LENGTH);
	}

	private static String toOpCode(String op) {
		return toBinary(mapOpCode.get(op), OP_CODE_LENGTH);
	}

	private static String toFunction(String op) {
		return toBinary(mapFunction.get(op), FUNCTION_LENGTH);
	}

	private static String toBinary(int input, int length) {
		if (input == EMPTY) {
			return "";
		}


		String output = Integer.toBinaryString(input);
		int missing = length - output.length();
		while (missing > 0) {
			output = "0" + output;
			missing--;
		}
		if (missing < 0)
		{
			output = output.substring(output.length() - length, output.length());
		}
		return output;
	}

/********************************************************************************************/
/**********************************Exception handling functions******************************/
/********************************************************************************************/
	private static void checkParam(int expected, List<String> command) {
		if (command.size() == 0) {
			throw new IllegalArgumentException("No argument found");
		} else {
			if (command.size() - 1 != expected) {
				throw new IllegalArgumentException("Expected " + expected + " argument but only have " + (command.size() - 1) + "argument(s)");
			}
		}
	}

	/**
	 * Read a plain text file.
	 * @param file file that will be read
	 * @return StringBuffer the read result.
	 */
	public static StringBuffer readFromFile(File file) {
		StringBuffer output = new StringBuffer("");
		FileInputStream fr = null;

		try {
			fr = new FileInputStream(file);

			InputStreamReader char_input = new InputStreamReader(fr, Charset.forName("UTF-8").newDecoder());

			BufferedReader br = new BufferedReader(char_input);

			while (true) {
	            String in = br.readLine();
	            if (in == null) {
	               break;
	            }
	            output.append(in).append("\n");
	        }

			br.close();

		} catch (IOException e) {
			e.printStackTrace();
			return null;
		} finally {
			if (fr != null) {
				try {
					fr.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
		return output;
	}

}
