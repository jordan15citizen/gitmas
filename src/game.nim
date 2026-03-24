import std/[os, osproc, json, strformat,  strutils, random, terminal]

const BGT = ansiStyleCode(styleBright)
const RED = BGT & ansiForegroundColorCode(fgRed)
const BLUE  = BGT & ansiForegroundColorCode(fgBlue)
const GRN = BGT & ansiForegroundColorCode(fgGreen)
const RST = ansiResetCode
const savePath = "/data/data/com.termux/files/home/.gitmas"
const saveFile = savePath & "/userdata.json"

var lives = 5
var money = 300
var wins = 0
var losses = 0

proc saveData(money: int, lives: int, losses: int, wins: int) =
  let data = %* {
    "Money": money,
    "Lives": lives,
    "Losses": losses,
    "Wins": wins
  }
  writeFile(saveFile, $data) 

randomize()

echo "Loading data..."
createDir(savePath)

if fileExists(saveFile):
  let contents = readFile(saveFile)
  let jsonNode = parseJson(contents)

  money = jsonNode["Money"].getInt()
  lives = jsonNode["Lives"].getInt()
  losses = jsonNode["Losses"].getInt()
  wins = jsonNode["Wins"].getInt()
  echo ""

else:
  echo "No data to load."
  echo "Starting fresh are we?"    
  echo ""

while true:
  let randNum = rand(1..5)
  
  echo fmt"{BLUE}Wins: {wins}"
  echo fmt"{BLUE}Losses: {losses}{RST}"
  
  if lives == 0:
    echo ""
    echo fmt"{RED}No lives left!{RST}"
    stdout.write fmt"{BLUE}Spend 100$ to gain 2 life? (Y/n) "
    let gainLife = stdin.readLine()
    if gainLife.toLowerAscii().contains("y"):
      echo "Deducting 100$ and granting 2 lives..."
      if money >= 100:
        lives += 2
        money -= 100
        saveData(money, lives, losses, wins)
        
      else:
        echo fmt"{RED}You don't have 100$ or more!{RST}"
        quit(0)
      
    else:
      echo fmt"{RED}Exiting...{RST}"
      quit(0)

  echo fmt"{BLUE}Money: {money}$"
  echo fmt"{BLUE}Lives: {lives}{RST}"
  echo ""
  
  echo "I am thinking of a number between 1 and 5"

  stdout.write fmt"{BLUE}Enter your guess: {RST}"
  let guessNum = stdin.readLine().parseInt()

  if guessNum == randNum:
    sleep(100)
    echo "Number is " & $randNum
    sleep(100)
    echo fmt"{GRN}Your guess was correct!{RST}"
    
    money += 25
    wins += 1
    saveData(money, lives, losses, wins)
    
    stdout.write fmt"{BLUE}Contiune? (Y/n) {RST}"
    let again = stdin.readLine()
    if again.toLowerAscii().contains('y'):
      echo "Restarting..."
      sleep(500)
      discard execCmd("clear")
      
    else:
      echo fmt"{BLUE}Exiting...{RST}"
      quit(0)
    
  else:
    sleep(500)
    echo "Number was " & $randNum
    sleep(500)
    echo fmt"{RED}Your guess was not correct{RST}"
    lives -= 1
    losses += 1
    saveData(money, lives, losses, wins)
      
    stdout.write fmt"{BLUE}Try again? (Y/n) {RST}"
    let tryAgain = stdin.readLine()
    if tryAgain.toLowerAscii().contains('y'):
      echo "Restarting..."
      sleep(500)
      discard execCmd("clear")
    else:
      echo fmt"{BLUE}Exiting...{RST}"
      quit(0)
