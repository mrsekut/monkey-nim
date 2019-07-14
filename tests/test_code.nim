import
    strutils, unittest, strformat, typetraits,
    ../src/code/code


suite "Code":

    test "test make proc":
        type Test = object
            op: Opcode
            operands: seq[int]
            expected: seq[byte]

        let testInputs = @[
            # expectedの１つ目はopcode,2つめは
            Test(op: OpConstant, operands: @[65534], expected: @[byte(OpConstant), 255, 254 ]),
        ]

        for t in testInputs:
            let instruction = make(t.op, t.operands)
            if instruction.len != t.expected.len:
                echo fmt"instruction has wrong length. want={t.expected.len}, got={instruction.len}"
            for i, b in t.expected:
                if instruction[i] != t.expected[i]:
                    echo fmt"wrong byte at pos {i}. want={b}, got={instruction[i]}"