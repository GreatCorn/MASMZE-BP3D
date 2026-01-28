MAZE_CELL_PASSTOP	EQU 00000001b
MAZE_CELL_PASSLEFT	EQU 00000010b
MAZE_CELL_VISITED	EQU 00000100b
MAZE_CELL_ROTATED	EQU 00001000b
MAZE_CELL_PROPS		EQU 11110000b

ENUM \
	MAZE_LOCK_NONE, \
	MAZE_LOCK_LOCKED, \
	MAZE_LOCK_UNLOCKED
	
ENUM \
	MAZE_TRAM_NONE, \
	MAZE_TRAM_ACCELERATE, \
	MAZE_TRAM_DECELERATE, \
	MAZE_TRAM_STOP

ENUM \
	MAZE_TYPE_NORMAL, \
	MAZE_TYPE_SQUIGGLY, \
	MAZE_TYPE_BROKEN
	
ENUM \
	MAZE_SLAM_NONE, \
	MAZE_SLAM_ACTIVE, \
	MAZE_SLAM_OPEN, \
	MAZE_SLAM_SLAM
	
ENUML
	E MAZE_STATE_SAFE
	E MAZE_STATE_GAME
	E MAZE_STATE_STOP_SIREN
	E MAZE_STATE_WAIT_IMPACT
	E MAZE_STATE_SHAKE
	E MAZE_STATE_ENDING
	E MAZE_STATE_ASCEND
	E MAZE_STATE_ASCENDED
	E MAZE_STATE_WASTELAND_FADE_IN
	E MAZE_STATE_WASTELAND
	E MAZE_STATE_WASTELAND_FADE_OUT
	E MAZE_STATE_END
	E MAZE_STATE_CROA
	E MAZE_STATE_BORDER
	

.DATA
Maze				BPPtr 0		; 2D BYTE array of dimensions MazeSize
MazeByteSize 		DWORD 0
MazeDrawCull		DWORD 5		; The 'radius', in cells, to draw
MazeEntranceCell	BPPtr 0		; Entrance cell offset (0 .. (width-1))
MazeGenerating		BPBool FALSE
MazeLayer			DWORD 1
MazeLayerPopup		BPEnum 0	; Maze layer popup, 0 = none, 1 = down, 2 = up
MazeLayerPopupY		REAL4 -48.0
MazeLayerPopupTimer	REAL4 0.0
MazeLocked 			BPEnum MAZE_LOCK_NONE
MazeSeed			DWORD 0		; Sneed's Feed & Seed (Formerly Chuck's)
MazeSize			DWORD 5, 5, ?, ?	; Width, height, width-1, height-1
MazeState 			BPEnum 0	; Used with intro and endings
MazeStateCallback	BPPtr 0
MazeStateTimer		REAL4 0.0
MazeType			BPEnum MAZE_TYPE_NORMAL

MazeCheck			BPEnum FALSE	; Checkpoint state
MazeCheckDoorRot	REAL4 0.0		; Checkpoint exit door rotation

MazeCrevice 	BPBool FALSE	; Maze crevice active
MazeCrevicePos	DWORD 0, 0		; Maze crevice cell position

MazeDoorRot		REAL4 0.0				; Maze end door rotation
MazeDoorPos		Vector3 <0.0, 0.0, 0.0>	; Maze end door cell center position

MazeSlam	BPEnum MAZE_SLAM_NONE	; Door slam event state
MazeSlamRot	REAL4 0.0				; The entrance door rotation (for drawing)

MazeGlyphs		BPBool FALSE			; Maze glyphs item
MazeGlyphsPos	Vector3 <0.0, 0.0, 0.0>	; Glyphs item position in layer
MazeGlyphsRot	REAL4 0.0				; Glyphs item rotation

MazeKeyPos		Vector3 <0.0, 0.0, 0.0>	; Key position
MazeKeyRot		REAL4 0.0, 0.0			; Key rotation + target

MazeSiren		REAL4 0.0	; Siren gain etc (intro)

MazeTeleport		BPBool FALSE			; Teleporters state
MazeTeleportPos1	Vector3 <0.0, 0.0, 0.0>	; First tele position
MazeTeleportPos2	Vector3 <0.0, 0.0, 0.0>	; Second tele position
MazeTeleportRot		REAL4 0.0				; Teleporter rotation for animating

MazeTram		BPEnum MAZE_TRAM_NONE; Tram state
MazeTramDoors	DWORD 99		; Tram doors list to draw
MazeTramArea	DWORD 0, 0		; The area (X from, X to) that the rails occupy
MazeTramRot		DWORD 8, 0		; Tram direction (rotations[]) and REAL4 rot
MazeTramPlr		BPEnum 0		; Tram player state
MazeTramPos		Vector3 <0.0, 0.0, 0.0>	; Tram position
MazeTramSpeed	REAL4 0.0			; Tram speed to accelerate
MazeTramSnd		DWORD 0				; Tram announcement sound index
MazeTramWait	REAL4 0.0			; Tram wait at stop timer

