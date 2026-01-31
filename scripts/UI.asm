ENUM	UI_FADE_NONE, \
		UI_FADE_IN,	\
		UI_FADE_OUT
		
ENUML	
		E UI_STATE_GAME
		E UI_STATE_FADING
		E UI_STATE_MENU_PAUSE
		E UI_STATE_MENU_MAIN
		E UI_STATE_MENU_REALLY_EXIT
		
		E UI_STATE_MENU_SETTINGS
		E 	UI_STATE_MENU_SETTINGS_GRAPHICS
		E 	UI_STATE_MENU_SETTINGS_CONTROLS
		
		; UI_STATE_MENU_SETTINGS_GRAPHICS tree
		E 	UI_STATE_MENU_SETTINGS_GRAPHICS_EFFECTS
		E 	UI_STATE_MENU_SETTINGS_GRAPHICS_GAMMA
		
		; UI_STATE_MENU_SETTINGS_CONTROLS tree
		E	UI_STATE_MENU_SETTINGS_CONTROLS_BINDINGS
		
; UI parameters and values
UI_SCALE	EQU 4
UI_BRD_M	EQU 4*UI_SCALE				; Border margin
UI_BTN_H	EQU 12*UI_SCALE				; Button height; height of text (used 
										; without margin)
UI_BTN_M	EQU 2*UI_SCALE				; Button margin (only between two 
										; buttons, not around)
UI_BTN_W	EQU 80*UI_SCALE			; Button width
UI_BTN_WS	EQU UI_BTN_W/2 - UI_BTN_M	; Small button width
UI_CB_MAX	EQU 7						; Max amount of combobox items
UI_HR_H		EQU UI_HR_T + UI_BTN_M*2	; UI horizontal line height
UI_HR_T		EQU 1*UI_SCALE				; UI horizontal line thickness
UI_SLD_H	EQU 2*UI_SCALE				; Slider line height
UI_SLD_T	EQU 5*UI_SCALE				; Slider tack size

ENUM	UI_NONE, \
		UI_BUTTON, \
		UI_BUTTON_SMALL, \
		UI_SLIDER, \
		UI_COMBOBOX, \
		UI_CHECKBOX, \
		UI_MAPPER
		
ENUM	UICB_NONE, \
		UICB_LANGUAGE, \
		UICB_RESOLUTION, \
		UICB_DISPLAYMODE, \
		UICB_DISPLAYDEV, \
		UICB_MSAA
		
ENUM	UIPP_NONE, \
		UIPP_EXIT, \
		UIPP_DISCARD, \
		UIPP_RESTART, \
		UIPP_BIND

.DATA
IFDEF MODE_DEBUG
UIDebug			BPBool FALSE
ENDIF

UIState			DWORD UI_STATE_GAME

UIBinding		BPEnum BIND_NONE
UIBindAction	BPPtr 0
UIBindStr		BPPtr 0

UIButtonType	BPEnum UI_BUTTON
UIButtonJump	BPBool FALSE	; Jump to button that's in focus

UIComboboxCount		DWORD 0
UIComboboxHeight	DWORD 0
UIComboboxMenu		SDWORD 0
UIComboboxNames		BPPtr 0		; Array of 32-length strings
UIComboboxSelected	BYTE 0	; Currently selected item to display check
UIComboboxXLerp		REAL4 0.0

UIDisabled			BPBool FALSE

UIID				BYTE 0

UIFade				BPEnum UI_FADE_NONE
UIFadeCallback		BPPtr 0
UIFadeVal			REAL4 0.0

UIFocus				BYTE 0
UIFocusPrev			BYTE 0
UIFocusBeforePopup	BYTE 0
UIFocusType			BPEnum UI_NONE
UIPressed			BYTE 0

UIInvRot			REAL4 0.0

UIMove				SDWORD 0
UIPopupMenu			DWORD 0
UIScroll			SDWORD 0
UIScrollLimit		DWORD 0
UIScrollPressed		BPBool FALSE
UIScrollable		BPBool FALSE
UISliderRange		REAL4 0.0, 1.0
UISliderStep		REAL4 0.0
UISliderZeros		BPBool TRUE
UISmallButtons		BPBool FALSE
UIXFrom				SDWORD 0

UISubtitlesStr		BPPtr 0
UISubtitlesTimer	REAL4 0.0

UISTTPos			SDWORD 0
UISTTDir 			BPBool FALSE

UIInteractPrompt	BPPtr 0

UIDisplays			BPPtr 0	; Array of DWORD
UILangs				BPPtr 0	; Array of BYTE[32]
UIPresets			BPPtr 0	; Array of BYTE[32]
UIMSAA				BPPtr 0	; Array of DWORD
UIResolutions		BPPtr 0 ; Array of Vector2

.DATA?
UIResSize			BPPtr ?

.CODE
UI_DrawRectangle PROTO :DWORD, :DWORD
UI_MouseFocus PROTO :SDWORD, :SDWORD, :BYTE
UI_Text PROTO :BPPtr, :SDWORD, :SDWORD, :BPEnum, :BPEnum

FontSize MACRO FontWidth:REQ, FontHeight:REQ
	invoke Vector2Set, ADDR bpFontWidth, f(%(FontWidth*UI_SCALE)), \
	f(%(FontHeight*UI_SCALE))
ENDM

IFDEF MODE_DEBUG
UI_DrawDebug PROC EXPORT
	invoke glEnable, GL_ALPHA_TEST
	push bpFontWidth
	push bpFontHeight
	
	FontSize 2, 4
	
	call glLoadIdentity
	RenderText "FPS: ", 16, 8
	RenderText str$(FPS), 72, 8
	RenderText real4$(CamPos.X), 16, 32
	RenderText real4$(CamPos.Y), 112, 32
	RenderText real4$(CamPos.Z), 208, 32
	RenderText real4$(CamRot.Y), 304, 32
	RenderText real4$(PlrSpeed), 16, 56
	RenderText real4$(PlrSpeedScaled), 112, 56
	RenderText real4$(PlrHealth), 16, 80
	
	RenderText str$(FXAfterimageNow), 16, 104
	RenderText " AFTERIMAGE FRAMES", 32, 104
	
	RenderText "STACK:", 16, 128
	RenderText str$(psp), 112, 128
	IFDEF BP_TRACEABLE_HEAP
	RenderText "HEAP:", 16, 152
	RenderText str$(heapAllocated), 112, 152
	ENDIF
	RenderText "FPU:", 16, 176
	RenderText str$(rv(fpuGetStackTop)), 112, 176
	
	
	pop bpFontHeight
	pop bpFontWidth
	invoke glDisable, GL_ALPHA_TEST
	ret
UI_DrawDebug ENDP
ENDIF

; Various UI elements
UI_Button PROC EXPORT String:BPPtr, X:SDWORD, Y:SDWORD, ButtonAlign:BPEnum
	LOCAL xFrom:SDWORD, boolRet:BPPtr
	
	inc UIID
	
	mov boolRet, FALSE
	bpMEM32 xFrom, X
	.IF (ButtonAlign == BP_ALIGN_CENTER)
		.IF (UISmallButtons)
			sub xFrom, UI_BTN_WS / 2
		.ELSE
			sub xFrom, UI_BTN_W / 2
		.ENDIF
	.ENDIF
	invoke UI_MouseFocus, xFrom, Y, UIID
	
	; Draw background rect
	call glPushMatrix
	mov eax, X
	.IF (ButtonAlign == BP_ALIGN_CENTER)
		.IF (UISmallButtons)
			sub eax, UI_BTN_WS / 2
		.ELSE
			sub eax, UI_BTN_W / 2
		.ENDIF
	.ENDIF
	invoke glTranslatei, eax, Y, 0
	invoke glBindTexture, GL_TEXTURE_2D, 0
	.IF (UIDisabled)
		invoke glColor4fv, ADDR clGray
	.ELSE
		mov al, UIID
		.IF (UIPressed == al)
			invoke glColor4fv, ADDR clGray
		.ELSEIF (UIFocus == al)
			invoke glColor4fv, ADDR clLightGray
		.ELSE
			invoke glColor4fv, ADDR clWhite
		.ENDIF
	.ENDIF
	
	.IF (UISmallButtons)
		invoke UI_DrawRectangle, UI_BTN_WS, UI_BTN_H
	.ELSE
		invoke UI_DrawRectangle, UI_BTN_W, UI_BTN_H
	.ENDIF
	call glPopMatrix
	
	.IF !(UIDisabled)
		mov al, UIID
		.IF (UIFocus == al)
			.IF (UISmallButtons)
				mov UIFocusType, UI_BUTTON_SMALL
			.ELSE
				mbm UIFocusType, UIButtonType
			.ENDIF
		
			.IF (UIButtonJump)
				mov UIButtonJump, FALSE
				mov al, UIID
				.IF (UIComboboxMenu) && (al & 128)
					uiFindMenu:
					mov eax, Y
					sub eax, ScreenHalf.Y
					mov ecx, UIComboboxHeight
					shr ecx, 1
					add eax, ecx
					mov xFrom, eax
					
					mov ecx, UIComboboxHeight
					sub ecx, UI_BRD_M*2
					
					.IF !(rv(intInRange, eax, 0, ecx))
						invoke intSign, xFrom
						mov ecx, UI_BTN_H + UI_BTN_M
						imul ecx
						sub UIScroll, eax
						add Y, eax
						jmp uiFindMenu
					.ENDIF
				.ENDIF
			.ENDIF
			
			mov al, UIID
			.IF (InputUIConfirmT)
				mov UIPressed, al
			.ELSEIF (!InputUIConfirm) && (UIPressed == al)
				.IF (UIButtonType != UI_MAPPER)
					.IF (UIFocusType == UI_BUTTON) \
					|| (UIFocusType == UI_BUTTON_SMALL)
						mov UIFocus, 0
					.ENDIF
				.ENDIF
				mov UIPressed, 0
				mov boolRet, TRUE
			.ENDIF
		.ENDIF
	.ENDIF
	
	.IF (String)
		.IF (ButtonAlign == BP_ALIGN_LEFT)
			.IF (UISmallButtons)
				add X, UI_BTN_WS/2
			.ELSE
				add X, UI_BTN_W/2
			.ENDIF
		.ENDIF
		mov eax, UI_BTN_H
		fld bpFontHeight
		fistp xFrom
		sub eax, xFrom
		shr eax, 1
		add Y, eax
		.IF (UIDisabled)
			mov pax, OFFSET clDarkGray
			mov UIDisabled, FALSE
		.ELSE
			mov pax, OFFSET clBlack
		.ENDIF
		invoke glColor4fv, pax
		invoke UI_Text, String, X, Y, BP_ALIGN_CENTER, 0
	.ENDIF

	invoke glColor4fv, OFFSET clWhite
	mov pax, boolRet
	ret
UI_Button ENDP

