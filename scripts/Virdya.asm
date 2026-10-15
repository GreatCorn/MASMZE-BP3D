ENUM	VIRDYA_NONE, \
		VIRDYA_CHILL, \
		VIRDYA_SCARED, \
		VIRDYA_DEFENSIVE, \
		VIRDYA_BLIND, \
		VIRDYA_COVER
		
.DATA
Virdya				BPEnum VIRDYA_NONE
VirdyaAnimPlr		BPAnimPlayer <>
VirdyaBlinkTimer	REAL4 0.0, 0.3, 4.0
VirdyaCoverTimer	REAL4 9.0
VirdyaHeadRot		Vector2 <>
VirdyaLookPos		Vector3 <>
VirdyaLookPtr		BPPtr 0
VirdyaPos			Vector3 <>
VirdyaRot			REAL4 0.0
VirdyaSpeed			REAL4 0.0
VirdyaStrafe		SDWORD 0
VirdyaStrafeTimer	REAL4 0.5
VirdyaVisible		BPBool FALSE
VirdyaWaveTimer		DWORD 0

.DATA?
VirdyaCurSpeed		REAL4 ?
VirdyaFace			DWORD ?
VirdyaHeadPosPtr	BPPtr ?
VirdyaHairVel		BPPtr ?

.CODE

Virdya_Backoff PROC EXPORT PosPtr:BPPtr, Distance:REAL4, Speed:REAL4
	LOCAL dist:REAL4
	
	mov dist, rv(Vector32DDistanceSqr, OFFSET VirdyaPos, PosPtr)
	; Stop when far enough away
	fcmp dist, Distance
	.IF (Carry?)
		bpMEM32 VirdyaSpeed, Speed
		fcmp VirdyaCurSpeed, f(0.1)
		.IF (Carry?)
			fld VirdyaStrafeTimer
			fsub deltaTime
			fstp VirdyaStrafeTimer
			
			.IF (VirdyaStrafeTimer & FLT_NEG)
				.IF (VirdyaStrafe)
					neg VirdyaStrafe
				.ELSE
					invoke nRand, 2
					.IF (al)
						mov VirdyaStrafe, 1
					.ELSE
						mov VirdyaStrafe, -1
					.ENDIF
					
					.IF (VirdyaAnimPlr.TrackPtr != OFFSET AnimVirdyaCornered)
						invoke bpAnimPlay, ADDR VirdyaAnimPlr, \
						ADDR AnimVirdyaCornered
					.ENDIF
				.ENDIF
			.ENDIF
		.ELSE
			bpMEM32 VirdyaStrafeTimer, f(0.5)
		.ENDIF
		mov pax, 1
	.ELSE
		xor pax, pax
		mov VirdyaSpeed, 0
		mov VirdyaStrafe, 0
	.ENDIF
	ret
Virdya_Backoff ENDP

Virdya_Scare PROC EXPORT PosPtr:BPPtr, CorrectY:BPBool
	LOCAL flVal:REAL4
	
	.IF (Virdya != VIRDYA_COVER)
		mov flVal, vrv(Vector32DDistanceSqr, PosPtr, OFFSET VirdyaPos)
		fcmp flVal, f(4)
		.IF (Carry?)
			mov Virdya, VIRDYA_SCARED
			.IF (CorrectY)
				vinvoke Vector32DCopy, OFFSET VirdyaLookPos, PosPtr
				bpMEM32 VirdyaLookPos.Y, f(1.2)
				mov VirdyaLookPtr, OFFSET VirdyaLookPos
			.ELSE
				bpMPM VirdyaLookPtr, PosPtr
			.ENDIF
			bpMEM32 VirdyaBlinkTimer, f(2)
		.ENDIF
	.ENDIF
	ret
Virdya_Scare ENDP

