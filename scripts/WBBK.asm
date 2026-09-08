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

.CODE

WBBK_Spawn PROC EXPORT State:BPEnum
	mbm WBBK, State
	
	.IF (WBBK)
		print "Webubychko is "
		print ubyte$(WBBK), 13, 10
		
		bpMEM32 PlrStepPitch, f(0.33333333)
		invoke alSourcef, SndAmbT, AL_PITCH, f(0.2)
		invoke alSourcePlay, SndAmbT
		mov pax, MazeAmb
		invoke alSourceStop, DWORD PTR [pax]
		
		invoke glLightf, GL_LIGHT0, GL_QUADRATIC_ATTENUATION, f(2)
		
		mov MazeState, MAZE_STATE_WBBK
	.ELSE
		mov PlrStepPitch, FLT_1
		invoke alSourcef, SndAmbT, AL_PITCH, FLT_1
		invoke alSourceStop, SndAmbT
		
		invoke glLightf, GL_LIGHT0, GL_QUADRATIC_ATTENUATION, 0
		
		mov MazeState, MAZE_STATE_GAME
	.ENDIF
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
	ret
WBBK_Draw ENDP

WBBK_Process PROC EXPORT
	.IF (WBBK == WBBK_ABSTRACTED)		
		fld WBBKTimer
		fsub deltaTime
		fstp WBBKTimer
		
		.IF (WBBKTimer & FLT_NEG)
			invoke SndSetPos, SndWBBK, ADDR WBBKPos
			.IF (rv(SndPlaying, SndWBBK) != AL_PLAYING)
				invoke alSourcePlay, SndWBBK
				print "WEBUBYCHKO", 13, 10
			.ENDIF
			mov WBBKDist, rv(flMove, WBBKDist, 0, deltaTime)
			.IF !(WBBKDist)
				bpMEM32 WBBKTimer, f(10)
				invoke alSourceStop, SndWBBK
			.ENDIF
		.ELSE
			fld WBBKTimer
			fsin
			fmul f(0.02)
			fadd f(0.3)
			fstp WBBKDist
			.IF (InputMovement.X) || (InputMovement.Y)
				bpMEM32 WBBKTimer, f(10)
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
	ret
WBBK_Process ENDP
