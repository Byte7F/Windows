:: Script usage:
::               installation: %windir%\System32\reboot.cmd
::                application: Command Prompt with Administrator privs; quick-access: [Win]+[X] -> [A]dmin Command Prompt
::
:: Command usage:
::                reboot [<*>.exe|<name>]
::
@SetLocal
@set args=%*
@call kill.cmd %args%
@call boot.cmd %args%
@EndLocal
@exit /b 0
