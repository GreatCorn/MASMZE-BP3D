ENUM	SHILBRIK_NONE, \
		SHILBRIK_PASSIVE, \
		SHILBRIK_HIDE, \
		SHILBRIK_WARN, \
		SHILBRIK_ATTACK, \
		SHILBRIK_JUMP

SHILBRIK_STACK_COUNT	EQU 36

.DATA

Shilbrik			BPEnum SHILBRIK_NONE
ShilbrikAnimPlr		BPAnimPlayer <>
ShilbrikBlinkTimer	REAL4 0.0, 0.2, 2.0	; Timer, min, max
ShilbrikBlinkTex	DWORD 0
ShilbrikCooldown	REAL4 0.0
ShilbrikCell		Vector2 <>
ShilbrikCellT		Vector2 <>
ShilbrikLookTimer	REAL4 0.0
ShilbrikPatience	REAL4 6.0, 7.0	; Patience, max
ShilbrikPos			Vector3 <>
ShilbrikPosP		Vector3 <>
ShilbrikPosL		Vector3 <>
ShilbrikRot			REAL4 0.0, 0.0	; Real, displayed (lerped)
ShilbrikTarget		Vector3 <>
ShilbrikTPlrPos		BPPtr 0
ShilbrikSpeed		REAL4 0.0
ShilbrikStep		BPBool FALSE

ShilbrikMazeMap		BPPtr 0
ShilbrikMazeMapT	BPPtr 0	; UNUSED
ShilbrikStack		BPPtr 0
ShilbrikStackT		BPPtr 0
ShilbrikStackPtr	BPPtr 0

.CODE

Shilbrik_Hide PROC EXPORT
	LOCAL minRoute:BPPtr, bounds:Vector2, pos:Vector3
	
	print "Shilbrik hiding from "
	print str$(ShilbrikCell.X), 9
	print str$(ShilbrikCell.Y), 13, 10
	
	mov minRoute, 65535
	
	push pbx
	mov pbx, ShilbrikCell.X
	mov bounds.X, pbx
	sub pbx, 2
	add bounds.X, 2
	.WHILE (SDWORD PTR pbx <= SDWORD PTR bounds.X)
		mov pcx, ShilbrikCell.Y
		mov bounds.Y, pcx
		sub pcx, 2
		add bounds.Y, 2
		.WHILE (SDWORD PTR pcx <= SDWORD PTR bounds.Y)
			push pcx
			print "Testing position "
			print str$(pbx), 9
			pop pcx
			push pcx
			print str$(pcx), 13, 10
			pop pcx
			
			.IF (pbx == ShilbrikCell.X) && (pcx == ShilbrikCell.Y)
				inc pcx
				.CONTINUE
			.ENDIF
			
			.IF (rv(intInRange, pbx, 0, MazeSize[8]))
				.IF (rv(intInRange, pcx, 0, MazeSize[12]))
					invoke Vector32DSet, ADDR pos, pbx, pcx
					shl pos.X, 1
					inc pos.X
					shl pos.Z, 1
					inc pos.Z
					invoke Vector32DF, ADDR pos
					
					push pcx
					xor pax, pax
					.IF (NetSock)
						push pbx
						xor pbx, pbx
						.WHILE (pbx < SIZEOF NetPlayers)
							.IF (NetPlayers[pbx].PlayerID != -1) \
							&& (NetPlayersVL[pbx].Visible & NET_VISIBLE_GLOBAL)
								invoke Maze_Raycast, \
								ADDR NetPlayersV[pbx].Position, ADDR pos, FALSE
								.IF !(pax)
									.BREAK
								.ENDIF
							.ENDIF
							add pbx, SIZEOF NetPlayerLocal
						.ENDW
						pop pbx
					.ELSE
						invoke Maze_Raycast, ADDR CamPos, ADDR pos, FALSE
					.ENDIF
					.IF (pax)
						; Found blocked position, solve to it
						print "Found blocked position at "
						Vector32DPrint pos
						pop pcx
						invoke Vector2Set, ADDR pos, pbx, pcx
						push pcx
						invoke Maze_Solve, ShilbrikStack, SHILBRIK_STACK_COUNT,\
						ShilbrikMazeMap, ADDR ShilbrikCell, ADDR pos, 2
						mov pax, ShilbrikStack
						mov pax, BPPtr PTR [pax]
						.IF (pax < minRoute)
							mov minRoute, pax
							print "Found min route of "
							print str$(minRoute), 9
							mov pax, ShilbrikStack
							print str$(BPPtr PTR [pax]), 9
							invoke RtlMoveMemory, ShilbrikStackT, \
							ShilbrikStack, (SHILBRIK_STACK_COUNT+1) shl BPPtrShift
							mov pax, ShilbrikStackT
							print str$(BPPtr PTR [pax]), 13, 10
							invoke Vector2Copy, ADDR ShilbrikCellT, ADDR pos
						.ENDIF
					.ENDIF
					pop pcx
				.ENDIF
			.ENDIF
			inc pcx
		.ENDW
		inc pbx
	.ENDW
	pop pbx
	
	.IF (minRoute == 65535)
		print "No hiding spot found", 13, 10
		
		bpMEM32 ShilbrikLookTimer, f(0.5)
	.ELSE
		mov Shilbrik, SHILBRIK_HIDE
		mov ShilbrikStackPtr, SIZEOF BPPtr
		invoke Vector32DCopy, ADDR ShilbrikTarget, ADDR ShilbrikPos
		print "Hiding to ",
		print str$(ShilbrikCellT.X), 9
		print str$(ShilbrikCellT.Y), 13, 10
		
		mov pax, ShilbrikStackT
		mov pcx, 0
		pushad
		print str$(BPPtr PTR [pax]), 9
		popad
		.WHILE (pcx < BPPtr PTR [pax])
			pushad
			print str$(BPPtr PTR [pax+pcx]), 13, 10
			popad
			add pcx, SIZEOF BPPtr
		.ENDW
		
		.IF !(rv(nRand, 3))
			invoke PlayRandomSnd, ADDR SndShilbrikHide, SIZEOF SndShilbrikHide/4
			push pax
			invoke flRandRange, f(0.9), f(1.1)
			pop pcx
			invoke alSourcef, DWORD PTR [pcx], AL_PITCH, eax
		.ENDIF
	.ENDIF
	ret
