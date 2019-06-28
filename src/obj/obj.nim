import
    strformat, tables, sequtils,
    ../parser/ast


type
    TObjectKind* = enum
        Integer
        String
        Boolean
        TNull
        ReturnValue
        Function
        Error

    Environment* = ref object of RootObj
        store: Table[string, Object]
        outer: Environment

    ObjectType* = enum
        INTEGER_OBJ = "INTEGER"
        STRING_OBJ = "STRING"
        BOOLEAN_OBJ = "BOOLEAN"
        NULL_OBJ = "NULL"
        RETURN_VALUE_OBJ = "RETURN_VALUE"
        FUNCTION_OBJ = "FUNCTION"
        ERROR_OBJ="ERROR_OBJ"

    Object* = ref TObject
    TObject = object
        case kind*: TObjectKind
        of Integer:
            IntValue*: int
        of String:
            StringValue*: string
        of Boolean:
            BoolValue*: bool
        of TNull:
            discard
        of ReturnValue:
            ReValue*: Object
        of Function:
            Parameters*: seq[PNode]
            Body*: BlockStatements
            Env*: Environment
        of Error:
            ErrMessage*: string
        else: discard


proc inspect*(self: Object): string
proc myType*(self: Object): ObjectType


proc inspect*(self: Object): string =
    case self.kind:
    of Integer:
        result = $self.IntValue
    of String:
        result = $self.StringValue
    of Boolean:
        result = $self.BoolValue
    of TNull:
        result = "null"
    of ReturnValue:
        result = self.ReValue.inspect()
    of Function:
        var params: seq[string]
        for p in self.Parameters:
            params.add(p.astToString())
        # NOTE:
        result = fmt"fn ({params}) " & "{" & fmt"{'\n'} {self.Body.astToString()} {'\n'}" & "}"
    of Error:
        result = fmt"ERROR: {self.ErrMessage}"


proc myType*(self: Object): ObjectType =
    case self.kind:
    of Integer:
        result = INTEGER_OBJ
    of String:
        result = STRING_OBJ
    of Boolean:
        result = BOOLEAN_OBJ
    of TNull:
        result = NULL_OBJ
    of ReturnValue:
        result = RETURN_VALUE_OBJ
    of Function:
        result = FUNCTION_OBJ
    of Error:
        result = ERROR_OBJ


proc newEnvironment*(): Environment =
    Environment(store: initTable[string, Object](1))


proc get*(self: Environment, name: string): Object =
    var obj = self.store[name]
    # TODO:
    # if self.outer != nil:
    #     obj = self.outer.get(name)
    return obj


proc set*(self: Environment, name: string, val: Object) =
    self.store[name] = val


proc newEncloseEnvironment*(outer: Environment): Environment =
    result = newEnvironment()
    result.outer = outer
