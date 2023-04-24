@SetLocal
@set id_md5_uefn=7f138a09169b250e9dcb378140907378
@set args=%*
@set proc=%1
@set proc=%proc:"=%
@set prefix=^( ^( @start ^"^"
@set suffix=^&^& @echo started: ^"%proc%^" ^) ^|^| @echo absent: ^"%proc%^" ^)
@if "%proc:~-4%"==".exe" @%prefix% %args% %suffix%
@if "%args%"=="firefox"  @%prefix% "%programfiles% (x86)\Mozilla Firefox\private_browsing.exe"                                      %suffix%
@if "%args%"=="discord"  @%prefix% "%appdata%\..\Local\Discord\Update.exe" --processStart "Discord.exe"                             %suffix%
@if "%args%"=="epic"     @%prefix% "%programfiles% (x86)\Epic Games\Launcher\Portal\Binaries\Win64\EpicGamesLauncher.exe"           %suffix%
@if "%args%"=="fn"       @%prefix% "com.epicgames.launcher://apps/Fortnite?action=launch&silent=true"                               %suffix%
@if "%args%"=="uefn"     @%prefix% "com.epicgames.launcher://apps/fn%%3A%id_md5_uefn%%%3AFortnite_Studio?action=launch&silent=true" %suffix%
@EndLocal
@exit /b 0
