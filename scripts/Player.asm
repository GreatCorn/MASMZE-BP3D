ENUML
	E PLAYER_STATE_GAME
	E PLAYER_STATE_ENTER
	E PLAYER_STATE_EXIT
	E PLAYER_STATE_EXITING
	
	; Wmblyk strangle minigame
	E PLAYER_STATE_STRANGLE
	E PLAYER_STATE_GETUP
	
	E PLAYER_STATE_DYING
	E PLAYER_STATE_DEAD
	
	; Intro-related
	E PLAYER_STATE_INTRO_DARK
	E PLAYER_STATE_INTRO_CITY
	E PLAYER_STATE_INTRO_TEXT1
	E PLAYER_STATE_INTRO_OUTSKIRTS
	E PLAYER_STATE_INTRO_TEXT2
	E PLAYER_STATE_INTRO_WOODS
	E PLAYER_STATE_INTRO_TEXT3
	
	E PLAYER_STATE_STOP
	E PLAYER_STATE_ETC
	
.CONST
CamHeight		REAL4 1.2
PlrSpeedCrouch	REAL4 2.0
PlrSpeedWalk	REAL4 3.6
	
.DATA
; Movement and transformation
CamPos			Vector3 <>	; Real camera position
CamPosI			Vector3 <>	; Real rounded (FPU_ROUND_ROUND) position
CamPosL			Vector3 <>	; Displayed (lerped) camera position
CamPosP			Vector3 <>	; Previous frame camera position
CamRot			Vector3 <>
CamRotL			Vector3 <>
CamRotSmooth	REAL4 16.0
PlrCanControl	BPBool TRUE
PlrCrouch		REAL4 0.0
PlrForward		Vector3 <>
PlrUp			Vector3 <0.0, 1.0, 0.0>	; Up vector for AL_ORIENTATION
PlrRight		Vector3 <>
PlrSpeed		REAL4 0.0	; Current absolute player speed
PlrSpeedScaled	REAL4 0.0	; Current scaled player speed (0.0 - PlrSpeedWalk)

CamAnimPlr		BPAnimPlayer <>
CamPosA			Vector3 <>
CamRotA			Vector3 <>

CamLightPos		Vector4 <0.0, 0.0, 0.0, 1.0>
CamFOV			REAL4 75.0
CamBaseFOV		REAL4 75.0
PlrGlyphs		DWORD 7
PlrGlyphsInMaze	DWORD 0
PlrGlyphPos		Vector3 7 DUP (<>)
PlrGlyphRot		REAL4 7 DUP (0.0)
PlrHealth		REAL4 1.0
PlrPlayStep		BPBool FALSE

PlrState			DWORD PLAYER_STATE_ENTER
PlrStateCallback	BPPtr 0
PlrStateTimer		REAL4 0.0

PlrPartRain	ParticleSystem	<>

.CODE
Plr_Shake PROTO :REAL4

