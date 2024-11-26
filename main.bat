@echo off
title fourflash

cd /d C:\fourflash\platform-tools
if %errorlevel% neq 0 (
    echo [!] Folder not found. Exiting..
    echo.
    pause
    exit /b
)

:check
echo =================================
echo [!] Checking for ADB and Fastboot
echo.

where adb >nul 2>nul
if %errorlevel%==0 (
    echo [+] ADB Found!
) else (
    echo [-] ADB Not found.
)

where fastboot >nul 2>nul
if %errorlevel%==0 (
    echo [+] Fastboot Found!
) else (
    echo [-] Fastboot Not found.
)

goto menu

:menu
cls
echo =================================
echo fourflash / 1.0 / made by zhh4
echo.
echo [1] Reboot into bootloader
echo [2] Reboot into recovery
echo [3] Reboot into fastbootd
echo.
echo [4] Show all apps
echo [5] Delete apps
echo [6] Screencast
echo.
echo [7] Device logs
echo [8] About program
echo [9] Characteristics
echo.
echo [10] Exit
echo =================================
set /p choice="Choose an option: "

if "%choice%"=="1" goto bootloader
if "%choice%"=="2" goto recovery
if "%choice%"=="3" goto fastbootd
if "%choice%"=="4" goto allapps
if "%choice%"=="5" goto delapps
if "%choice%"=="6" goto scrcrpy
if "%choice%"=="7" goto devicelogs
if "%choice%"=="8" goto about
if "%choice%"=="9" goto charac
if "%choice%"=="txt" goto txt_joke
if "%choice%"=="10" goto exit /b


:bootloader
adb reboot bootloader
goto menu

:recovery
adb reboot recovery
goto menu

:fastbootd
adb reboot fastboot
goto menu

:allapps
cls
adb shell pm list packages -f | findstr /i "package:" > log-of-apps.txt
if %errorlevel% neq 0 (
    echo Failed to retrieve the list of applications. Make sure the device is connected and ADB is enabled.
    pause >nul
    goto main_menu
)

echo =======================
echo List of installed applications:
for /f "tokens=2 delims==" %%A in (log-of-apps.txt) do (
    echo %%A
)

del log-of-apps.txt
echo.
pause >nul
goto main_menu

:delapps
cls
echo =========================================================================================
set /p package=Enter the package name of the application to delete (e.g., com.android.chrome): 
if "%package%"=="" (
    echo Package name cannot be empty.
    pause >nul
    goto main_menu
)
cls
echo ==========================================================================
echo Deleting application %package%...
adb shell pm uninstall --user 0 %package% >nul 2>&1
if %errorlevel% neq 0 (
    echo Failed to delete the application. The package name might be incorrect.
    pause >nul
    goto main_menu
)

goto menu

:scrcrpy
cd /d C:\fourflash\screen-cast
start scrcpy-noconsole.vbs
goto menu

:charac
cls
echo =============================================================
echo Serial Number:
adb -d shell getprop ro.serialno
echo.
echo Phone Model:
adb -d shell getprop ro.product.model
echo.
echo Display Build Number:
adb -d shell getprop ro.build.display.id
echo.
echo SDK Version:
adb -d shell getprop ro.build.version.sdk
echo.
echo Fingerprint Build:
adb -d shell getprop ro.build.fingerprint
echo.
echo Android Codename:
adb -d shell getprop ro.build.version.codename
echo.
echo Brand Phone:
adb -d shell getprop ro.product.brand
echo.
echo Codename Device:
adb -d shell getprop ro.product.device
echo.
echo Bootloader Version: 
adb -d shell getprop ro.bootloader
echo.
echo Processor:
adb shell "cat /proc/cpuinfo | grep Hardware"
echo.
pause >nul
goto menu

:devicelogs
cls
echo ========================================================================================================================
echo Press any key to exit from logs.
timeout /t 2 /nobreak >nul
start "" cmd /c "adb logcat"
pause >nul
taskkill /f /im adb.exe >nul 2>&1
goto menu


:about
cls
echo ========================================================================================================================
echo The program was created to quickly flash the phone or reboot into some mode. Also, using the program you can find out everything about your phone.
echo. 
echo Fastboot Version
fastboot --version
echo.
echo ADB Verison
adb version
echo.
echo Made by zhh4 - https://t.me/zh4eny, https://www.youtube.com/@zhh4eny
echo.
pause >nul
goto menu
