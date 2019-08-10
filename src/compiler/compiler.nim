import
    ../parser/ast, ../code/code, ../obj/obj

type
    Compiler* = ref object of RootObj
        instructions: Instructions
        constants: seq[Object]

    Bytecode* = ref object of RootObj
        instructions*: Instructions
        constants*: seq[Object]



proc newCompiler*(): Compiler
proc compile*(self: Compiler, node: PNode): bool
proc bytecode*(self: Compiler): Bytecode
proc addConstant(self: Compiler, obj: Object): int
proc emit(self: Compiler, op: Opcode, operands: seq[int] = @[])
proc addInstruction(self: Compiler, ins: seq[byte])


# implementation


proc newCompiler*(): Compiler =
    Compiler(
        instructions: newSeq[byte](),
        constants: newSeq[Object]()
    )


# trueならerr
proc compile*(self: Compiler, node: PNode): bool =
    case node.kind
    of Program:
        for _, s in node.statements:
            var err = self.compile(s)
            if err: return err

    of nkExpressionStatement:
        # TODO: きてない
        var err = self.compile(node.Expression)
        if err: return err
        self.emit(OpPop)

    of nkInfixExpression:
        var err = self.compile(node.InLeft)
        if err: return err
        err = self.compile(node.InRight)
        if err: return err
        case node.InOperator
        of "+":
            self.emit(OpAdd)
        else:
            discard

    of nkIntegerLiteral:
        var integer = Object(kind: Integer, IntValue: node.IntValue)
        self.emit(OpConstant, @[self.addConstant(integer)])

    else:
        discard


proc addConstant(self: Compiler, obj: Object): int =
    self.constants.add(obj)
    return self.constants.len - 1


proc emit(self: Compiler, op: Opcode, operands: seq[int] = @[]) =
    let ins = makeByte(op, operands)
    self.addInstruction(ins)


proc addInstruction(self: Compiler, ins: seq[byte]) =
    self.instructions.add(ins)





proc bytecode*(self: Compiler): Bytecode =
    Bytecode(
        instructions: self.instructions,
        constants: self.constants
    )


proc main() = discard
when isMainModule:
    main()