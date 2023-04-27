:: Script usage:
::               installation: %systemroot%\System32\kill.cmd
::                application: Command Prompt with Administrator privs; quick-access: [Win]+[X] -> [A]dmin Command Prompt
::
:: Command usage:
::                kill [<*>.exe|<name>|all <type>|all]
::
@SetLocal
@set args=%*
@goto :skip
:func
@set proc=%3
@set proc=%proc:"=%
@if "%args%"=="all"    @( ( @taskkill /f /im "%proc%" >nul 2>&1 && @echo stopped: "%2"     ) || @echo inactive: "%2"     )
@if "%args%"=="all %1" @( ( @taskkill /f /im "%proc%" >nul 2>&1 && @echo stopped: "%2"     ) || @echo inactive: "%2"     )
@if "%args%"=="%2"     @( ( @taskkill /f /im "%proc%" >nul 2>&1 && @echo stopped: "%2"     ) || @echo inactive: "%2"     )
@if "%1 %2"=="* *"     @( ( @taskkill /f /im "%proc%" >nul 2>&1 && @echo stopped: "%proc%" ) || @echo inactive: "%proc%" )
@exit /b 0
:skip
@set proc=%1
@set proc=%proc:"=%
@if "%proc:~-4%"==".exe" @call :func * * "%proc%"
@call :func web    explorer "iexplore.exe"
@call :func web    edge     "msedge.exe"
@call :func web    firefox  "firefox.exe"
@call :func web    chrome   "chrome.exe"
@call :func web    opera    "opera.exe"
@call :func web    torch    "torch.exe"
@call :func web    safari   "safari.exe"
@call :func social discord  "Discord.exe"
@call :func social skype    "Skype.exe"
@call :func epic   uefn     "UnrealEditorFortnite-Win64-Shipping.exe"
@call :func epic   fn       "FortniteClient-Win64-Shipping.exe"
@call :func epic   epic     "EpicGamesLauncher.exe"
@EndLocal
@exit /b 0
