ENUM	HBD_NONE, \
		HBD_SLEEP, \
		HBD_MOVE

.DATA
HBD			BPEnum HBD_NONE
HBDAnimPlr	BPAnimPlayer <>
HBDCell		Vector2 <>
HBDPos		Vector3 <>
HBDPosT		Vector2 <>	; Target position (in target cell)
HBDRot		REAL4 0.0, 0.0	; Functional rotation, displayed rotation
HBDTimer	REAL4 0.0

.CODE
HBD_Spawn PROC EXPORT
	print "Spawned Huenbergondel at "
	mov HBD, HBD_SLEEP
	mov HBDAnimPlr.FrameType, BPA_FRAME_VERTEX
	mov HBDAnimPlr.Mesh, OFFSET MeshHBD
	invoke Maze_GetRandomPos, ADDR HBDPos, TRUE
	Vector32DPrint HBDPos
	invoke Vector2Set, ADDR HBDPosT, HBDPos.X, HBDPos.Z
	invoke Vector2Copy, ADDR HBDCell, ADDR HBDPosT
	invoke fpuSetRounding, FPU_ROUND_TRUNC
	invoke Vector2RoundInt, ADDR HBDCell
	invoke fpuSetRounding, FPU_ROUND_ROUND
	sar HBDCell.X, 1
	sar HBDCell.Y, 1
	mov HBDTimer, rv(flRandRange, f(5), f(8))
	ret
HBD_Spawn ENDP


HBD_Draw PROC EXPORT
	invoke glBindTexture, GL_TEXTURE_2D, TexHBD
	call glPushMatrix
	invoke glTranslate3fv, ADDR HBDPos
	invoke glRotatefr, HBDRot[4], 0, f(1), 0
	invoke bpDrawMesh, ADDR MeshHBD
	invoke glScalef, f(-1), f(1), f(1)
	invoke glCullFace, GL_FRONT
	invoke bpDrawMesh, ADDR MeshHBD
	invoke glCullFace, GL_BACK
	call glPopMatrix
	ret
HBD_Draw ENDP

HBD_Process PROC EXPORT
	LOCAL MovePool:BYTE
	
	fld HBDTimer
	fsub deltaTime
	fstp HBDTimer
	
	.IF (HBDTimer & FLT_NEG)
		.IF (HBD == HBD_SLEEP)
			mov HBD, HBD_MOVE
			bpMEM32 HBDTimer, f(2)
			
			; Choose direction to go
			mov MovePool, 0
			.IF (HBDCell.Y > 0)		; Up
				invoke Maze_GetCellI, HBDCell.X, HBDCell.Y
				.IF (al & MAZE_CELL_PASSTOP)
					or MovePool, FREE_UP
				.ENDIF
			.ENDIF
			.IF (HBDCell.X > 0)		; Left
				invoke Maze_GetCellI, HBDCell.X, HBDCell.Y
				.IF (al & MAZE_CELL_PASSLEFT)
					or MovePool, FREE_LEFT
				.ENDIF
			.ENDIF
			mov eax, HBDCell.Y
			.IF (eax < MazeSize[12]); Down
				inc HBDCell.Y
				invoke Maze_GetCellI, HBDCell.X, HBDCell.Y
				dec HBDCell.Y
				.IF (al & MAZE_CELL_PASSTOP)
					or MovePool, FREE_DOWN
				.ENDIF
			.ENDIF
			mov eax, HBDCell.X
			.IF (eax < MazeSize[8])	; Right
				inc HBDCell.X
				invoke Maze_GetCellI, HBDCell.X, HBDCell.Y
				dec HBDCell.X
				.IF (al & MAZE_CELL_PASSLEFT)
					or MovePool, FREE_RIGHT
				.ENDIF
			.ENDIF
			
			xor al, al
			.REPEAT	; Choose random available direction to go
				invoke nRand, 4
				mov cl, al
				mov al, 1
				shl al, cl
			.UNTIL (MovePool & al)
			
			.IF (al == FREE_UP)
				bpMEM32 HBDRot[4], PI
				dec HBDCell.Y
			.ELSEIF (al == FREE_LEFT)
				bpMEM32 HBDRot[4], PIHalfN
				dec HBDCell.X
			.ELSEIF (al == FREE_DOWN)
				mov HBDRot[4], 0
				inc HBDCell.Y
			.ELSEIF (al == FREE_RIGHT)
				bpMEM32 HBDRot[4], PIHalf
				inc HBDCell.X		
			.ENDIF
			
			invoke Vector2Copy, ADDR HBDPosT, ADDR HBDCell
			invoke Vector2F, ADDR HBDPosT
			invoke Vector2MulF, ADDR HBDPosT, f(2)
			invoke Vector2Add, ADDR HBDPosT, ADDR Vector2One
			
			Vector2Print HBDPosT
			
			invoke SndSetPos, SndHBDO, ADDR HBDPos
			invoke alSourcePlay, SndHBDO
			
			mov HBDAnimPlr.Speed, FLT_1 or FLT_NEG
			invoke bpAnimPlay, ADDR HBDAnimPlr, ADDR AnimHBDBlink
		.ELSEIF (HBD == HBD_MOVE)
			mov HBD, HBD_SLEEP
			bpMEM32 HBDTimer, f(4)
			
			invoke Vector32DSet, ADDR HBDPos, HBDPosT.X, HBDPosT.Y
			invoke alSourceStop, SndHBD
			
			mov HBDAnimPlr.Speed, FLT_1
			invoke bpAnimPlay, ADDR HBDAnimPlr, ADDR AnimHBDBlink
		.ENDIF
	.ENDIF
	
	.IF (HBD == HBD_MOVE)
		mov HBDRot[0], rv(flLerpAngle, HBDRot[0], HBDRot[4], delta2)
		fcmp HBDTimer, f(1)
		.IF (Carry?)
			mov HBDPos.X, rv(flMove, HBDPos.X, HBDPosT.X, delta2)
			mov HBDPos.Z, rv(flMove, HBDPos.Z, HBDPosT.Y, delta2)
			invoke SndSetPos, SndHBD, ADDR HBDPos
			.IF (rv(SndPlaying, SndHBD) != AL_PLAYING)
				invoke alSourcePlay, SndHBD
			.ENDIF
		.ENDIF
	.ENDIF
	
	invoke Collide_Distance, ADDR CamPos, ADDR HBDPos, f(1.2), 0
	.IF (al) && (HBD == HBD_MOVE) && (PlrState == PLAYER_STATE_GAME)
		
		invoke alSourcePlay, SndImpact
		mov PlrState, PLAYER_STATE_DYING
	.ENDIF
	
	invoke bpProcessAnimPlayer, ADDR HBDAnimPlr, deltaTime
	ret
HBD_Process ENDP
