@echo off
:: Check if the path argument is provided
if "%~1"=="" (
    echo Error: Target directory is not specified!
    echo Usage: %~nx0 "path_to_directory"
    exit /b
)

:: Save the argument to a variable (automatically stripping quotes)
set "target_dir=%~1"

:: Loop through each file extension and run the application
for %%e in (dpk dpr pas inc) do (
    AnsiToUtf8.exe "%target_dir%\*.%%e"
)
