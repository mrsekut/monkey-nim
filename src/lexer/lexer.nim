type Lexer = ref object of RootObj
    input: string
    position: int
    readPosition: int
    ch: char


proc readNextChar(this: Lexer) =
    if this.readPosition >= len(this.input):
        this.ch = ' '
    else:
        this.ch = this.input[this.readPosition]
    this.position = this.readPosition
    this.readPosition += 1


proc newLexer(input: string): Lexer =
    var l = Lexer(input: input)
    l.readNextChar()
    return l







proc main() =
  block:
    var l = newLexer("let test = 2")
    echo l.ch
    l.readNextChar()
    echo l.ch


when isMainModule:
  main()