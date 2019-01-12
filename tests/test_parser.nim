import
    unittest, strformat, typetraits,
    ../src/parser/ast,
    ../src/parser/parser,
    ../src/lexer/lexer

proc checkParserError(self: Parser): void =
    let errors = self.error()
    if errors.len == 0: return
    echo fmt"parser has {errors.len} errors"

# # NOTE: わからん
# proc testIntegerLiteral(il: auto, value: int): bool =
#     # let integ = il.IntegerLiteral
#     return true



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

    # test "it should parse ident expression":
    #     let input = """foobar;\0"""

    #     let l = newLexer(input)
    #     let p = newParser(l)
    #     let program = p.parseProgram()
    #     checkParserError(p)
    #     check(program.statements.len == 1)

    #     let statement = program.statements[0]
    #     # check(statement.kind == ExpressionStatement)

    #     let value = statement.Expression.IdentValue
    #     check(value == "foobar")
    #     let literal = statement.Expression.Token.Literal
    #     check(literal == "foobar")

    # test "it should parse int expression":
    #     let input = """5;\0"""

    #     let l = newLexer(input)
    #     let p = newParser(l)
    #     let program = p.parseProgram()
    #     checkParserError(p)
    #     check(program.statements.len == 1)

    #     let statement = program.statements[0]
    #     # check(statement.kind == ExpressionStatement)

    #     let value = statement.Expression.IntValue
    #     check(value == 5)
    #     let literal = statement.Expression.Token.Literal
    #     check(literal == "5")

    # test "it should parse prefixExpressions":

    #     type Test = object
    #         input: string
    #         operator: string
    #         integerValue: int

    #     let testInputs = @[
    #         Test(input: "!5", operator: "!", integerValue: 5),
    #         Test(input: "-15", operator: "-", integerValue: 15)
    #     ]

    #     for i in testInputs:
    #         let l = newLexer(i.input)
    #         let p = newParser(l)
    #         let program = p.parseProgram()
    #         checkParserError(p)

    #         check(program.statements.len == 1)

    #         let exp = program.statements[0].Expression
    #         check(exp.Token.Literal == i.operator)
    #         # NOTE:
    #         testIntegerLiteral(exp.Right, i.integerValue)