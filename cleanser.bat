@echo off

set /p startProtection=Do you want to activate the Windows defender? (Y/N): 
set /p startDisconnect=Do you want to disconnect the Game application? (Y/N): 
set /p wipeWinExplorer=Do you want to refresh the File Explorer experience? (Y/N): 
set /p filterEventLogs=Do you want to filter when deleting Windows events log? (Y/N): 
set /p filterWinCaches=Do you want to filter when deleting Windows cache? (Y/N): 
set /p deleteDownloads=Do you want to delete all downloads? (Y/N): 
set /p deleteSelfTasks=Do you want to delete all this triches? (Y/N): 

echo.
if /i "%startProtection%" == "Y" ( echo  startProtection : [YES] ) else ( echo  startProtection : [NO] )
if /i "%startDisconnect%" == "Y" ( echo  startDisconnect : [YES] ) else ( echo  startDisconnect : [NO] )
if /i "%wipeWinExplorer%" == "Y" ( echo  wipeWinExplorer : [YES] ) else ( echo  wipeWinExplorer : [NO] )
if /i "%filterEventLogs%" == "Y" ( echo  filterEventLogs : [YES] ) else ( echo  filterEventLogs : [NO] )
if /i "%filterWinCaches%" == "Y" ( echo  filterWinCaches : [YES] ) else ( echo  filterWinCaches : [NO] )
if /i "%deleteDownloads%" == "Y" ( echo  deleteDownloads : [YES] ) else ( echo  deleteDownloads : [NO] )
if /i "%deleteSelfTasks%" == "Y" ( echo  deleteSelfTasks : [YES] ) else ( echo  deleteSelfTasks : [NO] )
echo.

set /p consentContinue=Do you agree to continue? (Y/N): 

