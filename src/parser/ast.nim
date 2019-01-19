import
    strformat, typetraits,
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
        nkBlockStatement

        # PrefixExpression
        nkPrefixExpression
        nkInfixExpression

        Nil # TODO: 最終的に消す


    TNodeKinds = set[TNodeKind]

type
    PNode* = ref TNode
    TNodeSeq = seq[PNode]
    TNode = object
        Token*: token.Token
        case kind*: TNodeKind
        of nkIdent:
            IdentValue*: string
        of nkIntegerLiteral:
            IntValue*: int
        of nkBoolean:
            BlValue*: bool

        of nkLetStatement:
            Name*: PNode
            Value*:  PNode
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
proc astToString(self: PNode): string
proc astToString(self: BlockStatements): string


# implementation

proc expressionNode(self: var PNode) = discard

proc tokenLiteral(self: PNode): string = self.Token.Literal

proc astToString(self: PNode): string =
    case self.kind:
    of nkIntegerLiteral: result =  self.Token.Literal
    of nkBoolean: result = self.Token.Literal

    of nkLetStatement:
        # let name = <expression>;
        result = fmt"{self.tokenLiteral()} {self.Name.Token.Literal} = {self.Value.Token.Literal};"

    of nkReturnStatement: # TODO: p.53
        result = fmt"{self.tokenLiteral()} returnValueString;"

    of nkExpressionStatement: # TODO: p.53
        result = "ExpressionStatementString dayo"

    of nkIFExpression: # TODO:
        result = "if dayo"

    of nkFunctionLiteral: # TODO:
        result = "function dayo"

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

proc astToString(self: BlockStatements): string =
    #  TODO: 仮
    echo "block sttement"

# Program
type
    Program* = object of RootObj
        statements*: seq[PNode]

proc astToString*(self: Program): string =
    result = ""
    for statement in self.statements:
        result = result & statement.astToString()


proc main() = discard
when isMainModule:
    main()
