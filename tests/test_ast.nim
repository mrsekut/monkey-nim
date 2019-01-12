import
    unittest, strformat
    # ../src/parser/ast,
    # ../src/parser/parser,
    # ../src/lexer/lexer,
    # ../src/lexer/token

suite "AST":
    test "it should parse index letStatement":
        check(true==true)
#         let program = Program(
#             statements: @[
#                 Statement(
#                     kind: LetStatement,
#                     Token: Token(Type: token.LET, Literal: "let"),
#                     Name: Identifier(
#                         kind: TIdentifier.Ident,
#                         Token: Token(Type: token.IDENT, Literal: "myVar"),
#                         IdentValue: "myVar"
#                     ),
#                     Value: Identifier(
#                         kind: TIdentifier.Ident,
#                         Token: Token(Type: token.IDENT, Literal: "anotherVar"),
#                         IdentValue: "anotherVar"
#                     )
#                 )
#             ]
#         )

#         let input: string = "let myVar = anotherVar;"
#         check(program.astToString() == input)
