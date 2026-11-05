ENUM \
	HDL_NONE, \
	HDL_WANDER, \
	HDL_RUSH, \
	HDL_SEARCH, \
	HDL_ATTACK, \
	HDL_ATTACKING

.DATA
HDL			BPEnum HDL_NONE
HDLAnimPlr	BPAnimPlayer <>
HDLAttackTimer	REAL4 0.0
HDLCell		Vector2 <>
HDLCellT	Vector2 <>		; Final target cell
HDLCellNext	Vector2 <>		; Next cell to move to
HDLCloseT	Vector3 <>		; Close target position (used when rushing, etc)
HDLCurSpeed	REAL4 0.0		; Current calculated speed
HDLMazeMap	BPPtr 0
HDLMirror	BPBool FALSE
HDLPos		Vector3 <>
HDLPosP		Vector3 <>
HDLRot		REAL4 0.0
HDLSndTimer	REAL4 0.0
HDLSpeed	REAL4 0.0		; Speed multiplier
HDLStack	BPPtr 0
HDLStackPtr	BPPtr 0
HDLState	SDWORD 0
HDLStep		BPBool FALSE	; Step leg alternation
HDLTarget	Vector3 <>		; Global final target position
HDLTimer	REAL4 0.0
HDLVisible	BPBool FALSE

.CODE
HDL_Alert PROC EXPORT PosPtr:BPPtr, Amplitude:REAL4
	LOCAL dist:REAL4, flVal:REAL4, v3Val:Vector3
	
	.IF !(HDL)
		ret
	.ENDIF
	
	mov dist, rv(Vector32DDistanceSqr, ADDR HDLPos, PosPtr)
	fld dist
	fmul f(0.01)
	fstp flVal
	fcmp Amplitude, flVal	; Amplitude > DistSqr*0.01
	; Sounds after 10 meteres of distance won't pass at Amplitude of 1
	.IF (!Carry?)
		fld Amplitude
		fsub flVal
		fmul f(2)
		fstp flVal
		invoke flRand
		fcmp eax, flVal	; Rand(0 -- 1) < (Amplitude - DistSqr*0.01)*2
		; A random chance to not hear sound, if far enough away.
		.IF (Carry?)
			; Random distant offset
			fld dist
			fmul f(0.01)
			fld Amplitude
			fmul st, st
			fdiv
			fst flVal
			fchs
			fstp v3Val.Y
			; Max distance of sqrt(100) (when Amp=1) will result in 1 meters
			; possible random offset.
			mov v3Val.X, rv(flRandRange, v3Val.Y, flVal)
			mov v3Val.Z, rv(flRandRange, v3Val.Y, flVal)
			invoke Vector32DAdd, ADDR v3Val, PosPtr
			
			; React according to distance
			fcmp dist, f(14)
			.IF (Carry?)
				invoke Vector32DCopy, ADDR HDLCloseT, ADDR v3Val
				fcmp dist, f(1)
				.IF (Carry?)
					mov HDL, HDL_ATTACK
				.ELSE
					mov HDL, HDL_SEARCH
				.ENDIF
			.ELSE
				vinvoke HDL_Solve, ADDR v3Val
			.ENDIF
			
			.IF (NetHosting)
				invoke Net_FormSend, NET_MAZE_ENTITIES, NetSock
			.ENDIF
			
			.IF (HDL == HDL_WANDER) && !(rv(nRand, 3))
				invoke SndSetPos, SndHDLAlarm, ADDR HDLPos
				invoke alSourcePlay, SndHDLAlarm
			.ENDIF
		.ENDIF
	.ENDIF
	ret
HDL_Alert ENDP

HDL_Solve PROC EXPORT PosPtr:BPPtr
	invoke Vector32DCopy, ADDR HDLTarget, PosPtr
	print "HDL solving to "
	Vector32DPrint HDLTarget
	invoke Vector2Set, ADDR HDLCellT, HDLTarget.X, HDLTarget.Z
	invoke fpuSetRounding, FPU_ROUND_TRUNC
	invoke Vector2RoundInt, ADDR HDLCellT
	invoke fpuSetRounding, FPU_ROUND_ROUND
	shr HDLCellT.X, 1
	shr HDLCellT.Y, 1
	print "From cell "
	print str$(HDLCell.X), 9
	print str$(HDLCell.Y), 9
	print "position "
	Vector32DPrint HDLPos
	
	mov HDL, HDL_RUSH
	
	invoke Vector32DCopy, ADDR HDLCloseT, ADDR HDLPos
	mov HDLStackPtr, SIZEOF BPPtr
	mov eax, MazeByteSize
	shl eax, 1
	invoke Maze_Solve, HDLStack, eax, HDLMazeMap, ADDR HDLCell, ADDR HDLCellT, 2
	.IF !(pax)
		mov HDL, HDL_WANDER
	.ENDIF
	ret
