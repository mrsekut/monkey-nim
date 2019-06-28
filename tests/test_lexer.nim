import unittest
import ../src/lexer/lexer
import ../src/lexer/token


suite "Lexer":
    test "it analysis simple code":
        let input = """
            let five = 5
            let ten = 10

            fn add(x, y) =
              x + y

            let result = add(five, ten)

            !-/*5
            5 < 10 > 5

            if 5 > 10:
              return true
            else:
              return false

            10 == 10
            10 != 9;
            "foobar"
            "foo bar"
            """

        let test = @[
            ( LET, "let" ),
            ( IDENT, "five" ),
            ( ASSIGN, "=" ),
            ( INT, "5" ),
            ( LET, "let" ),
            ( IDENT, "ten"),
            ( ASSIGN, "=" ),
            ( INT, "10" ),
            ( FUNCTION, "fn" ),
            ( IDENT, "add" ),
            ( LPAREN, "(" ),
            ( IDENT, "x" ),
            ( COMMA, "," ),
            ( IDENT, "y" ),
            ( RPAREN, ")" ),
            ( ASSIGN, "=" ),
            ( IDENT, "x" ),
            ( PLUS, "+" ),
            ( IDENT, "y" ),
            ( LET, "let" ),
            ( IDENT, "result" ),
            ( ASSIGN, "=" ),
            ( IDENT, "add" ),
            ( LPAREN, "(" ),
            ( IDENT, "five" ),
            ( COMMA, "," ),
            ( IDENT, "ten" ),
            ( RPAREN, ")" ),

            ( token.BANG, "!" ),
            ( MINUS, "-" ),
            ( SLASH, "/" ),
            ( ASTERISC, "*" ),
            ( INT, "5" ),
            ( INT, "5" ),
            ( LT, "<" ),
            ( INT, "10" ),
            ( GT, ">" ),
            ( INT, "5" ),
            ( IF, "if" ),
            ( INT, "5" ),
            ( GT, ">" ),
            ( INT, "10" ),
            ( COLON, ":" ),
            ( RETURN, "return" ),
            ( TRUE, "true" ),
            ( ELSE, "else" ),
            ( COLON, ":" ),
            ( RETURN, "return" ),
            ( FALSE, "false" ),

            ( INT, "10" ),
            ( EQ, "==" ),
            ( INT, "10" ),
            ( INT, "10" ),
            ( NOT_EQ, "!=" ),
            ( INT, "9" ),
            ( SEMICOLON, ";" ),
            ( STRING, "foobar" ),
            ( STRING, "foo bar" ),
            ( EOF, "\0" ),
        ]

        var l = lexer.newLexer(input)

        for i in test:
            let tok = l.nextToken()
            check(i[0] == tok.Type)
            check(i[1] == tok.Literal)
