@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
for /f %%a in ('echo prompt $E ^| cmd') do set ESC=%%a
set result=""
set RED=%ESC%[31m
set YELLOW=%ESC%[33m
set BLUE=%ESC%[34m
set RESET=%ESC%[0m
REM EQU - equal
REM NEQ - not equal
REM LSS - less than
REM LEQ - less than or equal
REM GTR - greater than
REM GEQ - greater than or equal


set nbMod=3

:Startup
cls
set str1=┌
set str2=│
set str3=│
set str4=│
set str5=└

set timerMinute = %time:~3,2%
set /A timerMinute = %time:~3,2%+1
set /A timerSecond = %time:~6,2%

for /l %%i in (1,1,%nbMod%) do (
    set /A listMod[%%i]=!RANDOM! * 1 / 32768 + 1
    REM set /A listMod[%%i] = 1
    set str1=!str1!───────
    call :moduleDisplay !listMod[%%i]!
    set str5=!str5!───────

    if %%i==%nbMod% (
        set str1=!str1!┐
        set str5=!str5!┘
    ) else (
        set str1=!str1!┬
        set str5=!str5!┴
    )
)
goto base
exit /b

:failed
echo failed
echo with %timerMinute%:%timerSecond%
if %time:~3,2% GEQ %timerMinute% (
    if %time:~6,2% GEQ %timerSecond% (
        echo %time:~3,2%:%time:~6,2%
        echo %timerMinute%:%timerSecond%
    )
)
if %~1 NEQ !correctWire! (
    echo current: %~1
    echo answer: !correctWire!
    echo !rules1!
    for /l %%i in (1,1,!nbWire!) do (
        echo %%i: !listColor[%%i]!
    )
)
pause
goto startup

:win
echo you Win
echo with %timerMinute%:%timerSecond%
pause
goto startup

:base
cls
set result=%nbMod%
for /l %%i in (1,1,%nbMod%) do (
    if !listMod[%%i]!==-1 (
        set /A result=!result!-1
    )
)

if %time:~3,2% GEQ %timerMinute% (
    if %time:~6,2% GEQ %timerSecond% (goto failed)
)

if !result!==0 (goto win)
echo need %result% to finish / %time:~3,2%:%time:~6,2%
echo !str1!
echo !str2!
echo !str3!
echo !str4!
echo !str5!

set /P input="Choose module: "
call :modRedirect %input%
goto base

REM 1=Wire 2=Button 3=Keypad
:moduleDisplay
if "%~1"=="1" (
    set str2=!str2!~~~~~~~│
    set str3=!str3!~~~~~~~│
    set str4=!str4!~~~~~~~│
) else if "%~1"=="3" (
    set str2=!str2! /───\ │
    set str3=!str3!  ---  │
    set str4=!str4! \───/ │
) else if "%~1"=="2" (
    set str2=!str2! ┌─┬─┐ │
    set str3=!str3! ├─┼─┤ │
    set str4=!str4! └─┴─┘ │
) else if "%~1"=="-1" (
    set str2=!str2!       │
    set str3=!str3!       │
    set str4=!str4!       │
) else (
    set str2=!str2! error │
    set str3=!str3! error │
    set str4=!str4! error │
)
exit /b

REM 1=RED 2=YELLOW 3=BLUE 4=BLACK
:intToColor
if "%~1"=="1" (
    set color=!RED!
) else if "%~1"=="2" (
    set color=!YELLOW!
) else if "%~1"=="3" (
    set color=!BLUE!
) else (
    set color=!RESET!
)
exit /b

:modRedirect
if "!listMod[%~1]!"=="1" (call :modWires %~1)
if "!listMod[%~1]!"=="3" (call :modButton %~1)
if "!listMod[%~1]!"=="2" (call :modKeypad %~1)
echo !listMod[%~1]!
goto base
exit /b

:modWires
cls
set /A nbWire= 2 + !RANDOM! * 2 / 32768 + 1
echo ┌────────┐
for /l %%i in (1,1,!nbWire!) do (
    set /A listColor[%%i]=!RANDOM! * 4 / 32768 + 1
    call :intToColor !listColor[%%i]!
    echo │%%i!color!~~~~~~~!RESET!│
)
echo └────────┘
set response=0
set /P response="(x to exit) which Wires to you cut ?: "
if /i "%response%"=="x" (goto base)
call :verifyWires !response!
goto startup

REM ─ Si 3 cables ───
REM If there are no white wires and the serial number starts with a letter, cut the second wire.
REM If there is exactly one red wire, cut the first wire.
REM If there is more than one blue wire, cut the first blue wire.
REM If the last wire is red, cut the last wire.
REM Otherwise, cut the second wire

REM ─ Si 4 cables ───
REM If there is exactly one yellow wire and the last wire is red, cut the third wire.
REM Otherwise, If the last wire is white, cut the second wire.
REM Otherwise, If there are no yellow wires, cut the first wire.
REM Otherwise, cut the last wire

:verifyWires
set correctWire=0
set rules1=0
set rules2=0
set rules3=0
set rules3bis=0
if !nbWire!==3 (
	for /l %%i in (1,1,3) do (
		if !listColor[%%i]!==1 (set rules1=1)
		if !listColor[%%i]!==3 (
			set /A rules3=!rules3!+1
			set rules3bis=%%i
		)
	)
	if !rules1!==0 (set correctWire=2
	) else if !listColor[3]!==4 (set correctWire=3
    ) else if !rules3! GTR 1 (set correctWire=!rules3bis!
    ) else (set correctWire=%nbWire%)

) else if !nbWire!==4 (
    for /l %%i in (1,1,4) do (
        if !listColor[%%i]!==2 (
            set /A rules1=!rules1!+1
        )
    )
    if !rules1!==1 (if !listColor[4]!==1 (set correctWire=3))
    if !correctWire!!==0 (
        if !listColor[4]!==4 (set correctWire=2
        ) else if !rules1!==0 (set correctWire=1
        ) else (set correctWire=4)
    )
) else (
	echo undifined rules
    echo nbWire: !nbWire!
)
if %~1==!correctWire! (
    set listMod[%input%]=-1
    goto base
) else (
    goto failed
)
pause
exit /b

:modButton
echo button
pause
exit /b

:modKeypad
echo keypad
set /A idList=!RANDOM! * 6 / 32768 + 1
if %idList%==1 (set keypadList=ϬҨҖ☆¶Ͽζ)
if %idList%==2 (set keypadList=ҨҊƛѦϫ¶Җ)
if %idList%==3 (set keypadList=ѬϬϗζΨƛω)
if %idList%==4 (set keypadList=ѬAB©ϞϿϗ)
if %idList%==5 (set keypadList=Ϙ©¿Ѫ☆★ϫ)
if %idList%==6 (set keypadList=ӕԆӬѪѣωΨ)
echo %idList%:%keypadList%
set /A keypadSymbol1=!RANDOM! * 4 / 32768
set /A keypadSymbol2=!RANDOM! * 4 / 32768
set /A keypadSymbol3=!RANDOM! * 4 / 32768
set /A keypadSymbol4=!RANDOM! * 4 / 32768

:ensureUnique
if !keypadSymbol1!==!keypadSymbol2! (set /A keypadSymbol2=!RANDOM! * 4 / 32768 & goto ensureUnique)
if !keypadSymbol1!==!keypadSymbol3! (set /A keypadSymbol3=!RANDOM! * 4 / 32768 & goto ensureUnique)
if !keypadSymbol1!==!keypadSymbol4! (set /A keypadSymbol4=!RANDOM! * 4 / 32768 & goto ensureUnique)
if !keypadSymbol2!==!keypadSymbol3! (set /A keypadSymbol3=!RANDOM! * 4 / 32768 & goto ensureUnique)
if !keypadSymbol2!==!keypadSymbol4! (set /A keypadSymbol4=!RANDOM! * 4 / 32768 & goto ensureUnique)
if !keypadSymbol3!==!keypadSymbol4! (set /A keypadSymbol4=!RANDOM! * 4 / 32768 & goto ensureUnique)
set keypadSymbol1=!keypadList:~%keypadSymbol1%,1!
set keypadSymbol2=!keypadList:~%keypadSymbol2%,1!
set keypadSymbol3=!keypadList:~%keypadSymbol3%,1!
set keypadSymbol4=!keypadList:~%keypadSymbol4%,1!
if "!keypadSymbol1!"=="A" (set keypadSymbol1=ټ)
if "!keypadSymbol2!"=="A" (set keypadSymbol2=ټ)
if "!keypadSymbol3!"=="A" (set keypadSymbol3=ټ)
if "!keypadSymbol4!"=="A" (set keypadSymbol4=ټ)
if "!keypadSymbol1!"=="B" (set keypadSymbol1=҈)
if "!keypadSymbol2!"=="B" (set keypadSymbol2=҈)
if "!keypadSymbol3!"=="B" (set keypadSymbol3=҈)
if "!keypadSymbol4!"=="B" (set keypadSymbol4=҈)
echo ┌1┬2┐
echo │%keypadSymbol1%│%keypadSymbol2%│
echo ├─┼─┤
echo │%keypadSymbol3%│%keypadSymbol4%│
echo └3┴4┘
set /P response ="WIP (x to exit) which symbol do you press ?: "
if %response%==x (goto base)
exit /b


