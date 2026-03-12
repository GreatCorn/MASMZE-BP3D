MAZE_CELL_PASSTOP	EQU 00000001b
MAZE_CELL_PASSLEFT	EQU 00000010b
MAZE_CELL_VISITED	EQU 00000100b
MAZE_CELL_ROTATED	EQU 00001000b
MAZE_CELL_PROPS		EQU 11110000b

MAZE_FREE_UP	EQU 0001b	; Movement pool bitfield
MAZE_FREE_LEFT	EQU 0010b
MAZE_FREE_DOWN	EQU 0100b
MAZE_FREE_RIGHT	EQU 1000b

MAZE_PROP_SHIFT			EQU 4
MAZE_PROP_DOORWAY		EQU 1 shl MAZE_PROP_SHIFT
MAZE_PROP_TABURETKA		EQU 2 shl MAZE_PROP_SHIFT
MAZE_PROP_LAMP			EQU 3 shl MAZE_PROP_SHIFT
MAZE_PROP_ARCH			EQU 4 shl MAZE_PROP_SHIFT
MAZE_PROP_WINDOWS		EQU 5 shl MAZE_PROP_SHIFT

ENUM \
	MAZE_CHECK_NONE, \
	MAZE_CHECK_OPEN, \
	MAZE_CHECK_CLOSE, \
	MAZE_CHECK_SAVED
	
MAZE_ITEM_COMPASS	EQU 1
MAZE_ITEM_GLYPHS	EQU 2
MAZE_ITEM_MAP		EQU 4

MAZE_MAP_WALL_SHL	EQU 3
MAZE_MAP_WALL_SIZE	EQU 1 shl MAZE_MAP_WALL_SHL

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
	E MAZE_STATE_TRENCH
	E MAZE_STATE_END
	E MAZE_STATE_CROA
	E MAZE_STATE_BORDER
	E MAZE_STATE_LOBBY_CREAK
	E MAZE_STATE_LOBBY_FALL
	
LayerData STRUCT
	MazeSeed	DWORD ?
	MazeSize	DWORD ?, ?
LayerData ENDS
	
.CONST
MazeItemDist	REAL4 0.7
MazeItemDistImp	REAL4 1.0
MazeRaycastMax	BPPtr 64
MazeRandPosMax	BPPtr 64
	

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
MazeSize			DWORD 5, 5, ?, ?	; Width, height, width-1, height-1
MazeState 			BPEnum MAZE_STATE_GAME	; Used with intro and endings
MazeStateCallback	BPPtr 0
MazeStateTimer		REAL4 0.0
MazeType			BPEnum MAZE_TYPE_NORMAL

MazeCheck			BPEnum MAZE_CHECK_NONE	; Checkpoint state
MazeCheckErasePos	Vector3 <>
MazeCheckErasePosL	Vector3 <>

MazeCrevice 	BPBool FALSE	; Maze crevice active
MazeCreviceCell	DWORD 0, 0		; Maze crevice cell position
MazeCrevicePos	Vector3 <>		; Maze crevice world position

MazeDoorRot		REAL4 0.0		; Maze end door rotation

MazeItems		BPEnum 0		; Maze items bitmask
MazeCompassPos	Vector3 <>		; Compass item position
MazeGlyphsPos	Vector3 <>		; Glyphs item position in layer
MazeGlyphsRot	REAL4 0.0		; Glyphs item rotation

MazeKeyPos		Vector3 <>		; Key position
MazeKeyRot		REAL4 0.0, 0.0	; Key rotation + target

MazeLayoutTex	DWORD 0

MazeNoiseTimer	REAL4 10.0, 12.0, 56.0

MazeNote		BPEnum 0
MazeNotePos		Vector3 <>

MazePrevLayer	LayerData <0>

MazeSiren		REAL4 0.0	; Siren gain etc (intro)

MazeSlam	BPBool FALSE	; Door slam event
MazeSlamRot	REAL4 0.0		; The entrance door rotation (for drawing)

MazeTeleport		BPBool FALSE	; Teleporters state
MazeTeleportPos1	Vector3 <>		; First tele position
MazeTeleportPos2	Vector3 <>		; Second tele position
MazeTeleportRot		REAL4 0.0		; Teleporter rotation for animating

MazeTram		BPEnum MAZE_TRAM_NONE; Tram state
MazeTramDoors	DWORD 99		; Tram doors list to draw
MazeTramArea	DWORD 0, 0		; The area (X from, X to) that the rails occupy
MazeTramRot		DWORD 8, 0		; Tram direction (rotations[]) and REAL4 rot
MazeTramPlr		BPEnum 0		; Tram player state
MazeTramPos		Vector3 <>		; Tram position
MazeTramSpeed	REAL4 0.0		; Tram speed to accelerate
MazeTramSnd		DWORD 0			; Tram announcement sound index
MazeTramWait	REAL4 0.0		; Tram wait at stop timer

MazeShop		BPBool FALSE
MazeShopTimer	REAL4 0.0

MazeTrenchTimer	REAL4 0.0

MazeVasPos		Vector3 <>
MazeVasRot		REAL4 0.0

MazePartAmb		ParticleSystem <>
MazePartDust	ParticleSystem <>

KoluplykAnimPlr	BPAnimPlayer <>
MotryaAnimPlr	BPAnimPlayer <>
VasAnimPlr		BPAnimPlayer <>

.DATA?
MazeCheckPos	Vector3 <?, ?, ?>	; Maze checkpoint
MazeCurFloor	DWORD ?	; Environmental variety
MazeCurRoof		DWORD ?
MazeCurWall		DWORD ?
MazeCurWallMDL	DWORD ?
MazeDoorPos		Vector3 <?, ?, ?>	; Maze end door cell center position
MazeMapSize		Vector2 <?, ?>
MazePlrPos		Vector2 <?, ?>		; Player cell position
MazeSeed		DWORD ?

.CODE
Maze_GetCellF PROTO :REAL4, :REAL4
Maze_GetCellI PROTO :SDWORD, :SDWORD
Maze_InRange PROTO :SDWORD, :SDWORD
Maze_OrCellI PROTO :SDWORD, :SDWORD, :BYTE
Maze_SetPropI PROTO :SDWORD, :SDWORD, :BYTE, :BPBool

;   Clamp X and Y parameters to maze boundaries.
Maze_ClampXYI MACRO _X:=<X>, _Y:=<Y>
	mov _X, rv(intClamp, _X, 0, MazeSize[8])
	mov _Y, rv(intClamp, _Y, 0, MazeSize[12])
ENDM

Maze_CheckFree PROC EXPORT X:SDWORD, Y:SDWORD, Hor:BPBool, Fat:BPBool
	;print "Testing cell "
	;print str$(X), 32
	;print str$(Y), 32
	;.IF (Hor)
	;	print "H", 32
	;.ELSE
	;	print "V", 32
	;.ENDIF
	
	mov eax, X
	mov ecx, Y
	.IF (eax != MazeCreviceCell[0]) || (ecx != MazeCreviceCell[4]) \
	|| !(MazeCrevice)
		invoke Maze_GetCellI, X, Y
		;pushad
		;print ubyte$(al), 9
		;popad
		.IF (Hor)
			mov cl, al
			and cl, MAZE_CELL_PROPS
			.IF (cl == MAZE_PROP_DOORWAY) && (al & MAZE_CELL_ROTATED) && (Fat)
				xor al, al
			.ELSE
				and al, MAZE_CELL_PASSLEFT
			.ENDIF
		.ELSE
			mov cl, al
			and cl, MAZE_CELL_PROPS
			.IF (cl == MAZE_PROP_DOORWAY) && !(al & MAZE_CELL_ROTATED) && (Fat)
				xor al, al
			.ELSE
				and al, MAZE_CELL_PASSTOP
			.ENDIF
		.ENDIF
		.IF (al)
			;print "FREE", 13, 10
			mov pax, TRUE
			ret
		.ENDIF
	.ENDIF
	;print "OCCUPIED", 13, 10
	xor pax, pax
	ret
Maze_CheckFree ENDP

Maze_Collide PROC EXPORT PosPtr:BPPtr, Radius:REAL4, X:REAL4, Y:REAL4, Cell:BYTE
	LOCAL colPos:Vector3, colSize:Vector2
	wallCollide MACRO _hor:REQ
		IF _hor EQ TRUE
			fld X
		ELSE
			fld Y
		ENDIF
		fadd f(1)
		IF _hor EQ TRUE
			fstp colPos.X
			bpMEM32 colPos.Z, Y
		ELSE
			fstp colPos.Z
			bpMEM32 colPos.X, X
		ENDIF
		fld f(2.1)
		fadd Radius
		IF _hor EQ TRUE
			fstp colSize.X
		ELSE
			fstp colSize.Y
		ENDIF
		fld f(0.2)
		fadd Radius
		IF _hor EQ TRUE
			fstp colSize.Y
		ELSE
			fstp colSize.X
		ENDIF
		invoke Collide_Rectangle, PosPtr, ADDR colPos, colSize.X, colSize.Y
	ENDM
	
	; Walls
	.IF !(Cell & MAZE_CELL_PASSTOP)
		wallCollide TRUE
	.ENDIF
	.IF !(Cell & MAZE_CELL_PASSLEFT)
		wallCollide FALSE
	.ENDIF
	
	; Props
	invoke Vector32DSet, ADDR colPos, X, Y
	mov al, Cell
	and al, MAZE_CELL_PROPS
	.IF (al == MAZE_PROP_DOORWAY)
		fld f(0.2)
		fadd Radius
		fstp colSize.X
		fld f(0.3)	; Not 0.6 because too narrow
		fadd Radius
		fstp colSize.Y
		.IF (Cell & MAZE_CELL_ROTATED)
			lea pcx, colPos.Z
		.ELSE
			lea pcx, colPos.X
			mov eax, colSize.X
			mov edx, colSize.Y
			mov colSize.X, edx
			mov colSize.Y, eax
		.ENDIF
		
		fld REAL4 PTR [pcx]
		fadd f(0.3)
		fstp REAL4 PTR [pcx]
		push pcx
		invoke Collide_Rectangle, PosPtr, ADDR colPos, colSize.X, colSize.Y
		pop pcx
		fld REAL4 PTR [pcx]
		fadd f(1.4)
		fstp REAL4 PTR [pcx]
		invoke Collide_Rectangle, PosPtr, ADDR colPos, colSize.X, colSize.Y
	.ELSEIF (al == MAZE_PROP_TABURETKA)
		.IF (Cell & MAZE_CELL_ROTATED)
			fld colPos.X
			fsub f(0.46)
			fstp colPos.X
			fld colPos.Z
			fadd f(0.42)
			fstp colPos.Z
		.ELSE
			fld colPos.X
			fadd f(0.42)
			fstp colPos.X
			fld colPos.Z
			fadd f(0.46)
			fstp colPos.Z
		.ENDIF
		fld Radius
		fsub f(0.3)
		fstp colSize.X
		
		invoke Collide_Distance, PosPtr, ADDR colPos, colSize.X, 0
	.ENDIF
	ret
