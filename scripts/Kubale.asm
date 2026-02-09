ENUM	KUBALE_NONE, \
		KUBALE_EVENT, \
		KUBALE_ACTIVE

.DATA
Kubale			BPEnum KUBALE_NONE		; Kubale state
KubaleAnimPlr	BPAnimPlayer <>
KubaleAppeared	BPBool FALSE			; If Kubale ever appeared
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
		mov KubaleAppeared, TRUE
		mov KubaleRot, rv(flRandRange, f(2), f(8))	; State val (timer)
		
		print "event", 13, 10
	.ELSEIF (State == KUBALE_ACTIVE)
		invoke Maze_GetRandomPos, ADDR KubalePos
		
		invoke alSourcePlay, SndKubaleV
		
		mov KubaleAnimPlr.FrameType, BPA_FRAME_VERTEX	; Init animator
		;mov KubaleAnimPlr.Interpolation, BP_INTERPOLATE_CONSTANT
		mov KubaleAnimPlr.Mesh, OFFSET MeshKubale
		invoke bpAnimPlay, ADDR KubaleAnimPlr, ADDR AnimKubaleMove
		bpMEM32 KubaleAnimPlr.Speed, f(10)
	
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
			invoke bpDrawMesh, OFFSET MeshKubale
		call glPopMatrix
	.ENDIF
	ret
Kubale_Draw ENDP

Kubale_Process PROC EXPORT
	LOCAL dist:REAL4, flVal:REAL4
	
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
		
		mov dist, rv(Vector32DDistanceSqr, ADDR KubalePos, ADDR CamPos)
		invoke Collide_Distance, ADDR CamPos, ADDR KubalePos, f(0.7), dist
		
		mov flVal, rv(Plr_FrustumDot, ADDR KubalePos)
		fcmp flVal, f(0.3)
		.IF (Carry?)	; Invisible
			print real4$(flVal), 13, 10
			invoke bpProcessAnimPlayer, ADDR KubaleAnimPlr, deltaTime
		.ENDIF
		
		fcmp dist, f(1000)
		.IF (!Carry?)
			print "Teleporting Kubale", 13, 10
			xor al, al	; Repeated check for visibility
			.WHILE (!al)
				invoke Maze_GetRandomPos, ADDR KubalePos
				
				mov flVal, rv(Plr_FrustumDot, ADDR KubalePos)
				fcmp flVal, f(0.3)
				.IF (Carry?)	; Invisible
					mov al, 1
				.ELSE			; Visible
					xor al, al
				.ENDIF
			.ENDW
		.ENDIF
	.ENDIF
	ret
Kubale_Process ENDP
