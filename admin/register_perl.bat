@echo off

set "pathToInsert=C:\Perl64\bin"

echo %pathToInsert%

rem Check if pathToInsert is not already in system path
if "!path:%pathToInsert%=!" equ "%path%" (
   setx PATH "%PATH%;%pathToInsert%"
) else (echo %pathToInsert% PRESENT)

set "pathToInsert=C:\Perl64\site\bin"

echo %pathToInsert%

rem Check if pathToInsert is not already in system path
if "!path:%pathToInsert%=!" equ "%path%" (
   setx PATH "%PATH%;%pathToInsert%"
) else (echo %pathToInsert% PRESENT)