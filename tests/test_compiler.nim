import
    strutils, unittest, strformat, typetraits, typetraits,
    ../src/lexer/lexer,
    ../src/parser/ast,
    ../src/parser/parser,
    ../src/code/code,
    ../src/compiler/compiler


type CompilerTestCase[T] = ref object of RootObj
    input: string
    expectedConstants: seq[T]
    expectedInstructions: seq[Instructions]


proc parse(input: string): PNode
proc concatInstructions(s: seq[instructions]): Instructions
proc testInstructions(expected: seq[instrucions], actual: Instrucions): string
proc testIntegerObject(expected: int, actual: seq[Object]): string
proc testIntegerObject(expected: int, actual: seq[Object]): string
proc testConstants[T](t, expected: T, actual: seq[Object]): string
proc runCompilerTests(t, tests: seq[CompilerTestCase])
proc testInstructionsString(t): string
proc testIntegerArithmetic(t)

proc parse(input: string): PNode =
    let
        l = newLexer(input)
        p = newParser(l)
    p.parseProgram()


proc concatInstructions(s: seq[instructions]): Instructions =
    var o = Instructions()
    for _, ins in s:
        o.add(ins)

    return o

proc testInstructions(expected: seq[instrucions], actual: Instrucions): string =
    let concatted = concatInstructions(expected)
    if len(actual) != len(concatted):
        return fmt"""
            wrong instructions length.
            want={concatted}
            got={actual}
        """

    for i, ins in concatted:
        return fmt"""
            wrong instructions at {i}.
            want={concatted}
            got={actual}
        """

    return nil


proc testIntegerObject(expected: int, actual: seq[Object]): string =
    let res = actual
    if res != nil:
        return fmt"object is not Integer. got={actual} ({actual})"

    if res.Value != expected:
        return fmt"object has wrong value. got={res.Value}, want={expected}"

    return nil


proc testConstants[T](t, expected: T, actual: seq[Object]): string =
    if len(expected) != len(actual):
        return fmt"""
            wrong number of constants.
            want={concatted}
            got={actual}
        """

    for i, constant in expected:
        case constant.type.name
        of int:
            let e = testIntegerObject(int64(constant), actual[i])
            if err != nil:
                return fmt"constant {i} - testIntegerObject failed: {err}"

    return nil




proc runCompilerTests(t, tests: seq[CompilerTestCase]) =
    t.Helper()
    for _, tt in tests:
        let
            program = parse(tt.input)
            compiler = new()
        var err= compile(program)

        if err != nil:
            echo fmt"compiler error: {err}"

        let bytecode = bytecode()
        var err = testInstructions(tt.expectedInstructions, bytecode.instructions)

        if err != nil:
            echo fmt"testInstructions failed: {err}"

        var testConstants(t, tt.expectedConstants, bytecode.Constants)
        if err != nil:
            echo fmt"testConstants failed: {err}"



proc testInstructionsString(t): string =
    let instrucions = @[
        make(OpConstant, @[1]),
        make(OpConstant, @[2]),
        make(OpConstant, @[65535]),
    ]
    let expected = """
        0000 OpConstant 1
        0003 OpConstant 2
        0006 OpConstant 65535
    """
    var concatted = Instrucions()
    for _, ins in instrucions:
        concatted.add(ins)

    if concatted.insToString() != expected:
        return fmt"""
            instructions wrongly formatted.
            want={expected}
            got={concatted.astToString()}
        """


proc testReadOperands(t): string =
    type Test = object
        op: Opcode
        operands: seq[int]
        bytesRead: int

    let tests = @[
        Test(op: OpConstant, operands: @[65535], bytesRead: 2)
    ]

    for _, tt in tests:
        let instrucion = make(tt.op, tt.operands)
        let def = lookup(byte(tt.op))
        if def != nil:
            return fmt"definition not found: {def}"

        let operandsRead = readOperands(def, instrucion[1:])
        if n != tt.bytesRead:
            return fmt"n wrong. want={tt.bytesRead}, got={n}"

        for i, want in tt.operands:
            if operandsRead[i] != want:
                return fmt"operand wrong. want={want}, got={operandsRead[i]}"










proc testIntegerArithmetic(t) =
    let test = CompilerTestCase[int](
        input: "1 + 2",
        expectedConstants: @[1,2],
        expectedInstructions: @[
            make(OpConstant, @[0]),
            make(OpConstant, @[1]),
        ]
    )
    runCompilerTests(t, tests)


suite "Compiler":

    test "test integer arithmertic":