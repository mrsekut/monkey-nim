# import
#     unittest,
#     ../src/parser/parser,
#     ../src/lexer/lexer,
#     ../src/obj/obj

# proc testEvalIntegerExpression(): bool
# proc testEval(input: string): Object
# proc testIntegerObject(obj: Object, expexted: int): bool

# proc testIntegerObject(obj: Object, expexted: int): bool =
#     if(obj.kind ==  )

# proc testEvalIntegerExpression(): bool =
#     type Test = object
#         input: string
#         expected: int

#     let testInput = @[
#             Test(input: "5", expected: 5),
#             Test(input: "10", expected: 10)]

#     for t in testInput:
#         let evaluated = testEval(t.input)
#         testIntegerObject(evaluated, t.expected)

# proc testEval(input: string): Object =
#     let
#         l = newLexer(input)
#         p = newParser(l)
#         program = p.parseProgram()

#     return Eval(program)

# suite "REPL":
#     test "test IntegerObject":
#         echo "hello"

# #         let input = """
# #             let x = 5;
# #             let y = 10;
# #             let foobar = 838383;\0
# #         """

# #         let l = newLexer(input)
# #         let p = newParser(l)

# #         let program = p.parseProgram()
# #         checkParserError(p)
# #         check(program.statements.len == 3)

# #         let expects = @["x", "y", "foobar"]

# #         for i in 0..<program.statements.len:
# #             let statement = program.statements[i]
# #             check(statement.LetName.IdentValue == expects[i])