Maze_Collide ENDP

Maze_CollideLayout PROC EXPORT PosPtr:BPPtr, Radius:REAL4, Props:BPBool
	LOCAL flVal:REAL4, colPos:Vector2, worldPos:Vector2, bounds:Vector4
		
	; Get collidee cell position
	invoke fpuSetRounding, FPU_ROUND_TRUNC
	mov pax, PosPtr
	fld REAL4 PTR [pax]
	fistp colPos.X
	fld REAL4 PTR [pax+8]
	fistp colPos.Y
	sar colPos.X, 1	; /2
	sar colPos.Y, 1	; /2
	invoke fpuSetRounding, FPU_ROUND_ROUND
	
	; Establish boundaries (collide just around the collidee)
	dec colPos.X
	mov ecx, colPos.X
	mov bounds.X, ecx
	dec colPos.Y
	mov edx, colPos.Y
	mov bounds.Y, edx
	add ecx, 2
	mov bounds.Z, ecx
	add edx, 2
	mov bounds.W, edx
	
	mov ecx, colPos.X
	.WHILE (SDWORD PTR ecx <= bounds.Z)
		mov edx, bounds.Y
		mov colPos.Y, edx
		.WHILE (SDWORD PTR edx <= bounds.W)
			.IF (rv(Maze_InRange, colPos.X, colPos.Y))
				.IF (MazeCrevice)
					; Indentation lovers rejoice
					mov ecx, colPos.X
					mov edx, colPos.Y
					.IF (ecx == MazeCreviceCell[0]) \
					&& (edx == MazeCreviceCell[4])
						.IF (PosPtr == OFFSET CamPos)
							fcmp PlrCrouch, f(0.4)
							.IF (!Carry?) || (MazeCrevice == 2)
								mov ecx, MazePlrPos.X
								mov edx, MazePlrPos.Y
								.IF (ecx == MazeCreviceCell[0]) && \
								(edx == MazeCreviceCell[4])
									mov MazeCrevice, 2
								.ELSE
									mov MazeCrevice, 1
								.ENDIF
							.ELSE
								jmp mazeColLayCrevice
							.ENDIF
						.ELSE
							mazeColLayCrevice:
							fld f(2)
							fadd Radius
							fstp flVal
							invoke Collide_Rectangle, PosPtr, \
							ADDR MazeCrevicePos, flVal, flVal
						.ENDIF
					.ENDIF
				.ENDIF
				invoke Vector2Copy, ADDR worldPos, ADDR colPos
				sal worldPos.X, 1	; *2
				sal worldPos.Y, 1	; *2
				invoke Vector2F, ADDR worldPos
				invoke Maze_GetCellI, colPos.X, colPos.Y
				.IF !(Props)
					and al, BYTE PTR not MAZE_CELL_PROPS
				.ENDIF
				invoke Maze_Collide, PosPtr, Radius, worldPos.X, worldPos.Y, al
				mov eax, colPos.X
				.IF (eax == MazeSize[8])	; End walls vertical
					fld worldPos.X
					fadd f(2)
					fstp flVal
					invoke Maze_Collide, PosPtr, Radius, flVal, worldPos.Y, \
					MAZE_CELL_PASSTOP
				.ENDIF
				mov eax, colPos.Y
				.IF (eax == MazeSize[12])	; End walls hor and exit
					fld worldPos.Y
					fadd f(2)
					fstp flVal
					mov eax, colPos.X
					.IF (eax == MazeSize[8]) && (MazeCheck == MAZE_CHECK_OPEN) \
					&& (PosPtr == OFFSET CamPos)
						; Collide checkpoint doorway
						mov al, MAZE_CELL_PASSTOP or MAZE_CELL_PASSLEFT \
						or MAZE_PROP_DOORWAY
					.ELSE
						mov al, MAZE_CELL_PASSLEFT
					.ENDIF
					invoke Maze_Collide, PosPtr, Radius, worldPos.X, flVal, al
				.ENDIF
			.ENDIF
			inc colPos.Y
			mov edx, colPos.Y
		.ENDW
		inc colPos.X
		mov ecx, colPos.X
	.ENDW
	
	ret
Maze_CollideLayout ENDP

Maze_DrawCheck PROC EXPORT
	LOCAL v3Val:Vector3
	
	call glPushMatrix
	invoke glTranslate32Dfv, ADDR MazeCheckPos
	invoke glBindTexture, GL_TEXTURE_2D, TexFloor
	invoke glCallList, MdlCheckFloor
	invoke glBindTexture, GL_TEXTURE_2D, TexWall
	invoke glCallList, MdlCheckRails
	invoke glTranslatef, 0, MazeCheckPos.Y, 0
	invoke glCallList, MdlCheckWalls
	invoke glBindTexture, GL_TEXTURE_2D, TexRoof
	invoke glCallList, MdlCheckRoof
	
	call glPushMatrix
	; Draw exit door
	invoke glTranslatef, 0, 0, f(6.1)
	.IF (MazeCheck == MAZE_CHECK_SAVED)
		mov eax, MazeDoorRot
	.ELSE
		xor eax, eax
	.ENDIF
	vinvoke Maze_DrawDoor, eax
	call glPopMatrix
	
	; Draw TONE
	;call glPushMatrix
	invoke glEnable, GL_BLEND
	invoke glDisable, GL_FOG
	invoke glDisable, GL_LIGHTING
	invoke glBlendFunc, GL_ONE, GL_ONE
	invoke glBindTexture, GL_TEXTURE_2D, TexTone
	invoke glTranslatef, f(1), f(2.2), f(5.99)
	invoke glRotatef, f(180), 0, f(1), 0
	invoke glCallList, MdlParticle
	call glPopMatrix
	
	; Draw erase flare or Motrya
	call glPushMatrix
	.IF (MazeCheck == MAZE_CHECK_SAVED) && (GameState != GAME_STATE_LOBBY)
		invoke glTranslate3fv, ADDR MazeCheckErasePosL
		fld CamRotL.Y
		fmul f(2)
		fstp v3Val.Y
		vinvoke glRotatef, CamBillboard.Y, 0, f(1), 0
		vinvoke glRotatef, CamBillboard.X, f(1), 0, 0
		vinvoke glRotatefr, v3Val.Y, 0, 0, f(1)
		invoke glDisable, GL_DEPTH_TEST
		invoke flRandRange, f(0.8), f(1)
		invoke Vector3Set, ADDR v3Val, eax, eax, eax
		
		;   Sometimes OpenGL likes glMaterial, sometimes it likes glColor. I
		; thought glColor maps onto glMaterial properties and changes them when
		; called but I just don't even fucking know anymore
		;invoke glMaterialfv, GL_FRONT, GL_DIFFUSE, ADDR v3Val
		invoke glColor3fv, ADDR v3Val
		
		invoke glBindTexture, GL_TEXTURE_2D, TexLight
		invoke glCallList, MdlParticle
		
		;invoke glMaterialfv, GL_FRONT, GL_DIFFUSE, ADDR clWhite
		invoke glColor3fv, ADDR clWhite
		
		invoke glEnable, GL_DEPTH_TEST
	.ENDIF
	invoke glDisable, GL_BLEND
	invoke glEnable, GL_FOG
	invoke glEnable, GL_LIGHTING
	.IF (MazeCheck != MAZE_CHECK_SAVED)
		invoke glTranslate3fv, ADDR MazeCheckPos
		invoke glTranslatef, f(1), 0, f(4)
		invoke glRotatef, f(180), 0, f(1), 0
		invoke glBindTexture, GL_TEXTURE_2D, TexMotrya
		invoke bpDrawMesh, ADDR MeshMotrya
	.ENDIF
	call glPopMatrix
	ret
