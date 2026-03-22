import std/os
import std/osproc
import std/strutils
import std/terminal

const libPath = "/data/data/com.termux/files/usr/lib/libgitmas.so"
var YLW {.importc, dynlib: libPath.}: string
var RST {.importc, dynlib: libPath.}: string
var RED {.importc, dynlib: libPath.}: string

let ver = execProcess("dpkg-query -W -f='${Version}\n' gitmas").strip()

proc sys_prop_get(key: cstring, value: cstring): int32 
  {.importc: "__system_property_get", header: "<sys/system_properties.h>".}

proc getAndroidProp(key: string): string =
  var buffer = newString(1024) 
  let length = sys_prop_get(key.cstring, buffer.cstring)
  if length > 0:
    return $buffer.cstring
  else:
    return "Not found"

proc gitPush(commitMsg: string) =
  echo "- Committing..."
  discard execCmd("git add .")
  discard execCmd("git commit -am " & quoteShell(commitMsg))
  echo "- Pushing..."
  discard execCmd("git push origin main")

proc hasAuth(): bool {.importc, dynlib: libPath.}

proc error(msgErr: string) {.importc, dynlib: libPath}
proc warn(msgWarn: string) {.importc, dynlib: libPath}

proc doSetup() {.importc, dynlib: libPath.}

proc gitInit(addStruc: bool) =
  echo "- Initializing git..."
  discard execCmd("git init")
  discard execCmd("git branch -m main")
  if addStruc:
    echo "- Adding file structure..."
    discard execCmd("git add .")
  else:
    echo "- Not adding file structure."

proc showHelp() =
  echo "- Gitmas " & ver & "- By Jordan"
  echo "- Do not type grinch, or else..."
  echo ""
  
  echo "Commands:"
  echo ""

  echo "init <true|false>:"
  echo "- Initialize git and add file structure based on input."
       
  echo "push <commitMsg>:"
  echo "- Push files to remote."

  echo "sys-info:"
  echo "- Get system information."
  echo ""

  echo "update:"
  echo "- If APT updating won't work, try this."
  echo ""

  echo "setup-auth:"
  echo "- Setup git user data"
  
proc showSystemInfo() =
  let androidVer = getAndroidProp("ro.build.version.release")
  let androidSDK = getAndroidProp("ro.build.version.sdk")
  let deviceModel = getAndroidProp("ro.product.model")
  let sysABI = getAndroidProp("ro.product.cpu.abi")
  echo "Android Version: " & androidVer
  echo "Android SDK: " & androidSDK
  echo "Device Model: " & deviceModel
  echo "System ABI: " & sysABI



let args = commandLineParams()

if args.len == 0:
  warn "no command given."
  warn "redirecting to help."
  echo ""
  showHelp()
  quit(0)

let command = args[0]

case command
  of "sys-info":
    showSystemInfo()
    
  of "init":
    if args.len > 1:
      try:
        let shouldAdd = parseBool(args[1]) 
        gitInit(shouldAdd)
      except ValueError:
        error "argument must be 'true' or 'false'."
    else:
      error "'init' needs a 'true' or 'false' argument."
    
  of "push":
    if args.len > 1:
      let argMsg = args[1]
      if argMsg.isEmptyOrWhitespace():
        error "commit message cannot be empty or whitespace!"
      else:
        gitPush(argMsg)
    else:
      error "commit message not given!"  

  of "help":
    showHelp()

  of "grinch":
    error "YOU DARE TRY IT?"
    error "Yeah you did, so now nothing will happen."
    echo "- Grinch go kaboom!"
    quit(1)

  of "update":
    echo YLW & "--- Force Refreshing Repo ---" & RST
    discard execCmd("rm -f $PREFIX/var/lib/apt/lists/jordan15citizen*")
    discard execCmd("apt clean")
    discard execCmd("apt update")
    discard execCmd("apt upgrade")
    echo "Package is synced with " & $ver

  of "setup-auth":
    if not hasAuth():
      echo "No credentials found."
      doSetup()
    else:
      echo "Credentials already established."
    
  else:
    error "invalid command " & command
    echo "Try 'init', 'push', 'sys-info', 'update', 'setup-auth' or 'help'."
