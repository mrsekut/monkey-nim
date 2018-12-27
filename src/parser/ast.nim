import ../lexer/token

type Identifier* = ref object of RootObj
    Token*: token.Token
    Value*: string

proc expressionNode(self: Identifier) = discard
proc tokenLiteral(self: Identifier): string = self.Token.Literal

type
    TStatement* = enum LetStatement, ReturnStatement, Nil

    Statement* = object of RootObj
        Token*: token.Token

        case kind*: TStatement
        of LetStatement:
            Name*: Identifier
            Value: string
        of ReturnStatement:
            ReturnValue: string
        of Nil:
            nil

type Program* = object of RootObj
    statements*: seq[Statement]

proc tokenLiteral[T](self: T): string =
    if self.statements.len > 0:
        return self.statements[0].tokenLiteral()
    else:
        return ""

