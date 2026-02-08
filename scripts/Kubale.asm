ENUM	KUBALE_NONE, \
		KUBALE_EVENT, \
		KUBALE_ACTIVE

.DATA
Kubale			BPEnum KUBALE_NONE		; Kubale state
KubaleAppeared	BPBool FALSE			; If Kubale ever appeared
KubaleList		DWORD 0					; Kubale GL list to draw
KubaleRot		REAL4 0.0				; Kubale rotation (radians)
KubalePos		Vector3 <0.0, 0.0, 0.0>	; The act of transferring the Kubale
KubaleInkblot	DWORD 0					; Kubale inkblot index
KubaleVision	REAL4 0.0				; Kubale vision value (alpha, gain)

.CODE
; Spawn Kubale into the layer with random position
Kubale_Spawn PROC EXPORT State:BPEnum
	IFDEF MODE_DEBUG
	.IF (State != KUBALE_NONE)
		print "Spawned Kubale: "
	.ENDIF
	ENDIF
	.IF (State == KUBALE_NONE)
		invoke alSourceStop, SndKubale
		invoke alSourceStop, SndKubaleV
	.ELSEIF (State == KUBALE_EVENT)
		mov KubaleRot, rv(flRandRange, f(2), f(8))	; State val (timer)
		
		print "event", 13, 10
	.ELSEIF (State == KUBALE_ACTIVE)
		invoke Maze_GetRandomPos, ADDR KubalePos
		
		bpMEM32 KubaleList, MdlKubale
		invoke alSourcePlay, SndKubaleV
	
		print "active, at "
		Vector3Print KubalePos
	.ENDIF
	mbm Kubale, State
	ret
Kubale_Spawn ENDP


Kubale_Draw	PROC EXPORT
	.IF (Kubale == KUBALE_ACTIVE)
		call glPushMatrix
			invoke glTranslate3fv, OFFSET KubalePos
			invoke glRotatefr, KubaleRot, 0, f(1), 0
			invoke glBindTexture, GL_TEXTURE_2D, TexKubale
			invoke glCallList, KubaleList
		call glPopMatrix
	.ENDIF
	ret
Kubale_Draw ENDP

Kubale_Process PROC EXPORT
	.IF (Kubale == KUBALE_EVENT)
		; KubaleRot is state val (timer)
		mov eax, KubaleRot
		fld KubaleRot
		fsub deltaTime
		fstp KubaleRot
		mov ecx, KubaleRot
		.IF (ecx & FLT_NEG)
			.IF !(eax & FLT_NEG)
				invoke alSourcePlay, SndKubaleAppear
			.ENDIF
			
			fcmp KubaleRot, f(-3)
			.IF (Carry?)
				invoke Kubale_Spawn, KUBALE_ACTIVE
			.ELSE
				fcmp KubaleRot, f(-1)
				.IF (Carry?)	; > -3, < -1
					; Darkness
					mov FogDensity, rv(flLerp, FogDensity, f(5), delta20)
				.ELSE			; > -1, < 0
					; Flicker
					mov FogDensity, rv(flRandRange, f(0.5), f(1.0))
				.ENDIF		
			.ENDIF
		.ENDIF
	.ELSEIF (Kubale == KUBALE_ACTIVE)
		mov FogDensity, rv(flLerp, FogDensity, f(0.5), delta2)
	.ENDIF
	ret
Kubale_Process ENDP
