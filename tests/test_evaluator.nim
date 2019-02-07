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

proc testNullObject(obj: Object): bool =
    if(obj.kind != TNull): return false
    return true

proc testEval(input: string): Object =
    let
        l = newLexer(input)
        p = newParser(l)
        program = p.parseProgram()

    return eval(program)

suite "REPL":
    test "test eval IntegerObject":
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


    test "test eval BooleanExpression":
        type Test = object
            input: string
            expected: bool

        let testInput = @[
                Test(input: """true\0""", expected: true),
                Test(input: """false\0""", expected: false),

                Test(input: """1 < 2\0""", expected: true),
                Test(input: """1 > 2\0""", expected: false),
                Test(input: """1 < 1\0""", expected: false),
                Test(input: """1 > 1\0""", expected: false),
                Test(input: """1 == 1\0""", expected: true),
                Test(input: """1 != 1\0""", expected: false),
                Test(input: """1 == 2\0""", expected: false),
                Test(input: """1 != 2\0""", expected: true),

                Test(input: """true == true\0""", expected: true),
                Test(input: """false == false\0""", expected: true),
                Test(input: """true == false\0""", expected: false),
                Test(input: """true != false\0""", expected: true),
                Test(input: """false != true\0""", expected: true),

                Test(input: """(1 < 2) == true\0""", expected: true),
                Test(input: """(1 < 2) == false\0""", expected: false),
                Test(input: """(1 > 2) == true\0""", expected: false),
                Test(input: """(1 > 2) == false\0""", expected: true)]

        for t in testInput:
            let evaluated = testEval(t.input)
            check(testBoolObject(evaluated, t.expected))

    test "test eval BangOperator":
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


    test "test eval ifElseExpression":
        type Test = object
            input: string
            expected: int

        let testInput = @[
                Test(input: """if (true) { 10 }\0""", expected: 10),
                Test(input: """if (1) { 10 }\0""", expected: 10),
                Test(input: """if (1 < 2) { 10 }\0""", expected: 10),
                Test(input: """if (1 > 2) { 10 } else { 20 }\0""", expected: 20),
                Test(input: """if (1 < 2) { 10 } else { 20 }\0""", expected: 10)]

        for t in testInput:
            let evaluated = testEval(t.input)
            check(testIntegerObject(evaluated, t.expected))

        type TestNull = object
            input: string
            expected: string

        let testInputNull = @[
                TestNull(input: """if (false) { 10 }\0""", expected: "null"),
                TestNull(input: """if (1 > 2) { 10 }\0""", expected: "null")]

        for t in testInputNull:
            let evaluated = testEval(t.input)
            check(testNullObject(evaluated))
