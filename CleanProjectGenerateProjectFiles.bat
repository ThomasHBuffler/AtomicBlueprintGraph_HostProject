@echo off
REM Unreal Project Cleaner + Visual Studio Project Generator
REM Deletes Intermediate, Binaries, Saved, DerivedDataCache folders and .sln files
REM Then regenerates Visual Studio project files

SET "PROJECT_PATH=%~dp0"
echo ===================================================
echo Unreal Project Cleanup and Regeneration
echo ===================================================
echo Project: %PROJECT_PATH%
echo.

REM ===================================================
REM STEP 1: CLEAN PROJECT
REM ===================================================
echo [1/2] Cleaning project...
echo.

REM Clean main project folder
CALL :CleanFolder "%PROJECT_PATH%"

REM Clean each plugin folder
IF EXIST "%PROJECT_PATH%Plugins" (
    FOR /D %%P IN ("%PROJECT_PATH%Plugins\*") DO (
        CALL :CleanFolder "%%P\"
    )
)

echo.
echo Cleanup complete!
echo.

REM ===================================================
REM STEP 2: GENERATE PROJECT FILES
REM ===================================================
echo [2/2] Generating Visual Studio project files...
echo.

REM Find the .uproject file in current directory
SET "UPROJECT_FILE="
FOR %%F IN ("%PROJECT_PATH%*.uproject") DO (
    SET "UPROJECT_FILE=%%F"
    GOTO :FoundProject
)

:FoundProject
IF "%UPROJECT_FILE%"=="" (
    echo Error: No .uproject file found in %PROJECT_PATH%
    echo Please place this script in your Unreal project folder.
    pause
    exit /b 1
)

echo Found project: %UPROJECT_FILE%

REM Find UnrealVersionSelector.exe
SET "UVSEL="

REM Method 1: Check registry
FOR /f "tokens=2*" %%a IN ('reg query "HKLM\SOFTWARE\Classes\.uproject\shell\rungenproj\command" /ve 2^>nul ^| find "REG_SZ"') DO (
    SET "REGCMD=%%b"
    REM Extract path from quotes
    FOR /f "tokens=1 delims= " %%c IN ("!REGCMD!") DO (
        SET "UVSEL=%%~c"
    )
)

REM Method 2: Check common install locations
IF NOT EXIST "%UVSEL%" (
    IF EXIST "%ProgramFiles(x86)%\Epic Games\Launcher\Engine\Binaries\Win64\UnrealVersionSelector.exe" (
        SET "UVSEL=%ProgramFiles(x86)%\Epic Games\Launcher\Engine\Binaries\Win64\UnrealVersionSelector.exe"
    )
)

IF NOT EXIST "%UVSEL%" (
    IF EXIST "%ProgramFiles%\Epic Games\Launcher\Engine\Binaries\Win64\UnrealVersionSelector.exe" (
        SET "UVSEL=%ProgramFiles%\Epic Games\Launcher\Engine\Binaries\Win64\UnrealVersionSelector.exe"
    )
)

IF NOT EXIST "%UVSEL%" (
    echo Error: Could not find UnrealVersionSelector.exe
    echo Please ensure Unreal Engine is properly installed.
    pause
    exit /b 1
)

echo Found UnrealVersionSelector: %UVSEL%
echo.

REM Execute the command
"%UVSEL%" /projectfiles "%UPROJECT_FILE%"

IF ERRORLEVEL 1 (
    echo.
    echo Error: Failed to generate project files
    pause
    exit /b %errorlevel%
)

echo.
echo ===================================================
echo SUCCESS! Project cleaned and regenerated!
echo ===================================================
pause
exit /b 0

REM ===================================================
REM SUBROUTINE: Clean a folder
REM ===================================================
:CleanFolder
SET "CURRENT_PATH=%~1"
FOR %%F IN (Intermediate Binaries Saved DerivedDataCache Derived) DO (
    IF EXIST "%CURRENT_PATH%%%F" (
        echo Deleting %%F folder in %CURRENT_PATH%...
        rmdir /s /q "%CURRENT_PATH%%%F"
    )
)
FOR %%S IN ("%CURRENT_PATH%*.sln") DO (
    IF EXIST "%%S" (
        echo Deleting %%~nxS file in %CURRENT_PATH%...
        del /q "%%S"
    )
)
GOTO :EOF