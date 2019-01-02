import ast, sequtils, strformat, typetraits, tables, strutils
import ../lexer/lexer
import ../lexer/token


type
    Parser* = ref object of RootObj
        l: Lexer
        curToken: Token
        peekToken: Token
        errors: seq[string]

        prefixParseFns: Table[TokenType, proc(self: Parser): Identifier]
        # prefixParseFns: Table[TokenType, PrefixParseFn]
        # infixParseFns: Table[TokenType, InfixParseFn]

    PrefixParseFn =  proc(self: Parser): Identifier
    # InfixParseFn = proc(x: Identifier): Identifier

type Precedence = enum
    LOWEST
    # EQUALS,
    # LESSGREATER,j
    # SUM,
    # PRODUCT,
    PREFIX,
    # CALL

# type PrefixType = enum
#     # PLUS,
#     MINUS,
#     NOT

proc error*(self: Parser): seq[string] = self.errors

proc noPrefixParseError(self: Parser) =
    self.errors.add(fmt"no prefix parse function for {self.curToken.Type}")


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

# proc parseIntegerLiteral(self: Parser): Identifier =
#     Identifier(kind: TIdentifier.IntegerLiteral, Token: self.curToken, IntValue: self.curToken.Literal.parseInt)

# proc parsePrefixExpression(self: Parser): PrefixExpression =
#     var t = self.curToken

#     self.nextToken()

#     # let right = self.parseExpression(PREFIX)

#     return Prefixexpression(
#         Token: t,
#         # Right: right
#     )




proc parseExpression(self: Parser, precedence: Precedence): Identifier =
    let prefix = self.prefixParseFns[self.curToken.Type](self)

    # NOTE: nil判定 p.59

    let leftExp = prefix
    # return Identifier(kind: IdentNil)
    return leftExp


    # TODO: p.59
    # case self.curToken.Token.Type
    # of token.IDENT: return self.parseIdentifier()
    # of token.INT: return self.parseIntegerLiteral()
    # # of token.BANG: return self.parsePrefixExpression()
    # # of token.MINUS: return self.parsePrefixExpression()
    # else:
    #     self.noPrefixParseError()
    #     return Identifier(kind: TIdentifier.IdentNil)


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

proc regiserPrefix(self: Parser, tokenType: TokenType, fn: proc(self: Parser): Identifier) =
    self.prefixParseFns[tokenType] = fn

# proc registerInfix(self: Parser, tokenType: TokenType, fn: PrefixParseFn) =
#     self.prefixParseFns[tokenType] = fn

proc newParser*(l: Lexer): Parser =
    let p = Parser(l: l, errors: newSeq[string]())

    p.prefixParseFns = initTable[TokenType, proc(self: Parser): Identifier]()
    p.regiserPrefix(token.IDENT, parseIdentifier)

    p.nextToken()
    p.nextToken()
    p






proc main() = # discard
    let input = """foobar;\0"""

    let l = newLexer(input)
    let p = newParser(l)
    let program = p.parseProgram()

    let statement = program.statements[0]
    echo statement

    let value = statement.Expression.IdentValue
    let literal = statement.Expression.Token.Literal

    echo value
    echo literal
when isMainModule:
    main()
