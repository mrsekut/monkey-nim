import ast
import ../lexer/lexer
import ../lexer/token

type Parser = ref object of RootObj
    l: Lexer
    curToken: Token
    peekToken: Token

proc nextToken(self: Parser) =
    self.curToken = self.peekToken
    self.peekToken = self.l.nextToken()

proc parserProgram(self: Parser): Program = nil


proc newParser*(self: Parser, l: Lexer): Parser =
    let p = Parser(l: l) # NOTE: newとか合ってる？
    p.nextToken()
    p.nextToken()
    p

