PARTICLE_BILLBOARD_Y	EQU 1
PARTICLE_BILLBOARD_X	EQU 2

PARTICLE_FADE_IN	EQU 1
PARTICLE_FADE_OUT	EQU 2
PARTICLE_FADE_DOT	EQU 4
PARTICLE_FADE_DIST	EQU 8

PARTICLE_VELOCITY_POSITION	EQU 1
PARTICLE_VELOCITY_ROTATION	EQU 2
PARTICLE_VELOCITY_SCALE		EQU 4

;   Particles are placed sequentially in the ParticleSystem.Particles buffer and 
; are processed by iterating through said buffer. When making changes to the
; Particle STRUCT, respective changes must be done to the Particles_Draw and
; Particles_Process procedures.
Particle STRUCT
	Lifetime REAL4 ?
	Position Vector3 <>
	Rotation REAL4 ?
	Scale REAL4 ?
	StartLifetime REAL4 ?
	Velocity Vector4 <>
Particle ENDS

ParticleSystem STRUCT
	Billboard		BPEnum 0
	Count			BPPtr 0
	Distance		Vector2 <0.0, 0.0>
	EndAddr			BPPtr ?
	Fade			BYTE 0
	Friction		REAL4 0.0
	Gravity			BPBool FALSE
	Lifetime		Vector2 <0.0, 0.0>
	Looping			BPBool FALSE
	Position		Vector3 <0.0, 0.0, 0.0>
	Rotate			BPBool FALSE
	Scale			Vector2 <1.0, 1.0>
	Velocity		Vector2 <0.0, 0.0>
	VelocityAffects	BPEnum PARTICLE_VELOCITY_POSITION
	
	Particles	BPPtr 0
ParticleSystem ENDS

.DATA
ParticleColor		REAL4 1.0, 1.0, 1.0, 1.0
ParticleGravity		REAL4 9.1
ParticleMaxAlpha	REAL4 1.0
ParticleFadeDist	REAL4 0.022

.DATA?
ListParticle	DWORD ?

.CODE
Particles_Create PROC EXPORT ParSysPtr:BPPtr
	ASSUME pcx:PTR ParticleSystem
	ASSUME pbx:PTR Particle
	
	mov pcx, ParSysPtr
	mov pax, [pcx].Count
	mov pcx, SIZEOF Particle
	mul pcx
	push pax
	invoke bpMalloc, bpDefHeap, HEAP_ZERO_MEMORY, pax
	mov pcx, ParSysPtr
	mov [pcx].Particles, pax
	pop pdx
	add pax, pdx
	mov [pcx].EndAddr, pax
	
	; Spawn all
	push pbx
	mov pbx, [pcx].Particles
	.WHILE (pbx < [pcx].EndAddr)
		call Particle_Init
		mov [pbx].Lifetime, 0
		add pbx, SIZEOF Particle
	.ENDW
	pop pbx
	
	ASSUME pcx:nothing
	ASSUME pbx:nothing
	ret
Particles_Create ENDP

