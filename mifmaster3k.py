# MIF Master 3000
# Very simple and breakable creator of memory initialization files for
# the processor described by Altera exercise 10.
#
# Assembles instructions into the hex used in the memory's mif
#
import re;
import sys;

global argNum;
global dataWidth;
global dataDepth;
global assemblyFileName;
global memAddr;

#
# convert an integer value to a hex string
#
def toHex(value):
    return str(hex(int(value)))[2:];

#
# makes sure that the given value is no wider than what is specified
#
def checkWidth(value, line):
    if int(value) >= (1<<dataWidth) :
        print("Error!!! Data width of "+str(dataWidth)+" exceeded at line "+str(line)+" with value "+str(int(value)));

#
# display the help for using mm3k
#
def printHelp():
    print("""To use the MIF Master 3000 specify an assembly file (MUST end in .as)
and optionally specify the data width (-dw <int>) and data depth (-dd <int>).
Options:
    -h --help       :   Display this help
    -dw --datawidth :   Specify the width of the instructions in bits
    -dd --datadepth :   Specify the maximum number of memory locations

Provides basic necessities in creating the MIF:
    use symbolic names:
        operations - mv, mvi, add, sub, ld, st, mvnz
        registers - r0, r1, r2, r3, r4, r5, r6, r7 and/or PC

    all instructions except mvi have the format
        INS RX,RY
    where RX and RY are one of the above register names

    mvi has the format
        mvi RX,<data>
    Where <data> can be:
        #hXXXXXXX... with X representing a hex digit
        #dXXXXXXX... with X representing a decimal digit
        #bXXXXXXX... with X representing a binary digit
        $(+/-)N     with $ represents the current PC address and N is an offset
        If no base is specified, decimal is assumed.

        Example of an infinite loop:
        mvi PC,$
""");

#
# Get the address value for the register name
#
def addrForReg(regName):
    if regName == 'r0':
        return '000';
    elif regName == 'r1':
        return '001';
    elif regName == 'r2':
        return '010';
    elif regName == 'r3':
        return '011';
    elif regName == 'r4':
        return '100';
    elif regName == 'r5':
        return '101';
    elif regName == 'r6':
        return '110';
    elif regName == 'r7':
        return '111';
    elif regName == 'pc':
        return '111';
    else :
        raise NameError("Unknown register name "+str(regName));
#
# Gets the address value for the register and catches any exception it may throw
#
def getRegNumSafe(reg, line):
    try:
        return addrForReg(reg);
    except NameError:
        print("Unknown register at line " + str(line));
        quit();

#
# Get the opcode for the instruction name
#
def opcodeForInstr(instruction):
    if instruction == "mv":
        return '000';
    elif instruction == "mvi":
        return '001';
    elif instruction == "add":
        return '010';
    elif instruction == "sub":
        return '011';
    elif instruction == "ld":
        return '100';
    elif instruction == "st":
        return '101';
    elif instruction == "mvnz":
        return '110';
    else:
        raise NameError("Unknown instruction "+str(instruction));

#
# Get the opcode for the instruction name and catch any exception it may throw
#
def getOpcodeSafe(instruction, line):
    try:
        return opcodeForInstr(instruction);
    except NameError:
        print("Unknown opcode at line "+str(line));
        quit();

#
# Get the specified immediate data and make sure it is within the data width bounds
#
def getImmediateData(idata):
    retVal = 0;
    if idata[:2] == "#h":
        retVal = int(idata[2:], 16);
    elif idata[:2] == "#d":
        retVal = int(idata[2:]);
    elif idata[:2] == "#b":
        retVal = int(idata[2:], 2);
    elif idata[0] == "$":
        retVal = memAddr;
        if len(idata) == 2 :
            raise Exception("Bad PC offset");
        elif len(idata) > 2 :
            if idata[1] == "-" or idata[1] == "+" :
                retVal = retVal + int(idata[1:]);
                if retVal < 0 or retVal >= dataDepth :
                   raise Exception("Address out of range");
            else :
                raise Exception("Bad operation on PC relative address");
    else: # assume base 10
        print("Warning, no radix specified. Assuming base 10\n");
        retVal = int(idata[2:]);

    if retVal >= (1<<dataDepth) :
        raise Exception("specified immediate data is too large for width "+str(dataWidth));
    return retVal;

