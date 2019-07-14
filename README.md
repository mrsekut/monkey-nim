# Monkey-Nim

Implementing the Monkey language interpreter with Nim, referring to the book "Writing An Interpreter In Go"

![sample](https://github.com/mrsekut/monkey-nim/blob/master/img/interp.gif)

## Blog

- [Nim で自作インタプリタ ① Lexer を作った - mrsekut-p](https://scrapbox.io/mrsekut-p/Nim%E3%81%A7%E8%87%AA%E4%BD%9C%E3%82%A4%E3%83%B3%E3%82%BF%E3%83%97%E3%83%AA%E3%82%BF%E2%91%A0_Lexer%E3%82%92%E4%BD%9C%E3%81%A3%E3%81%9F)
- [Nim で自作インタプリタ ② Pratt Parser を実装した - mrsekut-p](https://scrapbox.io/mrsekut-p/Nim%E3%81%A7%E8%87%AA%E4%BD%9C%E3%82%A4%E3%83%B3%E3%82%BF%E3%83%97%E3%83%AA%E3%82%BF%E2%91%A1_Pratt_Parser%E3%82%92%E5%AE%9F%E8%A3%85%E3%81%97%E3%81%9F)
- [Nim で自作インタプリタ ③ Evaluator を実装した - mrsekut-p](https://scrapbox.io/mrsekut-p/Nim%E3%81%A7%E8%87%AA%E4%BD%9C%E3%82%A4%E3%83%B3%E3%82%BF%E3%83%97%E3%83%AA%E3%82%BF%E2%91%A2_Evaluator%E3%82%92%E5%AE%9F%E8%A3%85%E3%81%97%E3%81%9F)

## Build

`$ nimble build`

## Run

- `$ ./moneky_nim`

## Test

`$ nimble test`

## Run in developing

- `$ nim c -r src/monkey_nim.nim`
