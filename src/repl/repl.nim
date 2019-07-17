import
    strformat,
    ../lexer/lexer,
    ../parser/parser,
    ../parser/ast,
    ../evaluator/evaluator,
    ../obj/obj,
    ../compiler/compiler,
    ../vm/vm


const MONKEY_FACE = """
    ^                      _______
    |                     < Error!! >
    |                /\    --------
    |       /\      /  \  /
    |      /  \____/    \     _
    |     /              \    /|
    |    /    X   X       \  /
    |   /                  \/
    |------------------------------->
"""


proc printParserErrors(errors: seq[string]) =
    echo MONKEY_FACE
    for e in errors: echo e


# when isMainModule:
proc repl*() =
    let env = newEnvironment()
    while true:
        stdout.write ">> "
        let
            line = stdin.readLine()
            l = newLexer(line)
            p = newParser(l)
            program = p.parseProgram()

        if p.errors.len != 0:
            printParserErrors(p.errors)
            continue

        # compiler
        let
            comp = newCompiler()
            errComp = comp.compile(program)

        if errComp:
            echo fmt"Woops! Compilation failed"

        let machine = newVm(comp.bytecode())
        machine.runVm()
        echo machine.stackTop().inspect()

        # interpreter
        # let evaluated = evaluator.eval(program, env)
        # if evaluated != nil:
        #     echo evaluated.inspect()