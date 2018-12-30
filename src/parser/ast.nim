import ../lexer/token

type Identifier* = ref object of RootObj
    Token*: token.Token
    Value*: string

proc expressionNode(self: Identifier) = discard
proc tokenLiteral(self: Identifier): string = self.Token.Literal
proc astToString(self: Identifier): string = self.Value

type
    TStatement* = enum LetStatement, ReturnStatement, ExpressionStatement, Nil

    Statement* = object of RootObj
        Token*: token.Token

        case kind*: TStatement
        of LetStatement:
            Name*: Identifier
            Value*: Identifier # NOTE: 仮 Expression
        of ReturnStatement:
            ReturnValue*: Identifier # NOTE: 仮 Expression
        of ExpressionStatement:
            Expression*: Identifier # NOTE: 仮 Expression
        of Nil:
            nil

type Program* = object of RootObj
    statements*: seq[Statement]

proc tokenLiteral*(self: Statement): string =
    self.Token.Literal

# proc tokenLiteral*[T](self: T): string =
#     if self.statements.len > 0:
#         return self.statements[0].Token.literal
#     else:
#         return ""

