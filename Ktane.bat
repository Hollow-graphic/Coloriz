@echo off
chcp 65001 >nul
set nbMod=3
set /A mod1=%RANDOM% * 3 / 32768 + 1
set /A mod2=%RANDOM% * 3 / 32768 + 1
set /A mod3=%RANDOM% * 3 / 32768 + 1
:base
cls
set str=""
for /l %x in (1, 1, 100) do (
   echo %x
   copy %x.txt z:\whatever\etc
)
echo "┌───────┬───────┬───────┐"
echo "|       |       |       |"
echo "|       |       |       |"
echo "|       |       |       |"
echo "└───────┴───────┴───────┘"

if %mod1%==1 (


set /P A="chose module:"
if %A%==1 (goto mod1)
goto base

:mod1
pause
echo mod1
goto mod1