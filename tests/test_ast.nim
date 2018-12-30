import unittest, strformat
import ../src/parser/ast
import ../src/parser/parser
import ../src/lexer/lexer
import ../src/lexer/token

suite "AST":
    test "it should": # TODO:
        let program = Program(
            statements: @[
                Statement(
                    kind: LetStatement,
                    Token: Token(Type: token.LET, Literal: "let"),
                    Name: Identifier(
                        Token: Token(Type: token.IDENT, Literal: "myVar"),
                        Value: "myVar"
                    ),
                    Value: Identifier(
                        Token: Token(Type: token.IDENT, Literal: "anothoerVar"),
                        Value: "anotherVar"
                    )
                )
            ]
        )

        let input: string = "let myVar = anotherVar;"
        check(program.astToString() == input)
