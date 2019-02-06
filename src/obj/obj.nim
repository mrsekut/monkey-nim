type
    TObjectKind* = enum
        Integer
        Boolean
        Null

type
    ObjectType = enum
        INTEGER_OBJ = "INTEGER"
        BOOLEAN_OBJ = "BOOLEAN"
        NULL_OBJ = "NULL"

    Object* = ref TObject
    TObject = object
        case kind*: TObjectKind
        of Integer:
            IntValue*: int
        of Boolean:
            BoolValue*: bool
        of Null:
            discard
        else: discard

proc inspect*(self: Object): string
proc type(self: Object): ObjectType


proc inspect*(self: Object): string =
    case self.kind:
    of Integer:
        result = $self.IntValue
    of Boolean:
        result = $self.BoolValue
    of Null:
        result = "string"

proc type(self: Object): ObjectType =
    case self.kind:
    of Integer:
        result = INTEGER_OBJ
    of Boolean:
        result = BOOLEAN_OBJ
    of Null:
        result = NULL_OBJ
