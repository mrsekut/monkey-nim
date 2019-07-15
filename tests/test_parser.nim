import
    strutils, unittest, strformat, typetraits,
    ../src/parser/ast,
    ../src/parser/parser,
    ../src/lexer/lexer


proc checkParserError(self: Parser): void =
    let errors = self.error()
    if errors.len == 0: return
    echo fmt"parser has {errors.len} errors"


proc testIntegerLiteral(exp: PNode, value: int): bool =
    if(exp.kind != nkIntegerLiteral): return false
    let integer = exp.IntValue
    if(integer != value): return false
    if(exp.Token.Literal != $value): return false
    return true


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
#     # TODO: type check
#     let v = expected.type.name
#     case v
#     of "int": return testIntegerLiteral(exp, expected.parseInt)
#     of "string": return testIdentifier(exp, expected)
#     # of "boolean": return testBooleanLiteral(exp, expected)
#     else:
#         echo fmt"type of exp not handled. got={exp.astToString()}"
#         return false


# proc testInfixExpression(exp: PNode, left: auto, op: string, right: auto): bool =
#     if(exp.kind != nkInfixExpression): return false
#     if not testLiteralExpression(exp.nkInfixExpression.InLeft, left): return false
#     if exp.nkInfixExpression.InOperator != op: return false
#     if not testLiteralExpression(exp.nkInfixExpression.InRight, right): return false
#     return true