UI_Checkbox PROC EXPORT String:BPPtr, X:SDWORD, Y:SDWORD, BoolPtr:BPPtr
	inc UIID
	
	push pbx
	
	mov bl, UIID
	
	sub X, UI_BTN_W/2
	
	.IF (UIDisabled)
		mov UIDisabled, FALSE
		invoke glColor4fv, OFFSET clGray
	.ELSE
		invoke UI_MouseFocus, X, Y, UIID
		
		.IF (UIFocus == bl)	
			mov UIFocusType, UI_CHECKBOX
			invoke glColor4fv, OFFSET clLightGray
			.IF (UIPressed == bl)
				invoke glColor4fv, OFFSET clGray
			.ENDIF
			
			.IF (InputUIConfirmT)
				mov UIPressed, bl
			.ELSEIF (!InputUIConfirm) && (UIPressed == bl)
				mov UIPressed, 0
				mov pax, BoolPtr
				.IF (BPBool PTR [pax])
					mov BPBool PTR [pax], FALSE
				.ELSE
					mov BPBool PTR [pax], TRUE
				.ENDIF
				invoke Settings_SetOption, BoolPtr
			.ENDIF
		.ELSE
			invoke glColor4fv, OFFSET clWhite
		.ENDIF
	.ENDIF
	
	call glPushMatrix
	invoke glBindTexture, GL_TEXTURE_2D, 0
	invoke glTranslatei, X, Y, 0
	invoke UI_DrawRectangle, UI_BTN_H, UI_BTN_H
	
	mov pax, BoolPtr
	.IF (BPBool PTR [pax])
		invoke glTranslatei, (UI_BTN_H - 16)/2, (UI_BTN_H - 16)/2, 0
		invoke glScalef, f(16), f(16), 0
		invoke glBindTexture, GL_TEXTURE_2D, TexUICircle
		invoke glEnable, GL_ALPHA_TEST
		invoke glCallList, ScreenQuad
		invoke glDisable, GL_ALPHA_TEST
	.ENDIF
	call glPopMatrix
	
	add X, UI_BTN_H + UI_BTN_M
	mov eax, UI_BTN_H
	fld bpFontHeight
	sub esp, 4
	fistp DWORD PTR [esp]
	pop ecx
	sub eax, ecx
	shr eax, 1
	add Y, eax
	invoke UI_Text, String, X, Y, BP_ALIGN_LEFT, 0
	
	pop pbx
	ret
UI_Checkbox ENDP

UI_Combobox PROC EXPORT String:BPPtr, X:SDWORD, Y:SDWORD, CBMenu:SDWORD
	push pbx
	xor pbx, pbx
	
	pushb UIButtonType
	mov UIButtonType, UI_COMBOBOX
	invoke UI_Button, String, X, Y, BP_ALIGN_CENTER
	.IF (al)
		.IF (UIComboboxMenu == -1)
			fld1
			fsub UIComboboxXLerp
			fstp UIComboboxXLerp
		.ELSEIF !(UIComboboxMenu)
			mov UIComboboxXLerp, 0
		.ENDIF
		
		bpMEM32 UIComboboxMenu, CBMenu
		mov UIFocus, 129
		mbm UIFocusBeforePopup, UIID
		mov pbx, TRUE

		mov UIComboboxCount, 0
		mov UIComboboxHeight, UI_BRD_M*2
		.IF (UIComboboxNames)
			invoke bpFree, bpDefHeap, 0, UIComboboxNames
			mov UIComboboxNames, 0
		.ENDIF
		mov UIComboboxSelected, 0
		mov UIScrollable, FALSE
	.ENDIF
	popb UIButtonType
	call glPushMatrix
	add X, UI_BTN_W/2 - 32
	add Y, (UI_BTN_H-16)/2
	invoke glTranslatei, X, Y, 0
	invoke glScalef, f(16), f(16), 0
	invoke glBindTexture, GL_TEXTURE_2D, TexUIArrow
	invoke glEnable, GL_ALPHA_TEST
	invoke glCallList, ScreenQuad
	invoke glDisable, GL_ALPHA_TEST
	call glPopMatrix
	
	mov pax, pbx
	pop pbx
	ret
UI_Combobox ENDP

; Copy string to UIComboboxNames
UI_ComboboxAdd PROC EXPORT String:BPPtr
	LOCAL offs:BPPtr
	
	.IF (UIComboboxNames)
		mov pax, UIComboboxCount
		shl pax, 5
		mov offs, pax
		add pax, 32
		invoke bpReAlloc, bpDefHeap, 0, UIComboboxNames, pax
		mov UIComboboxNames, pax
		add offs, pax
	.ELSE
		mov UIComboboxNames, rv(bpMalloc, bpDefHeap, 0, 32)
		mov offs, pax
	.ENDIF
	invoke RtlMoveMemory, offs, String, 32
	inc UIComboboxCount
	.IF (UIComboboxHeight < UI_BRD_M*2 + UI_BTN_H*UI_CB_MAX + UI_BTN_M*(UI_CB_MAX-1))
		.IF (UIComboboxHeight != UI_BRD_M*2)
			add UIComboboxHeight, UI_BTN_M
		.ENDIF
		add UIComboboxHeight, UI_BTN_H
	.ELSE
		mov UIScrollable, TRUE
	.ENDIF
	ret
UI_ComboboxAdd ENDP

UI_ComboboxChoose PROC EXPORT ItemID:BYTE
	dec ItemID
	and ItemID, 127
	SWITCH UIComboboxMenu
		CASE UICB_LANGUAGE
			movzx pax, ItemID
			shl pax, 5
			add pax, UILangs
			invoke RtlMoveMemory, ADDR SettingsMiscLanguage, pax, 32
			
			invoke WritePrivateProfileStringA, ADDR SettingsIniMisc, \
			ADDR SettingsIniLanguage, ADDR SettingsMiscLanguage, \
			ADDR SettingsIniPathAbs
			
			invoke Settings_SetOption, OFFSET SettingsMiscLanguage
			call UI_HandleMenuEscape
			
			invoke bpFree, bpDefHeap, 0, UILangs
			mov UILangs, 0
			
		CASE UICB_RESOLUTION
			movzx pax, ItemID
			shl pax, 3
			add pax, UIResolutions
			invoke Vector2Copy, ADDR SettingsGraphicsResolution, pax
			invoke Settings_SetOption, OFFSET SettingsGraphicsResolution
			call UI_HandleMenuEscape
			
			invoke bpFree, bpDefHeap, 0, UIResolutions
			mov UIResolutions, 0
		CASE UICB_DISPLAYMODE
			.IF (ItemID == 0)
				mov SettingsGraphicsWindowMode, BP_WINDOW_MODE_WINDOWED
				invoke Settings_SetOption, OFFSET SettingsGraphicsWindowMode
			.ELSEIF (ItemID == 1)
				mov SettingsGraphicsWindowMode, BP_WINDOW_MODE_FULLSCREEN
				invoke Settings_SetOption, OFFSET SettingsGraphicsWindowMode
			.ELSEIF (ItemID == 2)
				mov SettingsGraphicsWindowMode, BP_WINDOW_MODE_FULLSCREEN_EX
				invoke Settings_SetOption, OFFSET SettingsGraphicsWindowMode
			.ENDIF
			call UI_HandleMenuEscape
		CASE UICB_DISPLAYDEV
			movzx pax, ItemID
			shl pax, 2
			add pax, UIDisplays
			bpMEM32 SettingsGraphicsDisplay, DWORD PTR [pax]
			invoke Settings_SetOption, OFFSET SettingsGraphicsDisplay
			call UI_HandleMenuEscape
			
			invoke bpFree, bpDefHeap, 0, UIDisplays
			mov UIDisplays, 0
		CASE UICB_MSAA
			movzx pax, ItemID
			shl pax, 2
			add pax, UIMSAA
			bpMEM32 SettingsGraphicsMSAA, DWORD PTR [pax]
			invoke Settings_SetOption, OFFSET SettingsGraphicsMSAA
			call UI_HandleMenuEscape
			
			mov UIPopupMenu, UIPP_RESTART
			
			invoke bpFree, bpDefHeap, 0, UIMSAA
			mov UIMSAA, 0
	ENDSW
	ret
UI_ComboboxChoose ENDP

UI_ComboboxJumpToSelected PROC EXPORT
	.IF (UIComboboxSelected) && (UIScrollable)
		mbm UIFocus, UIComboboxSelected
		mov UIButtonJump, TRUE
	.ENDIF
	ret
UI_ComboboxJumpToSelected ENDP

UI_ComboboxHas PROC EXPORT String:BPPtr
	LOCAL has:BPPtr
	
	mov has, FALSE
	push pbx
	xor pbx, pbx
	.WHILE (pbx < UIComboboxCount)
		mov pdx, pbx
		shl pdx, 5
		add pdx, UIComboboxNames
		
		mov pcx, String
		
		cmpLoop:
		mov al, BYTE PTR [pcx]
		.IF (BYTE PTR [pdx] != al)
			inc pbx
			.CONTINUE
		.ELSEIF (BYTE PTR [pdx] == 0)
			mov has, TRUE
			.BREAK
		.ENDIF
		inc pcx
		inc pdx
		jmp cmpLoop
		
		inc pbx
	.ENDW
	pop pbx
	mov pax, has
	ret
UI_ComboboxHas ENDP

UI_HR PROC EXPORT X:SDWORD, Y:SDWORD
	sub X, UI_BTN_W/2
	add Y, (UI_HR_H - UI_HR_T)/2
	
	call glPushMatrix
	invoke glTranslatei, X, Y, 0
	invoke glScalei, UI_BTN_W, UI_HR_T, 1
	invoke glBindTexture, GL_TEXTURE_2D, 0
	invoke glColor4fv, OFFSET clDarkGray
	invoke glCallList, ScreenQuad
	call glPopMatrix
	invoke glColor4fv, OFFSET clWhite
	ret
UI_HR ENDP

UI_KeyMapper PROC EXPORT BindType:BPEnum, X:SDWORD, Y:SDWORD, MapPtr:BPPtr, \
ActionStrPtr:BPPtr
	pushb UIButtonType
	mov UIButtonType, UI_MAPPER
	invoke UI_Button, 0, X, Y, BP_ALIGN_CENTER
	.IF (al)
		mbm UIBinding, BindType
		bpMEM32 UIBindAction, MapPtr
		bpMEM32 UIBindStr, ActionStrPtr
		mbm UIFocusBeforePopup, UIFocus
		mov UIPopupMenu, UIPP_BIND
	.ENDIF
	popb UIButtonType
	call glPushMatrix
	sub X, 4*UI_SCALE
	add Y, (UI_BTN_H-8*UI_SCALE)/2
	invoke glTranslatei, X, Y, 0
	invoke glScalef, f(%(8*UI_SCALE)), f(%(8*UI_SCALE)), 0
	mov pax, MapPtr
	movzx pax, BYTE PTR [pax]
	shl pax, 2
	.IF (BindType == BIND_KEY_MOUSE)
		;add pax, OFFSET FntKeys
		mov pax, FntKeys[pax]
	.ELSEIF (BindType == BIND_JOYSTICK)
		;add pax, OFFSET FntJoystick
		.IF (XInput)
			mov pax, FntXB[pax]
		.ELSE
			mov pax, FntPS[pax]
		.ENDIF
	.ENDIF
	invoke glBindTexture, GL_TEXTURE_2D, pax
	invoke glEnable, GL_BLEND
	invoke glBlendFunc, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA
	invoke glCallList, ScreenQuad
	invoke glDisable, GL_BLEND
	call glPopMatrix
	ret
UI_KeyMapper ENDP

