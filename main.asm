.686
.model flat,stdcall
option casemap:none

;BP_COMPATIBILITY_W9X		EQU <1>
BP_ERROR_PASS				EQU <1>
BP_INTERPOLATION_DYNAMIC	EQU <1>
;BP_IMPORTERS_VERBOSE	EQU <1>
IFDEF MODE_DEBUG
	ECHO Compiling MASMZE-BP3D in debug mode.
	BP_TRACEABLE_HEAP EQU <1>
ENDIF

include ..\BoilPlate3D\src\BP3D.asm

IFDEF BP_COMPATIBILITY_W9X
	MOUSE_RAW EQU 0
	JOYSTICK_RAW EQU BP_IF_JOYSTICK
ELSE
	MOUSE_RAW EQU BP_IF_RAW_MOUSE
	JOYSTICK_RAW EQU BP_IF_RAW_JOYSTICK
ENDIF

IFDEF BP_WININC
	includelib advapi32.lib
	include include\stdlib.inc
	includelib msvcrt.lib
ELSEIFNDEF BP_CUSTOM_INCLUDES
	include include\advapi32.inc
	includelib advapi32.lib
	include include\msvcrt.inc
	includelib msvcrt.lib
	
	include include\masm32.inc
	includelib masm32.lib
	include macros\macros.asm
ENDIF

include ..\BoilPlate3D\src\BP3DArrays.inc
include ..\BoilPlate3D\src\BP3DMaths.inc
include ..\BoilPlate3D\src\BP3DVectors.inc
include ..\BoilPlate3D\src\BP3DImporters.inc
include ..\BoilPlate3D\src\BP3DGLPlus.inc
include ..\BoilPlate3D\src\BP3DText.inc

include lib\soft_oal.inc
includelib lib\soft_oal.lib
include lib\stb_vorbis.inc
includelib lib\stb_vorbis.lib

; ----- Miscellaneous helper macros -----
;   Define a series of symbolic EQUs with incrementing numeric constants.
ENUM MACRO vargs:VARARG
	LOCAL idx_
	idx_=0
	FOR varg,<vargs>
		varg EQU idx_
		idx_ = idx_+1
	ENDM
ENDM
;   MASM32 treats macro arguments as a single 255-char string. This is a split
; ENUM macro to accommodate for that bullshit.
ENUML MACRO
	IFNDEF enumlval_
		PUBLIC enumlval_
	ENDIF
	enumlval_ = 0
ENDM

E MACRO earg:REQ
	earg EQU enumlval_
	enumlval_ = enumlval_ +1
ENDM

IFNDEF print
	;   Blank print macro cuz I can't bother to rewrite it for full 
	; compatibility with MASM's print macro.
	print MACRO Dummy:VARARG
	ENDM
ENDIF
IFNDEF real4$
	; msvcrt cheats to replace macros (they use it anyway I think)
	real4$ MACRO FlVal:REQ
		LOCAL localDbl, localStr
		.DATA
			localStr DB 16 DUP (0)
		.DATA?
			localDbl REAL8 ?
		.CODE
		IF (OPATTR FlVal) AND 00010000b	; Register
			push FlVal
			fld REAL4 PTR [psp]
			add psp, SIZEOF BPPtr
		ELSE
			fld FlVal
		ENDIF
		fstp localDbl
		IFDEF _gcvt	; WinInc
			invoke _gcvt, localDbl, 7, ADDR localStr
		ELSE		; MASM
			invoke crt__gcvt, localDbl, 7, ADDR localStr
		ENDIF
		EXITM pax
	ENDM
ENDIF
IFNDEF rv
	rv MACRO ProcName:REQ, Args:VARARG
		procCall EQU <invoke ProcName>
		FOR var,<Args>
			procCall CATSTR procCall,<, var>
		ENDM
		procCall
		EXITM <pax>
	ENDM
ENDIF
IFNDEF str$
	str$ MACRO IntVal:REQ
		LOCAL localStr
		.DATA
			localStr DB 11 DUP (0)
		.CODE
		IFDEF _ltoa	; WinInc
			invoke _ltoa, IntVal, ADDR localStr, 10
		ELSE		; MASM
			invoke crt__ltoa, IntVal, ADDR localStr, 10
		ENDIF
		EXITM <ADDR localStr>
	ENDM
ENDIF
IFNDEF SWITCH
	swCases	= 0
	SWITCH MACRO VarName:REQ
		mov pax, VarName
		swCases = 0
	ENDM
	CASE MACRO Args:VARARG
		LOCAL stat, argc
		argc = 0
		stat TEXTEQU <>
		FOR var,<Args>
			IF argc EQ 1
				stat CATSTR stat, < || >
			ENDIF
			stat CATSTR stat, <pax == var>
			argc = 1
		ENDM
		IF swCases EQ 0
			.IF stat
			swCases = 1
		ELSE
			.ELSEIF stat
		ENDIF
	ENDM
	DEFAULT MACRO
		.ELSE
	ENDM
	ENDSW MACRO
		.ENDIF
	ENDM
ENDIF
IFNDEF ubyte$
	ubyte$ MACRO ByteVal:REQ
		movzx pax, ByteVal
		EXITM <str$(pax)>
	ENDM
ENDIF

mbm MACRO m1, m2
	mov al, m2
	mov m1, al
ENDM

pushb MACRO m1
	;movzx pax, m1
	mov al, m1
	push pax
ENDM

popb MACRO m1
	pop pax
	mov m1, al
ENDM

;   Implicit call a function identifier with VARARG arguments.
vinvoke MACRO ProcName:REQ, args:VARARG
	LOCAL txt, arg, adr
	txt TEXTEQU <>
	%FOR arg, <args>
		txt CATSTR <arg>, <,>, txt
	ENDM
	adr SIZESTR txt
	txt SUBSTR txt, 1, adr-1
	
	%FOR var, <txt>
		adr INSTR <var>,<ADDR>
		IF adr
			the@adr SUBSTR <var>,adr+5
			lea pax, the@adr
			the@arg EQU pax
		ELSE
			the@arg EQU var
		ENDIF
		push the@arg
	ENDM
	call ProcName