Plr_Control PROC EXPORT
	LOCAL flVal:REAL4, movSpd:REAL4, velocity:Vector3
	; Prepare movement from generic axes
	fld InputAxes[0]
	fsub InputAxes[4]
	fstp InputMovement.Y
	fld InputAxes[12]
	fsub InputAxes[8]
	fstp InputMovement.X
	
	; Prepare look from generic axes
	fld InputAxes[20]
	fsub InputAxes[16]
	fmul delta2
	fmul SettingsControlsJoystickSpeed
	fadd InputLook.Y
	fstp InputLook.Y
	fld InputAxes[28]
	fsub InputAxes[24]
	fmul delta2
	fmul SettingsControlsJoystickSpeed
	fadd InputLook.X
	fstp InputLook.X
	
	; Look
	.IF (FMain.MouseMode == BP_MOUSE_MODE_LOCKED)
		fld InputLook.Y
		fadd CamRot.X
		fstp CamRot.X
		mov CamRot.X, rv(flClamp, CamRot.X, PIHalfN, PIHalf)
		
		fld InputLook.X
		fsubr CamRot.Y
		fstp CamRot.Y
		mov CamRot.Y, rv(flAngle, CamRot.Y)
		mov CamRotL.Y, rv(flAngle, CamRotL.Y)
	.ENDIF
	
	; Clamp movement magnitude
	mov flVal, rv(Vector2LengthSqr, ADDR InputMovement)
	fcmp flVal, f(1)
	.IF (!Carry?)
		fld flVal
		fsqrt
		fld st
		fld InputMovement.X
		fdivr
		fstp InputMovementClamped.X
		fld InputMovement.Y
		fdivr
		fstp InputMovementClamped.Y
	.ELSE
		invoke Vector2Copy, ADDR InputMovementClamped, ADDR InputMovement
	.ENDIF
	
	.IF (InputCrouch)	; Handle crouching
		mov PlrCrouch, rv(flLerp, PlrCrouch, f(0.5), delta20)
	.ELSE
		mov PlrCrouch, rv(flLerp, PlrCrouch, 0, delta20)
		fcmp PlrCrouch, f(0.01)
		.IF (Carry?)
			mov PlrCrouch, 0
		.ENDIF
	.ENDIF
	.IF (PlrCrouch)		; Choose movement speed
		bpMEM32 movSpd, PlrSpeedCrouch
	.ELSE
		bpMEM32 movSpd, PlrSpeedWalk
	.ENDIF
	
	; Move
	fld InputMovementClamped.X
	fmul movSpd
	fmul deltaTime
	fstp flVal
	invoke Vector32DCopy, ADDR velocity, ADDR PlrRight
	invoke Vector32DMulF, ADDR velocity, flVal
	invoke Vector32DAdd, ADDR CamPos, ADDR velocity	; X movement
	fld InputMovementClamped.Y
	fmul movSpd
	fmul deltaTime
	fstp flVal
	invoke Vector32DCopy, ADDR velocity, ADDR PlrForward
	invoke Vector32DMulF, ADDR velocity, flVal
	invoke Vector32DAdd, ADDR CamPos, ADDR velocity	; Y movement
	fld CamHeight
	fsub PlrCrouch
	fstp CamPos.Y
	
	; Tilt
	fld InputMovementClamped.X
	fmul f(0.02)
	fstp CamRot.Z
	
	; Glyphs
	.IF (PlrState == PLAYER_STATE_GAME) && (InputGlyph)
		.IF (PlrGlyphs)
			invoke alSourcePlay, SndScribble
			dec PlrGlyphs
			
			mov pax, PlrGlyphsInMaze
			mov pcx, 12
			mul pcx
			push pax
			invoke Vector32DCopy, ADDR PlrGlyphPos[pax], ADDR CamPos
			pop pax
			fild PlrGlyphsInMaze
			fmul f(0.01)
			fadd f(0.01)
			fstp PlrGlyphPos[pax].Y
			
			mov pcx, PlrGlyphsInMaze
			shl pcx, 2
			bpMEM32 PlrGlyphRot[pcx], CamRot.Y
			
			inc PlrGlyphsInMaze
			
			.IF (PlrGlyphs)
				vinvoke UI_ShowSubtitles, StrCCGlyphs, UISubDur
			.ELSE
				invoke alSourcePlay, SndMistake
			.ENDIF
		.ENDIF
		.IF !(PlrGlyphs)
			vinvoke UI_ShowSubtitles, StrCCGlyphsNone, UISubDur
		.ENDIF
		
		mov InputGlyph, 0
	.ENDIF
	ret
Plr_Control ENDP

Plr_DrawGlyphs PROC EXPORT
	LOCAL pos:Vector3, rot:REAL4
	
	xor pbx, pbx
	.WHILE (pbx < PlrGlyphsInMaze)
		mov pax, pbx
		shl pax, 2
		mov ecx, PlrGlyphRot[pax]
		mov rot, ecx
		mov pcx, 3
		mul pcx
		invoke Vector3Copy, ADDR pos, ADDR PlrGlyphPos[pax]
		invoke glEnable, GL_BLEND
		invoke glDisable, GL_FOG
		invoke glDisable, GL_LIGHTING
		invoke glBlendFunc, GL_ONE, GL_ONE
		call glPushMatrix
		invoke glTranslate3fv, ADDR pos
		invoke glRotatefr, rot, 0, f(1), 0
		invoke glRotatef, f(-90), f(1), 0, 0
		invoke glScalef, f(0.4), f(0.8), f(1)
		
		mov pax, ((SIZEOF TexGlyph) shr 2)	; 7
		sub pax, PlrGlyphs
		sub pax, PlrGlyphsInMaze
		add pax, pbx
		invoke glBindTexture, GL_TEXTURE_2D, TexGlyph[pax*4]
		
		invoke glCallList, MdlParticle
		call glPopMatrix
		invoke glDisable, GL_BLEND
		invoke glEnable, GL_FOG
		invoke glEnable, GL_LIGHTING
		
		inc pbx
	.ENDW
	ret
