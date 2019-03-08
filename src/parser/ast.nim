import
    strformat, typetraits, sequtils, strutils,
    ../lexer/token

type
    PrefixTypes* = enum
        PrPlus,
        PrMinus,
        PrNot

    InfixTypes* = enum
        InPlus,
        InMinus,
        InDivide,
        InMultiply,
        InEq,
        InNot_Eq,
        InGt,
        InLT


    Precedence* = enum
        Lowest,
        Equals,
        Lg,
        Sum,
        Product,
        Prefix,
        Call

type
    TNodeKind* = enum
        # root
        Program

        # Identifier
        nkIdent
        nkIntegerLiteral
        nkBoolean

        # Statement
        nkLetStatement
        nkReturnStatement
        nkExpressionStatement

        # Expression
        nkIFExpression
        nkFunctionLiteral
        nkCallExpression
        nkBlockStatement

        # PrefixExpression
        nkPrefixExpression
        nkInfixExpression

        Nil # TODO: 最終的に消す

type
    PNode* = ref TNode
    TNodeSeq = seq[PNode]
    TNode = object
        Token*: token.Token
        case kind*: TNodeKind
        of Program:
            statements*: seq[PNode]

        of nkIdent:
            IdentValue*: string
        of nkIntegerLiteral:
            IntValue*: int
        of nkBoolean:
            BlValue*: bool

        of nkLetStatement:
            LetName*: PNode
            LetValue*:  PNode
        of nkReturnStatement:
            ReturnValue*: PNode
        of nkExpressionStatement:
            Expression*: PNode

        of nkIFExpression:
            Condition*: PNode
            Consequence*: BlockStatements
            Alternative*: BlockStatements
        of nkFunctionLiteral:
            FnParameters*: seq[PNode] # NOTE: 本来は,seq[nkIdent]
            FnBody*: BlockStatements
        of nkCallExpression:
            Function*: PNode
            Args*: seq[PNode]

        of nkPrefixExpression:
            PrOperator*: string
            PrRight*: PNode
        of nkInfixExpression:
            InLeft*: PNode
            InOperator*: string
            InRight*: PNode

        of Nil: discard
        else: sons: TNodeSeq

    BlockStatements* = ref object
        Token*: token.Token
        Statements*: seq[PNode]

proc expressionNode(self: var PNode)
proc tokenLiteral(self: PNode): string
proc astToString*(self: PNode): string
proc astToString*(self: BlockStatements): string


# implementation

proc expressionNode(self: var PNode) = discard

proc tokenLiteral(self: PNode): string = self.Token.Literal

proc astToString*(self: PNode): string =
    case self.kind:
    of Program:
        result = ""
        for statement in self.statements:
            result = result & statement.astToString()

    of nkIntegerLiteral: result =  self.Token.Literal
    of nkBoolean: result = self.Token.Literal

    of nkLetStatement:
        result = fmt"{self.tokenLiteral()} {self.LetName.Token.Literal} = {self.LetValue.astToString()};"

    of nkReturnStatement:
        result = fmt"{self.tokenLiteral()} {self.ReturnValue.astToString()};"

    of nkExpressionStatement: # TODO: p.53
        result = "ExpressionStatementString dayo"

    of nkIFExpression: # TODO:
        result = "if dayo"

    of nkFunctionLiteral: # TODO:
        result = "function dayo"

    of nkCallExpression:
        var args = newSeq[string]()
        for arg in self.Args:
            args.add(arg.astToString())

        result = fmt"{self.Function.Token.Literal}({ args.foldr(a & ',' & ' ' & b) })"

    of nkPrefixExpression:
        let
            operator = self.PrOperator
            right = self.PrRight.astToString()
        result = fmt"({operator}{right})"

    of nkInfixExpression:
        let
            left = self.InLeft.astToString()
            operator = self.InOperator
            right = self.InRight.astToString()
        result = fmt"({left} {operator} {right})"

    else: result = self.Token.Literal

proc astToString*(self: BlockStatements): string =
    var body: seq[string]

    for b in self.Statements:
        body.add(b.astToString())

    result = body.join(" ")


proc main() = discard
when isMainModule:
    main()
