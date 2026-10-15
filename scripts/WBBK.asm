ENUM \
	WBBK_NONE, \
	WBBK_ABSTRACTED, \
	WBBK_UNABSTRACTED
	
.DATA

WBBK		BPEnum WBBK_NONE
WBBKDist	REAL4 1.0
WBBKPos		Vector3 <>
WBBKRot		REAL4 0.0
WBBKTimer	REAL4 10.0

WBBKGlimpse			DWORD 0
WBBKGlimpsePos		Vector3 <>
WBBKGlimpseRot		REAL4 0.0
WBBKGlimpseTimer	REAL4 4.0, 1.0, 6.0

.CODE

WBBK_Spawn PROC EXPORT State:BPEnum
	.IF (State)
		print "Webubychko is "
		print ubyte$(WBBK), 13, 10
		
		bpMEM32 PlrStepPitch, f(0.33333333)
		invoke alSourcef, SndAmbT, AL_PITCH, f(0.2)
		invoke alSourcePlay, SndAmbT
		mov pax, MazeAmb
		invoke alSourceStop, DWORD PTR [pax]
		
		invoke glLightf, GL_LIGHT0, GL_QUADRATIC_ATTENUATION, f(1)
		
		mov MazeState, MAZE_STATE_WBBK
	.ELSEIF (WBBK)
		mov PlrStepPitch, FLT_1
		invoke alSourcef, SndAmbT, AL_PITCH, FLT_1
		invoke alSourceStop, SndAmbT
		invoke alSourceStop, SndWBBK
		
		invoke glLightf, GL_LIGHT0, GL_QUADRATIC_ATTENUATION, 0
		
		mov MazeState, MAZE_STATE_GAME
	.ENDIF
	mbm WBBK, State
	ret
WBBK_Spawn ENDP


WBBK_Draw PROC EXPORT
	.IF (WBBK == WBBK_ABSTRACTED)
		call glPushMatrix
		invoke glDisable, GL_LIGHTING
		invoke glEnable, GL_BLEND
		invoke glBlendFunc, GL_ONE, GL_ONE
		invoke glTranslatef, WBBKPos.X, f(0.6), WBBKPos.Z
		invoke glRotatefr, WBBKRot, 0, FLT_1, 0
		.IF (WBBKTimer & FLT_NEG)
			invoke glBindTexture, GL_TEXTURE_2D, TexWBBK1
		.ELSE
			invoke glBindTexture, GL_TEXTURE_2D, TexWBBK
		.ENDIF
		invoke glCallList, MdlPlaneC
		invoke glEnable, GL_LIGHTING
		call glPopMatrix
	.ELSE
		
	.ENDIF
	
	.IF (WBBKGlimpse)
		call glPushMatrix
		invoke glDisable, GL_LIGHTING
		invoke glEnable, GL_BLEND
		invoke glBlendFunc, GL_ONE, GL_ONE
		invoke glTranslate3fv, ADDR WBBKGlimpsePos
		invoke glRotatefr, WBBKGlimpseRot, 0, FLT_1, 0
		invoke glBindTexture, GL_TEXTURE_2D, WBBKGlimpse
		invoke glCallList, MdlPlaneC
		invoke glEnable, GL_LIGHTING
		call glPopMatrix
	.ENDIF
	ret
WBBK_Draw ENDP

