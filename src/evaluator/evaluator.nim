import
    ../parser/ast,
    ../obj/obj

let
    TRUE = Object(kind: Boolean, BoolValue: true)
    FALSE = Object(kind: Boolean, BoolValue: false)
    NULL = Object(kind: TNull)

proc eval*(self: PNode): Object
proc evalStatements(statements: seq[PNode]): Object
proc nativeBoolToBooleanObject(input: bool): Object
proc evalPrefixExpression(operator: string, right: Object): Object
proc evalBanOperationExpression(right: Object): Object

# implementation

proc eval*(self: PNode): Object =
    case self.kind
    of Program:
        result = evalStatements(self.statements)
    of nkExpressionStatement:
        result = eval(self.Expression)
    of nkIntegerLiteral:
        result = Object(kind: Integer, IntValue: self.IntValue)
    of nkBoolean:
        result = nativeBoolToBooleanObject(self.BlValue)
    of nkPrefixExpression:
        let right = eval(self.PrRight)
        result = evalPrefixExpression(self.PrOperator, right)
    else: discard

proc evalStatements(statements: seq[PNode]): Object =
    result = Object()
    for statement in statements:
        result = eval(statement)

proc nativeBoolToBooleanObject(input: bool): Object =
    if input: return TRUE
    return FALSE

proc evalPrefixExpression(operator: string, right: Object): Object =
    case operator
    of "!": return evalBanOperationExpression(right)
    else: return NULL

proc evalBanOperationExpression(right: Object): Object =
    case right.kind
    of Boolean:
        case right.BoolValue
        of true: result = FALSE
        of false: result = TRUE
    of TNull: result = TRUE
    else: result = FALSE

# test
# =================
import
    ../parser/ast,
    ../parser/parser,
    ../lexer/lexer

proc testEval(input: string): Object =
    let
        l = newLexer(input)
        p = newParser(l)
        program = p.parseProgram()

    return eval(program)

proc main() =  #discard
    type Test = object
        input: string
        expected: int

    let testInput = @[
            Test(input: """5\0""", expected: 5),
            Test(input: """10\0""", expected: 10)]

    for t in testInput:
        let evaluated = testEval(t.input)
        echo repr evaluated

when isMainModule:
    main()