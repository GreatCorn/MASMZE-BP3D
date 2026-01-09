.386
.model flat,stdcall
option casemap:none

BP_IMPORTERS_VERBOSE	EQU <1>

include ..\BoilPlate3D\src\BP3D.asm

include include\advapi32.inc
includelib advapi32.lib
include include\masm32.inc
includelib masm32.lib
include include\msvcrt.inc
includelib msvcrt.lib
include macros\macros.asm

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

;   Implicit call a function identifier with VARARG arguments.
vinvoke MACRO FuncName:REQ, args:VARARG
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
	call FuncName
ENDM

;   Make the argument into a string (for preprocessor @ data).
stringify MACRO arg
    LOCAL foo
    foo CATSTR <'>,arg,<'>
    EXITM foo
ENDM
.CONST
AppName DB "MASMZE-3D", 0	; App name & caption
AsmTime	DB "Assembly time: ", stringify(@Date), 32, stringify(@Time), 13, 10, 0

.DATA
; ----- Forms, form creation -----
FARB	BPForm <>		; Dummy form to load wgl functions and init ARB ext
FMain	BPForm <>		; Main form

ARBPixelAttribsMSAA DWORD \	; Pixel attributes for MSAA
	2001h, GL_TRUE, \			; WGL_DRAW_TO_WINDOW_ARB = true
	2010h, GL_TRUE, \			; WGL_SUPPORT_OPENGL_ARB = true
	2011h, GL_TRUE, \			; WGL_DOUBLE_BUFFER_ARB = true
	2013h, 202Bh, \				; WGL_PIXEL_TYPE_ARB = WGL_TYPE_RGBA_ARB
	2014h, 24, \				; WGL_COLOR_BITS_ARB = 24
	2022h, 24, \				; WGL_DEPTH_BITS_ARB = 24
	2041h, 1, \					; WGL_SAMPLE_BUFFERS_ARB = 1 (multisample)
	2042h, 4, \					; WGL_SAMPLES_ARB = 4 (4x MSAA?)
0		

AudioDevice		ALCdevice 0		; OpenAL audio device
AudioContext	ALCcontext 0	; OpenAL audio context

Glyphs	DWORD 7

.DATA?
delta2	REAL4 ?
delta10	REAL4 ?
FPUCW	WORD ?	; To store the x87 FPU codeword

; ----- WGL extended functions -----
wglChoosePixelFormatARB			BPPtr ?
wglGetPixelFormatAttribivARB	BPPtr ?
wglSwapIntervalEXT				BPPtr ?

CurrentFloor	DWORD ?	; Environmental variety
CurrentRoof		DWORD ?
CurrentWall		DWORD ?
CurrentWallMDL	DWORD ?

include Resources.asm

include Maze.asm
include Kubale.asm
include Player.asm
include UI.asm

include Settings.asm

.CODE

;   Manually initialize an ARB-compatible OpenGL context on FMain
InitARBContext PROC EXPORT
	LOCAL numFormats:UINT, pixelFormat:DWORD, pfd:PIXELFORMATDESCRIPTOR
	
	mov FMain.DeviceContext, rv(GetDC, FMain.Handle)

	vinvoke wglChoosePixelFormatARB, FMain.DeviceContext, \
	ADDR ARBPixelAttribsMSAA, 0, 1, ADDR pixelFormat, ADDR numFormats
	
	invoke DescribePixelFormat, FMain.DeviceContext, pixelFormat, \
	SIZEOF PIXELFORMATDESCRIPTOR, ADDR pfd
	.IF (!al)
		invoke bpError, SADD("Can't describe pixel format."), 0
	.ENDIF
	
	invoke SetPixelFormat, FMain.DeviceContext, pixelFormat, ADDR pfd
	.IF (!al)
		invoke bpError, SADD("Can't set pixel format."), 0
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
	ret
InitARBContext ENDP

InitAudio PROC EXPORT
	mov AudioDevice, rv(alcOpenDevice, NULL)
	mov AudioContext, rv(alcCreateContext, AudioDevice, NULL)
	invoke alcMakeContextCurrent, AudioContext
	ret
InitAudio ENDP

