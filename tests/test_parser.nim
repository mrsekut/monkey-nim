import
    unittest, strformat, typetraits,
    ../src/parser/ast,
    ../src/parser/parser,
    ../src/lexer/lexer

proc checkParserError(self: Parser): void =
    let errors = self.error()
    if errors.len == 0: return
    echo fmt"parser has {errors.len} errors"

proc testIntegerLiteral(il: int, value: int): bool =
    il == value



suite "Parser":
    test "it should parse letStatements":
        let input: string = """
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
            check(statement.Name.IdentValue == expects[i])


    test "it should parse returnStatements":
        let input: string = """
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
    #         check(testIntegerLiteral(exp.InLeft.IntValue, i.leftValue))
    #         check(exp.InOperator == i.operator)
    #         check(testIntegerLiteral(exp.InRight.IntValue, i.rightValue))

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
