import
    strformat,
    ../parser/ast,
    ../obj/obj

let
    TRUE* = Object(kind: Boolean, BoolValue: true)
    FALSE* = Object(kind: Boolean, BoolValue: false)
    NULL* = Object(kind: TNull)

proc eval*(self: PNode, env: Environment): Object
proc evalProgram(self: PNode, env: Environment): Object
proc evalIdentifier(self: PNode, env: Environment): Object
proc evalBlockStatement(statements: seq[PNode], env: Environment): Object
proc nativeBoolToBooleanObject(input: bool): Object
proc evalPrefixExpression(operator: string, right: Object): Object
proc evalBanOperationExpression(right: Object): Object
proc evalMinusPrefixOperatorExpression(right: Object): Object
proc evalInfixExpression(operator: string, left: Object, right: Object): Object
proc evalIntegerInfixExpression(operator: string, left: Object, right: Object): Object
proc evalIfExpression(ie: PNode, env: Environment): Object
proc isTruthy(obj: Object): bool

proc isError(self: Object): bool
proc newError(format: string, right: ObjectType): Object
proc newError(format: string, operator: string, right: ObjectType ): Object
proc newError(format: string, left: ObjectType, operator: string, right: ObjectType ): Object


# implementation

proc eval*(self: PNode, env: Environment): Object =
    case self.kind
    of Program:
        result = evalProgram(self, env)
    of nkExpressionStatement:
        result = eval(self.Expression, env)
    of nkIntegerLiteral:
        result = Object(kind: Integer, IntValue: self.IntValue)
    of nkBoolean:
        result = nativeBoolToBooleanObject(self.BlValue)
    of nkPrefixExpression:
        let right = eval(self.PrRight, env)
        if isError(right): return right
        result = evalPrefixExpression(self.PrOperator, right)
    of nkInfixExpression:
        let
            left = eval(self.InLeft, env)
            right = eval(self.InRight, env)
        if isError(right): return right
        if isError(left): return left
        result = evalInfixExpression(self.InOperator, left, right)
    of nkBlockStatement:
        result = evalBlockStatement(self.statements, env)
    of nkIFExpression:
        result = evalIfExpression(self, env)
    of nkReturnStatement:
        let val = eval(self.ReturnValue, env)
        if isError(val): return val
        result = Object(kind: ReturnValue, ReValue: val)
    of nkLetStatement:
        let val = eval(self.LetValue, env)
        if isError(val): return val
        return env.set(self.LetName.Token.Literal, val)
    of nkIdent:
        return evalIdentifier(self, env)
    else: discard

proc evalIdentifier(self: PNode, env: Environment): Object =
    let val = env.get(self.IdentValue)
    return val

proc evalProgram(self: PNode, env: Environment): Object =
    var r: Object
    for s in self.statements:
        r = eval(s, env)
        if r.kind == ReturnValue:
            return r.ReValue
        elif r.kind == Error:
            return r
    return r

proc evalBlockStatement(statements: seq[PNode], env: Environment): Object =
    var r: Object
    for b in statements:
        r = eval(b, env)

        if r.kind != TNull:
            if r.myType() == RETURN_VALUE_OBJ or r.myType() == ERROR_OBJ:
                return r

    return r

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

proc evalIfExpression(ie: PNode, env: Environment): Object =
    let condition = eval(ie.Condition, env)
    if isError(condition): return condition

    if isTruthy(condition):
        return eval(ie.Consequence.Statements[0], env)
    elif ie.Alternative != nil:
        return eval(ie.Alternative.Statements[0], env)
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
        env = newEnvironment()

    return eval(program, env)

proc main() =  #discard
    type Test = object
        input: string
        expected: string

    let testInput = @[
            Test(input: """let a = 5; a;\0""", expected: "5"),
            Test(input: """let a = 5 * 5; 25;\0""", expected: "25"),
            Test(input: """let a = 5; let b = a; b;\0""", expected: "5"),
            Test(input: """let a = 5; b = a; let c = a + b + 5; c;\0""", expected: "15"),
        ]

    for t in testInput:
        let evaluated = testEval(t.input)
        echo repr evaluated.IntValue
        # repr t.expected

when isMainModule:
    main()