Shilbrik_Hide ENDP

Shilbrik_Spawn PROC EXPORT State:BPEnum
	.IF (State == SHILBRIK_NONE)
		.IF (ShilbrikMazeMap)
			invoke bpFree, bpDefHeap, 0, ShilbrikMazeMap
			invoke bpFree, bpDefHeap, 0, ShilbrikMazeMapT
			mov ShilbrikMazeMap, 0
			mov ShilbrikMazeMapT, 0
		.ENDIF
		.IF (ShilbrikStack)
			invoke HSFree, ShilbrikStack
			invoke HSFree, ShilbrikStackT
			mov ShilbrikStack, 0
			mov ShilbrikStackT, 0
		.ENDIF
	.ELSE
		mov ShilbrikStack, rv(HSCreate, SHILBRIK_STACK_COUNT)
		mov ShilbrikStackT, rv(HSCreate, SHILBRIK_STACK_COUNT)
		
		;mov pax, SHILBRIK_STACK_COUNT
		;inc pax
		;shl pax, BPPtrShift
		;print str$(pax), " STACK SIZE", 13, 10
		
		mov ShilbrikMazeMap, \
		rv(bpMalloc, bpDefHeap, HEAP_ZERO_MEMORY, MazeByteSize)
		mov ShilbrikMazeMapT, \
		rv(bpMalloc, bpDefHeap, HEAP_ZERO_MEMORY, MazeByteSize)
		
		bpMEM32 ShilbrikBlinkTex, TexShilbrikBlink[0]
		
		bpMEM32 ShilbrikPatience, ShilbrikPatience[4]
	
		mov ShilbrikAnimPlr.FrameType, BPA_FRAME_VERTEX	; Init animator
		mov ShilbrikAnimPlr.Mesh, OFFSET MeshShilbrik
		mov ShilbrikAnimPlr.MeshUseNormals, TRUE
		invoke bpAnimPlay, ADDR ShilbrikAnimPlr, ADDR AnimShilbrikIdle
		invoke Maze_GetRandomPos, ADDR ShilbrikPos, FALSE
		invoke Vector32DCopy, ADDR ShilbrikPosL, ADDR ShilbrikPos
		invoke Vector32DCopy, ADDR ShilbrikPosP, ADDR ShilbrikPos
		print "Spawned Shilbrik at "
		Vector32DPrint ShilbrikPos
	.ENDIF
	mbm Shilbrik, State
	ret
