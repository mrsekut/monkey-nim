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

        # Statement
        nkLetStatement
        nkReturnStatement
        nkExpressionStatement

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
        of nkLetStatement:
            Name*: PNode
            Value*:  PNode
        of nkReturnStatement:
            ReturnValue*: PNode
        of nkExpressionStatement:
            Expression*: PNode
        of nkPrefixExpression:
            Right*: PNode # TODO: name
        of nkInfixExpression:
            InLeft*: PNode
            Operator*: string
            InRight*: PNode # TODO: name
        of Nil:
            discard
        else:
            sons: TNodeSeq

proc expressionNode(self: var PNode)
proc tokenLiteral(self: PNode): string
proc astToString(self: PNode): string


# implementation

proc expressionNode(self: var PNode) = discard

proc tokenLiteral(self: PNode): string = self.Token.Literal

proc astToString(self: PNode): string =
    case self.kind:
    # of Ident: result =  self.IdentValue
#     of nkIntegerLiteral: result =  self.Token.Literal
    of nkLetStatement:
        # let name = <expression>;
        result = fmt"{self.tokenLiteral()} {self.Name.Token.Literal} = {self.Value.Token.Literal};"

    of nkReturnStatement:
        # return hoge;
        # NOTE: 仮 p.53
        result = fmt"{self.tokenLiteral()}  returnValueString;"

#         # self.ReturnValue.astToString()

    of nkExpressionStatement:
#         # NOTE: 仮 p.53
        result = "ExpressionStatementString dayo"

#     # of nkPrefixExpression:
#     #     result = fmt"({self.Token.Literal}{self.Right.astToString()})"
#         # result = fmt"({self.Token.Literal}{self.Right.astToString()})"

#     # of nkInfixExpression:
    else:
        result = "仮astToString"

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
