import
    ../src/obj/obj,
    ../src/parser/parser,
    ../src/lexer/lexer,
    ../src/evaluator/evaluator


proc main() =
    # TODO: 恐らくbodyで２つの関数を実行するenvがないので落ちる
    let
        input = """
            let fib = fn(n) {
                if (n < 2) {
                    return n;
                } else {
                    fib(num - 1) + fib(num - 2);
                }
            };
            fib(2);
        """
        l = newLexer(input)
        p = newParser(l)
        program = p.parseProgram()
        env = newEnvironment()

    echo eval(program, env).IntValue


when isMainModule:
    main()
