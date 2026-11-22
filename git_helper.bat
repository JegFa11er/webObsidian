@echo off
cd /d "%~dp0"
setlocal enabledelayedexpansion

:MENU
cls
echo ========================================================
echo             GIT BRANCH AND PUSH MANAGER
echo ========================================================

for /f "tokens=*" %%i in ('git branch --show-current 2^>nul') do set CURRENT_BRANCH=%%i

if "%CURRENT_BRANCH%"=="" (
    echo [ERROR] Could not determine branch. Is .git folder present?
    pause
    exit /b
)

echo Current active branch: [%CURRENT_BRANCH%]
echo ========================================================
echo.
echo [1] Switch branch (main ^<--^> opencode-edits)
echo [2] Push changes (Add + Commit + Push to %CURRENT_BRANCH%)
echo [3] Show git status
echo [0] Exit
echo.
set /p CHOICE="Select action [0-3]: "

if "%CHOICE%"=="1" goto SWITCH_BRANCH
if "%CHOICE%"=="2" goto PUSH_CURRENT
if "%CHOICE%"=="3" goto SHOW_STATUS
if "%CHOICE%"=="0" exit /b
goto MENU


:SWITCH_BRANCH
cls
if /i "%CURRENT_BRANCH%"=="main" (
    set TARGET_BRANCH=opencode-edits
) else (
    set TARGET_BRANCH=main
)

echo Switching to branch: [%TARGET_BRANCH%]
git show-ref --verify --quiet refs/heads/%TARGET_BRANCH%
if errorlevel 1 (
    echo Local branch %TARGET_BRANCH% does not exist. Creating...
    git checkout -b %TARGET_BRANCH%
) else (
    echo Switching to existing branch %TARGET_BRANCH%...
    git checkout %TARGET_BRANCH%
)
echo.
pause
goto MENU


:PUSH_CURRENT
cls
git status --short
echo.
set /p COMMIT_MSG="Commit message (Enter for auto): "
if "%COMMIT_MSG%"=="" (
    for /f "tokens=1-4 delims=/:. " %%a in ("%date% %time%") do set DATETIME_STR=%%a-%%b %%c:%%d
    set COMMIT_MSG=Auto-update !DATETIME_STR! on %CURRENT_BRANCH%
)

echo 1. Indexing files...
git add .
echo 2. Committing...
git commit -m "%COMMIT_MSG%"
echo 3. Pushing...
git rev-parse --abbrev-ref --symbolic-full-name @{u} >nul 2>&1
if errorlevel 1 (
    git push -u origin %CURRENT_BRANCH%
) else (
    git push origin %CURRENT_BRANCH%
)
echo.
pause
goto MENU


:SHOW_STATUS
cls
git status
echo.
pause
goto MENU