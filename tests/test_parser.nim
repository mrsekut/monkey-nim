import unittest
import ../src/parser/ast
import ../src/parser/parser
import ../src/lexer/lexer

suite "Parser":
    test "it should parse statements":
        let input: string = """
            let x = 5
            let y = 10
            let foobar = 838383
        """

        let l = newLexer(input)
        # let p = newParser(l)

        # NOTE: テスト足りないかも
        # let program = p.ParseProgram()
        # check(program.statements == 3)

        # let expects = @["x", "y", "foobar"]


        # # NOTE: わからん
        # for i in 1..program.statements:
        #     let statement = program.statements[i]
        #     check(statement.token_literal == "let")
        #     check(ls.name.value == expect)

    test "it should peek error syntax":
        let input: string = """
            let x 5
            let = 10
            let 838383
        """

        # NOTE: わからん