HDL_Solve ENDP

HDL_Spawn PROC EXPORT State:BPEnum
	mbm HDL, State
	.IF (State == HDL_NONE)
		.IF (HDLMazeMap)
			invoke bpFree, bpDefHeap, 0, HDLMazeMap
			mov HDLMazeMap, 0
		.ENDIF
		.IF (HDLStack)
			invoke HSFree, HDLStack
			mov HDLStack, 0
		.ENDIF
		
		invoke SndSetGain, SndWmblykB, f(1)
		invoke alSourcef, SndWmblykB, AL_PITCH, f(1)
		invoke alSourceStop, SndWmblykB
	.ELSE
		print "Spawned Huendul", 13, 10
		
		mov HDLAnimPlr.FrameType, BPA_FRAME_VERTEX
		mov HDLAnimPlr.Mesh, OFFSET MeshHDL
		mov HDLAnimPlr.MeshUseNormals, TRUE
		invoke bpAnimPlay, ADDR HDLAnimPlr, ADDR AnimHDLIdle
		
		mov eax, MazeByteSize
		shl eax, 1
		mov HDLStack, rv(HSCreate, eax)
		
		mov HDLMazeMap, rv(bpMalloc, bpDefHeap, HEAP_ZERO_MEMORY, MazeByteSize)
		
		invoke Maze_GetRandomPos, ADDR HDLPos, FALSE
		invoke SndSetGain, SndWmblykB, f(2)
		invoke alSourcef, SndWmblykB, AL_PITCH, f(0.5)
		invoke alSourcePlay, SndWmblykB
	.ENDIF
	ret
HDL_Spawn ENDP


HDL_Draw PROC EXPORT
	.IF (HDLVisible)
		call glPushMatrix
		invoke glTranslate3fv, ADDR HDLPos
		; facing back cuz i fuckin forgot to apply the 180 rotation
		invoke glRotatefr, HDLRot, 0, FLT_1, 0
		.IF (HDLMirror)
			invoke glCullFace, GL_FRONT
			mov eax, f(-0.9)
		.ELSE
			mov eax, f(0.9)
		.ENDIF
		invoke glScalef, eax, f(0.9), f(0.9)	; idiot
		invoke glBindTexture, GL_TEXTURE_2D, TexHDL
		invoke bpDrawMesh, ADDR MeshHDL
		.IF (HDLMirror)
			invoke glCullFace, GL_BACK
		.ENDIF
		call glPopMatrix
	.ENDIF
	
	IFDEF DEBUG_BULLSHIT
	invoke glPushAttrib, GL_ENABLE_BIT
	invoke glDisable, GL_FOG
	invoke glDisable, GL_LIGHTING
	invoke glDisable, GL_TEXTURE_2D
	invoke glBegin, GL_LINES
	invoke glColor3fv, ADDR clGreen
	invoke glVertex3fv, ADDR HDLCloseT
	invoke glVertex3f, HDLCloseT.X, FLT_1, HDLCloseT.Z
	invoke glColor3fv, ADDR clRed
	invoke glVertex3fv, ADDR HDLTarget
	invoke glVertex3f, HDLTarget.X, FLT_1, HDLTarget.Z
	invoke glEnd
	invoke glPopAttrib
	invoke glColor3fv, ADDR clWhite
	ENDIF
	ret
HDL_Draw ENDP

