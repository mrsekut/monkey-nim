import strformat, typetraits
import ../lexer/token

# type Identifier*[T] = ref object of RootObj
#     Token*: token.Token
#     Value*: T

# proc expressionNode(self: Identifier) = discard
# proc tokenLiteral(self: Identifier): string = self.Token.Literal
# proc astToString(self: Identifier): string =
#     if self.Value.type.name == "string":
#         return self.Value
#     elif self.Value.type.name == "int":
#         return self.Token.Literal

# NOTE: 一つのオブジェクトしにしたもの =========
# Error: 同じ名前のプロパティを作れない(Value)
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
# ここまで ============================


# NOTE: 本と同じように一つずつ作ったもの。
# Error: case..ofを使うメソッドの返り値の型を指定できない
# type Identifier* = ref object of RootObj
#     Token*: token.Token
#     Value*: string

# proc expressionNode(self: Identifier) = discard
# proc tokenLiteral(self: Identifier): string = self.Token.Literal
# proc astToString(self: Identifier): string = self.Value


# type IntegerLiteral* = ref object of RootObj
#     Token*: token.Token
#     Value*: int64

# proc expressionNode(self: IntegerLiteral) = discard
# proc tokenLiteral(self: IntegerLiteral): string = self.Token.Literal
# proc astToString(self: IntegerLiteral): string = self.Token.Literal
# ここまで ============================


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