Plr_DrawGlyphs ENDP

Plr_DrawIntro PROC EXPORT
	SWITCH PlrState
		CASE PLAYER_STATE_INTRO_CITY
			invoke glBindTexture, GL_TEXTURE_2D, TexRoof
			invoke glCallList, MdlCityConcrete
			invoke glBindTexture, GL_TEXTURE_2D, TexFacade
			invoke glCallList, MdlCityFacade
			invoke glBindTexture, GL_TEXTURE_2D, TexFloor
			invoke glCallList, MdlCityTerrain
		CASE PLAYER_STATE_INTRO_OUTSKIRTS
			invoke glBindTexture, GL_TEXTURE_2D, TexRoof
			invoke glCallList, MdlOutskirtsRoad
			invoke glBindTexture, GL_TEXTURE_2D, TexFloor
			invoke glCallList, MdlOutskirtsTerrain
			invoke glEnable, GL_ALPHA_TEST
			invoke glBindTexture, GL_TEXTURE_2D, TexTree
			invoke glCallList, MdlOutskirtsTrees
			invoke glDisable, GL_ALPHA_TEST
		CASE PLAYER_STATE_INTRO_WOODS
			invoke glBindTexture, GL_TEXTURE_2D, TexFloor
			invoke glCallList, MdlOutskirtsTerrain
			invoke glEnable, GL_ALPHA_TEST
			invoke glBindTexture, GL_TEXTURE_2D, TexTree
			invoke glCallList, MdlOutskirtsTrees
			invoke glDisable, GL_ALPHA_TEST
			invoke glBindTexture, GL_TEXTURE_2D, TexDoor
			invoke glCallList, MdlOutskirtsBunker
	ENDSW
	
	.IF (SettingsGraphicsParticles)
		.IF (PlrState == PLAYER_STATE_INTRO_CITY) \
		|| (PlrState == PLAYER_STATE_INTRO_OUTSKIRTS) \
		|| (PlrState == PLAYER_STATE_INTRO_WOODS)
			invoke glEnable, GL_BLEND
			invoke glDepthMask, GL_FALSE
			invoke glDisable, GL_LIGHTING
			;invoke glDisable, GL_CULL_FACE
			
			invoke glColor4f, f(0.5), f(0.5), f(0.5), f(0.5)
			
			invoke glBlendFunc, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA
			invoke glBindTexture, GL_TEXTURE_2D, 0
			call glPushMatrix
			invoke glScalef, f(1), f(8), f(1)
			;invoke glRotatef, f(180), 0, f(1), 0
			invoke Particles_Draw, ADDR PlrPartRain
			call glPopMatrix
			
			invoke glDisable, GL_BLEND
			invoke glDepthMask, GL_TRUE
			invoke glEnable, GL_LIGHTING
			;invoke glEnable, GL_CULL_FACE
			
			invoke glColor4fv, OFFSET clWhite
		.ENDIF
	.ENDIF
	ret
Plr_DrawIntro ENDP

;   Checks if a point is in the (2D) frustum of the player camera
Plr_FrustumDot PROC EXPORT Position:BPPtr
	LOCAL Dot:Vector2
	
	mov pax, Position
	fld REAL4 PTR [pax]
	fsub CamPos.X
	fstp Dot.X
	fld REAL4 PTR [pax+8]
	fsub CamPos.Z
	fstp Dot.Y
	
	invoke Vector2Normalize, ADDR Dot
	fld Dot.X
	fmul PlrForward.X
	fld Dot.Y
	fmul PlrForward.Z
	fadd
	sub psp, SIZEOF BPPtr
	fstp REAL4 PTR [psp]
	pop pax
	ret
Plr_FrustumDot ENDP

