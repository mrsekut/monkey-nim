import
    unittest,
    ../src/parser/parser,
    ../src/lexer/lexer,
    ../src/parser/ast,
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
        env = newEnvironment()

    return eval(program, env)




suite "REPL":
    test "test eval IntegerObject":
        type Test = object
            input: string
            expected: int

        let testInput = @[
                Test(input: "5", expected: 5),
                Test(input: "10", expected: 10),
                Test(input: "-5", expected: -5),
                Test(input: "-10", expected: -10),

                Test(input: "5 + 5 + 5 + 5 - 10", expected: 10),
                Test(input: "2 * 2 * 2 * 2 * 2", expected: 32),
                Test(input: "-50 + 100 -50", expected: 0),
                Test(input: "5 * 2 + 10", expected: 20),
                Test(input: "5 + 2 * 10", expected: 25),
                Test(input: "20 + 2 * -10", expected: 0),
                Test(input: "50 / 2 * 2 + 10", expected: 60),
                Test(input: "2 * (5 + 10)", expected: 30),
                Test(input: "3 * 3 * 3 + 10", expected: 37),
                Test(input: "3 * (3 * 3) + 10", expected: 37),
                Test(input: "(5 + 10 * 2 + 15 / 3) * 2 + -10", expected: 50)
        ]

        for t in testInput:
            let evaluated = testEval(t.input)
            check(testIntegerObject(evaluated, t.expected))


    test "test eval BooleanExpression":
        type Test = object
            input: string
            expected: bool

        let testInput = @[
                Test(input: "true", expected: true),
                Test(input: "false", expected: false),

                Test(input: "1 < 2", expected: true),
                Test(input: "1 > 2", expected: false),
                Test(input: "1 < 1", expected: false),
                Test(input: "1 > 1", expected: false),
                Test(input: "1 == 1", expected: true),
                Test(input: "1 != 1", expected: false),
                Test(input: "1 == 2", expected: false),
                Test(input: "1 != 2", expected: true),

    #             Test(input: """true == true""", expected: true),
    #             Test(input: """false == false""", expected: true),
    #             Test(input: """true == false""", expected: false),
    #             Test(input: """true != false""", expected: true),
    #             Test(input: """false != true""", expected: true),

    #             Test(input: """(1 < 2) == true""", expected: true),
    #             Test(input: """(1 < 2) == false""", expected: false),
    #             Test(input: """(1 > 2) == true""", expected: false),
    #             Test(input: """(1 > 2) == false""", expected: true)]
        ]

        for t in testInput:
            let evaluated = testEval(t.input)
            check(testBoolObject(evaluated, t.expected))


    test "test eval BangOperator":
        type Test = object
            input: string
            expected: bool

        let testInput = @[
                Test(input: "!true", expected: false),
                Test(input: "!false", expected: true),
                Test(input: "!5", expected: false),

                Test(input: "!!true", expected: true),
                Test(input: "!!false", expected: false),
                Test(input: "!!5", expected: true)
        ]

        for t in testInput:
            let evaluated = testEval(t.input)
            check(testBoolObject(evaluated, t.expected))


    test "test eval ifElseExpression":
        type Test = object
            input: string
            expected: int

        let testInput = @[
                Test(input: "if (true) { 10 }", expected: 10),
                Test(input: "if (1) { 10 }", expected: 10),
                Test(input: "if (1 < 2) { 10 }", expected: 10),
                Test(input: "if (1 > 2) { 10 } else { 20 }", expected: 20),
                Test(input: "if (1 < 2) { 10 } else { 20 }", expected: 10)]

        for t in testInput:
            let evaluated = testEval(t.input)
            check(testIntegerObject(evaluated, t.expected))

        type TestNull = object
            input: string
            expected: string

        let testInputNull = @[
                TestNull(input: "if (false) { 10 }", expected: "null"),
                TestNull(input: "if (1 > 2) { 10 }", expected: "null")]

        for t in testInputNull:
            let evaluated = testEval(t.input)
            check(testNullObject(evaluated))


    test "test eval returnStatements":
        type Test = object
            input: string
            expected: int

        let testInput = @[
                Test(input: "return 10", expected: 10),
                Test(input: "return 10; 9;", expected: 10),
                Test(input: "return 2 * 5; 9;", expected: 10),
                Test(input: "9; return 2 * 5; 9;", expected: 10),
                Test(input: """
                    if (10 > 1) {
                        if(10 > 1) {
                            return 10;
                        }
                        return 1;
                    }""", expected: 10),
        ]

        for t in testInput:
            let evaluated = testEval(t.input)
            check(testIntegerObject(evaluated, t.expected))


    # test "test error handling":
    #     type Test = object
    #         input: string
    #         expected: string

    #     let testInput = @[
    #             Test(input: """5 + true;""",
    #                  expected: "type mismatch: INTEGER + BOOLEAN"),
    #             Test(input: """5 + true; 5;""",
    #                  expected: "type mismatch: INTEGER + BOOLEAN"),
    #             Test(input: """-true;""",
    #                  expected: "unknown operator: -BOOLEAN"),
    #             Test(input: """true + false;""",
    #                  expected: "unknown operator: BOOLEAN + BOOLEAN"),
    #             Test(input: """5; true + false; 5;""",
    #                  expected: "unknown operator: BOOLEAN + BOOLEAN"),
    #             Test(input: """if (10 > 1) { true + false; }""",
    #                  expected: "unknown operator: BOOLEAN + BOOLEAN"),
    #             Test(input: """
    #                     if (10 > 1) {
    #                         if(10 > 1) {
    #                             return true + false;
    #                         }
    #                         return 1;
    #                     }
    #                 """,
    #                  expected: "unknown operator: BOOLEAN + BOOLEAN"),
    #             # Test(input: """foobar;""",
    #             #      expected: "identifier not found; foobar"),
    #             ]

    #     for t in testInput:
    #         let evaluated = testEval(t.input)
    #         check(evaluated.ErrMessage == t.expected)

    # test "test letStatements":
    #     type Test = object
    #         input: string
    #         expected: int

    #     let testInput = @[
    #             Test(input: """let a = 5; a;""", expected: 5),
    #             Test(input: """let a = 5 * 5; 25;""", expected: 25),
    #             Test(input: """let a = 5; let b = a; b;""", expected: 5),
    #             Test(input: """let a = 5; let b = a; let c = a + b + 5; c;""", expected: 15),
    #         ]

    #     for t in testInput:
    #         let evaluated = testEval(t.input)
    #         check(evaluated.IntValue == t.expected)

    # test "test functionObject":
    #     let
    #         input = """fn(x) {x + 2};"""
    #         evaluated = testEval(input)

    #     check(evaluated.Parameters.len == 1)
    #     check(evaluated.Parameters[0].Token.Literal == "x")
    #     check(evaluated.Body.astToString() == "(x + 2)")

    # test "test functionApplication":
    #     type Test = object
    #         input: string
    #         expected: int

    #     let testInput = @[
    #             Test(input: """let identity = fn(x) { x; }; identity(5);""", expected: 5),
    #             Test(input: """let identity = fn(x) { return x; }; identity(5);""", expected: 5),
    #             Test(input: """let double = fn(x) {x * 2;}; double(5);""", expected: 10),
    #             Test(input: """let add = fn(x, y) {x + y;}; add(5, 6);""", expected: 11),
    #             Test(input: """let add = fn(x, y) {x + y;}; add(5 + 6, add(5, 6));""", expected: 22),
    #             Test(input: """fn(x) {x;}(5)""", expected: 5),
    #             # Test(input: """let add = fn(x, y) {let o = x + y; return 42;}; add(5+6, 6);""", expected: 42), // FIXME:
    #         ]

    #     for t in testInput:
    #         let evaluated = testEval(t.input)
    #         check(evaluated.IntValue == t.expected)