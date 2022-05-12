@echo OFF
setLocal enableDelayedExpansion

:: NOTE:             personally; used in "Command Prompt" with "Administrator" privs, qa.: [Win]+[X] -> [A]dmin Command Prompt
:: Install location: "%windir%\System32\flush-caches.cmd"
:: Command usage:    flush-caches
::                                -cls              :: clears screen (useful for multiple execs), keeping cmd-lbl/args visible
::                                --use-event [0|1] :: opens "Event Viewer" if you feel generous to manually scan & clear logs
::                                --use-procs [0|1] :: opens an array of built-in Cleaners: DiskCleanup, WinStoreReset, DeFrag

:options_
set use_userprofile=%userprofile%\
set use_eventvwr=0
set use_procs=0
:_options

:parse_
set head=
set tail=
for %%a in (%*) do (
 set tail=!head!
 set head=%%a
 if "!head!"=="-cls" cls && echo %cd%^>%~n0 %*
 if "!tail!"=="--user" for %%D in ("!userprofile!\..\!head!\") do set use_userprofile=%%~dpD
 if "!tail!"=="--use-event" set use_eventvwr=!head!
 if "!tail!"=="--use-procs" set use_procs=!head!
)
set use_userprofile=%use_userprofile:~0,-1%
:_parse

echo.
echo User Profile :: "%use_userprofile%"
:check_
set /P check="Continue (Y/N)? "
if "%check:~0,1%"=="Y" goto :_check
if "%check:~0,1%"=="y" goto :_check
if "%check:~0,1%"=="N" goto :ExitApp
if "%check:~0,1%"=="n" goto :ExitApp
echo Invalid input^^!
goto :check_
:_check
goto :_functions

:functions_

:echo_info
echo.
echo.
echo :: [ info ] :: %*
echo.
exit /B 0

:flush_entire
set x=%*
echo :: Flushing :: %x%
cd /D %x%
for /D %%D in (*) do rd /S /Q "%%D"
del /F /Q *
exit /B 0

:flush_folder
set x=%*
echo :: Flushing :: %x%
cd /D %x%
for /D %%D in (*) do rd /S /Q "%%D"
exit /B 0

:flush_binary
set x=%*
echo :: Flushing :: %x%
cd /D %x%
del /F /Q *
exit /B 0

:flush_normal
set x=%*
echo :: Flushing :: %x%
cd /D %x%\..
for %%F in (%x%) do del /F /Q "%%~nxF"
exit /B 0

:flush_hidden
set x=%*
echo :: Flushing :: %x%
cd /D %x%\..
for %%F in (%x%) do del /F /Q /AH "%%~nxF"
exit /B 0

:run_process
set x=%*
echo :: Starting :: %x%
%x%
exit /B 0

:end_process
set x=%*
echo :: Stopping :: %x%
taskkill /F /IM %x%
exit /B 0

:_functions

call :echo_info Windows version...
for /F "tokens=4-5 delims=. " %%i in ('ver') do set version=%%i.%%j
echo Microsoft Windows [Version %version%]

set restart_wuauserv=0
for /F "tokens=3 delims=: " %%a in ('sc query wuauserv') do (
 if "%%a"=="RUNNING" (
  call :echo_info Stopping Service "wuauserv" ...
  set restart_wuauserv=1
  net stop wuauserv
 )
 if "%%a"=="STOPPED" (
  call :echo_info Service "wuauserv" already "STOPPED" ...
 )
)
echo restart_wuauserv == %restart_wuauserv%

if "%use_eventvwr%"=="1" (
 call :echo_info Running Event Viewer...
 echo How considerate of you^^!
 call :run_process "%windir%\System32\eventvwr.exe"
)

call :echo_info Flushing common caches...
call :flush_entire "C:\Temp"
call :flush_entire "C:\Windows\Temp"
call :flush_entire "%use_userprofile%\AppData\Local\Temp"
call :flush_entire "%use_userprofile%\AppData\Local\Microsoft\Windows\AppCache"
call :flush_entire "%use_userprofile%\AppData\Local\Microsoft\Windows\Caches"

call :echo_info Flushing history caches...
call :flush_entire "%use_userprofile%\Recent"
call :flush_entire "%use_userprofile%\AppData\Roaming\Microsoft\Windows\Recent"

call :echo_info Flushing icon caches...
call :flush_hidden "%use_userprofile%\AppData\Local\IconCache.db"

call :echo_info Flushing Windows Update caches...
call :flush_entire "C:\Windows\SoftwareDistribution\Download"
call :flush_entire "C:\Windows\SoftwareDistribution\EventCache"
call :flush_entire "C:\Windows\SoftwareDistribution\PostRebootEventCache"
call :flush_entire "C:\Windows\SoftwareDistribution\PostRebootEventCache.V2"

call :echo_info Flushing Crash Dumps...
call :flush_entire "%use_userprofile%\AppData\Local\CrashDumps"
call :flush_entire "%use_userprofile%\AppData\Local\CrashRpt\UnsentCrashReports"

call :echo_info Flushing Prefetch caches...
call :flush_entire "C:\Windows\Prefetch"

call :echo_info Flushing DirectX caches...
call :flush_entire "%use_userprofile%\AppData\Local\D3DSCache"

call :echo_info Flushing Microsoft Internet Explorer caches...
call :flush_binary "%use_userprofile%\AppData\Local\Microsoft\Windows\INetCache"
call :flush_binary "%use_userprofile%\AppData\Local\Microsoft\Windows\INetCache\IE"
call :flush_binary "%use_userprofile%\AppData\Local\Microsoft\Windows\Temporary Internet Files"
call :flush_binary "%use_userprofile%\AppData\Local\Microsoft\Windows\WebCache"
call :flush_binary "%use_userprofile%\AppData\Local\Microsoft\Windows\WebCache.old"

call :echo_info Flushing Microsoft Edge caches...
call :flush_binary "%use_userprofile%\AppData\Local\Microsoft\Edge\User Data\Default\Cache"
call :flush_binary "%use_userprofile%\AppData\Local\Microsoft\Edge\User Data\Default\Cache\Cache_Data"
call :flush_entire "%use_userprofile%\AppData\Local\Microsoft\Edge\User Data\Default\Code Cache"
call :flush_binary "%use_userprofile%\AppData\Local\Microsoft\Edge\User Data\Default\Media Cache"
call :flush_binary "%use_userprofile%\AppData\Local\Microsoft\Edge\User Data\Default\Media Cache\Cache_Data"
call :flush_binary "%use_userprofile%\AppData\Local\Microsoft\Edge\User Data\Default\System Cache"
call :flush_binary "%use_userprofile%\AppData\Local\Microsoft\Edge\User Data\Default\System Cache\Cache_Data"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\INetCache"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\INetHistory"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\Microsoft\CryptnetUrlCache"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\MicrosoftEdge\BingPageDataCache"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\MicrosoftEdge\Cache"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\MicrosoftEdge\History"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\MicrosoftEdge\IECompatCache"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\MicrosoftEdge\IECompatUaCache"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\MicrosoftEdge\IEFlipAheadCache"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\MicrosoftEdge\User\Default\DownloadHistory"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\Temp"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\TokenBroker\Cache"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AppData\User\Default\CacheStorage"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AppData\User\Default\Indexed DB"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\LocalCache"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\TempState"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\AC\INetCache"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\AC\INetHistory"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\AC\Microsoft\CryptnetUrlCache"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\AC\MicrosoftEdge\BingPageDataCache"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\AC\MicrosoftEdge\Cache"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\AC\MicrosoftEdge\History"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\AC\MicrosoftEdge\IECompatCache"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\AC\MicrosoftEdge\IECompatUaCache"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\AC\MicrosoftEdge\IEFlipAheadCache"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\AC\MicrosoftEdge\User\Default\DownloadHistory"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\AC\Temp"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\AC\TokenBroker\Cache"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\AppData\User\Default\CacheStorage"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\AppData\User\Default\Indexed DB"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\LocalCache"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\TempState"

call :echo_info Flushing Mozilla Firefox caches...
for /D %%D in ("%use_userprofile%\AppData\Local\Mozilla\Firefox\Profiles\*") do (
 call :flush_binary "%%~D\cache"
 call :flush_binary "%%~D\cache2\entries"
 call :flush_binary "%%~D\OfflineCache"
 call :flush_binary "%%~D\startupCache"
 call :flush_binary "%%~D\thumbnails"
 call :flush_normal "%%~D\chromeappsstore.sqlite"
 call :flush_normal "%%~D\webappsstore.sqlite"
)

call :echo_info Flushing Google Chrome caches...
call :flush_binary "%use_userprofile%\AppData\Local\Google\Chrome\User Data\Default\Cache"
call :flush_binary "%use_userprofile%\AppData\Local\Google\Chrome\User Data\Default\Cache\Cache_Data"
call :flush_entire "%use_userprofile%\AppData\Local\Google\Chrome\User Data\Default\Code Cache"
call :flush_binary "%use_userprofile%\AppData\Local\Google\Chrome\User Data\Default\Media Cache"
call :flush_binary "%use_userprofile%\AppData\Local\Google\Chrome\User Data\Default\Media Cache\Cache_Data"
call :flush_binary "%use_userprofile%\AppData\Local\Google\Chrome\User Data\Default\System Cache"
call :flush_binary "%use_userprofile%\AppData\Local\Google\Chrome\User Data\Default\System Cache\Cache_Data"

call :echo_info Flushing KTL Opera caches...
call :flush_binary "%use_userprofile%\AppData\Local\Opera Software\Opera Stable\Cache"
call :flush_binary "%use_userprofile%\AppData\Local\Opera Software\Opera Stable\Cache\Cache_Data"
call :flush_entire "%use_userprofile%\AppData\Local\Opera Software\Opera Stable\Code Cache"
call :flush_binary "%use_userprofile%\AppData\Local\Opera Software\Opera Stable\Media Cache"
call :flush_binary "%use_userprofile%\AppData\Local\Opera Software\Opera Stable\Media Cache\Cache_Data"
call :flush_binary "%use_userprofile%\AppData\Local\Opera Software\Opera Stable\System Cache"
call :flush_binary "%use_userprofile%\AppData\Local\Opera Software\Opera Stable\System Cache\Cache_Data"

call :echo_info Flushing AMD caches...
call :flush_entire "%use_userprofile%\AppData\Local\AMD\DxCache"
call :flush_entire "%use_userprofile%\AppData\Local\AMD\GLCache"
call :flush_entire "%use_userprofile%\AppData\Local\AMD\VkCache"

call :echo_info Flushing Microsoft SkyDrive caches...
call :flush_entire "%use_userprofile%\AppData\Local\Packages\microsoft.microsoftskydrive_8wekyb3d8bbwe\AC\AppCache"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\microsoft.microsoftskydrive_8wekyb3d8bbwe\AC\INetCache"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\microsoft.microsoftskydrive_8wekyb3d8bbwe\AC\INetHistory"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\microsoft.microsoftskydrive_8wekyb3d8bbwe\AC\Microsoft\CryptnetUrlCache"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\microsoft.microsoftskydrive_8wekyb3d8bbwe\AC\Microsoft\Internet Explorer\DOMStore"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\microsoft.microsoftskydrive_8wekyb3d8bbwe\AC\Temp"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\microsoft.microsoftskydrive_8wekyb3d8bbwe\AC\TokenBroker\Cache"

call :echo_info Flushing Microsoft GamingApp caches...
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.GamingApp_8wekyb3d8bbwe\AC\AMD\DxCache"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.GamingApp_8wekyb3d8bbwe\AC\Microsoft\CryptnetUrlCache"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.GamingApp_8wekyb3d8bbwe\LocalCache"
call :flush_entire "%use_userprofile%\AppData\Local\Packages\Microsoft.GamingApp_8wekyb3d8bbwe\TempState"

if "%restart_wuauserv%"=="1" (
 call :echo_info Restarting Service "wuauserv" ...
 net start wuauserv
)

cd /D "%~dp0"

if "%use_procs%"=="1" (
 call :echo_info Running built-in cleaners...
 call :run_process "%windir%\System32\cleanmgr.exe"
 call :run_process "%windir%\System32\WSReset.exe"
 call :end_process "WinStore.App.exe"
 call :run_process "%windir%\System32\dfrgui.exe"
)

:ExitApp
echo.
echo.

endLocal enableDelayedExpansion
@echo ON

