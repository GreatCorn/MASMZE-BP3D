ENUM	WMBLYK_NONE, \
		WMBLYK_STILL, \
		WMBLYK_STILL_SCARE, \
		WMBLYK_JUMPSCARE, \
		WMBLYK_STEALTH_WAIT, \
		WMBLYK_STEALTH_APPEAR, \
		WMBLYK_WALK, \
		WMBLYK_STRANGLE, \
		WMBLYK_DEAD

.DATA
Wmblyk			BPEnum WMBLYK_NONE
WmblykAnimPlr	BPAnimPlayer <>
WmblykHeadRot	Vector2 <>
WmblykPos		Vector3 <>
WmblykRot		REAL4 0.0	; Wmblyk rotation
WmblykStateVal	REAL4 0.0

.DATA?

.CODE
Wmblyk_Spawn PROC EXPORT State:BPEnum
	print "Spawned Wmblyk: "
	.IF (State == WMBLYK_STILL)
		invoke Maze_GetRandomPos, ADDR WmblykPos
		
		print "still, at "
		Vector3Print WmblykPos
	.ELSEIF (State == WMBLYK_STEALTH_WAIT)
		print "stealthy", 13, 10
		mov WmblykStateVal, rv(flRandRange, f(4), f(11))
	.ENDIF
	mbm Wmblyk, State
	ret
Wmblyk_Spawn ENDP


Wmblyk_Draw PROC EXPORT
	LOCAL flVal:REAL4
	
	invoke glDisable, GL_FOG
	invoke glDisable, GL_LIGHTING
	
	call glPushMatrix
	invoke glTranslate3fv, ADDR WmblykPos
	invoke glRotatefr, WmblykRot, 0, f(1), 0
	.IF (Wmblyk == WMBLYK_STILL) || (Wmblyk == WMBLYK_STILL_SCARE) \
	|| (Wmblyk == WMBLYK_STEALTH_APPEAR)
		.IF (Wmblyk == WMBLYK_STEALTH_APPEAR)
			invoke glEnable, GL_BLEND
			invoke glBlendFunc, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA
			invoke glColor4f, f(1), f(1), f(1), WmblykStateVal
		.ENDIF
		
		invoke glBindTexture, GL_TEXTURE_2D, TexWmblykNeutral
		
		.IF (Wmblyk == WMBLYK_STILL_SCARE)
			invoke glCallList, MdlWmblykBodyG
		.ELSE
			invoke glCallList, MdlWmblykBody
		.ENDIF
		
		invoke glTranslatef, 0, f(1.56), 0
		invoke glRotate2fvr, ADDR WmblykHeadRot
		
		invoke glCallList, MdlWmblykHead
		.IF (Wmblyk == WMBLYK_STEALTH_APPEAR)
			invoke glDisable, GL_BLEND
		.ENDIF
	.ENDIF
	call glPopMatrix
	
	invoke glEnable, GL_FOG
	invoke glEnable, GL_LIGHTING
	ret
Wmblyk_Draw ENDP