Maze_DrawCheck ENDP

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
	LOCAL Pos:Vector2, Boundaries:Vector4, cell:BYTE, rotated:BPBool
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
				.IF (MazeState != MAZE_STATE_TRENCH)
					invoke glBindTexture, GL_TEXTURE_2D, MazeCurRoof
					invoke glCallList, MdlPlaneR
				.ENDIF
				
				; Props
				call glPushMatrix
				invoke Maze_GetCellI, Pos.X, Pos.Y
				mov cell, al
				.IF (al & MAZE_CELL_ROTATED)
					mov rotated, TRUE
					push pax
					invoke glRotatef, f(-90), 0, f(1), 0
					pop pax
				.ELSE
					mov rotated, FALSE
				.ENDIF
				and al, MAZE_CELL_PROPS
				.IF (al == MAZE_PROP_DOORWAY)
					invoke glBindTexture, GL_TEXTURE_2D, MazeCurWall
					invoke glCallList, MdlDoorwayM
					invoke glBindTexture, GL_TEXTURE_2D, TexDoor
					invoke glCallList, MdlDoorFrame
				.ELSEIF (al == MAZE_PROP_TABURETKA)
					invoke glBindTexture, GL_TEXTURE_2D, TexTaburetka
					invoke glCallList, MdlTaburetka
				.ELSEIF (al == MAZE_PROP_LAMP)
					invoke glBindTexture, GL_TEXTURE_2D, TexLamp
					invoke glCallList, MdlLamp
				.ELSEIF (al == MAZE_PROP_ARCH)
					.IF (MazeState == MAZE_STATE_TRENCH)
						invoke glBindTexture, GL_TEXTURE_2D, TexPlanks
						invoke glCallList, MdlPlanks
					.ELSE
					
					.ENDIF
				.ENDIF
				call glPopMatrix
				
				invoke glBindTexture, GL_TEXTURE_2D, MazeCurWall
				mov al, cell
				and al, MAZE_CELL_PROPS
				.IF (al == MAZE_PROP_WINDOWS)
					.IF (MazeState == MAZE_STATE_TRENCH)
						bpPush32 MazeCurWallMDL
						bpMEM32 MazeCurWallMDL, MdlWall
						invoke glBindTexture, GL_TEXTURE_2D, TexPlanks
					.ELSE
						bpPush32 MazeCurWallMDL
						
					.ENDIF
				.ENDIF
				
				; Crevice
				.IF (MazeCrevice)
					mov ecx, Pos.X
					mov edx, Pos.Y
					.IF (ecx == MazeCreviceCell[0])&&(edx == MazeCreviceCell[4])
						invoke glCallList, MdlCrevice
					.ENDIF
				.ENDIF
				
				mov ecx, MazeEntranceCell
				mov al, cell
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
				.IF (Pos.X == 0) && (Pos.Y == 0) && (MazeShop)	; Draw shop
					call glPushMatrix
					invoke glTranslatef, f(-2), 0, 0
					invoke glCallList, MdlShop
					invoke glBindTexture, GL_TEXTURE_2D, MazeCurFloor
					invoke glCallList, MdlPlane
					invoke glBindTexture, GL_TEXTURE_2D, TexKoluplyk
					invoke bpDrawMesh, ADDR MeshKoluplyk
					invoke glBindTexture, GL_TEXTURE_2D, MazeCurWall
					call glPopMatrix
					.IF (MazeShopTimer)
						call glPushMatrix
						invoke glTranslatef, MazeShopTimer, 0, 0
						invoke glRotatef, f(-90), 0, f(1), 0
						invoke glCallList, MazeCurWallMDL
						call glPopMatrix
					.ENDIF
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
				
				and cell, MAZE_CELL_PROPS
				.IF (cell == MAZE_PROP_WINDOWS)
					bpPop32 MazeCurWallMDL
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
	; Something uses it at start idfk what
	push pbx
	
	bpMEM32 FogDensity, f(0.5)
	
	; Clear all elements
	mov PlrGlyphsInMaze, 0
	and PlrItems, not MAZE_ITEM_MAP
	
	mov MazeCheck, MAZE_CHECK_NONE
	mov MazeCrevice, 0
	mov MazeItems, 0
	mov MazeLocked, MAZE_LOCK_NONE
	mov MazeNote, 0
	mov MazeShop, FALSE
	mov MazeSlam, FALSE
	mov MazeSlamRot, 0
	mov MazeTeleport, FALSE
	
	; Reset entities
	call Maze_ResetEntities
	
	; Change layer string
	invoke IntToStr, StrLayerNumPtr, MazeLayer, TRUE
	vinvoke UI_ShowTextPopup, StrLayerNumber, UISubDur
	
	; Set door world position
	fild MazeSize[8]
	fmul f(2)
	fadd f(1)
	fstp MazeDoorPos.X
	fild MazeSize[12]
	fmul f(2)
	fadd f(1)
	fstp MazeDoorPos.Z
	bpMEM32 MazeDoorPos.Y, CamHeight
	
	; Trench
	.IF (MazeLayer > 22)
		.IF !(rv(nRand, 12))
			call Maze_SpawnTrench
		.ENDIF
	.ENDIF
	
	.IF (MazeState != MAZE_STATE_TRENCH)
		call Maze_SpawnElements
	.ENDIF
	
	pop pbx
	
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
	
	print " ", 13, 10
	print "Generating maze with size "
	print str$(MazeSize[0]), 32
	print str$(MazeSize[4]), 9
	print "Seed: "
	print str$(Seed), 13, 10
	
	bpMEM32 MazeSeed, Seed
	
	mov eax, MazeSize[0]
	dec eax
	mov MazeSize[8], eax
	mov eax, MazeSize[4]
	dec eax
	mov MazeSize[12], eax
	
	; Create maze array (zero memory by default)
	mov Maze, rv(bp2DArrayCreate, 1, MazeSize[0], MazeSize[4])
	mov MazeByteSize, ecx	; Size returned in ecx by function
	invoke RtlZeroMemory, Maze, MazeByteSize
	
	bpMEM32 nRandSeed, Seed
	
	invoke nRand, 7
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
	
	.WHILE TRUE
		.REPEAT
			; Ensure start is always to the right to display tutorial
			.IF (MazeLayer == 1) && (Pos.X == 0) && (Pos.Y == 0)
				mov MazePool, MAZE_FREE_RIGHT
			.ELSE
				mov MazePool, 0
				; Check for available ways to move:
				.IF (Pos.Y > 0)
					dec Pos.Y	; 0, -1
					invoke Maze_GetCellI, Pos.X, Pos.Y
					inc Pos.Y
					.IF !(al & MAZE_CELL_VISITED)
						or MazePool, MAZE_FREE_UP
					.ENDIF
				.ENDIF
				
				.IF (Pos.X > 0)
					dec Pos.X	; -1, 0
					invoke Maze_GetCellI, Pos.X, Pos.Y
					inc Pos.X
					.IF !(al & MAZE_CELL_VISITED)
						or MazePool, MAZE_FREE_LEFT
					.ENDIF
				.ENDIF
				
				mov eax, Pos.Y
				.IF (eax < MazeSize[12])
					inc Pos.Y	; 0, 1
					invoke Maze_GetCellI, Pos.X, Pos.Y
					dec Pos.Y
					.IF !(al & MAZE_CELL_VISITED)
						or MazePool, MAZE_FREE_DOWN
					.ENDIF
				.ENDIF
				
				mov eax, Pos.X
				.IF (eax < MazeSize[8])
					inc Pos.X	; 1, 0
					invoke Maze_GetCellI, Pos.X, Pos.Y
					dec Pos.X
					.IF !(al & MAZE_CELL_VISITED)
						or MazePool, MAZE_FREE_RIGHT
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
		
		xor al, al
		.REPEAT	; Choose random available direction to go
			.IF (MazeType == MAZE_TYPE_SQUIGGLY)
				.IF (al)
					shl al, 1
				.ELSE
					mov al, 1
				.ENDIF
			.ELSE
				invoke nRand, 4
				mov cl, al
				mov al, 1
				shl al, cl
			.ENDIF
		.UNTIL (MazePool & al)
		
		.IF (al == MAZE_FREE_UP)	; Set passes (no walls)
			invoke Maze_OrCellI, Pos.X, Pos.Y, MAZE_CELL_PASSTOP
			dec Pos.Y
		.ELSEIF (al == MAZE_FREE_LEFT)
			invoke Maze_OrCellI, Pos.X, Pos.Y, MAZE_CELL_PASSLEFT
			dec Pos.X
		.ELSEIF (al == MAZE_FREE_DOWN)
			inc Pos.Y
			invoke Maze_OrCellI, Pos.X, Pos.Y, MAZE_CELL_PASSTOP
		.ELSEIF (al == MAZE_FREE_RIGHT)
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

Maze_GenerateLayoutTex PROC EXPORT
	LOCAL buf:BPPtr, texSize:Vector2, pos:Vector2, cell:BYTE
	mov eax, MazeSize[0]
	shl eax, MAZE_MAP_WALL_SHL
	inc eax		; +1 for rightmost edge wall
	mov texSize.X, eax
	mov ecx, MazeSize[4]
	shl ecx, MAZE_MAP_WALL_SHL
	inc ecx
	mov texSize.Y, ecx
	mul ecx
	mov buf, rv(bpMalloc, bpDefHeap, HEAP_ZERO_MEMORY, eax)
	
	print str$(texSize.X), 'x'
	print str$(texSize.Y), 13, 10
	
	push pbx
	xor pbx, pbx
	.WHILE (pbx < MazeSize[0])
		xor pcx, pcx
		.WHILE (pcx < MazeSize[4])
			push pcx
			invoke Maze_GetCellI, pbx, pcx
			mov cell, al
			pop pcx
			
			mov pax, MazeSize[0]
			sub pax, pbx
			mov pos.X, pax
			mov pos.Y, pcx
			shl pos.X, MAZE_MAP_WALL_SHL
			shl pos.Y, MAZE_MAP_WALL_SHL
			push pcx
			invoke bp2DArrayGetOffset, pos.X, pos.Y, texSize.X, 1
			pop pcx
			add pax, buf
			
			.IF !(cell & MAZE_CELL_PASSTOP)
				push pax
				REPEAT MAZE_MAP_WALL_SIZE
					mov BYTE PTR [pax], 255
					dec pax
				ENDM
				pop pax
			.ENDIF
			.IF !(cell & MAZE_CELL_PASSLEFT)
				push pax
				mov pdx, texSize.X
				REPEAT MAZE_MAP_WALL_SIZE
					mov BYTE PTR [pax], 255
					add pax, pdx
				ENDM
				pop pax
			.ENDIF
			
			; Right walls
			.IF (pbx == MazeSize[8])
				push pax
				sub pax, MAZE_MAP_WALL_SIZE
				mov pdx, texSize.X
				REPEAT MAZE_MAP_WALL_SIZE
					mov BYTE PTR [pax], 255
					add pax, pdx
				ENDM
				pop pax
			.ENDIF
			
			; Bottom walls
			.IF (pcx == MazeSize[12])
				push pax
				mov pdx, texSize.X
				shl pdx, MAZE_MAP_WALL_SHL
				add pax, pdx
				REPEAT MAZE_MAP_WALL_SIZE
					mov BYTE PTR [pax], 255
					dec pax
				ENDM
				pop pax
			.ENDIF
			inc pcx
		.ENDW
		inc pbx
	.ENDW
	.IF (MazeLayoutTex)
		invoke glDeleteTextures, 1, ADDR MazeLayoutTex
	.ENDIF
	invoke glGenTextures, 1, ADDR MazeLayoutTex
	invoke glBindTexture, GL_TEXTURE_2D, MazeLayoutTex
	invoke gluBuild2DMipmaps, GL_TEXTURE_2D, 1, texSize.X, texSize.Y, \
	GL_LUMINANCE, GL_UNSIGNED_BYTE, buf
	invoke glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST
	invoke glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST
	
	invoke bpFree, bpDefHeap, 0, buf
	pop pbx
	
	mov eax, MazeSize[0]
	.IF (eax > MazeSize[4])
		mov MazeMapSize.X, FLT_1
		fild MazeSize[4]
		fidiv MazeSize[0]
		fstp MazeMapSize.Y
	.ELSE
		fild MazeSize[0]
		fidiv MazeSize[4]
		fstp MazeMapSize.X
		mov MazeMapSize.Y, FLT_1
	.ENDIF
	ret
Maze_GenerateLayoutTex ENDP

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
	mov ecx, X
	mov edx, Y
	ret
Maze_GetCellF ENDP

;   Get maze cell data from maze cell int coordinates.
Maze_GetCellI PROC EXPORT X:SDWORD, Y:SDWORD
	mov eax, X
	mov ecx, Y
	.IF (SDWORD PTR eax > MazeSize[8]) || (SDWORD PTR ecx > MazeSize[12])
		xor al, al
		ret
	.ENDIF
	Maze_ClampXYI
	invoke bp2DArrayGetOffset, X, Y, MazeSize[0], 1
	mov pcx, pax
	
	add pax, Maze
	mov al, BYTE PTR [pax]
	ret
Maze_GetCellI ENDP

Maze_GetCellOffsetF PROC EXPORT X:REAL4, Y:REAL4
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
	
	Maze_ClampXYI
	invoke bp2DArrayGetOffset, X, Y, MazeSize[0], 1
	mov ecx, X
	mov edx, Y
	ret
Maze_GetCellOffsetF ENDP

