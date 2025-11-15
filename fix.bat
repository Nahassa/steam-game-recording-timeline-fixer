@echo off
setlocal enabledelayedexpansion

echo Steam Game Recording Timeline Fixer
echo ====================================
echo.
echo Scanning for timeline JSON files...
echo.

REM Use PowerShell to find and fix all timeline JSON files
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference = 'Continue'; " ^
  "$fixedCount = 0; " ^
  "$skippedCount = 0; " ^
  "$errorCount = 0; " ^
  "$paths = @(); " ^
  "if (Test-Path 'timelines') { $paths += Get-ChildItem -Path 'timelines' -Filter '*.json' -File }; " ^
  "if (Test-Path 'clips') { $paths += Get-ChildItem -Path 'clips\*\timelines' -Filter '*.json' -File -Recurse }; " ^
  "if ($paths.Count -eq 0) { Write-Host 'No JSON files found in timelines folders'; exit 1 }; " ^
  "Write-Host \"Found $($paths.Count) JSON file(s) to check`n\"; " ^
  "foreach ($file in $paths) { " ^
  "  Write-Host \"Checking: $($file.FullName)\"; " ^
  "  try { " ^
  "    $json = Get-Content $file.FullName -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop; " ^
  "    if ($json.PSObject.Properties.Name -contains 'entries') { " ^
  "      $entriesType = $json.entries.GetType().Name; " ^
  "      if ($entriesType -eq 'PSCustomObject') { " ^
  "        Write-Host '  Status: INVALID - entries is an object, converting to array...' -ForegroundColor Yellow; " ^
  "        $json.entries = ($json.entries.PSObject.Properties | Sort-Object Name | ForEach-Object { $_.Value }); " ^
  "        $json | ConvertTo-Json -Depth 10 -Compress:$false | Set-Content $file.FullName -ErrorAction Stop; " ^
  "        Write-Host '  Result: FIXED' -ForegroundColor Green; " ^
  "        $fixedCount++; " ^
  "      } elseif ($entriesType -eq 'Object[]') { " ^
  "        Write-Host '  Status: OK - entries is already an array' -ForegroundColor Green; " ^
  "        $skippedCount++; " ^
  "      } else { " ^
  "        Write-Host \"  Status: UNKNOWN - entries type: $entriesType\" -ForegroundColor Cyan; " ^
  "        $skippedCount++; " ^
  "      } " ^
  "    } else { " ^
  "      Write-Host '  Status: SKIPPED - no entries field found' -ForegroundColor Gray; " ^
  "      $skippedCount++; " ^
  "    } " ^
  "  } catch { " ^
  "    Write-Host \"  Status: ERROR - $($_.Exception.Message)\" -ForegroundColor Red; " ^
  "    $errorCount++; " ^
  "  } " ^
  "  Write-Host ''; " ^
  "}; " ^
  "Write-Host '===================================='; " ^
  "Write-Host \"Summary:\"; " ^
  "Write-Host \"  Fixed: $fixedCount\"; " ^
  "Write-Host \"  Already valid: $skippedCount\"; " ^
  "Write-Host \"  Errors: $errorCount\"; " ^
  "if ($fixedCount -gt 0) { Write-Host \"`nRemember to restart Steam for changes to take effect!\" -ForegroundColor Yellow }"

echo.
pause
