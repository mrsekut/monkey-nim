import
    ../parser/ast,
    ../obj/obj

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
    else: discard

proc evalStatements(statements: seq[PNode]): Object =
    result = Object()
    for statement in statements:
        result = eval(statement)


# test
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