Maze_GetRandomPos PROC EXPORT PosPtr:BPPtr, Occupy:BPBool
	LOCAL pos:Vector2
	
	push pbx
	xor pbx, pbx
	mazeRandPosLoop:
	mov eax, MazeSize[8]
	mov pos.X, rv(intRandRange, 1, eax)
	mov eax, MazeSize[12]
	mov pos.Y, rv(intRandRange, 1, eax)
	invoke Maze_GetCellI, pos.X, pos.Y
	.IF (al & MAZE_CELL_VISITED) && (pbx < MazeRandPosMax)
		inc pbx
		jmp mazeRandPosLoop
	.ENDIF
	.IF (Occupy)
		invoke Maze_OrCellI, pos.X, pos.Y, MAZE_CELL_VISITED
	.ENDIF
	
	shl pos.X, 1
	inc pos.X
	shl pos.Y, 1
	inc pos.Y
	mov pax, PosPtr
	fild pos.X
	fstp REAL4 PTR [pax]
	fild pos.Y
	fstp REAL4 PTR [pax+8]
	pop pbx
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
	LOCAL flVal:REAL4, v3Val:Vector3
	
	.IF (MazeState == MAZE_STATE_SAFE)	; Play siren
		.IF (PlrState < PLAYER_STATE_INTRO_DARK)
			.IF !(MazeStateTimer)
				bpMEM32 MazeStateTimer, f(51)
				mov MazeStateCallback, OFFSET mazeSafe
				invoke alSourcePlay, SndSiren
			.ENDIF
			
			fild MazeLayer
			fmul f(0.2)
			fsubr f(1)
			fstp flVal
			
			mov eax, flVal
			.IF (eax & FLT_NEG)
				mov flVal, 0
			.ENDIF
			
			mov MazeSiren, rv(flLerp, MazeSiren, flVal, delta2)
			invoke alSourcef, SndSiren, AL_GAIN, MazeSiren
		.ENDIF
	.ELSEIF (MazeState == MAZE_STATE_GAME)
		.IF (Maze)
			fld MazeNoiseTimer
			fsub deltaTime
			fstp MazeNoiseTimer
			
			.IF (MazeNoiseTimer & FLT_NEG)
				mov MazeNoiseTimer, \
				rv(flRandRange, MazeNoiseTimer[4], MazeNoiseTimer[8])
				
				mov v3Val.X, rv(flRandRange, f(-4), f(4))
				mov v3Val.Z, rv(flRandRange, f(-4), f(4))
				vinvoke Vector32DAdd, ADDR v3Val, OFFSET CamPos
				invoke PlayRandomSnd, ADDR SndRand, 6
				mov ecx, eax
				invoke SndSetPos, ecx, ADDR v3Val
			.ENDIF
		.ENDIF
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
	.ELSEIF (MazeState == MAZE_STATE_TRENCH)
		mov flVal, vrv(Vector32DDistanceSqr, OFFSET CamPos, OFFSET MazeVasPos)
		
		; Vasylko and effects
		mov MazeVasRot, vrv(Vector32DAngle, OFFSET MazeVasPos, OFFSET CamPos)
		fld MazeVasRot
		fsincos
		fmul f(0.7)
		fmul deltaTime
		fadd MazeVasPos.Z
		fstp MazeVasPos.Z
		fmul f(0.7)
		fmul deltaTime
		fadd MazeVasPos.X
		fstp MazeVasPos.X
		fcmp flVal, f(3)
		.IF (Carry?)
			mov ClearBuffers, FALSE
			fcmp flVal, f(0.5)
			.IF (Carry?)
				invoke bpError, s("Can't describe pixel format."), 0
				invoke TerminateProcess, rv(GetCurrentProcess), 0
			.ENDIF
		.ELSE
			mov ClearBuffers, TRUE
		.ENDIF
		invoke SndSetPos, SndWmblykB, ADDR MazeVasPos
		
		.IF !(rv(nRand, 4))
			xor VasAnimPlr.Speed, FLT_NEG
		.ENDIF
		invoke bpProcessAnimPlayer, ADDR VasAnimPlr, deltaTime
		
		; Sky color
		fld flVal
		fmul f(0.1)
		fstp flVal
		mov flVal, rv(flClamp, flVal, 0, f(1))
		invoke Vector3Copy, ADDR v3Val, ADDR clBlack
		invoke Vector3Lerp, ADDR v3Val, ADDR clSky, flVal
		invoke glFogfv, GL_FOG_COLOR, ADDR v3Val
		invoke glClearColor4fv, ADDR v3Val
		
		; Slow player down
		.IF (PlrState == PLAYER_STATE_GAME)
			vinvoke Vector32DLerp, OFFSET CamPos, OFFSET CamPosP, f(0.6)
		.ENDIF
		
		fld PlrSpeedScaled
		fmul deltaTime
		fsubr MazeTrenchTimer
		fstp MazeTrenchTimer
		
		.IF (MazeTrenchTimer & FLT_NEG)
			mov ClearBuffers, TRUE
			
			mov MazeState, MAZE_STATE_GAME
			
			invoke glClearColor4fv, ADDR clBlack
			invoke glFogfv, GL_FOG_COLOR, ADDR clBlack
			invoke alSourceStop, SndAmbT
			invoke alSourcePlay, SndAmb
			
			invoke alSourcef, SndWmblykB, AL_PITCH, f(1)
			invoke alSourcef, SndWmblykB, AL_GAIN, f(1)
			invoke alSourceStop, SndWmblykB
			
			mov UIFade, UI_FADE_IN
			mov UIFadeCallback, 0
			mov UIFadeVal, FLT_1
			
			bpMEM32 CamBaseFOV, f(75)
			bpMEM32 CamRotSmooth, f(16)
			bpMEM32 PlrStepPitch, f(1)
			
			call Maze_SpawnElements
			vinvoke UI_ShowSubtitles, StrCCTrench, UISubDur
			
			invoke alSourcePlay, SndMistake
		.ENDIF
	.ELSEIF (MazeState == MAZE_STATE_LOBBY_CREAK)
		bpMEM32 MazeStateTimer, f(4)
		mov MazeStateCallback, OFFSET mazeFadeOut
		invoke alSourcePlay, SndCreak
		mov MazeState, MAZE_STATE_LOBBY_FALL
	.ELSEIF (MazeState == MAZE_STATE_LOBBY_FALL)
		.IF (MazeStateTimer)
			fcmp MazeStateTimer, f(1)
			.IF (!Carry?)
				fld MazeStateTimer
				fsub f(1)
				fsubr f(3)
				fmul f(0.33333333)
				fmul st, st
				fmul f(0.1)
				fstp flVal
				vinvoke Plr_Shake, flVal
			.ENDIF
		.ELSE
			fld MazeCheckPos.Y
			fadd delta10
			fstp MazeCheckPos.Y
		.ENDIF
	.ENDIF
		
	.IF (MazeStateTimer)
		fld MazeStateTimer
		fsub deltaTime
		fstp MazeStateTimer
		
		mov eax, MazeStateTimer
		.IF (eax & FLT_NEG)
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
		
		mov eax, flVal
		.IF (eax & FLT_NEG)
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
		
		.IF (SettingsGraphicsParticles)
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
		.ELSE
			pop pax
		.ENDIF
		
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
	mazeFadeOut:
		mov UIFade, UI_FADE_OUT
		mov UIFadeVal, 0
		ret
Maze_ProcessState ENDP

Maze_Progress PROC EXPORT
	; Populate previous layer struct
	bpMEM32 MazePrevLayer.MazeSeed, MazeSeed
	invoke Vector2Copy, ADDR MazePrevLayer.MazeSize, ADDR MazeSize
	
	.IF (Maze)
		call Maze_Free
	.ENDIF
	inc MazeLayer
	
	invoke nRand, 6
	.IF (al == 0)
		inc MazeSize[0]
	.ELSEIF (al == 1)
		inc MazeSize[4]
	.ENDIF
	
	.IF (NetSock)
		mov eax, NetMagic
		add eax, MazeLayer
		mov nRandSeed, eax
		
		invoke fpuSetRounding, FPU_ROUND_CEIL
		fild MazeLayer
		fdiv f(3.15)
		fld st
		fistp MazeSize[0]
		invoke fpuSetRounding, FPU_ROUND_FLOOR
		fistp MazeSize[4]
		invoke fpuSetRounding, FPU_ROUND_ROUND
	.ENDIF
	invoke Maze_Generate, nRandSeed
	vinvoke Settings_SaveGame, TRUE
	ret
Maze_Progress ENDP

Maze_Raycast PROC EXPORT Pos:BPPtr, PosTarget:BPPtr
	LOCAL dir:Vector2, cellPos:Vector2, fracPos:Vector2, maxTravel:Vector2
	LOCAL destCell:Vector2
	
	; Get ray direction vector
	mov pax, Pos
	mov pcx, PosTarget
	fld REAL4 PTR [pcx]
	fsub REAL4 PTR [pax]
	fstp dir.X
	fld REAL4 PTR [pcx+8]
	fsub REAL4 PTR [pax+8]
	fstp dir.Y
	invoke Vector2Normalize, ADDR dir
	
	; Set cell pos (+fractional remainder) and destination cell pos
	invoke fpuSetRounding, FPU_ROUND_TRUNC
	mov pax, Pos
	fld REAL4 PTR [pax]
	fmul f(0.5)
	fist cellPos.X
	fisub cellPos.X
	fstp fracPos.X
	fld REAL4 PTR [pax+8]
	fmul f(0.5)
	fist cellPos.Y
	fisub cellPos.Y
	fstp fracPos.Y
	
	fld REAL4 PTR [pcx]
	fmul f(0.5)
	fistp destCell.X
	fld REAL4 PTR [pcx+8]
	fmul f(0.5)
	fistp destCell.Y
	invoke fpuSetRounding, FPU_ROUND_ROUND
	
	; Determine distances to cell wall using fractional parts of position
	fld fracPos.X
	.IF (dir.X & FLT_NEG)
		fchs
	.ELSE
		fsubr f(1)
	.ENDIF
	fdiv dir.X
	fstp maxTravel.X	; Distance to first vertical wall
	
	fld fracPos.Y
	.IF (dir.Y & FLT_NEG)
		fchs
	.ELSE
		fsubr f(1)
	.ENDIF
	fdiv dir.Y
	fstp maxTravel.Y	; Distance to first horizontal wall
	
	; Distances per cell (delta)
	fld dir.X
	fabs
	fdivr f(1)
	fstp fracPos.X
	fld dir.Y
	fabs
	fdivr f(1)
	fstp fracPos.Y
	
	push pbx
	xor pbx, pbx
	.WHILE (pbx < MazeRaycastMax)
		; Check if we've reached destination cell
		mov eax, cellPos.X
		mov ecx, cellPos.Y
		.IF (eax == destCell.X) && (ecx == destCell.Y)
			mov pax, FALSE
			.BREAK
		.ENDIF
		
		fcmp maxTravel.X, maxTravel.Y
		.IF (Carry?)
			; Check vertical wall
			.IF (dir.X & FLT_NEG)	; Left
				; Get cell
				invoke Maze_GetCellI, cellPos.X, cellPos.Y
			.ELSE					; Right
				; Get cell
				mov eax, cellPos.X
				.IF (eax == MazeSize[8])
					mov al, 0
				.ELSE
					inc eax
					invoke Maze_GetCellI, eax, cellPos.Y
				.ENDIF
			.ENDIF
			; Test for vertical wall
			.IF !(al & MAZE_CELL_PASSLEFT)
				mov pax, TRUE
				.BREAK
			.ENDIF
			
			.IF (dir.X & FLT_NEG)	; Cell step
				dec cellPos.X
			.ELSE
				inc cellPos.X
			.ENDIF
			mov eax, cellPos.X
			.IF (eax < 0) || (eax > MazeSize[8])
				xor pax, pax
				.BREAK
			.ENDIF
			fld maxTravel.X
			fadd fracPos.X	; delta x
			fstp maxTravel.X
		.ELSE
			; Check horizontal wall
			.IF (dir.Y & FLT_NEG)	; Top
				; Get cell
				invoke Maze_GetCellI, cellPos.X, cellPos.Y
			.ELSE					; Bottom
				; Get cell
				mov eax, cellPos.Y
				.IF (eax == MazeSize[12])
					mov al, 0
				.ELSE
					inc eax
					invoke Maze_GetCellI, cellPos.X, eax
				.ENDIF
			.ENDIF
			; Test for horizontal wall
			.IF !(al & MAZE_CELL_PASSTOP)
				mov pax, TRUE
				.BREAK
			.ENDIF
			
			.IF (dir.Y & FLT_NEG)	; Cell step
				dec cellPos.Y
			.ELSE
				inc cellPos.Y
			.ENDIF
			mov eax, cellPos.Y
			.IF (eax < 0) || (eax > MazeSize[12])
				xor pax, pax
				.BREAK
			.ENDIF
			fld maxTravel.Y
			fadd fracPos.Y	; delta y
			fstp maxTravel.Y
		.ENDIF
		
		inc pbx
	.ENDW
	pop pbx
	ret