MazeTrench		BPBool FALSE

MazeShop		BPBool FALSE

MazePartAmb		ParticleSystem <>
MazePartDust	ParticleSystem <>

.DATA?
MazeCurFloor	DWORD ?	; Environmental variety
MazeCurRoof		DWORD ?
MazeCurWall		DWORD ?
MazeCurWallMDL	DWORD ?
MazePlrPos		Vector2 <?, ?>

.CODE
Maze_GetCellF PROTO :REAL4, :REAL4
Maze_GetCellI PROTO :SDWORD, :SDWORD
Maze_InRange PROTO :SDWORD, :SDWORD
Maze_OrCellI PROTO :SDWORD, :SDWORD, :BYTE

;   Clamp X and Y parameters to maze boundaries.
Maze_ClampXYI MACRO _X:=<X>, _Y:=<Y>
	mov _X, rv(intClamp, _X, 0, MazeSize[8])
	mov _Y, rv(intClamp, _Y, 0, MazeSize[12])
ENDM

Maze_Collide PROC EXPORT PosPtr:BPPtr
	LOCAL cell:BYTE, pos:Vector2, colPos:Vector3, bounds:Vector4, fpucw:WORD
	cellCollide MACRO _hor:REQ, _endW
		Vector32DPush colPos
		IF _hor EQ TRUE
			push pax
			
			sal colPos.X, 1	; *2
			inc colPos.X
			IFNB <_endW>
				inc colPos.Z
			ENDIF
			sal colPos.Z, 1	; *2
		ELSE
			IFNB <_endW>
				inc colPos.X
			ENDIF
			sal colPos.X, 1	; *2
			sal colPos.Z, 1	; *2
			inc colPos.Z
		ENDIF
		
		invoke Vector32DF, ADDR colPos
		IF _hor EQ TRUE		; Wall real size + 0.7 (player size)
			invoke Collide_Rectangle, PosPtr, ADDR colPos, f(2.8), f(0.9)
		ELSE
			invoke Collide_Rectangle, PosPtr, ADDR colPos, f(0.9), f(2.8)
		ENDIF
		
		IF _hor EQ TRUE
			pop pax
		ENDIF
		Vector32DPop colPos
	ENDM
		
	fnstcw fpucw
	or fpucw, FPU_ROUND_TRUNC
	fldcw fpucw
	
	mov pax, PosPtr
	fld REAL4 PTR [pax]
	fistp colPos.X
	fld REAL4 PTR [pax+8]
	fistp colPos.Z
	sar colPos.X, 1	; /2
	sar colPos.Z, 1	; /2
	
	xor fpucw, FPU_ROUND_TRUNC
	fldcw fpucw
	
	dec colPos.X
	mov ecx, colPos.X
	mov bounds.X, ecx
	dec colPos.Z
	mov edx, colPos.Z
	mov bounds.Y, edx
	add ecx, 2
	mov bounds.Z, ecx
	add edx, 2
	mov bounds.W, edx
	
	mov ecx, colPos.X
	.WHILE (SDWORD PTR ecx <= bounds.Z)
		mov edx, bounds.Y
		mov colPos.Z, edx
		.WHILE (SDWORD PTR edx <= bounds.W)
			.IF (rv(Maze_InRange, colPos.X, colPos.Z))
				invoke Maze_GetCellI, colPos.X, colPos.Z
				
				.IF !(al & MAZE_CELL_PASSTOP)
					cellCollide TRUE
				.ENDIF
				.IF !(al & MAZE_CELL_PASSLEFT)
					cellCollide FALSE
				.ENDIF
				
				mov eax, colPos.Z
				.IF (eax == MazeSize[12])
					cellCollide TRUE, TRUE
				.ENDIF
				mov eax, colPos.X
				.IF (eax == MazeSize[8])
					cellCollide FALSE, TRUE
				.ENDIF
			.ENDIF
			inc colPos.Z
			mov edx, colPos.Z
		.ENDW
		inc colPos.X
		mov ecx, colPos.X
	.ENDW
	
	ret
	ret
Maze_Collide ENDP

Maze_DrawDoor PROC EXPORT Rotation:REAL4
	invoke glBindTexture, GL_TEXTURE_2D, TexDoor
	invoke glCallList, MdlDoorFrame
	
	call glPushMatrix
	invoke glTranslatef, f(0.65), 0, 0
	.IF (Rotation)
		invoke glRotatef, Rotation, 0, f(1), 0
	.ENDIF
	invoke glCallList, MdlDoor
	call glPopMatrix
	ret
Maze_DrawDoor ENDP

