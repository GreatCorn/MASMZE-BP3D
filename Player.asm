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
CamHeight	REAL4 1.2
	
.DATA
CamPos			Vector3 <0.0, 0.0, 0.0>
CamPosL			Vector3 <0.0, 0.0, 0.0>
CamRot			Vector3 <0.0, 0.0, 0.0>
CamRotL			Vector3 <0.0, 0.0, 0.0>
CamStep			REAL4 0.0, 0.0
PlrCanControl	BPBool FALSE
PlrSpeed		REAL4 0.0
PlrState		DWORD PLAYER_GAME

.CODE

Plr_ProcessState PROC EXPORT
	LOCAL fltVal:REAL4
	
	SWITCH PlrState
		CASE PLAYER_ENTER
			invoke Vector3Set, ADDR CamRot, f(0.3), PI, 0
			invoke Vector3Copy, ADDR CamRotL, ADDR CamRot
			invoke Vector3Set, ADDR CamPos, f(1), CamHeight, f(0.2)
			invoke Vector3Copy, ADDR CamPosL, ADDR CamPos
			
			invoke Vector2Set, ADDR CamStep, 0, 0
					
			mov MazeDoorRot, 0
			
			mov UIFade, UIFADE_IN
			mov UIFadeCallback, 0
			m2m UIFadeVal, f(1)
			
			mov PlrState, PLAYER_ENTERING
			ret
		CASE PLAYER_ENTERING
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
		CASE PLAYER_EXIT_DOOR
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
				.IF ((MazeState == MAZE_GAME) || (Glyphs == 7))
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
				
				mov UIFade, UIFADE_OUT
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
	ENDSW
	ret
Plr_ProcessState ENDP