Maze_Raycast ENDP

Maze_ResetEntities PROC EXPORT
	vinvoke HBD_Spawn, HBD_NONE
	vinvoke Kubale_Spawn, KUBALE_NONE
	mov Vebra, VEBRA_NONE
	vinvoke Wmblyk_Spawn, WMBLYK_NONE
	ret
Maze_ResetEntities ENDP

Maze_SetPropI PROC EXPORT X:SDWORD, Y:SDWORD, Prop:BYTE, Rotated:BPBool
	Maze_ClampXYI
	invoke bp2DArrayGetOffset, X, Y, MazeSize[0], 1
	add pax, Maze
	and BYTE PTR [pax], 00000111b
	mov cl, Prop
	or BYTE PTR [pax], cl
	.IF (Rotated)
		or BYTE PTR [pax], MAZE_CELL_ROTATED
	.ENDIF
	ret
Maze_SetPropI ENDP

Maze_SpawnElements PROC EXPORT
	LOCAL bounds:Vector4, posY:DWORD, typeVal:DWORD
	; Crevice
	.IF (rv(nRand, 10) > 6) && (MazeLayer > 4)
		print "Spawned crevice at "
		mov MazeCrevice, 1
		invoke Maze_GetRandomPos, ADDR MazeCrevicePos, TRUE
		Vector32DPrint MazeCrevicePos
		invoke fpuSetRounding, FPU_ROUND_TRUNC
		fld MazeCrevicePos.X
		fistp MazeCreviceCell[0]
		sar MazeCreviceCell[0], 1
		fld MazeCrevicePos.Z
		fistp MazeCreviceCell[4]
		sar MazeCreviceCell[4], 1
		invoke fpuSetRounding, FPU_ROUND_ROUND
	.ENDIF
	
	; Props and clear MAZE_CELL_VISITED
	xor pbx, pbx
	.WHILE (pbx < MazeByteSize)
		mov pcx, Maze
		and BYTE PTR [pcx+pbx], 00000011b
		
		invoke nRand, 2
		.IF !(al)
			invoke intRandRange, 2, 16
			shl eax, MAZE_PROP_SHIFT
			push pax
			invoke nRand, 2
			pop pdx
			mov pcx, Maze
			or BYTE PTR [pcx+pbx], dl	; Prop val
			.IF (al)	; Rotate
				or BYTE PTR [pcx+pbx], MAZE_CELL_ROTATED
			.ENDIF
		.ENDIF
		inc pbx
	.ENDW
	
	.IF !(rv(nRand, 8))	; Room
		mov ebx, MazeSize[0]
		shr ebx, 1	; /2
		mov bounds.X, rv(intRandRange, 1, ebx)
		mov bounds.Z, rv(intRandRange, ebx, MazeSize[0])
		mov ebx, MazeSize[4]
		shr ebx, 1	; /2
		mov bounds.Y, rv(intRandRange, 1, ebx)
		mov bounds.W, rv(intRandRange, ebx, MazeSize[4])
		
		mov typeVal, rv(nRand, 4)	; Fill with doorways or not
		
		mov ebx, bounds.X
		.WHILE (ebx <= bounds.Z)
			mov edx, bounds.Y
			.WHILE (edx <= bounds.W)
				mov posY, edx
				.IF (edx != bounds.W)
					.IF (ebx == bounds.X) || (ebx == bounds.Z)
						invoke Maze_GetCellI, ebx, posY
						.IF (al & MAZE_CELL_PASSLEFT) && (typeVal)
							invoke Maze_SetPropI, ebx, posY, \
							MAZE_PROP_DOORWAY, TRUE
						.ENDIF
					.ELSE
						invoke Maze_OrCellI, ebx, posY, MAZE_CELL_PASSLEFT
					.ENDIF
				.ENDIF
				.IF (ebx != bounds.Z)
					mov edx, posY
					.IF (edx == bounds.Y) || (edx == bounds.W)
						invoke Maze_GetCellI, ebx, posY
						.IF (al & MAZE_CELL_PASSTOP) && (typeVal)
							invoke Maze_SetPropI, ebx, posY, \
							MAZE_PROP_DOORWAY, FALSE
						.ENDIF
					.ELSE
						invoke Maze_OrCellI, ebx, posY, MAZE_CELL_PASSTOP
					.ENDIF
				.ENDIF
				mov edx, posY
				inc edx
			.ENDW
			inc ebx
		.ENDW
		print "Generated room from "
		print str$(bounds.X), ',', 32
		print str$(bounds.Y)
		print " to "
		print str$(bounds.Z), ',', 32
		print str$(bounds.W), 13, 10
	.ENDIF
		
	; Start taburetka, random start pos and env var
	.IF (MazeLayer == 1)
		invoke Maze_SetPropI, 1, 0, MAZE_PROP_TABURETKA, 0
	.ELSE
		invoke nRand, 6		; Random start pos
		.IF !(al)
			mov MazeEntranceCell, rv(nRand, MazeSize[0])
			print "Randomized start cell position", 13, 10
		.ELSE
			mov MazeEntranceCell, 0
		.ENDIF
		
		; Environmental variety
		.IF (MazeLayer <= 21)							; Plain zone
			invoke nRand, 5	; Wall
			SWITCH eax
				CASE 0
					bpMEM32 MazeCurWall, TexWall
				CASE 1
					bpMEM32 MazeCurWall, TexWhitewall
				CASE 2
					bpMEM32 MazeCurWall, TexWallpaper
				CASE 3
					bpMEM32 MazeCurWall, TexPlaster
				CASE 4
					bpMEM32 MazeCurWall, TexWallPainted
			ENDSW
			invoke nRand, 5	; Floor
			SWITCH eax
				CASE 0
					bpMEM32 MazeCurFloor, TexFloor
				CASE 1
					bpMEM32 MazeCurFloor, TexMetalFloor
				CASE 2
					bpMEM32 MazeCurFloor, TexTilefloor
				CASE 3
					bpMEM32 MazeCurFloor, TexFloorParquet
				CASE 4
					bpMEM32 MazeCurFloor, TexFloorLinoleum
			ENDSW
			
			invoke nRand, 2	; Wall model
			SWITCH eax
				CASE 0
					bpMEM32 MazeCurWallMDL, MdlWall
				CASE 1
					bpMEM32 MazeCurWallMDL, MdlWallWainscot
			ENDSW
		.ELSEIF (MazeLayer > 21) && (MazeLayer <= 42)	; Moderate zone
			invoke nRand, 5	; Wall
			SWITCH eax
				CASE 0
					bpMEM32 MazeCurWall, TexWhitewall
				CASE 1
					bpMEM32 MazeCurWall, TexBricks
				CASE 2
					bpMEM32 MazeCurWall, TexConcrete
				CASE 3
					bpMEM32 MazeCurWall, TexPlaster
				CASE 4
					bpMEM32 MazeCurWall, TexWallPainted
			ENDSW
			invoke nRand, 5	; Floor
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
			invoke nRand, 5	; Wall model
			SWITCH eax
				CASE 0
					bpMEM32 MazeCurWallMDL, MdlWall
				CASE 1
					bpMEM32 MazeCurWallMDL, MdlWallClerestory
				CASE 2
					bpMEM32 MazeCurWallMDL, MdlWallWainscot
				CASE 3
					bpMEM32 MazeCurWallMDL, MdlWallSlit
				CASE 4
					bpMEM32 MazeCurWallMDL, MdlWallSlant
			ENDSW
		.ELSEIF (MazeLayer > 42)						; Heavy zone
			invoke nRand, 4	; Wall
			SWITCH eax
				CASE 0
					bpMEM32 MazeCurWall, TexMetal
				CASE 1
					bpMEM32 MazeCurWall, TexBricks
				CASE 2
					bpMEM32 MazeCurWall, TexConcrete
				CASE 3
					bpMEM32 MazeCurWall, TexRustPanel
			ENDSW
			invoke nRand, 4	; Floor
			SWITCH eax
				CASE 0
					bpMEM32 MazeCurFloor, TexDiamond
				CASE 1
					bpMEM32 MazeCurFloor, TexTileBig
				CASE 2
					bpMEM32 MazeCurFloor, TexWalkway
				CASE 3
					bpMEM32 MazeCurFloor, TexWalkwaySmall
			ENDSW
			invoke nRand, 4	; Wall model
			SWITCH eax
				CASE 0
					bpMEM32 MazeCurWallMDL, MdlWallColumn
				CASE 1
					bpMEM32 MazeCurWallMDL, MdlWallArch
				CASE 2
					bpMEM32 MazeCurWallMDL, MdlWallTunnel
				CASE 3
					bpMEM32 MazeCurWallMDL, MdlWallSlant
			ENDSW
		.ENDIF
		invoke nRand, 3
		SWITCH eax
			CASE 0
				bpMEM32 MazeCurRoof, TexRoof
			CASE 1
				bpMEM32 MazeCurRoof, TexMetalRoof
			CASE 2
				bpMEM32 MazeCurRoof, TexConcreteRoof
		ENDSW
	.ENDIF
	
	.IF (MazeState == MAZE_STATE_GAME)
		; Items
		; Compass
		.IF !(PlrItems & MAZE_ITEM_COMPASS) && (MazeLayer > 11)
			.IF !(rv(nRand, 4))
				print "Spawned compass at "
				or MazeItems, MAZE_ITEM_COMPASS
				invoke Maze_GetRandomPos, ADDR MazeCompassPos, TRUE
				Vector32DPrint MazeCompassPos
			.ENDIF
		.ENDIF
		; Glyphs
		.IF (PlrGlyphs < 5)
			.IF (PlrGlyphs > 1)
				vinvoke nRand, PlrGlyphs
			.ELSE
				mov al, 0
			.ENDIF
			.IF !(al)
				print "Spawned glyphs at "
				or MazeItems, MAZE_ITEM_GLYPHS
				invoke Maze_GetRandomPos, ADDR MazeGlyphsPos, TRUE
				Vector32DPrint MazeGlyphsPos
			.ENDIF
		.ENDIF
		
		; Key
		.IF (rv(nRand, MazeLayer) > 7)
			print "Locked maze, key at "
			mov MazeLocked, MAZE_LOCK_LOCKED
			invoke Maze_GetRandomPos, ADDR MazeKeyPos, TRUE
			Vector32DPrint MazeKeyPos
		.ENDIF
		
		; Kubale
		.IF (rv(nRand, MazeLayer) > 10) && (MazeTram == MAZE_TRAM_NONE)
			.IF !(rv(nRand, 3))
				.IF !(rv(nRand, 10)) || !(KubaleAppeared)
					push KUBALE_EVENT
				.ELSE
					push KUBALE_ACTIVE
				.ENDIF
				call Kubale_Spawn
			.ENDIF
		.ENDIF
		
		; Shop
		.IF (MazeByteSize > 80)
			.IF ((PlrGlyphs >= 5) || (MazeItems & MAZE_ITEM_GLYPHS)) \
			&& (MazeEntranceCell == 0) && !(rv(nRand, 2))
				print "Spawned shop", 13, 10
				mov MazeShop, TRUE
				mov MazeShopTimer, 0
				call Maze_GenerateLayoutTex
				
				mov KoluplykAnimPlr.Interpolation, BP_INTERPOLATE_CONSTANT
				invoke bpAnimPlay, ADDR KoluplykAnimPlr, ADDR AnimKoluplykShop
			.ENDIF
		.ENDIF
		
		; Slam door event
		.IF !(rv(nRand, 4))
			print "Will slam door", 13, 10
			mov MazeSlam, TRUE
		.ENDIF
	
		; Teleporters
		.IF (MazeLayer > 17) && !(MazeTram) && !(Vebra) && !(rv(nRand, 4))
			print "Spawned teleporters at "
			invoke Maze_GetRandomPos, ADDR MazeTeleportPos1, TRUE
			invoke Maze_GetRandomPos, ADDR MazeTeleportPos2, TRUE
			Vector32DPrint MazeTeleportPos1
			print "and "
			Vector32DPrint MazeTeleportPos2
			mov MazeTeleport, TRUE
		.ENDIF
		
		; Vebra
		.IF !(rv(nRand, 9)) && (MazeLocked == MAZE_LOCK_NONE)
			call Vebra_Spawn
		.ENDIF
		
		; Wmblyk
		.IF (rv(nRand, MazeLayer) > 3)
			invoke nRand, 5
			SWITCH eax
				CASE 0
					vinvoke Wmblyk_Spawn, WMBLYK_STILL
				CASE 1
					vinvoke Wmblyk_Spawn, WMBLYK_STEALTH_WAIT
				CASE 2
					.IF (MazeLayer > 7)
						vinvoke Wmblyk_Spawn, WMBLYK_WALK
					.ENDIF
			ENDSW
		.ENDIF
		
		; Huenbergondel appears if nobody is present
		.IF (MazeLayer > 21) && !(Kubale) ;&& (!Virdya) && (!HDL)
			.IF (MazeType == MAZE_TYPE_SQUIGGLY)
				.IF (rv(nRand, 2))
					;call HDL_Spawn
				.ENDIF
			.ELSEIF (Wmblyk != WMBLYK_WALK) && (Wmblyk != WMBLYK_STILL)
				vinvoke HBD_Spawn, HBD_SLEEP
			.ENDIF
		.ENDIF
	.ENDIF
		
	SWITCH MazeLayer	; Notes
		CASE 8
			mov MazeNote, 1
			fild MazeEntranceCell
			fmul f(2)
			fadd f(1)
			fstp MazeNotePos.X
			bpMEM32 MazeNotePos.Z, f(3)
			invoke Maze_OrCellI, MazeEntranceCell, 1, MAZE_CELL_PASSTOP
		CASE 12
			mov MazeNote, 2
		CASE 16
			mov MazeNote, 3
		CASE 23
			mov MazeNote, 4
		CASE 36
			mov MazeNote, 5
		CASE 41
			mov MazeNote, 6
		CASE 62
			mov MazeNote, 7
	ENDSW
	.IF (MazeNote > 1)
		invoke Maze_GetRandomPos, ADDR MazeNotePos, TRUE
	.ENDIF
	bpMEM32 MazeNotePos.Y, f(0.01)
	ret
