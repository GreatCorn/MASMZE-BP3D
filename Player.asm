ENUML
	E PLAYER_GAME
	E PLAYER_ENTER
	E PLAYER_ENTERING
	E PLAYER_EXIT_DOOR
	E PLAYER_EXITING
	E PLAYER_EXIT_WAIT
	
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
PlrCrouchSpeed	REAL4 2.6
PlrWalkSpeed	REAL4 3.6
	
.DATA
; Movement and transformation
CamPos			Vector3 <>	; Real camera position
CamPosI			Vector3 <>	; Real rounded (FPU_ROUND_ROUND) position
CamPosL			Vector3 <>	; Displayed (lerped) camera position
CamRot			Vector3 <>
CamRotL			Vector3 <>
CamRotSmooth	REAL4 16.0
CamStep			REAL4 0.0, 0.0
PlrCanControl	BPBool TRUE
PlrCrouch		REAL4 0.0
PlrForward		Vector3 <>
PlrRight		Vector3 <>
PlrSpeed		REAL4 0.0	; Current plr speed

CamLightPos		Vector4 <0.0, 0.0, 0.0, 1.0>
CamFOV			REAL4 70.0
PlrGlyphs		DWORD 7
PlrHealth		REAL4 1.0
PlrState		DWORD PLAYER_GAME

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
		bpMEM32 movSpd, PlrCrouchSpeed
	.ELSE
		bpMEM32 movSpd, PlrWalkSpeed
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

Plr_ProcessState PROC EXPORT
	LOCAL fltVal:REAL4
	
	.IF (PlrState == PLAYER_ENTER)
		invoke Vector3Set, ADDR CamRot, f(0.3), PI, 0
		invoke Vector3Copy, ADDR CamRotL, ADDR CamRot
		invoke Vector3Set, ADDR CamPos, f(1), CamHeight, f(0.2)
		invoke Vector3Copy, ADDR CamPosL, ADDR CamPos
		
		invoke Vector2Set, ADDR CamStep, 0, 0
				
		mov MazeDoorRot, 0
		
		mov UIFade, UI_FADE_IN
		mov UIFadeCallback, 0
		bpMEM32 UIFadeVal, f(1)
		
		mov PlrState, PLAYER_ENTERING
		ret
	.ELSEIF (PlrState == PLAYER_ENTERING)
		mov CamRot.X, rv(flLerp, CamRot.X, 0, delta2)
		mov CamPos.Z, rv(flLerp, CamPos.Z, f(1.1), delta2)
		
		fcmp CamPos.Z, f(1)
		.IF (!Carry?)
			.IF (MazeState != MAZE_CROA)
				mov PlrCanControl, TRUE
				mov PlrState, PLAYER_GAME
			.ELSE
				mov PlrState, PLAYER_STOP
			.ENDIF
		.ENDIF
		ret
	.ELSEIF (PlrState == PLAYER_EXIT_DOOR)
		mov PlrCanControl, 0
		
		.IF (MazeLevel == 63)
			mov CamRot.X, rv(flLerp, CamRot.X, 0, delta2)
		.ELSEIF (MazeState == MAZE_ENDING)
			mov CamRot.X, rv(flLerp, CamRot.X, f(-0.33), delta2)
		.ELSE
			mov CamRot.X, rv(flLerp, CamRot.X, f(0.33), delta2)
		.ENDIF
		mov CamRot.Y, rv(flLerpAngle, CamRot.Y, PI, delta2)
		
		.IF (Kubale != KUBALE_ACTIVE)
			mov Kubale, KUBALE_INACTIVE
		.ENDIF
		
		invoke Vector32DLerp, ADDR CamPos, ADDR MazeDoorPos, delta2
		
		.IF (MazeCheck)
			.IF ((MazeState == MAZE_GAME) || (PlrGlyphs == 7))
				invoke alGetSourcef, SndMus[8], AL_GAIN, ADDR fltVal
				mov fltVal, rv(flLerp, fltVal, 0, delta2)
				invoke alSourcef, SndMus[8], AL_GAIN, fltVal
				mov MazeCheckDoorRot, \
				rv(flLerp, MazeCheckDoorRot, (-100), delta2)
				push MazeCheckDoorRot
			.ELSE
				mov MazeDoorRot, rv(flLerp, MazeDoorRot, (-100), delta2)
				push MazeDoorRot
			.ENDIF
		.ELSE
			mov MazeDoorRot, rv(flLerp, MazeDoorRot, (-100), delta2)
			push MazeDoorRot
		.ENDIF
		
		fcmp REAL4 PTR [psp], f(-90)
		add psp, 4
		.IF (Carry?)
			fld MazeDoorPos.Z
			fadd f(2)
			fstp MazeDoorPos.Z
			
			mov UIFade, UI_FADE_OUT
			mov UIFadeVal, 0
			
			mov PlrState, PLAYER_EXITING
			.IF (MazeCheck)
				.IF (MazeState == MAZE_GAME)
					invoke alSourcePlay, SndAmb
				.ENDIF
				invoke alSourceStop, SndMus[8]
			.ENDIF
		.ENDIF
		ret
	.ENDIF
	ret
Plr_ProcessState ENDP

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
	
	fld deltaTime
	fmul CamRotSmooth
	fstp flVal
	invoke Vector3LerpAngle, ADDR CamRotL, ADDR CamRot, flVal
	invoke Vector3LerpAngle, ADDR CamPosL, ADDR CamPos, delta10
	
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
