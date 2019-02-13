import
    strformat,
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

proc isError(self: Object): bool
proc newError(format: string, right: ObjectType): Object
proc newError(format: string, operator: string, right: ObjectType ): Object
proc newError(format: string, left: ObjectType, operator: string, right: ObjectType ): Object


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
        if isError(right): return right
        result = evalPrefixExpression(self.PrOperator, right)
    of nkInfixExpression:
        let
            left = eval(self.InLeft)
            right = eval(self.InRight)
        if isError(right): return right
        if isError(left): return left
        result = evalInfixExpression(self.InOperator, left, right)
    of nkBlockStatement:
        result = evalBlockStatement(self.statements)
    of nkIFExpression:
        result = evalIfExpression(self)
    of nkReturnStatement:
        let val = eval(self.ReturnValue)
        if isError(val): return val
        result = Object(kind: ReturnValue, ReValue: val)
    else: discard

proc evalProgram(self: PNode): Object =
    var r: Object
    for s in self.statements:
        r = eval(s)
        if r.kind == ReturnValue:
            return r.ReValue
        elif r.kind == Error:
            return r
    return r

proc evalBlockStatement(statements: seq[PNode]): Object =
    var r: Object
    for b in statements:
        r = eval(b)

        if r.kind != TNull:
            if r.myType() == RETURN_VALUE_OBJ or r.myType() == ERROR_OBJ:
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
    else: return newError("unknown operator: ", operator, right.myType())

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
        return newError("unknown operator: -", right.myType())
    let value = right.IntValue
    return Object(kind: Integer, IntValue: -value)

proc evalInfixExpression(operator: string, left: Object, right: Object): Object =
    if left.myType() == obj.INTEGER_OBJ and right.myType() == obj.INTEGER_OBJ:
        return evalIntegerInfixExpression(operator, left, right)
    elif operator == "==":
        return nativeBoolToBooleanObject(left == right)
    elif operator == "!=":
        return nativeBoolToBooleanObject(left != right)
    elif left.myType() != right.myType():
        return newError("type mismatch: ", left.myType(), operator, right.myType())
    else:
        return newError("unknown operator: ", left.myType(), operator, right.myType())

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
        result = newError("unknown operator: ", left.myType(), operator, right.myType())

proc evalIfExpression(ie: PNode): Object =
    let condition = eval(ie.Condition)
    if isError(condition): return condition

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


proc isError(self: Object): bool =
    self.kind == Error

proc newError(format: string, right: ObjectType): Object =
    Object(
        kind: Error,
        ErrMessage: fmt"{format}{right}")

proc newError(format: string, operator: string, right: ObjectType ): Object =
    Object(
        kind: Error,
        ErrMessage: fmt"2{format}{right}{operator}")

proc newError(format: string, left: ObjectType, operator: string, right: ObjectType ): Object =
    Object(
        kind: Error,
        ErrMessage: fmt"{format}{left} {operator} {right}")




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
        expected: string

    let testInput = @[
            Test(input: """5 + true;\0""",
                    expected: "type mismatch: INTEGER + BOOLEAN"),
            Test(input: """5 + true; 5;\0""",
                    expected: "type mismatch: INTEGER + BOOLEAN"),
            Test(input: """-true;\0""",
                    expected: "unknown operator: -BOOLEAN"),
            Test(input: """true + false;\0""",
                    expected: "unknown operator: BOOLEAN + BOOLEAN"),
            Test(input: """5; true + false; 5;\0""",
                    expected: "unknown operator: BOOLEAN + BOOLEAN"),
            Test(input: """if (10 > 1) { true + false; }\0""",
                    expected: "unknown operator: BOOLEAN + BOOLEAN"),
            Test(input: """
                    if (10 > 1) {
                        if(10 > 1) {
                            return true + false;
                        }
                        return 1;
                    }
                \0""",
                    expected: "unknown operator: BOOLEAN + BOOLEAN"),
        ]

    for t in testInput:
        let evaluated = testEval(t.input)
        echo evaluated.ErrMessage

when isMainModule:
    main()