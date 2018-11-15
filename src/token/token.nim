type TokenType = string

type Token = ref object of RootObj
    Type: TokenType
    Literal: string
