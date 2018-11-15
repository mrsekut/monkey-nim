type TokenType* = string

type Token* = ref object of RootObj
    Type: TokenType
    Literal: string

const
    ILLEGAL* = "ILLEGAL"
    EOF = "EOF"

    IDENT = "IDENT"
    INT = "INT"

    ASSIGN* = "="
    PLUS = "+"

    COMMA = ","
    SEMICOLON = ";"

    LPAREN = "("
    RPAREN = ")"
    LBRACE = "{"
    RBRASE = "}"

    FUNCTION = "FUNCTION"
    LET = "LET"