UI_Slider PROC EXPORT String:BPPtr, X:SDWORD, Y:SDWORD, ValuePtr:BPPtr
	LOCAL xFrom:SDWORD, yFrom:SDWORD, boolRet:BPPtr
	
	inc UIID
	
	mov boolRet, FALSE
	push pbx
	mov bl, UIID
	
	mov eax, X
	sub eax, UI_BTN_W/2
	mov xFrom, eax
	mov eax, Y
	mov yFrom, eax
	
	push bpFontWidth
	push bpFontHeight
	FontSize 3, 6
	invoke glColor4fv, OFFSET clWhite
	invoke UI_Text, String, xFrom, yFrom, BP_ALIGN_LEFT, 0
	
	; Draw value text
	mov pax, ValuePtr
	mov eax, REAL4 PTR [pax]
	mov pcx, real4$(eax)
	push pcx
	IFDEF strlen
		invoke strlen, pcx
	ELSE
		invoke crt_strlen, pcx
	ENDIF
	pop pcx
	.IF (UISliderZeros)
		IFDEF BP_WININC
			; Dirty _gcvt tricks (add suppressed trailing)
			.IF (pax < 2)
				mov BYTE PTR [pcx+1], '.'
			.ENDIF
			.IF (pax < 3)
				mov BYTE PTR [pcx+2], '0'
			.ENDIF
			.IF (pax < 4)
				mov BYTE PTR [pcx+3], '0'
			.ENDIF
		ENDIF
		mov BYTE PTR [pcx+4], 0	; Keep fixed length of 4
	.ELSE
		IFNDEF BP_WININC
		IFNDEF BP_CUSTOM_INCLUDES
			; MASM tricks, as its real4$ doesn't suppress trailing
			dec pax
			.WHILE (pax)
				.IF (BYTE PTR [pcx+pax] == '0')
					mov BYTE PTR [pcx+pax], 0
					dec pax
				.ELSE
					.IF (BYTE PTR [pcx+pax]=='.') || (BYTE PTR [pcx+pax]==',')
						mov BYTE PTR [pcx+pax], 0
					.ENDIF
					.BREAK
				.ENDIF
			.ENDW
		ENDIF
		ENDIF
	.ENDIF
	mov eax, xFrom
	add eax, UI_BTN_W
	invoke UI_Text, pcx, eax, yFrom, BP_ALIGN_RIGHT, 0
	pop bpFontHeight
	pop bpFontWidth
	
	mov eax, Y
	add eax, (UI_BTN_H - UI_SLD_T) + (UI_SLD_T/2 - UI_SLD_H/2)
	mov yFrom, eax
	call glPushMatrix
	invoke glTranslatei, xFrom, yFrom, 0
	invoke glBindTexture, GL_TEXTURE_2D, 0
	invoke glColor4fv, OFFSET clDarkGray
	invoke UI_DrawRectangle, UI_BTN_W, UI_SLD_H
	invoke glColor4fv, OFFSET clWhite
	call glPopMatrix
	
	invoke UI_MouseFocus, xFrom, Y, bl
	
	.IF (UIDisabled)
		invoke glColor4fv, OFFSET clGray
		mov UIDisabled, FALSE
	.ELSE
		.IF (UIFocus == bl)	
			mov UIFocusType, UI_SLIDER
			invoke glColor4fv, OFFSET clLightGray
			.IF (UIPressed == bl)
				invoke glColor4fv, OFFSET clGray
				
				; dark wizardry in these calculations
				mov eax, bpMouseClient[0]
				sub eax, xFrom
				sub eax, UI_SLD_T/2
				push eax
				fild DWORD PTR [psp]	
				push UI_BTN_W - UI_SLD_T
				fidiv DWORD PTR [psp]
				add psp, SIZEOF BPPtr*2
				fld UISliderRange[4]	; Val * (Max - Min) + Min
				fsub UISliderRange[0]
				fmul
				fadd UISliderRange[0]
				mov pcx, ValuePtr
				fstp REAL4 PTR [pcx]
				mov REAL4 PTR [pcx], \
				rv(flClamp, REAL4 PTR [pcx], UISliderRange[0], UISliderRange[4])
				mov boolRet, TRUE
			.ENDIF
			
			.IF (InputUILeft || InputUIRight)
				.IF (UISliderZeros)
					fld UISliderStep
					fadd deltaUnscaled
					fstp UISliderStep
				.ELSE
					fld1
					fdiv deltaUnscaled
					fstp UISliderStep
				.ENDIF
				mov boolRet, TRUE
			.ELSE
				bpMEM32 UISliderStep, f(0.5)
			.ENDIF
			
			.IF (InputUILeft)
				mov pcx, ValuePtr
				fld REAL4 PTR [pcx]
				fld UISliderStep
				fmul deltaUnscaled
				fsub
				fstp REAL4 PTR [pcx]
				mov REAL4 PTR [pcx], \
				rv(flClamp, REAL4 PTR [pcx], UISliderRange[0], UISliderRange[4])
				
				.IF !(UISliderZeros)
					mov InputUILeft, FALSE
				.ENDIF
			.ELSEIF (InputUIRight)
				mov pcx, ValuePtr
				fld REAL4 PTR [pcx]
				fld UISliderStep
				fmul deltaUnscaled
				fadd
				fstp REAL4 PTR [pcx]
				mov REAL4 PTR [pcx], \
				rv(flClamp, REAL4 PTR [pcx], UISliderRange[0], UISliderRange[4])
				
				.IF !(UISliderZeros)
					mov InputUIRight, FALSE
				.ENDIF
			.ENDIF
			
			.IF (Keys[VK_LBUTTON] && InputUIConfirmT)
				mov UIPressed, bl
			.ELSEIF !(Keys[VK_LBUTTON]) && (UIPressed == bl)
				mov UIPressed, 0
			.ENDIF
		.ENDIF
	.ENDIF
	pop pbx
	
	call glPushMatrix
	sub yFrom, UI_SLD_T/2 - UI_SLD_H/2
	mov pax, ValuePtr
	fld REAL4 PTR [pax]
	fsub UISliderRange[0]
	fld UISliderRange[4]
	fsub UISliderRange[0]
	fdiv
	push UI_BTN_W - UI_SLD_T
	fimul DWORD PTR [psp]
	fistp DWORD PTR [psp]
	pop eax
	add xFrom, eax
	
	invoke glTranslatei, xFrom, yFrom, 0
	invoke UI_DrawRectangle, UI_SLD_T, UI_SLD_T
	call glPopMatrix
	
	invoke glColor4fv, OFFSET clWhite
	mov pax, boolRet
	ret
UI_Slider ENDP

UI_Text PROC EXPORT String:BPPtr, X:SDWORD, Y:SDWORD, HorAlign:BPEnum, \
VerAlign:BPEnum
	invoke glEnable, GL_ALPHA_TEST
	invoke bpRenderText, String, X, Y, HorAlign, VerAlign
	invoke glDisable, GL_ALPHA_TEST
	ret
UI_Text ENDP


UI_DrawComboboxMenu PROC EXPORT
	LOCAL menuHeight:DWORD, actualHeight:DWORD
	LOCAL xOffset:DWORD, yOffset:DWORD
	
	invoke glEnable, GL_STENCIL_TEST
	invoke glStencilFunc, GL_ALWAYS, 1, 0FFh
	invoke glStencilMask, 0FFh
	invoke glClear, GL_STENCIL_BUFFER_BIT
	
	call glPushMatrix	; Bounding box
	invoke glColorMask, GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE
	
	UI_MENU_CB_WIDTH	EQU UI_BTN_W + UI_BRD_M*2
	
	mov ebx, ScreenHalf.Y
	mov eax, UIComboboxHeight
	shr eax, 1	; /2
	sub ebx, eax
	invoke glTranslatei, ScreenHalf.X, ebx, 0
	mov eax, UI_MENU_CB_WIDTH
	.IF (UIScrollable)
		add eax, UI_SLD_H*2
	.ENDIF
	invoke UI_DrawRectangle, eax, UIComboboxHeight
	invoke glColorMask, GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE
	
	.IF (UIScrollable)	; Scrollbar
		; fucking insanity down here I don't know what these calculations are
		invoke glTranslatei, UI_MENU_CB_WIDTH, UI_BRD_M, 0
		invoke glColor4fv, OFFSET clDarkGray
		mov eax, UIComboboxHeight
		sub eax, UI_BRD_M*2
		invoke UI_DrawRectangle, UI_SLD_H, eax
		invoke glColor4fv, OFFSET clWhite
		
		; Convert UIScroll into scrollbar tack position somehow???
		.IF (UIScrollLimit)	; Check for 0 to not trigger c0000090...
			fild UIScroll
			fidiv UIScrollLimit
			fild UIComboboxHeight	; ...which gets triggered here??
			push UI_SLD_T*3 + UI_BRD_M*2	; UI_SLD_T*3 is scroll tack height
			fisub BPPtr PTR [psp]
			pop pax
			fmul
			fistp xOffset
		.ENDIF
		mov eax, -(UI_SLD_T/2 - UI_SLD_H/2)	; what the fuck
		invoke glTranslatei, eax, xOffset, 0
		
		; Check if mouse is in range of the scrollbar line
		mov eax, ScreenHalf.X
		add eax, UI_MENU_CB_WIDTH - (UI_SLD_T/2 - UI_SLD_H/2)
		mov ecx, eax
		add ecx, UI_SLD_T
		invoke intInRange, bpMouseClient[0], eax, ecx
		.IF (al)
			mov eax, ScreenHalf.Y
			mov ecx, UIComboboxHeight
			shr ecx, 1
			sub eax, ecx
			add eax, UI_BRD_M
			mov ecx, eax
			add ecx, UIComboboxHeight
			sub ecx, UI_BRD_M*2
			invoke intInRange, bpMouseClient[4], eax, ecx
			.IF (al)
				.IF (!UIScrollPressed)
					invoke glColor4fv, OFFSET clLightGray
					.IF (Keys[VK_LBUTTON])
						mov UIScrollPressed, TRUE
					.ENDIF
				.ENDIF
			.ENDIF
		.ENDIF
		
		.IF (UIScrollPressed)
			invoke glColor4fv, OFFSET clGray
			
			fild bpMouseClient[4]
			fisub ScreenHalf.Y
			push (UI_SLD_T*3)/2 + UI_BRD_M
			fisub BPPtr PTR [psp]
			pop pax
			fild UIComboboxHeight
			fmul f(0.5)
			fadd
			fild UIComboboxHeight
			push UI_SLD_T*3 + UI_BRD_M*2	; UI_SLD_T*3 is scroll tack height
			fisub BPPtr PTR [psp]
			pop pax
			fdiv
			fimul UIScrollLimit
			fistp UIScroll
			; shut up. it works. don't fucking touch a thing
			
			.IF !(Keys[VK_LBUTTON])
				mov UIScrollPressed, FALSE
			.ENDIF
		.ENDIF
		
		invoke UI_DrawRectangle, UI_SLD_T, UI_SLD_T*3
		invoke glColor4fv, OFFSET clWhite
	.ENDIF
	call glPopMatrix
	mov UIScroll, rv(intClamp, UIScroll, 0, UIScrollLimit)
	
	
	
	bpMEM32 xOffset, ScreenHalf.X
	add xOffset, UI_BRD_M
	add ebx, UI_BRD_M
	
	invoke glStencilFunc, GL_EQUAL, 1, 0FFh
	invoke glStencilMask, 0
	xor pcx, pcx
	.WHILE (pcx < UIComboboxCount)
		push pcx
		
		shl pcx, 5
		add pcx, UIComboboxNames
		mov edx, ebx
		.IF (UIScrollable)
			sub edx, UIScroll
		.ENDIF
		mov yOffset, edx
		invoke UI_Button, pcx, xOffset, yOffset, BP_ALIGN_LEFT
		.IF (pax)
			invoke UI_ComboboxChoose, UIID
		.ENDIF
		
		mov al, UIComboboxSelected
		.IF (al == UIID)
			invoke glBindTexture, GL_TEXTURE_2D, TexUICircle
			call glPushMatrix
			mov eax, xOffset
			add eax, UI_BTN_W - 32
			add yOffset, (UI_BTN_H-16)/2
			invoke glTranslatei, eax, yOffset, 0
			invoke glScalef, f(16), f(16), 0
			invoke glEnable, GL_ALPHA_TEST
			invoke glCallList, ScreenQuad
			invoke glDisable, GL_ALPHA_TEST
			call glPopMatrix
		.ENDIF
		
		add ebx, UI_BTN_H + UI_BTN_M
		
		pop pcx
		inc pcx
	.ENDW
	sub ebx, ScreenHalf.Y
	mov eax, UIComboboxHeight
	shr eax, 1
	sub eax, UI_BRD_M - UI_BTN_M
	sub ebx, eax
	mov UIScrollLimit, ebx
	
	invoke glDisable, GL_STENCIL_TEST
	ret