Shilbrik_Spawn ENDP

Shilbrik_StackMove PROC EXPORT
	LOCAL flVal:REAL4
	
	mov flVal, \
	rv(Vector32DDistanceSqr, OFFSET ShilbrikPos, OFFSET ShilbrikTarget)
	fcmp flVal, f(0.2)
	.IF (Carry?)
		mov eax, ShilbrikCell.X
		mov ecx, ShilbrikCell.Y
		.IF (eax == ShilbrikCellT.X) && (ecx == ShilbrikCellT.Y)
			; Arrived
			mov pax, TRUE
			ret
		.ELSEIF !(NetSock) || (NetHosting)
			; Reverse stack combing
			mov pax, ShilbrikStackT
			mov pcx, ShilbrikStackPtr
			.IF (pcx < BPPtr PTR [pax])
				mov pax, ShilbrikStackT
				add pax, ShilbrikStackPtr
				mov ecx, BPPtr PTR [pax]
				shl ecx, 1
				inc ecx
				mov ShilbrikTarget.X, ecx
				mov ecx, BPPtr PTR [pax+SIZEOF BPPtr]
				shl ecx, 1
				inc ecx
				mov ShilbrikTarget.Z, ecx
				invoke Vector32DF, ADDR ShilbrikTarget
				add ShilbrikStackPtr, SIZEOF BPPtr*2
				
				print "Moving to "
				Vector32DPrint ShilbrikTarget
			.ENDIF
		.ENDIF
	.ENDIF
	xor pax, pax
	ret
Shilbrik_StackMove ENDP


Shilbrik_Draw PROC EXPORT
	call glPushMatrix
	.IF (ShilbrikBlinkTimer & FLT_NEG)
		invoke glBindTexture, GL_TEXTURE_2D, ShilbrikBlinkTex
	.ELSE
		invoke glBindTexture, GL_TEXTURE_2D, TexShilbrik
	.ENDIF
	invoke glTranslate3fv, ADDR ShilbrikPosL
	invoke glRotatefr, ShilbrikRot[4], 0, FLT_1, 0
	invoke bpDrawMesh, ADDR MeshShilbrik
	call glPopMatrix
	
	IFDEF DEBUG_BULLSHIT
	invoke glPushAttrib, GL_ENABLE_BIT
	invoke glDisable, GL_FOG
	invoke glDisable, GL_LIGHTING
	invoke glDisable, GL_TEXTURE_2D
	invoke glColor3fv, ADDR clGreen
	invoke glBegin, GL_LINES
	invoke glVertex3fv, ADDR ShilbrikTarget
	invoke glVertex3f, ShilbrikTarget.X, FLT_1, ShilbrikTarget.Z
	invoke glEnd
	invoke glPopAttrib
	invoke glColor3fv, ADDR clWhite
	ENDIF
	ret
Shilbrik_Draw ENDP

