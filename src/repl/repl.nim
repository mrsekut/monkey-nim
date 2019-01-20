import ../lexer/lexer, ../parser/parser, ../parser/ast

const MONKEY_FACE = """           __,__
   .--.  .-'     '-.  .--.
  / .. \/  .-. .-.  \/ .. \
 | |  '|  /   Y   \  |'  | |
 | \   \  \ 0 | 0 /  /   / |
  \ '- ,\.-'''''''-./, -' /
   ''-' /_   ^ ^   _\ '-''
       |  \._   _./  |
       \   \ '~' /   /
        '._ '-=-' _.'
           '-----'
"""

proc printParserErrors(errors: seq[string]) =
    echo MONKEY_FACE
    for e in errors: echo e

proc start() =
    echo "hello"
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

        echo program.astToString()


proc main() = start()
when isMainModule:
    main()