Maze_DrawLayout PROC EXPORT
	LOCAL Pos:Vector2, Boundaries:Vector4
	call glPushMatrix
	
	mov eax, CamPosI.X
	sar eax, 1	; /2
	sub eax, SettingsGraphicsMazeCull
	mov Boundaries.X, eax
	mov Pos.X, eax
	
	mov eax, CamPosI.Z
	sar eax, 1	; /2
	sub eax, SettingsGraphicsMazeCull
	mov Boundaries.Y, eax
	mov Pos.Y, eax
	
	mov eax, CamPosI.Z
	sar eax, 1	; /2
	add eax, SettingsGraphicsMazeCull
	mov Boundaries.W, eax
	
	mov eax, CamPosI.X
	sar eax, 1	; /2
	add eax, SettingsGraphicsMazeCull
	mov Boundaries.Z, eax
	
	mov ecx, Pos.X
	.WHILE (SDWORD PTR ecx < Boundaries.Z)
		mov edx, Boundaries.Y
		mov Pos.Y, edx
		.WHILE (SDWORD PTR edx < Boundaries.W)
			.IF (rv(Maze_InRange, Pos.X, Pos.Y))
				call glPushMatrix
				Vector2Push Pos
				shl Pos.X, 1	; *2
				shl Pos.Y, 1
				invoke glTranslatei, Pos.X, 0, Pos.Y
				Vector2Pop Pos
				
				invoke glBindTexture, GL_TEXTURE_2D, MazeCurFloor
				invoke glCallList, MdlPlane
				invoke glBindTexture, GL_TEXTURE_2D, MazeCurRoof
				invoke glCallList, MdlPlaneR
				
				invoke glBindTexture, GL_TEXTURE_2D, MazeCurWall
				invoke Maze_GetCellI, Pos.X, Pos.Y
				mov ecx, MazeEntranceCell
				.IF (Pos.Y == 0) && (Pos.X == ecx)	; Draw entrance door
					push pax
					invoke glCallList, MdlDoorwayM			
					invoke Maze_DrawDoor, MazeSlamRot
					invoke glBindTexture, GL_TEXTURE_2D, MazeCurWall			
					pop pax
				.ELSEIF !(al & MAZE_CELL_PASSTOP)
					push pax
					invoke glCallList, MazeCurWallMDL
					pop pax
				.ENDIF
				.IF (Pos.X == 0) && (Pos.Y == 0) && (MazeShop)
					; Draw shop
				.ELSEIF !(al & MAZE_CELL_PASSLEFT)
					call glPushMatrix
					invoke glRotatef, f(-90), 0, f(1), 0
					invoke glCallList, MazeCurWallMDL
					call glPopMatrix
				.ENDIF
				
				; Draw border walls and exit
				mov eax, Pos.Y
				.IF (eax == MazeSize[12])
					mov eax, Pos.X
					.IF (eax == MazeSize[8])
						call glPushMatrix	; Draw exit door
						invoke glTranslatef, 0, 0, f(2)
						invoke glCallList, MdlDoorwayM
						invoke Maze_DrawDoor, MazeDoorRot
						.IF (MazeLocked)
							invoke glCallList, MdlDoorFrameLock
							.IF (MazeLocked == MAZE_LOCK_LOCKED)
								invoke glCallList, MdlPadlock
							.ENDIF
						.ENDIF
						invoke glBindTexture, GL_TEXTURE_2D, MazeCurWall	
						call glPopMatrix
					.ELSE
						call glPushMatrix
						invoke glTranslatef, 0, 0, f(2)
						invoke glCallList, MazeCurWallMDL
						call glPopMatrix
					.ENDIF
				.ENDIF
				mov eax, Pos.X
				.IF (eax == MazeSize[8])
					invoke glTranslatef, f(2), 0, 0
					invoke glRotatef, f(-90), 0, f(1), 0
					invoke glCallList, MazeCurWallMDL
				.ENDIF
				
				call glPopMatrix
			.ENDIF
			inc Pos.Y
			mov edx, Pos.Y
		.ENDW
		inc Pos.X
		mov ecx, Pos.X
	.ENDW
	
	call glPopMatrix
	ret
Maze_DrawLayout ENDP

