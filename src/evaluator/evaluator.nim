import
    ../parser/ast,
    ../obj/obj

let
    TRUE = Object(kind: Boolean, BoolValue: true)
    FALSE = Object(kind: Boolean, BoolValue: false)

proc eval*(self: PNode): Object
proc evalStatements(statements: seq[PNode]): Object

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
        result = Object(kind: Boolean, BoolValue: self.BlValue)
    else: discard

proc evalStatements(statements: seq[PNode]): Object =
    result = Object()
    for statement in statements:
        result = eval(statement)

proc nativeBoolToBooleanObject(input: bool): Object =
    if input: return TRUE
    return FALSE















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