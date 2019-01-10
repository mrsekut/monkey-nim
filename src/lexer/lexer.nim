import token

const
    chars: set[char] = {'a'..'z', 'A'..'Z', '_'}
    nums: set[char] = {'0'..'9'}

proc isLetter(ch: char): bool = ch in chars
proc isDigit(num: char): bool = num in nums

proc newToken(tokenType: TokenType, ch: char): Token =
    new result
    result.Type = tokenType
    result.Literal = $ch


# Lexer
# ================
type Lexer* = ref object of RootObj
    input: string
    position: int
    readPosition: int
    ch: char

proc newLexer*(input: string): Lexer
proc readNextChar(self: var Lexer)
proc readIdentifier(self: var Lexer): string
proc skipWhiteSpace(self: var Lexer)
proc readNumber(self: var Lexer): string
proc peekChar(self: var Lexer): char
proc nextToken*(self: var Lexer): token.Token

# implementation

proc newLexer*(input: string): Lexer =
    new result
    result.input = input
    result.readNextChar()

proc readNextChar(self: var Lexer) =
    if self.readPosition >= len(self.input):
        self.ch = ' '
    else:
        self.ch = self.input[self.readPosition]
    self.position = self.readPosition
    self.readPosition += 1

proc readIdentifier(self: var Lexer): string =
    let position = self.position
    while isLetter(self.ch):
        self.readNextChar()

    self.input[position..self.position-1]

proc skipWhiteSpace(self: var Lexer) =
    while self.ch == ' ' or self.ch == '\t' or self.ch == '\n':
        self.readNextChar()

proc readNumber(self: var Lexer): string =
    let position = self.position
    while isDigit(self.ch):
        self.readNextChar()

    self.input[position..self.position-1]

proc peekChar(self: var Lexer): char =
    if self.readPosition >= len(self.input):
        return ' '
    else:
        return self.input[self.readPosition]

proc nextToken*(self: var Lexer): token.Token =
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
    of ';':
        tok = newToken(SEMICOLON, self.ch)
    of '\\': # 仮
        tok = newToken(EOF, self.ch)
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

proc main() = discard

when isMainModule:
  main()