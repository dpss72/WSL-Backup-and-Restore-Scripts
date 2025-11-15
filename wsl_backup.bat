@echo off
setlocal enabledelayedexpansion

:: Configuration - Use relative paths
set BACKUP_DIR=%~dp0Backup
set TIMESTAMP=%date:~-4%%date:~-7,2%%date:~-10,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%

:: Create backup directory if it doesn't exist
if not exist "%BACKUP_DIR%" (
    echo Creating backup directory: %BACKUP_DIR%
    mkdir "%BACKUP_DIR%"
)

:: Display header
echo ========================================
echo WSL Backup Script - All Distributions
echo ========================================
echo Backup Location: %BACKUP_DIR%
echo Started: %date% %time%
echo ========================================
echo.

:: Check if WSL is installed and has distributions
wsl --status >nul 2>&1
if errorlevel 1 (
    echo ERROR: WSL is not installed!
    pause
    exit /b 1
)

echo Detecting WSL distributions...
echo.

:: List of common distributions to check
call :BackupDistro "Ubuntu"
call :BackupDistro "Ubuntu-20.04"
call :BackupDistro "Ubuntu-22.04"
call :BackupDistro "Ubuntu-24.04"
call :BackupDistro "Debian"
call :BackupDistro "kali-linux"
call :BackupDistro "openSUSE-Leap-15.5"
call :BackupDistro "openSUSE-Leap-15.6"
call :BackupDistro "Alpine"
call :BackupDistro "Fedora"
call :BackupDistro "docker-desktop"
call :BackupDistro "docker-desktop-data"

:: Display summary
echo.
echo ========================================
echo Backup Summary
echo ========================================
echo Total distributions: %TOTAL_DISTROS%
echo Successful backups: %SUCCESS_COUNT%
echo Failed backups: %FAILED_COUNT%
echo Completed: %date% %time%
echo ========================================
echo.

if %TOTAL_DISTROS% equ 0 (
    echo No WSL distributions were backed up!
    echo.
    echo Please check your WSL installation:
    wsl -l -v
)

pause
exit /b

:BackupDistro
set "DISTRO_NAME=%~1"

:: Try to terminate the distribution to check if it exists
wsl --terminate %DISTRO_NAME% >nul 2>&1
if errorlevel 1 (
    :: Distribution doesn't exist, skip it
    goto :eof
)

if not defined TOTAL_DISTROS set TOTAL_DISTROS=0
if not defined SUCCESS_COUNT set SUCCESS_COUNT=0
if not defined FAILED_COUNT set FAILED_COUNT=0

set /a TOTAL_DISTROS+=1

echo ----------------------------------------
echo Distribution: %DISTRO_NAME%
echo ----------------------------------------

set "BACKUP_FILE=%BACKUP_DIR%\%DISTRO_NAME%_%TIMESTAMP%.tar"

:: Stop distribution if running
echo Stopping %DISTRO_NAME% if running...
wsl --terminate %DISTRO_NAME% 2>nul
timeout /t 2 /nobreak >nul

:: Export distribution
echo Creating backup: %DISTRO_NAME%_%TIMESTAMP%.tar
echo Please wait, this may take several minutes...
wsl --export %DISTRO_NAME% "%BACKUP_FILE%"

if %errorlevel% equ 0 (
    :: Get file size (fixed calculation for large files)
    for %%F in ("%BACKUP_FILE%") do (
        set FILESIZE=%%~zF
    )
    if defined FILESIZE (
        set /a FILESIZE_MB=!FILESIZE! / 1048576
        echo SUCCESS: Backup completed - !FILESIZE_MB! MB
    ) else (
        echo SUCCESS: Backup completed
    )
    set /a SUCCESS_COUNT+=1
) else (
    echo ERROR: Backup failed for %DISTRO_NAME%
    set /a FAILED_COUNT+=1
)
echo.

goto :eof