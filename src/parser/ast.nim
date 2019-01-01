import strformat, typetraits
import ../lexer/token

type
    TIdentifier* = enum Ident, IntegerLiteral

    Identifier* = object of RootObj
        Token*: token.Token
        case kind*: TIdentifier
        of Ident:
            IdentValue*: string
        of IntegerLiteral:
            IntValue*: int

proc expressionNode(self: Identifier) = discard
proc tokenLiteral(self: Identifier): string = self.Token.Literal
proc astToString(self: Identifier): string =
    case self.kind:
    of Ident:
        return self.IdentValue
    of IntegerLiteral:
        return self.Token.Literal


# Statement
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

proc tokenLiteral*(self: Statement): string =
    self.Token.Literal

proc astToString(self: Statement): string =
    echo "kore", $self.kind
    case self.kind
    of LetStatement:
        # let name = <expression>;
        result = fmt"{self.tokenLiteral()} {self.Name.astToString()} = {self.Value.astToString()};"

        # NOTE: nilあり版
        # o = fmt"{self.tokenLiteral()} {self.Name.astToString()} = "
        # if self.Value != nil:
        #     o = o & self.Value.astToString()
        # result = o & ";"

    of ReturnStatement:
        # return hoge;
        # NOTE: 仮 p.53
        result = fmt"{self.tokenLiteral()}  returnValueString;"

        # self.ReturnValue.astToString()

    of ExpressionStatement:
        # NOTE: 仮 p.53
        result = "ExpressionStatementString"

    of Nil:
        discard



# Program
type Program* = object of RootObj
    statements*: seq[Statement]

proc astToString*(self: Program): string =
    echo "program ", self.statements
    var o = ""
    for statement in self.statements:
        o = o & statement.astToString()

    return o

