import token

type Lexer* = ref object of RootObj
    input: string
    position: int
    readPosition: int
    ch: char


proc readNextChar(this: Lexer) =
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

proc newToken(tokenType: token.TokenType, ch: char):token.Token =
    return token.Token(Type: tokenType, Literal: $ch)

proc isLetter(ch: char): bool =
    return ('a' <= ch and ch <= 'z') or ('A' <= ch and ch <= 'Z') or ch == '_'

proc readIdentifier(this: Lexer): string =
    let position = this.position
    while isLetter(this.ch):
        this.readNextChar()

    return this.input[position..this.position-1]

proc skipWhiteSpace(this: Lexer) =
    while this.ch == ' ' or this.ch == '\t' or this.ch == '\n':
        this.readNextChar()

proc isDigit(ch: char): bool =
    return '0' <= ch and ch <= '9'


proc readNumber(this: Lexer): string =
    let position = this.position
    while isDigit(this.ch):
        this.readNextChar()

    return this.input[position..this.position-1]

proc nextToken*(this: Lexer): token.Token =
    var tok: token.Token
    this.skipWhiteSpace()

    case this.ch
    of '=':
        tok = newToken(token.ASSIGN, this.ch)
    of ':':
        tok = newToken(token.COLON, this.ch)
    of '(':
        tok = newToken(token.LPAREN, this.ch)
    of ')':
        tok = newToken(token.RPAREN, this.ch)
    of ',':
        tok = newToken(token.COMMA, this.ch)
    of '+':
        tok = newToken(token.PLUS, this.ch)
    of '{':
        tok = newToken(token.LBRACE, this.ch)
    of '}':
        tok = newToken(token.RBRACE, this.ch)
    else:
        if isLetter(this.ch):
            let l = this.readIdentifier()
            let t = token.LookUpIdent(l)
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
    let l = newLexer("10")
    echo $isDigit('1')
    # let b = l.nextToken()
    # echo $b.Literal




when isMainModule:
  main()