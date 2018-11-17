import unittest
import lexer/lexer
import lexer/token

suite "Lexer":
  # test "it analysis simple token":
  #   let input: string = """
  #     =+(){},:
  #     !-/*5
  #     5 < 10 > 5
  #   """

  #   let test = @[
  #       ( token.ASSiGN, "=" ),
  #       ( token.PLUS, "+" ),
  #       ( token.LPAREN, "(" ),
  #       ( token.RPAREN, ")" ),
  #       ( token.LBRACE, "{" ),
  #       ( token.RBRACE, "}"),
  #       ( token.COMMA, "," ),
  #       ( token.COLON, ":" ),
  #       # ( token.BANG, "!" ),
  #       # ( token.MINUS, "-" ),
  #       # ( token.SLASH, "/" ),
  #       # ( token.ASTERISC, "*" ),
  #       # ( token.INT, "5" ),
  #       # ( token.INT, "5" ),
  #       # ( token.LT, "<" ),
  #       # ( token.INT, "10" ),
  #       # ( token.GT, ">" ),
  #       # ( token.INT, "5" ),
  #       # ( token.EOF, "" ),
  #   ]

  #   var l = lexer.newLexer(input)

  #   for i in test:
  #       let tok = l.nextToken()
  #       check(i[0] == tok.Type)
  #       check(i[1] == tok.Literal)

  test "it analysis simple code":
    let input: string = """
      let five = 5
      let ten = 10

      proc add(x, y) =
        x + y

      let result = add(five, ten)
    """

    let test = @[
        ( token.LET, "let" ),
        ( token.IDENT, "five" ),
        ( token.ASSIGN, "=" ),
        ( token.INT, "5" ),
        ( token.LET, "let" ),
        ( token.IDENT, "ten"),
        ( token.ASSIGN, "=" ),
        ( token.INT, "10" ),
        ( token.PROC, "proc" ),
        ( token.IDENT, "add" ),
        ( token.LPAREN, "(" ),
        ( token.IDENT, "x" ),
        ( token.COMMA, "," ),
        ( token.IDENT, "y" ),
        ( token.RPAREN, ")" ),
        ( token.ASSIGN, "=" ),
        ( token.IDENT, "x" ),
        ( token.PLUS, "+" ),
        ( token.IDENT, "y" ),
        ( token.LET, "let" ),
        ( token.IDENT, "result" ),
        ( token.ASSIGN, "=" ),
        ( token.IDENT, "add" ),
        ( token.LPAREN, "(" ),
        ( token.IDENT, "five" ),
        ( token.COMMA, "," ),
        ( token.IDENT, "ten" ),
        ( token.RPAREN, ")" ),
        # ( token.EOF, "" ),
    ]

    var l = lexer.newLexer(input)

    for i in test:
        let tok = l.nextToken()
        check(i[0] == tok.Type)
        check(i[1] == tok.Literal)