UI_DrawComboboxMenu ENDP

UI_DrawFullscreen PROC EXPORT Alpha:REAL4
	invoke glEnable, GL_BLEND
	call glPushMatrix
	invoke glScalef, ScreenSizeF.X, ScreenSizeF.Y, f(1)
	invoke glBlendFunc, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA
	invoke glBindTexture, GL_TEXTURE_2D, 0
	invoke glColor4f, 0, 0, 0, Alpha
	invoke glCallList, ScreenQuad
	call glPopMatrix
	invoke glDisable, GL_BLEND
	ret
UI_DrawFullscreen ENDP

UI_DrawMenuPause PROC EXPORT
	UI_MENU_PAUSE_HEIGHT	EQU UI_BTN_H*4 + UI_BTN_M*3
	mov ebx, ScreenHalf.Y
	sub ebx, UI_MENU_PAUSE_HEIGHT/2
	
	invoke UI_Text, StrMenuPaused, ScreenHalf.X, ebx, BP_ALIGN_CENTER, 0
	add ebx, UI_BTN_H + UI_BTN_M
	
	invoke UI_Button, StrMenuResume, ScreenHalf.X, ebx, BP_ALIGN_CENTER
	.IF (al)
		call UI_HandleMenuEscape
	.ENDIF
	add ebx, UI_BTN_H + UI_BTN_M
	
	invoke UI_Button, StrMenuSettings, ScreenHalf.X, ebx, BP_ALIGN_CENTER
	.IF (al)
		mov UIState, UI_STATE_MENU_SETTINGS
	.ENDIF
	add ebx, UI_BTN_H + UI_BTN_M
	
	invoke UI_Button, StrMenuQuit, ScreenHalf.X, ebx, BP_ALIGN_CENTER
	.IF (al)
		mov UIPopupMenu, UIPP_EXIT
	.ENDIF
	ret
UI_DrawMenuPause ENDP