Plr_LateProcess PROC EXPORT
	LOCAL flVal:REAL4, v3Val:Vector3
	
	fld deltaTime
	fmul CamRotSmooth
	fstp flVal
	
	invoke Vector3Copy, ADDR v3Val, ADDR CamPosA
	;invoke Vector3MulF, ADDR v3Val, f(16.0)
	invoke Vector3Add, ADDR v3Val, ADDR CamPos
	invoke Vector3Lerp, ADDR CamPosL, ADDR v3Val, delta10
	invoke Vector3Copy, ADDR v3Val, ADDR CamRotA
	;invoke Vector3MulF, ADDR v3Val, f(16.0)
	invoke Vector3Add, ADDR v3Val, ADDR CamRot
	invoke Vector3LerpAngle, ADDR CamRotL, ADDR v3Val, flVal
	
	.IF (PlrCanControl)
		mov flVal, rv(Vector32DDistanceSqr, OFFSET CamPos, OFFSET CamPosP)
		fld flVal
		fsqrt
		fdiv deltaTime
		fst PlrSpeed
		fdiv PlrSpeedWalk
		fstp PlrSpeedScaled
	.ELSE
		mov PlrSpeed, 0
		mov PlrSpeedScaled, 0
	.ENDIF
	invoke Vector32DCopy, ADDR CamPosP, ADDR CamPos
	ret
Plr_LateProcess ENDP

