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
WmblykCell		BPPtr (-1)
WmblykCellPos	Vector3 <>
WmblykHeadRot	Vector2 <>
WmblykPos		Vector3 <>
WmblykRot		REAL4 0.0	; Wmblyk rotation
WmblykStateVal	REAL4 0.0
WmblykSpeed		REAL4 3.8

.DATA?

.CODE
Wmblyk_Spawn PROC EXPORT State:BPEnum
	IFDEF MODE_DEBUG
	.IF (State != WMBLYK_NONE)
		print "Spawned Wmblyk: "
	.ENDIF
	ENDIF
	.IF (State == WMBLYK_NONE)
		invoke alSourceStop, SndWmblykB
	.ELSEIF (State == WMBLYK_STILL)
		invoke Maze_GetRandomPos, ADDR WmblykPos
		
		print "still, at "
		Vector3Print WmblykPos
	.ELSEIF (State == WMBLYK_STEALTH_WAIT)
		mov WmblykStateVal, rv(flRandRange, f(4), f(11))
		
		print "stealthy", 13, 10
	.ELSEIF (State == WMBLYK_WALK)
		mov WmblykCell, -1
		invoke Maze_GetRandomPos, ADDR WmblykPos
		mov WmblykStateVal, rv(intRandRange, -2, 2)
		fild WmblykStateVal
		fmul PIHalf
		fstp WmblykStateVal
		
		mov WmblykAnimPlr.FrameType, BPA_FRAME_VERTEX	; Init animator
		mov WmblykAnimPlr.Mesh, OFFSET MeshWmblyk
		mov WmblykAnimPlr.MeshUseNormals, FALSE
		invoke bpAnimPlay, ADDR WmblykAnimPlr, ADDR AnimWmblykWalk
		
		invoke alSourcePlay, SndWmblykB
		
		print "walking", 13, 10
		Vector3Print WmblykPos
	.ENDIF
	mbm Wmblyk, State
	ret
Wmblyk_Spawn ENDP


Wmblyk_Draw PROC EXPORT
	LOCAL flVal:REAL4
	
	.IF (Wmblyk != WMBLYK_NONE) && (Wmblyk != WMBLYK_JUMPSCARE) \
	&& (Wmblyk != WMBLYK_STEALTH_WAIT)
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
			
			.IF (Wmblyk == WMBLYK_STILL)
				.IF (WmblykStateVal & FLT_NEG)
					invoke glColor4fv, ADDR clBlack
				.ENDIF
			.ENDIF
			
			call glPushMatrix
			invoke glTranslatef, 0, f(1.56), 0
			invoke glRotate2fvr, ADDR WmblykHeadRot
			
			invoke glCallList, MdlWmblykHead
			call glPopMatrix
			.IF (Wmblyk == WMBLYK_STEALTH_APPEAR)
				invoke glDisable, GL_BLEND
			.ENDIF
		.ELSEIF (Wmblyk >= WMBLYK_WALK)
			.IF (Wmblyk == WMBLYK_DEAD)
				invoke glColor4fv, ADDR clBlack
			.ENDIF
			invoke glBindTexture, GL_TEXTURE_2D, TexWmblykNeutral
			
			invoke bpDrawMesh, ADDR MeshWmblyk
		.ENDIF
		invoke glColor4fv, ADDR clWhite
		.IF (Wmblyk != WMBLYK_STEALTH_APPEAR)
			invoke glEnable, GL_BLEND
			invoke glTranslatef, f(-1), f(0.01), f(-1)
			invoke glBlendFunc, GL_DST_COLOR, GL_ZERO
			invoke glBindTexture, GL_TEXTURE_2D, TexShadow
			invoke glCallList, MdlPlane
			invoke glDisable, GL_BLEND
		.ENDIF
		
		call glPopMatrix
		
		invoke glEnable, GL_FOG
		invoke glEnable, GL_LIGHTING
	.ENDIF
	ret
Wmblyk_Draw ENDP

