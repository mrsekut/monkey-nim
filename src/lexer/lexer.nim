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

proc nextToken*(this: Lexer): token.Token =
    var tok: token.Token

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
        tok.Literal = ""
        tok.Type = token.EOF

    this.readNextChar()
    return tok

import unittest

proc main() =
  block:
    echo "hello"

when isMainModule:
  main()