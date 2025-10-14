@echo off
setlocal enabledelayedexpansion

REM 
for /f "delims=" %%A in ('dir /b /a:-d /o-d *.json 2^>nul') do (
    set "infile=%%A"
    goto found
)

echo no JSON files found
exit /b 1

:found
REM 
for /f "tokens=1,2 delims=," %%a in ('forfiles /m "%infile%" /c "cmd /c echo @fdate,@ftime"') do (
    set "filedate=%%a"
    set "filetime=%%b"
)

echo.
echo latest JSON timeline file:
echo   filename: %infile%
echo   date: %filedate% %filetime%
echo.
set /p "choice=fix this file? (Y/N): "

if /i "%choice%"=="Y" (
    echo.
    echo fixing...
    powershell -NoProfile -Command ^
      "$path = '%infile%'; " ^
      "$json = Get-Content $path -Raw | ConvertFrom-Json; " ^
      "$json.entries = ($json.entries.PSObject.Properties | Sort-Object Name | ForEach-Object { $_.Value }); " ^
      "$json | ConvertTo-Json -Depth 10 | Set-Content $path"
    echo.
    echo file corrected: %infile%
    echo remember to restart steam
) else (
    echo.
    echo Cancelled.
)

pause
