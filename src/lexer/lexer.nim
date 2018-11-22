import token

type Lexer* = ref object of RootObj
    input: string
    position: int
    readPosition: int
    ch: char

proc readNextChar(self: Lexer) =
    if self.readPosition >= len(self.input):
        self.ch = ' '
    else:
        self.ch = self.input[self.readPosition]
    self.position = self.readPosition
    self.readPosition += 1


proc newLexer*(input: string): Lexer =
    var l = Lexer(input: input)
    l.readNextChar()
    l

proc newToken(tokenType: TokenType, ch: char): Token =
    Token(Type: tokenType, Literal: $ch)

proc isLetter(ch: char): bool =
    ('a' <= ch and ch <= 'z') or ('A' <= ch and ch <= 'Z') or ch == '_'

proc isDigit(ch: char): bool =
    '0' <= ch and ch <= '9'

proc readIdentifier(self: Lexer): string =
    let position = self.position
    while isLetter(self.ch):
        self.readNextChar()

    self.input[position..self.position-1]

proc skipWhiteSpace(self: Lexer) =
    while self.ch == ' ' or self.ch == '\t' or self.ch == '\n':
        self.readNextChar()

proc readNumber(self: Lexer): string =
    let position = self.position
    while isDigit(self.ch):
        self.readNextChar()

    self.input[position..self.position-1]

proc peekChar(self: Lexer): char =
    if self.readPosition >= len(self.input):
        return ' '
    else:
        return self.input[self.readPosition]

proc nextToken*(self: Lexer): token.Token =
    var tok: token.Token
    self.skipWhiteSpace()

    case self.ch
    of '=':
        if self.peekChar() == '=':
            let ch = self.ch
            self.readNextChar()
            let l = $ch & $self.ch
            tok = Token(Type: EQ, Literal: l)
        else:
            tok = newToken(ASSIGN, self.ch)
    of ':':
        tok = newToken(COLON, self.ch)
    of '(':
        tok = newToken(LPAREN, self.ch)
    of ')':
        tok = newToken(RPAREN, self.ch)
    of ',':
        tok = newToken(COMMA, self.ch)
    of '+':
        tok = newToken(PLUS, self.ch)
    of '-':
        tok = newToken(MINUS, self.ch)
    of '!':
        if self.peekChar() == '=':
            let ch = self.ch
            self.readNextChar()
            let l = $ch & $self.ch
            tok = Token(Type: NOT_EQ, Literal: l)
        else:
            tok = newToken(BANG, self.ch)
    of '*':
        tok = newToken(ASTERISC, self.ch)
    of '/':
        tok = newToken(SLASH, self.ch)
    of '<':
        tok = newToken(LT, self.ch)
    of '>':
        tok = newToken(GT, self.ch)
    of '{':
        tok = newToken(LBRACE, self.ch)
    of '}':
        tok = newToken(RBRACE, self.ch)
    else:
        if isLetter(self.ch):
            let l = self.readIdentifier()
            let t = LookUpIdent(l)
            return Token(Type: t, Literal: l)
        elif isDigit(self.ch):
            let t = token.INT
            let l = self.readNumber()
            return Token(Type: t, Literal: l)
        else:
            tok = newToken(token.ILLEGAL, self.ch)

    self.readNextChar()
    tok

proc main() =
  block:

    let b:char = 'b'
    let c:char = 'c'

    let l = $b & $c
    echo l

when isMainModule:
  main()