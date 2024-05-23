:: Command usage:
::                flush-caches
::                             --user [username] :: sets profile for data to be cleared of, uses current username otherwise
::                             --use-event [0|1] :: opens "Event Viewer" if you feel generous to manually scan & clear logs
::                             --use-procs [0|1] :: opens an array of built-in Cleaners: DiskCleanup, WinStoreReset, DeFrag
::                             --kill-auto [0|1] :: keeps "Windows Update: Auto-Update (Service)" (wuauserv) stopped
::
:: NOTE:
::       Removes FileExplorer/WebBrowser/Download history and Prefetch/DirectX/AMD caches (among many other things).
::       Please delete any @call :flush_* "*" lines you don't want to commit to (you should probably check the list).

@SetLocal EnableDelayedExpansion

@set args=%*

@if "%args%"=="/?" @goto :help_
@if "%args%"=="/help" @goto :help_
@goto :_help

:help_
@echo.
@echo flush-caches
@echo              --user [username] :: sets profile for data to be cleared of, uses current username otherwise   &REM use_user;use_userprofile
@echo              --use-event [0^|1] :: opens "Event Viewer" if you feel generous to manually scan ^& clear logs &REM use_eventvwr
@echo              --use-procs [0^|1] :: opens an array of built-in Cleaners: DiskCleanup, WinStoreReset, DeFrag  &REM use_procs
@echo              --kill-auto [0^|1] :: keeps "Windows Update: Auto-Update (Service)" ^(wuauserv^) stopped       &REM end_wuauserv
@goto :_run
:_help

:options_
@set use_user=%username%
@set use_userprofile=%userprofile%\
@set use_eventvwr=0
@set use_procs=0
@set end_wuauserv=0
:_options