Particles_Draw PROC EXPORT ParSysPtr:BPPtr
	LOCAL Alpha:REAL4, Dot:Vector2
	ASSUME pcx:PTR ParticleSystem
	ASSUME pbx:PTR Particle
	push pbx
	
	mov pcx, ParSysPtr
	mov pbx, [pcx].Particles
	.WHILE (pbx < [pcx].EndAddr)
		.IF !([pbx].Lifetime)
			add pbx, SIZEOF Particle
			.CONTINUE
		.ENDIF
		IFDEF PARTICLES_DOT_CULL
		mov Alpha, rv(Plr_FrustumDot, ADDR [pbx].Position)
		fcmp Alpha, f(0.2)
		.IF (Carry?)
			add pbx, SIZEOF Particle
			.CONTINUE
		.ENDIF
		ENDIF
		
		call glPushMatrix
		
		bpMEM32 ParticleColor[12], f(1)
		
		mov pcx, ParSysPtr
		.IF ([pcx].Fade & PARTICLE_FADE_IN)
			fld [pbx].StartLifetime
			fsub [pbx].Lifetime
			fdiv [pbx].StartLifetime
			fmul f(2)
			fstp Alpha
			fcmp Alpha, f(1)
			.IF (Carry?)
				bpMEM32 ParticleColor[12], Alpha
			.ENDIF
		.ENDIF
		.IF ([pcx].Fade & PARTICLE_FADE_OUT)
			fld [pbx].StartLifetime
			fsub [pbx].Lifetime
			fdiv [pbx].StartLifetime
			fsubr f(1)
			fmul f(2)
			fstp Alpha
			fcmp Alpha, f(1)
			.IF (Carry?)
				bpMEM32 ParticleColor[12], Alpha
			.ENDIF
		.ENDIF
		
		invoke glTranslate3fv, ADDR [pbx].Position
		
		mov pcx, ParSysPtr
		.IF ([pcx].Billboard)
			.IF ([pcx].Billboard & PARTICLE_BILLBOARD_Y)
				vinvoke glRotatefr, CamRotL.Y, 0, f(-1), 0
				mov pcx, ParSysPtr
			.ENDIF
			.IF ([pcx].Billboard & PARTICLE_BILLBOARD_X)
				vinvoke glRotatefr, CamRotL.X, f(-1), 0, 0
			.ENDIF
			invoke glRotatefr, [pbx].Rotation, 0, 0, f(1)
		.ELSE
			invoke glRotatefr, [pbx].Rotation, 0, f(1), 0
			
			mov pcx, ParSysPtr
			.IF ([pcx].Fade & PARTICLE_FADE_DOT)
				fld [pbx].Position.X
				fsubr CamPos.X
				fstp Dot.X
				fld [pbx].Position.Z
				fsubr CamPos.Z
				fstp Dot.Y
				
				invoke Vector2Normalize, ADDR Dot
				fld [pbx].Rotation
				fsincos
				fmul Dot.Y	; Maybe switch
				fxch
				fmul Dot.X
				fadd
				fabs
				;fsubr f(1)
				fmul ParticleColor[12]
				fstp ParticleColor[12]
			.ENDIF
		.ENDIF
		
		mov pcx, ParSysPtr
		.IF ([pcx].Fade & PARTICLE_FADE_DIST)
			vinvoke Vector32DDistanceSqr, ADDR [pbx].Position, OFFSET CamPosL
			fmul ParticleFadeDist
			fsub f(0.5)
			fstp Dot.X
			mov Dot.X, rv(flClamp, Dot.X, 0, f(1))
			fld Dot.X
			fmul ParticleColor[12]
			fstp ParticleColor[12]
		.ENDIF
		
		fld ParticleColor[12]
		fmul ParticleMaxAlpha
		fstp ParticleColor[12]
		;invoke glColor4fv, ADDR ParticleColor
		invoke glMaterialfv, GL_FRONT, GL_DIFFUSE, ADDR ParticleColor
		
		invoke glScalef, [pbx].Scale, [pbx].Scale, [pbx].Scale
		
		invoke glCallList, ListParticle
		call glPopMatrix
		
		add pbx, SIZEOF Particle
		mov pcx, ParSysPtr
	.ENDW
	invoke glMaterialfv, GL_FRONT, GL_DIFFUSE, OFFSET clWhite
	
	pop pbx
	ASSUME pcx:nothing
	ASSUME pbx:nothing
	ret
Particles_Draw ENDP

Particles_Free PROC EXPORT ParSysPtr:BPPtr
	ASSUME pcx:PTR ParticleSystem
	mov pcx, ParSysPtr
	invoke bpFree, bpDefHeap, 0, [pcx].Particles
	mov pcx, ParSysPtr
	mov [pcx].Particles, 0
	ASSUME pcx:nothing
	ret
Particles_Free ENDP

Particles_Kill PROC EXPORT ParSysPtr:BPPtr
	ASSUME pcx:PTR ParticleSystem
	ASSUME pbx:PTR Particle
	
	mov pcx, ParSysPtr
	mov pbx, [pcx].Particles
	.WHILE (pbx < [pcx].EndAddr)
		mov [pbx].Lifetime, 0
		add pbx, SIZEOF Particle
	.ENDW
	ASSUME pcx:nothing
	ASSUME pbx:nothing
	ret
Particles_Kill ENDP