Virdya_Spawn PROC EXPORT State:BPEnum
	.IF (State == VIRDYA_NONE)
		invoke alSourceStop, SndVirdya
	.ELSE
		print "Spawned Virdya at "
		mov VirdyaAnimPlr.FrameType, BPA_FRAME_VERTEX	; Init animator
		mov VirdyaAnimPlr.Mesh, OFFSET MeshVirdya
		invoke bpAnimPlay, ADDR VirdyaAnimPlr, ADDR AnimVirdyaIdle
		
		invoke Maze_GetRandomPos, ADDR VirdyaPos, FALSE
		Vector32DPrint VirdyaPos
		
		bpMEM32 VirdyaFace, TexVirdyaNeut[0]
	.ENDIF
	
	mbm Virdya, State
	ret
Virdya_Spawn ENDP


Virdya_Draw PROC EXPORT
	LOCAL v2Val:Vector2
	
	.IF (VirdyaVisible)
		call glPushMatrix
		invoke glMaterialfv, GL_FRONT_AND_BACK, GL_AMBIENT, ADDR clBlack
		invoke glMaterialfv, GL_FRONT_AND_BACK, GL_DIFFUSE, ADDR clLightGray
		invoke glMaterialfv, GL_FRONT_AND_BACK, GL_SPECULAR, ADDR clBlack
		invoke glBindTexture, GL_TEXTURE_2D, VirdyaFace
		invoke glDisable, GL_CULL_FACE
		;invoke glShadeModel, GL_FLAT
		invoke glLightModeli, GL_LIGHT_MODEL_TWO_SIDE, 1
		invoke glTranslate3fv, ADDR VirdyaPos
		invoke glRotatefr, VirdyaRot, 0, FLT_1, 0
		invoke bpDrawMesh, ADDR MeshVirdya
		invoke glTranslate3fv, VirdyaHeadPosPtr
		invoke glRotatefr, VirdyaHeadRot.X, FLT_1, 0, 0
		.IF (SettingsGraphicsInterpolation)
			invoke bpDrawMesh, ADDR MeshVirdyaHairD
			invoke glRotatefr, VirdyaHeadRot.Y, 0, FLT_1, 0
		.ELSE
			invoke glRotatefr, VirdyaHeadRot.Y, 0, FLT_1, 0
			invoke glCallList, MdlVirdyaHairStatic
		.ENDIF
		invoke glEnable, GL_CULL_FACE
		;invoke glShadeModel, GL_SMOOTH
		invoke glLightModeli, GL_LIGHT_MODEL_TWO_SIDE, 0
		invoke glCallList, MdlVirdyaHead
		invoke glMaterialfv, GL_FRONT_AND_BACK, GL_AMBIENT, ADDR clAmbient
		invoke glMaterialfv, GL_FRONT_AND_BACK, GL_DIFFUSE, ADDR clWhite
		invoke glMaterialfv, GL_FRONT_AND_BACK, GL_SPECULAR, ADDR clWhite
		
		call glPopMatrix
	.ENDIF
	ret
Virdya_Draw ENDP

Virdya_Fixed PROC EXPORT
	LOCAL tVert:Vector3, vert:Vector3
	
	.IF (SettingsGraphicsInterpolation) && (VirdyaVisible)
		push pbx
		xor pbx, pbx
		.WHILE (pbx < MeshVirdyaHair.V3Size)
			mov pax, pbx
			add pax, MeshVirdyaHair.Vertices
			invoke Vector3Copy, ADDR tVert, pax
			mov pcx, pbx
			add pcx, MeshVirdyaHairD.Vertices
			invoke Vector32DCopy, ADDR vert, pcx
			
			mov eax, VirdyaHeadRot.Y
			xor eax, FLT_NEG
			invoke Rotate2DPoint, ADDR tVert, eax
			;invoke Rotate2DPoint, ADDR vert, vert.Y
			
			fld tVert.Y
			fsub f(0.2)
			fmul st, st
			fdivr f(1.5)
			fmul deltaFixed
			;fld deltaFixed
			fstp tVert.Y
			
			fcmp tVert.Y, f(1)
			.IF (!Carry?) || (Zero?)	; Clamp
				bpMPM vert.X, tVert.X
				bpMPM vert.Z, tVert.Z
				
				jmp virdyaHairEnd
			.ENDIF
			
			mov pdx, VirdyaHairVel
			add pdx, pbx
			invoke DampedSpring, pdx, vert.X, tVert.X, f(0.7), f(0.5), tVert.Y
			fld REAL4 PTR [pdx]
			fmul tVert.Y
			fadd vert.X
			fstp vert.X
			add pdx, 8
			invoke DampedSpring, pdx, vert.Z, tVert.Z, f(0.7), f(0.5), tVert.Y
			fld REAL4 PTR [pdx]
			fmul tVert.Y
			fadd vert.Z
			fstp vert.Z
			
			virdyaHairEnd:
			invoke Vector32DCopy, pcx, ADDR vert
			add pbx, SIZEOF Vector3
		.ENDW
		pop pbx
	.ENDIF
	ret
