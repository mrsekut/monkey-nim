import
    unittest,
    ../src/parser/parser,
    ../src/lexer/lexer,
    ../src/obj/obj,
    ../src/evaluator/evaluator

proc testEvalIntegerExpression()
proc testEval(input: string): Object
proc testIntegerObject(obj: Object, expexted: int): bool

proc testIntegerObject(obj: Object, expexted: int): bool =
    if(obj.kind != Integer): return false
    if(obj.IntValue != expexted): return false
    return true

proc testEvalIntegerExpression() =
    type Test = object
        input: string
        expected: int

    let testInput = @[
            Test(input: """5\0""", expected: 5),
            Test(input: """10\0""", expected: 10)]

    for t in testInput:
        let evaluated = testEval(t.input)
        check(testIntegerObject(evaluated, t.expected))

proc testEval(input: string): Object =
    let
        l = newLexer(input)
        p = newParser(l)
        program = p.parseProgram()

    return eval(program)

suite "REPL":
    test "test IntegerObject":
        testEvalIntegerExpression()