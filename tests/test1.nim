import unittest
import lexer/lexer
import lexer/token

suite "Lexer":
   test "it analysis simple token":
    let input: string = "=+(){},:"

    let test = @[
        ( token.ASSiGN, "=" ),
        ( token.PLUS, "+" ),
        ( token.LPAREN, "(" ),
        ( token.RPAREN, ")" ),
        ( token.LBRACE, "{" ),
        ( token.RBRACE, "}"),
        ( token.COMMA, "," ),
        ( token.COLON, ":" ),
        # ( token.EOF, "" ),
    ]

    var l = lexer.newLexer(input)

    for i in test:
        let tok = l.nextToken()
        check(i[1] == tok.Literal)