Maze_Finish PROC EXPORT
	LOCAL bounds:Vector4
	
	fild MazeSize[8]
	fmul f(2)
	fadd f(1)
	fstp MazeDoorPos.X
	fild MazeSize[12]
	fmul f(2)
	fadd f(1)
	fstp MazeDoorPos.Z
	bpMEM32 MazeDoorPos.Y, CamHeight
	
	invoke nRand, 16	; Center room
	.IF !(al) && (MazeSize[0] > 7) && (MazeSize[4] > 7)
		mov eax, MazeSize[0]
		mov ecx, eax
		shr eax, 2		; /4
		mov bounds.X, eax
		shr ecx, 1		; /2
		add eax, ecx	; 3/4
		mov bounds.Z, eax
		
		mov eax, MazeSize[4]
		mov ecx, eax
		shr eax, 2		; /4
		mov bounds.Y, eax
		shr ecx, 1		; /2
		add eax, ecx	; 3/4
		mov bounds.W, eax
		
		mov ebx, bounds.X
		.WHILE (ebx < bounds.Z)
			mov edx, bounds.Y
			.WHILE (edx < bounds.W)
				push pdx
				invoke Maze_OrCellI, ebx, edx, MAZE_CELL_PASSLEFT
				pop pdx
				push pdx
				invoke Maze_OrCellI, ebx, edx, MAZE_CELL_PASSTOP
				pop pdx
				inc edx
			.ENDW
			inc ebx
		.ENDW
		print "Generated center room", 13, 10
	.ENDIF
	
	; Environmental variety
	.IF (MazeLayer > 1)
		invoke nRand, 6	; Random environment
		SWITCH eax
			CASE 0
				bpMEM32 MazeCurWall, TexWall
			CASE 1
				bpMEM32 MazeCurWall, TexMetal
			CASE 2
				bpMEM32 MazeCurWall, TexWhitewall
			CASE 3
				bpMEM32 MazeCurWall, TexBricks
			CASE 4
				bpMEM32 MazeCurWall, TexConcrete
			CASE 5
				bpMEM32 MazeCurWall, TexPlaster
		ENDSW
		invoke nRand, 7
		SWITCH eax
			CASE 0
				bpMEM32 MazeCurWallMDL, MdlWall
			CASE 1
				bpMEM32 MazeCurWallMDL, MdlWallB
			CASE 2
				bpMEM32 MazeCurWallMDL, MdlWallD
			CASE 3
				bpMEM32 MazeCurWallMDL, MdlWallM
			CASE 4
				bpMEM32 MazeCurWallMDL, MdlWallT
			CASE 5
				bpMEM32 MazeCurWallMDL, MdlWallT2
			CASE 6
				bpMEM32 MazeCurWallMDL, MdlWallW
		ENDSW
		invoke nRand, 3
		SWITCH eax
			CASE 0
				bpMEM32 MazeCurRoof, TexRoof
			CASE 1
				bpMEM32 MazeCurRoof, TexMetalRoof
			CASE 2
				bpMEM32 MazeCurRoof, TexConcreteRoof
		ENDSW
		invoke nRand, 5
		SWITCH eax
			CASE 0
				bpMEM32 MazeCurFloor, TexFloor
			CASE 1
				bpMEM32 MazeCurFloor, TexMetalFloor
			CASE 2
				bpMEM32 MazeCurFloor, TexTilefloor
			CASE 3
				bpMEM32 MazeCurFloor, TexDiamond
			CASE 4
				bpMEM32 MazeCurFloor, TexTileBig
		ENDSW
	.ENDIF
	
	.IF !(MazeTrench)
		call Maze_SpawnElements
	.ENDIF
	
	mov MazeGenerating, FALSE
	ret
Maze_Finish ENDP

Maze_Free PROC EXPORT
	invoke bpFree, bpDefHeap, 0, Maze
	mov Maze, 0
	ret
Maze_Free ENDP