Plr_ProcessState PROC EXPORT
	LOCAL flVal:REAL4, v3Val:Vector3
	
	.IF (PlrState == PLAYER_STATE_ENTER)		
		mov CamAnimPlr.Interpolation, BP_INTERPOLATE_CONSTANT
		invoke bpAnimPlay, ADDR CamAnimPlr, ADDR AnimCamEnter
		invoke bpProcessAnimPlayer, ADDR CamAnimPlr, 0
		mov CamAnimPlr.Interpolation, BP_INTERPOLATE_LINEAR
		
		invoke Vector3Set, ADDR CamRot, 0, 0, 0
		invoke Vector3Copy, ADDR v3Val, ADDR CamRotA
		invoke Vector3Add, ADDR v3Val, ADDR CamRot
		invoke Vector3Copy, ADDR CamRotL, ADDR v3Val
		fild MazeEntranceCell
		fmul f(2)
		fadd f(1)
		fstp CamPos.X
		invoke Vector2Set, ADDR CamPos.Y, CamHeight, f(1)
		invoke Vector3Copy, ADDR v3Val, ADDR CamPosA
		invoke Vector3Add, ADDR v3Val, ADDR CamPos
		invoke Vector3Copy, ADDR CamPosL, ADDR v3Val
		
		mov PlrCanControl, FALSE
				
		mov MazeDoorRot, 0
		
		mov UIFade, UI_FADE_IN
		mov UIFadeCallback, OFFSET plrEnterFade
		bpMEM32 UIFadeVal, f(1)
		
		mov PlrState, PLAYER_STATE_ETC
		ret
	.ELSEIF (PlrState == PLAYER_STATE_EXIT)
		invoke bpAnimPlay, ADDR CamAnimPlr, ADDR AnimCamExit
		
		mov PlrCanControl, FALSE
		
		mov UIFade, UI_FADE_NONE
		
		mov PlrState, PLAYER_STATE_EXITING
		
		invoke alSourcePlay, SndExit
		ret
	.ELSEIF (PlrState == PLAYER_STATE_EXITING)
		mov MazeDoorRot, rv(flLerp, MazeDoorRot, f(-100), delta2)
		invoke Vector3Lerp, ADDR CamPos, ADDR MazeDoorPos, delta2
		mov CamRot.X, rv(flLerp, CamRot.X, 0, delta2)
		mov CamRot.Y, rv(flLerpAngle, CamRot.Y, 0, delta2)
		fcmp CamAnimPlr.Timer, f(40)
		.IF (!Carry?) && !(UIFade)
			mov UIFade, UI_FADE_OUT
			mov UIFadeCallback, OFFSET plrExitFade
			mov UIFadeVal, 0
		.ENDIF
	.ELSEIF (PlrState >= PLAYER_STATE_INTRO_DARK) \
	&& (PlrState <= PLAYER_STATE_INTRO_TEXT3)
		.IF (MazeState != MAZE_STATE_END)
			.IF !(PlrStateTimer)
				.IF (PlrState == PLAYER_STATE_INTRO_DARK)
					bpMEM32 CamBaseFOV, f(60)
					bpMEM32 PlrStateTimer, f(5)
					
					mov PlrStateCallback, OFFSET plrIntroProgress
					
					invoke Vector3Set, ADDR CamPos, 0, CamHeight, 0
					invoke Vector2Set, ADDR CamRot, f(-0.5), 0
					mov PlrCanControl, FALSE
					invoke glLightf, GL_LIGHT0, GL_CONSTANT_ATTENUATION, f(1)
					invoke glLightf, GL_LIGHT0, GL_LINEAR_ATTENUATION, 0
					
					bpMEM32 FogDensity, f(0.1)
					invoke alSourcePlay, SndIntro
				.ELSEIF (PlrState == PLAYER_STATE_INTRO_TEXT3)
					bpMEM32 PlrStateTimer, f(5)
					
					mov PlrStateCallback, OFFSET GameStart
				.ELSE
					bpMEM32 PlrStateTimer, f(4)
				.ENDIF
			.ENDIF
			SWITCH PlrState
				CASE PLAYER_STATE_INTRO_CITY
					fld deltaTime
					fmul f(0.1)
					fstp flVal
					mov CamRot.X, rv(flLerp, CamRot.X, f(-0.6), flVal)
					mov CamRot.Y, rv(flLerp, CamRot.Y, f(-0.1), deltaTime)
					
					mov FogDensity, rv(flLerp, FogDensity, f(0.5), flVal)
				CASE PLAYER_STATE_INTRO_TEXT1
					invoke Vector32DSet, ADDR CamPos, 0, f(7)
					invoke Vector32DCopy, ADDR CamPosL, ADDR CamPos
					invoke Vector2Set, ADDR CamRot, 0, 0
					invoke Vector2Copy, ADDR CamRotL, ADDR CamRot
				CASE PLAYER_STATE_INTRO_OUTSKIRTS
					bpMEM32 PlrSpeedScaled, f(2)
					fld deltaTime
					fmul f(6)
					fadd CamPos.Z
					fstp CamPos.Z
					
					mov FogDensity, rv(flLerp, FogDensity, f(0.1), deltaTime)
				CASE PLAYER_STATE_INTRO_TEXT2
					invoke Vector32DSet, ADDR CamPos, 0, f(16)
					invoke Vector32DCopy, ADDR CamPosL, ADDR CamPos
					
					bpMEM32 FogDensity, f(0.5)
				CASE PLAYER_STATE_INTRO_WOODS
					bpMEM32 PlrSpeedScaled, f(2)
					fld deltaTime
					fmul f(6)
					fadd CamPos.Z
					fstp CamPos.Z
					
					mov FogDensity, rv(flLerp, FogDensity, f(0.1), deltaTime)
			ENDSW
			.IF (SettingsGraphicsParticles)
				fld CamPos.Z
				;fchs
				fadd f(4)
				fstp PlrPartRain.Position.Z
				bpMEM32 PlrPartRain.Position.Y, CamPos.Y
				invoke Particles_Process, ADDR PlrPartRain, deltaTime
			.ENDIF
		.ENDIF
	.ELSEIF (PlrState == PLAYER_STATE_STRANGLE)
		mov PlrCanControl, FALSE
		mov CamRot.Y, vrv(Vector32DAngle, OFFSET CamPos, OFFSET WmblykPos)
		;bpMEM32 CamRot.X, WmblykStateVal
		fld WmblykStateVal
		fmul st, st
		fmul f(1.5)
		fstp CamRot.X
		.IF (WmblykStateVal & FLT_NEG)
			xor CamRot.X, FLT_NEG
		.ENDIF
		fld CamRot.X
		fsub f(0.3)
		fstp CamRot.X
		
		; Change cam height
		fld WmblykStateVal
		fsub f(0.5)
		fmul f(0.2)
		fabs
		fsubr CamHeight
		fstp CamPos.Y
		
		; Translate by forward
		fld WmblykStateVal
		fadd f(0.5)
		;fmul f(2)
		fstp flVal
		mov flVal, rv(flClamp, flVal, f(0.2), f(2))
		invoke Vector32DCopy, ADDR v3Val, ADDR PlrForward
		invoke Vector32DMulF, ADDR v3Val, flVal
		invoke Vector32DCopy, ADDR CamPosL, ADDR CamPos
		invoke Vector32DAdd, ADDR CamPosL, ADDR v3Val
		
		; Time limit
		fld deltaTime
		fmul f(0.1)
		fsubr PlrHealth
		fstp PlrHealth
		
		
		invoke Plr_Shake, f(0.01)
		
		vinvoke UI_ShowSubtitles, StrCCFightBack, f(0.1)
	.ELSEIF (PlrState == PLAYER_STATE_GETUP)
		fld PlrHealth
		fmul delta2
		fstp flVal
		
		mov CamRot.X, rv(flLerp, CamRot.X, 0, flVal)
		mov flVal, rv(flAbs, CamRot.X)
		fcmp flVal, f(0.1)
		.IF (Carry?)
			mov PlrCanControl, TRUE
			mov PlrState, PLAYER_STATE_GAME
		.ENDIF
		
		mov CamPos.Y, rv(flLerp, CamPos.Y, CamHeight, deltaTime)
	.ELSEIF (PlrState == PLAYER_STATE_DYING) || (PlrState == PLAYER_STATE_DEAD)
		mov PlrCanControl, FALSE
		
		.IF (PlrState == PLAYER_STATE_DYING)
			mov CamPos.Y, rv(flLerp, CamPos.Y, 0, deltaTime)
			mov CamRot.X, rv(flLerp, CamRot.X, PIHalfN, deltaTime)
			mov UIFadeVal, vrv(flLerp, UIFadeVal, f(1.1), deltaTime)
			
			fcmp UIFadeDisp, f(1)
			.IF (!Carry?)
				mov PlrState, PLAYER_STATE_DEAD
				invoke alSourcePlay, SndDeath
			.ENDIF
		.ELSE
			mov UIFadeVal, FLT_1
		.ENDIF
		
		; Fade sounds
		.IF (Kubale)
			invoke SndFade, SndKubale, 0, deltaTime
			invoke SndFade, SndKubaleV, 0, deltaTime
		.ENDIF
		.IF (Wmblyk)
			invoke SndFade, SndWmblykStrM, 0, deltaTime
			invoke SndFade, SndWmblykB, 0, deltaTime
		.ENDIF
	.ENDIF
	
	.IF (PlrStateTimer)
		fld PlrStateTimer
		fsub deltaTime
		fstp PlrStateTimer
		
		mov eax, PlrStateTimer
		.IF (eax & FLT_NEG)
			mov PlrStateTimer, 0
			.IF (PlrStateCallback)
				call PlrStateCallback
			.ENDIF
		.ENDIF
	.ENDIF
	ret
	
	plrEnterFade:
		invoke bpAnimPlay, ADDR CamAnimPlr, ADDR AnimCamWalk
		mov PlrCanControl, TRUE
		mov PlrState, PLAYER_STATE_GAME
		mov UIFadeCallback, 0
		ret
	plrExitFade:
		mov PlrState, PLAYER_STATE_ENTER
		call Maze_Progress
		mov UIFadeCallback, 0
		ret
	plrIntroProgress:
		inc PlrState
		ret		