suite "Parser":

    test "it should parse letStatements":
        let input = """
            let x = 5;
            let y = 10;
            let foobar = 838383;
        """
        let
            l = newLexer(input)
            p = newParser(l)
            program = p.parseProgram()
        checkParserError(p)
        check(program.statements.len == 3)

        let expects = @["x", "y", "foobar"]
        for i in 0..<program.statements.len:
            let statement = program.statements[i]
            # check(statement.LetName.IdentValue == expects[i])


    test "it should parse returnStatements":
        let input = """
            return 5;
            return 10;
            return 838383;
        """
        let
            l = newLexer(input)
            p = newParser(l)
            program = p.parseProgram()

        checkParserError(p)
        check(program.statements.len == 3)

        for i in 0..<program.statements.len:
            let statement = program.statements[i].Token.Literal
            check(statement == "return")


    test "it should parse ident expression":
        let input = "foobar;"
        let
            l = newLexer(input)
            p = newParser(l)
            program = p.parseProgram()

        checkParserError(p)
        check(program.statements.len == 1)

        let
            statement = program.statements[0]
            value = statement.IdentValue
            literal = statement.Token.Literal
        check(value == "foobar")
        check(literal == "foobar")


    test "it should parse int expression":
        let input = "5;"
        let
            l = newLexer(input)
            p = newParser(l)
            program = p.parseProgram()
        checkParserError(p)
        check(program.statements.len == 1)

        let statement = program.statements[0]
        check(statement.kind == nkIntegerLiteral)

        let value = statement.IntValue
        check(value == 5)
        let literal = statement.Token.Literal
        check(literal == "5")


    test "it should parse boolean expression":
        let input = "true;"
        let
            l = newLexer(input)
            p = newParser(l)
            program = p.parseProgram()
        checkParserError(p)
        check(program.statements.len == 1)

        let statement = program.statements[0]
        check(statement.kind == nkBoolean)

        let value = statement.BlValue
        check(value == true)
        let literal = statement.Token.Literal
        check(literal == "true")


    test "it should parse prefixExpressions":
        type Test = object
            input: string
            operator: string
            integerValue: int

        let testInputs = @[
            Test(input: "!5", operator: "!", integerValue: 5),
            Test(input: "-15", operator: "-", integerValue: 15)
        ]

        for i in testInputs:
            let
                l = newLexer(i.input)
                p = newParser(l)
                program = p.parseProgram()
                exp = program.statements[0]
            checkParserError(p)
            check(program.statements.len == 1)
            check(exp.PrOperator == i.operator)
            check(testIntegerLiteral(exp.PrRight, i.integerValue))


    # # NOTE: If this test case is executed alone, it passes.
    # test "it should parse infixExpressions":
    #      TODO: コメントアウトしてるテスト、この「Test」型の名前をファイル内でユニークなものにしたら動くTestHogeなど
    #     type Test = object
    #         input: string
    #         leftValue: int
    #         operator: string
    #         rightValue: int
    #
    #     let testInputs = @[
    #         Test(input: "5 + 5;", leftValue: 5, operator: "+", rightValue: 5),
    #         Test(input: "5 - 5;", leftValue: 5, operator: "-", rightValue: 5),
    #         Test(input: "5 * 5;", leftValue: 5, operator: "*", rightValue: 5),
    #         Test(input: "5 / 5;", leftValue: 5, operator: "/", rightValue: 5),
    #         Test(input: "5 > 5;", leftValue: 5, operator: ">", rightValue: 5),
    #         Test(input: "5 < 5;", leftValue: 5, operator: "<", rightValue: 5),
    #         Test(input: "5 == 5;", leftValue: 5, operator: "==", rightValue: 5),
    #         Test(input: "5 != 5;", leftValue: 5, operator: "!=", rightValue: 5)
    #     ]
    #
    #     for i in testInputs:
    #         let
    #             l = newLexer(i.input)
    #             p = newParser(l)
    #             program = p.parseProgram()
    #             exp = program.statements[0]
    #
    #         checkParserError(p)
    #         check(program.statements.len == 1)
    #         check(testIntegerLiteral(exp.InLeft, i.leftValue))
    #         check(exp.InOperator == i.operator)
    #         check(testIntegerLiteral(exp.InRight, i.rightValue))


    # # NOTE: If this test case is executed alone, it passes.
    # test "test operator precedenve parsing":
    #     type Test = object
    #         input: string
    #         expected: string
    #
    #     let testInputs = @[
    #         Test(input: "-a * b", expected: "((-a) * b)"),
    #         Test(input: "!-a", expected: "(!(-a))"),
    #         Test(input: "a + b + c", expected: "((a + b) + c)"),
    #         Test(input: "a * b / c", expected: "((a * b) / c)"),
    #         Test(input: "a + b * c + d / e - f", expected: "(((a + (b * c)) + (d / e)) - f)"),
    #         Test(input: "3 + 4; -5 * 5", expected: "(3 + 4)((-5) * 5)"),
    #         Test(input: "5 > 4 == 3 < 4", expected: "((5 > 4) == (3 < 4))"),
    #         Test(input: "5 < 4 != 3 > 4", expected: "((5 < 4) != (3 > 4))"),
    #         Test(input: "3 + 4 * 5 == 3 * 1 + 4 * 5", expected: "((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))"),
    #     ]
    #
    #     for i in testInputs:
    #         let
    #             l = newLexer(i.input)
    #             p = newParser(l)
    #             program = p.parseProgram()
    #             act = program.astToString()
    #         checkParserError(p)
    #         check(act == i.expected)


    # # NOTE: If this test case is executed alone, it passes.
    # test "test operator precedence parsing":
    #     type Test = object
    #         input: string
    #         expected: string
    #
    #     let testInputs = @[
    #         Test(input: "true", expected: "true"),
    #         Test(input: "false", expected: "false"),
    #         Test(input: "3 < 5 == false", expected: "((3 < 5) == false)"),
    #         Test(input: "3 < 5 == true", expected: "((3 < 5) == true)"),
    #
    #         Test(input: "true == true", expected: "(true == true)"),
    #         Test(input: "true != false", expected: "(true != false)"),
    #         Test(input: "false == false", expected: "(false == false)"),
    #
    #         Test(input: "!true;", expected: "(!true)"),
    #         Test(input: "!false;", expected: "(!false)"),
    #
    #         Test(input: "1 + (2 + 3) + 4", expected: "((1 + (2 + 3)) + 4)"),
    #         Test(input: "(5 + 5) * 2", expected: "((5 + 5) * 2)"),
    #         Test(input: "2 / (5 + 5);", expected: "(2 / (5 + 5))"),
    #         Test(input: "-(5 + 5);", expected: "(-(5 + 5))"),
    #         Test(input: "!(true == true);", expected: "(!(true == true))"),
    #     ]
    #
    #     for i in testInputs:
    #         let
    #             l = newLexer(i.input)
    #             p = newParser(l)
    #             program = p.parseProgram()
    #             act = program.astToString()
    #         checkParserError(p)
    #         check(act == i.expected)


    test "test if expression":
        let input = "if (x < y){ x }"
        let
            l = newLexer(input)
            p = newParser(l)
            program = p.parseProgram()
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
        let input = "if (x < y){ x } else { y }"
        let
            l = newLexer(input)
            p = newParser(l)
            program = p.parseProgram()
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
        let input = "fn(x, y) { x + y }"
        let
            l = newLexer(input)
            p = newParser(l)
            program = p.parseProgram()
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


    # # NOTE: If this test case is executed alone, it passes.
    # test "test functionParameter parging":
    #     type Test = object
    #         input: string
    #         expected: seq[string]
    #
    #     let testInputs = @[
    #         Test(input: "fn() {}", expected: @[]),
    #         Test(input: "fn(x) {}", expected: @["x"]),
    #         Test(input: "fn(x, y, z) {}", expected: @["x", "y", "z"])
    #     ]
    #
    #     for i in testInputs:
    #         let
    #             l = newLexer(i.input)
    #             p = newParser(l)
    #             program = p.parseProgram()
    #             params = program.statements[0].FnParameters
    #
    #         check(params.len == i.expected.len)
    #
    #         for idx, e in i.expected:
    #             check(params[idx].Token.Literal == e)


    test "test callExpressions parging":
        let input = "add(1, 2 * 3, 4 + 5)"
        let
            l = newLexer(input)
            p = newParser(l)
            statement = p.parseProgram().statements[0]
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


    # # NOTE: If this test case is executed alone, it passes.
    # test "test operator precedence parsing":
    #     type Test = object
    #         input: string
    #         expected: string
    #
    #     let testInputs = @[
    #         Test(input: """a + add(b * c) + d""",
    #              expected: """((a + add((b * c))) + d)"""),
    #         Test(input: """add(a, b, 1, 2 * 3, 4 + 5, add(6, 7 * 8))""",
    #              expected: """add(a, b, 1, (2 * 3), (4 + 5), add(6, (7 * 8)))"""),
    #         Test(input: """add(a + b + c * d / f + g)""",
    #              expected: """add((((a + b) + ((c * d) / f)) + g))"""),
    #     ]
    #
    #     for i in testInputs:
    #         let
    #             l = newLexer(i.input)
    #             p = newParser(l)
    #             program = p.parseProgram()
    #         checkParserError(p)
    #
    #         let act = program.astToString()
    #         check(act == i.expected)


    test "test let statement":
        type Test[T] = object
            input: string
            expectedIdentifier: string
            expectedValue: T
        let
            testInt = Test[int](input: """let x = 5;""",
                                expectedIdentifier: "x",
                                expectedValue: 5)
            testBool = Test[bool](input: """let y = true;""",
                                    expectedIdentifier: "y",
                                    expectedValue: true)
            testStr = Test[string](input: """let foobar = y;""",
                                    expectedIdentifier: "foobar",
                                    expectedValue: "y")

        proc tes[T](test: Test[T]): PNode =
            let
                l = newLexer(test.input)
                p = newParser(l)
                program = p.parseProgram()
            checkParserError(p)
            result = program.statements[0]
            check(result.LetName.Token.Literal == test.expectedIdentifier)

        var actInt = tes(testInt)
        check(actInt.LetValue.IntValue == testInt.expectedValue)

        var actBool = tes(testBool)
        check(actBool.LetValue.BlValue == testBool.expectedValue)

        var actStr = tes(testStr)
        check(actStr.LetValue.IdentValue == testStr.expectedValue)
