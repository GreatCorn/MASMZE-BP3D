EBD_SEGMENTS	EQU 4

ENUM	\
	EBD_NONE, \
	EBD_ACTIVE, \
	EBD_ATTACK

.DATA
EBD				BPEnum EBD_NONE
EBDAmplitude	REAL4 1.0
EBDAnim			REAL4 0.0, 0.0
EBDAnimSpeed	REAL4 3.0
EBDPos	Vector3 <>

.DATA?
EBDSegmentLength	REAL4 ?

.CODE

EBD_DrawHair PROC EXPORT
	LOCAL v2Val:Vector2
	
	call glPushMatrix
	invoke glRotatef, CamBillboard.Y, 0, FLT_1, 0
	invoke glScalef, f(0.25), FLT_1, FLT_1
	
	mov v2Val.Y, 0
	invoke glBegin, GL_QUADS
	
	push pbx
	xor pbx, pbx
	.WHILE (pbx < EBD_SEGMENTS*2)
		fld EBDAnim
		fadd EBDAnim[4]
		fsin
		fmul v2Val.Y
		fmul EBDAmplitude
		
		.IF !(pbx & 1)
			fadd f(-1)
			fst v2Val.X
			invoke glTexCoord2f, 0, v2Val.Y
			invoke glVertex2f, v2Val.X, v2Val.Y
			fadd f(2)
			fstp v2Val.X
			invoke glTexCoord2f, FLT_1, v2Val.Y
			invoke glVertex2f, v2Val.X, v2Val.Y
		
			fld v2Val.Y
			fsub EBDSegmentLength
			fstp v2Val.Y
			
			fld EBDAnim[4]
			fadd f(0.1)
			fstp EBDAnim[4]
		.ELSE
			fadd f(1)
			fst v2Val.X
			invoke glTexCoord2f, FLT_1, v2Val.Y
			invoke glVertex2f, v2Val.X, v2Val.Y
			fsub f(2)
			fstp v2Val.X
			invoke glTexCoord2f, 0, v2Val.Y
			invoke glVertex2f, v2Val.X, v2Val.Y
		.ENDIF
		
		inc pbx
	.ENDW
	pop pbx
	
	call glEnd
	
	call glPopMatrix
	ret
EBD_DrawHair ENDP

EBD_Spawn PROC EXPORT State:BPEnum
	mbm EBD, State
	
	.IF (State)
		fld1
		fdiv f(%EBD_SEGMENTS)
		fstp EBDSegmentLength
		
		push pbx
		xor pbx, pbx
		.WHILE (pbx < 32)
			invoke Maze_GetRandomPos, ADDR EBDPos, FALSE
			invoke Maze_GetCellF, EBDPos.X, EBDPos.Z
			and al, MAZE_CELL_PROPS
			.IF (al != MAZE_PROP_ARCH) && (al != MAZE_PROP_LAMP)
				invoke Maze_OrCellI, ecx, edx, MAZE_CELL_VISITED
				.BREAK
			.ENDIF
			
			.IF (pbx == 31)
				pop pbx
				mov EBD, FALSE
				ret
			.ENDIF
		.ENDW
		pop pbx
		
		bpMEM32 EBDPos.Y, f(2)
		invoke SndSetPos, SndEBD, ADDR EBDPos
		invoke alSourcePlay, SndEBD
		
		print "Spawned Eblodryn at "
		Vector32DPrint EBDPos
	.ELSE
		invoke alSourceStop, SndEBD
		invoke alSourceStop, SndEBDA
	.ENDIF
	ret
EBD_Spawn ENDP


EBD_Draw PROC EXPORT
	invoke glEnable, GL_BLEND
	invoke glDisable, GL_LIGHTING
	invoke glDisable, GL_FOG
	
	call glPushMatrix
	invoke glTranslate3fv, ADDR EBDPos
	
	invoke glBindTexture, GL_TEXTURE_2D, TexEBDShadow
	invoke glBlendFunc, GL_ZERO, GL_SRC_COLOR
	call glPushMatrix
		invoke glTranslatef, f(-1), f(-2.01), f(-1)
		invoke glCallList, MdlPlaneR
	call glPopMatrix
	
	invoke glDisable, GL_CULL_FACE
	invoke glEnable, GL_ALPHA_TEST
	invoke glBlendFunc, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA
	
	mov EBDAnim[4], 0
	
	invoke glBindTexture, GL_TEXTURE_2D, TexEBD[0]
	invoke glTranslatef, 0, 0, f(0.2)
	call EBD_DrawHair
	invoke glBindTexture, GL_TEXTURE_2D, TexEBD[4]
	invoke glTranslatef, f(-0.2), 0, f(-0.4)
	call EBD_DrawHair
	invoke glBindTexture, GL_TEXTURE_2D, TexEBD[8]
	invoke glTranslatef, f(0.4), 0, 0
	call EBD_DrawHair
	
	invoke glEnable, GL_CULL_FACE
	invoke glDisable, GL_ALPHA_TEST
	
	call glPopMatrix
	
	invoke glDisable, GL_BLEND
	invoke glEnable, GL_LIGHTING
	invoke glEnable, GL_FOG
	ret
EBD_Draw ENDP

EBD_Process PROC EXPORT
	LOCAL dist:REAL4, flVal:REAL4
	
	fld deltaTime
	fmul EBDAnimSpeed
	fadd EBDAnim
	fstp EBDAnim
	
	mov EBD, EBD_ACTIVE
	
	mov dist, rv(GetPlrNearDist, OFFSET EBDPos)
	fcmp dist, f(4)
	.IF (Carry?)
		fld f(6)
		fsub dist
		fmul f(0.5)
		fstp flVal
		mov EBDAmplitude, rv(flLerp, EBDAmplitude, flVal, delta10)
		fld f(7)
		fsub dist
		fstp flVal
		mov EBDAnimSpeed, rv(flLerp, EBDAnimSpeed, flVal, delta10)
	.ELSE
		mov EBDAmplitude, rv(flLerp, EBDAmplitude, FLT_1, deltaTime)
		mov EBDAnimSpeed, rv(flLerp, EBDAnimSpeed, f(3), deltaTime)
	.ENDIF
	
	.IF (NetSock)
		mov dist, rv(Vector32DDistanceSqr, OFFSET EBDPos, OFFSET CamPos)
	.ENDIF
	
	fcmp dist, f(4)
	.IF (Carry?)
		.IF !(GameTips & GAME_TIP_CROUCH)
			vinvoke UI_ShowSubtitles, StrCCCrouch, UISubDur
			or GameTips, GAME_TIP_CROUCH
		.ENDIF
		
		fcmp dist, f(0.6)
		.IF (Carry?)
			fcmp PlrCrouch, f(0.25)
			.IF (Carry?)
				mov EBD, EBD_ATTACK
			.ENDIF
		.ENDIF
	.ENDIF
	
	.IF (EBD == EBD_ATTACK) && (PlrState == PLAYER_STATE_GAME)
		fld PlrHealth
		fsub delta2
		fst PlrHealth
		fsubr f(1)
		fmul f(0.1)
		fstp flVal
		
		invoke Plr_Shake, flVal
		bpMPM UIDeadTipStr, StrTipEBD
			
		.IF (rv(SndPlaying, SndEBDA) != AL_PLAYING)
			invoke alSourcePlay, SndEBDA
		.ENDIF
	.ELSE
		.IF (rv(SndPlaying, SndEBDA) == AL_PLAYING)
			invoke alSourcePause, SndEBDA
		.ENDIF
	.ENDIF
	ret
EBD_Process ENDP