Particles_Process PROC EXPORT ParSysPtr:BPPtr, Delta:REAL4
	LOCAL DeltaFriction:REAL4
	ASSUME pcx:PTR ParticleSystem
	ASSUME pbx:PTR Particle
	
	push pbx
	
	mov pcx, ParSysPtr
	fld [pcx].Friction
	fmul Delta
	fstp DeltaFriction
	
	mov pbx, [pcx].Particles
	.WHILE (pbx < [pcx].EndAddr)
		; Check lifetime
		.IF !([pbx].Lifetime)
			.IF ([pcx].Looping)
				call Particle_Init
				mov pcx, ParSysPtr
			.ELSE
				add pbx, SIZEOF Particle
				.CONTINUE
			.ENDIF
		.ENDIF
		
		fld [pbx].Lifetime
		fsub Delta
		fstp [pbx].Lifetime
		
		fcmp [pbx].Lifetime
		.IF (Carry?)
			mov [pbx].Lifetime, 0
		.ENDIF
		
		.IF ([pcx].VelocityAffects & PARTICLE_VELOCITY_POSITION)
			fld [pbx].Velocity.X
			fmul Delta
			fadd [pbx].Position.X
			fstp [pbx].Position.X
			fld [pbx].Velocity.Y
			fmul Delta
			fadd [pbx].Position.Y
			fstp [pbx].Position.Y
			fld [pbx].Velocity.Z
			fmul Delta
			fadd [pbx].Position.Z
			fstp [pbx].Position.Z
		.ENDIF
		
		.IF ([pcx].VelocityAffects & PARTICLE_VELOCITY_ROTATION)
			fld [pbx].Velocity.W
			fmul Delta
			fadd [pbx].Rotation
			fstp [pbx].Rotation
		.ENDIF
		.IF ([pcx].VelocityAffects & PARTICLE_VELOCITY_SCALE)
			fld [pbx].Velocity.W
			fmul Delta
			fadd [pbx].Scale
			fstp [pbx].Scale
		.ENDIF
		
		mov [pbx].Velocity.X, rv(flLerp, [pbx].Velocity.X, 0, DeltaFriction)
		mov [pbx].Velocity.Y, rv(flLerp, [pbx].Velocity.Y, 0, DeltaFriction)
		mov [pbx].Velocity.Z, rv(flLerp, [pbx].Velocity.Z, 0, DeltaFriction)
		mov [pbx].Velocity.W, rv(flLerp, [pbx].Velocity.W, 0, DeltaFriction)
		
		.IF ([pcx].Gravity)
			fld ParticleGravity
			fmul Delta
			fsubr [pbx].Velocity.Y
			fstp [pbx].Velocity.Y
		.ENDIF
		
		add pbx, SIZEOF Particle
		mov pcx, ParSysPtr
	.ENDW
	
	pop pbx
	
	ASSUME pcx:nothing
	ASSUME pbx:nothing
	ret
Particles_Process ENDP

Particles_Spawn PROC EXPORT ParSysPtr:BPPtr, Amount:DWORD
	ASSUME pcx:PTR ParticleSystem
	ASSUME pbx:PTR Particle
	
	mov pcx, ParSysPtr
	mov pbx, [pcx].Particles
	.WHILE (pbx < [pcx].EndAddr)
		.IF !([pbx].Lifetime)
			call Particle_Init
			dec Amount
			.IF (!Amount)
				.BREAK
			.ENDIF
		.ENDIF
		add pbx, SIZEOF Particle
	.ENDW
	ASSUME pcx:nothing
	ASSUME pbx:nothing
	ret
Particles_Spawn ENDP

; Takes ParSysPtr in pcx and Particle in pbx
Particle_Init PROC EXPORT 
	LOCAL PosOffset:BPPtr
	ASSUME pcx:PTR ParticleSystem
	ASSUME pbx:PTR Particle
	
	push pcx
	mov [pbx].Lifetime, rv(flRandRange, [pcx].Lifetime.X, [pcx].Lifetime.Y)
	mov [pbx].StartLifetime, eax
	pop pcx
	
	lea pax, [pcx].Position
	sub pax, pcx
	mov PosOffset, pax
	
	
	push pcx
	invoke flRandRange, [pcx].Distance.X, [pcx].Distance.Y
	pop pcx
	push pax
	push pcx
	invoke flRandRange, 0, PI2
	pop pcx
	push pax
	fld REAL4 PTR [esp]		; 0 - 3.14*2
	fsincos
	
	fmul REAL4 PTR [esp+4]	; times distance
	fadd [pcx].Position.X
	fstp [pbx].Position.X
	
	fmul REAL4 PTR [esp+4]
	fadd [pcx].Position.Z
	fstp [pbx].Position.Z
	add esp, SIZEOF BPPtr*2
	bpMEM32 [pbx].Position.Y, [pcx].Position.Y
	
	
	.IF ([pcx].Rotate)
		push pcx
		mov [pbx].Rotation, rv(flRandRange, 0, PI2)
		pop pcx
	.ENDIF
	
	push pcx
	mov [pbx].Scale, rv(flRandRange, [pcx].Scale.X, [pcx].Scale.Y)
	pop pcx
	
	PosOff = 0
	REPEAT 4	; Velocity
		push pcx
		mov [pbx+PosOff].Velocity.X, \
			rv(flRandRange, [pcx].Velocity.X, [pcx].Velocity.Y)
		pop pcx
		
		push pcx
		invoke nRand, 2
		pop pcx
		.IF (al)	; Random neg
			xor [pbx+PosOff].Velocity.X, FLT_NEG
		.ENDIF
		PosOff = PosOff+4
	ENDM
	fld [pbx].Velocity.W
	fmul f(0.5)
	fstp [pbx].Velocity.W
	
	ASSUME pcx:nothing
	ASSUME pbx:nothing
	ret
Particle_Init ENDP