Wmblyk_Process PROC EXPORT
	LOCAL flVal:REAL4, v3Val:Vector3, ways:BYTE
	LOCAL cellFwd:BPPtr, cellLeft:BPPtr, cellRight:BPPtr
	wmblykRotateHead MACRO
		mov flVal, rv(Vector32DDistanceSqr, OFFSET CamPos, OFFSET WmblykPos)
		
		fld flVal
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
		; StateVal is blink timer (< 0 - blink)
		invoke Vector32DAngle, ADDR WmblykPos, ADDR CamPosL
		mov WmblykHeadRot.Y, eax
		.IF (Wmblyk == WMBLYK_STILL)
			mov ecx, delta2
		.ELSE
			mov ecx, delta20
		.ENDIF
		mov WmblykRot, rv(flLerpAngle, WmblykRot, eax, ecx)
		
		fld WmblykStateVal
		fsub deltaTime
		fstp WmblykStateVal
		fcmp WmblykStateVal, f(-0.1)
		.IF (Carry?)
			mov WmblykStateVal, rv(flRandRange, f(0.4), f(5))
		.ENDIF
		
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
				
				invoke Vector32DMove, ADDR WmblykPos, ADDR CamPos, flVal
			.ELSE
				mov Wmblyk, WMBLYK_STILL
			.ENDIF
		.ENDIF
	.ELSEIF (Wmblyk == WMBLYK_JUMPSCARE)
		; StateVal is jumpscare alpha and shake amount
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
		; StateVal is timer to appear
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
		; StateVal is Wmblyk alpha (< 1.0 triggers fade)
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
	.ELSEIF (Wmblyk == WMBLYK_WALK)
		; StateVal is functional rotation
		mov WmblykStateVal, rv(flAngle, WmblykStateVal)
		mov WmblykRot, rv(flLerpAngle, WmblykRot, WmblykStateVal, delta10)
		mov WmblykRot, rv(flAngle, WmblykRot)	; ?
		
		invoke SndSetPos, SndWmblykB, ADDR WmblykPos
		
		fld deltaTime
		fmul WmblykSpeed
		fstp v3Val.Y	; Y unused, keep delta speed here
		
		fld WmblykStateVal
		fsincos
		fist v3Val.Z
		fmul v3Val.Y
		fadd WmblykPos.Z
		fstp WmblykPos.Z
		fist v3Val.X
		fmul v3Val.Y
		fadd WmblykPos.X
		fstp WmblykPos.X
			
		invoke Maze_GetCellOffsetF, WmblykPos.X, WmblykPos.Z
		push pax
		sal ecx, 1
		inc ecx
		sal edx, 1
		inc edx
		mov WmblykCellPos.X, ecx
		mov WmblykCellPos.Z, edx
		invoke Vector32DF, ADDR WmblykCellPos
		; Line him up with the center of the cell
		.IF (DWORD PTR v3Val.X)	; Horizontal movement
			mov WmblykPos.Z, rv(flMove, WmblykPos.Z, WmblykCellPos.Z, v3Val.Y)
		.ELSE	; Vertical movement
			mov WmblykPos.X, rv(flMove, WmblykPos.X, WmblykCellPos.X, v3Val.Y)
		.ENDIF
		pop pax
		.IF (pax != WmblykCell)
			push pax
			
			mov flVal, \
			rv(Vector32DDistanceSqr, OFFSET WmblykPos, ADDR WmblykCellPos)
			fcmp flVal, v3Val.Y
			.IF (Carry?)
				pop WmblykCell
				;invoke Vector32DCopy, ADDR WmblykPos, ADDR WmblykCellPos
				
				; Choose where to go
				invoke Vector32DRoundInt, ADDR WmblykCellPos
				sar WmblykCellPos.X, 1
				sar WmblykCellPos.Z, 1
				
				WMBLYK_FORWARD	EQU 001b
				WMBLYK_LEFT		EQU 010b
				WMBLYK_RIGHT	EQU 100b
				mov ways, 0
				; I hope you like-a spaghetti, special for you
				.IF (SDWORD PTR v3Val.X == 1)		; Going right
					mov eax, WmblykCellPos.X
					inc eax
					invoke Maze_GetCellI, eax, WmblykCellPos.Z
					.IF (al & MAZE_CELL_PASSLEFT)
						or ways, WMBLYK_FORWARD
						mov cellFwd, pcx
					.ENDIF
					mov eax, WmblykCellPos.Z
					inc eax
					invoke Maze_GetCellI, WmblykCellPos.X, eax
					.IF (al & MAZE_CELL_PASSTOP)	; right (down)
						or ways, WMBLYK_RIGHT
						mov cellRight, pcx
					.ENDIF
					invoke Maze_GetCellI, WmblykCellPos.X, WmblykCellPos.Z
					.IF (al & MAZE_CELL_PASSTOP)	; left (up)
						or ways, WMBLYK_LEFT
						mov cellLeft, pcx
					.ENDIF
				.ELSEIF (SDWORD PTR v3Val.Z == 1)	; Going down
					mov eax, WmblykCellPos.Z
					inc eax
					invoke Maze_GetCellI, WmblykCellPos.X, eax
					.IF (al & MAZE_CELL_PASSTOP)
						or ways, WMBLYK_FORWARD
						mov cellFwd, pcx
					.ENDIF
					invoke Maze_GetCellI, WmblykCellPos.X, WmblykCellPos.Z
					.IF (al & MAZE_CELL_PASSLEFT)	; right (left)
						or ways, WMBLYK_RIGHT
						mov cellRight, pcx
					.ENDIF
					mov eax, WmblykCellPos.X
					inc eax
					invoke Maze_GetCellI, eax, WmblykCellPos.Z
					.IF (al & MAZE_CELL_PASSLEFT)	; left (right)
						or ways, WMBLYK_LEFT
						mov cellLeft, pcx
					.ENDIF
				.ELSEIF (SDWORD PTR v3Val.X == -1)	; Going left
					invoke Maze_GetCellI, WmblykCellPos.X, WmblykCellPos.Z
					.IF (al & MAZE_CELL_PASSLEFT)
						or ways, WMBLYK_FORWARD
						mov cellFwd, pcx
					.ENDIF
					.IF (al & MAZE_CELL_PASSTOP)	; right (up)
						or ways, WMBLYK_RIGHT
						mov cellRight, pcx
					.ENDIF
					mov eax, WmblykCellPos.Z
					inc eax
					invoke Maze_GetCellI, WmblykCellPos.X, eax
					.IF (al & MAZE_CELL_PASSTOP)	; left (down)
						or ways, WMBLYK_LEFT
						mov cellLeft, pcx
					.ENDIF
				.ELSEIF (SDWORD PTR v3Val.Z == -1)	; Going up
					invoke Maze_GetCellI, WmblykCellPos.X, WmblykCellPos.Z
					.IF (al & MAZE_CELL_PASSTOP)
						or ways, WMBLYK_FORWARD
						mov cellFwd, pcx
					.ENDIF
					.IF (al & MAZE_CELL_PASSLEFT)	; LEFT!! (left, same)
						or ways, WMBLYK_LEFT
						mov cellLeft, pcx
					.ENDIF
					mov eax, WmblykCellPos.X
					inc eax
					invoke Maze_GetCellI, eax, WmblykCellPos.Z
					.IF (al & MAZE_CELL_PASSLEFT)	; right (right)
						or ways, WMBLYK_RIGHT
						mov cellRight, pcx
					.ENDIF
				.ENDIF
				
				print "Wmblyk "
				.IF (ways & WMBLYK_FORWARD)
					print "can go forward, "
				.ENDIF
				.IF (ways & WMBLYK_LEFT)
					print "can go left, "
				.ENDIF
				.IF (ways & WMBLYK_RIGHT)
					print "can go right"
				.ENDIF
				.IF !(ways)
					print "can solely recede rearwards"
				.ENDIF
				print " ", 13, 10
				
				.IF (ways > WMBLYK_FORWARD)
					.REPEAT
						invoke nRand, 3
						mov cl, al
						mov al, 1
						shl al, cl
						and al, ways
					.UNTIL (al)
					mov ways, al
				.ENDIF
				
				.IF (ways == WMBLYK_FORWARD)
					;bpMPM WmblykCell, cellFwd
				.ELSEIF (ways == WMBLYK_LEFT)
					;bpMPM WmblykCell, cellLeft
					fld WmblykStateVal
					fadd PIHalf
					fstp WmblykStateVal
				.ELSEIF (ways == WMBLYK_RIGHT)
					;bpMPM WmblykCell, cellRight
					fld WmblykStateVal
					fsub PIHalf
					fstp WmblykStateVal
				.ELSE
					fld WmblykStateVal
					fadd PI
					fstp WmblykStateVal
				.ENDIF
			.ELSE
				pop pax
			.ENDIF
		.ENDIF
		
		
		mov flVal, rv(Vector32DDistanceSqr, OFFSET WmblykPos, OFFSET CamPos)
		fcmp flVal, f(0.75)
		.IF (Carry?)
			mov PlrState, PLAYER_STATE_STRANGLE
			mov Wmblyk, WMBLYK_STRANGLE
			mov WmblykStateVal, 0
			invoke bpAnimPlay, ADDR WmblykAnimPlr, ADDR AnimWmblykStrangle
			bpMEM32 WmblykAnimPlr.Timer, f(10)
		.ENDIF
		
		invoke bpProcessAnimPlayer, ADDR WmblykAnimPlr, deltaTime
	.ELSEIF (Wmblyk == WMBLYK_STRANGLE)
		; StateVal is strangling state (-1.0 -- 1.0)
		mov WmblykRot, rv(Vector32DAngle, OFFSET WmblykPos, OFFSET CamPos)
		
		invoke bpProcessAnimPlayer, ADDR WmblykAnimPlr, deltaTime
		
		fld deltaTime
		fmul f(0.5)
		fsubr WmblykStateVal
		fst WmblykStateVal
		fadd f(1)
		fmul f(20)
		fsub WmblykAnimPlr.Timer
		fmul f(0.5)
		fstp WmblykAnimPlr.Speed
		
		.IF (InputAction)
			fild MazeLayer
			fsubr f(100)
			fmul f(0.003)
			fadd WmblykStateVal
			fstp WmblykStateVal
			mov InputAction, 0
		.ENDIF
		
		print real4$(WmblykStateVal), 13, 10
		
		fcmp WmblykStateVal, f(1)
		.IF (!Carry?) || (Zero?)
			mov PlrState, PLAYER_STATE_GETUP
			mov Wmblyk, WMBLYK_DEAD
			invoke bpAnimPlay, ADDR WmblykAnimPlr, ADDR AnimWmblykDead
			bpMEM32 WmblykAnimPlr.Speed, f(1)
		.ENDIF
	.ELSEIF (Wmblyk == WMBLYK_DEAD)
		invoke bpProcessAnimPlayer, ADDR WmblykAnimPlr, deltaTime
	.ENDIF
	ret
Wmblyk_Process ENDP
