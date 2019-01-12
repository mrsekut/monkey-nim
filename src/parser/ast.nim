import
    strformat, typetraits,
    ../lexer/token

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
            Name*: PNode # Identifier
            Value*:  PNode # Identifier
        of nkReturnStatement:
            ReturnValue*: PNode # Identifier
        of nkExpressionStatement:
            Expression*: PNode # Identifier
        of nkPrefixExpression:
            Right: TNodeSeq
        of Nil:
            discard
        else:
            sons: TNodeSeq

proc expressionNode(self: var PNode)
proc tokenLiteral(self: PNode): string
# proc astToString(self: PNode): string


# implementation

proc expressionNode(self: var PNode) = discard

proc tokenLiteral(self: PNode): string = self.Token.Literal

# proc astToString(self: PNode): string =
#     case self.kind:
#     of Ident: result =  self.IdentValue
#     of nkIntegerLiteral: result =  self.Token.Literal
#     of nkLetStatement:
#         # let name = <expression>;
#         # result = fmt"{self.tokenLiteral()} {$self.Name} = {$self.Value};"
#         result = "nkLetStatement dayo"
#         # result = fmt"{self.tokenLiteral()} {self.Name.astToString()} = {self.Value.astToString()};"

#         # NOTE: nilあり版
#         # o = fmt"{self.tokenLiteral()} {self.Name.astToString()} = "
#         # if self.Value != nil:
#         #     o = o & self.Value.astToString()
#         # result = o & ";"

#     of nkReturnStatement:
#         # return hoge;
#         # NOTE: 仮 p.53
#         result = fmt"{self.tokenLiteral()}  returnValueString;"

#         # self.ReturnValue.astToString()

#     of nkExpressionStatement:
#         # NOTE: 仮 p.53
#         result = "ExpressionStatementString"

#     # of nkPrefixExpression:
#     #     result = fmt"({self.Token.Literal}{self.Right.astToString()})"
#         # result = fmt"({self.Token.Literal}{self.Right.astToString()})"

#     else: discard

# Program
type
    Program* = object of RootObj
        statements*: seq[PNode]

# proc astToString*(self: Program): string =
#     result = ""
#     for statement in self.statements:
#         result = result & statement.astToString()



# ============================
# ============================
# ============================
# NOTE: 修正
# ============================
# ============================
# ============================

# type
#     TIdentifier* = enum Ident, IntegerLiteral, IdentNil

#     Identifier* = object of RootObj
#         Token*: token.Token
#         case kind*: TIdentifier
#         of Ident:
#             IdentValue*: string
#         of IntegerLiteral:
#             IntValue*: int
#         of IdentNil:
#             discard

# proc expressionNode(self: Identifier) = discard
# proc tokenLiteral(self: Identifier): string = self.Token.Literal
# proc astToString(self: Identifier): string =
#     case self.kind:
#     of Ident:
#         return self.IdentValue
#     of IntegerLiteral:
#         return self.Token.Literal
#     else: discard

# type PrefixExpression* = object of RootObj
#     Token*: token.Token
#     Right*: Identifier

# proc expressionNode(self: PrefixExpression) = discard
# proc tokenLiteral(self: PrefixExpression): string = self.Token.Literal
# proc astToString(self: PrefixExpression): string =
#     fmt"({self.Token.Literal}{self.Right.astToString()})"



# Statement
# type
#     TStatement* = enum LetStatement, ReturnStatement, ExpressionStatement, Nil

#     Statement* = object of RootObj
#         Token*: token.Token

#         case kind*: TStatement
#         of LetStatement:
#             Name*: Identifier
#             Value*: Identifier
#         of ReturnStatement:
#             ReturnValue*: Identifier
#         of ExpressionStatement:
#             Expression*: Identifier
#         of Nil:
#             nil

# proc tokenLiteral*(self: Statement): string =
#     self.Token.Literal

# proc astToString(self: Statement): string =
#     case self.kind
#     of LetStatement:
#         # let name = <expression>;
#         result = fmt"{self.tokenLiteral()} {self.Name.astToString()} = {self.Value.astToString()};"

#         # NOTE: nilあり版
#         # o = fmt"{self.tokenLiteral()} {self.Name.astToString()} = "
#         # if self.Value != nil:
#         #     o = o & self.Value.astToString()
#         # result = o & ";"

#     of ReturnStatement:
#         # return hoge;
#         # NOTE: 仮 p.53
#         result = fmt"{self.tokenLiteral()}  returnValueString;"

#         # self.ReturnValue.astToString()

#     of ExpressionStatement:
#         # NOTE: 仮 p.53
#         result = "ExpressionStatementString"

#     of Nil:
#         discard



# # Program
# type Program* = object of RootObj
#     statements*: seq[Statement]

# proc astToString*(self: Program): string =
#     var o = ""
#     for statement in self.statements:
#         o = o & statement.astToString()

#     return o