HDL_Process PROC EXPORT
	LOCAL v3Val:Vector3
	
	HDL_Arrive MACRO
		.IF (rv(nRand, 3))
			mov HDL, HDL_SEARCH
		.ELSE
			mov HDL, HDL_ATTACK
		.ENDIF
		invoke Vector32DCopy, ADDR HDLCloseT, ADDR HDLTarget
		print "HDL arrived to pos", 13, 10
		ret
	ENDM
	
	.IF (rv(Plr_Cull, OFFSET HDLPos))
		mov HDLVisible, FALSE
	.ELSE
		mov HDLVisible, TRUE
	.ENDIF
	
	invoke Vector2Set, ADDR HDLCell, HDLPos.X, HDLPos.Z
	invoke fpuSetRounding, FPU_ROUND_TRUNC
	invoke Vector2RoundInt, ADDR HDLCell
	invoke fpuSetRounding, FPU_ROUND_ROUND
	shr HDLCell.X, 1
	shr HDLCell.Y, 1
	Maze_ClampXYI HDLCell.X, HDLCell.Y
	
	;print str$(HDLState), 9
	;print ubyte$(HDL), 13, 10
	
	fld HDLTimer
	fsub deltaTime
	fstp HDLTimer
	.IF (HDLTimer & FLT_NEG)
		.IF (HDL == HDL_WANDER)
			dec HDLState
			
			.IF (HDLState > 0)
				; Twitching (stationary)
				.IF !(HDLAnimPlr.TrackPtr) && (rv(nRand, 2))
					invoke bpAnimPlay, ADDR HDLAnimPlr, ADDR AnimHDLIdle
				.ENDIF
				mov HDLTimer, rv(flRand)
			.ELSE
				; Moving
				.IF (rv(nRand, 8))	; Random close
					invoke Vector32DCopy, ADDR HDLCloseT, ADDR HDLPos
					mov v3Val.X, rv(flRandRange, f(-3), f(3))
					mov v3Val.Z, rv(flRandRange, f(-3), f(3))
					invoke Vector32DAdd, ADDR HDLCloseT, ADDR v3Val
					
					mov HDLTimer, rv(flRandRange, f(0.5), f(6))
					
					mov HDLState, rv(intRandRange, 1, 5)
				.ELSE				; Solving to location
					fild MazeSize[0]
					fmul f(2)
					fsub f(1)
					fstp v3Val.X
					fild MazeSize[4]
					fmul f(2)
					fsub f(1)
					fstp v3Val.Z
					mov v3Val.X, rv(flRandRange, FLT_1, v3Val.X)
					mov v3Val.Z, rv(flRandRange, FLT_1, v3Val.Z)
					invoke HDL_Solve, ADDR v3Val
				.ENDIF
			.ENDIF
		.ELSEIF (HDL == HDL_SEARCH)
			mov v3Val.X, rv(flRandRange, f(-0.5), f(0.5))
			mov v3Val.Z, rv(flRandRange, f(-0.5), f(0.5))
			invoke Vector32DAdd, ADDR HDLCloseT, ADDR v3Val
			
			dec HDLState
			.IF (HDLState > 0)
				mov HDLTimer, rv(flRandRange, f(0.1), f(0.5))
			.ELSE
				mov HDL, HDL_WANDER
			.ENDIF
		.ENDIF
	.ENDIF
	
	.IF (HDL == HDL_WANDER)
		fld HDLSndTimer
		fsub deltaTime
		fstp HDLSndTimer
		
		.IF (HDLSndTimer & FLT_NEG)
			mov HDLSndTimer, rv(flRandRange, f(1), f(6))
			invoke PlayRandomSnd, ADDR SndHDLIdle, SIZEOF SndHDLIdle/4
			invoke SndSetPos, DWORD PTR [pax], ADDR HDLPos
		.ENDIF
	.ELSEIF (HDL == HDL_RUSH)	
		mov eax, HDLCellT.X
		mov ecx, HDLCellT.Y
		.IF (HDLCell.X == eax) && (HDLCell.Y == ecx)
			mov v3Val.X, 1
			invoke Vector32DCopy, ADDR HDLCloseT, ADDR HDLTarget
		.ELSE
			mov v3Val.X, 0
		.ENDIF
		
		mov v3Val.Y, rv(Vector32DDistanceSqr, OFFSET HDLPos, OFFSET HDLCloseT)
		fcmp v3Val.Y, f(0.2)
		.IF (Carry?)
			; Reverse stack combing
			mov pax, HDLStack
			mov pcx, HDLStackPtr
			.IF !(v3Val.X) && (pcx < BPPtr PTR [pax])
				mov pax, HDLStack
				add pax, HDLStackPtr
				bpMPM HDLCellNext.X, BPPtr PTR [pax]
				bpMPM HDLCellNext.Y, BPPtr PTR [pax+SIZEOF BPPtr]
				bpMEM32 HDLCloseT.X, HDLCellNext.X
				shl HDLCloseT.X, 1
				inc HDLCloseT.X
				bpMEM32 HDLCloseT.Z, HDLCellNext.Y
				shl HDLCloseT.Z, 1
				inc HDLCloseT.Z
				invoke Vector32DF, ADDR HDLCloseT
				add HDLStackPtr, SIZEOF BPPtr*2
				print "Moving to "
				Vector32DPrint HDLCloseT
			.ELSE
				HDL_Arrive
			.ENDIF
		.ENDIF
	.ELSEIF (HDL == HDL_ATTACK)
		.IF (NetHosting)
			invoke Net_FormSend, NET_MAZE_ENTITIES, NetSock
		.ENDIF
		mov HDLSpeed, 0
		mov HDL, HDL_ATTACKING
		invoke SndSetPos, SndHDLAttack, ADDR HDLPos
		invoke alSourcePlay, SndHDLAttack
		invoke bpAnimPlay, ADDR HDLAnimPlr, ADDR AnimHDLAttack
	.ELSEIF (HDL == HDL_ATTACKING)
		.IF !(HDLAnimPlr.TrackPtr)
			mov HDL, HDL_SEARCH
			mov HDLState, rv(intRandRange, 6, 16)
		.ENDIF
	.ENDIF
	
	; Calculate current speed, rotate, move if not attacking
	.IF (HDL == HDL_ATTACKING)
		mov v3Val.Y, rv(Vector32DAngle, OFFSET HDLCloseT, OFFSET HDLPos)
		bpMEM32 v3Val.X, delta2
	.ELSE
		; Move and collide
		mov v3Val.Y, rv(Vector32DDistance, OFFSET HDLPos, OFFSET HDLTarget)
		fcmp v3Val.Y, f(0.05)
		.IF (Carry?)
			mov HDLSpeed, 0
		.ELSE
			fld v3Val.Y
			.IF (HDL == HDL_SEARCH) || (HDL == HDL_RUSH)
				fmul f(0.4)
				fadd f(1.8)
			.ELSE
				fmul f(0.6)
			.ENDIF
			fstp v3Val.Y
			mov HDLSpeed, rv(flLerp, HDLSpeed, v3Val.Y, deltaTime)
			fld HDLSpeed
			fmul deltaTime
			fstp v3Val.Y
			invoke Vector32DMoveEach, ADDR HDLPos, ADDR HDLCloseT, v3Val.Y
		.ENDIF
		
		; Collide
		.IF (HDL == HDL_SEARCH) || (HDL == HDL_WANDER)
			; Kubale
			.IF (Kubale == KUBALE_ACTIVE)
				vinvoke Collide_Distance, OFFSET HDLPos, \
				OFFSET KubalePos, f(1), 0
			.ENDIF
		
			; World collison
			invoke Maze_CollideLayout, ADDR HDLPos, f(0.7), TRUE
			
			; Wmblyk
			.IF (Wmblyk == WMBLYK_STILL)
				vinvoke Collide_Distance, OFFSET HDLPos, \
				OFFSET WmblykPos, f(0.8), 0
			.ENDIF
		.ENDIF
		
		mov v3Val.Y, rv(Vector32DAngle, OFFSET HDLPos, OFFSET HDLPosP)
		mov v3Val.X, rv(Vector32DDistance, OFFSET HDLPosP, OFFSET HDLPos)
		fld v3Val.X
		fld st
		fdiv deltaTime
		fstp HDLCurSpeed
		fmul f(2)
		fstp v3Val.X
	.ENDIF
	mov HDLRot, rv(flLerpAngle, HDLRot, v3Val.Y, v3Val.X)
	
	; Player collision
	.IF (PlrState == PLAYER_STATE_GAME)
		invoke Collide_Distance, ADDR CamPos, ADDR HDLPos, f(0.3), 0
		.IF (al)
			.IF ((HDL != HDL_ATTACKING) && \
			((InputMovement.X) || (InputMovement.Y))) || (HDL == HDL_SEARCH)
				fld HDLAttackTimer
				fsub deltaTime
				fstp HDLAttackTimer
				
				.IF (HDLAttackTimer & FLT_NEG)
					invoke Vector32DCopy, ADDR HDLCloseT, ADDR CamPos
					mov HDL, HDL_ATTACK
					invoke Net_FormSend, NET_MAZE_ENTITIES, NetSock
					
					mov HDLAttackTimer, rv(flRandRange, f(0.2), f(0.6))
				.ENDIF
			.ENDIF
		.ENDIF
	.ENDIF
	
	; Scare Virdya
	.IF (Virdya)
		vinvoke Virdya_Scare, OFFSET HDLPos, TRUE
	.ENDIF
	
	; Walk animation
	.IF (HDL == HDL_ATTACKING)
		mov HDLAnimPlr.Speed, FLT_1
	.ELSE
		fcmp HDLCurSpeed, f(0.1)
		.IF (!Carry?)
			.IF (HDLAnimPlr.TrackPtr != OFFSET AnimHDLWalk)
				invoke bpAnimPlay, ADDR HDLAnimPlr, ADDR AnimHDLWalk
			.ENDIF
			bpMEM32 HDLAnimPlr.Speed, HDLCurSpeed
		.ELSEIF (HDLAnimPlr.TrackPtr == OFFSET AnimHDLWalk)
			invoke bpAnimPlay, ADDR HDLAnimPlr, ADDR AnimHDLIdle
			mov HDLAnimPlr.Speed, FLT_1
			.IF (rv(nRand, 2))
				not HDLMirror
			.ENDIF
		.ENDIF
	.ENDIF
	
	invoke Vector32DCopy, ADDR HDLPosP, ADDR HDLPos
	
	invoke SndSetPos, SndWmblykB, ADDR HDLPos
	invoke bpProcessAnimPlayer, ADDR HDLAnimPlr, deltaTime
	.IF (pax) 	; Frame changed
		; I hope you like indentations
		.IF (HDLAnimPlr.TrackPtr == OFFSET AnimHDLWalk)	
			xor cl, cl
			fcmp HDLAnimPlr.Timer, f(22)
			.IF (!Carry?)
				.IF (HDLStep)
					mov cl, 1
					mov HDLStep, FALSE
				.ENDIF
			.ELSE
				fcmp HDLAnimPlr.Timer, f(8)
				.IF (!Carry?)
					.IF !(HDLStep)
						mov cl, 1
						mov HDLStep, TRUE
					.ENDIF			
				.ENDIF			
			.ENDIF
			.IF (cl)
				invoke PlayRandomSnd, ADDR SndHDLStep, SIZEOF SndHDLStep/4
				push pax
				invoke SndSetPos, DWORD PTR [pax], ADDR HDLPos
				invoke flRandRange, f(0.9), f(1.1)
				pop pcx
				invoke alSourcef, DWORD PTR [pcx], AL_PITCH, eax
			.ENDIF
		.ELSEIF (HDLAnimPlr.TrackPtr == OFFSET AnimHDLAttack) && \
		(PlrState == PLAYER_STATE_GAME)
			fcmp HDLAnimPlr.Timer, f(4)
			.IF (!Carry?)
				fcmp HDLAnimPlr.Timer, f(6)
				.IF (Carry?)
					; Check if player in range
					mov v3Val.Y, \
					rv(Vector32DDistanceSqr, OFFSET HDLPos, OFFSET CamPos)
					fcmp v3Val.Y, f(1)
					.IF (Carry?)
						invoke Vector32DCopy, ADDR v3Val, ADDR CamPos
						invoke Vector32DSub, ADDR v3Val, ADDR HDLPos
						invoke Vector32DNormalize, ADDR v3Val
						fld HDLRot
						fsincos
						fmul v3Val.Z
						fxch
						fmul v3Val.X
						fadd
						fstp v3Val.Y
						; This is inverted dot cuz HDL is rotated 180 idk why
						fcmp v3Val.Y, f(-0.5)
						.IF (Carry?)
							.IF !(rv(Maze_Raycast, OFFSET HDLPos, OFFSET CamPos, TRUE))
								bpMPM UIDeadTipStr, StrTipHDL
								invoke SndSetPos, SndHurt, ADDR HDLPos
								invoke alSourcePlay, SndHurt
								
								bpMEM32 NetSound, SndHurt
								invoke Vector32DCopy,ADDR NetSoundPos,ADDR CamPos
								invoke Net_FormSend, NET_SOUND, NetSock
								
								;mov PlrState, PLAYER_STATE_DYING
								fld PlrHealth
								fsub f(0.8)
								fstp PlrHealth
								
								fld PlrHeal
								fmul f(0.4)
								fstp PlrHeal
							.ENDIF
						.ENDIF
					.ENDIF
				.ENDIF
			.ENDIF
		.ENDIF
	.ENDIF
	ret
HDL_Process ENDP
