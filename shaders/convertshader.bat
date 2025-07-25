@echo off
setlocal

set vsfile=%~1
set psfile=%~dpn1.ps

if not exist "%vsfile%" (
    echo Missing .vs file!
    pause
)

cd /d "C:\Program Files (x86)\Steam\steamapps\common\Don't Starve Mod Tools\mod_tools\tools\bin"

ShaderCompiler.exe -little "%~n1" "%vsfile%" "%psfile%" "%~n1.ksh" -oglsl
echo DONEZO!
pause
