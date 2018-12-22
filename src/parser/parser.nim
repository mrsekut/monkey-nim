import ast
import ../lexer/lexer
import ../lexer/token
import sequtils, strformat, typetraits


type Parser = ref object of RootObj
    l: Lexer
    curToken: Token
    peekToken: Token
    errors: seq[string]

proc nextToken(self: Parser) =
        self.curToken = self.peekToken
        self.peekToken = self.l.nextToken()

proc curTokenIs(self: Parser, t: TokenType): bool = self.curToken.Type == t
proc peekTokenIs(self: Parser, t: TokenType): bool = self.peekToken.Type == t

proc peekError(self: Parser, t: token.TokenType) =
    let msg = fmt"expected next tokent to be {t}, got {self.peekToken.Type} instead"
    self.errors.add(msg)

proc expectPeek(self: Parser, t: token.TokenType): bool =
    if self.peekTokenIs(t):
        self.nextToken()
        return true
    else:
        self.peekError(t)
        return false


proc parseLetStatement(self: Parser): LetStatement =
    var statement = LetStatement(Token: self.curToken)

    # ident
    if not self.expectPeek(token.IDENT): return nil
    statement.Name = Identifier(
                        Token: self.curToken,
                        Value: self.curToken.Literal
                     )

    # =
    if not self.expectPeek(token.ASSIGN): return nil

    # ~ ;
    while not self.curTokenIs(token.SEMICOLON):
        self.nextToken()

    statement


proc parseStatement(self: Parser): LetStatement =
    case self.curToken.Type
    of token.LET:
        return self.parseLetStatement()
    else:
        return nil

# create AST Root Node
proc parseProgram*(self: Parser): Program =
    var program = Program()
    program.statements = newSeq[LetStatement]()

    while self.curToken.Type != token.EOF:
        let statement = self.parseStatement()
        if statement != nil: program.statements.add(statement)
        self.nextToken()

    program

proc error(self: Parser): seq[string] = self.errors

proc newParser*(l: Lexer): Parser =
    let p = Parser(l: l, errors: newSeq[string]())
    p.nextToken()
    p.nextToken()
    p

proc main() = discard

when isMainModule:
    main()