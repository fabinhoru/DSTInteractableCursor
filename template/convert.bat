@echo off
setlocal enabledelayedexpansion

:: Go to the folder where scml.exe is
cd /d "C:\Program Files (x86)\Steam\steamapps\common\Don't Starve Mod Tools\mod_tools"

:: Handle each dragged .scml file
for %%F in (%*) do (
    set "input=%%~fF"
    set "outdir=%%~dpF"
    call :sanitize_and_run
)

pause
exit /b

:sanitize_and_run
:: Remove trailing backslash if it exists
if "!outdir:~-1!"=="\" set "outdir=!outdir:~0,-1!"

:: Run the command without wrapping outdir in quotes
:: ONLY if it doesn't contain spaces (for your specific case it doesn't)
scml.exe "!input!" "!outdir!"
goto :eof