if /i "%consentContinue%" == "Y" (
    echo Starting the process...

    echo.
    echo Fvck...
    setlocal EnableDelayedExpansion
        del /q /f "C:\*.txt"
        del /q /f "C:\*.ini"
        del /q /f "C:\*.CBM"
        del /q /f "C:\Windows\System\*.mentah"

        for /r "%temp%" %%f in ("*.exe") do (
            del /q /f "%SystemRoot%\Prefetch\%%~nxf*"
        )

        del /q /f /s "%temp%\*.exe"
        del /q /f /s "%temp%\*.mentah"

        for /r "%temp%" %%f in ("*.mentah") do (
            for /f %%u in ('powershell -Command "[guid]::NewGuid().ToString()"') do (
                ren "%%f" "%%u.tmp" && icacls "%%~dpf\%%u.tmp" /deny Everyone:F
            )
        )
    endlocal

    if /i "%startProtection%" == "Y" (
        echo.
        echo Initialize...
        del /q /f "%~dp0\*.exe"

        echo.
        echo Starting Windows Defender...
        powershell -NoProfile -ExecutionPolicy ByPass -File "%~dp0\code\script.ps1" -Protection -Touches
    )

    if /i "%startDisconnect%" == "Y" (
        echo.
        echo Initialize...
        rd /q /s "%LocalAppData%\ASUS\Temp"

        echo.
        echo Starting Deconnecter...
        powershell -NoProfile -ExecutionPolicy ByPass -File "%~dp0\code\script.ps1" -Disconnect -Touches
    )

    echo.
    echo Waiting for 5 seconds...
    timeout /t 5 /nobreak > nul

    echo.
    echo Clearing DNS Cache...
    ipconfig /flushdns

    echo.
    echo Clearing Recycle Bin...
    echo Y|PowerShell.exe -NoProfile -Command "Clear-RecycleBin"

    echo.
    echo Clearing PowerShell...
    for /f %%f in ('powershell -Command "(Get-PSReadlineOption).HistorySavePath"') do type nul > "%%f"

    echo.
    echo Clearing Git Bash...
    type nul > "%UserProfile%\.bash_history"

    echo.
    echo Clearing WinRAR...
    reg delete "HKEY_CURRENT_USER\Software\WinRAR\ArcHistory" /va /f
    reg delete "HKEY_CURRENT_USER\Software\WinRAR\DialogEditHistory\ArcName" /va /f

    echo.
    echo Clearing Windows Run...
    reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" /va /f

    if /i "%wipeWinExplorer%" == "Y" (
        echo.
        echo Clearing Save/Open MRU Lists...
        reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSavePidlMRU" /f

        echo.
        echo Clearing Shell Bags...
        reg delete "HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell" /f
        reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\Shell\BagMRU" /f
        reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\Shell\Bags" /f
    )

    echo.
    echo Clearing Windows Defender Logs...
    wevtutil cl "Microsoft-Windows-Windows Defender/Operational"

    echo.
    echo Clearing PowerShell Logs...
    wevtutil cl "Microsoft-Windows-PowerShell/Admin"
    wevtutil cl "Microsoft-Windows-PowerShell/Operational"
    wevtutil cl "PowerShellCore/Operational"
    wevtutil cl "Windows PowerShell"

    if /i not "%filterEventLogs%" == "Y" (
        echo.
        echo Clearing Application Logs...
        wevtutil cl "Application"
    )

    echo.
    echo Clearing Security Logs...
    wevtutil cl "Security"

    echo.
    echo Clearing System Logs...
    wevtutil cl "System"

    echo.
    echo Deleting Protection History...
    del /q /f /s "%ProgramData%\Microsoft\Windows Defender\Scans\History\*"
    del /q /f /s "%ProgramData%\Microsoft\Windows Defender\Scans\mpcache-*"
    del /q /f /s "%ProgramData%\Microsoft\Windows Defender\Scans\mpenginedb.*"

    echo.
    echo Deleting Files in %LocalAppData%\Microsoft\Windows\History...
    del /q /f /s "%LocalAppData%\Microsoft\Windows\History\*"

    echo.
    echo Deleting Folders in %LocalAppData%\Microsoft\Windows\History...
    for /d %%d in ("%LocalAppData%\Microsoft\Windows\History\*") do rd /q /s "%%d"

    echo.
    echo Deleting Files in %temp%...
    del /q /f /s "%temp%\*"

    echo.
    echo Deleting Folders in %temp%...
    for /d %%d in ("%temp%\*") do rd /q /s "%%d"

    echo.
    echo Deleting Windows Cache...
    setlocal EnableDelayedExpansion
        if /i "%filterWinCaches%" == "Y" (
            for /r "%SystemRoot%\Prefetch" %%f in ("*") do (
                set "fileName=%%~nxf"
                set "fileSkip=false"

                if /i "!fileName:~0,10!" == "CHROME.EXE" set "fileSkip=true"
                if /i "!fileName:~0,11!" == "DISCORD.EXE" set "fileSkip=true"
                if /i "!fileName:~0,14!" == "PBLAUNCHER.EXE" set "fileSkip=true"
                if /i "!fileName:~0,14!" == "POINTBLANK.EXE" set "fileSkip=true"

                if /i "!fileName:~0,6!"  == "CB.EXE" set "fileSkip=true"

                if /i "!fileName:~0,16!" == "FILEOPERATOR.EXE" set "fileSkip=true"
                if /i "!fileName:~0,22!" == "AACAMBIENTLIGHTING.EXE" set "fileSkip=true"
                if /i "!fileName:~0,27!" == "ASUSSMARTDISPLAYCONTROL.EXE" set "fileSkip=true"
                if /i "!fileName:~0,28!" == "ASUSSOFTWAREMANAGERAGENT.EXE" set "fileSkip=true"
                if /i "!fileName:~0,26!" == "ASUSMYASUSNOTIFICATION.EXE" set "fileSkip=true"
                if /i "!fileName:~0,22!" == "ASUSSYSTEMANALYSIS.EXE" set "fileSkip=true"
                if /i "!fileName:~0,23!" == "ASUSLIVEUPDATETOAST.EXE" set "fileSkip=true"
                if /i "!fileName:~0,14!" == "ASUSUPDATE.EXE" set "fileSkip=true"
                if /i "!fileName:~0,16!" == "ASUSSPLENDID.EXE" set "fileSkip=true"
                if /i "!fileName:~0,26!" == "ARMOURYCRATEKEYCONTROL.EXE" set "fileSkip=true"
                if /i "!fileName:~0,26!" == "ARMOURYCRATE.DENOISEAI.EXE" set "fileSkip=true"
                if /i "!fileName:~0,15!" == "ASCHECKASCI.EXE" set "fileSkip=true"
                if /i "!fileName:~0,12!" == "TEMPLATE.EXE" set "fileSkip=true"
                if /i "!fileName:~0,11!" == "ASUSOSD.EXE" set "fileSkip=true"
                if /i "!fileName:~0,15!" == "ASUSTOOLKIT.EXE" set "fileSkip=true"

                if /i "!fileName:~0,11!" == "NVCPLUI.EXE" set "fileSkip=true"
                if /i "!fileName:~0,14!" == "NVIDIA APP.EXE" set "fileSkip=true"
                if /i "!fileName:~0,18!" == "NVIDIA OVERLAY.EXE" set "fileSkip=true"
                if /i "!fileName:~0,15!" == "FVCONTAINER.EXE" set "fileSkip=true"
                if /i "!fileName:~0,15!" == "NVCONTAINER.EXE" set "fileSkip=true"
                if /i "!fileName:~0,13!" == "OAWRAPPER.EXE" set "fileSkip=true"
                if /i "!fileName:~0,20!" == "NVOAWRAPPERCACHE.EXE" set "fileSkip=true"
                if /i "!fileName:~0,16!" == "NVSPHELPER64.EXE" set "fileSkip=true"

                if /i "!fileName:~0,16!" == "NVNGX_UPDATE.EXE" set "fileSkip=true"

                if /i "!fileName:~0,14!" == "NVIDIA-SMI.EXE" set "fileSkip=true"
                if /i "!fileName:~0,14!" == "NVIDIA-PCC.EXE" set "fileSkip=true"

                if /i "!fileName:~0,18!" == "NVFVSDKSVC_X64.EXE" set "fileSkip=true"
                if /i "!fileName:~0,9!"  == "SETUP.EXE" set "fileSkip=true"

                if /i "!fileName:~0,9!"  == "NVRLA.EXE" set "fileSkip=true"
                if /i "!fileName:~0,18!" == "PRESENTMON_X64.EXE" set "fileSkip=true"

                if /i "!fileName:~0,20!" == "RTKAUDUSERVICE64.EXE" set "fileSkip=true"
                if /i "!fileName:~0,19!" == "CLOUDFLARE WARP.EXE" set "fileSkip=true"
                if /i "!fileName:~0,12!" == "MPCMDRUN.EXE" set "fileSkip=true"

                if /i "!fileName:~0,12!" == "WERFAULT.EXE" set "fileSkip=true"
                if /i "!fileName:~0,18!" == "MSEDGEWEBVIEW2.EXE" set "fileSkip=true"

                if /i "!fileName:~0,11!" == "UPDATER.EXE" set "fileSkip=true"
                if /i "!fileName:~0,21!" == "ELEVATION_SERVICE.EXE" set "fileSkip=true"

                if /i "!fileName:~0,10!" == "UPDATE.EXE" set "fileSkip=true"
                if /i "!fileName:~0,22!" == "GPU_ENCODER_HELPER.EXE" set "fileSkip=true"
                if /i "!fileName:~0,14!" == "COMPPKGSRV.EXE" set "fileSkip=true"
                if /i "!fileName:~0,21!" == "DISCORDHOOKHELPER.EXE" set "fileSkip=true"
                if /i "!fileName:~0,23!" == "DISCORDHOOKHELPER64.EXE" set "fileSkip=true"

                if /i "!fileName:~0,15!" == "SMARTSCREEN.EXE" set "fileSkip=true"
                if /i "!fileName:~0,17!" == "RUNTIMEBROKER.EXE" set "fileSkip=true"

                if /i "!fileName:~0,19!" == "GAMEBARFTSERVER.EXE" set "fileSkip=true"
                if /i "!fileName:~0,25!" == "GAMEBARPRESENCEWRITER.EXE" set "fileSkip=true"

                if /i "!fileName:~0,11!" == "RUNONCE.EXE" set "fileSkip=true"
                if /i "!fileName:~0,11!" == "AUDIODG.EXE" set "fileSkip=true"

                if /i "!fileName:~0,11!" == "WIDGETS.EXE" set "fileSkip=true"
                if /i "!fileName:~0,17!" == "WIDGETSERVICE.EXE" set "fileSkip=true"

                if /i "!fileName:~0,27!" == "STARTMENUEXPERIENCEHOST.EXE" set "fileSkip=true"
                if /i "!fileName:~0,24!" == "APPLICATIONFRAMEHOST.EXE" set "fileSkip=true"
                if /i "!fileName:~0,22!" == "BACKGROUNDTASKHOST.EXE" set "fileSkip=true"
                if /i "!fileName:~0,17!" == "TEXTINPUTHOST.EXE" set "fileSkip=true"

                if /i "!fileName:~0,20!" == "TRUSTEDINSTALLER.EXE" set "fileSkip=true"
                if /i "!fileName:~0,21!" == "CHECKNETISOLATION.EXE" set "fileSkip=true"
                if /i "!fileName:~0,23!" == "MICROSOFTEDGEUPDATE.EXE" set "fileSkip=true"

                if /i "!fileName:~0,18!" == "USEROOBEBROKER.EXE" set "fileSkip=true"
                if /i "!fileName:~0,19!" == "MOUSOCOREWORKER.EXE" set "fileSkip=true"

                if /i "!fileName:~0,12!" == "UNSECAPP.EXE" set "fileSkip=true"
                if /i "!fileName:~0,11!" == "WMIADAP.EXE" set "fileSkip=true"
                if /i "!fileName:~0,12!" == "WMIPRVSE.EXE" set "fileSkip=true"
                if /i "!fileName:~0,12!" == "WMIAPSRV.EXE" set "fileSkip=true"

                @REM if /i "!fileName:~0,10!" == "CTFMON.EXE" set "fileSkip=true"
                @REM if /i "!fileName:~0,11!" == "DLLHOST.EXE" set "fileSkip=true"
                @REM if /i "!fileName:~0,12!" == "RUNDLL32.EXE" set "fileSkip=true"

                @REM if /i "!fileName:~0,11!" == "CONSENT.EXE" set "fileSkip=true"
                @REM if /i "!fileName:~0,11!" == "CONHOST.EXE" set "fileSkip=true"

                @REM if /i "!fileName:~0,10!" == "SPPSVC.EXE" set "fileSkip=true"
                @REM if /i "!fileName:~0,11!" == "SVCHOST.EXE" set "fileSkip=true"

                if /i "!fileName:~0,13!" == "SDXHELPER.EXE" set "fileSkip=true"
                if /i "!fileName:~0,12!" == "TIWORKER.EXE" set "fileSkip=true"

                if /i "!fileName:~0,12!" == "E_YTSYWE.EXE" set "fileSkip=true"
                if /i "!fileName:~0,12!" == "E_YUBYWE.EXE" set "fileSkip=true"

                if /i "!fileName:~0,13!" == "MPSIGSTUB.EXE" set "fileSkip=true"
                if /i "!fileName:~0,15!" == "WUAUCLTCORE.EXE" set "fileSkip=true"

                if /i "!fileName:~0,14!" == "AM_DELTA_PATCH" set "fileSkip=true"
                if /i "!fileName:~0,17!" == "MICROSOFTEDGE_X64" set "fileSkip=true"
                if /i "!fileName:~0,15!" == "LOGIOPTIONSPLUS" set "fileSkip=true"
                if /i "!fileName:~0,9!"  == "POWERTOYS" set "fileSkip=true"

                if !fileSkip! == false (
                    del /q /f "%%f" && echo Deleted file - %%f
                ) else (
                    echo Filtered file - %%f
                )
            )
        ) else (
            del /q /f /s "%SystemRoot%\Prefetch\*"
        )

        del /q /f /s "%SystemRoot%\SoftwareDistribution\*"
        del /q /f /s "%SystemRoot%\SystemTemp\*"
        del /q /f /s "%SystemRoot%\Temp\*"

        for /d %%d in ("%SystemRoot%\Prefetch\*") do rd /q /s "%%d"
        for /d %%d in ("%SystemRoot%\SoftwareDistribution\*") do rd /q /s "%%d"
        for /d %%d in ("%SystemRoot%\SystemTemp\*") do rd /q /s "%%d"
        for /d %%d in ("%SystemRoot%\Temp\*") do rd /q /s "%%d"
    endlocal

    if /i "%deleteDownloads%" == "Y" (
        echo.
        echo Deleting All Downloads...
        del /q /f "%UserProfile%\Downloads\*" && for /d %%d in ("%UserProfile%\Downloads\*") do rd /q /s "%%d"
    )

    if /i "%deleteSelfTasks%" == "Y" (
        echo.
        echo Deleting All This Triches...
        rmdir /q /s "%~dp0"
    )

    echo.
    echo Process complete!
) else (
    echo You choose not to continue...
)

pause
