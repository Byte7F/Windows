:: Command usage:
::                boot [name|process]

@SetLocal

@set id_uefn=7f138a09169b250e9dcb378140907378
@set args=%*
@goto :run_

:boot
@( ( @start "" %* && @echo started: "%args%" ) || @echo absent: "%args%" )
@goto :_run

:run_
@if "%args%"=="firefox" @call :boot "%programfiles% (x86)\Mozilla Firefox\private_browsing.exe"
@if "%args%"=="discord" @call :boot "%appdata%\..\Local\Discord\Update.exe" --processStart "Discord.exe"
@if "%args%"=="epic"    @call :boot "%programfiles% (x86)\Epic Games\Launcher\Portal\Binaries\Win64\EpicGamesLauncher.exe"
@if "%args%"=="fn"      @call :boot "com.epicgames.launcher://apps/Fortnite?action=launch&silent=true"
@if "%args%"=="uefn"    @call :boot "com.epicgames.launcher://apps/fn%%3A%id_uefn%%%3AFortnite_Studio?action=launch&silent=true"
@call :boot %args%
:_run

@EndLocal

@exit /b 0

