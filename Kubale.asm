ENUM	KUBALE_INACTIVE, \
		KUBALE_APPEARED, \
		KUBALE_ACTIVE

.DATA
Kubale			BPEnum KUBALE_INACTIVE	; Kubale state
KubaleAppeared	BPBool FALSE			; If Kubale ever appeared
KubaleList		DWORD 0					; Kubale GL list to draw
KubaleRot		REAL4 0.0				; Kubale rotation (radians)
KubalePos		Vector3 <0.0, 0.0, 0.0>	; The act of transferring the Kubale
KubaleInkblot	DWORD 0					; Kubale inkblot index
KubaleVision	REAL4 0.0				; Kubale vision value (alpha, gain)

.CODE
; Spawn Kubale into the layer with random position
Kubale_Spawn PROC EXPORT
	mov Kubale, KUBALE_ACTIVE
	m2m KubaleList, MdlKubale
	
	invoke alSourcePlay, SndKubaleV
	
	invoke Maze_GetRandomPos, ADDR KubalePos
	ret
Kubale_Spawn ENDP

Kubale_Draw	PROC EXPORT
	call glPushMatrix
		invoke glTranslate3fv, OFFSET KubalePos
		invoke glRotatef, KubaleRot, 0, f(1), 0
		invoke glBindTexture, GL_TEXTURE_2D, TexKubale
		invoke glCallList, KubaleList
	call glPopMatrix
	ret
Kubale_Draw ENDP

Kubale_Process PROC EXPORT
	ret
Kubale_Process ENDP