ENDM

vrv MACRO ProcName:REQ, Args:VARARG
	vinvoke ProcName, Args
	EXITM <pax>
ENDM

;   Simple MASM SADD replacement. Declares a string and returns its ADDR in pax.
;   qStr:String - quoted string.
s MACRO qStr:REQ
	LOCAL strDb
	.DATA
		strDb DB qStr,0
	.CODE
	EXITM <ADDR strDb>
ENDM

;   Make the argument into a string (for preprocessor @ data).
stringify MACRO arg
    LOCAL foo
    foo CATSTR <'>,arg,<'>
    EXITM foo
ENDM

.CONST
FLT_1	EQU 1065353216
ENUM	BIND_NONE, \
		BIND_KEY_MOUSE, \
		BIND_JOYSTICK

AppName DB "MASMZE-3D", 0	; App name & caption
AsmTime	DB "Assembly time: ", stringify(@Date), 32, stringify(@Time), 13, 10, 0

.DATA
; ----- Forms, form creation -----
FARB	BPForm <>		; Dummy form to load wgl functions and init ARB ext
FMain	BPForm <>		; Main form

; To check for MSAA options
ARBPixelAttribs DWORD \	
	2001h, GL_TRUE, \	; WGL_DRAW_TO_WINDOW_ARB = true
	2010h, GL_TRUE, \	; WGL_SUPPORT_OPENGL_ARB = true
	2011h, GL_TRUE, \	; WGL_DOUBLE_BUFFER_ARB = true
	2013h, 202Bh, \		; WGL_PIXEL_TYPE_ARB = WGL_TYPE_RGBA_ARB
	2014h, 24, \		; WGL_COLOR_BITS_ARB = 24
	2022h, 24, \		; WGL_DEPTH_BITS_ARB = 24
	2023h, 1, \			; WGL_STENCIL_BITS_ARB = 1
0		

; Pixel attributes to apply MSAA
ARBPixelAttribsMSAA DWORD \	
	2001h, GL_TRUE, \			; WGL_DRAW_TO_WINDOW_ARB = true
	2010h, GL_TRUE, \			; WGL_SUPPORT_OPENGL_ARB = true
	2011h, GL_TRUE, \			; WGL_DOUBLE_BUFFER_ARB = true
	2013h, 202Bh, \				; WGL_PIXEL_TYPE_ARB = WGL_TYPE_RGBA_ARB
	2014h, 24, \				; WGL_COLOR_BITS_ARB = 24
	2022h, 24, \				; WGL_DEPTH_BITS_ARB = 24
	2023h, 1, \					; WGL_STENCIL_BITS_ARB = 1
	2041h, 1, \					; WGL_SAMPLE_BUFFERS_ARB = 1 (multisample)
	2042h, 0, \					; WGL_SAMPLES_ARB = 0
0		

; ----- INPUT -----
Keys BPBool 255 DUP (0)
LastInput BPPtr 0
LastInputTimer REAL4 0.2, 0.05

; Input binds
IBUp		BPPtr "W"
IBDown		BPPtr "S"
IBLeft		BPPtr "A"
IBRight		BPPtr "D"
IBLookUp	BPPtr VK_UP
IBLookDown	BPPtr VK_DOWN
IBLookLeft	BPPtr VK_LEFT
IBLookRight	BPPtr VK_RIGHT
IBCrouch	BPPtr VK_CONTROL
IBGlyph		BPPtr "G"
IBAction	BPPtr VK_SPACE
IBConfirm	BPPtr VK_RETURN

IBMenu		BPPtr VK_ESCAPE
IBUIUp		BPPtr VK_UP
IBUIDown	BPPtr VK_DOWN
IBUILeft	BPPtr VK_LEFT
IBUIRight	BPPtr VK_RIGHT
IBUIConfirm	BPPtr VK_RETURN

; Gamepad axes
GAMEPAD_NEG		EQU 128
GAMEPAD_LS_H	EQU 64
GAMEPAD_LS_V	EQU 65
GAMEPAD_RS_H	EQU 66
GAMEPAD_RS_V	EQU 67
GAMEPAD_TRIG_L	EQU 68
GAMEPAD_TRIG_R	EQU 68 or GAMEPAD_NEG

; Joystick binds
JBUp		BPPtr GAMEPAD_LS_V or GAMEPAD_NEG
JBDown		BPPtr GAMEPAD_LS_V
JBLeft		BPPtr GAMEPAD_LS_H or GAMEPAD_NEG
JBRight		BPPtr GAMEPAD_LS_H
JBLookUp	BPPtr GAMEPAD_RS_V or GAMEPAD_NEG
JBLookDown	BPPtr GAMEPAD_RS_V
JBLookLeft	BPPtr GAMEPAD_RS_H or GAMEPAD_NEG
JBLookRight	BPPtr GAMEPAD_RS_H
JBCrouch	BPPtr 4
JBGlyph		BPPtr 0
JBAction	BPPtr 1
JBConfirm	BPPtr 8


JBMenu		BPPtr 9
JBCancel	BPPtr 2
JBUIUp		BPPtr BP_JOY_DPAD_UP
JBUIDown	BPPtr BP_JOY_DPAD_DOWN
JBUILeft	BPPtr BP_JOY_DPAD_LEFT
JBUIRight	BPPtr BP_JOY_DPAD_RIGHT
JBUIConfirm	BPPtr 1

ENUM \
	INPUT_KEYBOARD_MOUSE, \
	INPUT_JOYSTICK
InputMethod BPEnum INPUT_KEYBOARD_MOUSE

