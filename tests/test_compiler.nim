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


# proc testConstants[T](expected: T, actual: seq[Object]): string
# proc testIntegerObject(expected: int, actual: seq[Object]): string
proc testInstructions(expected: seq[Instructions], actual: Instructions)
proc concatInstructions(s: seq[Instructions]): Instructions
proc parse(input: string): PNode

proc runCompilerTests[T](tests: seq[CompilerTestCase[T]])


# implementation



# proc testConstants[T](expected: T, actual: seq[Object]): string =
#     if len(expected) != len(actual):
#         return fmt"""
#             wrong number of constants.
#             want={concatted}
#             got={actual}
#         """

#     # 定数を処理し、コンパイラが生成した定数と比較する
#     for i, constant in expected:
#         case constant.type.name
#         of int:
#             let e = testIntegerObject(int64(constant), actual[i])
#             # if err != nil:
#             #     return fmt"constant {i} - testIntegerObject failed: {err}"

#     return nil


# proc testIntegerObject(expected: int, actual: seq[Object]): string =
#     let res = actual
    # if res != nil:
    #     return fmt"object is not Integer. got={actual} ({actual})"

    # if res.Value != expected:
    #     return fmt"object has wrong value. got={res.Value}, want={expected}"

    # return nil


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
            program = parse(test.input) # ASTを作成
            compiler = newCompiler()
            errCompilr = compiler.compile(program)

        if errCompilr:
            echo fmt"compiler error"
            # echo fmt"compiler error: {err}"

        # バイトコードの正しさのテスト
        let bytecode = compiler.bytecode()
        echo bytecode.instructions
        testInstructions(test.expectedInstructions, bytecode.instructions)

        # var errCons = testConstants(test.expectedConstants, bytecode.Constants)
        # if errCons:
        #     checkpoint(fmt"testConstants failed: {err}")
        #     fail()



suite "Compiler":
    test "test integer arithmertic":
        let tests = @[
            CompilerTestCase[int](
                input: "1 + 2",
                expectedConstants: @[1,2],
                expectedInstructions: @[
                    makeByte(OpConstant, @[0]),
                    makeByte(OpConstant, @[1]),
                ]
            )
        ]
        runCompilerTests(tests)