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


    test "it should parse string expression":
        let
            input = """
                "hello world";
            """
            l = newLexer(input)
            p = newParser(l)
            program = p.parseProgram()

        checkParserError(p)
        let statement = program.statements[0]
        check(statement.kind == nkStringLiteral)
        let value = statement.StringValue
        check(value == "hello world")


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
        type TestPrefixExpressions = object
            input: string
            operator: string
            integerValue: int

        let testInputs = @[
            TestPrefixExpressions(input: "!5", operator: "!", integerValue: 5),
            TestPrefixExpressions(input: "-15", operator: "-", integerValue: 15)
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


    test "it should parse infixExpressions":
        type TestInfixExpressions = object
            input: string
            leftValue: int
            operator: string
            rightValue: int

        let testInputs = @[
            TestInfixExpressions(input: "5 + 5;", leftValue: 5, operator: "+", rightValue: 5),
            TestInfixExpressions(input: "5 - 5;", leftValue: 5, operator: "-", rightValue: 5),
            TestInfixExpressions(input: "5 * 5;", leftValue: 5, operator: "*", rightValue: 5),
            TestInfixExpressions(input: "5 / 5;", leftValue: 5, operator: "/", rightValue: 5),
            TestInfixExpressions(input: "5 > 5;", leftValue: 5, operator: ">", rightValue: 5),
            TestInfixExpressions(input: "5 < 5;", leftValue: 5, operator: "<", rightValue: 5),
            TestInfixExpressions(input: "5 == 5;", leftValue: 5, operator: "==", rightValue: 5),
            TestInfixExpressions(input: "5 != 5;", leftValue: 5, operator: "!=", rightValue: 5)
        ]

        for i in testInputs:
            let
                l = newLexer(i.input)
                p = newParser(l)
                program = p.parseProgram()
                exp = program.statements[0]

            checkParserError(p)
            check(program.statements.len == 1)
            check(testIntegerLiteral(exp.InLeft, i.leftValue))
            check(exp.InOperator == i.operator)
            check(testIntegerLiteral(exp.InRight, i.rightValue))


    test "test operator precedence parsing":
        type TestOpPrecedence = object
            input: string
            expected: string

        let testInputs = @[
            TestOpPrecedence(input: "-a * b", expected: "((-a) * b)"),
            TestOpPrecedence(input: "!-a", expected: "(!(-a))"),
            TestOpPrecedence(input: "a + b + c", expected: "((a + b) + c)"),
            TestOpPrecedence(input: "a * b / c", expected: "((a * b) / c)"),
            TestOpPrecedence(input: "a + b * c + d / e - f", expected: "(((a + (b * c)) + (d / e)) - f)"),
            TestOpPrecedence(input: "3 + 4; -5 * 5", expected: "(3 + 4)((-5) * 5)"),
            TestOpPrecedence(input: "5 > 4 == 3 < 4", expected: "((5 > 4) == (3 < 4))"),
            TestOpPrecedence(input: "5 < 4 != 3 > 4", expected: "((5 < 4) != (3 > 4))"),
            TestOpPrecedence(input: "3 + 4 * 5 == 3 * 1 + 4 * 5", expected: "((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))"),
        ]

        for i in testInputs:
            let
                l = newLexer(i.input)
                p = newParser(l)
                program = p.parseProgram()
                act = program.astToString()
            checkParserError(p)
            check(act == i.expected)


    test "test operator precedence parsing":
        type TestOpPrecedence2 = object
            input: string
            expected: string

        let testInputs = @[
            TestOpPrecedence2(input: "true", expected: "true"),
            TestOpPrecedence2(input: "false", expected: "false"),
            TestOpPrecedence2(input: "3 < 5 == false", expected: "((3 < 5) == false)"),
            TestOpPrecedence2(input: "3 < 5 == true", expected: "((3 < 5) == true)"),

            TestOpPrecedence2(input: "true == true", expected: "(true == true)"),
            TestOpPrecedence2(input: "true != false", expected: "(true != false)"),
            TestOpPrecedence2(input: "false == false", expected: "(false == false)"),

            TestOpPrecedence2(input: "!true;", expected: "(!true)"),
            TestOpPrecedence2(input: "!false;", expected: "(!false)"),

            TestOpPrecedence2(input: "1 + (2 + 3) + 4", expected: "((1 + (2 + 3)) + 4)"),
            TestOpPrecedence2(input: "(5 + 5) * 2", expected: "((5 + 5) * 2)"),
            TestOpPrecedence2(input: "2 / (5 + 5);", expected: "(2 / (5 + 5))"),
            TestOpPrecedence2(input: "-(5 + 5);", expected: "(-(5 + 5))"),
            TestOpPrecedence2(input: "!(true == true);", expected: "(!(true == true))"),
        ]

        for i in testInputs:
            let
                l = newLexer(i.input)
                p = newParser(l)
                program = p.parseProgram()
                act = program.astToString()
            checkParserError(p)
            check(act == i.expected)


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


    test "test functionParameter parging":
        type TestFuncParm = object
            input: string
            expected: seq[string]

        let testInputs = @[
            TestFuncParm(input: "fn() {}", expected: @[]),
            TestFuncParm(input: "fn(x) {}", expected: @["x"]),
            TestFuncParm(input: "fn(x, y, z) {}", expected: @["x", "y", "z"])
        ]

        for i in testInputs:
            let
                l = newLexer(i.input)
                p = newParser(l)
                program = p.parseProgram()
                params = program.statements[0].FnParameters

            check(params.len == i.expected.len)

            for idx, e in i.expected:
                check(params[idx].Token.Literal == e)


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


    test "test operator precedence parsing":
        type TestOpPrecedence3 = object
            input: string
            expected: string

        let testInputs = @[
            TestOpPrecedence3(input: """a + add(b * c) + d""",
                 expected: """((a + add((b * c))) + d)"""),
            TestOpPrecedence3(input: """add(a, b, 1, 2 * 3, 4 + 5, add(6, 7 * 8))""",
                 expected: """add(a, b, 1, (2 * 3), (4 + 5), add(6, (7 * 8)))"""),
            TestOpPrecedence3(input: """add(a + b + c * d / f + g)""",
                 expected: """add((((a + b) + ((c * d) / f)) + g))"""),
        ]

        for i in testInputs:
            let
                l = newLexer(i.input)
                p = newParser(l)
                program = p.parseProgram()
            checkParserError(p)

            let act = program.astToString()
            check(act == i.expected)


    test "test let statement":
        type TestLetStmt[T] = object
            input: string
            expectedIdentifier: string
            expectedValue: T
        let
            testInt = TestLetStmt[int](input: """let x = 5;""",
                                expectedIdentifier: "x",
                                expectedValue: 5)
            testBool = TestLetStmt[bool](input: """let y = true;""",
                                    expectedIdentifier: "y",
                                    expectedValue: true)
            testStr = TestLetStmt[string](input: """let foobar = y;""",
                                    expectedIdentifier: "foobar",
                                    expectedValue: "y")

        proc tes[T](test: TestLetStmt[T]): PNode =
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
