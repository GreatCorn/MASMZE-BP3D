ENUM	HBD_NONE, \
		HBD_SLEEP, \
		HBD_MOVE

.DATA
HBD			BPEnum HBD_NONE
HBDAnimPlr	BPAnimPlayer <>
HBDCell		Vector2 <>
HBDPos		Vector3 <>
HBDPosT		Vector2 <>	; Target position (in target cell)
HBDRot		REAL4 0.0, 0.0	; Displayed rotation, functional rotation
HBDTimer	REAL4 0.0

.CODE
HBD_Spawn PROC EXPORT State:BPEnum
	mov al, State
	mov HBD, al
	.IF (State == HBD_NONE)
		invoke alSourceStop, SndHBD
	.ELSE
		print "Spawned Huenbergondel at "
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
	.ENDIF
	ret
HBD_Spawn ENDP


HBD_Draw PROC EXPORT
	invoke glBindTexture, GL_TEXTURE_2D, TexHBD
	call glPushMatrix
	invoke glTranslate3fv, ADDR HBDPos
	invoke glRotatefr, HBDRot[0], 0, f(1), 0
	invoke bpDrawMesh, ADDR MeshHBD
	invoke glScalef, f(-1), f(1), f(1)
	invoke glCullFace, GL_FRONT
	invoke bpDrawMesh, ADDR MeshHBD
	invoke glCullFace, GL_BACK
	call glPopMatrix
	ret
HBD_Draw ENDP

HBD_Process PROC EXPORT
	LOCAL movePool:BYTE, v3Val:Vector3, hbdFwd:Vector3
	
	fld HBDTimer
	fsub deltaTime
	fstp HBDTimer
	
	.IF (HBDTimer & FLT_NEG)
		.IF (HBD == HBD_SLEEP)
			mov HBD, HBD_MOVE
			bpMEM32 HBDTimer, f(2)
			
			; Choose direction to go
			mov movePool, 0
			.IF (HBDCell.Y > 0)		; Up
				.IF (rv(Maze_CheckFree, HBDCell.X, HBDCell.Y, FALSE, TRUE))
					or movePool, MAZE_FREE_UP
				.ENDIF
			.ENDIF
			.IF (HBDCell.X > 0)		; Left
				.IF (rv(Maze_CheckFree, HBDCell.X, HBDCell.Y, TRUE, TRUE))
					or movePool, MAZE_FREE_LEFT
				.ENDIF
			.ENDIF
			mov eax, HBDCell.Y
			.IF (eax < MazeSize[12]); Down
				inc HBDCell.Y
				.IF (rv(Maze_CheckFree, HBDCell.X, HBDCell.Y, FALSE, TRUE))
					or movePool, MAZE_FREE_DOWN
				.ENDIF
				dec HBDCell.Y
			.ENDIF
			mov eax, HBDCell.X
			.IF (eax < MazeSize[8])	; Right
				inc HBDCell.X
				.IF (rv(Maze_CheckFree, HBDCell.X, HBDCell.Y, TRUE, TRUE))
					or movePool, MAZE_FREE_RIGHT
				.ENDIF
				dec HBDCell.X
			.ENDIF
			.IF !(movePool)
				print "Huenbergondel stuck", 13, 10
				ret
			.ENDIF
			
			xor al, al
			.REPEAT	; Choose random available direction to go
				invoke nRand, 4
				mov cl, al
				mov al, 1
				shl al, cl
				mov ecx, HBDRot[4]
				; Give it up baby
				.IF ((ecx == 0) && (al == MAZE_FREE_UP)) \
				|| ((ecx == PIHalf) && (al == MAZE_FREE_LEFT)) \
				|| ((ecx == PI) && (al == MAZE_FREE_DOWN)) \
				|| ((ecx == PIHalfN) && (al == MAZE_FREE_RIGHT))
					; Check if HBD is going backward
					.IF (movePool != al)	; Not our only option
						xor al, al	; Try again
					.ENDIF
				.ENDIF
			.UNTIL (movePool & al)
			
			.IF (al == MAZE_FREE_UP)
				bpMEM32 HBDRot[4], PI
				dec HBDCell.Y
			.ELSEIF (al == MAZE_FREE_LEFT)
				bpMEM32 HBDRot[4], PIHalfN
				dec HBDCell.X
			.ELSEIF (al == MAZE_FREE_DOWN)
				mov HBDRot[4], 0
				inc HBDCell.Y
			.ELSEIF (al == MAZE_FREE_RIGHT)
				bpMEM32 HBDRot[4], PIHalf
				inc HBDCell.X		
			.ENDIF
			
			invoke Vector2Copy, ADDR HBDPosT, ADDR HBDCell
			invoke Vector2F, ADDR HBDPosT
			invoke Vector2MulF, ADDR HBDPosT, f(2)
			invoke Vector2Add, ADDR HBDPosT, ADDR Vector2One
			
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
	
	invoke Collide_Distance, ADDR CamPos, ADDR HBDPos, f(0.85), 0
	mov movePool, al
	
	.IF (HBD == HBD_MOVE)
		mov HBDRot[0], rv(flLerpAngle, HBDRot[0], HBDRot[4], delta10)
		fcmp HBDTimer, f(1)
		.IF (Carry?)
			mov HBDPos.X, rv(flMove, HBDPos.X, HBDPosT.X, delta2)
			mov HBDPos.Z, rv(flMove, HBDPos.Z, HBDPosT.Y, delta2)
			invoke SndSetPos, SndHBD, ADDR HBDPos
			.IF (rv(SndPlaying, SndHBD) != AL_PLAYING)
				invoke alSourcePlay, SndHBD
			.ENDIF
	
			.IF (movePool) && (PlrState == PLAYER_STATE_GAME)
				; Calculate dot product to check if plr is in front
				fld HBDRot[4]
				fsincos
				fstp hbdFwd.Z
				fstp hbdFwd.X
				
				invoke Vector32DCopy, ADDR v3Val, ADDR CamPos
				invoke Vector32DSub, ADDR v3Val, ADDR HBDPos
				invoke Vector32DNormalize, ADDR v3Val
				invoke Vector32DDot, ADDR v3Val, ADDR hbdFwd
				
				fcmp eax, f(0.5)
				.IF (!Carry?)
					bpMPM UIDeadTipStr, StrTipHBD
					invoke alSourcePlay, SndImpact
					mov PlrState, PLAYER_STATE_DYING
				.ENDIF
			.ENDIF
		.ENDIF
	.ENDIF
	
	invoke bpProcessAnimPlayer, ADDR HBDAnimPlr, deltaTime
	ret
HBD_Process ENDP
