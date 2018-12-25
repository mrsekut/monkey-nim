import ../lexer/token

# NOTE: conseptまだわかってない
# type
#     Node = concept x
#         x.Token() is Token

#     Statement* = concept x
#         Token is Node
#         x.statementNode()

    # Expression = concept
    #     Node
    #     expresssionNode()

# proc statementNode(self: Statement) = discard
# proc tokenLiteral(self: Statement): string = self.Token.Literal

type Identifier* = ref object of RootObj
    Token*: token.Token
    Value*: string

proc expressionNode(self: Identifier) = discard
proc tokenLiteral(self: Identifier): string = self.Token.Literal

# let =============
# type LetStatement* = ref object of RootObj
#     Token*: token.Token
#     Name*: Identifier
#     # Value: Expression

# proc statementNode(self: LetStatement) = discard
# proc tokenLiteral(self: LetStatement): string = self.Token.Literal


# # return ===========
# type ReturnStatement* = ref object of RootObj
#     Token*: token.Token
#     # ReturnValue: Expression

# proc statementNode(self: ReturnStatement) = discard
# proc tokenLiteral(self: ReturnStatement): string = self.Token.Literal

# type Hoge = enum LetStatement, ReturnStatement


# # root node
# type
#     Statement* = enum LetStatement, ReturnStatement

#     Program* = object of RootObj
#         statements*: seq[Statement]

type
    TStatement* = enum LetStatement, ReturnStatement

    Statement* = object of RootObj
        Token*: token.Token
        case kind*: TStatement
        of LetStatement:
            Name*: Identifier
            Value: string
        of ReturnStatement:
            ReturnValue: string

type Program* = object of RootObj
    statements*: seq[Statement]

proc tokenLiteral[T](self: T): string =
    if self.statements.len > 0:
        return self.statements[0].tokenLiteral()
    else:
        return ""

