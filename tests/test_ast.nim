import
    unittest, strformat,
    ../src/parser/ast,
    ../src/parser/parser,
    ../src/lexer/lexer,
    ../src/lexer/token


suite "AST":
    test "it should parse index letStatement":
        let program = PNode(
            kind: Program,
            statements: @[
                PNode(
                    kind: nkLetStatement,
                    Token: Token(Type: token.LET, Literal: "let"),
                    LetName: PNode(
                        kind: nkIdent,
                        Token: Token(Type: token.IDENT, Literal: "myVar"),
                        IdentValue: "myVar"
                    ),
                    LetValue: PNode(
                        kind: nkIdent,
                        Token: Token(Type: token.IDENT, Literal: "anotherVar"),
                        IdentValue: "anotherVar"
                    )
                )
            ]
        )

        let input = "let myVar = anotherVar;"
        check(program.astToString() == input)
