import
    strutils, unittest, strformat, typetraits, typetraits,
    ../src/lexer/lexer,
    ../src/parser/ast,
    ../src/parser/parser,
    ../src/obj/obj,
    ../src/code/code,
    ../src/compiler/compiler,
    ../src/vm/vm


type VmTestCase[T] = ref object of RootObj
    input: string
    expected: T


proc testIntegerObject(expected: int, actual: Object)
proc parse(input: string): PNode
proc runVmTests(tests: seq[VmTestCase])
proc testExpectedObject[T](expected: T, actual: Object)

# implementation


proc testIntegerObject(expected: int, actual: Object) =
    if actual.kind != Integer:
        checkpoint(fmt"object is not Integer. got={actual.kind}")
        fail()
    if actual.IntValue != expected:
        checkpoint(fmt"object has wrong value. got={actual.IntValue}, want={expected}")
        fail()



proc parse(input: string): PNode =
    let
        l = newLexer(input)
        p = newParser(l)
    p.parseProgram()


proc runVmTests(tests: seq[VmTestCase]) =
    for _, test in tests:
        let
            program = parse(test.input) # make an AST
            compiler = newCompiler()
            errCompilr = compiler.compile(program)

        if errCompilr:
            checkpoint(fmt"compiler error")
            fail()

        let vm = newVm(compiler.bytecode())
        vm.runVm()

        # if errVm:
        #     checkpoint("vm error")
        #     fail()

        let stackElem = vm.stackTop()
        testExpectedObject[int](test.expected, stackElem)


proc testExpectedObject[T](expected: T, actual: Object) =
    case expected.type.name:
    of "int":
        testIntegerObject(int(expected), actual)
    else:
        discard



suite "VM":
    test "test integer arithmertic":
        let tests = @[
            VmTestCase[int](input: "1", expected: 1),
            VmTestCase[int](input: "2", expected: 2),
            VmTestCase[int](input: "1 + 2", expected: 2),
        ]
        runVmTests(tests)