Maze_SpawnElements ENDP

Maze_SpawnTrench PROC EXPORT
	LOCAL pos:Vector2
	
	print "Spawned trench", 13, 10
	fild MazeLayer
	fmul f(0.05)
	fstp MazeTrenchTimer
	
	bpMEM32 MazeCurWall, TexDirt
	bpMEM32 MazeCurFloor, TexDirt
	bpMEM32 MazeCurWallMDL, MdlWallTrench
	
	invoke alSourcePlay, SndAmbT
	invoke alSourcef, SndWmblykB, AL_PITCH, f(0.2)
	invoke alSourcef, SndWmblykB, AL_GAIN, f(10)
	invoke alSourcePlay, SndWmblykB
	invoke alSourceStop, SndAmb
	
	mov MazeState, MAZE_STATE_TRENCH
	
	fild MazeSize[12]
	fmul f(2)
	fsub f(1)
	fstp MazeVasPos.Z
	mov MazeVasPos.X, FLT_1
	invoke bpAnimPlay, ADDR VasAnimPlr, ADDR AnimVasFloat
	
	bpMEM32 CamBaseFOV, f(60)
	bpMEM32 CamRotSmooth, f(4)
	bpMEM32 PlrStepPitch, f(0.25)
	
	; Clean first column and spawn planks
	xor ecx, ecx
	.WHILE (ecx < MazeSize[0])
		mov pos.X, ecx
		xor edx, edx
		.WHILE (edx < MazeSize[4])
			mov pos.Y, edx
			.IF (pos.X == 0) && (pos.Y > 0)
				invoke Maze_OrCellI, pos.X, pos.Y, MAZE_CELL_PASSTOP
			.ENDIF
			
			; Spawn planks
			.IF (rv(nRand, 2))
				invoke Maze_GetCellI, pos.X, pos.Y
				.IF !(al & MAZE_CELL_PASSTOP)
					inc pos.Y
					invoke Maze_GetCellI, pos.X, pos.Y
					dec pos.Y
					.IF !(al & MAZE_CELL_PASSTOP)
						invoke Maze_SetPropI, pos.X, pos.Y, \
						MAZE_PROP_ARCH, FALSE
					.ENDIF
				.ENDIF
			.ENDIF
			
			; Spawn planks
			.IF (rv(nRand, 2))
				invoke Maze_SetPropI, pos.X, pos.Y, MAZE_PROP_WINDOWS, FALSE
			.ENDIF
			
			mov edx, pos.Y
			inc edx
		.ENDW
		mov ecx, pos.X
		inc ecx
	.ENDW
	ret
Maze_SpawnTrench ENDP


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
	invoke Vector2Set, ADDR MazePartAmb.Velocity, f(0.01), f(0.06)
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
	
	mov KoluplykAnimPlr.FrameType, BPA_FRAME_VERTEX	; Init Koluplyk animator
	mov KoluplykAnimPlr.Mesh, OFFSET MeshKoluplyk
	mov MotryaAnimPlr.FrameType, BPA_FRAME_VERTEX	; Init Motrya animator
	mov MotryaAnimPlr.Mesh, OFFSET MeshMotrya
	mov VasAnimPlr.FrameType, BPA_FRAME_VERTEX		; Init Vasylko animator
	mov VasAnimPlr.Mesh, OFFSET MeshVas
	bpMEM32 VasAnimPlr.Speed, f(2)
	ret
Maze_Create ENDP

