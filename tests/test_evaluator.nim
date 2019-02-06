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
                Test(input: """10\0""", expected: 10),

                Test(input: """-5\0""", expected: -5),
                Test(input: """-10\0""", expected: -10),

                Test(input: """5 + 5 + 5 + 5 - 10\0""", expected: 10),
                Test(input: """2 * 2 * 2 * 2 * 2\0""", expected: 32),
                Test(input: """-50 + 100 -50\0""", expected: 0),
                Test(input: """5 * 2 + 10\0""", expected: 20),
                Test(input: """5 + 2 * 10\0""", expected: 25),
                Test(input: """20 + 2 * -10\0""", expected: 0),
                Test(input: """50 / 2 * 2 + 10\0""", expected: 60),
                Test(input: """2 * (5 + 10)\0""", expected: 30),
                Test(input: """3 * 3 * 3 + 10\0""", expected: 37),
                Test(input: """3 * (3 * 3) + 10\0""", expected: 37),
                Test(input: """(5 + 10 * 2 + 15 / 3) * 2 + -10\0""", expected: 50)]

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