Maze_Generate PROC EXPORT Seed:DWORD
	LOCAL Pos:Vector2, MazePool:BYTE, StackCnt:DWORD
	
	mov MazeGenerating, TRUE
	
	print "Generating maze with size "
	print str$(MazeSize[0]), 32
	print str$(MazeSize[4]), 9
	print "Seed: "
	print str$(Seed), 13, 10
	
	mov eax, MazeSize[0]
	dec eax
	mov MazeSize[8], eax
	mov eax, MazeSize[4]
	dec eax
	mov MazeSize[12], eax
	
	; Create maze array (zero memory by default)
	mov Maze, rv(bpCreate2DArray, 1, MazeSize[0], MazeSize[4])
	mov MazeByteSize, ecx	; Size returned in ecx by function
	invoke RtlZeroMemory, Maze, MazeByteSize
	
	bpMEM32 nRandSeed, Seed
	
	invoke nRand, 8
	.IF (al > 2)
		mov MazeType, MAZE_TYPE_NORMAL
	.ELSE
		mov MazeType, al
		print "Maze type is: "
		print ubyte$(MazeType), 13, 10
	.ENDIF
	
	; Treat Pos as [SDWORD, SDWORD]
	.IF (MazeLayer == 1)
		invoke Vector2Set, ADDR Pos, 0, 0	; Make first level the same (why??)
	.ELSE
		mov Pos.X, rv(nRand, MazeSize[0])	; Set random starting position
		mov Pos.Y, rv(nRand, MazeSize[4])
	.ENDIF
		
	print "Starting position: "
	print str$(Pos.X), 32
	print str$(Pos.Y), 13, 10
	
	mov StackCnt, 0			; Count the stack
	
	FREE_UP		EQU 0001b	; Movement pool bitfield
	FREE_LEFT	EQU 0010b
	FREE_DOWN	EQU 0100b
	FREE_RIGHT	EQU 1000b
	.WHILE TRUE
		.REPEAT
			; Ensure start is always to the right to display tutorial
			.IF (MazeLayer == 1) && (Pos.X == 0) && (Pos.Y == 0)
				mov MazePool, FREE_RIGHT
			.ELSE
				mov MazePool, 0
				; Check for available ways to move:
				.IF (Pos.Y > 0)
					dec Pos.Y	; 0, -1
					invoke Maze_GetCellI, Pos.X, Pos.Y
					inc Pos.Y
					.IF !(al & MAZE_CELL_VISITED)
						or MazePool, FREE_UP
					.ENDIF
				.ENDIF
				
				.IF (Pos.X > 0)
					dec Pos.X	; -1, 0
					invoke Maze_GetCellI, Pos.X, Pos.Y
					inc Pos.X
					.IF !(al & MAZE_CELL_VISITED)
						or MazePool, FREE_LEFT
					.ENDIF
				.ENDIF
				
				mov eax, Pos.Y
				.IF (eax < MazeSize[12])
					inc Pos.Y	; 0, 1
					invoke Maze_GetCellI, Pos.X, Pos.Y
					dec Pos.Y
					.IF !(al & MAZE_CELL_VISITED)
						or MazePool, FREE_DOWN
					.ENDIF
				.ENDIF
				
				mov eax, Pos.X
				.IF (eax < MazeSize[8])
					inc Pos.X	; 1, 0
					invoke Maze_GetCellI, Pos.X, Pos.Y
					dec Pos.X
					.IF !(al & MAZE_CELL_VISITED)
						or MazePool, FREE_RIGHT
					.ENDIF
				.ENDIF
			.ENDIF
			
			.IF (!MazePool)		; No direction to draw from
				.IF (StackCnt == 0)	; Stack depleted, end
					print "Generation finished", 13, 10
					
					call Maze_Finish
					ret
				.ENDIF
				
				Vector2Pop Pos		; Pop latest way, check there
				dec StackCnt
			.ENDIF
		.UNTIL (MazePool != 0)
		
		invoke Maze_OrCellI, Pos.X, Pos.Y, MAZE_CELL_VISITED
		
		.REPEAT	; Choose random available direction to go
			invoke nRand, 4
			mov cl, al
			mov al, 1
			shl al, cl
		.UNTIL (MazePool & al)
		
		.IF (al == FREE_UP)	; Set passes (no walls)
			invoke Maze_OrCellI, Pos.X, Pos.Y, MAZE_CELL_PASSTOP
			dec Pos.Y
		.ELSEIF (al == FREE_LEFT)
			invoke Maze_OrCellI, Pos.X, Pos.Y, MAZE_CELL_PASSLEFT
			dec Pos.X
		.ELSEIF (al == FREE_DOWN)
			inc Pos.Y
			invoke Maze_OrCellI, Pos.X, Pos.Y, MAZE_CELL_PASSTOP
		.ELSEIF (al == FREE_RIGHT)
			inc Pos.X
			invoke Maze_OrCellI, Pos.X, Pos.Y, MAZE_CELL_PASSLEFT
		.ENDIF
		
		;print "Pos: "
		;print str$(Pos.X), 32
		;print str$(Pos.Y)
		;print ", MazePool is "
		;print ubyte$(MazePool), 13, 10
		
		.IF (MazeType == MAZE_TYPE_BROKEN) && (Pos.X > 0) && (Pos.Y > 0)
			invoke nRand, 10
		.ELSE
			xor al, al
		.ENDIF
		.IF (!al)
			invoke Maze_OrCellI, Pos.X, Pos.Y, MAZE_CELL_VISITED
		.ENDIF
		
		Vector2Push Pos
		inc StackCnt
	.ENDW
	ret
Maze_Generate ENDP

;   Get maze cell data from real-world REAL4 coordinates.
Maze_GetCellF PROC EXPORT X:REAL4, Y:REAL4
	LOCAL fpucw:WORD
	fnstcw fpucw
	or fpucw, FPU_ROUND_TRUNC
	fldcw fpucw
	
	fld X
	fistp X
	fld Y
	fistp Y
	sar X, 1	; /2
	sar Y, 1	; /2
	
	xor fpucw, FPU_ROUND_TRUNC
	fldcw fpucw
	
	invoke Maze_GetCellI, X, Y
	ret
Maze_GetCellF ENDP

;   Get maze cell data from maze cell int coordinates.
Maze_GetCellI PROC EXPORT X:SDWORD, Y:SDWORD
	Maze_ClampXYI
	invoke bp2DArrayGetOffset, X, Y, MazeSize[0], 1
	
	mov ecx, X
	mov edx, Y
	
	add pax, Maze
	mov al, BYTE PTR [pax]
	ret
Maze_GetCellI ENDP