UI_DrawMenuSettings PROC EXPORT
	LOCAL fFind:WIN32_FIND_DATAA, hFind:BPPtr, langStr[32]:BYTE, hFile:BPPtr
	LOCAL dwBytesRead:DWORD	; Needed for older WinAPI
	
	UI_MENU_SETTINGS_HEIGHT	EQU UI_BTN_H*5 + UI_BTN_M*3 + UI_HR_H
	
	mov ebx, ScreenHalf.Y
	sub ebx, UI_MENU_SETTINGS_HEIGHT/2
	
	invoke UI_Button, StrMenuGraphics, UIXFrom, ebx, BP_ALIGN_CENTER
	.IF (al)
		.IF (UIComboboxMenu)
			mov UIComboboxMenu, 0
		.ENDIF
		mov UIState, UI_STATE_MENU_SETTINGS_GRAPHICS
		mov SettingsChanged, FALSE
	.ENDIF
	add ebx, UI_BTN_H + UI_BTN_M
	
	invoke UI_Button, StrMenuControls, UIXFrom, ebx, BP_ALIGN_CENTER
	.IF (al)
		.IF (UIComboboxMenu)
			mov UIComboboxMenu, 0
		.ENDIF
		mov UIState, UI_STATE_MENU_SETTINGS_CONTROLS
		mov SettingsChanged, FALSE
	.ENDIF
	add ebx, UI_BTN_H + UI_BTN_M
	
	invoke Vector2Set, ADDR UISliderRange, f(0), f(2)
	invoke UI_Slider, StrMenuVolume, UIXFrom, ebx, OFFSET SettingsAudioVolume
	.IF (al)
		invoke Settings_SetOption, OFFSET SettingsAudioVolume
		invoke Settings_Save, OFFSET SettingsIniAudio
	.ENDIF
	add ebx, UI_BTN_H + UI_BTN_M
	
	invoke UI_Combobox, StrMenuLanguage, UIXFrom, ebx, UICB_LANGUAGE
	.IF (pax)
		invoke FindFirstFile, OFFSET SettingsLangPath, ADDR fFind
		mov hFind, pax
		
		uiLanguageEnum:
		.IF !(fFind.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
			invoke RtlZeroMemory, ADDR langStr, 32
			
			invoke bpArrayAppend, UILangs, ADDR fFind.cFileName, 32
			mov UILangs, pax
			
			; Insert dir path before filename
			invoke RtlMoveMemory, ADDR fFind.cFileName + LANGOFFSET,
			ADDR fFind.cFileName, MAX_PATH - LANGOFFSET
			invoke RtlMoveMemory, ADDR fFind.cFileName,
			OFFSET SettingsLangPath, LANGOFFSET
			
			print ADDR fFind.cFileName, 9
			
			invoke CreateFile, ADDR fFind.cFileName, GENERIC_READ, \
			FILE_SHARE_READ, 0, OPEN_EXISTING, FILE_FLAG_SEQUENTIAL_SCAN, 0
			mov hFile, pax
			
			invoke ReadFile, hFile, ADDR langStr, 32, ADDR dwBytesRead, 0
			invoke CloseHandle, hFile
			
			; Replace newline char with 0 to terminate string
			xor pax, pax
			.WHILE (pax < 32)
				.IF (langStr[pax] == 13) || (langStr[pax] == 10)
					mov langStr[pax], 0
					.BREAK
				.ENDIF
				inc pax
			.ENDW
			
			print ADDR langStr, 13, 10
			
			invoke UI_ComboboxAdd, ADDR langStr
		.ENDIF
		invoke FindNextFile, hFind, ADDR fFind
		cmp pax, 0
		jne uiLanguageEnum
		
		invoke FindClose, hFind
	.ENDIF
	add ebx, UI_BTN_H
	
	invoke UI_HR, UIXFrom, ebx
	add ebx, UI_HR_H
	
	invoke UI_Button, StrMenuBack, UIXFrom, ebx, BP_ALIGN_CENTER
	.IF (al)
		call UI_HandleMenuEscape
	.ENDIF
	ret
UI_DrawMenuSettings ENDP

UI_DrawMenuSettingsControls PROC EXPORT
	UI_MENU_CONTROLS_HEIGHT	EQU UI_BTN_H*6 + UI_BTN_M*3 + UI_HR_H*3
	
	mov ebx, ScreenHalf.Y
	sub ebx, UI_MENU_CONTROLS_HEIGHT/2
	
	; Mouse section
	invoke Vector2Set, ADDR UISliderRange, f(0.05), f(2.5)
	invoke UI_Slider, StrMenuMouseSens, UIXFrom, ebx, \
	OFFSET SettingsControlsMouseSensitivity
	.IF (al)
		invoke Settings_SetOption, OFFSET SettingsControlsMouseSensitivity
	.ENDIF
	add ebx, UI_BTN_H + UI_BTN_M
	
	IFDEF BP_COMPATIBILITY_W9X
		mov UIDisabled, TRUE
	ENDIF
	invoke UI_Checkbox, StrMenuMouseRaw, UIXFrom, ebx, \
	OFFSET SettingsControlsRawMouse
	add ebx, UI_BTN_H
	
	invoke UI_HR, UIXFrom, ebx
	add ebx, UI_HR_H
	
	; Joystick section
	invoke UI_Checkbox, StrMenuUseGpad, UIXFrom, ebx, \
	OFFSET SettingsControlsJoystick
	add ebx, UI_BTN_H + UI_BTN_M
	
	invoke Vector2Set, ADDR UISliderRange, f(0.5), f(8.0)
	invoke UI_Slider, StrMenuGpadSpd, UIXFrom, ebx, \
	OFFSET SettingsControlsJoystickSpeed
	.IF (al)
		invoke Settings_SetOption, OFFSET SettingsControlsJoystickSpeed
	.ENDIF
	add ebx, UI_BTN_H
	
	invoke UI_HR, UIXFrom, ebx
	add ebx, UI_HR_H
	
	; Bindings
	invoke UI_Button, StrMenuBindings, UIXFrom, ebx, BP_ALIGN_CENTER
	.IF (al)
		.IF (UIComboboxMenu)
			mov UIComboboxMenu, 0
		.ENDIF
		mov UIState, UI_STATE_MENU_SETTINGS_CONTROLS_BINDINGS
	.ENDIF
	add ebx, UI_BTN_H
	
	invoke UI_HR, UIXFrom, ebx
	add ebx, UI_HR_H
	
	mov UISmallButtons, TRUE
	mov edx, UIXFrom
	sub edx, UI_BTN_WS + UI_BTN_M/2
	invoke UI_Button, StrMenuCancel, edx, ebx, BP_ALIGN_LEFT
	.IF (al)
		.IF (UIComboboxMenu > 0)
			call UI_HandleMenuEscape
		.ENDIF
		call UI_HandleMenuEscape
	.ENDIF
	
	mov edx, UIXFrom
	add edx, UI_BTN_M/2
	invoke UI_Button, StrMenuOK, edx, ebx, BP_ALIGN_LEFT
	.IF (al)
		invoke Settings_Save, OFFSET SettingsIniControls
		.IF (UIComboboxMenu > 0)
			call UI_HandleMenuEscape
		.ENDIF
		call UI_HandleMenuEscape
	.ENDIF
	
	mov UISmallButtons, FALSE
	
	ret
UI_DrawMenuSettingsControls ENDP

UI_DrawMenuSettingsControlsBindings PROC EXPORT
	LOCAL leftPos:REAL4, rightPos:REAL4
	
	UI_MENU_BINDINGS_WIDTH	EQU UI_BTN_WS*3 + UI_BTN_M*2
	UI_MENU_BINDINGS_HEIGHT	EQU UI_BTN_H*14 + UI_BTN_M*11 + UI_HR_H*2
	
	mov ebx, ScreenHalf.Y
	sub ebx, UI_MENU_BINDINGS_HEIGHT/2
	
	mov eax, ScreenHalf.X
	sub eax, UI_MENU_BINDINGS_WIDTH/2
	mov leftPos, eax
	add eax, UI_BTN_WS*2 + UI_BTN_M*2 + (UI_BTN_WS/2)
	mov rightPos, eax
	
	mov eax, ScreenHalf.X
	sub eax, UI_BTN_WS + UI_BTN_M
	invoke UI_Text, StrMenuAction, eax, ebx, BP_ALIGN_CENTER, 0
	invoke UI_Text, StrMenuKey, ScreenHalf.X, ebx, BP_ALIGN_CENTER, 0
	mov eax, ScreenHalf.X
	add eax, UI_BTN_WS + UI_BTN_M
	invoke UI_Text, StrMenuGamepad, eax, ebx, BP_ALIGN_CENTER, 0
	add ebx, UI_BTN_H
	
	invoke UI_HR, UIXFrom, ebx
	add ebx, UI_HR_H
	
	mov UISmallButtons, TRUE
	
	; Up
	invoke UI_Text, StrMenuInUp, leftPos, ebx, BP_ALIGN_LEFT, 0
	invoke UI_KeyMapper, BIND_KEY_MOUSE, ScreenHalf.X, ebx,	ADDR IBUp, \
	StrMenuInUp
	invoke UI_KeyMapper, BIND_JOYSTICK, rightPos, ebx,		ADDR JBUp, \
	StrMenuInUp
	add ebx, UI_BTN_H + UI_BTN_M
	
	; Down
	invoke UI_Text, StrMenuInDown, leftPos, ebx, BP_ALIGN_LEFT, 0
	invoke UI_KeyMapper, BIND_KEY_MOUSE, ScreenHalf.X, ebx,	ADDR IBDown, \
	StrMenuInDown
	invoke UI_KeyMapper, BIND_JOYSTICK, rightPos, ebx,		ADDR JBDown, \
	StrMenuInDown
	add ebx, UI_BTN_H + UI_BTN_M
	
	; Left
	invoke UI_Text, StrMenuInLeft, leftPos, ebx, BP_ALIGN_LEFT, 0
	invoke UI_KeyMapper, BIND_KEY_MOUSE, ScreenHalf.X, ebx,	ADDR IBLeft, \
	StrMenuInLeft
	invoke UI_KeyMapper, BIND_JOYSTICK, rightPos, ebx,		ADDR JBLeft, \
	StrMenuInLeft
	add ebx, UI_BTN_H + UI_BTN_M
	
	; Right
	invoke UI_Text, StrMenuInRight, leftPos, ebx, BP_ALIGN_LEFT, 0
	invoke UI_KeyMapper, BIND_KEY_MOUSE, ScreenHalf.X, ebx,	ADDR IBRight, \
	StrMenuInRight
	invoke UI_KeyMapper, BIND_JOYSTICK, rightPos, ebx,		ADDR JBRight, \
	StrMenuInRight
	add ebx, UI_BTN_H + UI_BTN_M
	
	; Look up
	invoke UI_Text, StrMenuInLookUp, leftPos, ebx, BP_ALIGN_LEFT, 0
	invoke UI_KeyMapper, BIND_KEY_MOUSE, ScreenHalf.X, ebx,	ADDR IBLookUp, \
	StrMenuInLookUp
	invoke UI_KeyMapper, BIND_JOYSTICK, rightPos, ebx,		ADDR JBLookUp, \
	StrMenuInLookUp
	add ebx, UI_BTN_H + UI_BTN_M
	
	; Look down
	invoke UI_Text, StrMenuInLookDown, leftPos, ebx, BP_ALIGN_LEFT, 0
	invoke UI_KeyMapper, BIND_KEY_MOUSE, ScreenHalf.X, ebx,	ADDR IBLookDown, \
	StrMenuInLookDown
	invoke UI_KeyMapper, BIND_JOYSTICK, rightPos, ebx,		ADDR JBLookDown, \
	StrMenuInLookDown
	add ebx, UI_BTN_H + UI_BTN_M
	
	; Look left
	invoke UI_Text, StrMenuInLookLeft, leftPos, ebx, BP_ALIGN_LEFT, 0
	invoke UI_KeyMapper, BIND_KEY_MOUSE, ScreenHalf.X, ebx,	ADDR IBLookLeft, \
	StrMenuInLookLeft
	invoke UI_KeyMapper, BIND_JOYSTICK, rightPos, ebx,		ADDR JBLookLeft, \
	StrMenuInLookLeft
	add ebx, UI_BTN_H + UI_BTN_M
	
	; Look right
	invoke UI_Text, StrMenuInLookRight, leftPos, ebx, BP_ALIGN_LEFT, 0
	invoke UI_KeyMapper, BIND_KEY_MOUSE, ScreenHalf.X, ebx,	ADDR IBLookRight, \
	StrMenuInLookRight
	invoke UI_KeyMapper, BIND_JOYSTICK, rightPos, ebx,		ADDR JBLookRight, \
	StrMenuInLookRight
	add ebx, UI_BTN_H + UI_BTN_M
	
	; Crouch
	invoke UI_Text, StrMenuInCrouch, leftPos, ebx, BP_ALIGN_LEFT, 0
	invoke UI_KeyMapper, BIND_KEY_MOUSE, ScreenHalf.X, ebx,	ADDR IBCrouch, \
	StrMenuInCrouch
	invoke UI_KeyMapper, BIND_JOYSTICK, rightPos, ebx,		ADDR JBCrouch, \
	StrMenuInCrouch
	add ebx, UI_BTN_H + UI_BTN_M
	
	; Glyph
	invoke UI_Text, StrMenuInGlyph, leftPos, ebx, BP_ALIGN_LEFT, 0
	invoke UI_KeyMapper, BIND_KEY_MOUSE, ScreenHalf.X, ebx,	ADDR IBGlyph, \
	StrMenuInGlyph
	invoke UI_KeyMapper, BIND_JOYSTICK, rightPos, ebx,		ADDR JBGlyph, \
	StrMenuInGlyph
	add ebx, UI_BTN_H + UI_BTN_M
	
	; Action
	invoke UI_Text, StrMenuInAction, leftPos, ebx, BP_ALIGN_LEFT, 0
	invoke UI_KeyMapper, BIND_KEY_MOUSE, ScreenHalf.X, ebx,	ADDR IBAction, \
	StrMenuInAction
	invoke UI_KeyMapper, BIND_JOYSTICK, rightPos, ebx,		ADDR JBAction, \
	StrMenuInAction
	add ebx, UI_BTN_H + UI_BTN_M
	
	; Confirm
	invoke UI_Text, StrMenuInConfirm, leftPos, ebx, BP_ALIGN_LEFT, 0
	invoke UI_KeyMapper, BIND_KEY_MOUSE, ScreenHalf.X, ebx,	ADDR IBConfirm, \
	StrMenuInConfirm
	invoke UI_KeyMapper, BIND_JOYSTICK, rightPos, ebx,		ADDR JBConfirm, \
	StrMenuInConfirm
	add ebx, UI_BTN_H
	
	
	mov UISmallButtons, FALSE
	
	invoke UI_HR, UIXFrom, ebx
	add ebx, UI_HR_H
	
	invoke UI_Button, StrMenuBack, UIXFrom, ebx, BP_ALIGN_CENTER
	.IF (al)
		call UI_HandleMenuEscape
	.ENDIF
	ret
UI_DrawMenuSettingsControlsBindings ENDP

UI_DrawMenuSettingsGraphics PROC EXPORT
	LOCAL dm:DEVMODEAFIX, res:Vector2, resEnum:DWORD, strPtr:BPPtr
	LOCAL nameStr[32]:BYTE, devNamePtr:BPPtr
	
	UI_MENU_GRAPHICS_HEIGHT	EQU UI_BTN_H*7 + UI_BTN_M*5 + UI_HR_H*2
	
	mov ebx, ScreenHalf.Y
	sub ebx, UI_MENU_GRAPHICS_HEIGHT/2
	
	invoke UI_Combobox, StrMenuResolution, UIXFrom, ebx, UICB_RESOLUTION
	.IF (al)
		mov UIScroll, 0
		
		mov dm.dmSize, SIZEOF DEVMODEAFIX
		invoke Vector2Set, ADDR res, 0, 0
		
		mov UIResSize, 0
		mov resEnum, 0			; to enumerate through all
		
		uiGraphicsResEnum:
		mov pax, FMain.DisplayDevice
		mov pcx, SIZEOF BPDisplayDevice
		mul pcx
		lea pax, bpDisplayDevices[pax].RawName
		mov devNamePtr, pax
		invoke EnumDisplaySettingsA, devNamePtr, resEnum, ADDR dm
		.IF (al)
			invoke Vector2Set, ADDR res, dm.dmPelsWidth, dm.dmPelsHeight
			
			invoke RtlZeroMemory, ADDR nameStr, 32
			invoke IntToStr, ADDR nameStr, dm.dmPelsWidth
			mov nameStr[pax], 'x'
			invoke IntToStr, ADDR nameStr[pax+1], dm.dmPelsHeight
			
			.IF (rv(UI_ComboboxHas, ADDR nameStr))
				inc resEnum
				jmp uiGraphicsResEnum
			.ENDIF
			
			invoke bpArrayAppend, UIResolutions, ADDR res, SIZEOF Vector2
			mov UIResolutions, pax
			
			invoke UI_ComboboxAdd, ADDR nameStr
			
			mov ecx, SettingsGraphicsResolution[0]
			mov edx, SettingsGraphicsResolution[4]
			
			.IF (ecx == res.X) && (edx == res.Y)
				mov eax, UIComboboxCount
				or al, 128
				mov UIComboboxSelected, al
			.ENDIF
			
			add UIResSize, SIZEOF Vector2
			
			; loop
			inc resEnum
			jmp uiGraphicsResEnum
		.ENDIF
		call UI_ComboboxJumpToSelected
	.ENDIF
	add ebx, UI_BTN_H + UI_BTN_M
	
	invoke UI_Combobox, StrMenuDisplayMode, UIXFrom, ebx, UICB_DISPLAYMODE
	.IF (al)
		invoke UI_ComboboxAdd, StrMenuWindowed
		invoke UI_ComboboxAdd, StrMenuFullscreen
		invoke UI_ComboboxAdd, StrMenuExclusive
		.IF (SettingsGraphicsWindowMode == BP_WINDOW_MODE_WINDOWED)
			mov UIComboboxSelected, 129
		.ELSEIF (SettingsGraphicsWindowMode == BP_WINDOW_MODE_FULLSCREEN)
			mov UIComboboxSelected, 130
		.ELSEIF (SettingsGraphicsWindowMode == BP_WINDOW_MODE_FULLSCREEN_EX)
			mov UIComboboxSelected, 131
		.ENDIF
	.ENDIF
	add ebx, UI_BTN_H + UI_BTN_M
	
	invoke UI_Combobox, StrMenuDisplayDev, UIXFrom, ebx, UICB_DISPLAYDEV
	.IF (al)	
		push pbx
		xor pbx, pbx
		.WHILE (pbx < bpDisplayDeviceCount)
			invoke RtlZeroMemory, ADDR nameStr, 32
			invoke IntToStr, ADDR nameStr, pbx
			mov nameStr[1], ':'
			mov nameStr[2], ' '
			mov nameStr[3], '('
			
			
			mov pax, pbx
			mov pcx, SIZEOF BPDisplayDevice
			mul pcx
			push pbx
			mov pbx, pax
			invoke IntToStr, ADDR nameStr[4], bpDisplayDevices[pbx].ScreenSize.x
			mov nameStr[pax+4], 'x'
			push pax
			invoke IntToStr, ADDR nameStr[pax+5], \
			bpDisplayDevices[pbx].ScreenSize.y
			pop pcx
			add pax, pcx
			mov nameStr[pax+5], ')'
			
			.IF (rv(UI_ComboboxHas, ADDR nameStr)) || \
			!(bpDisplayDevices[pbx].Active)
				pop pbx
				inc pbx
				.CONTINUE
			.ENDIF
			
			mov eax, UIComboboxCount
			.IF (SettingsGraphicsDisplay == eax)
				or al, 128
				inc al
				mov UIComboboxSelected, al
			.ENDIF
			
			invoke bpArrayAppend, UIDisplays, ADDR UIComboboxCount, 4
			mov UIDisplays, pax
			invoke UI_ComboboxAdd, ADDR nameStr
			
			pop pbx
			inc pbx
		.ENDW
		pop pbx
		mov al, bpDisplayDevices[3*SIZEOF BPDisplayDevice].Active
		print ubyte$(al), 13, 10
	.ENDIF
	add ebx, UI_BTN_H + UI_BTN_M
	
	invoke UI_Checkbox, StrMenuVSync, UIXFrom, ebx, OFFSET SettingsGraphicsVSync
	add ebx, UI_BTN_H
	
	invoke UI_HR, UIXFrom, ebx
	add ebx, UI_HR_H
	
	invoke Vector2Set, ADDR UISliderRange, f(3), f(10)
	mov UISliderZeros, FALSE
	fild SettingsGraphicsMazeCull
	fstp resEnum
	invoke UI_Slider, StrMenuMazeCull, UIXFrom, ebx, ADDR resEnum
	.IF (al)
		fld resEnum
		fistp SettingsGraphicsMazeCull
	.ENDIF
	mov UISliderZeros, TRUE
	add ebx, UI_BTN_H + UI_BTN_M
	
	; Effects
	invoke UI_Button, StrMenuEffects, UIXFrom, ebx, BP_ALIGN_CENTER
	.IF (al)
		.IF (UIComboboxMenu)
			mov UIComboboxMenu, 0
		.ENDIF
		mov UIState, UI_STATE_MENU_SETTINGS_GRAPHICS_EFFECTS
	.ENDIF
	add ebx, UI_BTN_H + UI_BTN_M
	
	; Gamma
	invoke UI_Button, StrMenuGammaSetup, UIXFrom, ebx, BP_ALIGN_CENTER
	.IF (al)
		.IF (UIComboboxMenu)
			mov UIComboboxMenu, 0
		.ENDIF
		mov UIState, UI_STATE_MENU_SETTINGS_GRAPHICS_GAMMA
	.ENDIF
	add ebx, UI_BTN_H
	
	invoke UI_HR, UIXFrom, ebx
	add ebx, UI_HR_H
	
	mov UISmallButtons, TRUE
	mov edx, UIXFrom
	sub edx, UI_BTN_WS + UI_BTN_M/2
	invoke UI_Button, StrMenuCancel, edx, ebx, BP_ALIGN_LEFT
	.IF (al)
		.IF (UIComboboxMenu > 0)
			call UI_HandleMenuEscape
		.ENDIF
		call UI_HandleMenuEscape
	.ENDIF
	
	mov edx, UIXFrom
	add edx, UI_BTN_M/2
	invoke UI_Button, StrMenuOK, edx, ebx, BP_ALIGN_LEFT
	.IF (al)
		invoke Settings_Save, OFFSET SettingsIniGraphics
		.IF (UIComboboxMenu > 0)
			call UI_HandleMenuEscape
		.ENDIF
		call UI_HandleMenuEscape
	.ENDIF
	
	mov UISmallButtons, FALSE
	ret
UI_DrawMenuSettingsGraphics ENDP

UI_DrawMenuSettingsGraphicsEffects PROC EXPORT
	LOCAL pxFmts[256]:DWORD, numFmts:DWORD, samples:DWORD, wglsamples:DWORD
	LOCAL nameStr[32]:BYTE

	UI_MENU_EFFECTS_HEIGHT	EQU UI_BTN_H*7 + UI_BTN_M*5 + UI_HR_H
	
	mov ebx, ScreenHalf.Y
	sub ebx, UI_MENU_EFFECTS_HEIGHT/2
	
	; MSAA
	.IF !(wglChoosePixelFormatARB)
		mov UIDisabled, TRUE
	.ENDIF
	invoke UI_Combobox, StrMenuMSAA, UIXFrom, ebx, UICB_MSAA
	.IF (al)		
		.IF (wglChoosePixelFormatARB)
			vinvoke wglChoosePixelFormatARB, FMain.DeviceContext, \
			ADDR ARBPixelAttribs, 0, 256, ADDR pxFmts, ADDR numFmts
			
			print str$(numFmts), 13, 10
			
			mov wglsamples, 2042h
			push pbx
			xor pbx, pbx
			.WHILE (pbx < numFmts)
				
				mov pcx, pbx
				shl pcx, 2
				vinvoke wglGetPixelFormatAttribivARB, FMain.DeviceContext, \
				pxFmts[pcx], 0, 1, ADDR wglsamples, ADDR samples
				
				invoke RtlZeroMemory, ADDR nameStr, 32
				.IF (!samples)
					invoke RtlMoveMemory, ADDR nameStr, StrMenuOff, 32
				.ELSE
					invoke IntToStr, ADDR nameStr, samples
					lea pcx, nameStr
					add pax, pcx
					mov BYTE PTR [pax], 120	; 'x'
				.ENDIF
				invoke UI_ComboboxHas, ADDR nameStr
				.IF (!al)
					mov UIMSAA, rv(bpArrayAppend, UIMSAA, ADDR samples, 4)
					invoke UI_ComboboxAdd, ADDR nameStr
					print str$(samples), 9
					print str$(SettingsGraphicsMSAA), 13, 10
					mov eax, SettingsGraphicsMSAA
					.IF (eax == samples)
						mov eax, UIComboboxCount
						or al, 128
						mov UIComboboxSelected, al
					.ENDIF
				.ENDIF
				inc pbx
			.ENDW
			pop pbx
		.ENDIF
	.ENDIF
	add ebx, UI_BTN_H + UI_BTN_M
	
	; Pixelization
	invoke UI_Checkbox, StrMenuPixelization, UIXFrom, ebx, \
	OFFSET SettingsGraphicsPixelization
	add ebx, UI_BTN_H + UI_BTN_M
	
	; Posterization
	invoke UI_Checkbox, StrMenuPosterization, UIXFrom, ebx, \
	OFFSET SettingsGraphicsPosterization
	add ebx, UI_BTN_H + UI_BTN_M
	
	; Afterimage
	invoke UI_Checkbox, StrMenuAfterimage, UIXFrom, ebx, \
	OFFSET SettingsGraphicsAfterimage
	add ebx, UI_BTN_H + UI_BTN_M
	
	; Particles
	invoke UI_Checkbox, StrMenuParticles, UIXFrom, ebx, \
	OFFSET SettingsGraphicsParticles
	add ebx, UI_BTN_H + UI_BTN_M
	
	; Animation interpolation
	invoke UI_Checkbox, StrMenuInterpolation, UIXFrom, ebx, \
	OFFSET SettingsGraphicsInterpolation
	add ebx, UI_BTN_H
	
	invoke UI_HR, UIXFrom, ebx
	add ebx, UI_HR_H
	
	invoke UI_Button, StrMenuBack, UIXFrom, ebx, BP_ALIGN_CENTER
	.IF (al)
		call UI_HandleMenuEscape
	.ENDIF
	ret
UI_DrawMenuSettingsGraphicsEffects ENDP

UI_DrawMenuSettingsGraphicsGamma PROC EXPORT
	UI_MENU_GAMMA_WIDTH		EQU 128*UI_SCALE
	UI_MENU_GAMMA_HEIGHT	EQU 64*UI_SCALE + UI_BTN_H*4 + UI_BTN_M*2 + UI_HR_H
	
	mov ebx, ScreenHalf.Y
	sub ebx, UI_MENU_GAMMA_HEIGHT/2
	
	call glPushMatrix
	mov eax, ScreenHalf.X
	sub eax, UI_MENU_GAMMA_WIDTH/2
	invoke glTranslatei, eax, ebx, 0
	invoke glScalef, f(%(128*UI_SCALE)), f(%(64*UI_SCALE)), f(1)
	invoke glBindTexture, GL_TEXTURE_2D, TexGamma
	invoke glCallList, ScreenQuad
	invoke FX_DrawGamma, SettingsGraphicsGamma
	call glPopMatrix
	add ebx, 64*UI_SCALE
	
	push bpFontWidth
	push bpFontHeight
	FontSize 3, 6
	invoke UI_Text, StrMenuGammaDesc, ScreenHalf.X, ebx, BP_ALIGN_CENTER, 0
	pop bpFontHeight
	pop bpFontWidth
	add ebx, UI_BTN_H + UI_BTN_M
	
	.IF (SettingsGraphicsGammaBypass)
		mov UIDisabled, TRUE
	.ENDIF
	invoke Vector2Set, ADDR UISliderRange, f(0.1), f(1)
	invoke UI_Slider, StrMenuGamma, UIXFrom, ebx, OFFSET SettingsGraphicsGamma
	.IF (al)
		invoke Settings_SetOption, OFFSET SettingsGraphicsGamma
	.ENDIF
	add ebx, UI_BTN_H + UI_BTN_M
	
	; Bypass
	invoke UI_Checkbox, StrMenuBypass, UIXFrom, ebx, \
	OFFSET SettingsGraphicsGammaBypass
	add ebx, UI_BTN_H
	
	invoke UI_HR, UIXFrom, ebx
	add ebx, UI_HR_H
	
	invoke UI_Button, StrMenuBack, UIXFrom, ebx, BP_ALIGN_CENTER
	.IF (al)
		call UI_HandleMenuEscape
	.ENDIF
	ret
UI_DrawMenuSettingsGraphicsGamma ENDP

UI_DrawPopupMenu PROC EXPORT
	invoke UI_DrawFullscreen, f(0.75)	; Another background darkening frame
	.IF (UIFocus < 128)
		mov UIFocus, 128
	.ENDIF
	
	invoke glColor4fv, ADDR clWhite
	invoke glBindTexture, GL_TEXTURE_2D, 0
	
	SWITCH UIPopupMenu
		CASE UIPP_EXIT
			mov UIComboboxCount, 2
			
			UIPP_EXIT_H		EQU UI_BTN_H*2 + UI_BRD_M*2 + UI_HR_H
			
			mov ebx, ScreenHalf.Y
			sub ebx, UIPP_EXIT_H/2
			add ebx, UI_BRD_M
			
			invoke UI_Text, StrMenuReallyQuit, ScreenHalf.X, ebx, \
			BP_ALIGN_CENTER, 0
			add ebx, UI_BTN_H
			
			invoke UI_HR, ScreenHalf.X, ebx
			add ebx, UI_HR_H
			
			mov UISmallButtons, TRUE
			mov edx, ScreenHalf.X
			sub edx, UI_BTN_WS + UI_BTN_M/2
			invoke UI_Button, StrMenuNo, edx, ebx, BP_ALIGN_LEFT
			.IF (al)
				call UI_HandleMenuEscape
			.ENDIF
			
			mov edx, ScreenHalf.X
			add edx, UI_BTN_M/2
			invoke UI_Button, StrMenuYes, edx, ebx, BP_ALIGN_LEFT
			.IF (al)
				mov UIFade, UI_FADE_OUT
				mov UIFadeCallback, OFFSET uiExitFaded
				mov UIFadeVal, 0
				mov deltaScale, 0
				mov UIState, UI_STATE_FADING
				call UI_HandleMenuEscape
			.ENDIF
			mov UISmallButtons, FALSE
		CASE UIPP_DISCARD
			mov UIComboboxCount, 3
			
			UIPP_CANCEL_W	EQU UI_BTN_WS*3 + UI_BTN_M*2 + UI_BRD_M*2
			UIPP_CANCEL_H	EQU UI_BTN_H*2 + UI_HR_H + UI_BRD_M*2
		
			mov ebx, ScreenHalf.Y
			sub ebx, UIPP_CANCEL_H/2
			add ebx, UI_BRD_M
			
			invoke UI_Text, StrMenuDiscardSett, ScreenHalf.X, ebx, \
			BP_ALIGN_CENTER, 0
			add ebx, UI_BTN_H
			
			invoke UI_HR, ScreenHalf.X, ebx
			add ebx, UI_HR_H
			
			mov UISmallButtons, TRUE
			mov edx, ScreenHalf.X
			sub edx, UIPP_CANCEL_W/2 - UI_BTN_M*2
			invoke UI_Button, StrMenuCancel, edx, ebx, BP_ALIGN_LEFT
			.IF (al)
				call UI_HandleMenuEscape
			.ENDIF
			
			invoke UI_Button, StrMenuDiscard, ScreenHalf.X, ebx, BP_ALIGN_CENTER
			.IF (al)
				push pbx
				call Settings_Load
				call UI_HandleMenuEscape
				call UI_HandleMenuEscape
				pop pbx
			.ENDIF
			
			mov edx, ScreenHalf.X
			add edx, UI_BTN_WS/2 + UI_BTN_M
			invoke UI_Button, StrMenuSave, edx, ebx, BP_ALIGN_LEFT
			.IF (al)
				.IF (UIState == UI_STATE_MENU_SETTINGS_GRAPHICS)
					lea pax, SettingsIniGraphics
				.ELSEIF (UIState == UI_STATE_MENU_SETTINGS_CONTROLS)
					lea pax, SettingsIniControls
				.ENDIF
				invoke Settings_Save, pax
				call UI_HandleMenuEscape
				call UI_HandleMenuEscape
			.ENDIF
			mov UISmallButtons, FALSE
			
		CASE UIPP_RESTART
			mov UIComboboxCount, 1
			
			UIPP_RESTART_H		EQU UI_BTN_H*3 + UI_BRD_M*2 + UI_HR_H
			
			mov ebx, ScreenHalf.Y
			sub ebx, UIPP_RESTART_H/2
			add ebx, UI_BRD_M
			
			invoke UI_Text, StrMenuRestartSett, ScreenHalf.X, ebx, \
			BP_ALIGN_CENTER, 0
			add ebx, UI_BTN_H*2
			
			invoke UI_HR, ScreenHalf.X, ebx
			add ebx, UI_HR_H
			
			invoke UI_Button, StrMenuOK, ScreenHalf.X, ebx, \
			BP_ALIGN_CENTER
			.IF (al)
				call UI_HandleMenuEscape
			.ENDIF
			
		CASE UIPP_BIND
			mov UIComboboxCount, 1
			
			UIPP_BIND_H		EQU UI_BTN_H*2 + UI_BRD_M*2 + UI_HR_H
			
			mov ebx, ScreenHalf.Y
			sub ebx, UIPP_BIND_H/2
			add ebx, UI_BRD_M
			
			push bpFontWidth
			push bpFontHeight
			FontSize 3, 6
			invoke UI_Text, StrMenuRebinding, ScreenHalf.X, ebx, \
			BP_ALIGN_CENTER, 0
			add ebx, UI_BTN_H/2
			invoke UI_Text, UIBindStr, ScreenHalf.X, ebx, BP_ALIGN_CENTER, 0
			pop bpFontHeight
			pop bpFontWidth
			add ebx, UI_BTN_H/2
			
			invoke UI_HR, ScreenHalf.X, ebx
			add ebx, UI_HR_H
			
			invoke UI_Button, StrMenuCancel, ScreenHalf.X, ebx, \
			BP_ALIGN_CENTER
			.IF (al)
				call UI_HandleMenuEscape
			.ENDIF
	ENDSW
	ret
	
	uiExitFaded:
		invoke bpDestroyForm, ADDR FMain
		mov UIFadeCallback, 0
		ret
	ret
UI_DrawPopupMenu ENDP

UI_DrawRectangle PROC EXPORT RectWidth:DWORD, RectHeight:DWORD
	call glPushMatrix
	invoke glScalei, RectWidth, RectHeight, 1
	invoke glCallList, ScreenQuad
	call glPopMatrix
	ret
	
	; Mesa sometimes doesn't like this here and is a fucking idiot
	invoke glBegin, GL_QUADS
		invoke glVertex2i, 0, 0
		invoke glVertex2i, 0, RectHeight
		invoke glVertex2i, RectWidth, RectHeight
		invoke glVertex2i, RectWidth, 0
	invoke glEnd
	ret
UI_DrawRectangle ENDP

UI_HandleMenuEscape PROC EXPORT
	mov UIPressed, 0
	.IF (UIPopupMenu)
		mov UIBinding, 0
		
		mov UIPopupMenu, 0
		mbm UIFocus, UIFocusBeforePopup
		ret
	.ENDIF
	.IF (UIComboboxMenu == -1)
		mov UIComboboxMenu, 0
	.ELSEIF (UIComboboxMenu)
		mov UIComboboxMenu, -1
		fld1
		fsub UIComboboxXLerp
		fstp UIComboboxXLerp
		mbm UIFocus, UIFocusBeforePopup
		ret
	.ENDIF
	.IF (PlrState >= PLAYER_STATE_INTRO_DARK) \
	&& (PlrState <= PLAYER_STATE_INTRO_TEXT3)
		call GameStart
	.ELSEIF (UIState == UI_STATE_GAME)
		invoke bpSetMouseMode, ADDR FMain, BP_MOUSE_MODE_VISIBLE
		mov deltaScale, 0
		invoke PauseSounds, TRUE
		
		mov UIState, UI_STATE_MENU_PAUSE
	.ELSEIF (UIState >= UI_STATE_MENU_SETTINGS_CONTROLS_BINDINGS)
		mov UIState, UI_STATE_MENU_SETTINGS_CONTROLS
	.ELSEIF (UIState >= UI_STATE_MENU_SETTINGS_GRAPHICS_EFFECTS)
		mov UIState, UI_STATE_MENU_SETTINGS_GRAPHICS
	.ELSEIF (UIState >= UI_STATE_MENU_SETTINGS_GRAPHICS)
		.IF (SettingsChanged)
			mbm UIFocusBeforePopup, UIFocus
			mov UIPopupMenu, UIPP_DISCARD
		.ELSE
			mov UIState, UI_STATE_MENU_SETTINGS
		.ENDIF
	.ELSEIF (UIState >= UI_STATE_MENU_REALLY_EXIT)
		mov UIState, UI_STATE_MENU_PAUSE
	.ELSEIF (UIState == UI_STATE_MENU_PAUSE)
		invoke bpSetMouseMode, ADDR FMain, BP_MOUSE_MODE_LOCKED
		invoke Vector2Copy, ADDR bpMouseClientPrev, ADDR FMain.ScreenCnt
		invoke Vector2Copy, ADDR bpMouseScreenPrev, ADDR FMain.ScreenCnt
		bpMEM32 deltaScale, f(1)
		invoke PauseSounds, FALSE
		mov UIState, UI_STATE_GAME
	.ENDIF
	ret
UI_HandleMenuEscape ENDP

UI_MouseFocus PROC EXPORT X:SDWORD, Y:SDWORD, ID:BYTE
	.IF !(UIPressed)
		.IF (UIPopupMenu) && (ID < 128)
			ret
		.ENDIF
		.IF (InputLook.X) || (InputLook.Y)
			mov eax, X
			.IF (UISmallButtons)
				add eax, UI_BTN_WS
			.ELSE
				add eax, UI_BTN_W
			.ENDIF
			invoke intInRange, bpMouseClient[0], X, eax
			mov cl, al
			mov eax, Y
			add eax, UI_BTN_H
			invoke intInRange, bpMouseClient[4], Y, eax
			and al, cl
			mov cl, ID
			.IF (al)
				mov UIFocus, cl
			.ELSEIF (UIFocus == cl)
				mov UIFocus, 0
				mov UIPressed, 0
			.ENDIF
		.ENDIF
	.ENDIF
	ret
UI_MouseFocus ENDP

UI_ShowSubtitles PROC EXPORT String:BPPtr, Duration:REAL4
	bpMPM UISubtitlesStr, String
	bpMEM32 UISubtitlesTimer, Duration
	ret
UI_ShowSubtitles ENDP


UI_Draw PROC EXPORT
	.IF (SettingsGraphicsMSAA)
		invoke glDisable, GL_MULTISAMPLE
	.ENDIF
	invoke glDepthMask, GL_FALSE
	invoke glDisable, GL_DEPTH_TEST
	invoke glDisable, GL_LIGHTING
	
	; Render downscale overlay
	invoke glMatrixMode, GL_PROJECTION
	call glLoadIdentity
	.IF (FXRenderSize.X)
		invoke gluOrtho2Di, 0, FXRenderSize.X, FXRenderSize.Y, 0
	.ENDIF
	
	invoke glMatrixMode, GL_MODELVIEW
	call glLoadIdentity
	
	; Full-screen effects
	.IF !(Loading)
		invoke glScalei, FXRenderSize.X, FXRenderSize.Y, 1
			
		; Vignette
		.IF (SettingsGraphicsVignette)
			invoke glEnable, GL_BLEND
			invoke glBlendFunc, GL_DST_COLOR, GL_ZERO
			invoke glBindTexture, GL_TEXTURE_2D, TexVignette
			invoke glCallList, ScreenQuad
			invoke glDisable, GL_BLEND
		.ENDIF
		
		; Fade
		.IF (UIFade)
			invoke glEnable, GL_BLEND
			invoke glBlendFunc, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA
			invoke glBindTexture, GL_TEXTURE_2D, 0
			invoke glColor4f, 0, 0, 0, UIFadeVal
			invoke glCallList, ScreenQuad
			invoke glDisable, GL_BLEND
		.ENDIF
		
		; Gamma
		.IF !(SettingsGraphicsGammaBypass)
			invoke FX_DrawGamma, SettingsGraphicsGamma
		.ENDIF
	
		; Noise
		.IF (SettingsGraphicsNoise)
			invoke glBindTexture, GL_TEXTURE_2D, TexNoise
			call FX_DrawNoise
		.ENDIF
			
		.IF (SettingsGraphicsAfterimage)
			call FX_PushAfterimage
		.ENDIF
	.ENDIF
	
	
	; Rain
	.IF !(SettingsGraphicsParticles)
		.IF (PlrState == PLAYER_STATE_INTRO_CITY) \
		|| (PlrState == PLAYER_STATE_INTRO_OUTSKIRTS) \
		|| (PlrState == PLAYER_STATE_INTRO_WOODS)
			invoke glBindTexture, GL_TEXTURE_2D, TexRain
			push FXNoiseAmplitude
			bpMEM32 FXNoiseAmplitude, f(0.1)
			call FX_DrawNoise
			pop FXNoiseAmplitude
		.ENDIF
	.ENDIF
	
	; Wmblyk jumpscare
	.IF (Wmblyk == WMBLYK_JUMPSCARE)
		invoke glBindTexture, GL_TEXTURE_2D, TexWmblykJumpscare
		invoke glEnable, GL_BLEND
		invoke glBlendFunc, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA
		invoke glColor4f, f(1), f(1), f(1), WmblykStateVal
		invoke glCallList, ScreenQuad
		invoke glDisable, GL_BLEND
		invoke glColor4fv, OFFSET clWhite
	.ENDIF
	
	
	; Initialize full-scale projection
	invoke glMatrixMode, GL_PROJECTION
	call glLoadIdentity
	.IF (ScreenSizeF.X)
		invoke gluOrtho2Df, 0, ScreenSizeF.X, ScreenSizeF.Y, 0
	.ENDIF
	
	invoke glMatrixMode, GL_MODELVIEW
	call glLoadIdentity
	invoke glScalef, ScreenSizeF.X, ScreenSizeF.Y, f(1)
	
	
	.IF (SettingsGraphicsAfterimage) || (SettingsGraphicsPixelization) || \
	(SettingsGraphicsPosterization)
		invoke FX_ScreenTexture, FXAfterimage
		.IF (SettingsGraphicsPixelization)
			invoke glViewport, 0, 0, FMain.ScreenSize.x, FMain.ScreenSize.y
		.ENDIF
	.ENDIF
	.IF !(Loading)
		invoke glColor4fv, OFFSET clWhite
		.IF (SettingsGraphicsAfterimage)
			call FX_DrawAfterimage
		.ELSEIF (SettingsGraphicsPixelization)||(SettingsGraphicsPosterization)
			mov pax, FXAfterimage
			invoke glBindTexture, GL_TEXTURE_2D, DWORD PTR [pax]
			invoke glCallList, ScreenQuad
		.ENDIF
	.ENDIF
	
	; UI Drawing
	call glLoadIdentity
	
	FontSize 4, 8
	
	.IF (Loading)
		invoke glColor4fv, OFFSET clWhite
		
		SWITCH LoadState
			CASE LOADING_ANIMATIONS
				mov pax, StrLoadAnimations
			CASE LOADING_FONTS
				mov pax, StrLoadFonts
			CASE LOADING_MODELS
				mov pax, StrLoadModels
			CASE LOADING_TEXTURES
				mov pax, StrLoadTextures
			CASE LOADING_SOUNDS
				mov pax, StrLoadSounds
			CASE LOADING_FINISHED
				mov pax, StrLoadFinished
			DEFAULT
				mov pax, StrLoading
		ENDSW
		
		invoke UI_Text, pax, ScreenHalf.X, ScreenHalf.Y, BP_ALIGN_CENTER, \
		BP_ALIGN_CENTER
		
		jmp uiFinish
	.ENDIF
	
	invoke glBlendFunc, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA
	
	; Menu background darkening frame
	.IF (UIState != UI_STATE_GAME) && \
	(UIState != UI_STATE_MENU_SETTINGS_GRAPHICS_GAMMA)
		invoke UI_DrawFullscreen, f(0.5)
	.ENDIF
	
	invoke glColor4fv, OFFSET clWhite
	
	SWITCH PlrState
		CASE PLAYER_STATE_INTRO_TEXT1
			invoke UI_Text, StrIntroText1, ScreenHalf.X, ScreenHalf.Y, \
			BP_ALIGN_CENTER, BP_ALIGN_CENTER
		CASE PLAYER_STATE_INTRO_TEXT2
			invoke UI_Text, StrIntroText2, ScreenHalf.X, ScreenHalf.Y, \
			BP_ALIGN_CENTER, BP_ALIGN_CENTER
		CASE PLAYER_STATE_INTRO_TEXT3
			invoke UI_Text, OFFSET AppName, ScreenHalf.X, ScreenHalf.Y, \
			BP_ALIGN_CENTER, BP_ALIGN_CENTER
	ENDSW
	
	.IF (UISubtitlesStr)
		mov eax, FMain.ScreenSize.y
		sub eax, UI_BTN_H*2
		invoke UI_Text, UISubtitlesStr, ScreenHalf.X, eax, \
		BP_ALIGN_CENTER, BP_ALIGN_CENTER
	.ENDIF
	
	; Draw combobox menus
	.IF (UIComboboxMenu > 0)
		mov UIID, 128
		call UI_DrawComboboxMenu
		call glLoadIdentity
	.ENDIF
	
	; Draw menus
	mov UIID, 0
	SWITCH UIState
		CASE UI_STATE_MENU_PAUSE
			call UI_DrawMenuPause
		CASE UI_STATE_MENU_SETTINGS
			call UI_DrawMenuSettings
		CASE UI_STATE_MENU_SETTINGS_CONTROLS
			call UI_DrawMenuSettingsControls
		CASE UI_STATE_MENU_SETTINGS_CONTROLS_BINDINGS
			call UI_DrawMenuSettingsControlsBindings
		CASE UI_STATE_MENU_SETTINGS_GRAPHICS
			call UI_DrawMenuSettingsGraphics
		CASE UI_STATE_MENU_SETTINGS_GRAPHICS_EFFECTS
			call UI_DrawMenuSettingsGraphicsEffects
		CASE UI_STATE_MENU_SETTINGS_GRAPHICS_GAMMA
			call UI_DrawMenuSettingsGraphicsGamma
	ENDSW
	; Draw popup menus
	.IF (UIPopupMenu)
		call glLoadIdentity
		mov UIID, 128
		call UI_DrawPopupMenu
	.ENDIF
		
	IFDEF MODE_DEBUG
	.IF (UIDebug)
		call UI_DrawDebug
	.ENDIF
	ENDIF
	
	uiFinish:
	invoke glEnable, GL_LIGHTING
	invoke glEnable, GL_DEPTH_TEST
	invoke glDepthMask, GL_TRUE
	.IF (SettingsGraphicsMSAA)
		invoke glEnable, GL_MULTISAMPLE
	.ENDIF
	ret
UI_Draw ENDP

UI_Process PROC EXPORT
	LOCAL flVal:REAL4
	; Do fading
	.IF (UIFade == UI_FADE_IN)
		.IF (UIState == UI_STATE_FADING)
			mov eax, deltaUnscaled
		.ELSE
			mov eax, deltaTime
		.ENDIF
		mov UIFadeVal, rv(flMove, UIFadeVal, 0, eax)
		.IF (UIFadeVal == 0)
			mov UIFade, UI_FADE_NONE
			.IF (UIFadeCallback)
				call UIFadeCallback
			.ENDIF
		.ENDIF
	.ELSEIF (UIFade == UI_FADE_OUT)
		.IF (UIState == UI_STATE_FADING)
			mov eax, deltaUnscaled
		.ELSE
			mov eax, deltaTime
		.ENDIF
		mov UIFadeVal, rv(flMove, UIFadeVal, FLT_1, eax)
		.IF (UIFadeVal == FLT_1)
			mov UIFade, UI_FADE_NONE
			.IF (UIFadeCallback)
				call UIFadeCallback
			.ENDIF
		.ENDIF
	.ENDIF
	
	; Do menu stuff
	.IF (UIState != UI_STATE_GAME)
		.IF (UIFocusType == UI_BUTTON_SMALL)	; Small button func shit
			.IF (UIMove == 1)
				mov InputUIDown, TRUE
				mov UIMove, 2
			.ELSEIF (UIMove == -1)
				mov InputUIUp, TRUE
				mov UIMove, 2
			.ENDIF
		.ELSE
			mov UIMove, 0
		.ENDIF
		.IF (InputUIRight)
			.IF (UIFocusType == UI_COMBOBOX)
				mbm UIPressed, UIFocus
			.ELSEIF (UIFocusType == UI_BUTTON_SMALL)
				mov InputUIDown, TRUE
			.ENDIF
		.ELSEIF (InputUILeft)
			.IF (UIComboboxMenu > 0)
				call UI_HandleMenuEscape
			.ELSEIF (UIFocusType == UI_BUTTON_SMALL)
				mov InputUIUp, TRUE
			.ENDIF
		.ENDIF
		.IF (InputUIUp)
			mov UIButtonJump, TRUE
			.IF (UIFocus == 129)
				mov pax, UIComboboxCount
				add al, 128
				mov UIFocus, al
			.ELSEIF (UIFocus <= 1)
				mov pax, UIState
				mov al, UIID
				mov UIFocus, al
			.ELSE
				dec UIFocus
				.IF !(UIMove) && !(InputUILeft) \
				&& (UIFocusType == UI_BUTTON_SMALL)
					mov UIMove, -1
				.ENDIF
			.ENDIF
		.ELSEIF (InputUIDown)
			mov UIButtonJump, TRUE
			.IF (UIFocus & 128)
				mov pax, UIComboboxCount
				add al, 128
			.ELSE
				mov pax, UIState
				mov al, UIID
				;mov al, UIElements[pax]
			.ENDIF
			.IF (UIFocus >= al)
				.IF (UIFocus & 128)
					mov UIFocus, 129
				.ELSE
					mov UIFocus, 1
				.ENDIF
			.ELSE
				inc UIFocus
				.IF !(UIMove) && !(InputUIRight) \
				&& (UIFocusType == UI_BUTTON_SMALL)
					mov UIMove, 1
				.ENDIF
			.ENDIF
		.ENDIF
		
		.IF (UIFocusType != UI_SLIDER)
			mov InputUILeft, FALSE
			mov InputUIRight, FALSE
		.ENDIF
		mov UIFocusType, UI_NONE
		
		.IF (UIMove == 2)
			mov UIMove, 0
		.ENDIF
		
		fild ScreenHalf.X
		.IF (UIComboboxMenu == -1)
			fcmp UIComboboxXLerp, f(0.99)
			.IF (!Carry?)
				mov UIComboboxMenu, 0
				bpMEM32 UIComboboxXLerp, f(1)
			.ENDIF
			
			fld1
			fsub UIComboboxXLerp
			push (UI_BTN_W+UI_BRD_M*2)/2
			fimul DWORD PTR [psp]
			pop pax
			fsub
		.ELSEIF (UIComboboxMenu)
			fld UIComboboxXLerp
			push (UI_BTN_W+UI_BRD_M*2)/2
			fimul DWORD PTR [psp]
			pop pax
			fsub
		.ENDIF
		fistp UIXFrom
		
		.IF (UIComboboxMenu)
			fld deltaUnscaled
			fmul f(12)
			fstp flVal
			mov UIComboboxXLerp, rv(flLerp, UIComboboxXLerp, f(1), flVal)
		.ENDIF
	.ENDIF
	
	.IF (UISubtitlesStr)
		fld UISubtitlesTimer
		fsub deltaTime
		fstp UISubtitlesTimer
		
		fcmp UISubtitlesTimer
		.IF (Carry?)
			mov UISubtitlesStr, 0
			mov UISubtitlesTimer, 0
		.ENDIF
	.ENDIF
	ret
UI_Process ENDP

UI_Create PROC EXPORT 
	FontSize 4, 8
	ret
UI_Create ENDP
