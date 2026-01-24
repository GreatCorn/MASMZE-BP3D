ENUML
	E PLAYER_GAME
	E PLAYER_ENTER
	E PLAYER_EXIT
	E PLAYER_EXITING
	
	; Wmblyk strangle minigame
	E PLAYER_STRANGLE
	E PLAYER_STRANGLING
	E PLAYER_GETUP
	
	E PLAYER_DYING
	E PLAYER_DEAD
	
	; Intro-related
	E PLAYER_INTRO_DARK
	E PLAYER_INTRO_CITY
	E PLAYER_INTRO_TEXT1
	E PLAYER_INTRO_OUTSKIRTS
	E PLAYER_INTRO_TEXT2
	E PLAYER_INTRO_WOODS
	E PLAYER_INTRO_TEXT3
	
	E PLAYER_STOP
	E PLAYER_ETC
	
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
PlrRight		Vector3 <>
PlrSpeed		REAL4 0.0	; Current absolute player speed
PlrSpeedScaled	REAL4 0.0	; Current scaled player speed (0.0 - PlrSpeedWalk)

CamAnimPlr		BPAnimPlayer <>
CamPosA			Vector3 <>
CamRotA			Vector3 <>

CamLightPos		Vector4 <0.0, 0.0, 0.0, 1.0>
CamFOV			REAL4 70.0
PlrGlyphs		DWORD 7
PlrHealth		REAL4 1.0
PlrPlayStep		BPBool FALSE
PlrState		DWORD PLAYER_ENTER

.CODE
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
		fadd CamRot.Y
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
	ret
Plr_Control ENDP

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
	
	
	invoke Vector32DDistanceSqr, ADDR CamPos, ADDR CamPosP
	fsqrt
	fdiv deltaTime
	fst PlrSpeed
	fdiv PlrSpeedWalk
	fstp PlrSpeedScaled
	invoke Vector32DCopy, ADDR CamPosP, ADDR CamPos
	ret
Plr_LateProcess ENDP

Plr_ProcessState PROC EXPORT
	LOCAL flVal:REAL4, v3Val:Vector3
	
	.IF (PlrState == PLAYER_ENTER)		
		mov CamAnimPlr.Interpolation, BP_INTERPOLATE_CONSTANT
		invoke bpAnimPlay, ADDR CamAnimPlr, ADDR AnimCamEnter
		invoke bpProcessAnimPlayer, ADDR CamAnimPlr, 0
		mov CamAnimPlr.Interpolation, BP_INTERPOLATE_LINEAR
		
		invoke Vector3Set, ADDR CamRot, 0, PI, 0
		invoke Vector3Copy, ADDR v3Val, ADDR CamRotA
		invoke Vector3Add, ADDR v3Val, ADDR CamRot
		invoke Vector3Copy, ADDR CamRotL, ADDR v3Val
		invoke Vector3Set, ADDR CamPos, f(1), CamHeight, f(1)
		invoke Vector3Copy, ADDR v3Val, ADDR CamPosA
		invoke Vector3Add, ADDR v3Val, ADDR CamPos
		invoke Vector3Copy, ADDR CamPosL, ADDR v3Val
		
		mov PlrCanControl, FALSE
				
		mov MazeDoorRot, 0
		
		mov UIFade, UI_FADE_IN
		mov UIFadeCallback, OFFSET plrEnterFade
		bpMEM32 UIFadeVal, f(1)
		
		mov PlrState, PLAYER_ETC
		ret
	.ELSEIF (PlrState == PLAYER_EXIT)
		invoke bpAnimPlay, ADDR CamAnimPlr, ADDR AnimCamExit
		
		mov PlrCanControl, FALSE
		
		mov UIFade, UI_FADE_NONE
		
		mov PlrState, PLAYER_EXITING
		
		invoke alSourcePlay, SndExit
		ret
	.ELSEIF (PlrState == PLAYER_EXITING)
		mov MazeDoorRot, rv(flLerp, MazeDoorRot, f(-100), delta2)
		invoke Vector3Lerp, ADDR CamPos, ADDR MazeDoorPos, delta2
		mov CamRot.X, rv(flLerp, CamRot.X, 0, delta2)
		mov CamRot.Y, rv(flLerpAngle, CamRot.Y, PI, delta2)
		fcmp CamAnimPlr.Timer, f(40)
		.IF (!Carry?) && !(UIFade)
			mov UIFade, UI_FADE_OUT
			mov UIFadeCallback, OFFSET plrExitFade
			mov UIFadeVal, 0
		.ENDIF
	.ENDIF
	ret
	
	plrEnterFade:
		invoke bpAnimPlay, ADDR CamAnimPlr, ADDR AnimCamWalk
		mov PlrCanControl, TRUE
		mov PlrState, PLAYER_GAME
		ret
	plrExitFade:
		mov PlrState, PLAYER_ENTER
		call Maze_Progress
		ret
Plr_ProcessState ENDP

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
	fst PlrRight.X
	fchs
	fstp PlrForward.Z
	fst PlrForward.X
	fstp PlrRight.Z
	
	.IF (PlrCanControl)
		call Plr_Control
	.ENDIF
	
	invoke bpProcessAnimPlayer, ADDR CamAnimPlr, deltaTime
	.IF (CamAnimPlr.TrackPtr == OFFSET AnimCamWalk)
		.IF (al)	; Frame changed
			.IF (CamAnimPlr.FrameOffset >= 6 * SIZEOF BPAnimFramePRS)
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
	
	call Plr_ProcessState
	
	; Health that affects afterimage
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
	ret
Plr_Process ENDP

Plr_Create PROC EXPORT
	mov CamAnimPlr.Position, OFFSET CamPosA	; Init player animator
	mov CamAnimPlr.Rotation, OFFSET CamRotA
	mov CamAnimPlr.TrackPtr, OFFSET AnimCamWalk
	ret
Plr_Create ENDP
