import ast, sequtils, strformat, typetraits, tables, strutils
import ../lexer/token
import ../lexer/lexer

type
    Parser* = ref object of RootObj
        l: Lexer
        curToken: Token
        peekToken: Token
        errors: seq[string]

        prefixParseFns: Table[TokenType, PrefixParseFn]
        # prefixParseFns: Table[TokenType, proc(self: Parser): Identifier]
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

proc parseExpression(self: Parser, precedence: Precedence): Identifier =
    let prefix = self.prefixParseFns[self.curToken.Type](self)

    # NOTE: nil判定 p.59

    let leftExp = prefix
    # return Identifier(kind: IdentNil)
    return leftExp


proc parseIdentifier(self: Parser): Identifier =
    Identifier(kind: TIdentifier.Ident, Token: self.curToken, IdentValue: self.curToken.Literal)

proc parseIntegerLiteral(self: Parser): Identifier =
    Identifier(kind: TIdentifier.IntegerLiteral, Token: self.curToken, IntValue: self.curToken.Literal.parseInt)

proc parsePrefixExpression(self: Parser): PrefixExpression =
    echo "in parse prefix expression"
    var t = self.curToken

    self.nextToken()
    let right = self.parseExpression(PREFIX)

    return Prefixexpression(
        Token: t,
        Right: right
    )


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

proc regiserPrefix(self: Parser, tokenType: TokenType, fn: PrefixParseFn) =
    self.prefixParseFns[tokenType] = fn

# proc registerInfix(self: Parser, tokenType: TokenType, fn: PrefixParseFn) =
#     self.prefixParseFns[tokenType] = fn

proc newParser*(l: Lexer): Parser =
    let p = Parser(l: l, errors: newSeq[string]())

    p.prefixParseFns = initTable[TokenType, PrefixParseFn]()
    p.regiserPrefix(token.IDENT, parseIdentifier)
    p.regiserPrefix(token.INT, parseIntegerLiteral)
    # p.regiserPrefix(token.BANG, parsePrefixExpression)
    # p.regiserPrefix(token.MINUS, parsePrefixExpression)

    p.nextToken()
    p.nextToken()
    p


proc main() = # discard
    echo " kore"

    type Test = object
        input: string
        operator: string
        integerValue: int

    let testInputs = @[
        Test(input: "!5", operator: "!", integerValue: 5),
        Test(input: "-15", operator: "-", integerValue: 15)
    ]


    for i in testInputs:
        let l = newLexer(i.input)
        let p = newParser(l)
        let program = p.parseProgram()

        # let exp = program.statements[0].Expression
        # echo exp
        # # NOTE:

when isMainModule:
    main()
