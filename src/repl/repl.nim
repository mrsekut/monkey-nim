import
    ../lexer/lexer,
    ../parser/parser,
    ../parser/ast,
    ../evaluator/evaluator,
    ../obj/obj

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

when isMainModule:
    let env = newEnvironment()
    while true:
        stdout.write ">> "
        # let
        var
            line = stdin.readLine()
            l = newLexer(line)
            p = newParser(l)
            program = p.parseProgram()

        if p.errors.len != 0:
            printParserErrors(p.errors)
            continue

        let evaluated = evaluator.eval(program, env)
        if evaluated != nil:
            echo evaluated.inspect()


        # TODO: 問題は読み込み終わってるのにnextTokenが終わらないこと
        # for i in 0..10:
        #     let tok = l.nextToken()
        #     echo tok.Literal