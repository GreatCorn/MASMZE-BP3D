ENUM	VEBRA_NONE, \
		VEBRA_SIT, \
		VEBRA_GO, \
		VEBRA_GOING

.DATA
Vebra			BPEnum VEBRA_NONE
VebraAnimPlr	BPAnimPlayer <>
VebraTimer		REAL4 0.0

.CODE

Vebra_Spawn PROC EXPORT
	print "Spawned Vebra", 13, 10
	mov Vebra, VEBRA_SIT
	mov VebraAnimPlr.FrameType, BPA_FRAME_VERTEX	; Init animator
	mov VebraAnimPlr.Mesh, OFFSET MeshVebra
	invoke bpAnimPlay, ADDR VebraAnimPlr, ADDR AnimVebraSit
	ret
Vebra_Spawn ENDP


Vebra_Draw PROC EXPORT
	call glPushMatrix
	invoke glTranslatef, MazeDoorPos.X, 0, MazeDoorPos.Z
	invoke glBindTexture, GL_TEXTURE_2D, TexVebra
	invoke bpDrawMesh, ADDR MeshVebra
	call glPopMatrix
	ret
Vebra_Draw ENDP

Vebra_Process PROC EXPORT
	LOCAL flVal:REAL4
	
	invoke bpProcessAnimPlayer, ADDR VebraAnimPlr, deltaTime
	
	.IF (Vebra == VEBRA_SIT)
		fld VebraTimer
		fsub deltaTime
		fstp VebraTimer
		.IF (VebraTimer & FLT_NEG)
			mov VebraTimer, rv(flRandRange, f(5), f(10))
			invoke bpAnimPlay, ADDR VebraAnimPlr, ADDR AnimVebraSit
		.ENDIF
		
		.IF !(PlrCanControl)
			; For some fucking reason
			ret
		.ENDIF
		
		mov flVal, rv(Vector32DDistanceSqr, OFFSET MazeDoorPos, OFFSET CamPos)
		fcmp flVal, f(12)
		.IF (Carry?)
			mov Vebra, VEBRA_GO
		.ELSE
			.IF !(rv(Maze_Raycast, OFFSET MazeDoorPos, OFFSET CamPos))
				mov flVal, \
				rv(Vector32DDistanceSqr, OFFSET MazeDoorPos, OFFSET CamPos)
				fcmp flVal, f(48)
				.IF (Carry?)
					mov Vebra, VEBRA_GO
				.ENDIF
			.ENDIF
		.ENDIF
	.ELSEIF (Vebra == VEBRA_GO)
		print "Vebra went", 13, 10
		invoke bpAnimPlay, ADDR VebraAnimPlr, ADDR AnimVebraGo
		mov Vebra, VEBRA_GOING
		.IF (NetSock)
			invoke Net_FormSend, NET_MAZE_ENTITIES, NetSock
		.ENDIF
	.ELSEIF (Vebra == VEBRA_GOING)
		fcmp VebraAnimPlr.Timer, f(26)
		.IF (!Carry?)
			mov MazeDoorRot, rv(flLerp, MazeDoorRot, 0, delta10)
			.IF !(rv(SndPlaying, SndDoorClose))
				invoke SndSetPos, SndDoorClose, ADDR MazeDoorPos
				invoke alSourcePlay, SndDoorClose
			.ENDIF
		.ELSE
			fcmp VebraAnimPlr.Timer, f(17)
			.IF (!Carry?)
				.IF !(MazeDoorRot)
					invoke SndSetPos, SndCheckpoint, ADDR MazeDoorPos
					invoke alSourcePlay, SndCheckpoint
				.ENDIF
				mov MazeDoorRot, rv(flLerp, MazeDoorRot, f(-90), delta10)
			.ENDIF
		.ENDIF
		.IF !(VebraAnimPlr.TrackPtr)
			mov Vebra, VEBRA_NONE
			mov MazeDoorRot, 0
		.ENDIF
	.ENDIF
	ret
Vebra_Process ENDP