InputAxes				REAL4 0.0, 0.0, 0.0, 0.0,	0.0, 0.0, 0.0, 0.0
InputLook				Vector2 <0.0, 0.0>
InputMovement			Vector2 <0.0, 0.0>
InputMovementClamped	Vector2 <0.0, 0.0>
InputCrouch				BPPtr FALSE
InputGlyph				BPPtr FALSE
InputAction				BPPtr FALSE
InputConfirm			BPPtr FALSE

InputMenu				BPPtr FALSE
InputUIUp				BPPtr FALSE
InputUIDown				BPPtr FALSE
InputUILeft				BPPtr FALSE
InputUIRight			BPPtr FALSE
InputUIConfirm			BPPtr FALSE
InputUIConfirmT			BPPtr FALSE

FogDensity	REAL4 0.5

.DATA?
delta2		REAL4 ?
delta10		REAL4 ?
delta20		REAL4 ?
deltaFixed	REAL4 ?
FPS			REAL4 ?

XInput BPBool ?

; Screen stuffs
ScreenHalf	Vector2 <?, ?>
ScreenSizeF	Vector2 <?, ?>
ScreenMode	BPEnum ?

; ----- WGL extended functions -----
wglChoosePixelFormatARB			BPPtr ?
wglGetPixelFormatAttribivARB	BPPtr ?
wglSwapIntervalEXT				BPPtr ?

;PROC_TRACE		EQU <1>
PROC_TRACE_ALL	EQU <1>
include scripts\ProcTrace.asm

AUDIO_OPENAL	EQU <1>
include scripts\SndUtils.asm
include scripts\Resources.asm

include scripts\FX.asm
include scripts\Collide.asm
PARTICLES_DOT_CULL	EQU <1>
include scripts\Particles.asm
include scripts\Maze.asm

include scripts\Player.asm

include scripts\Kubale.asm
include scripts\Wmblyk.asm

include scripts\Settings.asm
include scripts\UI.asm

.CODE

GPadParse PROTO :BPEnum, :BPPtr

CreateScene PROC EXPORT
	call Maze_Create
	ret
CreateScene ENDP

DrawScene PROC EXPORT
	IFDEF MODE_DEBUG	; Wireframe
		.IF (Keys[VK_MBUTTON])
			invoke glPolygonMode, GL_FRONT_AND_BACK, GL_LINE
			invoke glDisable, GL_TEXTURE_2D
		.ENDIF
	ENDIF
	.IF (PlrState >= PLAYER_STATE_INTRO_DARK) \
	&& (PlrState <= PLAYER_STATE_INTRO_TEXT3)
		call Plr_DrawIntro
	.ENDIF
	call Maze_Draw
	.IF (PlrGlyphsInMaze)
		call Plr_DrawGlyphs
	.ENDIF
	.IF (Kubale)
		call Kubale_Draw
	.ENDIF
	.IF (Wmblyk)
		call Wmblyk_Draw
	.ENDIF
	IFDEF MODE_DEBUG	; Wireframe cancel
		invoke glPolygonMode, GL_FRONT_AND_BACK, GL_FILL
		invoke glEnable, GL_TEXTURE_2D
	ENDIF
	ret
DrawScene ENDP

FixedScene PROC EXPORT
	fld bpFixedInterval
	fmul deltaScale
	fstp deltaFixed
	call Maze_Fixed
	ret
FixedScene ENDP

