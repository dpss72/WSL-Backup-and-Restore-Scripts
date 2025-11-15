@echo off
setlocal enabledelayedexpansion

:: Configuration - Use relative paths
set BACKUP_DIR=%~dp0Backup
set INSTALL_DIR=%~dp0

:: Display header
echo ========================================
echo WSL Restore Script - All Distributions
echo ========================================
echo Backup Location: %BACKUP_DIR%
echo Install Location: %INSTALL_DIR%
echo ========================================
echo.

:: Check if backup directory exists
if not exist "%BACKUP_DIR%" (
    echo ERROR: Backup directory does not exist: %BACKUP_DIR%
    echo.
    pause
    exit /b 1
)

:: Check for backup files
dir /b "%BACKUP_DIR%\*.tar" >nul 2>&1
if errorlevel 1 (
    echo ERROR: No backup files found in %BACKUP_DIR%
    echo.
    pause
    exit /b 1
)

echo Scanning for backups...
echo.
echo Available backups:
echo.

:: List all backup files
dir /b /o-d "%BACKUP_DIR%\*.tar"
echo.

set TOTAL_RESTORED=0
set TOTAL_FAILED=0
set TOTAL_SKIPPED=0

:: Create a list of processed distributions to avoid duplicates
set "PROCESSED_DISTROS= "

:: Process backup files (sorted by date, newest first)
for /f "delims=" %%F in ('dir /b /o-d "%BACKUP_DIR%\*.tar" 2^>nul') do (
    set "FILENAME=%%~nF"
    
    :: Extract distribution name (everything before first underscore)
    for /f "tokens=1 delims=_" %%a in ("!FILENAME!") do (
        set "DISTRO_NAME=%%a"
        
        :: Check if we've already processed this distribution
        echo !PROCESSED_DISTROS! | findstr /i " !DISTRO_NAME! " >nul
        if errorlevel 1 (
            :: Not processed yet, restore this one
            set "BACKUP_FILE=%BACKUP_DIR%\%%F"
            call :RestoreDistro "!DISTRO_NAME!" "!BACKUP_FILE!"
            
            :: Mark as processed
            set "PROCESSED_DISTROS=!PROCESSED_DISTROS!!DISTRO_NAME! "
        )
    )
)

:: Display summary
echo.
echo ========================================
echo Restore Summary
echo ========================================
echo Total restored: %TOTAL_RESTORED%
echo Already exists (skipped): %TOTAL_SKIPPED%
echo Failed: %TOTAL_FAILED%
echo Completed: %date% %time%
echo ========================================
echo.

:: Show current distributions
echo Current WSL distributions:
wsl -l -v
echo.

pause
exit /b

:RestoreDistro
set "DISTRO_NAME=%~1"
set "BACKUP_FILE=%~2"

echo ----------------------------------------
echo Distribution: %DISTRO_NAME%
echo ----------------------------------------
echo Backup file: %~nx2

:: Check if distribution already exists
wsl -l -v 2>nul | findstr /i "%DISTRO_NAME%" >nul
if not errorlevel 1 (
    echo WARNING: Distribution '%DISTRO_NAME%' already exists!
    set /p OVERWRITE="Overwrite existing distribution? (yes/no): "
    if /i not "!OVERWRITE!"=="yes" (
        echo SKIPPED: %DISTRO_NAME%
        set /a TOTAL_SKIPPED+=1
        echo.
        goto :eof
    )
    echo Removing existing distribution...
    wsl --unregister %DISTRO_NAME% 2>nul
    timeout /t 2 /nobreak >nul
)

:: Create distribution directory with full path
set "DISTRO_DIR=%INSTALL_DIR%%DISTRO_NAME%"
echo Target directory: %DISTRO_DIR%

:: Clean up - remove both files and directories with this name
if exist "%DISTRO_DIR%" (
    echo Cleaning up existing path...
    
    :: Try to delete as file first
    del /f /q "%DISTRO_DIR%" 2>nul
    
    :: Then try as directory
    rd /s /q "%DISTRO_DIR%" 2>nul
    
    timeout /t 1 /nobreak >nul
)

:: Create fresh directory
echo Creating directory...
md "%DISTRO_DIR%"

:: Verify directory was created
if not exist "%DISTRO_DIR%" (
    echo ERROR: Failed to create directory: %DISTRO_DIR%
    set /a TOTAL_FAILED+=1
    echo.
    goto :eof
)

echo Directory ready: %DISTRO_DIR%

:: Get and display file size (fixed calculation for large files)
for /f "tokens=3" %%s in ('dir /-c "%BACKUP_FILE%" 2^>nul ^| findstr /i "%~nx2"') do (
    set FILESIZE=%%s
)

if defined FILESIZE (
    :: Use PowerShell for large number calculation
    for /f %%m in ('powershell -command "[math]::Round(!FILESIZE! / 1MB, 2)"') do set FILESIZE_MB=%%m
    echo Backup size: !FILESIZE_MB! MB
)

:: Import distribution
echo.
echo Restoring %DISTRO_NAME%...
echo Please wait, this may take several minutes...

wsl --import "%DISTRO_NAME%" "%DISTRO_DIR%" "%BACKUP_FILE%"

if !errorlevel! equ 0 (
    echo.
    echo SUCCESS: %DISTRO_NAME% has been restored
    echo Location: %DISTRO_DIR%
    set /a TOTAL_RESTORED+=1
) else (
    echo.
    echo ERROR: Failed to restore %DISTRO_NAME%
    set /a TOTAL_FAILED+=1
)
echo.

goto :eof