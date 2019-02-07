type
    TObjectKind* = enum
        Integer
        Boolean
        TNull
        ReturnValue

type
    ObjectType* = enum
        INTEGER_OBJ = "INTEGER"
        BOOLEAN_OBJ = "BOOLEAN"
        NULL_OBJ = "NULL"
        RETURN_VALUE_OBJ = "RETURN_VALUE"

    Object* = ref TObject
    TObject = object
        case kind*: TObjectKind
        of Integer:
            IntValue*: int
        of Boolean:
            BoolValue*: bool
        of TNull:
            discard
        of ReturnValue:
            ReValue*: Object
        else: discard

proc inspect*(self: Object): string
proc myType*(self: Object): ObjectType


proc inspect*(self: Object): string =
    case self.kind:
    of Integer:
        result = $self.IntValue
    of Boolean:
        result = $self.BoolValue
    of TNull:
        result = "null"
    of ReturnValue:
        result = self.ReValue.inspect()

proc myType*(self: Object): ObjectType =
    case self.kind:
    of Integer:
        result = INTEGER_OBJ
    of Boolean:
        result = BOOLEAN_OBJ
    of TNull:
        result = NULL_OBJ
    of ReturnValue:
        result = RETURN_VALUE_OBJ
