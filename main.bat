@echo off
title fourflash

cd /d c:\fourflash\platform-tools
if %errorlevel% neq 0 (
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
echo =================================
echo fourflash / 2.0 / #madebyzhh4
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
echo [10] Flash logo
echo [11] APK install
echo [12] Liveboot install
echo.
echo [13] Ram Info
echo [14] State bootloader
echo.
echo [15] Exit
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
if "%choice%"=="10" goto logo
if "%choice%"=="11" goto apkinstall
if "%choice%"=="12" goto liveboot
if "%choice%"=="13" goto raminfo
if "%choice%"=="14" goto ifphoneunlocked
if "%choice%"=="15" goto exit /b

if "%choice%"=="fastboot reboot" fastboot reboot

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
cd /d c:\fourflash\platform-tools
start scrcpy-noconsole.vbs
goto menu

:charac
cls
echo ==========================================================
echo Phone Brand:
adb -d shell getprop ro.product.brand
echo.
echo Phone Model:
adb -d shell getprop ro.product.model
echo.
echo Build Number:
adb -d shell getprop ro.build.display.id
echo.
echo SDK Version:
adb -d shell getprop ro.build.version.sdk
echo.
echo Android Version:
adb -d shell getprop ro.build.version.release
echo.
echo Security Patch:
adb -d shell getprop ro.build.version.security_patch
echo.
echo Type build:
adb -d shell getprop ro.build.type
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
echo Date of build: 
adb -d shell getprop ro.build.date
echo.
echo Bootmode:
adb -d shell getprop ro.bootmode
echo.
echo Processor:
adb shell "cat /proc/cpuinfo | grep Hardware"
echo.
echo Serial Number:
adb -d shell getprop ro.serialno
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

:logo
cls
echo ==========================================================================================
echo ATTENTION! WE ARE NOT RESPONSIBLE FOR YOUR DEVICE
timeout /t 1 /nobreak >nul
echo Rebooting to bootloader
adb reboot bootloader
echo Place logo.bin in the platform-tools folder.
echo Write Y if you have done this, N if you want to return to the main menu.
echo =================================
set /p choice="Choose an option: "

if "%choice%"=="y" goto logo2
if "%choice%"=="n" goto ifno

:logo2
fastboot flash logo logo.bin
echo Ready.
pause >nul
goto menu

:ifno
fastboot reboot
goto menu

:apkinstall
cls
echo ==========================================================================================
echo List of applications that can be downloaded
echo.
echo [1] Cherrygram
echo [2] Magisk
echo [3] OST-Tools
echo ===========================================
set /p choice="Choose an option: "

if "%choice%"=="1" goto cherrygram
if "%choice%"=="2" goto magisk
if "%choice%"=="3" goto ost-tools

:cherrygram
cls
set APK_URL=https://github.com/arsLan4k1390/Cherrygram/releases/download/8.7.0/Cherrygram-8.7.0-TG-11.2.3-universal.apk
set APK_NAME=cherrygram.apk

set DEST_DIR=%~dp0
echo Downloading %APK_NAME%...
cls

curl -L -o "%DEST_DIR%%APK_NAME%" %APK_URL%
cls

if %errorlevel% neq 0 (
    echo [!] Error: Failed to download APK.
    pause >nul
    goto menu
)

echo Installing %APK_NAME% on device...
adb install -r "%DEST_DIR%%APK_NAME%"

if %errorlevel% neq 0 (
    echo [!] Error: Failed to install APK.
    pause >nul
    goto menu
)

echo Deleting %APK_NAME%...
del "%DEST_DIR%%APK_NAME%"
cls

echo ===========================================
echo Done!
echo.
pause >nul
goto apkinstall

:magisk
cls
set APK_URL=https://github.com/topjohnwu/Magisk/releases/download/v28.0/Magisk-v28.0.apk
set APK_NAME=magisk.apk

set DEST_DIR=%~dp0
echo Downloading %APK_NAME%...
cls

curl -L -o "%DEST_DIR%%APK_NAME%" %APK_URL%
cls

if %errorlevel% neq 0 (
    echo [!] Error: Failed to download APK.
    pause >nul
    goto menu
)

echo Installing %APK_NAME% on device...
adb install -r "%DEST_DIR%%APK_NAME%"

if %errorlevel% neq 0 (
    echo [!] Error: Failed to install APK.
    pause >nul
    goto menu
)

echo Deleting %APK_NAME%...
del "%DEST_DIR%%APK_NAME%"
cls

echo ===========================================
echo Done!
echo.
pause >nul
goto apkinstall

:ost-tools
cls
set APK_URL=https://github.com/ost-sys/ost-program-android/releases/download/2.3.0/app-release.apk
set APK_NAME=osttools.apk

set DEST_DIR=%~dp0
echo Downloading %APK_NAME%...
cls

curl -L -o "%DEST_DIR%%APK_NAME%" %APK_URL%
cls

if %errorlevel% neq 0 (
    echo [!] Error: Failed to download APK.
    pause >nul
    goto menu
)

echo Installing %APK_NAME% on device...
adb install -r "%DEST_DIR%%APK_NAME%"

if %errorlevel% neq 0 (
    echo [!] Error: Failed to install APK.
    pause >nul
    goto menu
)

echo Deleting %APK_NAME%...
del "%DEST_DIR%%APK_NAME%"
cls

echo ===========================================
echo Done!
echo.
pause >nul
goto apkinstall

:liveboot
cls
set APK_URL=https://github.com/MADWIN11/fourflash-apk/releases/download/blablalba/LiveBoot-Pro-v1.92_build_192-Mod.apk
set APK_NAME=osttools.apk

set DEST_DIR=%~dp0
echo Downloading %APK_NAME%...
cls

curl -L -o "%DEST_DIR%%APK_NAME%" %APK_URL%
cls

if %errorlevel% neq 0 (
    echo [!] Error: Failed to download APK.
    pause >nul
    goto menu
)

echo Installing %APK_NAME% on device...
adb install -r "%DEST_DIR%%APK_NAME%"

if %errorlevel% neq 0 (
    echo [!] Error: Failed to install APK.
    pause >nul
    goto menu
)

echo Deleting %APK_NAME%...
del "%DEST_DIR%%APK_NAME%"
cls

echo ===========================================
echo The program also requires ROOT. Done!
echo.
pause >nul
goto apkinstall

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
goto main_menu