Virdya_Fixed ENDP

Virdya_Process PROC EXPORT
	LOCAL v2Val:Vector2, v3Val:Vector3, deltaMove:REAL4, plrPosPtr:BPPtr
	
	.IF (rv(Plr_Cull, OFFSET VirdyaPos))
		mov VirdyaVisible, FALSE
	.ELSE
		mov VirdyaVisible, TRUE
	.ENDIF
	
	; Get closest player position
	mov plrPosPtr, rv(GetPlrNearPos, OFFSET VirdyaPos)
	
	.IF (Virdya == VIRDYA_BLIND) && \
	(VirdyaAnimPlr.TrackPtr != OFFSET AnimVirdyaBlind)
		invoke bpAnimPlay, ADDR VirdyaAnimPlr, ADDR AnimVirdyaBlind
		bpMEM32 VirdyaBlinkTimer, f(4.57)
		bpMEM32 VirdyaFace, TexVirdyaBlinkN
		mov VirdyaLookPtr, 0
		mov VirdyaSpeed, 0
		
		.IF (SettingsGraphicsInterpolation)
			mov VirdyaAnimPlr.Interpolation, BP_INTERPOLATE_LINEAR
		.ENDIF
	.ELSEIF (Virdya == VIRDYA_COVER) && \
	(VirdyaAnimPlr.TrackPtr != OFFSET AnimVirdyaSit) && \
	(VirdyaAnimPlr.TrackPtr != OFFSET AnimVirdyaCover)
		bpMEM32 VirdyaBlinkTimer, f(100)
		bpMEM32 VirdyaCoverTimer, f(9)
		mov VirdyaAnimPlr.Speed, FLT_1
		invoke bpAnimPlay, ADDR VirdyaAnimPlr, ADDR AnimVirdyaSit
		mov VirdyaSpeed, 0
		
		.IF (SettingsGraphicsInterpolation)
			mov VirdyaAnimPlr.Interpolation, BP_INTERPOLATE_LINEAR
		.ENDIF
	.ENDIF
	invoke bpProcessAnimPlayer, ADDR VirdyaAnimPlr, deltaTime
	; Animate blind face
	.IF (Virdya == VIRDYA_BLIND)
		.IF (pax)
			.IF (rv(flInRange, VirdyaAnimPlr.Timer, f(48), f(78)))
				bpMPM VirdyaLookPtr, plrPosPtr
			.ENDIF
			fcmp VirdyaAnimPlr.Timer, f(50)
			.IF (!Carry?)
				bpMEM32 VirdyaFace, TexVirdyaSquint
			.ENDIF
			fld VirdyaAnimPlr.Timer
			fistp deltaMove
			.IF (deltaMove == 61) || (deltaMove == 70) || (deltaMove > 83)
				bpMEM32 VirdyaFace, TexVirdyaBlinkN
			.ENDIF
		.ENDIF
		.IF !(VirdyaAnimPlr.TrackPtr)
			mov Virdya, VIRDYA_CHILL
		.ENDIF
	.ELSEIF (Virdya == VIRDYA_COVER)
		fcmp VirdyaAnimPlr.Timer, f(9)
		.IF (!Carry?)
			bpMEM32 VirdyaFace, TexVirdyaBlinkN
		.ENDIF
		
		fcmp VirdyaBlinkTimer, f(1.5)
		.IF (Carry?) && (VirdyaAnimPlr.TrackPtr == OFFSET AnimVirdyaCover)
			mov VirdyaAnimPlr.Speed, FLT_1 or FLT_NEG
			invoke bpAnimPlay, ADDR VirdyaAnimPlr, ADDR AnimVirdyaSit
		.ENDIF
		
		fld VirdyaRot
		fsincos
		fadd VirdyaPos.Z
		fstp VirdyaLookPos.Z
		fadd VirdyaPos.X
		fstp VirdyaLookPos.X
		;invoke Vector32DAdd, ADDR VirdyaLookPos, VirdyaHeadPosPtr
		.IF (VirdyaAnimPlr.TrackPtr == OFFSET AnimVirdyaSit)
			fld VirdyaAnimPlr.Timer
			fsub f(15)
			fstp VirdyaLookPos.Y
			.IF (VirdyaLookPos.Y & FLT_NEG)
				mov VirdyaLookPos.Y, 0
			.ENDIF
			fld VirdyaLookPos.Y
			fsubr f(10)
			fmul f(0.1)
			fstp VirdyaLookPos.Y
		.ELSE
			bpMEM32 VirdyaLookPos.Y, f(-4)
		.ENDIF
		mov VirdyaLookPtr, 0
		
		.IF !(VirdyaAnimPlr.TrackPtr)
			invoke bpAnimPlay, ADDR VirdyaAnimPlr, ADDR AnimVirdyaCover
		.ENDIF
	.ENDIF
	.IF (VirdyaAnimPlr.TrackPtr != OFFSET AnimVirdyaBlind) && \
	(VirdyaAnimPlr.TrackPtr != OFFSET AnimVirdyaSit) && \
	(SettingsGraphicsInterpolation)
		mov VirdyaAnimPlr.Interpolation, BP_INTERPOLATE_LINEAR_S
	.ENDIF
	
	.IF (Virdya == VIRDYA_CHILL)
		bpMEM32 deltaMove, delta2
	.ELSE
		bpMEM32 deltaMove, delta10
	.ENDIF
	
	; Look at position
	; Rotate head X
	invoke Vector32DCopy, ADDR v3Val, ADDR VirdyaPos
	mov pax, VirdyaHeadPosPtr
	bpMEM32 v3Val.Y, REAL4 PTR [pax+4]
	invoke Vector3Angle, ADDR v3Val, ADDR VirdyaLookPos, ADDR v2Val
	mov VirdyaHeadRot.X, rv(flLerp, VirdyaHeadRot.X, v2Val.X, deltaMove)
	fld v2Val.Y
	fsub VirdyaRot
	fstp v3Val.X
	mov v3Val.X, rv(flAngle, v3Val.X)
	mov VirdyaHeadRot.Y, rv(flLerpAngle, VirdyaHeadRot.Y, v3Val.X, deltaMove)
	mov v3Val.X, 0
	fcmp VirdyaHeadRot.Y, PIQuarter
	.IF (!Carry?)
		bpMEM32 v3Val.X, PIQuarter
	.ELSE
		fcmp VirdyaHeadRot.Y, PIQuarterN
		.IF (Carry?)
			bpMEM32 v3Val.X, PIQuarterN	
		.ENDIF
	.ENDIF
	.IF (v3Val.X)
		fld VirdyaHeadRot.Y
		fsub v3Val.X
		fadd VirdyaRot
		fstp VirdyaRot
		bpMEM32 VirdyaHeadRot.Y, v3Val.X	
	.ENDIF
	mov VirdyaRot, rv(flAngle, VirdyaRot)
	;mov VirdyaRot, rv(flLerpAngle, VirdyaRot, v2Val.Y, deltaMove)
	
	; Deliberately looks at an object
	.IF (VirdyaLookPtr)
		.IF (VirdyaLookPtr != OFFSET VirdyaLookPos)
			invoke Vector3Copy, ADDR VirdyaLookPos, VirdyaLookPtr
		.ENDIF
		mov eax, TexVirdyaBlink
		.IF (VirdyaFace != eax)
			.IF (Virdya == VIRDYA_CHILL)
				bpMEM32 VirdyaFace, TexVirdyaNeut[0]
			.ELSEIF (Virdya != VIRDYA_BLIND) && (Virdya != VIRDYA_COVER)
				bpMEM32 VirdyaFace, TexVirdyaN
			.ENDIF
		.ENDIF
	.ENDIF
	
	invoke Vector32DCopy, ADDR v3Val, ADDR VirdyaPos
	;invoke Vector32DMove, ADDR VirdyaPos, ADDR VirdyaTarget, deltaTime
	fld VirdyaRot
	fsincos
	fmul deltaTime
	fmul VirdyaSpeed
	fld st
	fimul VirdyaStrafe
	fadd VirdyaPos.X
	fstp VirdyaPos.X
	fadd VirdyaPos.Z
	fstp VirdyaPos.Z
	fmul deltaTime
	fmul VirdyaSpeed
	fld st
	fimul VirdyaStrafe
	fadd VirdyaPos.Z
	fstp VirdyaPos.Z
	fadd VirdyaPos.X
	fstp VirdyaPos.X
	
	; World collison
	invoke Maze_CollideLayout, ADDR VirdyaPos, f(0.7), TRUE
	
	invoke Collide_Distance, ADDR CamPos, ADDR VirdyaPos, f(0.3), 0
	.IF (PlrState == PLAYER_STATE_GAME) && (Virdya != VIRDYA_BLIND) && \
	(Virdya != VIRDYA_COVER)
		.IF (pax) && ((InputMovement.X) || (InputMovement.Y))
			mov VirdyaSpeed, FLT_1 or FLT_NEG
			mov VirdyaLookPtr, OFFSET CamPos
			;invoke Vector3Copy, ADDR VirdyaLookPos, ADDR CamPos
			
			; Send net stuff?
			invoke Net_FormSend, NET_MAZE_ENTITIES, NetSock
		.ENDIF
	.ENDIF
	
	; Get speed
	mov VirdyaCurSpeed, rv(Vector32DDistance, ADDR v3Val, OFFSET VirdyaPos)
	
	.IF (VirdyaAnimPlr.TrackPtr == OFFSET AnimVirdyaAttack)
		bpMEM32 v3Val.Y, delta2
	.ELSEIF (VirdyaAnimPlr.TrackPtr == OFFSET AnimVirdyaWave)
		bpMEM32 v3Val.Y, deltaTime
	.ELSE
		fld VirdyaCurSpeed
		fmul f(2)
		fstp v3Val.Y
		invoke SndFade, ADDR SndVirdya, 0, delta2
	.ENDIF
	mov VirdyaRot, rv(flLerpAngle, VirdyaRot, v2Val.Y, v3Val.Y)
	fld VirdyaCurSpeed
	fdiv deltaTime
	fstp VirdyaCurSpeed	; preserve for later
	
	; Animate
	;print real4$(VirdyaCurSpeed), 13, 10
	fcmp VirdyaCurSpeed, f(0.1)
	.IF (!Carry?)
		.IF (VirdyaSpeed & FLT_NEG)
			mov pax, OFFSET AnimVirdyaBack
		.ELSE
			mov pax, OFFSET AnimVirdyaWalk
		.ENDIF
		.IF (VirdyaAnimPlr.TrackPtr != pax)
			invoke bpAnimPlay, ADDR VirdyaAnimPlr, pax
		.ENDIF
		bpMEM32 VirdyaAnimPlr.Speed, VirdyaCurSpeed
	.ELSEIF (Virdya != VIRDYA_COVER)
		.IF (VirdyaAnimPlr.TrackPtr == OFFSET AnimVirdyaWalk) || \
		(VirdyaAnimPlr.TrackPtr == OFFSET AnimVirdyaBack) || \
		!(VirdyaAnimPlr.TrackPtr) || \
		((VirdyaAnimPlr.TrackPtr == OFFSET AnimVirdyaCornered) \
		&& (Virdya == VIRDYA_CHILL))
			invoke bpAnimPlay, ADDR VirdyaAnimPlr, ADDR AnimVirdyaIdle
		.ENDIF
		mov VirdyaAnimPlr.Speed, FLT_1
	.ENDIF
	
	; Self-scare behaviour
	.IF (Virdya != VIRDYA_BLIND) && (Virdya != VIRDYA_COVER)
		.IF (PlrGlyphs == 6) && (PlrGlyphsInMaze)
			invoke Virdya_Scare, ADDR PlrGlyphPos[0], FALSE
		.ELSEIF (PlrGlyphs < 6) && (Virdya != VIRDYA_SCARED)
			mov v3Val.Y, rv(GetPlrNearDist, OFFSET VirdyaPos)
			mov v3Val.Z, 0	; if can sense nearest player
			fld f(2)
			fsub PlrCrouch
			fmul f(4.5) ; *0.5 * 9
			fstp v3Val.X
			fcmp v3Val.Y, v3Val.X
			.IF (Carry?)
				mov v3Val.Z, 1
			.ELSE
				fld f(2)
				fsub PlrCrouch
				fmul f(9.5) ; *0.5 * 9
				fstp v3Val.X
				fcmp v3Val.Y, v3Val.X
				.IF (Carry?)
					.IF !(rv(Maze_Raycast, OFFSET VirdyaPos, plrPosPtr))
						mov v3Val.Z, 1
					.ENDIF
				.ENDIF
			.ENDIF
			
			.IF (v3Val.Z)
				mov Virdya, VIRDYA_DEFENSIVE
				bpMPM VirdyaLookPtr, plrPosPtr
			.ENDIF
		.ENDIF
	.ENDIF
	
	.IF (Virdya == VIRDYA_CHILL)
		mov v3Val.X, \
		rv(Vector32DDistanceSqr, OFFSET VirdyaPos, OFFSET VirdyaLookPos)
		.IF (VirdyaSpeed & FLT_NEG)
			; Stop when far enough away
			fcmp v3Val.X, f(1.0)
			.IF (!Carry?)
				mov VirdyaSpeed, 0
			.ENDIF
		.ELSE
			; Stop when reached target
			fcmp v3Val.X, f(0.4)
			.IF (Carry?)
				mov VirdyaSpeed, 0
			.ENDIF
		.ENDIF
	.ELSEIF (Virdya == VIRDYA_SCARED)
		invoke Virdya_Backoff, ADDR VirdyaLookPos, f(5), f(-2)
	.ELSEIF (Virdya == VIRDYA_DEFENSIVE)
		fcmp VirdyaCoverTimer, f(3)
		.IF (Carry?) && (Virdya == VIRDYA_DEFENSIVE)
			bpMEM32 v3Val.X, f(-2.7)
		.ELSE
			bpMEM32 v3Val.X, f(-2.4)
		.ENDIF
		.IF (rv(Virdya_Backoff, plrPosPtr, f(1), v3Val.X))
			fld VirdyaCoverTimer
			fsub deltaTime
			fstp VirdyaCoverTimer
			
			fcmp VirdyaCoverTimer, f(3)
			.IF (Carry?)
				bpMEM32 VirdyaFace, TexVirdyaNS
			.ENDIF
			
			.IF (VirdyaCoverTimer & FLT_NEG)
				mov Virdya, VIRDYA_COVER
			.ENDIF
		.ELSE
			bpMEM32 VirdyaCoverTimer, f(9)
			fcmp v3Val.Y, f(8)
			.IF (Carry?)
				.IF !(rv(Maze_Raycast, OFFSET VirdyaPos, plrPosPtr))
					.IF (VirdyaAnimPlr.TrackPtr != OFFSET AnimVirdyaAttack)
						invoke bpAnimPlay, ADDR VirdyaAnimPlr, \
						ADDR AnimVirdyaAttack
					.ENDIF
					.IF (rv(SndPlaying, SndVirdya) != AL_PLAYING)
						invoke alSourcePlay, SndVirdya
					.ENDIF
					invoke SndFade, ADDR SndVirdya, FLT_1, delta2
					
					; Attack effects
					.IF (PlrState == PLAYER_STATE_GAME)
						mov v3Val.X, \
						rv(Vector32DDistanceSqr, OFFSET CamPos, plrPosPtr)
						fcmp v3Val.X, f(1)
						.IF (Carry?)
							vinvoke Vector32DLerp, OFFSET CamPos, \
							OFFSET CamPosP, f(0.66)
							fld deltaTime
							fmul f(0.25)
							fsubr PlrHealth
							fstp PlrHealth
							bpMEM32 PlrHeal, f(0.7)
							bpMPM UIDeadTipStr, StrTipVirdya
						.ENDIF
					.ENDIF
				.ENDIF
			.ENDIF
			mov VirdyaSpeed, 0
		.ENDIF
	.ENDIF
	invoke SndSetPos, SndVirdya, ADDR VirdyaPos
	
	; Blink and rand move
	fld VirdyaBlinkTimer
	.IF (Virdya == VIRDYA_CHILL) || (Virdya == VIRDYA_BLIND)
		fsub deltaTime
	.ELSE
		fsub delta2
	.ENDIF
	fstp VirdyaBlinkTimer
	.IF (VirdyaBlinkTimer & FLT_NEG)
		.IF (Virdya == VIRDYA_CHILL)
			bpMEM32 VirdyaFace, TexVirdyaBlink
		.ELSE
			bpMEM32 VirdyaFace, TexVirdyaBlinkN
		.ENDIF
		
		fcmp VirdyaBlinkTimer, f(-0.1)
		.IF (Carry?)
			mov VirdyaBlinkTimer, \
			rv(flRandRange, VirdyaBlinkTimer[4], VirdyaBlinkTimer[8])
			
			.IF (Virdya == VIRDYA_CHILL)
				invoke nRand, SIZEOF TexVirdyaNeut/4
				shl pax, 2
				bpMEM32 VirdyaFace, TexVirdyaNeut[pax]
				
				; Move or emote
				invoke nRand, 5
				.IF (eax == 1)
					mov VirdyaSpeed, FLT_1
					mov VirdyaLookPos.Y, rv(flRandRange, f(1), f(1.8))
				.ELSEIF (eax == 2)
					invoke bpAnimPlay, ADDR VirdyaAnimPlr, ADDR AnimVirdyaRest
					mov pax, plrPosPtr
					.IF (VirdyaLookPtr == pax)
						.IF (VirdyaWaveTimer)
							dec VirdyaWaveTimer
						.ELSE
							print "Virdya wave", 13, 10
							mov VirdyaWaveTimer, rv(intRandRange, 5, 15)
							invoke bpAnimPlay, ADDR VirdyaAnimPlr, \
							ADDR AnimVirdyaWave
							bpMEM32 VirdyaBlinkTimer, f(2.8)
							mov VirdyaSpeed, 0
							bpMPM VirdyaLookPtr, plrPosPtr
							
							ret
						.ENDIF
					.ENDIF
				.ENDIF
				
				; Look at something
				invoke nRand, 6
				.IF (eax < 2)
					mov VirdyaLookPos.X, rv(flRandRange, f(-3), f(3))
					mov VirdyaLookPos.Z, rv(flRandRange, f(-3), f(3))
					mov VirdyaLookPos.Y, rv(flRandRange, f(0), f(1.6))
					invoke Vector3Add, ADDR VirdyaLookPos, ADDR VirdyaPos
					mov VirdyaLookPtr, 0
				.ELSEIF (eax == 2)
					; Closest player
					.IF !(rv(Maze_Raycast, OFFSET VirdyaPos, plrPosPtr))
						bpMPM VirdyaLookPtr, plrPosPtr
					.ENDIF
				.ENDIF
			.ELSE
				mov Virdya, VIRDYA_CHILL
				bpMEM32 VirdyaFace, TexVirdyaN
				mov VirdyaStrafe, 0
			.ENDIF
			
			; Send net stuff?
		.ENDIF
	.ENDIF
	ret
Virdya_Process ENDP