Maze_GetRandomPos PROC EXPORT PosPtr:BPPtr
	LOCAL pos:Vector2
	
	mazeRandPosLoop:
	mov eax, MazeSize[8]
	dec eax
	mov pos.X, rv(intRandRange, 1, eax)
	mov eax, MazeSize[12]
	dec eax
	mov pos.Y, rv(intRandRange, 1, eax)
	
	shl pos.X, 1
	inc pos.X
	shl pos.Y, 1
	inc pos.Y
	mov pax, PosPtr
	fild pos.X
	fstp REAL4 PTR [pax]
	fild pos.Y
	fstp REAL4 PTR [pax+8]
	ret
Maze_GetRandomPos ENDP

Maze_InRange PROC EXPORT X:SDWORD, Y:SDWORD
	.IF (rv(intInRange, X, 0, MazeSize[8]))
		.IF (rv(intInRange, Y, 0, MazeSize[12]))
			mov pax, 1
			ret
		.ENDIF
	.ENDIF
	xor pax, pax
	ret
Maze_InRange ENDP

;   OR Val with cell at position (X, Y). Uses pax, pcx.
Maze_OrCellI PROC EXPORT X:SDWORD, Y:SDWORD, Val:BYTE
	Maze_ClampXYI
	invoke bp2DArrayGetOffset, X, Y, MazeSize[0], 1
	add pax, Maze
	mov cl, Val
	or BYTE PTR [pax], cl
	ret
Maze_OrCellI ENDP

Maze_ProcessState PROC EXPORT
	LOCAL flVal:REAL4
	
	.IF (MazeState == MAZE_STATE_SAFE)	; Play siren
		.IF !(MazeStateTimer)
			bpMEM32 MazeStateTimer, f(51)
			mov MazeStateCallback, OFFSET mazeSafe
		.ENDIF
		
		fild MazeLayer
		fmul f(0.2)
		fsubr f(1)
		fstp flVal
		
		fcmp flVal
		.IF (Carry?)
			mov flVal, 0
		.ENDIF
		
		mov MazeSiren, rv(flLerp, MazeSiren, flVal, delta2)
		invoke alSourcef, SndSiren, AL_GAIN, MazeSiren
	.ELSEIF (MazeState == MAZE_STATE_STOP_SIREN)
		.IF !(MazeStateTimer)
			bpMEM32 MazeStateTimer, f(10)
			mov MazeStateCallback, OFFSET mazeStopSiren
		.ENDIF
		
		mov MazeSiren, rv(flLerp, MazeSiren, 0, delta2)
		invoke alSourcef, SndSiren, AL_GAIN, MazeSiren
	.ELSEIF (MazeState == MAZE_STATE_WAIT_IMPACT)
		.IF !(MazeStateTimer)
			fild MazeLayer
			fmul f(0.1)
			fstp MazeStateTimer
			mov MazeStateCallback, OFFSET mazeWaitImpact
		.ENDIF
	.ELSEIF (MazeState == MAZE_STATE_SHAKE)
		.IF !(MazeStateTimer)
			bpMEM32 MazeStateTimer, f(3)
			mov MazeStateCallback, OFFSET mazeShake
		.ENDIF
		
		mov MazeSiren, rv(flLerp, MazeSiren, 0, delta2)
		vinvoke Plr_Shake, MazeSiren
	.ENDIF
		
	.IF (MazeStateTimer)
		fld MazeStateTimer
		fsub deltaTime
		fstp MazeStateTimer
		
		fcmp MazeStateTimer
		.IF (Carry?)
			mov MazeStateTimer, 0
			.IF (MazeStateCallback)
				call MazeStateCallback
			.ENDIF
		.ENDIF
	.ENDIF
	ret
	
	mazeSafe:
		mov MazeState, MAZE_STATE_STOP_SIREN
		ret
	mazeStopSiren:
		mov MazeState, MAZE_STATE_WAIT_IMPACT
		
		fild MazeLayer
		fsub f(1)
		fmul f(0.1)
		fsubr f(1)
		fstp flVal
		
		invoke alSourcef, SndExplosion, AL_GAIN, flVal
		invoke alSourcePlay, SndExplosion
			
		invoke alSourceStop, SndSiren
		ret
	mazeWaitImpact:
		mov MazeState, MAZE_STATE_SHAKE
		
		fild MazeLayer
		fsub f(1)
		fmul f(0.14)
		fsubr f(1)
		fstp flVal
		
		fcmp flVal
		.IF (Carry?)
			mov flVal, 0
		.ENDIF
		
		fld flVal
		fmul f(48)
		sub psp, SIZEOF BPPtr
		fistp REAL4 PTR [psp]
		
		invoke alSourcef, SndImpact, AL_GAIN, flVal
		invoke alSourcePlay, SndImpact
		invoke alSourcef, SndCrumble, AL_GAIN, f(0.2)
		invoke alSourcePlay, SndCrumble
		
		vinvoke Vector32DCopy, OFFSET MazePartDust.Position, OFFSET CamPos
		bpMEM32 MazePartDust.Position.Y, f(2)
		pop pax
		IFDEF MODE_DEBUG
			push pax
			print str$(pax), 32
			print "particles released", 13, 10
			pop pax
		ENDIF
		invoke Particles_Spawn, ADDR MazePartDust, pax
		
		
		fld flVal
		fmul f(0.1)
		fstp flVal
		bpMEM32 MazeSiren, flVal
		ret
	mazeShake:
		mov MazeState, MAZE_STATE_GAME
		invoke alSourcePlay, SndAmb
		invoke nRand, 2
		.IF (al)
			invoke alSourcePlay, SndMus[4]
		.ENDIF
		ret
