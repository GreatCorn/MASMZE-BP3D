FX_AFTERIMAGE_AMOUNT	EQU 11
FX_PIXEL_SIZE			EQU 3

.DATA
FXAfterimage 			BPPtr 0	; Begin address of the frames
FXAfterimageAmount		BPPtr 0	; Count of afterimage frames (set with 
								; FX_SetAfterimage)
FXAfterimageNow			BPPtr 0	; Count of afterimage frames displayed now
FXAfterimageZoom		REAL4 0.0
FXNoiseAmplitude		REAL4 0.6
FXNoiseTexScale			Vector2 <0.0, 0.0>
FXAfterimageFPSTimer	DWORD 10

.DATA?
FXAfterimageEnd		BPPtr ?	; Last frame pointer, determines how much is drawn
FXAfterimageEndFull BPPtr ?	; Real end frame pointer at last afterimage frame
FXAfterimageFactor	REAL4 ?
FXAfterimageHighFPS	BPBool ?

FXNoiseScale			REAL4 ?
FXRenderSize			Vector2 <?, ?>
FXScreenTextureSize		DWORD ?
FXScreenTextureBuffer	BPPtr ?

.CODE

FX_DrawAfterimage PROC EXPORT
	LOCAL Alpha:REAL4, NowMulF:REAL4
	
	.IF (FPS > 70)	; Cheap pandering to 60+ Hz displayfags
		.IF (!FXAfterimageHighFPS)
			dec FXAfterimageFPSTimer	; Use timer for 10 frames
			.IF (!FXAfterimageFPSTimer)
				mov FXAfterimageHighFPS, TRUE
			.ENDIF
		.ELSE
			mov FXAfterimageFPSTimer, 10
		.ENDIF
	.ELSE
		.IF (FXAfterimageHighFPS)
			dec FXAfterimageFPSTimer
			.IF (!FXAfterimageFPSTimer)
				mov FXAfterimageHighFPS, FALSE
			.ENDIF
		.ELSE
			mov FXAfterimageFPSTimer, 10
		.ENDIF
	.ENDIF
	
	invoke glEnable, GL_BLEND
	invoke glBlendFunc, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA
	bpMEM32 Alpha, f(1)
	mov pbx, FXAfterimage
	
	fld1 
	fidiv FXAfterimageNow
	fstp NowMulF
	
	call glPushMatrix
	.WHILE (pbx <= FXAfterimageEnd)
		invoke glColor4f, f(1), f(1), f(1), Alpha
		
		invoke glBindTexture, GL_TEXTURE_2D, DWORD PTR [pbx]
		invoke glCallList, ScreenQuad
	
		fld Alpha
		fsub NowMulF
		fstp Alpha
		
		add pbx, SIZEOF BPPtr
	.ENDW
	call glPopMatrix
	
	sub pbx, FXAfterimage
	sub pbx, SIZEOF BPPtr
	shr pbx, BPPtrShift
	mov FXAfterimageNow, pbx
	invoke glDisable, GL_BLEND
	ret
FX_DrawAfterimage ENDP

FX_DrawGamma PROC EXPORT Gamma:REAL4
	;mov eax, Gamma
	;.IF (eax != f(0.5))
		invoke glBindTexture, GL_TEXTURE_2D, 0
		invoke glEnable, GL_BLEND
		invoke glBlendFunc, GL_DST_COLOR, GL_DST_COLOR
		invoke glColor3f, Gamma, Gamma, Gamma
		invoke glCallList, ScreenQuad
		invoke glCallList, ScreenQuad	
		invoke glColor3fv, OFFSET clWhite
		invoke glDisable, GL_BLEND
	;.ENDIF
	ret
FX_DrawGamma ENDP

FX_DrawNoise PROC EXPORT
	invoke glMatrixMode, GL_TEXTURE
	call glPushMatrix
	invoke glScalef, FXNoiseTexScale.X, FXNoiseTexScale.Y, f(1)
	call flRand
	push eax
	call flRand
	pop ecx
	invoke glTranslatef, eax, ecx, 0
	invoke glMatrixMode, GL_MODELVIEW

	invoke glEnable, GL_BLEND
	invoke glBlendFunc, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA
	invoke glBindTexture, GL_TEXTURE_2D, TexNoise
	invoke glColor4f, f(1), f(1), f(1), FXNoiseAmplitude
	invoke glCallList, ScreenQuad
	invoke glColor4fv, ADDR clWhite
	invoke glDisable, GL_BLEND
	
	invoke glMatrixMode, GL_TEXTURE
	call glPopMatrix
	invoke glMatrixMode, GL_MODELVIEW
	ret
FX_DrawNoise ENDP

