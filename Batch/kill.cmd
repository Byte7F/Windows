:: Command usage:
::                kill [<process>|<name>|all <type>|all]

@SetLocal

@set args=%*
@goto :run_

:kill
@set proc=%3
@set proc=%proc:"=%
@if "%args%"=="all"    @( ( @taskkill /f /im "%proc%" >nul 2>&1 && @echo stopped: "%2"     ) || @echo inactive: "%2"     )
@if "%args%"=="all %1" @( ( @taskkill /f /im "%proc%" >nul 2>&1 && @echo stopped: "%2"     ) || @echo inactive: "%2"     )
@if "%args%"=="%2"     @( ( @taskkill /f /im "%proc%" >nul 2>&1 && @echo stopped: "%2"     ) || @echo inactive: "%2"     )
@if "%1 %2"=="* *"     @( ( @taskkill /f /im "%proc%" >nul 2>&1 && @echo stopped: "%proc%" ) || @echo inactive: "%proc%" )
@exit /b 0

:run_
@set proc=%1
@set proc=%proc:"=%
@if "%proc:~-4%"==".exe" @call :kill * * "%proc%"
::    :kill type   name     "process"
@call :kill web    explorer "iexplore.exe"
@call :kill web    edge     "msedge.exe"
@call :kill web    firefox  "firefox.exe"
@call :kill web    chrome   "chrome.exe"
@call :kill web    opera    "opera.exe"
@call :kill web    torch    "torch.exe"
@call :kill web    safari   "safari.exe"
@call :kill social discord  "Discord.exe"
@call :kill social skype    "Skype.exe"
@call :kill epic   uefn     "UnrealEditorFortnite-Win64-Shipping.exe"
@call :kill epic   fn       "FortniteClient-Win64-Shipping.exe"
@call :kill epic   epic     "EpicGamesLauncher.exe"
:_run

@EndLocal

@exit /b 0