;   Game initialize (everything loaded in, could be a bind to FMain.OnStart, but
; we're using staged resource loading)
GameInit PROC EXPORT
	call Plr_Create
	print "Finished game object initialization.", 13, 10
	
	.IF !(rv(Settings_LoadGame))
		; If no save game is present start intro sequence
		mov PlrState, PLAYER_STATE_INTRO_DARK
		mov MazeState, MAZE_STATE_SAFE
	.ELSE
		call GameStart
		invoke alSourcePlay, SndAmb
	.ENDIF
	call CreateScene
	
	bpMEM32 ListParticle, MdlParticle
	
	invoke bpSetMouseMode, ADDR FMain, BP_MOUSE_MODE_LOCKED
	ret
GameInit ENDP

GameStart PROC EXPORT
	mov PlrState, PLAYER_STATE_ENTER
	mov PlrStateCallback, 0
	bpMEM32 CamBaseFOV, f(75)
	
	invoke glLightf, GL_LIGHT0, GL_CONSTANT_ATTENUATION, 0
	invoke glLightf, GL_LIGHT0, GL_LINEAR_ATTENUATION, f(0.5)
	
	bpMEM32 FogDensity, f(0.5)
	invoke alSourceStop, SndIntro
	
	invoke Maze_Generate, nRandSeed
	ret
GameStart ENDP

GPadInput PROC EXPORT InType:BPEnum, InStruct:BPPtr, Input:BPPtr, \
ValPtr:BPPtr	
	mov pbx, InStruct
	invoke GPadParse, InType, pbx
	
	.IF (InType == BP_INPUT_JOY_AXIS)	; Fix parallel axes
		mov pcx, pax
		and pcx, not GAMEPAD_NEG
		mov pdx, Input
		and pdx, not GAMEPAD_NEG
		.IF (pcx == pdx)
			ASSUME pbx:PTR BPInJoyAxis
			.IF (pax != Input)
				mov pax, ValPtr
				mov REAL4 PTR [pax], 0
				ret
			.ENDIF
		.ENDIF
	.ENDIF
	.IF (Input == pax)
		mov pax, ValPtr
		.IF (InType == BP_INPUT_JOY_AXIS)
			ASSUME pbx:PTR BPInJoyAxis
			mov ecx, [pbx].Position
			and ecx, not FLT_NEG
			mov REAL4 PTR [pax], ecx
		.ELSE
			ASSUME pbx:PTR BPInJoyButton
			.IF ([pbx].Pressed)
				mov DWORD PTR [pax], FLT_1
			.ELSE
				mov DWORD PTR [pax], 0
			.ENDIF
		.ENDIF
	.ENDIF
	ret
	.IF (Input >= GAMEPAD_LS_H) && (InType == BP_INPUT_JOY_AXIS)
		ASSUME pbx:PTR BPInJoyAxis
		.IF (Input & GAMEPAD_NEG)
			fcmp [pbx].Position
			.IF (!Carry?) && (!Zero?)
				ret
			.ENDIF
		.ELSE
			fcmp [pbx].Position
			.IF (Carry?) && (!Zero?)
				ret
			.ENDIF
		.ENDIF
		mov eax, Input
		and eax, not GAMEPAD_NEG
		
		.IF (XInput)
			.IF (eax == GAMEPAD_RS_H)
				mov eax, BP_JOY_AXIS_U+64
			.ELSEIF (eax == GAMEPAD_TRIG_L)
				mov eax, BP_JOY_AXIS_Z+64
			.ENDIF
		.ENDIF
		sub eax, 64
		
		.IF ([pbx].Axis == eax)
			mov pax, ValPtr
			mov pcx, [pbx].Position
			and pcx, not FLT_NEG
			mov REAL4 PTR [pax], pcx
		.ENDIF
	.ELSE
		ASSUME pbx:PTR BPInJoyButton
		
		mov eax, Input
		.IF (!XInput)
			.IF (eax & GAMEPAD_TRIG_L)
				.IF (eax & GAMEPAD_NEG)
					mov [pbx].Button, 7
				.ELSE
					mov [pbx].Button, 8
				.ENDIF
			.ENDIF
		.ENDIF
		
		.IF ([pbx].Button == eax)
			print str$([pbx].Button), 13, 10
		.ENDIF
	.ENDIF
	ASSUME pbx:nothing
	ret
GPadInput ENDP

GPadParse PROC EXPORT InType:BPEnum, InStruct:BPPtr
	mov pbx, InStruct
	.IF (InType == BP_INPUT_JOY_AXIS)
		ASSUME pbx:PTR BPInJoyAxis
		
		mov eax, [pbx].Axis
		
		.IF (XInput)
			.IF ([pbx].Axis == BP_JOY_AXIS_Z)
				mov eax, GAMEPAD_TRIG_L-64
			.ELSEIF ([pbx].Axis == BP_JOY_AXIS_U)
				mov eax, GAMEPAD_RS_H-64
			.ENDIF
		.ELSE
			.IF ([pbx].Axis == BP_JOY_AXIS_V)
				mov eax, GAMEPAD_RS_V-64
			.ENDIF
		.ENDIF
		
		add eax, 64
		
		fcmp [pbx].Position
		.IF (Carry?)
			or eax, GAMEPAD_NEG
		.ENDIF
		
	.ELSE
		ASSUME pbx:PTR BPInJoyButton
		
		mov eax, [pbx].Button
		
		.IF (XInput)
			.IF (eax == 0)
				mov eax, 1
			.ELSEIF (eax == 1)
				mov eax, 2
			.ELSEIF (eax == 2)
				mov eax, 0
			.ELSEIF (eax >= 6) && (eax < BP_JOY_DPAD_UP)
				add eax, 2
			.ENDIF
		.ELSE
			.IF (eax == 6)
				mov eax, GAMEPAD_TRIG_L
			.ELSEIF (eax == 7)
				mov eax, GAMEPAD_TRIG_R
			.ENDIF
		.ENDIF
		
	.ENDIF
	ret
GPadParse ENDP

;   Manually initialize an ARB-compatible OpenGL context on FMain
InitARBContext PROC EXPORT
	LOCAL numFormats:UINT, pixelFormat:DWORD, pfd:PIXELFORMATDESCRIPTOR
	
	mov FMain.DeviceContext, rv(GetDC, FMain.Handle)

	vinvoke wglChoosePixelFormatARB, FMain.DeviceContext, \
	ADDR ARBPixelAttribsMSAA, 0, 1, ADDR pixelFormat, ADDR numFormats
	
	invoke DescribePixelFormat, FMain.DeviceContext, pixelFormat, \
	SIZEOF PIXELFORMATDESCRIPTOR, ADDR pfd
	.IF (!al)
		invoke bpError, s("Can't describe pixel format."), 0
		xor pax, pax
		ret
	.ENDIF
	
	invoke SetPixelFormat, FMain.DeviceContext, pixelFormat, ADDR pfd
	.IF (!al)
		invoke bpError, s("Can't set pixel format."), 0
		xor pax, pax
		ret
	.ENDIF
	invoke wglCreateContext, FMain.DeviceContext
	mov FMain.GraphicsContext, pax
	
	invoke wglMakeCurrent, FMain.DeviceContext, FMain.GraphicsContext
	
	invoke glEnable, GL_MULTISAMPLE
	
	invoke glEnable, GL_CULL_FACE
	invoke glShadeModel, GL_SMOOTH
	invoke glEnable, GL_DEPTH_TEST
	invoke glEnable, GL_TEXTURE_2D
	invoke glDepthFunc, GL_LEQUAL
	
	invoke glEnableClientState, GL_VERTEX_ARRAY
	invoke glEnableClientState, GL_TEXTURE_COORD_ARRAY
	invoke glEnableClientState, GL_NORMAL_ARRAY
	
	invoke glClearColor4fv, ADDR clBlack
	mov pax, TRUE
	ret
InitARBContext ENDP

InitAudio PROC EXPORT
	call InitAudioSystem
	invoke alListenerf, AL_GAIN, SettingsAudioVolume
	ret
InitAudio ENDP

InitGraphics PROC EXPORT
	; Initialize the respective OpenGL context
	.IF (SettingsGraphicsMSAA) && (wglChoosePixelFormatARB)
		bpMEM32 ARBPixelAttribsMSAA[17*4], SettingsGraphicsMSAA
		.IF (!rv(InitARBContext))
			; MSAA failed, let's not crash
			mov SettingsGraphicsMSAA, 0
			invoke bpInitGLContext, OFFSET FMain
		.ENDIF
	.ELSE
		invoke bpInitGLContext, OFFSET FMain	; Initialize OpenGL context
	.ENDIF
	
	invoke wglGetProcAddress, s("wglSwapIntervalEXT")
	mov wglSwapIntervalEXT, pax
	.IF (wglSwapIntervalEXT)
		print "Got wglSwapIntervalEXT extension.", 13, 10
		invoke Settings_SetOption, OFFSET SettingsGraphicsVSync
	.ENDIF
	
	bpMEM32 bpAnimationFPS, f(24)
	bpMEM32 bpAnimInterpolateSpeed, f(1.5)
	
	invoke glHint, GL_FOG_HINT, GL_FASTEST
	invoke glHint, GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST
	
	invoke glPixelStorei, GL_PACK_ALIGNMENT, 1
	invoke glPixelStorei, GL_UNPACK_ALIGNMENT, 1
	
	invoke glEnable, GL_LIGHTING
	invoke glEnable, GL_LIGHT0
	invoke glLightModelfv, GL_LIGHT_MODEL_AMBIENT, OFFSET clBlack
	invoke glLightfv, GL_LIGHT0, GL_SPECULAR, OFFSET clWhite
	invoke glLightf, GL_LIGHT0, GL_CONSTANT_ATTENUATION, 0
	invoke glLightf, GL_LIGHT0, GL_LINEAR_ATTENUATION, f(0.5)
	
	invoke glEnable, GL_FOG
	
	invoke glColorMaterial, GL_FRONT, GL_DIFFUSE
	
	invoke glMaterialf, GL_FRONT, GL_SHININESS, f(64)
	invoke glMaterialfv, GL_FRONT, GL_SPECULAR, OFFSET clWhite
	
	ret
InitGraphics ENDP

ProcessScene PROC EXPORT
	call Plr_Process
	.IF (Maze)
		call Maze_Process
	.ENDIF
	.IF (Kubale)
		call Kubale_Process
	.ENDIF
	.IF (Wmblyk)
		call Wmblyk_Process
	.ENDIF
	call Plr_LateProcess
	ret
ProcessScene ENDP


;   FMain bindings
OnCreate PROC EXPORT
	call InitAudio
	call InitGraphics
	print "Finished base initialization.", 13, 10
	
	call FX_Create
	call UI_Create
	print "Finished scripts initialization.", 13, 10
	ret
OnCreate ENDP

OnFixed PROC EXPORT
	call FixedScene
	ret
OnFixed ENDP

OnInput PROC EXPORT BPInType:BPEnum, BPInStruct:BPPtr
	LOCAL axisVal:REAL4;, joyInfo:JOYINFOEX
	; Set current input method
	.IF (BPInType == BP_INPUT_MOUSE_BUTTON || BPInType == BP_INPUT_KEY)
		mov InputMethod, INPUT_KEYBOARD_MOUSE
	.ELSEIF (BPInType == BP_INPUT_JOY_AXIS || BPInType == BP_INPUT_JOY_BUTTON)
		mov InputMethod, INPUT_JOYSTICK
	.ENDIF
	
	mov pbx, BPInStruct
	.IF (BPInType == BP_INPUT_MOUSE_MOVE)
		ASSUME pbx:PTR BPInMouseMove
		.IF ([pbx].Relative.x)
			fild [pbx].Relative.x
			fmul f(0.01)
			fmul SettingsControlsMouseSensitivity
			fstp InputLook.X
		.ENDIF
		.IF ([pbx].Relative.y)
			fild [pbx].Relative.y
			fmul f(0.01)
			fmul SettingsControlsMouseSensitivity
			fstp InputLook.Y
		.ENDIF
	.ELSEIF (BPInType == BP_INPUT_KEY) || (BPInType == BP_INPUT_MOUSE_BUTTON)
		ASSUME pbx:PTR BPInKey
		mov al, [pbx].Pressed
		mov pcx, [pbx].Keycode
		
		.IF (pcx < 256)
			.IF (Keys[pcx] == al)
				ret
			.ENDIF
			mov Keys[pcx], al
		.ENDIF
			
		mov LastInput, 0
		bpMEM32 LastInputTimer, f(0.2)
		
		.IF ([pbx].Pressed)
			.IF (UIBinding == BIND_KEY_MOUSE) && ([pbx].Keycode != VK_ESCAPE)
				mov pax, UIBindAction
				bpMPM BPPtr PTR [pax], [pbx].Keycode
				call UI_HandleMenuEscape
				mov SettingsChanged, TRUE
			.ENDIF
			
			SWITCH [pbx].Keycode
				CASE IBMenu, VK_ESCAPE
					call UI_HandleMenuEscape
				CASE IBUIUp
					mov InputUIUp, TRUE
					mov LastInput, OFFSET InputUIUp
				CASE IBUIDown
					mov InputUIDown, TRUE
					mov LastInput, OFFSET InputUIDown
				CASE IBUILeft
					mov InputUILeft, TRUE
				CASE IBUIRight
					mov InputUIRight, TRUE
				
				CASE IBUIConfirm
					mov InputUIConfirm, TRUE
					mov InputUIConfirmT, TRUE
				
				CASE VK_F4, VK_F11
					.IF (Keys[VK_MENU])
						invoke bpDestroyForm, ADDR FMain
					.ENDIF
					.IF (FMain.WindowMode == BP_WINDOW_MODE_FULLSCREEN) || \
					(FMain.WindowMode == BP_WINDOW_MODE_FULLSCREEN_EX)
						invoke bpSetWindowMode, ADDR FMain, ScreenMode
					.ELSE
						mov al, FMain.WindowMode
						mov ScreenMode, al
						invoke bpSetWindowMode, ADDR FMain, \
						BP_WINDOW_MODE_FULLSCREEN
					.ENDIF
					
				; Mouse
				CASE VK_LBUTTON
					.IF (UIState == UI_STATE_GAME)
						invoke bpSetMouseMode, ADDR FMain, BP_MOUSE_MODE_LOCKED
					.ENDIF
					mov InputUIConfirm, TRUE
					mov InputUIConfirmT, TRUE
				CASE VK_MWHEEL_DOWN
					sub UIScroll, 12
				CASE VK_MWHEEL_UP
					add UIScroll, 12
					
				IFDEF MODE_DEBUG
				CASE 'F'
					bpMEM32 deltaScale, f(4)
					invoke MulSoundPitch, f(4)
				CASE 'I'
					mov MazeState, MAZE_STATE_WAIT_IMPACT
					mov MazeStateTimer, 0
					invoke alSourceStop, SndSiren
				CASE 'R'
					.IF (Maze)
						call Maze_Free
						invoke Maze_Generate, nRandSeed
					.ENDIF
				CASE 'T'
					invoke Plr_Teleport, MazeDoorPos.X, MazeDoorPos.Z
					mov PlrState, PLAYER_STATE_EXIT
				CASE 'K'
					.IF (Keys[VK_SHIFT])
						invoke Kubale_Spawn, KUBALE_EVENT
					.ELSE
						invoke Kubale_Spawn, KUBALE_ACTIVE
					.ENDIF
				CASE 'B'
					.IF (Keys[VK_SHIFT])
						invoke Wmblyk_Spawn, WMBLYK_STEALTH_WAIT
					.ELSEIF (Keys[VK_CONTROL])
						invoke Wmblyk_Spawn, WMBLYK_WALK
					.ELSE
						invoke Wmblyk_Spawn, WMBLYK_STILL
					.ENDIF
				CASE 'X'
					mov PlrState, PLAYER_STATE_ENTER
				CASE VK_OEM_PLUS
					.IF (Keys[VK_SHIFT])
						add MazeLayer, 5
					.ELSE
						inc MazeLayer
					.ENDIF
					invoke IntToStr, StrLayerNumPtr, MazeLayer
					call UI_ShowLayerPopup
					
				CASE VK_OEM_MINUS
					.IF (Keys[VK_SHIFT])
						sub MazeLayer, 5
					.ELSE
						dec MazeLayer
					.ENDIF
					invoke IntToStr, StrLayerNumPtr, MazeLayer
					call UI_ShowLayerPopup

				CASE VK_F3
					not UIDebug
				CASE '0'
					bpMEM32 MazeCurWallMDL, MdlWall
				CASE '1'
					bpMEM32 MazeCurWallMDL, MdlWallClerestory
				CASE '2'
					bpMEM32 MazeCurWallMDL, MdlWallWainscot
				CASE '3'
					bpMEM32 MazeCurWallMDL, MdlWallColumn
				CASE '4'
					bpMEM32 MazeCurWallMDL, MdlWallArch
				CASE '5'
					bpMEM32 MazeCurWallMDL, MdlWallTunnel
				CASE '6'
					bpMEM32 MazeCurWallMDL, MdlWallSlit
				CASE '7'
					bpMEM32 MazeCurWallMDL, MdlWallSlant
				ENDIF
			ENDSW
			
			; REBINDABLE
			SWITCH [pbx].Keycode
				CASE IBUp
					mov InputAxes[0], FLT_1
				CASE IBDown
					mov InputAxes[4], FLT_1
				CASE IBLeft
					mov InputAxes[8], FLT_1
				CASE IBRight
					mov InputAxes[12], FLT_1
				CASE IBLookUp
					mov InputAxes[16], FLT_1
				CASE IBLookDown
					mov InputAxes[20], FLT_1
				CASE IBLookLeft
					mov InputAxes[24], FLT_1
				CASE IBLookRight
					mov InputAxes[28], FLT_1
				CASE IBCrouch
					mov InputCrouch, 1
				CASE IBGlyph
					mov InputGlyph, 1
				CASE IBAction
					mov InputAction, 1
				CASE IBConfirm
					mov InputConfirm, 1
			ENDSW
		.ELSE
			SWITCH [pbx].Keycode
				CASE IBUIUp
					mov InputUIUp, FALSE
				CASE IBUIDown
					mov InputUIDown, FALSE
				CASE IBUILeft
					mov InputUILeft, FALSE
				CASE IBUIRight
					mov InputUIRight, FALSE
				
				CASE IBUIConfirm
					mov InputUIConfirm, FALSE
					
				; Mouse
				CASE VK_LBUTTON
					mov InputUIConfirm, FALSE
					
				IFDEF MODE_DEBUG
				CASE 'F'
					bpMEM32 deltaScale, f(1)
					invoke MulSoundPitch, f(0.25)
				ENDIF
			ENDSW
			
			; REBINDABLE
			SWITCH [pbx].Keycode
				CASE IBUp
					mov InputAxes[0], 0
				CASE IBDown
					mov InputAxes[4], 0
				CASE IBLeft
					mov InputAxes[8], 0
				CASE IBRight
					mov InputAxes[12], 0
				CASE IBLookUp
					mov InputAxes[16], 0
				CASE IBLookDown
					mov InputAxes[20], 0
				CASE IBLookLeft
					mov InputAxes[24], 0
				CASE IBLookRight
					mov InputAxes[28], 0
				CASE IBCrouch
					mov InputCrouch, 0
				CASE IBGlyph
					mov InputGlyph, 0
				CASE IBAction
					mov InputAction, 0
				CASE IBConfirm
					mov InputConfirm, 0
			ENDSW
		.ENDIF
	.ELSEIF (BPInType == BP_INPUT_JOY_AXIS) || (BPInType == BP_INPUT_JOY_BUTTON)		
		mov eax, DWORD PTR [pbx]
		mov ecx, SIZEOF BPJoystick
		mul ecx
		.IF (bpJoysticks[eax].NumAxes == 4)
			mov XInput, FALSE
		.ELSE
			mov XInput, TRUE
		.ENDIF
		
		mov LastInput, 0
		bpMEM32 LastInputTimer, f(0.2)
		
		.IF (UIBinding == BIND_JOYSTICK)
			.IF (BPInType == BP_INPUT_JOY_AXIS)
				ASSUME pbx:PTR BPInJoyAxis
				bpMEM32 axisVal, [pbx].Position
				and axisVal, not FLT_NEG
				fcmp axisVal, f(0.3)
				jc skipBind	; axisVal < 0.3
			.ENDIF
			mov pcx, UIBindAction
			mov BPPtr PTR [pcx], rv(GPadParse, BPInType, pbx)
			print str$(BPPtr PTR [pcx]), 13, 10
			call UI_HandleMenuEscape
			mov SettingsChanged, TRUE
			skipBind:
		.ELSE
			invoke GPadInput, BPInType, pbx, JBUIUp, ADDR InputUIUp
			.IF (InputUIUp)
				mov LastInput, OFFSET InputUIUp
			.ENDIF
			invoke GPadInput, BPInType, pbx, JBUIDown, ADDR InputUIDown
			.IF (InputUIDown)
				mov LastInput, OFFSET InputUIDown
			.ENDIF
			invoke GPadInput, BPInType, pbx, JBUILeft, ADDR InputUILeft
			invoke GPadInput, BPInType, pbx, JBUIRight, ADDR InputUIRight
			invoke GPadInput, BPInType, pbx, JBUIConfirm, ADDR InputUIConfirm
			bpMEM32 InputUIConfirmT, InputUIConfirm
			
			invoke GPadInput, BPInType, pbx, JBMenu, ADDR InputMenu
			.IF (InputMenu)
				call UI_HandleMenuEscape
				mov InputMenu, FALSE
			.ENDIF
			invoke GPadInput, BPInType, pbx, JBCancel, ADDR InputMenu
			.IF (InputMenu)
				.IF (UIState >= UI_STATE_MENU_PAUSE)
					call UI_HandleMenuEscape
				.ENDIF
				mov InputMenu, FALSE
			.ENDIF
		
			; REBINDABLE
			invoke GPadInput, BPInType, pbx, JBUp, ADDR InputAxes[0]
			invoke GPadInput, BPInType, pbx, JBDown, ADDR InputAxes[4]
			invoke GPadInput, BPInType, pbx, JBLeft, ADDR InputAxes[8]
			invoke GPadInput, BPInType, pbx, JBRight, ADDR InputAxes[12]
			
			invoke GPadInput, BPInType, pbx, JBLookUp, ADDR InputAxes[16]
			invoke GPadInput, BPInType, pbx, JBLookDown, ADDR InputAxes[20]
			invoke GPadInput, BPInType, pbx, JBLookLeft, ADDR InputAxes[24]
			invoke GPadInput, BPInType, pbx, JBLookRight, ADDR InputAxes[28]
			
			invoke GPadInput, BPInType, pbx, JBCrouch, ADDR InputCrouch
			invoke GPadInput, BPInType, pbx, JBGlyph, ADDR InputGlyph
			invoke GPadInput, BPInType, pbx, JBAction, ADDR InputAction
			invoke GPadInput, BPInType, pbx, JBConfirm, ADDR InputConfirm
		.ENDIF
	.ENDIF
	
	ret
OnInput ENDP

OnRender PROC EXPORT
	LOCAL v3Val:Vector3
	
	fld deltaTime
	fmul f(2)
	fst delta2
	fmul f(5)
	fst delta10
	fmul f(2)
	fstp delta20
	
	fld1
	fdiv deltaUnscaled
	fistp FPS		; FPS
	
	.IF (FMain.MouseMode == BP_MOUSE_MODE_LOCKED)
		.IF (!FMain.Focused)
			invoke bpSetMouseMode, ADDR FMain, BP_MOUSE_MODE_VISIBLE
		.ENDIF
	.ENDIF
	
	; Repeat last input
	.IF (LastInput)
		fld LastInputTimer[0]
		fsub deltaUnscaled
		fstp LastInputTimer[0]
		
		fcmp LastInputTimer[0]
		.IF (Carry?)
			fld LastInputTimer[4]
			fsub deltaUnscaled
			fstp LastInputTimer[4]
			
			fcmp LastInputTimer[4]
			.IF (Carry?)
				mov pax, LastInput
				mov BYTE PTR [pax], TRUE
				
				fld LastInputTimer[4]
				fadd f(0.1)
				fstp LastInputTimer[4]
			.ENDIF
		.ENDIF
	.ENDIF
				
	invoke glViewport, 0, 0, FXRenderSize.X, FXRenderSize.Y
	invoke glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT
	invoke glStencilOp, GL_KEEP, GL_KEEP, GL_REPLACE
	invoke glColor4fv, OFFSET clWhite
	invoke glAlphaFunc, GL_GREATER, f(0.5)
	
	invoke glMatrixMode, GL_PROJECTION
	call glLoadIdentity
	
	invoke gluPerspectivef, CamFOV, FMain.Aspect, f(0.01), f(1000)
	
	invoke glMatrixMode, GL_MODELVIEW
	call glLoadIdentity
	
	.IF (Loading)
		call LoadResources
		call UI_Draw
		
		call glFlush
		ret
	.ELSEIF (LoadState == LOADING_FINISHED)
		mov LoadState, LOADING_TEXT
		call GameInit
	.ENDIF
	
	; Processing
	call UI_Process
	.IF (deltaTime)
		call ProcessScene
	.ENDIF
	
	.IF (MazeState != MAZE_STATE_CROA)
		invoke glLightfv, GL_LIGHT0, GL_POSITION, ADDR CamLightPos	; Draw light
	.ENDIF
	
	Vector3Push CamRotL
	;invoke Vector3Negate, ADDR CamRotL
	fld CamRotL.Y
	fadd PI
	fchs
	fstp CamRotL.Y
	invoke glRotate3fvr, ADDR CamRotL	; Cam matrix
	Vector3Pop CamRotL
	Vector3Push CamPosL
	invoke Vector3Negate, ADDR CamPosL
	invoke glTranslate3fv, ADDR CamPosL
	Vector3Pop CamPosL
	
	; Drawing
	invoke glColor4fv, OFFSET clWhite
	invoke glFogf, GL_FOG_DENSITY, FogDensity
	invoke glMaterialfv, GL_FRONT, GL_DIFFUSE, OFFSET clWhite
	
	IFDEF MODE_DEBUG
	.IF (UIDebug)
		invoke glBindTexture, GL_TEXTURE_2D, 0
		invoke glDisable, GL_LIGHTING
		invoke glDisable, GL_FOG
		invoke glColor4fv, ADDR clRed
		invoke glBegin, GL_LINES
		Vector3Push CamPosL
		bpMEM32 CamPosL.Y, f(0.5)
		invoke glVertex3fv, ADDR CamPosL
		invoke Vector3Add, ADDR CamPosL, ADDR PlrForward
		invoke glVertex3fv, ADDR CamPosL
		Vector3Pop CamPosL
		invoke glEnd
		invoke glEnable, GL_LIGHTING
		invoke glEnable, GL_FOG
		invoke glColor4fv, ADDR clWhite
	.ENDIF
	ENDIF
	
	call DrawScene
	call UI_Draw
	
	mov InputUIUp, FALSE
	mov InputUIDown, FALSE
	mov InputUIConfirmT, FALSE
	
	invoke Vector2Set, ADDR InputLook, 0, 0
	
	call glFlush
	ret
OnRender ENDP

OnResize PROC EXPORT
	fild FMain.ScreenSize.x
	fstp ScreenSizeF.X
	fild FMain.ScreenSize.y
	fstp ScreenSizeF.Y
	
	mov eax, FMain.ScreenSize.x
	shr eax, 1
	mov ScreenHalf.X, eax
	mov eax, FMain.ScreenSize.y
	shr eax, 1
	mov ScreenHalf.Y, eax
	
	call FX_Resize

	mov FMain.DefaultFlag, FALSE			; We handle resizing ourselves (FX)
	invoke bpSetScreenCenter, ADDR FMain	; This is default behavior
	ret
OnResize ENDP

OnStart PROC EXPORT
	; Will start loading resources
	call LoadResources
	; Wait for frame to establish, then continue loading
	mov LoadState, LOADING_WAIT
	
	; Apply window settings, this will call OnRender
	invoke bpSetDisplayDevice, ADDR FMain, SettingsGraphicsDisplay
	invoke bpSetScreenSize, ADDR FMain, SettingsGraphicsResolution[0], \
	SettingsGraphicsResolution[4]
	invoke Settings_SetOption, OFFSET SettingsGraphicsWindowMode
	
	; Continue loading after OnRender calls ended
	mov LoadState, LOADING_TEXT+1
	ret
OnStart ENDP

;   FARB bindings
FARBOnCreate PROC EXPORT
	invoke bpInitGLContext, OFFSET FARB
	
	invoke wglGetProcAddress, s("wglChoosePixelFormatARB")
	mov wglChoosePixelFormatARB, pax
	.IF (wglChoosePixelFormatARB)
		print "Got wglChoosePixelFormatARB extension.", 13, 10
	.ELSE
		print "wglChoosePixelFormatARB not retrieved.", 13, 10
	.ENDIF
	
	invoke wglGetProcAddress, s("wglGetPixelFormatAttribivARB")
	mov wglGetPixelFormatAttribivARB, pax
	.IF (wglGetPixelFormatAttribivARB)
		print "Got wglGetPixelFormatAttribivARB extension.", 13, 10
	.ELSE
		print "wglGetPixelFormatAttribivARB not retrieved.", 13, 10
	.ENDIF
	
	invoke bpDestroyForm, OFFSET FARB
	ret
FARBOnCreate ENDP

start:
	print OFFSET AsmTime, 13, 10
	
	finit
	
	; Set FPU precision mode to single precision
	invoke fpuSetPrecision, FPU_PRECISION_REAL4
	;invoke fpuSetInterrupt, FPU_EXCEPTION_INVALID
	
	; Randomize nRand random generation
	call nRandomize
	
	; Load settings from .\settings.ini
	invoke Settings_Load, OFFSET SettingsIniAudio
	invoke Settings_Load, OFFSET SettingsIniControls
	invoke Settings_Load, OFFSET SettingsIniGraphics
	invoke Settings_Load, OFFSET SettingsIniMisc
	
	; Create dummy form to load wgl functions required for MSAA
	mov FARB.OnCreate, OFFSET FARBOnCreate
	invoke bpCreateForm, OFFSET FARB
	
	; Create main form
	; Assign callback functions
	mov FMain.OnCreate,	OFFSET OnCreate
	mov FMain.OnFixed,	OFFSET OnFixed
	mov FMain.OnInput,	OFFSET OnInput
	mov FMain.OnRender,	OFFSET OnRender
	mov FMain.OnResize,	OFFSET OnResize
	mov FMain.OnStart,	OFFSET OnStart
	
	; Set FMain parameters according to loaded settings
	mov FMain.Caption, OFFSET AppName
	.IF (SettingsControlsRawMouse)
		or FMain.InputFlags, MOUSE_RAW
	.ENDIF
	.IF (SettingsControlsJoystick)
		or FMain.InputFlags, JOYSTICK_RAW
	.ENDIF
	mov FMain.WindowStyle, WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU or \
	WS_MINIMIZEBOX
	
	invoke bpCreateForm, OFFSET FMain
	
	; Form processing exited, we can safely terminate process
	invoke TerminateProcess, rv(GetCurrentProcess), 0
end start