#include <cstdio>
#include <fstream>
#include <string>
#include <algorithm>


#define OP_LW       "111000"
#define OP_SW       "010000"
#define OP_ADD      "100000"
#define OP_BEQ      "000100"
#define OP_DISP     "011000"
#define OP_DISPR    "011100"
#define OP_SWL      "110000"

#define OP_SUB      "100010"
#define OP_AND      "100100"
#define OP_OR       "100101"
#define OP_XOR      "100110"
#define OP_SLT      "101010"
#define OP_NOT      "100011"

#define OP_LUI      "101111"
#define OP_ORI      "100111"
#define OP_HLT      "111111"

std::string delimiter = " ";

std::string toBinary(int input, int length = 5) {
    std::string res;

    int times = 0;
    while (input >= 1) {
        if (input % 2 == 0) {
            res.append("0");
        } else {
            res.append("1");
        }
        input /= 2;
        times++;
    }

    while (res.length() < length) res.append("0");

    std::reverse(res.begin(), res.end());
    return res;
}

std::string handleIType(const char *opcode, std::string operands) {
    std::string result(opcode);

    // get register rt
    std::string reg = operands.substr(0, operands.find(delimiter));
    operands.erase(0, operands.find(delimiter) + delimiter.length());

    // remove dollar sign
    reg.erase(0, 1);

    std::string rt = toBinary(std::stoi(reg));

    // get register rs
    std::string reg2 = operands.substr(0, operands.find(delimiter));
    operands.erase(0, operands.find(delimiter) + delimiter.length());

    // remove dollar sign
    reg2.erase(0, 1);

    std::string rs = toBinary(std::stoi(reg2));

    // get imm
    std::string immediate = toBinary(std::stoi(operands), 16);

    result.append(rs);
    result.append(rt);
    result.append(immediate);
    return result;
}

std::string handleDispr(const char *opcode, std::string operands) {
    std::string result(opcode);

    // get register rd
    std::string reg = operands.substr(0, operands.find(delimiter));
    operands.erase(0, operands.find(delimiter) + delimiter.length());

    // remove dollar sign
    reg.erase(0, 1);

    std::string rs = toBinary(std::stoi(reg));

    result.append(rs);
    result.append("00000");
    result.append("00000");
    result.append("00000000000");
    return result;
}

std::string handleSwitchLoad(const char *opcode, std::string operands) {
    std::string result(opcode);

    // get register rs
    std::string reg = operands.substr(0, operands.find(delimiter));
    operands.erase(0, operands.find(delimiter) + delimiter.length());

    // remove dollar sign
    reg.erase(0, 1);

    std::string rd = toBinary(std::stoi(reg));

    result.append("00000");
    result.append("00000");
    result.append(rd);
    result.append("00000000000");
    return result;
}

std::string handleLui(const char *opcode, std::string operands) {
    std::string result(opcode);

    // get register rt
    std::string reg = operands.substr(0, operands.find(delimiter));
    operands.erase(0, operands.find(delimiter) + delimiter.length());

    // remove dollar sign
    reg.erase(0, 1);

    std::string rt = toBinary(std::stoi(reg));

    // get imm
    std::string immediate = toBinary(std::stoi(operands), 16);

    result.append("00000");
    result.append(rt);
    result.append(immediate);
    return result;
}

std::string handleOri(const char *opcode, std::string operands) {
    std::string result(opcode);

    // get register rt
    std::string reg = operands.substr(0, operands.find(delimiter));
    operands.erase(0, operands.find(delimiter) + delimiter.length());

    // remove dollar sign
    reg.erase(0, 1);

    std::string rt = toBinary(std::stoi(reg));

    // get register rs
    std::string reg2 = operands.substr(0, operands.find(delimiter));
    operands.erase(0, operands.find(delimiter) + delimiter.length());

    // remove dollar sign
    reg2.erase(0, 1);

    std::string rs = toBinary(std::stoi(reg));

    // get imm
    std::string immediate = toBinary(std::stoi(operands), 16);

    result.append(rs);
    result.append(rt);
    result.append(immediate);
    return result;
}

std::string handleNot(const char *opcode, std::string operands) {
    std::string result(opcode);

    // get register rd
    std::string reg = operands.substr(0, operands.find(delimiter));
    operands.erase(0, operands.find(delimiter) + delimiter.length());

    // remove dollar sign
    reg.erase(0, 1);

    std::string rd = toBinary(std::stoi(reg));

    // get register rs
    reg = operands.substr(0, operands.find(delimiter));

    // remove dollar sign
    reg.erase(0, 1);

    std::string rs = toBinary(std::stoi(reg));
    operands.erase(0, operands.find(delimiter) + delimiter.length());

    result.append(rs);
    result.append("00000");
    result.append(rd);

    // shifting (optional)
    std::string shift_left = "lsl";
    std::string shift_right = "lsr";
    if (operands.find(shift_left) == std::string::npos && operands.find(shift_right) == std::string::npos) {
        result.append("00000000000");
        return result;
    }

    std::string func = operands.substr(0, operands.find(delimiter));
    operands.erase(0, operands.find(delimiter) + delimiter.length());

    std::string funct = func.find("lsl") != std::string::npos ? "000001" : "000000";
    
    std::string shamnt = toBinary(std::stoi(operands));

    
    result.append(shamnt);
    result.append(funct);
    return result;
}