FX_PushAfterimage PROC EXPORT
	mov pbx, FXAfterimageEnd
	mov ecx, DWORD PTR [pbx]
	.IF (ecx)
		mov pax, FXAfterimage
		mov DWORD PTR [pax], ecx
	.ENDIF
	
	.WHILE (pbx > FXAfterimage)
		mov pax, pbx
		sub pax, 4
		bpMEM32 DWORD PTR [pbx], DWORD PTR [pax]
		sub pbx, 4
	.ENDW
	ret
FX_PushAfterimage ENDP

FX_SetAfterimage PROC EXPORT Amount:BPPtr
	.IF (FXAfterimage)
		invoke glDeleteTextures, FXAfterimageAmount, FXAfterimage
		invoke bpFree, bpDefHeap, 0, FXAfterimage
	.ENDIF
	
	mov pax, Amount
	mov FXAfterimageAmount, pax
	shl pax, 2
	invoke bpMalloc, bpDefHeap, HEAP_ZERO_MEMORY, pax
	mov FXAfterimage, pax
	
	mov pax, FXAfterimageAmount
	dec pax
	shl pax, 2
	add pax, FXAfterimage
	mov FXAfterimageEnd, pax
	
	invoke glGenTextures, FXAfterimageAmount, FXAfterimage
	
	; In-game configurable afterimage
	bpMPM FXAfterimageEndFull, FXAfterimageEnd
	sub FXAfterimageEnd, 2 * SIZEOF BPPtr
	ret
FX_SetAfterimage ENDP

FX_ScreenTexture PROC EXPORT GLTexturePtr:BPPtr
	LOCAL endAddr:BPPtr, colorMode:DWORD
	
	.IF (SettingsGraphicsPosterization)
		mov colorMode, GL_UNSIGNED_SHORT_5_6_5
	.ELSE
		mov colorMode, GL_UNSIGNED_BYTE
	.ENDIF
	
	;   On Windows XP (VirtualBox), this produces GL_INVALID_ENUM. Is 
	; glReadPixels supported on XP at all?
	invoke glReadPixels, 0, 0, FXRenderSize.X, FXRenderSize.Y, GL_RGB, \
	colorMode, FXScreenTextureBuffer
	
	mov pax, GLTexturePtr
	invoke glBindTexture, GL_TEXTURE_2D, DWORD PTR [pax]
	invoke glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE
	invoke glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE
	invoke glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST
	invoke glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST
	invoke glTexImage2D, GL_TEXTURE_2D, 0, GL_RGB, \
	FXRenderSize.X, FXRenderSize.Y, 0, GL_RGB, colorMode, FXScreenTextureBuffer
	ret
FX_ScreenTexture ENDP


FX_Create PROC EXPORT
	fld1
	fdiv f(128)		; Noise texture size
	fstp FXNoiseScale
	
	invoke FX_SetAfterimage, FX_AFTERIMAGE_AMOUNT
	ret
FX_Create ENDP

FX_Resize PROC EXPORT
	fld ScreenSizeF.X
	fmul FXNoiseScale
	fstp FXNoiseTexScale.X
	fld ScreenSizeF.Y
	fmul FXNoiseScale
	fstp FXNoiseTexScale.Y

	.IF (SettingsGraphicsPixelization)
		mov eax, FMain.ScreenSize.y
		.IF (eax > 2160)
			mov ecx, FX_PIXEL_SIZE * 5
		.ELSEIF (eax > 1440)
			mov ecx, FX_PIXEL_SIZE * 4
		.ELSEIF (eax > 1080)
			mov ecx, FX_PIXEL_SIZE * 3
		.ELSEIF (eax > 720)
			mov ecx, FX_PIXEL_SIZE * 2
		.ELSE
			mov ecx, FX_PIXEL_SIZE
		.ENDIF
		xor edx, edx
		div ecx
		mov FXRenderSize.Y, eax
		mov eax, FMain.ScreenSize.x
		xor edx, edx
		div ecx
		mov FXRenderSize.X, eax
	.ELSE
		bpMEM32 FXRenderSize.X, FMain.ScreenSize.x
		mov eax, FMain.ScreenSize.y
		mov FXRenderSize.Y, eax
	.ENDIF
	mov ecx, FXRenderSize.X	; Y in eax
	mul ecx
	mov ecx, 3				; RGB (3 bytes per pixel max)
	mul ecx
	mov FXScreenTextureSize, eax

	.IF (FXScreenTextureBuffer)
		invoke bpFree, bpDefHeap, 0, FXScreenTextureBuffer
	.ENDIF
	mov FXScreenTextureBuffer, rv(bpMalloc, bpDefHeap, 0, FXScreenTextureSize)
	ret
FX_Resize ENDP
