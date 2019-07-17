import
    strutils, unittest, strformat, typetraits, typetraits,
    ../src/lexer/lexer,
    ../src/parser/ast,
    ../src/parser/parser,
    ../src/obj/obj,
    ../src/code/code,
    ../src/compiler/compiler


type CompilerTestCase[T] = ref object of RootObj
    input: string
    expectedConstants: seq[T]
    expectedInstructions: seq[Instructions]


proc testConstants[T](expected: T, actual: seq[Object])
proc testIntegerObject(expected: int, actual: Object)
proc testInstructions(expected: seq[Instructions], actual: Instructions)
proc concatInstructions(s: seq[Instructions]): Instructions
proc parse(input: string): PNode

proc runCompilerTests[T](tests: seq[CompilerTestCase[T]])


# implementation



proc testConstants[T](expected: T, actual: seq[Object]) =
    if len(expected) != len(actual):
        checkpoint(fmt"""
            wrong number of constants.
            got={actual.len}
            want={expected.len}
        """)
        fail()

    # 定数を処理し、コンパイラが生成した定数と比較する
    for i, constant in expected:
        case constant.type.name
        of "int":
            testIntegerObject(int(constant), actual[i])


proc testIntegerObject(expected: int, actual: Object) =
    if actual.kind != Integer:
        checkpoint(fmt"object is not Integer. got={actual.kind}")
        fail()
    if actual.IntValue != expected:
        checkpoint(fmt"object has wrong value. got={actual.IntValue}, want={expected}")
        fail()


proc testInstructions(expected: seq[Instructions], actual: Instructions) =
    let concatted = concatInstructions(expected)
    if len(actual) != len(concatted):
        checkpoint(fmt"""
            wrong instructions length.
            want={concatted}
            got={actual}
        """)
        fail()

    for i, ins in concatted:
        if actual[i] != ins:
            checkpoint(fmt"""
                wrong instructions at {i}.
                want={concatted}
                got={actual}
            """)
            fail()


proc concatInstructions(s: seq[Instructions]): Instructions =
    var o = newSeq[byte]()
    for _, ins in s:
        o.add(ins)
    return o


proc parse(input: string): PNode =
    let
        l = newLexer(input)
        p = newParser(l)
    p.parseProgram()




proc runCompilerTests[T](tests: seq[CompilerTestCase[T]]) =
    for _, test in tests:
        let
            program = parse(test.input) # make an AST
            compiler = newCompiler()
            errCompilr = compiler.compile(program)

        if errCompilr:
            checkpoint(fmt"compiler error")
            fail()

        # バイトコードの正しさのテスト
        let bytecode = compiler.bytecode()
        testInstructions(test.expectedInstructions, bytecode.instructions)
        testConstants(test.expectedConstants, bytecode.constants)



suite "Compiler":
    test "test integer arithmertic":
        let tests = @[
            CompilerTestCase[int](
                input: "1 + 2",
                expectedConstants: @[1,2],
                expectedInstructions: @[
                    makeByte(OpConstant, @[0]),
                    makeByte(OpConstant, @[1]),
                    makeByte(OpAdd),
                ]
            )
        ]
        runCompilerTests(tests)