Maze_Draw PROC EXPORT
	LOCAL flVal:REAL4
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
		
		; Items
		.IF (MazeItems & MAZE_ITEM_COMPASS)
			call glPushMatrix
			invoke glTranslate3fv, ADDR MazeCompassPos
			invoke glBindTexture, GL_TEXTURE_2D, TexCompassWorld
			invoke glCallList, MdlCompassWorld
			call glPopMatrix
		.ENDIF
		.IF (MazeItems & MAZE_ITEM_GLYPHS) && !(UIWhiteFadeVal)
			call glPushMatrix
			invoke glTranslate3fv, ADDR MazeGlyphsPos
			invoke glRotatefr, MazeGlyphsRot, 0, f(1), 0
			invoke glBindTexture, GL_TEXTURE_2D, TexGlyphs
			invoke glCallList, MdlGlyphs
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
		.IF (MazeNote) && !(MazeNote & 16)		; Note
			call glPushMatrix
			invoke glTranslate3fv, ADDR MazeNotePos
			mov flVal, rv(Vector32DLengthSqr, OFFSET MazeNotePos)
			invoke glRotatefr, flVal, 0, f(1), 0
			invoke glRotatef, f(-90), f(1), 0, 0
			invoke glScalef, f(0.4), f(0.4), f(1)
			invoke glBindTexture, GL_TEXTURE_2D, TexPaper
			invoke glEnable, GL_ALPHA_TEST
			invoke glCallList, MdlParticle
			invoke glDisable, GL_ALPHA_TEST
			call glPopMatrix
		.ENDIF
		.IF (MazeTeleport)
			invoke glBindTexture, GL_TEXTURE_2D, 0
			push pbx
			lea pbx, MazeTeleportPos1
			.WHILE (pbx <= OFFSET MazeTeleportPos2)
				call glPushMatrix
				invoke glTranslate3fv, pbx
				invoke glRotatef, MazeTeleportRot, 0, f(1), 0
				invoke glCallList, MdlSigil[0]
				fld MazeTeleportRot
				fmul f(-2)
				fstp flVal
				invoke glRotatef, flVal, 0, f(1), 0
				invoke glCallList, MdlSigil[4]
				call glPopMatrix
				
				add pbx, SIZEOF Vector3
			.ENDW
			pop pbx
		.ENDIF
		.IF (MazeState == MAZE_STATE_TRENCH)
			call glPushMatrix
			invoke glBindTexture, GL_TEXTURE_2D, TexVas
			invoke glTranslate3fv, ADDR MazeVasPos
			invoke glRotatefr, MazeVasRot, 0, f(1), 0
			invoke bpDrawMesh, ADDR MeshVas
			call glPopMatrix
		.ENDIF
	.ENDIF
	.IF (MazeCheck)			; Checkpoint
		; Maze, unlimited maze, but no maze
		.IF !(Maze)
			invoke glBindTexture, GL_TEXTURE_2D, MazeCurWall
			invoke glCallList, MdlDoorwayM
			invoke glBindTexture, GL_TEXTURE_2D, TexDoor
			invoke glCallList, MdlDoorFrame
			call glPushMatrix
			invoke glTranslatef, f(0.65), 0, 0
			invoke glCallList, MdlDoor
			call glPopMatrix
		.ENDIF
		call Maze_DrawCheck
	.ENDIF
	
	
	.IF (PlrState == PLAYER_STATE_EXITING)	; Exit door stairs
		call glPushMatrix
		sub psp, SIZEOF BPPtr*3
		fld MazeDoorPos.X
		fsub f(1)
		fstp REAL4 PTR [psp]
		mov REAL4 PTR [psp+4], 0
		fld MazeDoorPos.Z
		fadd f(1)
		fstp REAL4 PTR [psp+8]
		call glTranslatef
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
	
	.IF (SettingsGraphicsParticles)
		invoke glEnable, GL_BLEND
		invoke glDepthMask, GL_FALSE
		invoke glBlendFunc, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA
		
		.IF (MazeState == MAZE_STATE_GAME)
			;invoke glDisable, GL_CULL_FACE
			;invoke glDisable, GL_FOG
			;invoke glDisable, GL_LIGHTING
			
			invoke glBindTexture, GL_TEXTURE_2D, TexAmbient
			bpMEM32 ParticleMaxAlpha, f(0.5)
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
	LOCAL flVal:REAL4, v3Val:Vector3
	
	.IF (SettingsGraphicsParticles)
		.IF (MazeState == MAZE_STATE_GAME)
			vinvoke Vector3Copy, OFFSET MazePartAmb.Position, OFFSET CamPos
			invoke Particles_Process, ADDR MazePartAmb, deltaFixed
		.ENDIF
		invoke Particles_Process, ADDR MazePartDust, deltaFixed
	.ENDIF
	
	; Exit door
	.IF (MazeLocked == MAZE_LOCK_NONE) || (MazeLocked == MAZE_LOCK_UNLOCKED)
		mov flVal,vrv(Vector32DDistanceSqr,OFFSET CamPos,OFFSET MazeDoorPos)
		fcmp flVal, f(0.7)
		.IF (Carry?) && (PlrState == PLAYER_STATE_GAME)
			.IF (MazeLayer == 21) || (MazeLayer == 42) || (MazeLayer == 63) \
			|| (GameState == GAME_STATE_LOBBY)
				.IF (MazeCheck == MAZE_CHECK_NONE)
					bpMEM32 MazeCheckPos.X, MazeSize[8]
					shl MazeCheckPos.X, 1	; *2
					bpMEM32 MazeCheckPos.Z, MazeSize[12]
					inc MazeCheckPos.Z		; +1 cell
					shl MazeCheckPos.Z, 1	; *2
					mov MazeCheckPos.Y, 0
					invoke Vector32DF, ADDR MazeCheckPos
					mov MazeCheck, MAZE_CHECK_OPEN
					invoke bpAnimPlay, ADDR MotryaAnimPlr, ADDR AnimMotryaIdle
					invoke SndSetPos, SndCheckpoint, ADDR MazeDoorPos
					invoke alSourcePlay, SndCheckpoint
				.ENDIF
			.ELSE
				mov PlrState, PLAYER_STATE_EXIT
			.ENDIF
		.ENDIF
	.ENDIF
	
	; Items
	.IF (MazeItems & MAZE_ITEM_COMPASS)
		mov flVal, vrv(Vector32DDistanceSqr,OFFSET CamPos,OFFSET MazeCompassPos)
		fcmp flVal, MazeItemDist
		.IF (Carry?)
			or PlrItems, MAZE_ITEM_COMPASS
			and MazeItems, not MAZE_ITEM_COMPASS
			vinvoke UI_ShowSubtitles, StrCCCompass, UISubDur
			
			invoke alSourcePlay, SndMistake
		.ENDIF
	.ENDIF
	
	.IF (MazeLocked == MAZE_LOCK_LOCKED)	; Key
		mov flVal, rv(flDistance, MazeKeyRot[0], MazeKeyRot[4])
		fcmp flVal, f(0.05)
		.IF (Carry?)
			mov MazeKeyRot[4], rv(flRandRange, PIN, PI)
		.ENDIF
		fld deltaFixed
		fmul f(0.2)
		fstp flVal
		mov MazeKeyRot[0], rv(flLerpAngle, MazeKeyRot[0], MazeKeyRot[4], flVal)
		
		mov flVal, vrv(Vector32DDistanceSqr, OFFSET CamPos, OFFSET MazeKeyPos)
		fcmp flVal, MazeItemDistImp
		.IF (Carry?)
			mov MazeLocked, MAZE_LOCK_UNLOCKED
			vinvoke UI_ShowSubtitles, StrCCKey, UISubDur
			invoke SndSetPos, SndKey, ADDR MazeKeyPos
			
			invoke alSourcePlay, SndKey	; I love you process-wide OpenAL
			; ALERT WB
		.ENDIF
	.ENDIF
	
	; Notes
	.IF (MazeNote) && !(MazeNote & 16) && (PlrState == PLAYER_STATE_GAME)
		mov flVal, vrv(Vector32DDistanceSqr, OFFSET CamPos, OFFSET MazeNotePos)
		fcmp flVal, MazeItemDist
		.IF (Carry?)
			or MazeNote, 16
			mov deltaScale, 0
			invoke alSourcePlay, SndMistake
		.ENDIF
	.ENDIF
	
	.IF (MazeSlam) && (PlrState == PLAYER_STATE_GAME)	; Slam
		fild MazeEntranceCell
		fmul f(2)
		fadd f(1)
		fstp v3Val.X
		mov v3Val.Z, FLT_1
		mov flVal, vrv(Vector32DDistanceSqr, OFFSET CamPos, ADDR v3Val)
		
		fcmp flVal, f(24)
		.IF (!Carry?) || (MazeSlamRot)
			mov MazeSlamRot, rv(flLerp, MazeSlamRot, f(-24), deltaTime)
		.ENDIF
		.IF (MazeSlamRot)
			fcmp flVal, f(4)
			.IF (Carry?)
				invoke SndSetPos, SndSlam, ADDR v3Val
				invoke alSourcePlay, SndSlam
				mov MazeSlam, FALSE
				; ALERT WB
				; SCARE VIRDYA
			.ENDIF
		.ENDIF
	.ELSEIF !(MazeSlam) && (MazeSlamRot)
		fld delta20
		fmul f(10)
		fstp flVal
		mov MazeSlamRot, rv(flMove, MazeSlamRot, 0, flVal)
	.ENDIF
	ret
Maze_Fixed ENDP

