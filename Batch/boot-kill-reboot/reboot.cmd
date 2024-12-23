:: Command usage:
::                reboot [name|process]

@SetLocal

@set args=%*

@call kill.cmd %args%
@call boot.cmd %args%

@EndLocal

@exit /b 0

