Collide_Distance PROC EXPORT Pos:BPPtr, ColliderPos:BPPtr, Radius:REAL4, \
Distance:REAL4
	LOCAL dirAngle:REAL4
	mov pax, Pos	; Pos uses only X and Z, omitting Y
	mov pcx, ColliderPos
	
	.IF (!Distance)	; Distance isn't provided, calculate it
		fld REAL4 PTR [pax]
		fsub REAL4 PTR [pcx]
		fmul st, st
		fld REAL4 PTR [pax+8]
		fsub REAL4 PTR [pcx+8]
		fmul st, st
		fadd
		fstp Distance
		fcmp Distance, Radius
		.IF (Carry?)
			mov pax, Pos
			mov pcx, ColliderPos
		.ELSE
			ret
		.ENDIF
	.ENDIF
	
	fld REAL4 PTR [pax+8]	; Get the angle from collider to collidee
	fsub REAL4 PTR [pcx+8]
	fld REAL4 PTR [pax]
	fsub REAL4 PTR [pcx]
	fpatan
	fstp dirAngle
	
	fld Radius		; Get the distance to push collidee out of radius
	fsub Distance
	fstp Radius
	
	fld dirAngle	; Push collidee's position by angle (cos & sin)
	fsincos
	
	fmul Radius
	fadd REAL4 PTR [pax]
	fstp REAL4 PTR [pax]
	
	fmul Radius
	fadd REAL4 PTR [pax+8]
	fstp REAL4 PTR [pax+8]
	ret
Collide_Distance ENDP

Collide_Rectangle PROC EXPORT Pos:BPPtr, ColliderPos:BPPtr, \
ColliderWidth:REAL4, ColliderHeight:REAL4
	LOCAL inRange:BYTE, localPos:Vector2
	LOCAL penetration:Vector2, halfSize:Vector2
	
	; Get local in-collider position
	mov pax, Pos
	mov pcx, ColliderPos
	fld REAL4 PTR [pax]
	fsub REAL4 PTR [pcx]
	fstp localPos.X
	fld REAL4 PTR [pax+8]
	fsub REAL4 PTR [pcx+8]
	fstp localPos.Y
	
	; Get collider's half size (assuming its pos is its center)
	fld ColliderWidth
	fmul f(0.5)
	fstp halfSize.X
	
	fld ColliderHeight
	fmul f(0.5)
	fstp halfSize.Y
	
	; Check if Pos is in range of the boundaries
	push localPos.X
	and localPos.X, not FLT_NEG
	fcmp localPos.X, halfSize.X
	pop localPos.X
	.IF (Carry?) || (Zero?)
		push localPos.Y
		and localPos.Y, not FLT_NEG
		fcmp localPos.Y, halfSize.Y
		pop localPos.Y
		.IF (Carry?) || (Zero?)
			fld localPos.X
			fabs
			fsubr halfSize.X
			fstp penetration.X
			fld localPos.Y
			fabs
			fsubr halfSize.Y
			fstp penetration.Y
			; Push out on the smaller-overlap axis
			fcmp penetration.X, penetration.Y
			.IF (Carry?)
				.IF (localPos.X & FLT_NEG)	; Check sign (< 0)
					or halfSize.X, FLT_NEG	; chs
				.ENDIF
				bpMEM32 localPos.X, halfSize.X
			.ELSE
				.IF (localPos.Y & FLT_NEG)	; Check sign (< 0)
					or halfSize.Y, FLT_NEG	; chs
				.ENDIF
				bpMEM32 localPos.Y, halfSize.Y
			.ENDIF
			
			; Write back world position
			mov pax, Pos
			mov pcx, ColliderPos
			fld REAL4 PTR [pcx]
			fadd localPos.X
			fstp REAL4 PTR [pax]
			
			fld REAL4 PTR [pcx+8]
			fadd localPos.Y
			fstp REAL4 PTR [pax+8]
		.ENDIF
	.ENDIF
	
	IFDEF MODE_DEBUG
	.IF (Keys["C"]) && (UIDebug)
		call glPushMatrix
		mov pax, ColliderPos
		invoke glTranslatef, REAL4 PTR [pax], 0, REAL4 PTR [pax+8]
		fld ColliderWidth
		fsub f(0.7)
		fstp ColliderWidth
		fld ColliderHeight
		fsub f(0.7)
		fstp ColliderHeight
		invoke glDisable, GL_LIGHTING
		invoke glScalef, ColliderWidth, f(1), ColliderHeight
		invoke glBindTexture, GL_TEXTURE_2D, 0
		invoke glCallList, MdlCube
		invoke glEnable, GL_LIGHTING
		call glPopMatrix
	.ENDIF
	ENDIF
	ret
Collide_Rectangle ENDP