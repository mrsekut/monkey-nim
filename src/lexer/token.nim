import tables

type
    TokenType* = string

    Token* = ref object of RootObj
        Type*:    TokenType
        Literal*: string


const
    ILLEGAL*   = "ILLEGAL"
    EOF*       = "EOF"

    IDENT*     = "IDENT"
    INT*       = "INT"
    STRING*    = "STRING"

    ASSIGN*    = "="
    PLUS*      = "+"
    MINUS*     = "-"
    BANG*      = "!"
    ASTERISC*  = "*"
    SLASH*     = "/"

    LT*        = "<"
    GT*        = ">"

    COMMA*     = ","
    COLON*     = ":"
    SEMICOLON* = ";"

    LPAREN*    = "("
    RPAREN*    = ")"
    LBRACE*    = "{"
    RBRACE*    = "}"

    FUNCTION*  = "FUNCTION"
    LET*       = "LET"
    TRUE*      = "TRUE"
    FALSE*     = "FALSE"
    IF*        = "IF"
    ELSE*      = "ELSE"
    RETURN*    = "RETURN"

    EQ*        = "=="
    NOT_EQ*    = "!="

    LBRACKET*  = "["
    RBRACKET*  = "]"


var keywords = {
    "fn":     FUNCTION,
    "let":    LET,
    "true":   TRUE,
    "false":  FALSE,
    "if":     IF,
    "else":   ELSE,
    "return": RETURN
    }.newTable


proc LookUpIdent*(ident: string): TokenType =
    if keywords.hasKey(ident):
        return keywords[ident]
    return IDENT