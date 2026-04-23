@echo off
REM Unreal Project Cleaner - Deletes Intermediate, Binaries, Saved, DerivedDataCache folders and .sln files
REM Also traverses Plugins folder

SET "PROJECT_PATH=%~dp0"

echo Cleaning Unreal project at: %PROJECT_PATH%

REM Function to clean a folder
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

REM Clean main project folder
CALL :CleanFolder "%PROJECT_PATH%"

REM Clean each plugin folder
IF EXIST "%PROJECT_PATH%Plugins" (
    FOR /D %%P IN ("%PROJECT_PATH%Plugins\*") DO (
        CALL :CleanFolder "%%P\"
    )
)

echo Cleanup complete.
pause