Plr_ProcessState ENDP

;   Shake screen (through CamRotL)
Plr_Shake PROC Amplitude:REAL4
	LOCAL v3Val:Vector3
	mov eax, Amplitude
	or eax, FLT_NEG
	push pax
	mov v3Val.X, rv(flRandRange, eax, Amplitude)
	pop pax
	push pax
	mov v3Val.Y, rv(flRandRange, eax, Amplitude)
	pop pax
	mov v3Val.Z, rv(flRandRange, eax, Amplitude)
	invoke Vector3Add, ADDR CamRotL, ADDR v3Val
	ret
Plr_Shake ENDP

Plr_Step PROC EXPORT HalfStep:BPBool
	LOCAL flVal:REAL4
	mov al, HalfStep
	.IF (PlrPlayStep == al)
		not al
		mov PlrPlayStep, al
		
		invoke PlayRandomSnd, ADDR SndStep, 4
		push pax
		fld PlrSpeedScaled
		fmul st, st
		fstp flVal
		invoke alSourcef, eax, AL_GAIN, flVal
		
		invoke flRandRange, f(0.9), f(1.1)
		pop pcx
		invoke alSourcef, ecx, AL_PITCH, eax
	.ENDIF
	ret
Plr_Step ENDP

Plr_Teleport PROC EXPORT X:REAL4, Y:REAL4
	invoke Vector32DSet, ADDR CamPos, X, Y
	invoke Vector32DCopy, ADDR CamPosL, ADDR CamPos
	ret