Shilbrik_Process PROC EXPORT
	LOCAL flVal:REAL4, visible:BPBool, v3Val:Vector3
	
	.IF (Shilbrik == SHILBRIK_WARN) && \
	(ShilbrikAnimPlr.TrackPtr != OFFSET AnimShilbrikWarn)
		mov ShilbrikLookTimer, FLT_NEG
		invoke bpAnimPlay, ADDR ShilbrikAnimPlr, ADDR AnimShilbrikWarn
		invoke SndSetPos, SndShilbrikWarn, ADDR ShilbrikPosL
		invoke alSourcePlay, SndShilbrikWarn
	.ELSEIF (Shilbrik == SHILBRIK_JUMP) && \
	(ShilbrikAnimPlr.TrackPtr != OFFSET AnimShilbrikJump)
		invoke bpAnimPlay, ADDR ShilbrikAnimPlr, ADDR AnimShilbrikJump
		invoke SndSetPos, SndShilbrikJump, ADDR ShilbrikPosL
		invoke alSourcePlay, SndShilbrikJump
		
		fld ShilbrikPatience
		fmul f(0.5)
		fstp ShilbrikPatience
	.ENDIF
	invoke bpProcessAnimPlayer, ADDR ShilbrikAnimPlr, deltaTime
	
	.IF (pax)
		; Attack player, walk
		.IF (PlrState == PLAYER_STATE_GAME) && \
		(ShilbrikAnimPlr.TrackPtr == OFFSET AnimShilbrikJump)
			.IF (rv(flInRange, ShilbrikAnimPlr.Timer, f(7), f(15)))
				mov flVal, \
				rv(Vector32DDistance, OFFSET ShilbrikPos, OFFSET CamPos)
				fcmp flVal, f(1)
				.IF (Carry?)
					invoke Maze_GetRandomPos, ADDR v3Val, FALSE
					invoke Plr_Teleport, v3Val.X, v3Val.Z
					mov CamRot.Y, rv(flRandRange, PIN, PI)
					bpMEM32 CamRotL.Y, CamRot.Y
					
					mov UIFade, UI_FADE_IN
					mov UIFadeVal, FLT_1
					mov UIFadeDisp, FLT_1
					
					bpMPM UIDeadTipStr, StrTipShilbrik
					
					fld PlrHealth
					fsub f(0.6)
					fstp PlrHealth
					mov PlrHeal, 0
					
					;mov PlrGlyphsInMaze, 0
					;invoke Net_FormSend, NET_MAZE_ELEMENTS, NetSock
					
					invoke SndSetPos, SndHurt, ADDR CamPos
					invoke alSourcePlay, SndHurt
					bpMEM32 NetSound, SndHurt
					invoke Vector32DCopy, ADDR NetSoundPos, ADDR CamPos
					invoke Net_FormSend, NET_SOUND, NetSock
				.ENDIF
			.ENDIF
		.ELSEIF ((ShilbrikAnimPlr.TrackPtr == OFFSET AnimShilbrikBack) || \
		(ShilbrikAnimPlr.TrackPtr == OFFSET AnimShilbrikLeft) || \
		(ShilbrikAnimPlr.TrackPtr == OFFSET AnimShilbrikRight) || \
		(ShilbrikAnimPlr.TrackPtr == OFFSET AnimShilbrikRun))
			xor cl, cl
			.IF (ShilbrikStep)
				fcmp ShilbrikAnimPlr.Timer, f(6)
				.IF (!Carry?)
					mov cl, TRUE
					mov ShilbrikStep, FALSE
				.ENDIF
			.ELSE
				fcmp ShilbrikAnimPlr.Timer, f(6)
				.IF (Carry?)
					mov cl, TRUE
					mov ShilbrikStep, TRUE
				.ENDIF
			.ENDIF
			.IF (cl)
				fld ShilbrikSpeed
				fmul f(0.15)
				fstp flVal
				invoke alSourcef, SndShilbrikStep, AL_PITCH, \
				rv(flRandRange, f(0.9), f(1.1))
				invoke SndSetPos, SndShilbrikStep, ADDR ShilbrikPosL
				invoke SndSetGain, ADDR SndShilbrikStep, flVal
				invoke alSourcePlay, SndShilbrikStep
			.ENDIF
		.ENDIF
	.ENDIF
	
	invoke Vector2Set, ADDR ShilbrikCell, ShilbrikPos.X, ShilbrikPos.Z
	invoke fpuSetRounding, FPU_ROUND_TRUNC
	invoke Vector2RoundInt, ADDR ShilbrikCell
	invoke fpuSetRounding, FPU_ROUND_ROUND
	shr ShilbrikCell.X, 1
	shr ShilbrikCell.Y, 1
	
	.IF (Shilbrik != SHILBRIK_ATTACK)
		mov ShilbrikTPlrPos, rv(GetPlrNearPos, OFFSET ShilbrikPos)
	.ENDIF
	
	; Visibility detection
	mov visible, TRUE
	;mov flVal, rv(Vector32DDistanceSqr, ShilbrikTPlrPos, OFFSET ShilbrikPos)
	;fcmp flVal, f(8)
	;.IF (!Carry?)
	;	.IF !(rv(flInRange, CamRot.X, f(-0.9), f(0.9)))
	;		mov visible, FALSE
	;	.ENDIF
	;.ENDIF
	.IF (visible)
		.IF (rv(Maze_PlrVisibleGlobal, OFFSET ShilbrikPos, f(1)))
			mov visible, TRUE
		.ELSE
			mov visible, FALSE
		.ENDIF
	.ENDIF
	
	;print ubyte$(visible), 9
	;print real4$(ShilbrikLookTimer), 9
	;print real4$(ShilbrikPatience), 13, 10
	
	.IF (Shilbrik == SHILBRIK_PASSIVE)		
		.IF (visible)
			fld ShilbrikLookTimer
			fsub deltaTime
			fstp ShilbrikLookTimer
			.IF (ShilbrikLookTimer & FLT_NEG)
				call Shilbrik_Hide
			.ENDIF
		.ELSE
			bpMEM32 ShilbrikLookTimer, f(0.5)
		.ENDIF
		
		invoke Vector32DCopy, ADDR ShilbrikTarget, ADDR ShilbrikPos
	.ELSEIF (Shilbrik == SHILBRIK_HIDE)	
		.IF (rv(Shilbrik_StackMove))
			mov Shilbrik, SHILBRIK_PASSIVE
		.ENDIF
	.ELSEIF (Shilbrik == SHILBRIK_WARN)
		invoke Vector32DCopy, ADDR ShilbrikTarget, ADDR ShilbrikPos
		.IF !(ShilbrikAnimPlr.TrackPtr)
			.IF (ShilbrikPatience & FLT_NEG)
				mov Shilbrik, SHILBRIK_ATTACK
				mov ShilbrikLookTimer, FLT_NEG
				
				bpMEM32 ShilbrikPatience, f(-8.0)
			.ELSE
				mov Shilbrik, SHILBRIK_PASSIVE
			.ENDIF
		.ENDIF
	.ELSEIF (Shilbrik == SHILBRIK_ATTACK)
		.IF (rv(Maze_Raycast, OFFSET ShilbrikPos, ShilbrikTPlrPos, TRUE))
			fld ShilbrikLookTimer
			fsub deltaTime
			fstp ShilbrikLookTimer
			
			.IF (ShilbrikLookTimer & FLT_NEG)
				mov pax, ShilbrikTPlrPos
				invoke Vector2Set, ADDR ShilbrikTarget, REAL4 PTR [pax], \
				REAL4 PTR [pax+8]
				invoke Vector2MulF, ADDR ShilbrikTarget, f(0.5)
				invoke fpuSetRounding, FPU_ROUND_TRUNC
				invoke Vector2RoundInt, ADDR ShilbrikTarget
				invoke fpuSetRounding, FPU_ROUND_ROUND
				invoke Maze_Solve, ShilbrikStackT, SHILBRIK_STACK_COUNT,\
				ShilbrikMazeMap, ADDR ShilbrikCell, ADDR ShilbrikTarget, 2
				mov ShilbrikStackPtr, SIZEOF BPPtr
				invoke Vector32DCopy, ADDR ShilbrikTarget, ADDR ShilbrikPos
				
				mov ShilbrikLookTimer, FLT_1
			.ENDIF
			
			.IF (rv(Shilbrik_StackMove))
				invoke Vector32DCopy, ADDR ShilbrikTarget, ShilbrikTPlrPos
			.ENDIF
		.ELSE
			invoke Vector32DCopy, ADDR ShilbrikTarget, ShilbrikTPlrPos
		.ENDIF
		
		mov flVal, rv(Vector32DDistanceSqr, OFFSET ShilbrikPos, ShilbrikTPlrPos)
		fcmp flVal, f(3)
		.IF (Carry?)
			.IF !(rv(Maze_Raycast, OFFSET ShilbrikPos, ShilbrikTPlrPos, TRUE))
				mov Shilbrik, SHILBRIK_JUMP
			.ENDIF
		.ENDIF
		
		.IF !(ShilbrikPatience & FLT_NEG)
			mov Shilbrik, SHILBRIK_PASSIVE
			fld ShilbrikPatience[4]
			fmul f(0.5)
			fstp ShilbrikPatience
		.ENDIF
	.ELSEIF (Shilbrik == SHILBRIK_JUMP)
		.IF !(ShilbrikAnimPlr.TrackPtr)
			mov Shilbrik, SHILBRIK_ATTACK
			mov ShilbrikLookTimer, FLT_NEG
		.ENDIF
	.ENDIF
	
	.IF (visible)
		fld ShilbrikPatience
		fsub delta2
		fstp ShilbrikPatience
		
		.IF ((Shilbrik == SHILBRIK_PASSIVE) || (Shilbrik == SHILBRIK_HIDE)) && \
		(ShilbrikPatience & FLT_NEG)
			mov Shilbrik, SHILBRIK_WARN
		.ENDIF
	.ELSE
		fcmp ShilbrikPatience, ShilbrikPatience[4]
		.IF (Carry?)
			fld ShilbrikPatience
			fadd deltaTime
			fstp ShilbrikPatience
		.ELSE
			bpMEM32 ShilbrikPatience, ShilbrikPatience[4]
		.ENDIF
	.ENDIF
	
	.IF (ShilbrikCooldown)
		fld ShilbrikCooldown
		fsub deltaTime
		fstp ShilbrikCooldown
		.IF (ShilbrikCooldown & FLT_NEG)
			mov ShilbrikCooldown, 0
		.ENDIF
	.ENDIF
	
	; Rotate
	.IF (Shilbrik != SHILBRIK_WARN) && (Shilbrik != SHILBRIK_JUMP)
		mov ShilbrikRot, rv(Vector32DAngle, OFFSET ShilbrikPos, ShilbrikTPlrPos)
	.ENDIF
	
	; Move
	.IF (Shilbrik == SHILBRIK_ATTACK)
		fld f(6.5)
	.ELSE
		fld f(5)
	.ENDIF
	fmul deltaTime
	fstp flVal
	invoke Vector32DMoveEach, ADDR ShilbrikPos, ADDR ShilbrikTarget, flVal
	.IF (Shilbrik == SHILBRIK_ATTACK) || (Shilbrik == SHILBRIK_JUMP)
		mov al, FALSE
	.ELSE
		mov al, TRUE
	.ENDIF
	invoke Maze_CollideLayout, ADDR ShilbrikPos, f(0.85), al
	invoke Vector32DCopy, ADDR ShilbrikPosP, ADDR ShilbrikPosL
	invoke Vector32DLerp, ADDR ShilbrikPosL, ADDR ShilbrikPos, delta10
	
	invoke SndSetPos, SndShilbrikHide[0], ADDR ShilbrikPosL
	invoke SndSetPos, SndShilbrikHide[4], ADDR ShilbrikPosL
	invoke SndSetPos, SndShilbrikJump, ADDR ShilbrikPosL
	
	mov flVal, rv(Vector32DDistance,OFFSET ShilbrikPosL,OFFSET ShilbrikPosP)
	fld flVal
	fdiv deltaTime
	fmul f(0.3)
	fstp ShilbrikSpeed
	
	.IF (Shilbrik != SHILBRIK_WARN) && (Shilbrik != SHILBRIK_JUMP)
		; Blink
		fld ShilbrikBlinkTimer
		fsub deltaTime
		fstp ShilbrikBlinkTimer
		
		fcmp ShilbrikBlinkTimer, f(-0.1)
		.IF (Carry?)
			mov ShilbrikBlinkTimer, \
			rv(flRandRange, ShilbrikBlinkTimer[0], ShilbrikBlinkTimer[4])
			mov eax, ShilbrikBlinkTex
			.IF (eax == TexShilbrikBlink[0])
				bpMEM32 ShilbrikBlinkTex, TexShilbrikBlink[4]
			.ELSE
				bpMEM32 ShilbrikBlinkTex, TexShilbrikBlink[0]
			.ENDIF
		.ENDIF
	
		; Choose traverse animations
		fcmp ShilbrikSpeed, f(0.1)
		.IF (Carry?)
			.IF (ShilbrikAnimPlr.TrackPtr != OFFSET AnimShilbrikIdle)
				invoke bpAnimPlay, ADDR ShilbrikAnimPlr, ADDR AnimShilbrikIdle
			.ENDIF
			mov ShilbrikAnimPlr.Speed, FLT_1
		.ELSE
			bpMEM32 ShilbrikAnimPlr.Speed, ShilbrikSpeed
			
			mov flVal,rv(Vector32DAngle,OFFSET ShilbrikPosP,OFFSET ShilbrikPosL)
			fld flVal
			fsub ShilbrikRot
			fstp flVal
			mov flVal, rv(flAngle, flVal)
			.IF (rv(flInRange, flVal, PIQuarter, f(2.35619449)))
				mov pax, OFFSET AnimShilbrikLeft
			.ELSE
				.IF (rv(flInRange, flVal, f(-2.35619449), PIQuarterN))
					mov pax, OFFSET AnimShilbrikRight
				.ELSE
					.IF (rv(flInRange, flVal, PIQuarterN, PIQuarter))
						mov pax, OFFSET AnimShilbrikRun
					.ELSE
						mov pax, OFFSET AnimShilbrikBack
					.ENDIF
				.ENDIF
			.ENDIF
			
			.IF (ShilbrikAnimPlr.TrackPtr != OFFSET AnimShilbrikBack) && \
			(ShilbrikAnimPlr.TrackPtr != OFFSET AnimShilbrikLeft) && \
			(ShilbrikAnimPlr.TrackPtr != OFFSET AnimShilbrikRight) && \
			(ShilbrikAnimPlr.TrackPtr != OFFSET AnimShilbrikRun)
				invoke bpAnimPlay, ADDR ShilbrikAnimPlr, pax
			.ELSE
				mov ShilbrikAnimPlr.TrackPtr, pax
			.ENDIF
		.ENDIF
	.ELSE
		mov ShilbrikAnimPlr.Speed, FLT_1
		mov ShilbrikBlinkTimer, FLT_1
	.ENDIF
	
	mov ShilbrikRot[4], rv(flLerpAngle, ShilbrikRot[4], ShilbrikRot, delta10)
	
	; Collide with player
	.IF (PlrState == PLAYER_STATE_GAME)
		invoke Collide_Distance, ADDR CamPos, ADDR ShilbrikPos, f(0.3), 0
		.IF (pax)
			.IF (Shilbrik == SHILBRIK_HIDE)
				.IF !(ShilbrikCooldown)
					bpMEM32 ShilbrikCooldown, f(0.5)
					
					bpMPM UIDeadTipStr, StrTipShilbrik
			
					fld PlrHealth
					fsub f(0.4)
					fstp PlrHealth
					invoke SndSetPos, SndHurt, ADDR ShilbrikPos
					invoke alSourcePlay, SndHurt
					bpMEM32 NetSound, SndHurt
					invoke Vector32DCopy, ADDR NetSoundPos, ADDR CamPos
					invoke Net_FormSend, NET_SOUND, NetSock
				.ENDIF
			.ENDIF
		.ENDIF
	.ENDIF
	ret
Shilbrik_Process ENDP
