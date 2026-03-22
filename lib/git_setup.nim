import os, std/terminal, strutils

const tokenPath = "/data/data/com.termux/files/home/.gitmas_token"

proc hasAuth*(): bool {.exportc, dynlib.} =
  return fileExists(tokenPath)

proc getStoredToken*(): string {.exportc, dynlib.} =
  if hasAuth():
    return readFile(tokenPath).strip()
  return ""

proc doSetup*() {.exportc, dynlib.} =
  styledWriteLine(stdout, fgYellow, styleBright, "\n--- Gitmas Auth Setup ---", resetStyle)
  
  stdout.write "Enter your GitHub Personal Access Token (PAT): "
  let token = stdin.readLine().strip()
  
  if token.len > 0:
    try:
      writeFile(tokenPath, token)
      styledWriteLine(stdout, fgGreen, "Token saved successfully!", resetStyle)
    except OSError:
      styledWriteLine(stdout, fgRed, "Error: Could not write to " & tokenPath, resetStyle)
  else:
    styledWriteLine(stdout, fgRed, "Setup cancelled: Token cannot be empty.", resetStyle)
    quit(1)

if isMainModule:
  doSetup()
