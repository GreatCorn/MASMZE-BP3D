ENUM \
	MAZELOCK_NONE, \
	MAZELOCK_LOCKED, \
	MAZELOCK_UNLOCKED
	
ENUM \
	MAZETRAM_NONE, \
	MAZETRAM_ACCELERATE, \
	MAZETRAM_DECELERATE, \
	MAZETRAM_STOP

ENUM \
	MAZETYPE_NORMAL, \
	MAZETYPE_SQUIGGLY, \
	MAZETYPE_BROKEN
	
ENUML
	E MAZE_SAFE
	E MAZE_GAME
	E MAZE_STOP_SIREN
	E MAZE_WAIT_IMPACT
	E MAZE_SHAKE
	E MAZE_ENDING
	E MAZE_ASCEND
	E MAZE_ASCENDED
	E MAZE_WASTELAND_FADE_IN
	E MAZE_WASTELAND
	E MAZE_WASTELAND_FADE_OUT
	E MAZE_END
	E MAZE_CROA
	E MAZE_BORDER
	

.DATA
MazeByteSize 		DWORD 0
MazeDrawCull		DWORD 5		; The 'radius', in cells, to draw
MazeState 			BPEnum 0	; Used with intro and endings
MazeLevel			DWORD 0
MazeLevelPopup		BPEnum 0	; Maze layer popup, 0 = none, 1 = down, 2 = up
MazeLevelPopupY		REAL4 -48.0
MazeLevelPopupTimer	REAL4 0.0
MazeLocked 			BPEnum MAZELOCK_NONE
MazeSeed			DWORD 0		; Sneed's Feed & Seed (Formerly Chuck's)
MazeSize			DWORD 6, 6
MazeType			BPEnum MAZETYPE_NORMAL

MazeCheck			BPEnum FALSE	; Checkpoint state
MazeCheckDoorRot	REAL4 0.0		; Checkpoint exit door rotation

MazeCrevice 	BPBool FALSE	; Maze crevice active
MazeCrevicePos	DWORD 0, 0		; Maze crevice cell position

MazeDoorRot		REAL4 0.0				; Maze end door rotation
MazeDoorPos		Vector3 <0.0, 0.0, 0.0>	; Maze end door cell center position

MazeGlyphs		BPBool FALSE			; Maze glyphs item
MazeGlyphsPos	Vector3 <0.0, 0.0, 0.0>	; Glyphs item position in layer
MazeGlyphsRot	REAL4 0.0				; Glyphs item rotation

MazeKeyPos		Vector3 <0.0, 0.0, 0.0>	; Key position
MazeKeyRot		REAL4 0.0, 0.0			; Key rotation + target

MazeSiren		REAL4 0.0	; Siren gain etc (intro)
MazeSirenTimer	REAL4 51.0	; Siren timer (intro)

MazeTeleport		BPBool FALSE			; Teleporters state
MazeTeleportPos1	Vector3 <0.0, 0.0, 0.0>	; First tele position
MazeTeleportPos2	Vector3 <0.0, 0.0, 0.0>	; Second tele position
MazeTeleportRot		REAL4 0.0				; Teleporter rotation for animating

MazeTram		BPEnum MAZETRAM_NONE; Tram state
MazeTramDoors	DWORD 99		; Tram doors list to draw
MazeTramArea	DWORD 0, 0		; The area (X from, X to) that the rails occupy
MazeTramRot		DWORD 8, 0		; Tram direction (rotations[]) and REAL4 rotation
MazeTramPlr		BPEnum 0		; Tram player state
MazeTramPos		Vector3 <0.0, 0.0, 0.0>	; Tram position
MazeTramSpeed	REAL4 0.0			; Tram speed to accelerate
MazeTramSnd		DWORD 0				; Tram announcement sound index
MazeTramWait	REAL4 0.0			; Tram wait at stop timer

.CODE
Maze_GetRandomPos PROC EXPORT PosPtr:BPPtr
	
	ret
Maze_GetRandomPos ENDP