Maze_ProcessState ENDP

Maze_Progress PROC EXPORT
	call Maze_Free
	inc MazeLayer
	
	invoke nRand, 7
	.IF (al == 0)
		inc MazeSize[0]
	.ELSEIF (al == 1)
		inc MazeSize[4]
	.ENDIF
	
	invoke Maze_Generate, nRandSeed
	ret
Maze_Progress ENDP

Maze_SpawnElements PROC EXPORT
	.IF (MazeState == MAZE_STATE_GAME)
		invoke nRand, MazeLayer	; Key
		.IF (al > 7)
			print "Locked maze, key at "
			mov MazeLocked, MAZE_LOCK_LOCKED
			invoke Maze_GetRandomPos, ADDR MazeKeyPos
			Vector3Print MazeKeyPos
		.ENDIF
	.ENDIF
	ret
Maze_SpawnElements ENDP


Maze_Create PROC EXPORT
	mov MazePartAmb.Billboard, PARTICLE_BILLBOARD_Y or PARTICLE_BILLBOARD_X
	mov MazePartAmb.Count, 96
	invoke Vector2Set, ADDR MazePartAmb.Distance, f(1), f(4)
	mov MazePartAmb.Fade, PARTICLE_FADE_IN or PARTICLE_FADE_OUT
	bpMEM32 MazePartAmb.Friction, f(0.1)
	mov MazePartAmb.Looping, TRUE
	mov MazePartAmb.VelocityAffects, PARTICLE_VELOCITY_POSITION
	invoke Vector2Set, ADDR MazePartAmb.Lifetime, f(4), f(8)
	invoke Vector2Set, ADDR MazePartAmb.Scale, f(0.01), f(0.04)
	invoke Vector2Set, ADDR MazePartAmb.Velocity, f(0.02), f(0.1)
	invoke Particles_Create, ADDR MazePartAmb
	
	mov MazePartDust.Billboard, PARTICLE_BILLBOARD_Y or PARTICLE_BILLBOARD_X
	mov MazePartDust.Count, 64
	mov MazePartDust.Gravity, TRUE
	mov MazePartDust.Rotate, TRUE
	invoke Vector2Set, ADDR MazePartDust.Distance, f(0.5), f(3)
	mov MazePartDust.Fade, PARTICLE_FADE_OUT
	bpMEM32 MazePartDust.Friction, f(0.7)
	mov MazePartDust.VelocityAffects, PARTICLE_VELOCITY_POSITION \
	or PARTICLE_VELOCITY_ROTATION
	invoke Vector2Set, ADDR MazePartDust.Lifetime, f(0.4), f(0.6)
	invoke Vector2Set, ADDR MazePartDust.Scale, f(0.9), f(1.2)
	invoke Vector2Set, ADDR MazePartDust.Velocity, f(0.7), f(1)
	invoke Particles_Create, ADDR MazePartDust
	
	ret
Maze_Create ENDP

