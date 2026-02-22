ENUM	KUBALE_NONE, \
		KUBALE_EVENT, \
		KUBALE_ACTIVE
		
ENUM	KUBALE_ACT_NONE, \
		KUBALE_ACT_MOVE, \
		KUBALE_ACT_ATTACK

.CONST
KubaleDot		REAL4 0.1				; Smaller dot product will move Kubale

.DATA
Kubale			BPEnum KUBALE_NONE		; Kubale state
KubaleAction	BPBool KUBALE_ACT_NONE
KubaleActionP	BPBool KUBALE_ACT_NONE
KubaleAnimPlr	BPAnimPlayer <>
KubaleAppeared	BPBool FALSE			; If Kubale ever appeared
KubaleRot		REAL4 0.0				; Kubale rotation (radians)
KubalePos		Vector3 <0.0, 0.0, 0.0>	; The act of transferring the Kubale
KubaleRaycast	BPBool FALSE
KubaleInkblot	BPPtr 0					; Kubale inkblot index
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
		bpMEM32 FogDensity, f(0.5)
		invoke alSourceStop, SndKubale
		invoke alSourceStop, SndKubaleV
	.ELSEIF (State == KUBALE_EVENT)
		mov KubaleAppeared, TRUE
		mov KubaleRot, rv(flRandRange, f(2), f(8))	; State val (timer)
		
		print "event", 13, 10
	.ELSEIF (State == KUBALE_ACTIVE)
		invoke Maze_GetRandomPos, ADDR KubalePos, FALSE
		
		.IF (MazeLayer > 42)
			mov KubaleRaycast, TRUE
		.ENDIF
		
		mov KubaleAnimPlr.FrameType, BPA_FRAME_VERTEX	; Init animator
		mov KubaleAnimPlr.Mesh, OFFSET MeshKubale
		invoke bpAnimPlay, ADDR KubaleAnimPlr, ADDR AnimKubaleMove
		bpMEM32 KubaleAnimPlr.Speed, f(2)
		
		print "active, at "
		Vector32DPrint KubalePos
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
	LOCAL dist:REAL4, flVal:REAL4, blocked:BPBool
	
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
		
		mov dist, rv(Vector32DDistanceSqr, OFFSET KubalePos, OFFSET CamPos)
		
		mov flVal, rv(Plr_FrustumDot, OFFSET KubalePos)
		mov blocked, FALSE
		.IF (rv(Maze_Raycast, OFFSET KubalePos, OFFSET CamPosL))
			.IF (KubaleRaycast)
				mov flVal, 0
			.ENDIF
			mov blocked, TRUE
		.ENDIF
		fcmp flVal, KubaleDot
		.IF (Carry?) && (PlrState == PLAYER_STATE_GAME)	; Invisible
			fcmp dist, f(2)
			.IF (Carry?)
				or KubaleAction, KUBALE_ACT_ATTACK
			.ELSE
				and KubaleAction, not KUBALE_ACT_ATTACK
			.ENDIF
			fcmp dist, f(1)
			.IF (!Carry?)
				or KubaleAction, KUBALE_ACT_MOVE
				
				invoke alSourcefv, SndKubale, AL_POSITION, ADDR KubalePos
				
				fld dist
				fmul deltaTime
				fmul f(1.5)
				fadd delta2
				fstp flVal
				
				mov KubaleRot, rv(Vector32DAngle,OFFSET KubalePos,OFFSET CamPos)
				
				fld KubaleRot
				fsincos
				fmul flVal
				fadd KubalePos.Z
				fstp KubalePos.Z
				fmul flVal
				fadd KubalePos.X
				fstp KubalePos.X
				
				invoke bpProcessAnimPlayer, ADDR KubaleAnimPlr, deltaTime
			.ELSE
				and KubaleAction, not KUBALE_ACT_MOVE
			.ENDIF
		.ELSE
			and KubaleAction, not KUBALE_ACT_MOVE
			and KubaleAction, not KUBALE_ACT_ATTACK
		.ENDIF
			
		; Kollisions
		fcmp dist, f(32)
		.IF (Carry?)
			.IF (Maze) && (KubaleAction & KUBALE_ACT_MOVE)	; Just in case
				invoke Maze_CollideLayout, ADDR KubalePos, f(1.6), FALSE
			.ENDIF
			
			; Player collision
			invoke Collide_Distance, ADDR CamPos, ADDR KubalePos, f(0.5), dist
			
			; Wmblyk
			.IF (Wmblyk == WMBLYK_STILL)
				vinvoke Collide_Distance, OFFSET KubalePos, \
				OFFSET WmblykPos, f(0.8), 0
			.ENDIF
		.ENDIF
				
		.IF (KubaleAction & KUBALE_ACT_ATTACK) && (!blocked)
			mov KubaleVision, rv(flLerp, KubaleVision, FLT_1, delta2)
			
			fld PlrHealth
			fsub deltaTime
			fst PlrHealth
			fsubr f(1)
			fmul f(0.1)
			fstp flVal
			
			invoke Plr_Shake, flVal
			
			bpMPM UIDeadTipStr, StrTipKubale
		.ELSE
			mov KubaleVision, rv(flLerp, KubaleVision, f(-0.1), delta2)
			
			.IF (KubaleVision & FLT_NEG)
				mov KubaleVision, 0
				invoke alSourcePause, SndKubaleV
			.ENDIF
		.ENDIF
		
		mov pax, SIZEOF TexKubaleV
		shr pax, 2
		mov KubaleInkblot, rv(nRand, pax)
		shl KubaleInkblot, 2
		invoke alSourcef, SndKubaleV, AL_GAIN, KubaleVision
		
		; Do action trigger stuff
		push pbx
		mov bl, KubaleAction
		.IF (KubaleActionP != bl)
			mov bh, KubaleAction
			and bh, KUBALE_ACT_MOVE
			mov al, KubaleActionP
			and al, KUBALE_ACT_MOVE
			.IF (bh != al)
				.IF (bh)
					invoke alSourcePlay, SndKubale
				.ELSE
					invoke alSourcePause, SndKubale
				.ENDIF
			.ENDIF
			
			mov bh, KubaleAction
			and bh, KUBALE_ACT_ATTACK
			mov al, KubaleActionP
			and al, KUBALE_ACT_ATTACK
			.IF (bh != al)
				.IF (bh) && (rv(SndPlaying, SndKubaleV) != AL_PLAYING)
					invoke alSourcePlay, SndKubaleV
				.ENDIF
			.ENDIF
			
			mov KubaleActionP, bl
		.ENDIF
		pop pbx
		
		; Teleport if far enough away
		fcmp dist, f(96)
		.IF (!Carry?)
			print "Teleporting Kubale", 13, 10
			mov al, 64	; Repeated check for visibility
			.WHILE (al)
				push pax
				invoke Maze_GetRandomPos, ADDR KubalePos, FALSE
				
				mov flVal, rv(Plr_FrustumDot, ADDR KubalePos)
				fcmp flVal, KubaleDot
				.IF (Carry?)	; Invisible
					.BREAK
				.ELSE
					mov flVal, \
					rv(Vector32DDistanceSqr, OFFSET KubalePos, OFFSET CamPos)
					fcmp flVal, f(48)
					.IF (!Carry?)
						.BREAK
					.ENDIF
				.ENDIF
				pop pax
				dec al
			.ENDW
		.ENDIF
	.ENDIF
	ret
Kubale_Process ENDP
