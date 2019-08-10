import
    strformat, tables, strutils

type
    Instructions* = seq[byte]
    Opcode* = byte


# これらに振られる数値は各々ユニークであれば何でも良い
const
    OpConstant*: OpCode = 0
    OpAdd*: OpCode = 1
    OpPop*: OpCode = 2

type Definition = ref object of RootObj
    Name: string
    OperandWidths: seq[int]


var definitions = {
    OpConstant: Definition(Name: "OpConstant", OperandWidths: @[2]),
    OpAdd: Definition(Name: "OpAdd", OperandWidths: @[]),
    OpPop: Definition(Name: "OnPop", OperandWidths: @[]),
}.newTable


proc lookup*(op: byte): Definition
proc putBigEndian16(arr: var seq[byte], index: int, operand: uint16)
proc makeByte*(op: OpCode, operands: seq[int] = @[]): seq[byte]
proc insToString*(ins: Instructions): string
proc readUint16*(ins: Instructions): uint16
proc readOperands*(def: Definition, ins: Instructions): (seq[int], int)
proc fmtInstructions(self: Instructions, def: Definition, operands: seq[int]): string

# implementation

proc lookup*(op: byte): Definition =
    try:
        var def = definitions[Opcode(op)]
        return def
    except :
        errorMessageWriter(fmt"opcode {op} undefined")


proc putBigEndian16(arr: var seq[byte], index: int, operand: uint16) =
    if arr.len != index: arr.add(byte(0)) # FIXME:

    let hex: string = toHex(int(operand), 4) # FFFE
    for i in countup(0, len(hex)-1, 2):
        var bc = hex[i..i+1] # FF
        var c = fromHex[byte](bc) # 255
        arr.add(c)


# opcodeとoperandを引数にとり、その全体をバイトコード化したものの配列を返す
proc makeByte*(op: OpCode, operands: seq[int] = @[]): seq[byte] =
    try:
        let def = definitions[op]
        var instructionLen = 1

        for i, w in def.OperandWidths:
            instructionLen += w

        var instruction = newSeq[byte]()
        instruction.add(byte(op))
        var offset = 1

        for i, operand in operands:
            let width = def.OperandWidths[i]
            if width == 2:
                instruction.putBigEndian16(offset, uint16(operand))
            offset += width

        return instruction
    except :
        errorMessageWriter(fmt"opcode {op} undefined")


proc insToString*(ins: Instructions): string =
    result = ""
    var
       i = 0
       def: Definition
    while i < len(ins):
        def = lookup(ins[i])
        # if def != nil:
        #     echo fmt"Error"
        #     continue

        let (operands, read) = readOperands(def, ins[i+1..^1])
        result &= &"{i:04} {ins.fmtInstructions(def, operands)}\n"

        i += 1 + read


proc fmtInstructions(self: Instructions, def: Definition, operands: seq[int]): string =
    let operandCount = len(def.OperandWidths)

    if len(operands) != operandCount:
        return fmt"ERROR: operand len {len(operands)} does not match defined {operandCount}"

    case operandCount:
    of 0:
        return def.Name
    of 1:
        return fmt"{def.Name} {operands[0]}"
    else:
        discard

    return fmt"ERROR: unhandled operandCount for {def.Name}"



# バイナリの配列を引数にとって、uint16を返す
proc readUint16*(ins: Instructions): uint16 =
    let s = toHex(ins[0]) & toHex(ins[1])
    return fromHex[uint16](s)


proc readOperands*(def: Definition, ins: Instructions): (seq[int], int) =
    var
        # operands: array[0..def.OperandWidths.len, int]
        operands = newSeq[int]()
        offset = 0

    for i, width in def.OperandWidths:
        if width == 2:
            operands.add(int(readUint16(ins[offset..^1]))) # FIXME:
        offset += width

    return (operands, offset)





proc main() = discard
when isMainModule:
    main()