#
# Get the immediate data, catching any exceptions it may throw
#
def getImmediateSafe(idata, line):
    try:
        return getImmediateData(idata);
    except Exception:
        print("Error reading immediate data at line "+str(line));

#
# Main program begins here
#
argNum = 0;
dataWidth = 9;
dataDepth = 32;
assemblyFileName = ""
print("""
MIF Master 3000
Alex Stephens - Oct 8 2013
""");

if len(sys.argv) == 1 :
    printHelp();
    quit();

for arg in sys.argv:
    if re.match('.*\.as', arg) != None :
        assemblyFileName = arg;
    elif re.match('.*\.py', arg) != None:
        argNum = argNum + 1;
        continue;
    elif (re.match('-dw', arg) != None) or (re.match('--datawidth', arg) != None) :
        dataWidth = int(sys.argv[argNum+1]);
    elif (re.match('-dd', arg) != None) or (re.match('--datadepth', arg) != None) :
        dataDepth = int(sys.argv[argNum+1]);
    elif (re.match('-h', arg) is not None) or (re.match('--help', arg) is not None) :
        printHelp();
        quit();
    argNum = argNum + 1;

with open(assemblyFileName, "r") as assemblyFile :
    with open("inst_mem.mif", "w") as mifOut :
        # Create MIF header
        mifOut = open("inst_mem.mif", "w");
        mifOut.write("WIDTH = "+str(dataWidth)+";\n");
        mifOut.write("DEPTH = "+str(dataDepth)+";\n\n");
        mifOut.write("ADDRESS_RADIX = HEX;\n");
        mifOut.write("DATA_RADIX = HEX;\n\n");
        mifOut.write("CONTENT BEGIN\n");

        # Read through the given assembly
        lineNum = 1;
        memAddr = 0;
        for line in assemblyFile :
            valBin = "";
            line = line.lower();
            if re.match('^\s*\'.*$', line) != None :
                lineNum = lineNum + 1;
                continue;
            else :
                if memAddr >= dataDepth:
                    print("Warning!!! Exceeded memory depth! Program ends at line "+str(lineNum-1));
                    break;

                matches = re.match('^([a-z]+)\s+([a-z0-9]+),(\$?#?[a-z0-9\-\+]*)$', line);
                if matches != None:
                    valBin = getOpcodeSafe(matches.group(1), lineNum);
                    valBin = valBin + getRegNumSafe(matches.group(2), lineNum);
                    if(valBin[:3] == '001') :
                        # Put mvi rx,r0, and then read the next value as 9-bit hex
                        valBin = valBin + '000';
                        checkWidth(int(valBin, 2), lineNum);
                        mifOut.write("\t"+toHex(memAddr)+"\t:\t"+toHex(int(valBin, 2))+";\n");
                        valBin = getImmediateSafe(matches.group(3), lineNum);
                        memAddr = memAddr + 1;
                        mifOut.write("\t"+toHex(memAddr)+"\t:\t"+toHex(valBin)+";\n");
                    else :
                        valBin = valBin + getRegNumSafe(matches.group(3), lineNum);
                        checkWidth(int(valBin, 2), lineNum);
                        mifOut.write("\t"+toHex(memAddr)+"\t:\t"+toHex(int(valBin, 2))+";\n");
                else :
                    print("Malformed line ("+str(lineNum)+")\n");
                    quit();
                lineNum = lineNum + 1;
                memAddr = memAddr + 1;

        while memAddr < dataDepth :
            mifOut.write("\t"+toHex(memAddr)+"\t:\t0;\n")
            memAddr = memAddr + 1;
        mifOut.write("END;\n");

print("inst_mem.mif written");