InitGraphics PROC EXPORT
	; Initialize the respective OpenGL context
	.IF (SettingsGraphicsMSAA) && (wglChoosePixelFormatARB)
		m2m ARBPixelAttribsMSAA[15*4], SettingsGraphicsMSAA
		invoke InitARBContext
	.ELSE
		invoke bpInitGLContext, ADDR FMain	; Initialize OpenGL context
	.ENDIF
	
	invoke wglGetProcAddress, SADD("wglSwapIntervalEXT")
	mov wglSwapIntervalEXT, pax
	.IF (wglSwapIntervalEXT)
		print "Got wglSwapIntervalEXT extension.", 13, 10
		invoke Settings_SetOption, OFFSET SettingsGraphicsVSync
	.ENDIF
	
	m2m bpAnimationFPS, f(24)
	
	invoke glHint, GL_FOG_HINT, GL_FASTEST
	invoke glHint, GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST
	
	invoke glPixelStorei, GL_PACK_ALIGNMENT, 1
	invoke glPixelStorei, GL_UNPACK_ALIGNMENT, 1
	
	invoke glEnable, GL_LIGHTING
	invoke glEnable, GL_LIGHT0
	invoke glLightfv, GL_LIGHT0, GL_SPECULAR, ADDR clGray
	invoke glLightf, GL_LIGHT0, GL_CONSTANT_ATTENUATION, f(1)
	
	invoke glEnable, GL_FOG
	
	invoke glMaterialf, GL_FRONT, GL_SHININESS, f(64)
	invoke glMaterialfv, GL_FRONT, GL_SPECULAR, ADDR clGray
	ret
InitGraphics ENDP


;   FMain bindings
OnCreate PROC EXPORT
	call InitAudio
	call InitGraphics
	call LoadResources
	print "Finished initialization.", 13, 10
	.IF !(rv(Settings_LoadGame))
		; If no save game is present start intro sequence
		invoke alSourcePlay, SndIntro
	.ENDIF
	invoke bpSetMouseMode, ADDR FMain, BP_MOUSE_MODE_LOCKED
	ret
OnCreate ENDP

OnInput PROC EXPORT BPInType:BPEnum, BPInStruct:BPPtr
	
	ret
OnInput ENDP

OnRender PROC EXPORT
	fld deltaTime
	fmul f(2)
	fst delta2
	fmul f(5)
	fstp delta10
	
	.IF (FMain.MouseMode == BP_MOUSE_MODE_LOCKED)
		.IF (!FMain.Focused)
			invoke bpSetMouseMode, ADDR FMain, BP_MOUSE_MODE_VISIBLE
		.ENDIF
	.ENDIF
	
	invoke glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT
	
	invoke glMatrixMode, GL_PROJECTION
	call glLoadIdentity
	
	invoke glMatrixMode, GL_MODELVIEW
	call glLoadIdentity
	
	call glFlush
	ret
OnRender ENDP

;   FARB bindings
FARBOnCreate PROC EXPORT
	invoke bpInitGLContext, ADDR FARB
	
	invoke wglGetProcAddress, SADD("wglChoosePixelFormatARB")
	mov wglChoosePixelFormatARB, pax
	.IF (wglChoosePixelFormatARB)
		print "Got wglChoosePixelFormatARB extension.", 13, 10
	.ELSE
		print "wglChoosePixelFormatARB not retrieved.", 13, 10
	.ENDIF
	
	invoke wglGetProcAddress, SADD("wglGetPixelFormatAttribivARB")
	mov wglGetPixelFormatAttribivARB, pax
	.IF (wglGetPixelFormatAttribivARB)
		print "Got wglGetPixelFormatAttribivARB extension.", 13, 10
	.ELSE
		print "wglGetPixelFormatAttribivARB not retrieved.", 13, 10
	.ENDIF
	
	invoke bpDestroyForm, ADDR FARB
	ret
FARBOnCreate ENDP

start:
	print ADDR AsmTime, 13, 10
	
	finit
	
	; Set FPU precision mode to single precision
	invoke fpuSetPrecision, FPU_PRECISION_REAL4
	invoke fpuSetInterrupt, FPU_EXCEPTION_INVALID
	
	; Randomize nRand random generation
	call nRandomize
	
	; Load settings from .\settings.ini
	call Settings_Load
	
	; Create dummy form to load wgl functions required for MSAA
	mov FARB.OnCreate, OFFSET FARBOnCreate
	invoke bpCreateForm, ADDR FARB
	
	; Create main form
	; Assign callback functions
	mov FMain.OnCreate, OFFSET OnCreate
	mov FMain.OnInput, OFFSET OnInput
	mov FMain.OnRender, OFFSET OnRender
	
	; Set FMain parameters according to loaded settings
	mov FMain.Caption, OFFSET AppName
	.IF (SettingsControlsRawMouse)
		or FMain.InputFlags, BP_IF_RAW_MOUSE
	.ENDIF
	.IF (SettingsControlsJoystick)
		or FMain.InputFlags, BP_IF_JOYSTICK
	.ENDIF
	mov FMain.WindowStyle, WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU or \
	WS_MINIMIZEBOX
	
	invoke bpCreateForm, ADDR FMain
	
	; Form processing exited, we can safely terminate process
	invoke TerminateProcess, rv(GetCurrentProcess), 0
end start