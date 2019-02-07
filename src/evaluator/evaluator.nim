import
    ../parser/ast,
    ../obj/obj

let
    TRUE* = Object(kind: Boolean, BoolValue: true)
    FALSE* = Object(kind: Boolean, BoolValue: false)
    NULL* = Object(kind: TNull)

proc eval*(self: PNode): Object
proc evalProgram(self: PNode): Object
proc evalBlockStatement(statements: seq[PNode]): Object
proc evalStatements(statements: seq[PNode]): Object
proc nativeBoolToBooleanObject(input: bool): Object
proc evalPrefixExpression(operator: string, right: Object): Object
proc evalBanOperationExpression(right: Object): Object
proc evalMinusPrefixOperatorExpression(right: Object): Object
proc evalInfixExpression(operator: string, left: Object, right: Object): Object
proc evalIntegerInfixExpression(operator: string, left: Object, right: Object): Object
proc evalIfExpression(ie: PNode): Object
proc isTruthy(obj: Object): bool

# implementation

proc eval*(self: PNode): Object =
    case self.kind
    of Program:
        result = evalProgram(self)
    of nkExpressionStatement:
        result = eval(self.Expression)
    of nkIntegerLiteral:
        result = Object(kind: Integer, IntValue: self.IntValue)
    of nkBoolean:
        result = nativeBoolToBooleanObject(self.BlValue)
    of nkPrefixExpression:
        let right = eval(self.PrRight)
        result = evalPrefixExpression(self.PrOperator, right)
    of nkInfixExpression:
        let
            left = eval(self.InLeft)
            right = eval(self.InRight)
        result = evalInfixExpression(self.InOperator, left, right)
    of nkBlockStatement:
        result = evalBlockStatement(self.statements)
    of nkIFExpression:
        result = evalIfExpression(self)
    of nkReturnStatement:
        let val = eval(self.ReturnValue)
        result = Object(kind: ReturnValue, ReValue: val)
    else: discard

proc evalProgram(self: PNode): Object =
    var r: Object
    for s in self.statements:
        r = eval(s)
        if r.kind == ReturnValue:
            return r.ReValue
    return r

proc evalBlockStatement(statements: seq[PNode]): Object =
    var r: Object
    for b in statements:
        r = eval(b)

        if r.kind != TNull and r.myType() == RETURN_VALUE_OBJ:
            return r

    return r

proc evalStatements(statements: seq[PNode]): Object =
    result = Object()
    for statement in statements:
        result = eval(statement)

        if result.kind == ReturnValue:
            return result.ReValue


proc nativeBoolToBooleanObject(input: bool): Object =
    if input: return TRUE
    return FALSE

proc evalPrefixExpression(operator: string, right: Object): Object =
    case operator
    of "!": return evalBanOperationExpression(right)
    of "-": return evalMinusPrefixOperatorExpression(right)
    else: return NULL

proc evalBanOperationExpression(right: Object): Object =
    case right.kind
    of Boolean:
        case right.BoolValue
        of true: result = FALSE
        of false: result = TRUE
    of TNull: result = TRUE
    else: result = FALSE

proc evalMinusPrefixOperatorExpression(right: Object): Object =
    if right.myType() != obj.INTEGER_OBJ:
        return NULL
    let value = right.IntValue
    return Object(kind: Integer, IntValue: -value)

proc evalInfixExpression(operator: string, left: Object, right: Object): Object =
    if (left.myType() == obj.INTEGER_OBJ) and right.myType() == obj.INTEGER_OBJ:
        return evalIntegerInfixExpression(operator, left, right)
    elif (operator == "=="):
        return nativeBoolToBooleanObject(left == right)
    elif (operator == "!="):
        return nativeBoolToBooleanObject(left != right)
    else:
        return NULL

proc evalIntegerInfixExpression(operator: string, left: Object, right: Object): Object =
    let
        leftVal = left.IntValue
        rightVal = right.IntValue

    case operator
    of "+":
        result = Object(kind: Integer, IntValue: leftVal + rightVal)
    of "-":
        result = Object(kind: Integer, IntValue: leftVal - rightVal)
    of "*":
        result = Object(kind: Integer, IntValue: leftVal * rightVal)
    of "/":
        result = Object(kind: Integer, IntValue: (leftVal / rightVal).toInt)
    of "<":
        result = nativeBoolToBooleanObject(leftVal < rightVal)
    of ">":
        result = nativeBoolToBooleanObject(leftVal > rightVal)
    of "==":
        result = nativeBoolToBooleanObject(leftVal == rightVal)
    of "!=":
        result = nativeBoolToBooleanObject(leftVal != rightVal)
    else:
        result = NULL

proc evalIfExpression(ie: PNode): Object =
    let condition = eval(ie.Condition)

    if isTruthy(condition):
        return eval(ie.Consequence.Statements[0])
    elif ie.Alternative != nil:
        return eval(ie.Alternative.Statements[0])
    else: return NULL

proc isTruthy(obj: Object): bool =
    case obj.kind:
    of Boolean:
        case obj.BoolValue
        of false: return false
        of true: return true
    of TNull: return false
    else: return true






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