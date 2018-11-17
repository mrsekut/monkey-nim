import token

type Lexer* = ref object of RootObj
    input: string
    position: int
    readPosition: int
    ch: char


method readNextChar(this: Lexer)  {.base.} =
    if this.readPosition >= len(this.input):
        this.ch = ' '
    else:
        this.ch = this.input[this.readPosition]
    this.position = this.readPosition
    this.readPosition += 1


proc newLexer*(input: string): Lexer =
    var l = Lexer(input: input)
    l.readNextChar()
    return l

proc newToken(tokenType: TokenType, ch: char): Token =
    return Token(Type: tokenType, Literal: $ch)

proc isLetter(ch: char): bool =
    return ('a' <= ch and ch <= 'z') or ('A' <= ch and ch <= 'Z') or ch == '_'

proc isDigit(ch: char): bool =
    return '0' <= ch and ch <= '9'

method readIdentifier(this: Lexer): string {.base.} =
    let position = this.position
    while isLetter(this.ch):
        this.readNextChar()

    return this.input[position..this.position-1]

method skipWhiteSpace(this: Lexer)  {.base.} =
    while this.ch == ' ' or this.ch == '\t' or this.ch == '\n':
        this.readNextChar()

method readNumber(this: Lexer): string  {.base.} =
    let position = this.position
    while isDigit(this.ch):
        this.readNextChar()

    return this.input[position..this.position-1]

method peekChar(this: Lexer): char =
    if this.readPosition >= len(this.input):
        return ' '
    else:
        return this.input[this.readPosition]

method nextToken*(this: Lexer): token.Token  {.base.} =
    var tok: token.Token
    this.skipWhiteSpace()

    case this.ch
    of '=':
        if this.peekChar() == '=':
            let ch = this.ch
            this.readNextChar()
            let l = $ch & $this.ch
            tok = Token(Type: EQ, Literal: l)
        else:
            tok = newToken(ASSIGN, this.ch)
    of ':':
        tok = newToken(COLON, this.ch)
    of '(':
        tok = newToken(LPAREN, this.ch)
    of ')':
        tok = newToken(RPAREN, this.ch)
    of ',':
        tok = newToken(COMMA, this.ch)
    of '+':
        tok = newToken(PLUS, this.ch)
    of '-':
        tok = newToken(MINUS, this.ch)
    of '!':
        if this.peekChar() == '=':
            let ch = this.ch
            this.readNextChar()
            let l = $ch & $this.ch
            tok = Token(Type: NOT_EQ, Literal: l)
        else:
            tok = newToken(BANG, this.ch)
    of '*':
        tok = newToken(ASTERISC, this.ch)
    of '/':
        tok = newToken(SLASH, this.ch)
    of '<':
        tok = newToken(LT, this.ch)
    of '>':
        tok = newToken(GT, this.ch)
    of '{':
        tok = newToken(LBRACE, this.ch)
    of '}':
        tok = newToken(RBRACE, this.ch)

    else:
        if isLetter(this.ch):
            let l = this.readIdentifier()
            let t = LookUpIdent(l)
            return Token(Type: t, Literal: l)
        elif isDigit(this.ch):
            let t = token.INT
            let l = this.readNumber()
            return Token(Type: t, Literal: l)
        else:
            tok = newToken(token.ILLEGAL, this.ch)

    this.readNextChar()
    return tok


proc main() =
  block:

    let b:char = 'b'
    let c:char = 'c'

    let l = $b & $c
    echo l




when isMainModule:
  main()