Wmblyk_Process PROC EXPORT
	LOCAL flVal:REAL4
	wmblykRotateHead MACRO
		invoke Vector32DDistanceSqr, ADDR CamPos, ADDR WmblykPos
		fst flVal
		
		fadd f(2)
		fdivr f(1)
		fmul PIHalfN
		
		fld CamHeight
		fsub CamPosL.Y
		fmul f(0.6)
		fsubr
		fstp WmblykHeadRot.X
		
		fld WmblykHeadRot.Y
		fsub WmblykRot
		fstp WmblykHeadRot.Y
	ENDM
	wmblykSpawnBehind MACRO
		invoke Vector32DCopy, ADDR WmblykPos, ADDR PlrForward
		invoke Vector32DMulF, ADDR WmblykPos, f(-0.75)
		invoke Vector32DAdd, ADDR WmblykPos, ADDR CamPos
	ENDM
		
	
	.IF (Wmblyk == WMBLYK_STILL) || (Wmblyk == WMBLYK_STILL_SCARE)
		invoke Vector32DAngle, ADDR WmblykPos, ADDR CamPosL
		mov WmblykHeadRot.Y, eax
		.IF (Wmblyk == WMBLYK_STILL)
			mov ecx, delta2
		.ELSE
			mov ecx, delta20
		.ENDIF
		mov WmblykRot, rv(flLerpAngle, WmblykRot, eax, ecx)
		
		wmblykRotateHead
				
		fcmp flVal, f(0.2)
		.IF (Carry?)
			mov Wmblyk, WMBLYK_JUMPSCARE
			mov WmblykStateVal, FLT_1
			invoke alSourcePlay, SndWmblyk
		.ELSE
			fcmp flVal, f(0.65)
			.IF (Carry?)
				mov Wmblyk, WMBLYK_STILL_SCARE
				fld deltaTime
				fmul f(6)
				fstp flVal
				
				fld WmblykRot
				fsincos
				fmul f(6)
				fmul deltaTime
				fadd WmblykPos.Z
				fstp WmblykPos.Z
				fmul f(6)
				fmul deltaTime
				fadd WmblykPos.X
				fstp WmblykPos.X
			.ELSE
				mov Wmblyk, WMBLYK_STILL
			.ENDIF
		.ENDIF
	.ELSEIF (Wmblyk == WMBLYK_JUMPSCARE)
		mov WmblykStateVal, rv(flLerp, WmblykStateVal, f(-0.1), deltaTime)
		fld WmblykStateVal
		fmul st, st
		fmul f(0.2)
		fstp flVal
		
		invoke Plr_Shake, flVal
		
		fcmp WmblykStateVal
		.IF (Carry?)
			invoke nRand, 2
			.IF (al)
				mov Wmblyk, WMBLYK_NONE
			.ELSE
				invoke Wmblyk_Spawn, WMBLYK_STEALTH_WAIT
			.ENDIF
			mov WmblykStateVal, 0
		.ENDIF
	.ELSEIF (Wmblyk == WMBLYK_STEALTH_WAIT)
		fld WmblykStateVal
		fsub deltaTime
		fstp WmblykStateVal
		
		fcmp WmblykStateVal
		.IF (Carry?)
			wmblykSpawnBehind
			
			mov WmblykStateVal, FLT_1
			mov Wmblyk, WMBLYK_STEALTH_APPEAR
			
			print "Wmblyk appeared", 13, 10
		.ENDIF
	.ELSEIF (Wmblyk == WMBLYK_STEALTH_APPEAR)
		mov WmblykRot, rv(Vector32DAngle, OFFSET WmblykPos, OFFSET CamPosL)
		mov WmblykHeadRot.Y, eax
		
		wmblykRotateHead
		
		.IF (WmblykStateVal == FLT_1)
			fcmp flVal, f(1.2)
			.IF (!Carry?)
				wmblykSpawnBehind
			.ELSE
				fcmp flVal, f(0.4)
				.IF (Carry?)
					wmblykSpawnBehind
				.ENDIF
			.ENDIF
			mov flVal, rv(Plr_FrustumDot, ADDR WmblykPos)
			fcmp flVal, f(0.3)
			.IF (!Carry?)
				bpMEM32 WmblykStateVal, f(0.96)
			.ENDIF
			fcmp CamRotL.X, f(0.6)
			.IF (!Carry?)
				bpMEM32 WmblykStateVal, f(0.96)
			.ENDIF
		.ELSE
			fld deltaTime
			fmul f(5)
			fstp flVal
			mov WmblykStateVal, rv(flLerp, WmblykStateVal, f(-0.1), flVal)
			fcmp WmblykStateVal
			.IF (Carry?)
				invoke Wmblyk_Spawn, WMBLYK_STEALTH_WAIT
			.ENDIF
		.ENDIF
	.ENDIF
	ret
Wmblyk_Process ENDP
