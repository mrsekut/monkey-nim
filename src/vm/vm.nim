import
    strformat,
    ../compiler/compiler, ../code/code, ../obj/obj

const stackSize = 2048

type VM* = ref object of RootObj
    constants: seq[Object]
    instructions: Instructions
    stack: seq[Object]
    sp: int # top of stack is `stack[sp-1]`


proc newVm*(bytecode: Bytecode): VM
proc stackTop*(self: VM): Object
proc runVm*(self: VM)
proc push(self: VM, o: Object)

# implementation



proc newVm*(bytecode: Bytecode): VM =
    VM(
        constants: bytecode.constants,
        instructions: bytecode.instructions,
        stack: newSeq[Object](),
        sp: 0
    )


proc stackTop*(self: VM): Object =
    if self.sp == 0:
        return nil # TODO:
    self.stack[self.sp-1]


proc runVm*(self: VM) =
    var ip = 0
    while ip < self.instructions.len:
        case Opcode(self.instructions[ip])
        of OpConstant:
            let constIndex = readUint16(self.instructions[ip+1..^1])
            ip += 2
            self.push(self.constants[constIndex])
        else:
            discard
        inc ip


proc push(self: VM, o: Object) =
    if self.sp >= stackSize:
        raise newException(Exception, "stack overflow")

    self.stack.add(o)
    # self.stack[self.sp] = o
    inc self.sp







