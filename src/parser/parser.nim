import
    ast, sequtils, strformat, typetraits, tables, strutils,
    ../lexer/lexer, ../lexer/token


type
    PrefixType = enum
        # PLUS,
        MINUS,
        NOT

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


proc newParser*(l: Lexer): Parser
proc nextToken(self: Parser)
proc curTokenIs(self: Parser, t: TokenType): bool
proc peekTokenIs(self: Parser, t: TokenType): bool
proc peekError(self: Parser, t: token.TokenType)
proc expectPeek(self: Parser, t: token.TokenType): bool

proc parseLetStatement(self: Parser): PNode
proc parseReturnStatement(self: Parser): PNode
proc parseIdentifier(self: Parser): PNode
proc parseIntegerLiteral(self: Parser): PNode
proc parsePrefixExpression(self: Parser): PNode
proc parseExpressionStatement(self: Parser, precedence: Precedence): PNode
proc parseStatement(self: Parser): PNode

proc parseProgram*(self: Parser): Program
proc error*(self: Parser): seq[string]
proc noPrefixParseError(self: Parser)

# implementation

proc newParser*(l: Lexer): Parser =
    result = Parser(l: l, errors: newSeq[string]())
    result.nextToken()
    result.nextToken()

proc nextToken(self: Parser) =
    self.curToken = self.peekToken
    self.peekToken = self.l.nextToken()

proc curTokenIs(self: Parser, t: TokenType): bool =
    self.curToken.Type == t
proc peekTokenIs(self: Parser, t: TokenType): bool =
    self.peekToken.Type == t

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


proc parseLetStatement(self: Parser): PNode =
    result = PNode(kind: nkLetStatement, Token: self.curToken)

    # ident
    if not self.expectPeek(token.IDENT): return PNode(kind: Nil)
    result.Name = PNode(
                    kind: nkIdent,
                    Token: self.curToken,
                    IdentValue: self.curToken.Literal
                  )

    # =
    if not self.expectPeek(token.ASSIGN): return PNode(kind: Nil)

    # ~ ;
    while not self.curTokenIs(token.SEMICOLON):
        self.nextToken()

proc parseReturnStatement(self: Parser): PNode =
    result = PNode(kind: nkReturnStatement, Token: self.curToken)
    self.nextToken()

    # ~ ;
    while not self.curTokenIs(token.SEMICOLON):
        self.nextToken()

proc parseIdentifier(self: Parser): PNode =
    PNode(
        kind: nkIdent,
        Token: self.curToken,
        IdentValue: self.curToken.Literal)

proc parseIntegerLiteral(self: Parser): PNode =
    PNode(
        kind: nkIntegerLiteral,
        Token: self.curToken,
        IntValue: self.curToken.Literal.parseInt)

proc parsePrefixExpression(self: Parser): PNode =
    let prefix = self.curToken.Token
    # var prefix: PrefixType
    # case self.curToken.Token.Type
    # of token.BANG: prefix = PrefixType.NOT
    # of token.MINUS: prefix = PrefixType.MINUS
    # else: discard

    self.nextToken()

    let right = self.parseExpressionStatement(PREFIX)
    PNode(
        kind: nkPrefixExpression,
        Token: prefix,
        Right: right
    )

proc parseExpressionStatement(self: Parser, precedence: Precedence): PNode =
    case self.curToken.Token.Type
    of token.IDENT: return self.parseIdentifier()
    of token.INT: return self.parseIntegerLiteral()
    of token.BANG: return self.parsePrefixExpression()
    of token.MINUS: return self.parsePrefixExpression()
    else: self.noPrefixParseError()


proc parseStatement(self: Parser): PNode =
    case self.curToken.Type
    of token.LET: return self.parseLetStatement()
    of token.RETURN: return self.parseReturnStatement()
    else: return self.parseExpressionStatement(LOWEST)

# create AST Root Node
proc parseProgram*(self: Parser): Program =
    result = Program()
    result.statements = newSeq[PNode]()

    while self.curToken.Type != token.EOF:
        let statement = self.parseStatement()
        result.statements.add(statement)
        self.nextToken()


proc error*(self: Parser): seq[string] = self.errors
proc noPrefixParseError(self: Parser) =
    self.errors.add(fmt"no prefix parse function for {self.curToken.Type}")


proc main() = discard
when isMainModule:
    main()