Maze_Draw PROC EXPORT
	.IF (Maze)
		call Maze_DrawLayout
		
		.IF (MazeLayer == 1)	; Tutorial
			.IF (InputMethod == INPUT_KEYBOARD_MOUSE)
				mov eax, TexTutorial
			.ELSE
				mov eax, TexTutorialJ
			.ENDIF
			invoke glBindTexture, GL_TEXTURE_2D, eax
			invoke glEnable, GL_BLEND
			invoke glDisable, GL_LIGHTING
			invoke glDisable, GL_FOG
			invoke glBlendFunc, GL_DST_COLOR, GL_ZERO
			call glPushMatrix
			invoke glTranslatef, 0, 0, f(1.89)
			invoke glRotatef, f(-90), f(1), 0, 0
			invoke glCallList, MdlPlane
			call glPopMatrix
			invoke glDisable, GL_BLEND
			invoke glEnable, GL_LIGHTING
			invoke glEnable, GL_FOG
		.ENDIF
		.IF (PlrState == PLAYER_STATE_EXITING)	; Exit door stairs
			call glPushMatrix
			mov eax, MazeSize[8]
			shl eax, 1
			mov ecx, MazeSize[12]
			inc ecx
			shl ecx, 1
			invoke glTranslatei, eax, 0, ecx
			invoke glBindTexture, GL_TEXTURE_2D, MazeCurFloor
			invoke glCallList, MdlStairsM
			
			invoke glBindTexture, GL_TEXTURE_2D, TexDoorBlur
			invoke glScalef, f(1), f(0.99), f(1)
			invoke glEnable, GL_BLEND
			invoke glDisable, GL_LIGHTING
			invoke glDisable, GL_FOG
			invoke glBlendFunc, GL_DST_COLOR, GL_ZERO
			invoke glCallList, MdlStairsM
			invoke glDisable, GL_BLEND
			invoke glEnable, GL_LIGHTING
			invoke glEnable, GL_FOG
			call glPopMatrix
		.ENDIF
		.IF (MazeLocked == MAZE_LOCK_LOCKED)	; Key
			call glPushMatrix
			invoke glTranslate3fv, ADDR MazeKeyPos
			invoke glRotatefr, MazeKeyRot[0], 0, f(1), 0
			invoke glBindTexture, GL_TEXTURE_2D, TexKey
			invoke glEnable, GL_ALPHA_TEST
			invoke glCallList, MdlKey
			invoke glDisable, GL_ALPHA_TEST
			call glPopMatrix
		.ENDIF
	.ENDIF
	
	.IF (SettingsGraphicsParticles)
		invoke glEnable, GL_BLEND
		invoke glDepthMask, GL_FALSE
		invoke glBlendFunc, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA
		
		.IF (MazeState == MAZE_STATE_GAME)
			;invoke glDisable, GL_CULL_FACE
			;invoke glDisable, GL_FOG
			;invoke glDisable, GL_LIGHTING
			
			invoke glBindTexture, GL_TEXTURE_2D, TexAmbient
			;bpMEM32 ParticleMaxAlpha, f(0.5)
			invoke Particles_Draw, ADDR MazePartAmb
			
			;invoke glEnable, GL_CULL_FACE
			;invoke glEnable, GL_FOG
			;invoke glEnable, GL_LIGHTING
		.ENDIF
		
		invoke glDisable, GL_DEPTH_TEST
		invoke glBindTexture, GL_TEXTURE_2D, TexDust
		bpMEM32 ParticleMaxAlpha, f(0.5)
		invoke Particles_Draw, ADDR MazePartDust
		bpMEM32 ParticleMaxAlpha, f(1)
		invoke glEnable, GL_DEPTH_TEST
		
		invoke glDisable, GL_BLEND
		invoke glDepthMask, GL_TRUE
	.ENDIF
	ret
Maze_Draw ENDP

Maze_Fixed PROC EXPORT
	LOCAL flVal:REAL4
	
	.IF (SettingsGraphicsParticles)
		.IF (MazeState == MAZE_STATE_GAME)
			vinvoke Vector3Copy, OFFSET MazePartAmb.Position, OFFSET CamPos
			invoke Particles_Process, ADDR MazePartAmb, deltaFixed
		.ENDIF
		invoke Particles_Process, ADDR MazePartDust, deltaFixed
	.ENDIF
	
	.IF (MazeLocked == MAZE_LOCK_LOCKED)	; Key
		mov flVal, rv(flDistance, MazeKeyRot[0], MazeKeyRot[4])
		fcmp flVal, f(0.02)
		.IF (Carry?)
			mov MazeKeyRot[4], rv(flRandRange, 0, PI2)
		.ENDIF
		fld deltaFixed
		fmul f(0.2)
		fstp flVal
		mov MazeKeyRot[0], rv(flLerpAngle, MazeKeyRot[0], MazeKeyRot[4], flVal)
		
		vinvoke Vector32DDistanceSqr, OFFSET CamPos, OFFSET MazeKeyPos
		fstp flVal
		fcmp flVal, f(1)
		.IF (Carry?)
			mov MazeLocked, MAZE_LOCK_UNLOCKED
			vinvoke UI_ShowSubtitles, StrCCKey, f(2)
			invoke SndSetPos, SndKey, ADDR MazeKeyPos
			invoke alSourcePlay, SndKey
		.ENDIF
	.ENDIF
	ret
Maze_Fixed ENDP

Maze_Process PROC EXPORT
	LOCAL flVal:REAL4
	
	invoke fpuSetRounding, FPU_ROUND_TRUNC
	fld CamPos.X
	fistp MazePlrPos.X
	fld CamPos.Z
	fistp MazePlrPos.Y
	invoke fpuSetRounding, FPU_ROUND_ROUND
	
	call Maze_ProcessState
	
	.IF (Maze)
		vinvoke Maze_Collide, OFFSET CamPos
		
		; Detect exit door
		.IF (MazeLocked == MAZE_LOCK_NONE) || (MazeLocked == MAZE_LOCK_UNLOCKED)
			vinvoke Vector32DDistanceSqr, OFFSET CamPos, OFFSET MazeDoorPos
			fstp flVal
			fcmp flVal, f(0.7)
			.IF (Carry?) && (PlrState == PLAYER_STATE_GAME)
				mov PlrState, PLAYER_STATE_EXIT
			.ENDIF
		.ENDIF
	.ENDIF
	ret
Maze_Process ENDP