Maze_Process PROC EXPORT
	LOCAL flVal:REAL4, v3Val:Vector3
		
	; Unsafe but necessary
	call Maze_ProcessState
	
	.IF (Maze)
		invoke fpuSetRounding, FPU_ROUND_TRUNC
		fld CamPos.X
		fistp MazePlrPos.X
		sar MazePlrPos.X, 1
		fld CamPos.Z
		fistp MazePlrPos.Y
		sar MazePlrPos.Y, 1
		invoke fpuSetRounding, FPU_ROUND_ROUND
		
		.IF (MazeItems & MAZE_ITEM_GLYPHS)
			fld MazeGlyphsRot
			fadd delta2
			fst MazeGlyphsRot
			fsin
			fmul f(0.3)
			fstp MazeGlyphsPos.Y
			mov MazeGlyphsRot, rv(flAngle, MazeGlyphsRot)
			
			.IF (UIWhiteFadeVal)
				mov UIWhiteFadeVal, vrv(flMove, UIWhiteFadeVal, 0, deltaTime)
				.IF !(UIWhiteFadeVal)
					and MazeItems, not MAZE_ITEM_GLYPHS
					mov UIWhiteFadeVal, 0
				.ENDIF
			.ELSE
				mov flVal, \
				vrv(Vector32DDistanceSqr, OFFSET CamPos, OFFSET MazeGlyphsPos)
				fcmp flVal, MazeItemDist
				.IF (Carry?)
					mov PlrGlyphs, 7
					vinvoke UI_ShowSubtitles, StrCCGlyphsRestore, UISubDur
					mov UIWhiteFadeVal, FLT_1
					
					invoke alSourcePlay, SndMistake
				.ENDIF
			.ENDIF
		.ENDIF

		.IF (MazeTeleport)
			fld MazeTeleportRot
			fadd delta20
			fstp MazeTeleportRot
			fcmp MazeTeleportRot, f(360)
			.IF (Carry?)
				fld MazeTeleportRot
				fsub f(360)
				fstp MazeTeleportRot
			.ENDIF
			
			.IF (PlrState == PLAYER_STATE_GAME)||(PlrState == PLAYER_STATE_ETC)
				push pbx
				lea pbx, MazeTeleportPos1
				.WHILE (pbx <= OFFSET MazeTeleportPos2) && (MazeTeleport)
					mov flVal, vrv(Vector32DDistanceSqr, OFFSET CamPos, pbx)
					fcmp flVal, f(0.3)
					.IF (Carry?)
						mov PlrCanControl, FALSE
						mov PlrState, PLAYER_STATE_ETC
						vinvoke Vector32DLerp, ADDR CamPos, pbx, deltaTime
						mov UIFade, UI_FADE_OUT
						mov UIFadeCallback, 0
						.IF (UIFadeVal == FLT_1)
							mov UIFade, UI_FADE_IN
							mov PlrCanControl, TRUE
							mov PlrState, PLAYER_STATE_GAME
							
							; Beautiful
							.IF (MazeLayer != 22) && (MazeLayer != 43) \
							&& (MazeLayer != 20) && (MazeLayer != 41) \
							&& (MazeLayer != 62) && !(rv(nRand, 8)) \
							&& (MazePrevLayer.MazeSeed != 0)
								; Teleport to next or previous layer	
								.IF !(rv(nRand, 3))
									; Previous
									dec MazeLayer						
									call Maze_Free
									invoke Vector2Copy, ADDR MazeSize, \
									ADDR MazePrevLayer.MazeSize
									invoke Maze_Generate, MazePrevLayer.MazeSeed
								.ELSE
									; Next
									call Maze_Progress
								.ENDIF
								
								vinvoke Maze_GetRandomPos, OFFSET CamPos, TRUE
								
								invoke alSourcePlay, SndDistress
								vinvoke UI_ShowSubtitles, StrCCTeleportBad, \
								UISubDur
							.ELSE
								; Normal teleport behavior
								.IF (pbx == OFFSET MazeTeleportPos1)
									vinvoke Plr_Teleport, MazeTeleportPos2.X,\
									MazeTeleportPos2.Z
									print "Teleported to teleport 2: "
									Vector32DPrint MazeTeleportPos2
								.ELSE
									vinvoke Plr_Teleport, MazeTeleportPos1.X,\
									MazeTeleportPos1.Z
									print "Teleported to teleport 1: "
									Vector32DPrint MazeTeleportPos1
								.ENDIF
								
								invoke alSourcePlay, SndMistake
								vinvoke UI_ShowSubtitles, StrCCTeleport, \
								UISubDur
							.ENDIF
							
							.IF (MazeCrevice)
								mov MazeCrevice, 1
							.ENDIF
							mov MazeTeleport, FALSE
						.ENDIF
					.ENDIF
					add pbx, SIZEOF Vector3
				.ENDW
				pop pbx
			.ENDIF		
		.ENDIF
		.IF (MazeShop)
			
			mov flVal, \							; (0, 0, 1)
			vrv(Vector32DDistanceSqr, OFFSET CamPos, OFFSET Vector3Forward)
			.IF !(MazeShopTimer)
				fcmp flVal, MazeItemDistImp
				.IF (Carry?)
					.IF !(UISubtitlesTimer)
						vinvoke UI_ShowSubtitles, StrCCShop, f(0.1)
					.ENDIF
					
					.IF (InputConfirm)
						.IF (PlrGlyphs >= 5)
							bpMEM32 MazeShopTimer, f(-2)
							vinvoke UI_ShowSubtitles, StrCCShopBuy, UISubDur
							sub PlrGlyphs, 5
							or PlrItems, MAZE_ITEM_MAP
							
							.IF (SettingsGraphicsInterpolation)
								mov KoluplykAnimPlr.Interpolation, \
								BP_INTERPOLATE_LINEAR
							.ENDIF
							invoke bpAnimPlay, ADDR KoluplykAnimPlr, \
							ADDR AnimKoluplykDig
							
							invoke alSourcePlay, SndDig
							invoke alSourcePlay, SndMistake
							invoke alSourcePlay, SndHBD
						.ELSE
							vinvoke UI_ShowSubtitles, StrCCShopNo, UISubDur
						.ENDIF
					.ENDIF
				.ENDIF
			.ELSE
				fld MazeShopTimer
				fadd deltaTime
				fstp MazeShopTimer
				
				vinvoke Plr_Shake, f(0.03)
				invoke Vector3Set, ADDR MazePartDust.Position, \
				MazeShopTimer, f(2), f(1)
				.IF (SettingsGraphicsParticles)
					invoke Particles_Spawn, ADDR MazePartDust, 1
				.ENDIF
				invoke SndSetPos, SndHBD, ADDR MazePartDust.Position
				
				.IF !(MazeShopTimer & FLT_NEG)
					mov MazeShop, FALSE
					invoke alSourceStop, SndHBD
				.ENDIF
			.ENDIF
			
			invoke bpProcessAnimPlayer, ADDR KoluplykAnimPlr, deltaTime
		.ENDIF
	.ENDIF
	
	.IF (MazeCheck)
		; Collide
		invoke Vector32DCopy, ADDR v3Val, ADDR MazeCheckPos
		fld v3Val.X
		fadd f(0.45)
		fstp v3Val.X
		fld v3Val.Z
		fadd f(2)
		fstp v3Val.Z
		vinvoke Collide_Rectangle, OFFSET CamPos, ADDR v3Val, f(0.8), f(4.7)
		fld v3Val.X
		fadd f(1)
		fstp v3Val.X
		vinvoke Collide_Rectangle, OFFSET CamPos, ADDR v3Val, f(0.8), f(4.7)
		fld v3Val.X
		fsub f(1.5)
		fstp v3Val.X
		fld v3Val.Z
		fadd f(3)
		fstp v3Val.Z
		vinvoke Collide_Rectangle, OFFSET CamPos, ADDR v3Val, f(0.8), f(2.7)
		fld v3Val.X
		fadd f(2)
		fstp v3Val.X
		vinvoke Collide_Rectangle, OFFSET CamPos, ADDR v3Val, f(0.8), f(2.7)
		fld v3Val.X
		fsub f(1.05)
		fstp v3Val.X
		fld v3Val.Z
		fadd f(1.1)
		fstp v3Val.Z
		vinvoke Collide_Rectangle, OFFSET CamPos, ADDR v3Val, f(2.7), f(0.9)
		.IF !(Maze)
			invoke Vector32DCopy, ADDR v3Val, ADDR MazeCheckPos
			fld v3Val.X
			fadd f(1)
			fstp v3Val.X
			vinvoke Collide_Rectangle, OFFSET CamPos, ADDR v3Val, f(2.7), f(0.9)
		.ENDIF
		
		invoke SndFade, SndAmb, f(0), delta2
				
		; Process Motrya animator
		.IF (MazeCheck != MAZE_CHECK_SAVED)
			invoke bpProcessAnimPlayer, ADDR MotryaAnimPlr, deltaTime
		.ENDIF
		
		fld CamPos.Z
		fsub MazeCheckPos.Z
		fstp flVal
		.IF (MazeCheck == MAZE_CHECK_OPEN)
			mov MazeDoorRot, rv(flLerp, MazeDoorRot, f(-100), delta2)
			
			fcmp flVal, f(1)
			.IF (!Carry?)
				mov MazeCheck, MAZE_CHECK_CLOSE
				invoke SndSetPos, SndDoorClose, ADDR MazeDoorPos
				invoke alSourcePlay, SndDoorClose
				
				vinvoke UI_ShowSubtitles, StrCCSave, UISubDur
			.ENDIF
		.ELSEIF (MazeCheck == MAZE_CHECK_CLOSE)
			mov MazeDoorRot, rv(flLerp, MazeDoorRot, f(0), delta2)
			
			.IF (MotryaAnimPlr.TrackPtr == OFFSET AnimMotryaIdle)
				fcmp flVal, f(2)
				.IF (!Carry?)
					invoke bpAnimPlay, ADDR MotryaAnimPlr, ADDR AnimMotryaSave
					bpMEM32 MazeStateTimer, f(0.5)
					mov MazeStateCallback, 0
					invoke alSourcePlay, SndSave
				.ENDIF
			.ELSE
				.IF (!MazeStateTimer)
					mov MazeCheck, MAZE_CHECK_SAVED
					mov MazeStateTimer, FLT_1
					mov MazeDoorRot, 0
					invoke Vector32DSet, ADDR MazeDoorPos, f(1), f(5)
					invoke Vector32DAdd, ADDR MazeDoorPos, ADDR MazeCheckPos
					invoke Vector3Set, ADDR MazeCheckErasePos,f(1),f(1.5),f(0.5)
					invoke Vector32DAdd,ADDR MazeCheckErasePos,ADDR MazeCheckPos
					invoke Vector3Set, ADDR MazeCheckErasePosL, f(1), f(1), f(4)
					invoke Vector32DAdd, ADDR MazeCheckErasePosL, \
					ADDR MazeCheckPos
					call Maze_ResetEntities
					vinvoke UI_ShowSubtitles, StrCCSaved, UISubDur
					
					vinvoke Settings_EraseSave, TRUE
					vinvoke Settings_SaveGame, FALSE
					
					invoke alSourcePlay, SndMus[8]
				.ENDIF
				fld MazeStateTimer
				fsubr f(0.5)
				fld st
				fmul f(0.1)
				fstp flVal
				fmul f(2)
				fstp UIWhiteFadeVal
				vinvoke Plr_Shake, flVal
			.ENDIF
		.ELSEIF (MazeCheck == MAZE_CHECK_SAVED)
			.IF !(NetSock)
				bpMEM32 UIWhiteFadeVal, MazeStateTimer
			.ENDIF
			
			.IF (PlrState == PLAYER_STATE_EXITING)
				invoke SndFade, SndMus[8], f(0), delta2
			.ELSEIF (PlrState == PLAYER_STATE_GAME)
				fld deltaTime
				fmul f(0.3)
				fstp flVal
				invoke SndFade, SndMus[8], f(0.5), flVal
				
				; Exit door
				mov flVal, \
				vrv(Vector32DDistanceSqr, OFFSET CamPos, OFFSET MazeDoorPos)
				fcmp flVal, MazeItemDist
				.IF (Carry?)
					vinvoke UI_ShowSubtitles, StrCCCheckpoint, f(0.1)
					.IF (InputConfirm)
						.IF (NetSock)
							.IF (NetHosting)
								invoke Net_FormSend, NET_START_GAME, 0
							.ELSE
								invoke Net_FormSend, NET_START_GAME_REQUEST, \
								NetSock
							.ENDIF
						.ELSE
							mov PlrState, PLAYER_STATE_EXIT
						.ENDIF
					.ENDIF
				.ENDIF
			.ENDIF
				
			
			invoke Vector3Lerp, ADDR MazeCheckErasePosL,ADDR MazeCheckErasePos,\
			deltaTime
			; Erase save light
			mov flVal,\
			vrv(Vector32DDistanceSqr, OFFSET CamPos, OFFSET MazeCheckErasePos)
			fcmp flVal, MazeItemDist
			.IF (Carry?)
				vinvoke UI_ShowSubtitles, StrCCSaveErase, f(0.1)
				.IF (InputConfirm)
					mov eax, f(-100)
					mov MazeCheckErasePos.Z, eax
					mov MazeCheckErasePosL.Z, eax
					mov MazeStateTimer, FLT_1
					
					vinvoke Settings_EraseSave, FALSE
					
					invoke alSourcePlay, SndMistake
				.ENDIF
			.ENDIF
		.ENDIF
	.ENDIF
		
	ret
Maze_Process ENDP