Plr_Teleport ENDP


Plr_Process PROC EXPORT
	LOCAL flVal:REAL4
	
	invoke Vector3Copy, ADDR CamPosI, ADDR CamPos
	invoke Vector3RoundInt, ADDR CamPosI
	
	; Get forward & right
	fld CamRot.Y
	fsincos
	fst PlrForward.Z
	fchs
	fstp PlrRight.X
	fst PlrForward.X
	fstp PlrRight.Z
	
	; Move & rotate
	.IF (PlrCanControl)
		call Plr_Control
	.ENDIF
	
	call Plr_ProcessState
	
	.IF (Maze)
		invoke Maze_CollideLayout, ADDR CamPos, f(0.7), TRUE
	.ENDIF
	
	; Animation (+ stepping sounds)
	invoke bpProcessAnimPlayer, ADDR CamAnimPlr, deltaTime
	.IF (CamAnimPlr.TrackPtr == OFFSET AnimCamWalk)
		.IF (al)	; Frame changed
			.IF (CamAnimPlr.FrameOffset >= 5 * SIZEOF BPAnimFramePRS)
				invoke Plr_Step, 255
			.ELSE
				invoke Plr_Step, 0
			.ENDIF
		.ENDIF
		
		fld PlrSpeedScaled
		fsqrt
		fmul f(1.5)
		fstp CamAnimPlr.Speed
	.ELSE
		bpMEM32 CamAnimPlr.Speed, f(1)
	.ENDIF
	
	; Sound stuff
	invoke alListenerfv, AL_POSITION, ADDR CamPosL
	invoke alListenerfv, AL_ORIENTATION, ADDR PlrForward
	
	; Health restore
	.IF (PlrState != PLAYER_STATE_STRANGLE)
		fcmp PlrHealth, f(1)
		.IF (Carry?)
			fld deltaTime
			fmul f(0.2)
			fadd PlrHealth
			fstp PlrHealth
		.ELSE
			mov PlrHealth, FLT_1
		.ENDIF
	.ENDIF
	
	; Health affect FOV
	fld PlrHealth
	fmul f(5)
	fadd CamBaseFOV
	fstp CamFOV
	
	; Health affect afterimage
	fld PlrHealth
	.IF (FXAfterimageHighFPS)
		fmul f(3)
	.ELSE
		fmul f(4)
	.ENDIF
	fistp flVal
	mov eax, flVal
	shl pax, BPPtrShift
	mov pcx, FXAfterimageEndFull
	sub pcx, pax
	add pcx, SIZEOF BPPtr
	.IF (!FXAfterimageHighFPS)
		sub pcx, SIZEOF BPPtr*3
	.ENDIF
	mov FXAfterimageEnd, pcx
	
	; Health check (one hundred dollar (because US haha get it))
	.IF (PlrState != PLAYER_STATE_DYING) && (PlrState != PLAYER_STATE_DEAD)
		mov eax, PlrHealth
		.IF (eax & FLT_NEG)
			mov PlrState, PLAYER_STATE_DYING
		.ENDIF
	.ENDIF
	ret
Plr_Process ENDP

Plr_Create PROC EXPORT
	mov CamAnimPlr.Position, OFFSET CamPosA	; Init player animator
	mov CamAnimPlr.Rotation, OFFSET CamRotA
	mov CamAnimPlr.TrackPtr, OFFSET AnimCamWalk
	
	
	mov PlrPartRain.Billboard, PARTICLE_BILLBOARD_Y
	mov PlrPartRain.Count, 256
	invoke Vector2Set, ADDR PlrPartRain.Distance, 0, f(4)
	mov PlrPartRain.Looping, TRUE
	mov PlrPartRain.VelocityAffects, PARTICLE_VELOCITY_POSITION
	invoke Vector2Set, ADDR PlrPartRain.Lifetime, f(0.4), f(0.8)
	mov PlrPartRain.Gravity, TRUE
	invoke Vector2Set, ADDR PlrPartRain.Scale, f(0.01), f(0.03)
	vinvoke Vector3Copy, OFFSET PlrPartRain.Position, OFFSET CamPos
	invoke Particles_Create, ADDR PlrPartRain
	ret
Plr_Create ENDP
