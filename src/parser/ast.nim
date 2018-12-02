import ../lexer/token

# NOTE: conseptまだわかってない
type Node = concept x
    x.Tokenliteral() is string

type Statement = concept
    Node
    statementNode()

type Expression = concept
    Node
    expresssionNode()


type Program* = object of RootObj
    statements: seq[Statement] # TODO:

proc tokenLiteral[Statement](self: Statement): string =
    if self.statements.len > 0:
        return self.statements[0].tokenLiteral()
    else:
        return ""


type Identifier = ref object of RootObj
    Token: token.Token
    Value: string

type LetStatement = ref object of RootObj
    Token: token.Token
    Name: Identifier
    Value: Expression

proc statementNode(self: LetStatement) =
    discard

proc tokenLiteral(self: LetStatement): string =
    self.Token.Literal


proc expressionNode(self: Identifier) =
    discard

proc tokenLiteral(self: Identifier): string =
    self.Token.Literal