WBBK_Process PROC EXPORT
	LOCAL v3Val:Vector3
	
	.IF (WBBK == WBBK_ABSTRACTED)
		.IF (PlrState == PLAYER_STATE_GAME)
			fld WBBKTimer
			fsub deltaTime
			fstp WBBKTimer
		.ENDIF
		
		.IF (WBBKTimer & FLT_NEG)
			invoke SndSetPos, SndWBBK, ADDR WBBKPos
			.IF (rv(SndPlaying, SndWBBK) != AL_PLAYING)
				invoke alSourcePlay, SndWBBK
				print "WEBUBYCHKO", 13, 10
			.ENDIF
			mov WBBKDist, rv(flMove, WBBKDist, 0, deltaTime)
			.IF !(WBBKDist)
				bpMEM32 WBBKTimer, f(20)
				invoke alSourceStop, SndWBBK
			.ENDIF
		.ELSE
			fld WBBKTimer
			fcos
			fmul f(0.05)
			fadd f(0.25)
			fstp WBBKDist
			.IF (InputMovement.X) || (InputMovement.Y)
				bpMEM32 WBBKTimer, f(11.5)
			.ENDIF
		.ENDIF
		
		mov WBBKRot, rv(flLerpAngle, WBBKRot, CamRot.Y, delta2)
		fld WBBKRot
		fsincos
		fmul FogEndDist
		fmul WBBKDist
		fadd CamPos.Z
		fstp WBBKPos.Z
		fmul FogEndDist
		fmul WBBKDist
		fadd CamPos.X
		fstp WBBKPos.X
	.ELSE
	
	.ENDIF
	
	fld MazeNoiseTimer
	fsub deltaTime
	fstp MazeNoiseTimer
	
	.IF (MazeNoiseTimer & FLT_NEG)
		mov MazeNoiseTimer, \
		rv(flRandRange, MazeNoiseTimer[4], MazeNoiseTimer[8])
		fld MazeNoiseTimer
		fmul f(0.5)
		fstp MazeNoiseTimer
		
		mov v3Val.X, rv(flRandRange, f(-4), f(4))
		mov v3Val.Z, rv(flRandRange, f(-4), f(4))
		vinvoke Vector32DAdd, ADDR v3Val, OFFSET CamPos
		invoke PlayRandomSnd, ADDR SndAmbW, (SIZEOF SndAmbW)/4
		mov pcx, pax
		invoke SndSetPos, DWORD PTR [pcx], ADDR v3Val
	.ENDIF
	
	.IF (WBBKGlimpse)
		mov WBBKGlimpseRot, \
		rv(Vector32DAngle, OFFSET CamPos, OFFSET WBBKGlimpsePos)
	
		.IF (rv(Maze_PlrVisible, OFFSET WBBKGlimpsePos))
			fld WBBKGlimpseTimer
			fsub deltaTime
			fstp WBBKGlimpseTimer
			
			.IF (WBBKGlimpseTimer & FLT_NEG)
				mov WBBKGlimpse, 0
				mov WBBKGlimpseTimer, \
				rv(flRandRange, WBBKGlimpseTimer[4], WBBKGlimpseTimer[8])
				
				.IF !(rv(nRand, 5))
					.IF (rv(SndPlaying, SndGlimpse) != AL_PLAYING)
						invoke alSourcef, AL_PITCH, SndGlimpse, \
						rv(flRandRange, f(0.8), f(1.2))
						invoke SndSetPos, SndGlimpse, ADDR WBBKGlimpsePos
						invoke alSourcePlay, SndGlimpse
					.ENDIF
				.ENDIF
			.ENDIF
		.ENDIF
		
		mov v3Val.X,rv(Vector32DDistanceSqr,OFFSET WBBKGlimpsePos,OFFSET CamPos)
		
		fcmp v3Val.X, f(24)
		.IF (!Carry?)
			mov WBBKGlimpse, 0
		.ENDIF
		
	.ELSE
		fld WBBKGlimpseTimer
		fsub deltaTime
		fstp WBBKGlimpseTimer
		
		.IF (WBBKGlimpseTimer & FLT_NEG)
			invoke nRand, SIZEOF TexGlimpse/4
			shl pax, 2
			bpMEM32 WBBKGlimpse, TexGlimpse[pax]
			bpMEM32 WBBKGlimpseTimer, f(0.5)
			
			mov WBBKGlimpsePos.Y, rv(flRandRange, f(0.4), f(0.7))
			
			push pbx
			xor pbx, pbx
			.REPEAT
				mov WBBKGlimpsePos.X, rv(flRandRange, f(-4), f(4))
				mov WBBKGlimpsePos.Z, rv(flRandRange, f(-4), f(4))
				invoke Vector32DAdd, ADDR WBBKGlimpsePos, ADDR CamPos
				
				inc pbx
				.IF (pbx > 20)
					mov WBBKGlimpse, 0
					mov WBBKGlimpseTimer, \
					rv(flRandRange, WBBKGlimpseTimer[4], WBBKGlimpseTimer[8])
					print "Failed to spawn WBBK glimpse", 13, 10
					.BREAK
				.ENDIF
				
				invoke Maze_PlrVisible, OFFSET WBBKGlimpsePos
			.UNTIL !(eax)
			pop pbx
			
			print "Spawned glimpse at "
			Vector32DPrint WBBKGlimpsePos
			;mov WBBKGlimpseTimer, \
			;rv(flRandRange, WBBKGlimpseTimer[4], WBBKGlimpseTimer[8])
		.ENDIF
	.ENDIF
	ret
WBBK_Process ENDP
