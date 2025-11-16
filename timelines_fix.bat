@echo off
setlocal enabledelayedexpansion

REM Generate log filename with timestamp (dd-MM-yyyy HH-mm-ss format)
for /f "tokens=1-6 delims=/: " %%a in ("%date% %time%") do (
    set "logdate=%%c-%%b-%%a"
    set "logtime=%%d-%%e-%%f"
)
set "logfile=timelines_fix_%logdate%_%logtime%.log"

REM Start logging
echo Steam Game Recording Timeline Fixer > "%logfile%"
echo ==================================== >> "%logfile%"
echo Run started: %date% %time% >> "%logfile%"
echo. >> "%logfile%"

echo Steam Game Recording Timeline Fixer
echo ====================================
echo Log file: %logfile%
echo.
echo Scanning for timeline JSON files...
echo.

echo Scanning for timeline JSON files... >> "%logfile%"
echo. >> "%logfile%"

REM Use PowerShell to find and fix all timeline JSON files
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference = 'Continue'; " ^
  "$logFile = '%logfile%'; " ^
  "$fixedCount = 0; " ^
  "$skippedCount = 0; " ^
  "$errorCount = 0; " ^
  "$paths = @(); " ^
  "if (Test-Path 'timelines') { " ^
  "  $timelineFiles = Get-ChildItem -Path 'timelines' -Filter '*.json' -File -ErrorAction SilentlyContinue; " ^
  "  if ($timelineFiles) { $paths += $timelineFiles }; " ^
  "}; " ^
  "if (Test-Path 'clips') { " ^
  "  $clipTimelineFiles = Get-ChildItem -Path 'clips' -Recurse -Filter '*.json' -File -ErrorAction SilentlyContinue | Where-Object { $_.DirectoryName -like '*\timelines' }; " ^
  "  if ($clipTimelineFiles) { $paths += $clipTimelineFiles }; " ^
  "}; " ^
  "if ($paths.Count -eq 0) { " ^
  "  $msg = 'No JSON files found in timelines folders'; " ^
  "  Write-Host $msg; " ^
  "  Add-Content -Path $logFile -Value $msg; " ^
  "  exit 1; " ^
  "}; " ^
  "$msg = \"Found $($paths.Count) JSON file(s) to check`n\"; " ^
  "Write-Host $msg; " ^
  "Add-Content -Path $logFile -Value $msg; " ^
  "foreach ($file in $paths) { " ^
  "  $msg = \"Checking: $($file.FullName)\"; " ^
  "  Write-Host $msg; " ^
  "  Add-Content -Path $logFile -Value $msg; " ^
  "  try { " ^
  "    $json = Get-Content $file.FullName -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop; " ^
  "    if ($json.PSObject.Properties.Name -contains 'entries') { " ^
  "      $entriesType = $json.entries.GetType().Name; " ^
  "      if ($entriesType -eq 'PSCustomObject') { " ^
  "        $msg = '  Status: INVALID - entries is an object, converting to array...'; " ^
  "        Write-Host $msg -ForegroundColor Yellow; " ^
  "        Add-Content -Path $logFile -Value $msg; " ^
  "        $backupPath = $file.FullName + '.bak'; " ^
  "        Rename-Item -Path $file.FullName -NewName $backupPath -Force -ErrorAction Stop; " ^
  "        $msg = \"  Backup created: $backupPath\"; " ^
  "        Write-Host $msg -ForegroundColor Gray; " ^
  "        Add-Content -Path $logFile -Value $msg; " ^
  "        $json.entries = ($json.entries.PSObject.Properties | Sort-Object Name | ForEach-Object { $_.Value }); " ^
  "        $json | ConvertTo-Json -Depth 10 -Compress:$false | Set-Content $file.FullName -ErrorAction Stop; " ^
  "        $msg = '  Result: FIXED (original backed up to .bak)'; " ^
  "        Write-Host $msg -ForegroundColor Green; " ^
  "        Add-Content -Path $logFile -Value $msg; " ^
  "        $fixedCount++; " ^
  "      } elseif ($entriesType -eq 'Object[]') { " ^
  "        $msg = '  Status: OK - entries is already an array'; " ^
  "        Write-Host $msg -ForegroundColor Green; " ^
  "        Add-Content -Path $logFile -Value $msg; " ^
  "        $skippedCount++; " ^
  "      } else { " ^
  "        $msg = \"  Status: UNKNOWN - entries type: $entriesType\"; " ^
  "        Write-Host $msg -ForegroundColor Cyan; " ^
  "        Add-Content -Path $logFile -Value $msg; " ^
  "        $skippedCount++; " ^
  "      } " ^
  "    } else { " ^
  "      $msg = '  Status: SKIPPED - no entries field found'; " ^
  "      Write-Host $msg -ForegroundColor Gray; " ^
  "      Add-Content -Path $logFile -Value $msg; " ^
  "      $skippedCount++; " ^
  "    } " ^
  "  } catch { " ^
  "    $msg = \"  Status: ERROR - $($_.Exception.Message)\"; " ^
  "    Write-Host $msg -ForegroundColor Red; " ^
  "    Add-Content -Path $logFile -Value $msg; " ^
  "    $errorCount++; " ^
  "  } " ^
  "  Write-Host ''; " ^
  "  Add-Content -Path $logFile -Value ''; " ^
  "}; " ^
  "$msg = '===================================='; " ^
  "Write-Host $msg; " ^
  "Add-Content -Path $logFile -Value $msg; " ^
  "$msg = 'Summary:'; " ^
  "Write-Host $msg; " ^
  "Add-Content -Path $logFile -Value $msg; " ^
  "$msg = \"  Fixed: $fixedCount\"; " ^
  "Write-Host $msg; " ^
  "Add-Content -Path $logFile -Value $msg; " ^
  "$msg = \"  Already valid: $skippedCount\"; " ^
  "Write-Host $msg; " ^
  "Add-Content -Path $logFile -Value $msg; " ^
  "$msg = \"  Errors: $errorCount\"; " ^
  "Write-Host $msg; " ^
  "Add-Content -Path $logFile -Value $msg; " ^
  "if ($fixedCount -gt 0) { " ^
  "  $msg = \"`nOriginal files backed up with .bak extension\"; " ^
  "  Write-Host $msg -ForegroundColor Cyan; " ^
  "  Add-Content -Path $logFile -Value $msg; " ^
  "  $msg = \"Remember to restart Steam for changes to take effect!\"; " ^
  "  Write-Host $msg -ForegroundColor Yellow; " ^
  "  Add-Content -Path $logFile -Value $msg; " ^
  "}"

echo. >> "%logfile%"
echo Run completed: %date% %time% >> "%logfile%"

echo.
echo Log saved to: %logfile%
pause
