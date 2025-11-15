# steam-game-recording-timeline-fixer

### description
steam game recording sometimes corrupts timeline json files:
- replaces `entries` field with an object (should be array)
- prefixes each entry in the array with a string (should be just objects).

In the background recording ui timeline markers won't display correctly and the save/share button won't work.

This script automatically scans and fixes **all** timeline files in:
- `timelines\` folder (main recordings)
- `clips\*\timelines\` folders (all clip recordings, across all games)

### instructions
- locate your Steam Recordings folder (e.g., `C:\Program Files (x86)\Steam\userdata\<userid>\760\remote\<appid>\screenshots` or wherever you've configured Steam to save recordings)
- save timelines_fix.bat in the **Steam Recordings** folder (the parent folder containing `timelines` and `clips` subfolders)
- run timelines_fix.bat
- the script will automatically:
  - scan for all JSON files in timelines and clips folders
  - validate each file's JSON structure
  - convert `entries` from object to sorted array (only if needed)
  - skip files that are already valid
  - show detailed status for each file processed
  - create a timestamped log file (timelines_fix_dd-MM-yyyy_HH-mm-ss.log)
- restart steam and check if the timeline entries recordings are ok

### what the script does
- **Validates** all JSON files before attempting fixes
- **Detects** if `entries` is an object (invalid) or array (valid)
- **Backs up** original files to `.bak` before fixing (e.g., `timeline.json` → `timeline.json.bak`)
- **Creates** new fixed files with the original filename
- **Skips** files that are already correct
- **Reports** summary of fixed/skipped/error counts
- **Logs** all output to a timestamped log file for review

**Note:** Original corrupted files are safely preserved as `.bak` files, allowing you to recover them if needed.

### corrupt example
```json
{
	"daterecorded": "1760400462",
	"starttime": "0",
	"entries": { <- broken
  broken -> "0": { 
			"id": "5",
			"time": "9456",
			"type": "gamemode",
			"mode": 3
		}
,
  broken -> "1": { 
			"id": "6",
			"time": "11567",
			"type": "gamemode",
			"mode": 3
		}

    } <- broken
,
	"endtime": "29749"
}
```

### normal example
```json
{
	"daterecorded": "1760400462",
	"starttime": "0",
	"entries": [
		{
			"id": "5",
			"time": "9456",
			"type": "gamemode",
			"mode": 3
		}
,
		{
			"id": "6",
			"time": "11567",
			"type": "gamemode",
			"mode": 3
		}

    ]
,
	"endtime": "29749"
}
```