import tables
type TokenType* = string

type Token* = ref object of RootObj
    Type*: TokenType
    Literal*: string

const
    ILLEGAL* = "ILLEGAL"
    EOF* = "EOF"

    IDENT* = "IDENT"
    INT* = "INT"

    ASSIGN* = "="
    PLUS* = "+"

    COMMA* = ","
    COLON* = ":"

    LPAREN* = "("
    RPAREN* = ")"
    LBRACE* = "{"
    RBRACE* = "}"

    PROC* = "PROC"
    LET* = "LET"


var keywords = {
    "proc": PROC,
    "let": LET
    }.newTable

# proc keywords(ident) =


proc LookUpIdent*(ident: string): TokenType =
    if keywords.hasKey(ident):
        return string(LET)
    return IDENT