import
    strutils, unittest, strformat, typetraits,
    ../src/parser/ast,
    ../src/parser/parser,
    ../src/lexer/lexer

proc checkParserError(self: Parser): void =
    let errors = self.error()
    if errors.len == 0: return
    echo fmt"parser has {errors.len} errors"

# # TODO: テストヘルパー関数の定義と利用
# proc testIntegerLiteral(exp: PNode, value: int): bool =
#     if(exp.kind != nkIntegerLiteral): return false

#     let integer = exp.IntValue
#     if(integer != value): return false
#     if(exp.Token.Literal != $value): return false
#     return true

# proc testIdentifier(exp: PNode, value: string): bool =
#     if(exp.kind != nkIdent): return false

#     let ident = exp.IdentValue
#     if(ident != value): return false
#     if(exp.Token.Literal != value): return false
#     return true

# proc testBooleanLiteral(exp: PNode, value: bool): bool =
#     if(exp.kind != nkBoolean): return false

#     let boolean = exp.BlValue
#     if(boolean != value): return false
#     if(exp.Token.Literal != $value): return false

# proc testLiteralExpression(exp: PNode, expected: auto): bool =
#     let v = expected.type.name
#     case v
#     of "int": return testIntegerLiteral(exp, expected.parseInt)
#     of "string": return testIdentifier(exp, expected)
#     else: return false




