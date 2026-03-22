import std/os
import std/osproc
import std/strutils

const libPath = "/data/data/com.termux/files/usr/lib/libgitmas.so"

proc YLW(): string {.importc, dynlib: libPath.}
proc RST(): string {.importc, dynlib: libPath.}
proc RED(): string {.importc, dynlib: libPath.}
proc warn(msgWarn: string) {.importc, dynlib: libPath.}
proc error(msgErr: string) {.importc, dynlib: libPath.}
proc hasAuth(): bool {.importc, dynlib: libPath.}
proc doSetup(): uint8 {.importc, dynlib: libPath.}

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
  if execCmd("git add .") != 0:
    error("Failed to add files.")
    return
  if execCmd("git commit -am " & quoteShell(commitMsg)) != 0:
    warn("Commit failed or nothing to commit.")
  echo "- Pushing..."
  if execCmd("git push origin main") != 0:
    error("Push failed.")

proc gitInit(addStruc: bool) =
  echo "- Initializing git..."
  discard execCmd("git init")
  discard execCmd("git branch -m main")
  if addStruc:
    echo "- Adding file structure..."
    discard execCmd("git add .")

proc showHelp() =
  echo "- Gitmas " & ver & " - By Jordan"
  echo ""
  echo "Commands:"
  echo "init <true|false>  Initialize git"
  echo "push <msg>         Push to remote"
  echo "sys-info           Get system info"
  echo "update             Force refresh repo"
  echo "setup-auth         Setup git user data"
  
proc showSystemInfo() =
  echo "Android Version: " & getAndroidProp("ro.build.version.release")
  echo "Android SDK: " & getAndroidProp("ro.build.version.sdk")
  echo "Device Model: " & getAndroidProp("ro.product.model")
  echo "System ABI: " & getAndroidProp("ro.product.cpu.abi")

let args = commandLineParams()

if args.len == 0:
  warn "no command given."
  showHelp()
  quit(0)

case args[0]
  of "sys-info":
    showSystemInfo()
  of "init":
    if args.len > 1:
      try: gitInit(parseBool(args[1]))
      except ValueError: error "argument must be 'true' or 'false'."
    else: error "'init' needs an argument."
  of "push":
    if args.len > 1:
      if args[1].isEmptyOrWhitespace(): error "message empty!"
      else: gitPush(args[1])
    else: error "message not given!"  
  of "help":
    showHelp()
  of "update":
    echo YLW() & "--- Force Refreshing Repo ---" & RST()
    discard execCmd("rm -f $PREFIX/var/lib/apt/lists/jordan15citizen*")
    discard execCmd("apt clean && apt update && apt upgrade")
  of "setup-auth":
    if not hasAuth(): discard doSetup()
    else: echo "Credentials already established."
  else:
    error "invalid command " & args[0]
