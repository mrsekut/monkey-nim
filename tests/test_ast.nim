import unittest, strformat
import ../src/parser/ast
import ../src/parser/parser
import ../src/lexer/lexer
import ../src/lexer/token

suite "AST":
    test "it should parse index letStatement":
        let program = Program(
            statements: @[
                Statement(
                    kind: LetStatement,
                    Token: Token(Type: token.LET, Literal: "let"),
                    Name: Identifier(
                        kind: TIdentifier.Ident,
                        Token: Token(Type: token.IDENT, Literal: "myVar"),
                        IdentValue: "myVar"
                    ),
                    Value: Identifier(
                        kind: TIdentifier.Ident,
                        Token: Token(Type: token.IDENT, Literal: "anotherVar"),
                        IdentValue: "anotherVar"
                    )
                )
            ]
        )

        let input: string = "let myVar = anotherVar;"
        check(program.astToString() == input)
