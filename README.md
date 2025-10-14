# steam-game-recording-timeline-fixer

### description
steam game recording sometimes corrupts timeline json files: 
- replaces `entries` field with an object (should be array) 
- prefixes each entry in the array with a string (should be just objects).

In the background recording ui timeline markers won't display correctly and the save/share button won't work.

This fixes the most recent timeline file in your userdata\timelines folder.

### instructions
- open folder `C:\Program Files (x86)\Steam\userdata\timelines` 
- save fix.bat here
- run fix.bat
- check the file name it shows matches the most recent from the folder
- press y to continue and fix the file 
- restart steam and check if the timeline entries recordings are ok

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