suite "Parser":
    test "it should parse letStatements":
        let input = """
            let x = 5;
            let y = 10;
            let foobar = 838383;\0
        """

        let l = newLexer(input)
        let p = newParser(l)

        let program = p.parseProgram()
        checkParserError(p)
        check(program.statements.len == 3)

        let expects = @["x", "y", "foobar"]

        for i in 0..<program.statements.len:
            let statement = program.statements[i]
            check(statement.LetName.IdentValue == expects[i])


    test "it should parse returnStatements":
        let input = """
            return 5;
            return 10;
            return 838383;\0
        """

        let l = newLexer(input)
        let p = newParser(l)

        let program = p.parseProgram()
        checkParserError(p)
        check(program.statements.len == 3)

        for i in 0..<program.statements.len:
            let statement = program.statements[i].Token.Literal
            check(statement == "return")

    test "it should parse ident expression":
        let input = """foobar;\0"""

        let l = newLexer(input)
        let p = newParser(l)
        let program = p.parseProgram()
        checkParserError(p)
        # check(program.statements.len == 1)

        let statement = program.statements[0]

        let value = statement.IdentValue
        check(value == "foobar")
        let literal = statement.Token.Literal
        check(literal == "foobar")

    test "it should parse int expression":
        let input = """5;\0"""

        let l = newLexer(input)
        let p = newParser(l)
        let program = p.parseProgram()
        checkParserError(p)
        # check(program.statements.len == 1)

        let statement = program.statements[0]
        # check(statement.kind == ExpressionStatement)

        let value = statement.IntValue
        check(value == 5)
        let literal = statement.Token.Literal
        check(literal == "5")

    test "it should parse boolean expression":
        let input = """true;\0"""

        let l = newLexer(input)
        let p = newParser(l)
        let program = p.parseProgram()
        checkParserError(p)
        # check(program.statements.len == 1)

        let statement = program.statements[0]
        # check(statement.kind == ExpressionStatement)

        let value = statement.BlValue
        check(value == true)
        let literal = statement.Token.Literal
        check(literal == "true")


    # test "it should parse prefixExpressions":

    #     type Test = object
    #         input: string
    #         operator: string
    #         integerValue: int

    #     let testInputs = @[
    #         Test(input: """!5\0""", operator: "!", integerValue: 5),
    #         Test(input: """-15\0""", operator: "-", integerValue: 15)
    #     ]

    #     for i in testInputs:
    #         let l = newLexer(i.input)
    #         let p = newParser(l)
    #         let program = p.parseProgram()
    #         checkParserError(p)

    #         # check(program.statements.len == 1)

    #         let exp = program.statements[0]
    #         check(exp.PrOperator == i.operator)
    #         check(testIntegerLiteral(exp.PrRight.IntValue, i.integerValue))

    # test "it should parse infixExpressions":

    #     type Test = object
    #         input: string
    #         leftValue: int
    #         operator: string
    #         rightValue: int

    #     let testInputs = @[
    #         Test(input: """5 + 5\0""", leftValue: 5, operator: "+", rightValue: 5),
    #         Test(input: """5 - 5\0""", leftValue: 5, operator: "-", rightValue: 5),
    #         Test(input: """5 * 5\0""", leftValue: 5, operator: "*", rightValue: 5),
    #         Test(input: """5 / 5\0""", leftValue: 5, operator: "/", rightValue: 5),
    #         Test(input: """5 > 5\0""", leftValue: 5, operator: ">", rightValue: 5),
    #         Test(input: """5 < 5\0""", leftValue: 5, operator: "<", rightValue: 5),
    #         Test(input: """5 == 5\0""", leftValue: 5, operator: "==", rightValue: 5),
    #         Test(input: """5 != 5\0""", leftValue: 5, operator: "!=", rightValue: 5)
    #     ]

    #     for i in testInputs:
    #         let l = newLexer(i.input)
    #         let p = newParser(l)
    #         let program = p.parseProgram()
    #         checkParserError(p)

    #         check(program.statements.len == 1)

    #         let exp = program.statements[0]
    #         check(testIntegerLiteral(exp.InLeft, i.leftValue))
    #         check(exp.InOperator == i.operator)
    #         check(testIntegerLiteral(exp.InRight, i.rightValue))

    test "test operator precedenve parsing":

        type Test = object
            input: string
            expected: string

        let testInputs = @[
            Test(input: """-a * b\0""", expected: "((-a) * b)"),
            Test(input: """!-a\0""", expected: "(!(-a))"),
            Test(input: """a + b + c\0""", expected: "((a + b) + c)"),
            Test(input: """a * b / c\0""", expected: "((a * b) / c)"),
            Test(input: """a + b * c + d / e - f\0""", expected: "(((a + (b * c)) + (d / e)) - f)"),
            Test(input: """3 + 4; -5 * 5\0""", expected: "(3 + 4)((-5) * 5)"),
            Test(input: """5 > 4 == 3 < 4\0""", expected: "((5 > 4) == (3 < 4))"),
            Test(input: """5 < 4 != 3 > 4\0""", expected: "((5 < 4) != (3 > 4))"),
            Test(input: """3 + 4 * 5 == 3 * 1 + 4 * 5\0""", expected: "((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))"),
        ]


        for i in testInputs:
            let l = newLexer(i.input)
            let p = newParser(l)
            let program = p.parseProgram()
            checkParserError(p)

            let act = program.astToString()
            check(act == i.expected)

    test "test operator precedence parsing":

        type Test = object
            input: string
            expected: string

        let testInputs = @[
            Test(input: """true\0""", expected: "true"),
            Test(input: """false\0""", expected: "false"),
            Test(input: """3 < 5 == false\0""", expected: "((3 < 5) == false)"),
            Test(input: """3 < 5 == true\0""", expected: "((3 < 5) == true)"),

            Test(input: """true == true\0""", expected: "(true == true)"),
            Test(input: """true != false\0""", expected: "(true != false)"),
            Test(input: """false == false\0""", expected: "(false == false)"),

            Test(input: """!true;\0""", expected: "(!true)"),
            Test(input: """!false;\0""", expected: "(!false)"),

            Test(input: """1 + (2 + 3) + 4\0""", expected: "((1 + (2 + 3)) + 4)"),
            Test(input: """(5 + 5) * 2\0""", expected: "((5 + 5) * 2)"),
            Test(input: """2 / (5 + 5);\0""", expected: "(2 / (5 + 5))"),
            Test(input: """-(5 + 5);\0""", expected: "(-(5 + 5))"),
            Test(input: """!(true == true);\0""", expected: "(!(true == true))"),
        ]

        for i in testInputs:
            let l = newLexer(i.input)
            let p = newParser(l)
            let program = p.parseProgram()
            checkParserError(p)

            let act = program.astToString()
            check(act == i.expected)


    test "test if expression":
        let input = """if (x < y){ x }\0"""

        let l = newLexer(input)
        let p = newParser(l)
        let program = p.parseProgram()
        checkParserError(p)
        check(program.statements.len == 1)

        let act = program.statements[0]
        check(act.kind == nkIFExpression)

        let condition = act.Condition
        check(condition.InLeft.Token.Literal == "x")
        check(condition.InOperator == "<")
        check(condition.InRight.Token.Literal == "y")

        let consequence = act.Consequence
        check(consequence.Statements.len == 1)
        check(consequence.Statements[0].Token.Literal == "x")

    test "test if-else expression":
        let input = """if (x < y){ x } else { y }\0"""

        let l = newLexer(input)
        let p = newParser(l)
        let program = p.parseProgram()
        checkParserError(p)
        check(program.statements.len == 1)

        let act = program.statements[0]
        check(act.kind == nkIFExpression)

        let condition = act.Condition
        check(condition.InLeft.Token.Literal == "x")
        check(condition.InOperator == "<")
        check(condition.InRight.Token.Literal == "y")

        let consequence = act.Consequence
        check(consequence.Statements.len == 1)
        check(consequence.Statements[0].Token.Literal == "x")

        let alternative = act.Alternative
        check(alternative.Statements.len == 1)
        check(alternative.Statements[0].Token.Literal == "y")

    test "test functionLiteral parsing":
        let input = """fn(x, y) { x + y }\0"""

        let l = newLexer(input)
        let p = newParser(l)
        let program = p.parseProgram()
        checkParserError(p)
        check(program.statements.len == 1)

        let act = program.statements[0]
        check(act.kind == nkFunctionLiteral)

        let params = act.FnParameters
        check(params.len == 2)
        check(params[0].Token.Literal == "x")
        check(params[1].Token.Literal == "y")

        let body = act.FnBody.Statements
        check(body.len == 1)
        check(body[0].InLeft.Token.Literal == "x")
        check(body[0].InOperator == "+")
        check(body[0].InRight.Token.Literal == "y")

    test "test functionParameter parging":
        type Test = object
            input: string
            expected: seq[string]

        let testInputs = @[
            Test(input: """fn() {}\0""", expected: @[]),
            Test(input: """fn(x) {}\0""", expected: @["x"]),
            Test(input: """fn(x, y, z) {}\0""", expected: @["x", "y", "z"])
        ]

        for i in testInputs:
            let l = newLexer(i.input)
            let p = newParser(l)
            let program = p.parseProgram()

            let params = program.statements[0].FnParameters

            check(params.len == i.expected.len)

            for idx, e in i.expected:
                check(params[idx].Token.Literal == e)

    test "test callExpressions parging":
        let input = """add(1, 2 * 3, 4 + 5)\0"""

        let l = newLexer(input)
        let p = newParser(l)
        let statement = p.parseProgram().statements[0]

        check(statement.kind == nkCallExpression)

        let fn = statement.Token.Literal
        check(fn == "add")

        let args = statement.Args
        check(args[0].Token.Literal == "1")
        check(args[1].InLeft.Token.Literal == "2")
        check(args[1].InOperator == "*")
        check(args[1].InRight.Token.Literal == "3")
        check(args[2].InLeft.Token.Literal == "4")
        check(args[2].InOperator == "+")
        check(args[2].InRight.Token.Literal == "5")

    test "test operator precedence parsing":
        type Test = object
            input: string
            expected: string

        let testInputs = @[
            Test(input: """a + add(b * c) + d\0""",
                 expected: """((a + add((b * c))) + d)"""),
            Test(input: """add(a, b, 1, 2 * 3, 4 + 5, add(6, 7 * 8))\0""",
                 expected: """add(a, b, 1, (2 * 3), (4 + 5), add(6, (7 * 8)))"""),
            Test(input: """add(a + b + c * d / f + g)\0""",
                 expected: """add((((a + b) + ((c * d) / f)) + g))"""),
        ]

        for i in testInputs:
            let l = newLexer(i.input)
            let p = newParser(l)
            let program = p.parseProgram()
            checkParserError(p)

            let act = program.astToString()
            check(act == i.expected)

    test "test let statement":
        type Test[T] = object
            input: string
            expectedIdentifier: string
            expectedValue: T

        let testInt = Test[int](input: """let x = 5;\0""",
                                expectedIdentifier: "x",
                                expectedValue: 5)

        let testBool = Test[bool](input: """let y = true;\0""",
                                    expectedIdentifier: "y",
                                    expectedValue: true)

        let testStr = Test[string](input: """let foobar = y;\0""",
                                    expectedIdentifier: "foobar",
                                    expectedValue: "y")

        proc tes[T](test: Test[T]): PNode =
            let l = newLexer(test.input)
            let p = newParser(l)
            let program = p.parseProgram()
            checkParserError(p)

            result = program.statements[0]
            check(result.LetName.Token.Literal == test.expectedIdentifier)

        var actInt = tes(testInt)
        check(actInt.LetValue.IntValue == testInt.expectedValue)

        var actBool = tes(testBool)
        check(actBool.LetValue.BlValue == testBool.expectedValue)

        var actStr = tes(testStr)
        check(actStr.LetValue.IdentValue == testStr.expectedValue)