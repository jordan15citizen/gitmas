import std/[os, strformat,  strutils, random, terminal]

const BGT = ansiStyleCode(styleBright)
const RED = BGT & ansiForegroundColorCode(fgRed)
const GRN = BGT & ansiForegroundColorCode(fgGreen)
const RST = ansiResetCode

randomize()

while true:
  let randNum = rand(1..5)
  echo "I am thinking of a number between 1 and 10"

  stdout.write "Enter your guess: "
  let guessNum = stdin.readLine().parseInt()

  if guessNum == randNum:
    sleep(100)
    echo "Number is " & $randNum
    sleep(100)
    echo fmt"{GRN}Your guess was correct!{RST}"
    stdout.write "Contiune? (Y/n) "
    let again = stdin.readLine()
    if again.toLowerAscii().contains('y'):
      echo "Restarting..."
      sleep(500)
    else:
      echo "Exiting..."
      quit(0)
    
  else:
    sleep(500)
    echo "Number was " & $randNum
    sleep(500)
    echo "Your guess was not correct"
    stdout.write "Try again? (Y/n) "
    let tryAgain = stdin.readLine()
    if tryAgain.toLowerAscii().contains('y'):
      echo "Restarting..."
      sleep(1000)
    else:
      echo "Exiting..."
      quit(0)