:parse_
@set head=
@set tail=
@for %%a in (%args%) do @(
 @set tail=!head!
 @set head=%%a
 @set head=!head:"=!
 @if "!tail!"=="--user"      @set use_user=!head!
 @if "!tail!"=="--use-event" @set use_eventvwr=!head!
 @if "!tail!"=="--use-procs" @set use_procs=!head!
 @if "!tail!"=="--kill-auto" @set end_wuauserv=!head!
)
@for %%D in ("%userprofile%\..\%use_user%\") do @set use_userprofile=%%~dpD
@set use_userprofile=%use_userprofile:~0,-1%
@set i=0
:continue
@set /a i += 1
@for /f "tokens=%i% delims=\" %%a in ("%use_userprofile%") do @if not "%%a"=="" @set "use_user=%%a" & @goto :continue
:_parse

@echo.
@echo --user %use_user% ^[ %use_userprofile% ^]
@echo --use-event %use_eventvwr%
@echo --use-procs %use_procs%
@echo --kill-auto %end_wuauserv%
@echo.
:check_
@set /p check="Continue (Y/N)? "
@if "%check:~0,1%"=="Y" @goto :_check
@if "%check:~0,1%"=="y" @goto :_check
@if "%check:~0,1%"=="N" @goto :_run
@if "%check:~0,1%"=="n" @goto :_run
@echo Invalid input^^!
@goto :check_
:_check
@goto :_functions

:functions_

:echo_info
@echo.
@echo.
@echo :: [ info ] :: %*
@echo.
@exit /b 0

:: flush all [ folders + binaries ] in [ cd ]
:flush_entire
@set x=%*
@if exist %x% @(
 @echo :: Flushing :: %x%
 @cd /d %x%
 @for /d %%D in (*) do @if exist "%%D" @rd /q /s "%%D" >nul 2>&1
 @del /q /f * >nul 2>&1
) else @(
 @echo :: Skipping :: %x%
)
@exit /b 0

:: flush all [ folders ] in [ cd ]
:flush_folder
@set x=%*
@if exist %x% @(
 @echo :: Flushing :: %x%
 @cd /d %x%
 @for /d %%D in (*) do @if exist "%%D" @rd /q /s "%%D" >nul 2>&1
) else @(
 @echo :: Skipping :: %x%
)
@exit /b 0

:: flush all [ binaries ] in [ cd ]
:flush_binary
@set x=%*
@if exist %x% @(
 @echo :: Flushing :: %x%
 @cd /d %x%
 @del /q /f * >nul 2>&1
) else @(
 @echo :: Skipping :: %x%
)
@exit /b 0

:: flush a [ visible binary ] in [ cd ]
:flush_normal
@set x=%*
@if exist %x% @(
 @echo :: Flushing :: %x%
 @cd /d %x%\..
 @for %%F in (%x%) do @if exist "%%~nxF" @del /q /f "%%~nxF" >nul 2>&1
) else @(
 @echo :: Skipping :: %x%
)
@exit /b 0

:: flush an [ invisible binary ] in [ cd ]
:flush_hidden
@set x=%*
@if exist %x% @(
 @echo :: Flushing :: %x%
 @cd /d %x%\..
 @for %%F in (%x%) do @if exist "%%~nxF" @del /q /f /ah "%%~nxF" >nul 2>&1
) else @(
 @echo :: Skipping :: %x%
)
@exit /b 0

:: run a process
:run_process
@set x=%*
@echo :: Starting :: %x%
@%x%
@exit /b 0

:: end a process
:end_process
@set x=%*
@echo :: Stopping :: %x%
@taskkill /f /im "%x%"
@exit /b 0

:_functions

:run_

:: LOG: Windows Version
@call :echo_info Windows version...
@for /f "tokens=4-7 delims=[]. " %%a in ('ver') do @echo set win=%%a
@echo Windows %win%

:: HANDLE: end_wuauserv
@set restart_wuauserv=0
@for /f "tokens=3 delims=: " %%a in ('sc query wuauserv') do @(
 @if "%%a"=="RUNNING" @(
  @call :echo_info Service: "wuauserv" -> STOPPING ...
  @if not "%end_wuauserv%"=="1" @set restart_wuauserv=1
  @net stop wuauserv
 )
 @if "%%a"=="STOPPED" @(
  @call :echo_info Service: "wuauserv" -> already "STOPPED" ...
 )
)
@echo restart_wuauserv == %restart_wuauserv%

:: HANDLE: use_eventvwr
@if "%use_eventvwr%"=="1" @(
 @call :echo_info Running Event Viewer...
 @echo How considerate of you^^!
 @call :run_process "%systemroot%\System32\eventvwr.exe"
)

:: flush
@call :echo_info Flushing common caches...
@call :flush_entire "%systemdrive%\Temp"
@call :flush_entire "%systemroot%\Temp"
@call :flush_entire "%use_userprofile%\AppData\Local\Temp"
@call :flush_entire "%use_userprofile%\AppData\Local\Microsoft\Windows\AppCache"
@call :flush_entire "%use_userprofile%\AppData\Local\Microsoft\Windows\Caches"

@call :echo_info Flushing Windows Update caches...
@call :flush_entire "%systemroot%\SoftwareDistribution\Download"
@call :flush_entire "%systemroot%\SoftwareDistribution\EventCache"
@call :flush_entire "%systemroot%\SoftwareDistribution\PostRebootEventCache"
@call :flush_entire "%systemroot%\SoftwareDistribution\PostRebootEventCache.V2"

@call :echo_info Flushing Explorer File History caches...
@call :flush_entire "%use_userprofile%\Recent"
@call :flush_entire "%use_userprofile%\AppData\Roaming\Microsoft\Windows\Recent"

@call :echo_info Flushing Explorer Icon History caches...
@call :flush_hidden "%use_userprofile%\AppData\Local\IconCache.db"
@call :flush_entire "%use_userprofile%\AppData\Local\Microsoft\Windows\Explorer\IconCacheToDelete"
@call :flush_entire "%use_userprofile%\AppData\Local\Microsoft\Windows\Explorer\ThumbCacheToDelete"

@call :echo_info Flushing Windows Error Reports...
@call :flush_entire "%programdata%\Microsoft\Windows\WER"

@call :echo_info Flushing Crash Dumps & Crash Reports...
@call :flush_entire "%use_userprofile%\AppData\Local\CrashDumps"
@call :flush_entire "%use_userprofile%\AppData\Local\CrashRpt\UnsentCrashReports"

@call :echo_info Flushing Windows Defender Support cache...
@call :flush_entire "%programdata%\Microsoft\Windows Defender\Support"

@call :echo_info Flushing Prefetch caches...
@call :flush_entire "%systemroot%\Prefetch"

@call :echo_info Flushing DirectX caches...
@call :flush_entire "%use_userprofile%\AppData\Local\D3DSCache"

@call :echo_info Flushing AMD caches...
@call :flush_entire "%use_userprofile%\AppData\Local\AMD\DxCache"
@call :flush_entire "%use_userprofile%\AppData\Local\AMD\GLCache"
@call :flush_entire "%use_userprofile%\AppData\Local\AMD\VkCache"

@call :echo_info Flushing Microsoft InternetExplorer caches...
@call :flush_binary "%use_userprofile%\AppData\Local\Microsoft\Windows\INetCache"
@call :flush_binary "%use_userprofile%\AppData\Local\Microsoft\Windows\INetCache\IE"
@call :flush_binary "%use_userprofile%\AppData\Local\Microsoft\Windows\Temporary Internet Files"
@call :flush_binary "%use_userprofile%\AppData\Local\Microsoft\Windows\WebCache"
@call :flush_binary "%use_userprofile%\AppData\Local\Microsoft\Windows\WebCache.old"

@call :echo_info Flushing Microsoft Edge caches...
@call :flush_binary "%use_userprofile%\AppData\Local\Microsoft\Edge\User Data\Default\Cache"
@call :flush_binary "%use_userprofile%\AppData\Local\Microsoft\Edge\User Data\Default\Cache\Cache_Data"
@call :flush_entire "%use_userprofile%\AppData\Local\Microsoft\Edge\User Data\Default\Code Cache"
@call :flush_binary "%use_userprofile%\AppData\Local\Microsoft\Edge\User Data\Default\Media Cache"
@call :flush_binary "%use_userprofile%\AppData\Local\Microsoft\Edge\User Data\Default\Media Cache\Cache_Data"
@call :flush_binary "%use_userprofile%\AppData\Local\Microsoft\Edge\User Data\Default\System Cache"
@call :flush_binary "%use_userprofile%\AppData\Local\Microsoft\Edge\User Data\Default\System Cache\Cache_Data"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\INetCache"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\INetHistory"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\Microsoft\CryptnetUrlCache"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\MicrosoftEdge\BingPageDataCache"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\MicrosoftEdge\Cache"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\MicrosoftEdge\History"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\MicrosoftEdge\IECompatCache"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\MicrosoftEdge\IECompatUaCache"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\MicrosoftEdge\IEFlipAheadCache"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\MicrosoftEdge\User\Default\DownloadHistory"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\Temp"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\TokenBroker\Cache"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AppData\User\Default\CacheStorage"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AppData\User\Default\Indexed DB"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\LocalCache"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\TempState"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\AC\INetCache"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\AC\INetHistory"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\AC\Microsoft\CryptnetUrlCache"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\AC\MicrosoftEdge\BingPageDataCache"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\AC\MicrosoftEdge\Cache"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\AC\MicrosoftEdge\History"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\AC\MicrosoftEdge\IECompatCache"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\AC\MicrosoftEdge\IECompatUaCache"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\AC\MicrosoftEdge\IEFlipAheadCache"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\AC\MicrosoftEdge\User\Default\DownloadHistory"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\AC\Temp"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\AC\TokenBroker\Cache"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\AppData\User\Default\CacheStorage"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\AppData\User\Default\Indexed DB"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\LocalCache"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\TempState"

@call :echo_info Flushing Mozilla Firefox caches...
@for /d %%D in ("%use_userprofile%\AppData\Local\Mozilla\Firefox\Profiles\*") do @(
 @call :flush_binary "%%~D\cache"
 @call :flush_binary "%%~D\cache2\entries"
 @call :flush_binary "%%~D\OfflineCache"
 @call :flush_binary "%%~D\startupCache"
 @call :flush_binary "%%~D\thumbnails"
 @call :flush_normal "%%~D\chromeappsstore.sqlite"
 @call :flush_normal "%%~D\webappsstore.sqlite"
)

@call :echo_info Flushing Google Chrome caches...
@call :flush_binary "%use_userprofile%\AppData\Local\Google\Chrome\User Data\Default\Cache"
@call :flush_binary "%use_userprofile%\AppData\Local\Google\Chrome\User Data\Default\Cache\Cache_Data"
@call :flush_entire "%use_userprofile%\AppData\Local\Google\Chrome\User Data\Default\Code Cache"
@call :flush_binary "%use_userprofile%\AppData\Local\Google\Chrome\User Data\Default\Media Cache"
@call :flush_binary "%use_userprofile%\AppData\Local\Google\Chrome\User Data\Default\Media Cache\Cache_Data"
@call :flush_binary "%use_userprofile%\AppData\Local\Google\Chrome\User Data\Default\System Cache"
@call :flush_binary "%use_userprofile%\AppData\Local\Google\Chrome\User Data\Default\System Cache\Cache_Data"

@call :echo_info Flushing KTL Opera caches...
@call :flush_binary "%use_userprofile%\AppData\Local\Opera Software\Opera Stable\Cache"
@call :flush_binary "%use_userprofile%\AppData\Local\Opera Software\Opera Stable\Cache\Cache_Data"
@call :flush_entire "%use_userprofile%\AppData\Local\Opera Software\Opera Stable\Code Cache"
@call :flush_binary "%use_userprofile%\AppData\Local\Opera Software\Opera Stable\Media Cache"
@call :flush_binary "%use_userprofile%\AppData\Local\Opera Software\Opera Stable\Media Cache\Cache_Data"
@call :flush_binary "%use_userprofile%\AppData\Local\Opera Software\Opera Stable\System Cache"
@call :flush_binary "%use_userprofile%\AppData\Local\Opera Software\Opera Stable\System Cache\Cache_Data"

@call :echo_info Flushing Microsoft SkyDrive caches...
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\microsoft.microsoftskydrive_8wekyb3d8bbwe\AC\AppCache"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\microsoft.microsoftskydrive_8wekyb3d8bbwe\AC\INetCache"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\microsoft.microsoftskydrive_8wekyb3d8bbwe\AC\INetHistory"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\microsoft.microsoftskydrive_8wekyb3d8bbwe\AC\Microsoft\CryptnetUrlCache"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\microsoft.microsoftskydrive_8wekyb3d8bbwe\AC\Microsoft\Internet Explorer\DOMStore"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\microsoft.microsoftskydrive_8wekyb3d8bbwe\AC\Temp"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\microsoft.microsoftskydrive_8wekyb3d8bbwe\AC\TokenBroker\Cache"

@call :echo_info Flushing Microsoft GamingApp caches...
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.GamingApp_8wekyb3d8bbwe\AC\AMD\DxCache"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.GamingApp_8wekyb3d8bbwe\AC\Microsoft\CryptnetUrlCache"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.GamingApp_8wekyb3d8bbwe\LocalCache"
@call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.GamingApp_8wekyb3d8bbwe\TempState"

:: dip
@cd /d "%~dp0"

:: HANDLE: end_wuauserv
@if "%restart_wuauserv%"=="1" @(
 @call :echo_info Restarting Service "wuauserv" ...
 @net start wuauserv
)

:: HANDLE: use_procs
@if "%use_procs%"=="1" @(
 @call :echo_info Running built-in cleaners...
 @call :run_process "%systemroot%\System32\WSReset.exe"
 @call :end_process "WinStore.App.exe"
 @call :run_process "%systemroot%\System32\cleanmgr.exe"
 @call :run_process "%systemroot%\System32\dfrgui.exe"
)

:_run

:: make peace
@echo.
@echo.

@EndLocal

@exit /b 0

