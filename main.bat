@echo off
title fourflash

cd /d c:\fourflash\platform-tools
if %errorlevel% neq 0 (
    echo =================================
    echo [!] Folder not found. Exiting..
    echo.
    pause >nul
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
echo =============================================================
echo fourflash / 3.0 / madebyzhh4
echo.
echo [1] Show all apps  [4] Device logs      [7] Ram Info
echo [2] Delete apps    [!] Not available    [8] State bootloader
echo [3] Screencast     [6] Characteristics  [9] About program
echo.
set /p choice="[!] Choose an option: "

if "%choice%"=="1" goto allapps
if "%choice%"=="2" goto delapps
if "%choice%"=="3" goto scrcrpy
if "%choice%"=="4" goto devicelogs
if "%choice%"=="5" goto exit /b
if "%choice%"=="6" goto charac
if "%choice%"=="7" goto raminfo
if "%choice%"=="8" goto ifphoneunlocked
if "%choice%"=="9" goto about

if "%choice%"=="fastboot reboot" fastboot reboot

:allapps
cls
adb shell pm list packages -f | findstr /i "package:" > log-of-apps.txt
if %errorlevel% neq 0 (
    echo Failed to retrieve the list of applications. Make sure the device is connected and ADB is enabled.
    pause >nul
    goto menu
)

echo =======================
echo List of installed applications:
for /f "tokens=2 delims==" %%A in (log-of-apps.txt) do (
    echo %%A
)

del log-of-apps.txt
echo.
pause >nul
goto menu

:delapps
cls
echo =========================================================================================
set /p package=Enter the package name of the application to delete (e.g., com.android.chrome): 
if "%package%"=="" (
    echo Package name cannot be empty.
    pause >nul
    goto menu
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
cd /d c:\fourflash\platform-tools
start scrcpy-noconsole.vbs
goto menu

:charac
cls
echo =======================================================================================================================
echo Manufacturer: 
adb -d shell getprop ro.product.brand
adb -d shell getprop ro.product.model
adb -d shell getprop ro.product.device
adb -d shell getprop ro.serialno
echo.
echo Android:
adb -d shell getprop ro.build.version.sdk
adb -d shell getprop ro.build.version.release
adb -d shell getprop ro.build.version.security_patch
adb -d shell getprop ro.build.type
adb -d shell getprop ro.build.version.codename
adb -d shell getprop ro.build.date
adb -d shell getprop ro.bootmode
echo.
echo SIM:
adb -d shell getprop gsm.operator.alpha
adb -d shell getprop gsm.sim.operator.numeric
adb -d shell getprop gsm.sim.state
adb -d shell getprop gsm.operator.iso-country
echo.
echo Characteristics:
adb shell "cat /proc/cpuinfo | grep Hardware"
echo.
echo Testing for root access...
adb shell su -c "echo root_have" >nul 2>nul

if %errorlevel% equ 0 (
    echo root_have
) else (
    echo root_doesnt
)

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

:raminfo
cls
echo =========================
adb devices | findstr /i "device" >nul 2>&1
if %errorlevel% neq 0 (
    echo Phone don`t detected.
    pause
    exit /b
)

echo Retrieving information...

adb shell dumpsys meminfo | findstr /r "^[ ]*[0-9]" > log-of-ram.txt

echo RAM Usage (PSS) by Processes:
for /f "tokens=1,2,3,* delims= " %%A in (log-of-ram.txt) do (
    echo RAM: %%A - Process: %%B %%C %%D
)

pause >nul
goto menu

:ifphoneunlocked
echo =================================
cls
adb reboot bootloader
    
fastboot getvar unlocked
fastboot reboot

pause >nul
goto menu


