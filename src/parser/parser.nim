import ast, sequtils, strformat, typetraits, tables, strutils
import ../lexer/lexer
import ../lexer/token

# type
#     PrefixParseFn =  proc(): Identifier
#     InfixParseFn = proc(x: Identifier): Identifier




type Parser* = ref object of RootObj
    l: Lexer
    curToken: Token
    peekToken: Token
    errors: seq[string]

    # prefixParseFns: Table[Token, PrefixParseFn]
    # infixParseFns: Table[Token, InfixParseFn]

type Precedence = enum
    LOWEST
    # EQUALS,
    # LESSGREATER,
    # SUM,
    # PRODUCT,
    # PREFIX,
    # CALL



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


proc parseLetStatement(self: Parser): Statement =
    var statement = Statement(kind: LetStatement, Token: self.curToken)

    # ident
    if not self.expectPeek(token.IDENT): return Statement(kind: Nil)
    statement.Name = Identifier(
                        kind: TIdentifier.Ident,
                        Token: self.curToken,
                        IdentValue: self.curToken.Literal
                     )

    # =
    if not self.expectPeek(token.ASSIGN): return Statement(kind: Nil)

    # ~ ;
    while not self.curTokenIs(token.SEMICOLON):
        self.nextToken()

    statement

proc parseReturnStatement(self: Parser): Statement =

    var statement = Statement(kind: ReturnStatement, Token: self.curToken)
    self.nextToken()

    # ~ ;
    while not self.curTokenIs(token.SEMICOLON):
        self.nextToken()

    statement

proc parseIdentifier(self: Parser): Identifier =
    Identifier(kind: TIdentifier.Ident, Token: self.curToken, IdentValue: self.curToken.Literal)

proc parseIntegerLiteral(self: Parser): Identifier =
    Identifier(kind: TIdentifier.IntegerLiteral, Token: self.curToken, IntValue: self.curToken.Literal.parseInt)

proc parseExpression(self: Parser, precedence: Precedence): Identifier =
    # TODO: p.59
    case self.curToken.Token.Type
    of token.IDENT: return self.parseIdentifier()
    of token.INT: return self.parseIntegerLiteral()
    else: discard

proc parseExpressionStatement(self: Parser): Statement =
    var statement = Statement(kind: ExpressionStatement, Token: self.curToken)
    statement.Expression = self.parseExpression(LOWEST)

    # ~ ;
    if self.peekTokenIs(token.SEMICOLON):
        self.nextToken()

    statement


proc parseStatement(self: Parser): Statement =
    case self.curToken.Type
    of token.LET: return self.parseLetStatement()
    of token.RETURN: return self.parseReturnStatement()
    else: return self.parseExpressionStatement()

# create AST Root Node
proc parseProgram*(self: Parser): Program =
    var program = Program()
    program.statements = newSeq[Statement]()

    while self.curToken.Type != token.EOF:
        let statement = self.parseStatement()
        if statement.kind != Nil:
            program.statements.add(statement)

        self.nextToken()

    program

proc newParser*(l: Lexer): Parser =
    let p = Parser(l: l, errors: newSeq[string]())

    p.nextToken()
    p.nextToken()
    p

# proc regiserPrefix(self: Parser, tokenType: TokenType, fn: PrefixParseFn) =
#     self.prefixParseFns[tokenType] = fn



proc error*(self: Parser): seq[string] = self.errors


proc main() = discard

when isMainModule:
    main()
