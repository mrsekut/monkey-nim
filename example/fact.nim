import
    ../src/obj/obj,
    ../src/parser/parser,
    ../src/lexer/lexer,
    ../src/evaluator/evaluator


proc main() =
    let
        input = """
            let fact = fn(n) {
                if (n == 0) {
                    return 1;
                }
                if (n == 1) {
                    return 1;
                }
                return n * fact(n-1);
            };

            fact(6)
        """
        l = newLexer(input)
        p = newParser(l)
        program = p.parseProgram()
        env = newEnvironment()
    echo eval(program, env).IntValue


when isMainModule:
    main()
