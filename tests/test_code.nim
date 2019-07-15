import
    strutils, unittest, strformat, typetraits,
    ../src/code/code


suite "Code":
    test "test makeByte proc":
        type Test = object
            op: Opcode
            operands: seq[int]
            expected: seq[byte]

        let testInputs = @[
            Test(op: OpConstant, operands: @[65534], expected: @[byte(OpConstant), 255, 254 ]),
        ]

        for t in testInputs:
            let instruction = makeByte(t.op, t.operands)
            if instruction.len != t.expected.len:
                echo fmt"instruction has wrong length. want={t.expected.len}, got={instruction.len}"
            for i, b in t.expected:
                if instruction[i] != t.expected[i]:
                    echo fmt"wrong byte at pos {i}. want={b}, got={instruction[i]}"


    test "test InstructionsString":
        let
            instrucions = @[
                makeByte(OpConstant, @[1]),
                makeByte(OpConstant, @[2]),
                makeByte(OpConstant, @[65535]),
            ]
            expected = &"0000 OpConstant 1\n" &
                       &"0003 OpConstant 2\n" &
                       &"0006 OpConstant 65535\n"

        var concatted: seq[byte]
        for _, ins in instrucions:
            concatted.add(ins)

        if concatted.insToString() != expected:
            checkpoint(fmt"""
                instructions wrongly formatted.
                want= {expected}
                got= {concatted.insToString()}
            """)
            fail()


    # test "test readOperands":
    #     type Test = object
    #         op: Opcode
    #         operands: seq[int]
    #         bytesRead: int

    #     let tests = @[
    #         Test(op: OpConstant, operands: @[65535], bytesRead: 2)
    #     ]

    #     for _, test in tests:
    #         let
    #             instrucion = makeByte(test.op, test.operands)
    #             def = lookup(byte(test.op))

    #         if def != nil:
    #             checkpoint(fmt"definition not found")
    #             fail()

    #         let (operandsRead, n ) = readOperands(def, instrucion[1..^1])
    #         if n != test.bytesRead:
    #             checkpoint(fmt"n wrong. want={test.bytesRead}, got={n}")
    #             fail()

    #         for i, want in test.operands:
    #             if operandsRead[i] != want:
    #                 checkpoint(fmt"operand wrong. want={want}, got={operandsRead[i]}")
    #                 fail()