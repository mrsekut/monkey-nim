import
    strformat, tables, strutils

type
    Instructions* = seq[byte]
    Opcode* = byte


# これらに振られる数値は各々ユニークであれば何でも良い
const
    OpConstant*: OpCode = 0

type Definition = ref object of RootObj
    Name: string
    OperandWidths: seq[int]


var definitions = {
    OpConstant: Definition(Name: "OpConstant", OperandWidths: @[2])
}.newTable


proc lookup*(op: byte): Definition =
    try:
        var def = definitions[Opcode(op)]
        return def
    except :
        errorMessageWriter(fmt"opcode {op} undefined")


proc putBigEndian16(arr: var seq[byte], index: int, operand :int64) =
    if arr.len != index: arr.add(byte(0)) # FIXME:

    let hex: string = toHex(operand, 4) # FFFE
    for i in countup(0, len(hex)-1, 2):
        var bc = hex[i..i+1] # FF
        var c = fromHex[byte](bc) # 255
        arr.add(c)


proc make*(op: OpCode, operands: seq[int]): seq[byte] =
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
                instruction.putBigEndian16(offset, int64(operand))
            offset += width

        return instruction
    except :
        errorMessageWriter(fmt"opcode {op} undefined")




proc main() = discard
    # echo make(OpConstant, @[65534])
when isMainModule:
    main()

