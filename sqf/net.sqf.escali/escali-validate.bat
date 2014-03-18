REM 	Copyright (c) 2014 Nico Kutscherauer
	
REM 	This file is part of Escali Schematron.

REM 	Escali Schematron is free software: you can redistribute it and/or modify
REM 	it under the terms of the GNU General Public License as published by
REM 	the Free Software Foundation, either version 3 of the License, or
REM 	(at your option) any later version.

REM 	Escali Schematron is distributed in the hope that it will be useful,
REM 	but WITHOUT ANY WARRANTY; without even the implied warranty of
REM 	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
REM 	GNU General Public License for more details.

REM 	You should have received a copy of the GNU General Public License
REM 	along with Escali Schematron.  If not, see http://www.gnu.org/licenses/gpl-3.0.


@echo off

set CALL_DIR=%CD%
set ESCALI_DIR=%~dp0

set SOURCE=%~f1
set SCHEMA=%~f2

set CALABASH=%ESCALI_DIR%lib\calabash\
set OUT=%~f3
set CONFIG=%ESCALI_DIR%\META-INF\config.xml
set HTML=%ESCALI_DIR%\temp\report.html

set USER_ENTRY=%4

cd %CALABASH%


java -cp "calabash.jar; lib/" com.xmlcalabash.drivers.Main --input source=%SOURCE% --input schema=%SCHEMA% --input config=%CONFIG% --output html=%HTML% %ESCALI_DIR%xml\xproc\escali-validation.xpl

%HTML%

if "%3"=="" goto eop

echo The schematron report should be opened automaticaly. If not you will find it here:
echo %HTML%
echo.
echo The Schematron report contains the IDs of the QuickFix to execute them:
echo.
echo Sample:
echo ID                      Descritpion
echo [fix] name-dxex-dxex    this is a QuickFix
echo.
echo In this example the ID is name-dxex-dxex.

echo Please enter the ID of the QuickFix to execute. If you do not want to execute a QuickFix, type exit.
echo.
set /p FIX_ID=ID of the QuickFix:
echo.

if "%FIX_ID%"=="exit" goto eop

if "%USER_ENTRY%"=="no" goto fix

echo.
echo If the QuickFix needs a user entry it is listed on the report.
echo Sample:
echo ID                            Descritpion
echo [fix] name-dxex-dxex          this is a QuickFix
echo      [user-entry] entry-name  This is an user entry
echo      [user-entry] other-entry This is another user entry
echo.
echo In order to set the value of the user entry type it using following pattern:
echo entry-name="[value]";other-entry="[next-value]"
echo.
echo. If the QuickFix does not have user entries just use the [enter] key
echo.
set /p ENTRIES=Enter the user entries of the fixes:
echo.

:fix
java -cp "calabash.jar; lib/" com.xmlcalabash.drivers.Main --input config=%CONFIG% %ESCALI_DIR%xml\xproc\escali-quickFix.xpl fixId=%FIX_ID% userEntries=%ENTRIES%

copy %ESCALI_DIR%\temp\tempOutput.xml %OUT%

:eop

cd %CALL_DIR%