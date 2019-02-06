import
    unittest,
    ../src/parser/parser,
    ../src/lexer/lexer,
    ../src/obj/obj,
    ../src/evaluator/evaluator

proc testEval(input: string): Object
proc testIntegerObject(obj: Object, expexted: int): bool
proc testBoolObject(obj: Object, expexted: bool): bool

proc testIntegerObject(obj: Object, expexted: int): bool =
    if(obj.kind != Integer): return false
    if(obj.IntValue != expexted): return false
    return true

proc testBoolObject(obj: Object, expexted: bool): bool =
    if(obj.kind != Boolean): return false
    if(obj.BoolValue != expexted): return false
    return true

proc testEval(input: string): Object =
    let
        l = newLexer(input)
        p = newParser(l)
        program = p.parseProgram()

    return eval(program)

suite "REPL":
    test "test IntegerObject":
        type Test = object
            input: string
            expected: int

        let testInput = @[
                Test(input: """5\0""", expected: 5),
                Test(input: """10\0""", expected: 10)]

        for t in testInput:
            let evaluated = testEval(t.input)
            check(testIntegerObject(evaluated, t.expected))


    test "test BooleanObject":
        type Test = object
            input: string
            expected: bool

        let testInput = @[
                Test(input: """true\0""", expected: true),
                Test(input: """false\0""", expected: false)]

        for t in testInput:
            let evaluated = testEval(t.input)
            check(testBoolObject(evaluated, t.expected))

    test "test BangOperator":
        type Test = object
            input: string
            expected: bool

        let testInput = @[
                Test(input: """!true\0""", expected: false),
                Test(input: """!false\0""", expected: true),
                Test(input: """!5\0""", expected: false),
                Test(input: """!!true\0""", expected: true),
                Test(input: """!!false\0""", expected: false),
                Test(input: """!!5\0""", expected: true)]

        for t in testInput:
            let evaluated = testEval(t.input)
            check(testBoolObject(evaluated, t.expected))
