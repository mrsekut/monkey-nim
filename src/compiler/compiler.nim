import
    ../parser/ast, ../code/code, ../obj/obj

type
    Compiler* = ref object of RootObj
        instructions: Instructions
        constants: seq[Object]

    Bytecode = ref object of RootObj
        instructions: Instructions
        constants: seq[Object]




proc newCompiler*(self: Compiler): Compiler =
    Compiler(
        # instructions: Instructions(),
        constants: newSeq[Object]()
    )

proc compile*(self: Compiler, node: PNode) =
    discard


proc bytecode*(self: Compiler): Bytecode =
    Bytecode(
        instructions: self.instructions,
        constants: self.constants
    )
