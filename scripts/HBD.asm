ENUM	HBD_NONE, \
		HBD_SLEEP, \
		HBD_MOVE

.DATA
HBD			BPEnum HBD_NONE
HBDAnimPlr	BPAnimPlayer <>
HBDCell		Vector2 <>
HBDPos		Vector3 <>
HBDPosT		Vector3 <>	; Target position (in target cell)
HBDRot		REAL4 0.0, 0.0	; Displayed rotation, functional rotation
HBDTimer	REAL4 0.0
HBDSpeed	REAL4 1.0

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
		.IF (NetSock && !NetHosting)
			bpMEM32 HBDTimer, f(10)
		.ELSE
			mov HBDTimer, rv(flRandRange, f(5), f(8))
		.ENDIF
		
		.IF (MazeLayer < 22)
			mov HBDSpeed, FLT_1
		.ELSEIF (MazeLayer < 43)
			bpMEM32 HBDSpeed, f(1.5)
		.ELSE
			bpMEM32 HBDSpeed, f(3)
		.ENDIF
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

; Programming warcrimes
HBD_Process PROC EXPORT
	LOCAL movePool:BYTE, v3Val:Vector3, hbdFwd:Vector3
	
	fld deltaTime
	fmul HBDSpeed
	fsubr HBDTimer
	fstp HBDTimer
	
	.IF (HBDTimer & FLT_NEG)
		.IF (HBD == HBD_SLEEP)			
			.IF (NetSock && !NetHosting)
				; oughhh    i donr knoe ???
			.ELSE
				; Choose direction to go
				mov movePool, 0
				.IF (HBDCell.Y > 0)		; Up
					.IF (rv(Maze_CheckFree, HBDCell.X, HBDCell.Y, FALSE, TRUE))
						mov eax, HBDCell.X
						mov ecx, HBDCell.Y
						dec ecx
						.IF !(MazeCrevice) || (eax != MazeCreviceCell[0]) || \
						(ecx != MazeCreviceCell[4])
							or movePool, MAZE_FREE_UP
						.ENDIF						
					.ENDIF
				.ENDIF
				.IF (HBDCell.X > 0)		; Left
					.IF (rv(Maze_CheckFree, HBDCell.X, HBDCell.Y, TRUE, TRUE))
						mov eax, HBDCell.X
						mov ecx, HBDCell.Y
						dec eax
						.IF !(MazeCrevice) || (eax != MazeCreviceCell[0]) || \
						(ecx != MazeCreviceCell[4])
							or movePool, MAZE_FREE_LEFT
						.ENDIF	
					.ENDIF
				.ENDIF
				mov eax, HBDCell.Y
				.IF (eax < MazeSize[12]); Down
					inc HBDCell.Y
					.IF (rv(Maze_CheckFree, HBDCell.X, HBDCell.Y, FALSE, TRUE))
						mov eax, HBDCell.X
						mov ecx, HBDCell.Y
						.IF !(MazeCrevice) || (eax != MazeCreviceCell[0]) || \
						(ecx != MazeCreviceCell[4])
							or movePool, MAZE_FREE_DOWN
						.ENDIF	
					.ENDIF
					dec HBDCell.Y
				.ENDIF
				mov eax, HBDCell.X
				.IF (eax < MazeSize[8])	; Right
					inc HBDCell.X
					.IF (rv(Maze_CheckFree, HBDCell.X, HBDCell.Y, TRUE, TRUE))
						mov eax, HBDCell.X
						mov ecx, HBDCell.Y
						.IF !(MazeCrevice) || (eax != MazeCreviceCell[0]) || \
						(ecx != MazeCreviceCell[4])
							or movePool, MAZE_FREE_RIGHT
						.ENDIF	
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
				
				invoke Vector32DSet, ADDR HBDPosT, HBDCell.X, HBDCell.Y
				invoke Vector32DF, ADDR HBDPosT
				invoke Vector32DMulF, ADDR HBDPosT, f(2)
				invoke Vector32DAdd, ADDR HBDPosT, ADDR Vector3One
				
				invoke Net_FormSend, NET_MAZE_ENTITIES, NetSock
			.ENDIF
			
			mov HBD, HBD_MOVE
			bpMEM32 HBDTimer, f(2)
			
			invoke SndSetPos, SndHBDO, ADDR HBDPos
			invoke alSourcePlay, SndHBDO
			
			mov HBDAnimPlr.Speed, FLT_1 or FLT_NEG
			invoke bpAnimPlay, ADDR HBDAnimPlr, ADDR AnimHBDBlink
		.ELSEIF (HBD == HBD_MOVE)
			mov HBD, HBD_SLEEP
			bpMEM32 HBDTimer, f(4)
			
			invoke Vector32DCopy, ADDR HBDPos, ADDR HBDPosT
			invoke alSourceStop, SndHBD
			
			mov HBDAnimPlr.Speed, FLT_1
			invoke bpAnimPlay, ADDR HBDAnimPlr, ADDR AnimHBDBlink
		.ENDIF
	.ENDIF
	
	invoke Collide_Distance, ADDR CamPos, ADDR HBDPos, f(0.7), 0
	mov movePool, al
	
	.IF (HBD == HBD_MOVE)
		fld delta10
		fmul HBDSpeed
		fstp v3Val.X
		mov HBDRot[0], rv(flLerpAngle, HBDRot[0], HBDRot[4], v3Val.X)
		fcmp HBDTimer, f(1)
		.IF (Carry?)
			fld delta2
			fmul HBDSpeed
			fstp v3Val.X
			invoke Vector32DMove, ADDR HBDPos, ADDR HBDPosT, v3Val.X
			invoke SndSetPos, SndHBD, ADDR HBDPos
			.IF (rv(SndPlaying, SndHBD) != AL_PLAYING)
				invoke alSourcePlay, SndHBD
			.ENDIF
			
			mov v3Val.X, rv(Vector32DDistanceSqr, OFFSET HBDPos, OFFSET HBDPosT)
			invoke Maze_GetCellI, HBDCell.X, HBDCell.Y
			and al, MAZE_CELL_PROPS
			.IF (al == MAZE_PROP_ARCH)
				fcmp v3Val.X, f(0.8)
				.IF (Carry?)
					invoke Maze_SetPropI, HBDCell.X, HBDCell.Y, 0, FALSE
					invoke SndSetPos, SndBreak, ADDR HBDPos
					invoke alSourcePlay, SndBreak
					.IF (SettingsGraphicsParticles)
						invoke Vector32DCopy, ADDR MazePartDust.Position, \
						ADDR HBDPos
						invoke Particles_Spawn, ADDR MazePartDust, 32
					.ENDIF
				.ENDIF
			.ELSE
				.IF (rv(SndPlaying, SndBreak) == AL_PLAYING)
					mov v3Val.Y, \
					rv(Vector32DDistanceSqr, OFFSET HBDPos, OFFSET CamPos)
					fcmp v3Val.Y, f(1)
					.IF (Carry?)
						mov v3Val.Y, FLT_1
					.ENDIF
					fld v3Val.X
					fmul f(0.3)
					fdiv v3Val.Y
					fstp v3Val.X
					print real4$(v3Val.X), 13, 10
					invoke Plr_Shake, v3Val.X
				.ENDIF
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