std::string handleRType(const char *opcode, std::string operands) {
    std::string result(opcode);

    // get register rd
    std::string reg = operands.substr(0, operands.find(delimiter));
    operands.erase(0, operands.find(delimiter) + delimiter.length());

    // remove dollar sign
    reg.erase(0, 1);

    std::string rd = toBinary(std::stoi(reg));

    // get register rs
    reg = operands.substr(0, operands.find(delimiter));
    operands.erase(0, operands.find(delimiter) + delimiter.length());

    // remove dollar sign
    reg.erase(0, 1);

    std::string rs = toBinary(std::stoi(reg));

    // get register rt
    reg = operands.substr(0, operands.find(delimiter));
    operands.erase(0, operands.find(delimiter) + delimiter.length());

    // remove dollar sign
    reg.erase(0, 1);

    std::string rt = toBinary(std::stoi(reg));

    result.append(rs);
    result.append(rt);
    result.append(rd);

    // shifting (optional)
    std::string shift_left = "lsl";
    std::string shift_right = "lsr";
    if (operands.find(shift_left) == std::string::npos && operands.find(shift_right) == std::string::npos) {
        result.append("00000000000");
        return result;
    }

    std::string func = operands.substr(0, operands.find(delimiter));
    operands.erase(0, operands.find(delimiter) + delimiter.length());

    std::string funct = func.find("lsl") != std::string::npos ? "000001" : "000000";
    
    std::string shamnt = toBinary(std::stoi(operands));

    
    result.append(shamnt);
    result.append(funct);
    return result;
}

std::string handleLoadStore(const char *opcode, std::string operands) {
    std::string result(opcode);

    // get register
    std::string reg = operands.substr(0, operands.find(delimiter));
    operands.erase(0, operands.find(delimiter) + delimiter.length());

    // remove dollar sign
    reg.erase(0, 1);

    std::string rt = toBinary(std::stoi(reg));

    // get register 2
    std::string reg2 = operands.substr(0, operands.find(delimiter));

    // remove dollar sign
    reg2.erase(0, 1);

    std::string rs = toBinary(std::stoi(reg2));

    // get imm
    std::string bracket("(");
    std::string rbracket("(");
    std::string imm = operands.substr(operands.find(bracket), operands.find(rbracket));

    // remove bracket
    imm.erase(0, 1);

    std::string immediate = toBinary(std::stoi(imm), 16);

    result.append(rs);
    result.append(rt);
    result.append(immediate);
    return result;
}

int main(int argc, char **argv) {
    if (argc != 3) {
        printf("Usage: %s <input file> <output file>\n", argv[0]);
        return 1;
    }

    char *inputfile = argv[1];
    char *outputfile = argv[2];

    std::ifstream infile(inputfile);
    std::ofstream outfile(outputfile, std::ofstream::out | std::ofstream::trunc);

    int lines = 0;
    for (std::string line; getline(infile, line); ) {
        // find instruction
        std::string token = line.substr(0, line.find(delimiter));
        std::string line_cpy;
        line_cpy.assign(line);

        line.erase(0, line.find(delimiter) + delimiter.length());

        std::string res;
        if (token.compare("lw") == 0) {             // LW   $d i($s)
            res = handleLoadStore(OP_LW, line);
        } else if (token.compare("sw") == 0) {      // SW   $s i($d)
            res = handleLoadStore(OP_SW, line);
        } else if (token.compare("add") == 0) {     // ADD  $d $s $t
            res = handleRType(OP_ADD, line);
        } else if (token.compare("beq") == 0) {     // BEQ  $s $t i
            res = handleIType(OP_BEQ, line);
        } else if (token.compare("disp") == 0) {    // DISP $0 i($d)
            res = handleLoadStore(OP_DISP, line);
        }else if (token.compare("dispr") == 0) {    // DISPR $s
            res = handleDispr(OP_DISPR, line);
        } else if (token.compare("swl") == 0) {     // SWL $d
            res = handleSwitchLoad(OP_SWL, line);
        } else if (token.compare("sub") == 0) {     // SUB  $d $s $t
            res = handleRType(OP_SUB, line);
        } else if (token.compare("and") == 0) {     // AND  $d $s $t
            res = handleRType(OP_AND, line);
        } else if (token.compare("or") == 0) {      // OR   $d $s $t
            res = handleRType(OP_OR, line);
        } else if (token.compare("xor") == 0) {     // XOR  $d $s $t
            res = handleRType(OP_XOR, line);
        } else if (token.compare("slt") == 0) {     // SLT  $d $s $t
            res = handleRType(OP_SLT, line);
        } else if (token.compare("not") == 0) {     // NOT  $d $s
            res = handleNot(OP_NOT, line);
        } else if (token.compare("lui") == 0) {     // LUI  $d i
            res = handleLui(OP_LUI, line);
        } else if (token.compare("ori") == 0) {     // ORI  $d $s i
            res = handleOri(OP_ORI, line);
        } else if (token.compare("hlt") == 0) {     // HLT
            res = "11111100000000000000000000000000";
        } else if (token.compare("#") == 0 || token.compare("") == 0) {
            continue;
        } else {
            printf("Could not find instruction '%s' - options are:\nlw\nsw\nadd\nbeq\ndisp\ndispr\nswl\nsub\nand\nor\nxor\nslt\nnot\nlui\nori\nhlt\n", token.c_str());
            return 2;
        }

        outfile << "var_insn_mem(" << lines++ << ") := \"" << res << "\"; -- " << line_cpy << std::endl;
    }

    infile.close();
    outfile.close();
}