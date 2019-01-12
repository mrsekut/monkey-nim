import
    ast, sequtils, strformat, typetraits, tables, strutils,
    ../lexer/lexer, ../lexer/token


# type
#     PrefixParseFn =  proc(): Identifier
#     InfixParseFn = proc(x: Identifier): Identifier


# type PrefixType = enum
#     # PLUS,
#     MINUS,
#     NOT

type
    Precedence = enum
        LOWEST
        # EQUALS,
        # LESSGREATER,j
        # SUM,
        # PRODUCT,
        PREFIX,
        # CALL

type
    Parser* = ref object of RootObj
        l: Lexer
        curToken: Token
        peekToken: Token
        errors: seq[string]

    # prefixParseFns: Table[Token, PrefixParseFn]
    # infixParseFns: Table[Token, InfixParseFn]

proc newParser*(l: Lexer): Parser
# proc noPrefixParseError(self: Parser)
proc nextToken(self: Parser)
proc curTokenIs(self: Parser, t: TokenType): bool
proc peekTokenIs(self: Parser, t: TokenType): bool
# proc peekError(self: Parser, t: token.TokenType)
# proc expectPeek(self: Parser, t: token.TokenType): bool
proc parseLetStatement(self: Parser): PNode
# proc parseReturnStatement(self: Parser): Statement
# proc parseIdentifier(self: Parser): Identifier
# proc parseIntegerLiteral(self: Parser): Identifier
# proc parseExpression(self: Parser, precedence: Precedence): Identifier|PrefixExpression
# proc parsePrefixExpression(self: Parser): PrefixExpression
# proc parseExpression(self: Parser, precedence: Precedence): Identifier|PrefixExpression
# proc parseExpressionStatement(self: Parser): Statement
proc parseStatement(self: Parser): PNode
proc parseProgram*(self: Parser): Program
# proc error*(self: Parser): seq[string]

# implementation

proc newParser*(l: Lexer): Parser =
    let p = Parser(l: l, errors: newSeq[string]())

    p.nextToken()
    p.nextToken()
    p


proc nextToken(self: Parser) =
    self.curToken = self.peekToken
    self.peekToken = self.l.nextToken()

proc curTokenIs(self: Parser, t: TokenType): bool = self.curToken.Type == t
proc peekTokenIs(self: Parser, t: TokenType): bool = self.peekToken.Type == t

# proc peekError(self: Parser, t: token.TokenType) =
#     let msg = fmt"expected next tokent to be {t}, got {self.peekToken.Type} instead"
#     self.errors.add(msg)

proc expectPeek(self: Parser, t: token.TokenType): bool =
    if self.peekTokenIs(t):
        self.nextToken()
        return true
    else:
        # self.peekError(t)
        return false


proc parseLetStatement(self: Parser): PNode =
    var statement = PNode(kind: nkLetStatement, Token: self.curToken)

    # ident
    if not self.expectPeek(token.IDENT): return PNode(kind: Nil)
    statement.Name = PNode(
                        kind: nkIdent,
                        Token: self.curToken,
                        IdentValue: self.curToken.Literal
                     )

    # =
    if not self.expectPeek(token.ASSIGN): return PNode(kind: Nil)

    # ~ ;
    while not self.curTokenIs(token.SEMICOLON):
        self.nextToken()

    statement

# proc parseReturnStatement(self: Parser): Statement =

#     var statement = Statement(kind: ReturnStatement, Token: self.curToken)
#     self.nextToken()

#     # ~ ;
#     while not self.curTokenIs(token.SEMICOLON):
#         self.nextToken()

#     statement

# proc parseIdentifier(self: Parser): Identifier =
#     Identifier(
#         kind: TIdentifier.Ident,
#         Token: self.curToken,
#        IdentValue: self.curToken.Literal)

# proc parseIntegerLiteral(self: Parser): Identifier =
#     Identifier(
#         kind: TIdentifier.IntegerLiteral,
#         Token: self.curToken,
#         IntValue: self.curToken.Literal.parseInt)

# # Identifier or PrefixExpression
# proc parseExpression(self: Parser, precedence: Precedence): Identifier|PrefixExpression

# # NOTE: 登場人物
# # PrefixExpression
# proc parsePrefixExpression(self: Parser): PrefixExpression =
#     var t = self.curToken

#     self.nextToken()

#     Prefixexpression(
#         Token: t,
#         Right: self.parseExpression(PREFIX) # Identifier
#     )

# # NOTE: 登場人物
# # Identifier or PrefixExpression
# proc parseExpression(self: Parser, precedence: Precedence): Identifier|PrefixExpression =
#     # TODO: p.59
#     # Identifier or PrefixExpression
#     case self.curToken.Token.Type
#     of token.IDENT: return self.parseIdentifier()
#     of token.INT: return self.parseIntegerLiteral()
#     of token.BANG: return self.parsePrefixExpression()
#     of token.MINUS: return self.parsePrefixExpression()
#     else:
#         self.noPrefixParseError()
#         return Identifier(kind: TIdentifier.IdentNil)


# # NOTE: 登場人物
# proc parseExpressionStatement(self: Parser): Statement =
#     var statement = Statement(kind: ExpressionStatement, Token: self.curToken)
#     statement.Expression = self.parseExpression(LOWEST) # Identifier

#     # ~ ;
#     if self.peekTokenIs(token.SEMICOLON):
#         self.nextToken()

#     statement


proc parseStatement(self: Parser): PNode =
    case self.curToken.Type
    of token.LET: return self.parseLetStatement()
    # of token.RETURN: return self.parseReturnStatement()
    # else: return self.parseExpressionStatement()
    else: discard

# create AST Root Node
proc parseProgram*(self: Parser): Program =
    result = Program()
    result.statements = newSeq[PNode]()

    while self.curToken.Type != token.EOF:
        let statement = self.parseStatement()
        result.statements.add(statement)
        self.nextToken()


# # proc regiserPrefix(self: Parser, tokenType: TokenType, fn: PrefixParseFn) =
# #     self.prefixParseFns[tokenType] = fn




# proc error*(self: Parser): seq[string] = self.errors
# proc noPrefixParseError(self: Parser) =
#     self.errors.add(fmt"no prefix parse function for {self.curToken.Type}")




proc main() = discard
when isMainModule:
    main()
