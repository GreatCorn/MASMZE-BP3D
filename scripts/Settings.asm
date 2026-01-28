.CONST
SettingsIniAudio			DB "Audio", 0
SettingsIniVolume			DB "Volume", 0

SettingsIniControls			DB "Controls", 0
SettingsIniJoystick			DB "Joystick", 0
SettingsIniJoystickSpeed	DB "JoystickSpeed", 0
SettingsIniMouseSensitivity	DB "MouseSensitivity", 0
SettingsIniRawMouse			DB "RawMouse", 0

; Bind settings are in main
SettingsIniIBUp				DB "IBUp", 0
SettingsIniIBDown			DB "IBDown", 0
SettingsIniIBLeft			DB "IBLeft", 0
SettingsIniIBRight			DB "IBRight", 0
SettingsIniIBLookUp			DB "IBLookUp", 0
SettingsIniIBLookDown		DB "IBLookDown", 0
SettingsIniIBLookLeft		DB "IBLookLeft", 0
SettingsIniIBLookRight		DB "IBLookRight", 0
SettingsIniIBCrouch			DB "IBCrouch", 0
SettingsIniIBGlyph			DB "IBGlyph", 0
SettingsIniIBAction			DB "IBAction", 0
SettingsIniIBConfirm		DB "IBConfirm", 0

SettingsIniJBUp				DB "JBUp", 0
SettingsIniJBDown			DB "JBDown", 0
SettingsIniJBLeft			DB "JBLeft", 0
SettingsIniJBRight			DB "JBRight", 0
SettingsIniJBLookUp			DB "JBLookUp", 0
SettingsIniJBLookDown		DB "JBLookDown", 0
SettingsIniJBLookLeft		DB "JBLookLeft", 0
SettingsIniJBLookRight		DB "JBLookRight", 0
SettingsIniJBCrouch			DB "JBCrouch", 0
SettingsIniJBGlyph			DB "JBGlyph", 0
SettingsIniJBAction			DB "JBAction", 0
SettingsIniJBConfirm		DB "JBConfirm", 0

SettingsIniGraphics			DB "Graphics", 0
SettingsIniAfterimage		DB "Afterimage", 0
SettingsIniDisplay			DB "Display", 0
SettingsIniGamma			DB "Gamma", 0
SettingsIniGammaBypass		DB "GammaBypass", 0
SettingsIniMazeCull			DB "MazeCull", 0
SettingsIniMSAA				DB "MSAA", 0
SettingsIniNoise			DB "Noise", 0
SettingsIniParticles		DB "Particles", 0
SettingsIniPixelization		DB "Pixelization", 0
SettingsIniPosterization	DB "Posterization", 0
SettingsIniResolutionWidth	DB "Width", 0
SettingsIniResolutionHeight	DB "Height", 0
SettingsIniVignette			DB "Vignette", 0
SettingsIniVSync			DB "VSync", 0
SettingsIniWindowMode		DB "WindowMode", 0

SettingsIniMisc				DB "Misc", 0
SettingsIniLanguage			DB "Language", 0

SettingsIni2f		DB "2.0", 0
SettingsIni1f		DB "1.0", 0
SettingsIni0n5f		DB "0.5", 0
SettingsIniEnUS		DB "en_US.bplang", 0
SettingsIniFalse	DB "false", 0
SettingsIniTrue		DB "true", 0

SettingsLangPath	DB ".\lang\*", 0
LANGOFFSET			EQU SIZEOF SettingsLangPath - 2

SettingsRegCompass		DB "Compass", 0
SettingsRegComplete		DB "Complete", 0
SettingsRegCurLayer		DB "CurLayer", 0
SettingsRegCurWidth		DB "CurWidth", 0
SettingsRegCurHeight	DB "CurHeight", 0
SettingsRegFloor		DB "Floor", 0
SettingsRegGlyphs		DB "Glyphs", 0
SettingsRegLayer		DB "Layer", 0
SettingsRegMazeW		DB "MazeW", 0
SettingsRegMazeH		DB "MazeH", 0
SettingsRegRoof			DB "Roof", 0
SettingsRegWall			DB "Wall", 0

SettingsIniPath	DB "settings.ini", 0
SettingsRegPath DB "Software\\GreatCorn\\MASMZE-3D", 0

.DATA
SettingsAudioVolume				REAL4 1.0

SettingsControlsJoystick			BPBool TRUE
SettingsControlsJoystickSpeed		REAL4 2.0
SettingsControlsMouseSensitivity	REAL4 0.5
SettingsControlsRawMouse			BPBool TRUE

SettingsGraphicsAfterimage		BPBool TRUE
SettingsGraphicsDisplay			DWORD 0
SettingsGraphicsGamma			REAL4 0.5
SettingsGraphicsGammaBypass		BPBool FALSE
SettingsGraphicsMazeCull		DWORD 5
SettingsGraphicsMSAA			DWORD 0
SettingsGraphicsNoise			BPBool TRUE
SettingsGraphicsParticles		BPBool TRUE
SettingsGraphicsPixelization	BPBool TRUE
SettingsGraphicsPosterization	BPBool TRUE
SettingsGraphicsResolution		DWORD 854, 480
SettingsGraphicsVignette		BPBool TRUE
SettingsGraphicsVSync			BPBool TRUE
SettingsGraphicsWindowMode		BPEnum BP_WINDOW_MODE_WINDOWED

SettingsMiscLanguage			DB 256 DUP (0)
SettingsMiscMultithreading		BPBool TRUE

SettingsChanged		BPBool FALSE
SettingsIniDouble	REAL8 0.0
SettingsIniPathAbs	DB 256 DUP(0)
SettingsIniString	DB 16 DUP(0)

.DATA?
SettingsRegistry HKEY ?	; Default registry key

.CODE
Settings_SetOption PROTO :BPPtr

Settings_IsTrue PROC EXPORT 
	.IF (SettingsIniString[0] == 116) || (SettingsIniString[0] == 84) ; t or T
		mov pax, TRUE
	.ELSE
		xor pax, pax
	.ENDIF
	ret
Settings_IsTrue ENDP

Settings_Load PROC EXPORT 
	; Get absolute path to settings.ini
	invoke GetFullPathNameA, ADDR SettingsIniPath, LENGTH SettingsIniPathAbs, \
	ADDR SettingsIniPathAbs, 0
	print "Loading settings from "
	print ADDR SettingsIniPathAbs, 13, 10
	
	; ----- AUDIO -----
	; Volume
	invoke GetPrivateProfileString, ADDR SettingsIniAudio, \
	ADDR SettingsIniVolume, ADDR SettingsIni1f, ADDR SettingsIniString, \
	9, ADDR SettingsIniPathAbs
	invoke StrToFl, ADDR SettingsIniString, ADDR SettingsAudioVolume
	invoke Settings_SetOption, OFFSET SettingsAudioVolume
	
	; ----- CONTROLS -----
	; Joystick
	invoke GetPrivateProfileString, ADDR SettingsIniControls, \
	ADDR SettingsIniJoystick, ADDR SettingsIniTrue, ADDR SettingsIniString, \
	9, ADDR SettingsIniPathAbs
	call Settings_IsTrue
	.IF (al != SettingsControlsJoystick)
		mov SettingsControlsJoystick, al
		invoke Settings_SetOption, OFFSET SettingsControlsJoystick
	.ENDIF
	
	; Joystick speed
	invoke GetPrivateProfileString, ADDR SettingsIniControls, \
	ADDR SettingsIniJoystickSpeed, ADDR SettingsIni2f, ADDR SettingsIniString, \
	9, ADDR SettingsIniPathAbs
	invoke StrToFl, ADDR SettingsIniString, ADDR SettingsControlsJoystickSpeed
	
	; Mouse sensitivity
	invoke GetPrivateProfileString, ADDR SettingsIniControls, \
	ADDR SettingsIniMouseSensitivity, ADDR SettingsIni0n5f, \
	ADDR SettingsIniString, 9, ADDR SettingsIniPathAbs
	invoke StrToFl, ADDR SettingsIniString,ADDR SettingsControlsMouseSensitivity
	
	; Raw mouse
	invoke GetPrivateProfileString, ADDR SettingsIniControls, \
	ADDR SettingsIniRawMouse, ADDR SettingsIniTrue, ADDR SettingsIniString, \
	9, ADDR SettingsIniPathAbs
	call Settings_IsTrue
	.IF (al != SettingsControlsRawMouse)
		mov SettingsControlsRawMouse, al
		invoke Settings_SetOption, OFFSET SettingsControlsRawMouse
	.ENDIF
	
	; ----- GRAPHICS -----
	; Afterimage
	invoke GetPrivateProfileString, ADDR SettingsIniGraphics, \
	ADDR SettingsIniAfterimage, ADDR SettingsIniTrue, ADDR SettingsIniString, \
	9, ADDR SettingsIniPathAbs
	call Settings_IsTrue
	.IF (al != SettingsGraphicsAfterimage)
		mov SettingsGraphicsAfterimage, al
		invoke Settings_SetOption, OFFSET SettingsGraphicsAfterimage
	.ENDIF
	
	; Display device
	invoke GetPrivateProfileInt, ADDR SettingsIniGraphics, \
	ADDR SettingsIniDisplay, 0, ADDR SettingsIniPathAbs
	.IF (eax != SettingsGraphicsDisplay)
		mov SettingsGraphicsDisplay, eax
		invoke Settings_SetOption, OFFSET SettingsGraphicsDisplay
	.ENDIF
	
	; Gamma
	invoke GetPrivateProfileString, ADDR SettingsIniGraphics, \
	ADDR SettingsIniGamma, ADDR SettingsIni0n5f, ADDR SettingsIniString,\
	9, ADDR SettingsIniPathAbs
	invoke StrToFl, ADDR SettingsIniString, ADDR SettingsGraphicsGamma
	
	; Gamma bypass
	invoke GetPrivateProfileString, ADDR SettingsIniGraphics, \
	ADDR SettingsIniGammaBypass, ADDR SettingsIniFalse, ADDR SettingsIniString,\
	9, ADDR SettingsIniPathAbs
	call Settings_IsTrue
	.IF (al != SettingsGraphicsGammaBypass)
		mov SettingsGraphicsGammaBypass, al
	.ENDIF
	
	; Maze cull radius
	invoke GetPrivateProfileInt, ADDR SettingsIniGraphics, \
	ADDR SettingsIniMazeCull, SettingsGraphicsMazeCull, ADDR SettingsIniPathAbs
	.IF (eax != SettingsGraphicsMazeCull)
		mov SettingsGraphicsMazeCull, eax
		invoke Settings_SetOption, OFFSET SettingsGraphicsMazeCull
	.ENDIF
	
	; MSAA
	invoke GetPrivateProfileInt, ADDR SettingsIniGraphics, \
	ADDR SettingsIniMSAA, 0, ADDR SettingsIniPathAbs
	.IF (eax != SettingsGraphicsMSAA)
		mov SettingsGraphicsMSAA, eax
		invoke Settings_SetOption, OFFSET SettingsGraphicsMSAA
	.ENDIF
	
	; Noise
	invoke GetPrivateProfileString, ADDR SettingsIniGraphics, \
	ADDR SettingsIniNoise, ADDR SettingsIniTrue, ADDR SettingsIniString,\
	9, ADDR SettingsIniPathAbs
	call Settings_IsTrue
	.IF (al != SettingsGraphicsNoise)
		mov SettingsGraphicsNoise, al
	.ENDIF
	
	; Particles
	invoke GetPrivateProfileString, ADDR SettingsIniGraphics, \
	ADDR SettingsIniParticles, ADDR SettingsIniTrue, ADDR SettingsIniString,\
	9, ADDR SettingsIniPathAbs
	call Settings_IsTrue
	.IF (al != SettingsGraphicsParticles)
		mov SettingsGraphicsParticles, al
	.ENDIF
	
	; Pixelization
	invoke GetPrivateProfileString, ADDR SettingsIniGraphics, \
	ADDR SettingsIniPixelization, ADDR SettingsIniTrue, ADDR SettingsIniString,\
	9, ADDR SettingsIniPathAbs
	call Settings_IsTrue
	.IF (al != SettingsGraphicsPixelization)
		mov SettingsGraphicsPixelization, al
		invoke Settings_SetOption, OFFSET SettingsGraphicsPixelization
	.ENDIF
	
	; Posterization
	invoke GetPrivateProfileString, ADDR SettingsIniGraphics, \
	ADDR SettingsIniPosterization,ADDR SettingsIniTrue,ADDR SettingsIniString, \
	9, ADDR SettingsIniPathAbs
	call Settings_IsTrue
	.IF (al != SettingsGraphicsPosterization)
		mov SettingsGraphicsPosterization, al
	.ENDIF
	
	; Resolution
	invoke GetPrivateProfileInt, ADDR SettingsIniGraphics, \
	ADDR SettingsIniResolutionWidth, 800, ADDR SettingsIniPathAbs
	push pax
	invoke GetPrivateProfileInt, ADDR SettingsIniGraphics, \
	ADDR SettingsIniResolutionHeight, 600, ADDR SettingsIniPathAbs
	pop pcx
	.IF (SettingsGraphicsResolution[0] != ecx) || \
	(SettingsGraphicsResolution[4] != eax)
		mov SettingsGraphicsResolution[0], ecx
		mov SettingsGraphicsResolution[4], eax
		invoke Settings_SetOption, OFFSET SettingsGraphicsResolution
	.ENDIF
	
	; Vignette
	invoke GetPrivateProfileString, ADDR SettingsIniGraphics, \
	ADDR SettingsIniVignette, ADDR SettingsIniTrue, ADDR SettingsIniString, \
	9, ADDR SettingsIniPathAbs
	call Settings_IsTrue
	.IF (al != SettingsGraphicsVignette)
		mov SettingsGraphicsVignette, al
	.ENDIF
	
	; VSync
	invoke GetPrivateProfileString, ADDR SettingsIniGraphics, \
	ADDR SettingsIniVSync, ADDR SettingsIniTrue, ADDR SettingsIniString, \
	9, ADDR SettingsIniPathAbs
	call Settings_IsTrue
	.IF (al != SettingsGraphicsVSync)
		mov SettingsGraphicsVSync, al
		invoke Settings_SetOption, OFFSET SettingsGraphicsVSync
	.ENDIF
	
	; Window mode
	invoke GetPrivateProfileInt, ADDR SettingsIniGraphics, \
	ADDR SettingsIniWindowMode, 0, ADDR SettingsIniPathAbs
	.IF (al != SettingsGraphicsWindowMode)
		mov SettingsGraphicsWindowMode, al
		invoke Settings_SetOption, OFFSET SettingsGraphicsWindowMode
	.ENDIF
	
	
	; ----- MISC -----
	; Language
	invoke GetPrivateProfileString, ADDR SettingsIniMisc, \
	ADDR SettingsIniLanguage, ADDR SettingsIniEnUS, \
	ADDR SettingsMiscLanguage, 255, ADDR SettingsIniPathAbs
	invoke Settings_SetOption, OFFSET SettingsMiscLanguage
	
	mov SettingsChanged, FALSE
	ret
Settings_Load ENDP

Settings_LoadBindings PROC EXPORT
	; Keyboard/mouse
	invoke GetPrivateProfileInt, ADDR SettingsIniControls, \
	ADDR SettingsIniIBUp, IBUp, ADDR SettingsIniPathAbs
	mov IBUp, eax
	invoke GetPrivateProfileInt, ADDR SettingsIniControls, \
	ADDR SettingsIniIBDown, IBDown, ADDR SettingsIniPathAbs
	mov IBDown, eax
	invoke GetPrivateProfileInt, ADDR SettingsIniControls, \
	ADDR SettingsIniIBLeft, IBLeft, ADDR SettingsIniPathAbs
	mov IBLeft, eax
	invoke GetPrivateProfileInt, ADDR SettingsIniControls, \
	ADDR SettingsIniIBRight, IBRight, ADDR SettingsIniPathAbs
	mov IBRight, eax
	invoke GetPrivateProfileInt, ADDR SettingsIniControls, \
	ADDR SettingsIniIBLookUp, IBLookUp, ADDR SettingsIniPathAbs
	mov IBLookUp, eax
	invoke GetPrivateProfileInt, ADDR SettingsIniControls, \
	ADDR SettingsIniIBLookDown, IBLookDown, ADDR SettingsIniPathAbs
	mov IBLookDown, eax
	invoke GetPrivateProfileInt, ADDR SettingsIniControls, \
	ADDR SettingsIniIBLookLeft, IBLookLeft, ADDR SettingsIniPathAbs
	mov IBLookLeft, eax
	invoke GetPrivateProfileInt, ADDR SettingsIniControls, \
	ADDR SettingsIniIBLookRight, IBLookRight, ADDR SettingsIniPathAbs
	mov IBLookRight, eax
	invoke GetPrivateProfileInt, ADDR SettingsIniControls, \
	ADDR SettingsIniIBCrouch, IBCrouch, ADDR SettingsIniPathAbs
	mov IBCrouch, eax
	invoke GetPrivateProfileInt, ADDR SettingsIniControls, \
	ADDR SettingsIniIBGlyph, IBGlyph, ADDR SettingsIniPathAbs
	mov IBGlyph, eax
	invoke GetPrivateProfileInt, ADDR SettingsIniControls, \
	ADDR SettingsIniIBAction, IBAction, ADDR SettingsIniPathAbs
	mov IBAction, eax
	invoke GetPrivateProfileInt, ADDR SettingsIniControls, \
	ADDR SettingsIniIBConfirm, IBConfirm, ADDR SettingsIniPathAbs
	mov IBConfirm, eax
	
	; Joystick
	invoke GetPrivateProfileInt, ADDR SettingsIniControls, \
	ADDR SettingsIniJBUp, JBUp, ADDR SettingsIniPathAbs
	mov JBUp, eax
	invoke GetPrivateProfileInt, ADDR SettingsIniControls, \
	ADDR SettingsIniJBDown, JBDown, ADDR SettingsIniPathAbs
	mov JBDown, eax
	invoke GetPrivateProfileInt, ADDR SettingsIniControls, \
	ADDR SettingsIniJBLeft, JBLeft, ADDR SettingsIniPathAbs
	mov JBLeft, eax
	invoke GetPrivateProfileInt, ADDR SettingsIniControls, \
	ADDR SettingsIniJBRight, JBRight, ADDR SettingsIniPathAbs
	mov JBRight, eax
	invoke GetPrivateProfileInt, ADDR SettingsIniControls, \
	ADDR SettingsIniJBLookUp, JBLookUp, ADDR SettingsIniPathAbs
	mov JBLookUp, eax
	invoke GetPrivateProfileInt, ADDR SettingsIniControls, \
	ADDR SettingsIniJBLookDown, JBLookDown, ADDR SettingsIniPathAbs
	mov JBLookDown, eax
	invoke GetPrivateProfileInt, ADDR SettingsIniControls, \
	ADDR SettingsIniJBLookLeft, JBLookLeft, ADDR SettingsIniPathAbs
	mov JBLookLeft, eax
	invoke GetPrivateProfileInt, ADDR SettingsIniControls, \
	ADDR SettingsIniJBLookRight, JBLookRight, ADDR SettingsIniPathAbs
	mov JBLookRight, eax
	invoke GetPrivateProfileInt, ADDR SettingsIniControls, \
	ADDR SettingsIniJBCrouch, JBCrouch, ADDR SettingsIniPathAbs
	mov JBCrouch, eax
	invoke GetPrivateProfileInt, ADDR SettingsIniControls, \
	ADDR SettingsIniJBGlyph, JBGlyph, ADDR SettingsIniPathAbs
	mov JBGlyph, eax
	invoke GetPrivateProfileInt, ADDR SettingsIniControls, \
	ADDR SettingsIniJBAction, JBAction, ADDR SettingsIniPathAbs
	mov JBAction, eax
	invoke GetPrivateProfileInt, ADDR SettingsIniControls, \
	ADDR SettingsIniJBConfirm, JBConfirm, ADDR SettingsIniPathAbs
	mov JBConfirm, eax
	ret
Settings_LoadBindings ENDP

Settings_LoadGame PROC EXPORT
	LOCAL pcbData:DWORD
	
	invoke RegCreateKeyExA, HKEY_CURRENT_USER, ADDR SettingsRegPath, 0, NULL, \
	REG_OPTION_NON_VOLATILE, KEY_READ, NULL, ADDR SettingsRegistry, NULL
	.IF (eax != ERROR_SUCCESS)
		print "Failed to create registry key.", 13, 10
		xor pax, pax
		ret
	.ENDIF
	print "Loading game from "
	print ADDR SettingsRegPath, 13, 10
	
	mov pcbData, 4
	invoke RegQueryValueExA, SettingsRegistry, ADDR SettingsRegCurLayer, 0, \
	NULL, ADDR MazeLayer, ADDR pcbData
	.IF (eax == ERROR_SUCCESS)	; Load temporary progress
	
	.ELSE
		invoke RegQueryValueExA, SettingsRegistry, ADDR SettingsRegLayer, 0, \
		NULL, ADDR MazeLayer, ADDR pcbData
		.IF (eax != ERROR_SUCCESS)
			print "Failed to read layer value (DWORD).", 13, 10
			print str$(MazeLayer), 13, 10
			xor pax, pax
			ret
		.ENDIF
	.ENDIF
	invoke RegCloseKey, SettingsRegistry
	mov pax, TRUE
	ret
Settings_LoadGame ENDP

Settings_Save PROC EXPORT IniSection:BPPtr	
	mov SettingsChanged, FALSE
	print "Saving settings to section "
	print IniSection
	print " in "
	print ADDR SettingsIniPathAbs, 13, 10
	.IF (IniSection == OFFSET SettingsIniAudio)
		; Volume
		invoke WritePrivateProfileStringA, ADDR SettingsIniAudio, \
		ADDR SettingsIniVolume, real4$(SettingsAudioVolume), \
		ADDR SettingsIniPathAbs
	.ELSEIF (IniSection == OFFSET SettingsIniControls)
		; Mouse sensitivity
		invoke WritePrivateProfileStringA, ADDR SettingsIniControls, \
		ADDR SettingsIniMouseSensitivity, \
		real4$(SettingsControlsMouseSensitivity), ADDR SettingsIniPathAbs
		
		; Use raw mouse
		.IF (SettingsControlsRawMouse)
			lea pax, SettingsIniTrue
		.ELSE
			lea pax, SettingsIniFalse
		.ENDIF
		invoke WritePrivateProfileStringA, ADDR SettingsIniControls, \
		ADDR SettingsIniRawMouse, pax, ADDR SettingsIniPathAbs
		
		; Use joystick
		.IF (SettingsControlsJoystick)
			lea pax, SettingsIniTrue
		.ELSE
			lea pax, SettingsIniFalse
		.ENDIF
		invoke WritePrivateProfileStringA, ADDR SettingsIniControls, \
		ADDR SettingsIniJoystick, pax, ADDR SettingsIniPathAbs
		
		; Joystick speed
		invoke WritePrivateProfileStringA, ADDR SettingsIniControls, \
		ADDR SettingsIniJoystickSpeed, \
		real4$(SettingsControlsJoystickSpeed), ADDR SettingsIniPathAbs
		
		; Bindings
		call Settings_SaveBindings
	.ELSEIF (IniSection == OFFSET SettingsIniGraphics)
		; Resolution
		invoke WritePrivateProfileStringA, ADDR SettingsIniGraphics, \
		ADDR SettingsIniResolutionWidth, \
		str$(SettingsGraphicsResolution[0]), ADDR SettingsIniPathAbs
		invoke WritePrivateProfileStringA, ADDR SettingsIniGraphics, \
		ADDR SettingsIniResolutionHeight, \
		str$(SettingsGraphicsResolution[4]), ADDR SettingsIniPathAbs
		
		; Window mode
		invoke WritePrivateProfileStringA, ADDR SettingsIniGraphics, \
		ADDR SettingsIniWindowMode, ubyte$(SettingsGraphicsWindowMode), \
		ADDR SettingsIniPathAbs
		
		; Display device
		invoke WritePrivateProfileStringA, ADDR SettingsIniGraphics, \
		ADDR SettingsIniDisplay, str$(SettingsGraphicsDisplay), \
		ADDR SettingsIniPathAbs
		
		; VSync
		.IF (SettingsGraphicsVSync)
			lea pax, SettingsIniTrue
		.ELSE
			lea pax, SettingsIniFalse
		.ENDIF
		invoke WritePrivateProfileStringA, ADDR SettingsIniGraphics, \
		ADDR SettingsIniVSync, pax, ADDR SettingsIniPathAbs
		
		; Maze cull radius
		invoke WritePrivateProfileStringA, ADDR SettingsIniGraphics, \
		ADDR SettingsIniMazeCull, str$(SettingsGraphicsMazeCull), \
		ADDR SettingsIniPathAbs
		
		; Gamma
		invoke WritePrivateProfileStringA, ADDR SettingsIniGraphics, \
		ADDR SettingsIniGamma, real4$(SettingsGraphicsGamma), \
		ADDR SettingsIniPathAbs
		
		; Gamma bypass
		.IF (SettingsGraphicsGammaBypass)
			lea pax, SettingsIniTrue
		.ELSE
			lea pax, SettingsIniFalse
		.ENDIF
		invoke WritePrivateProfileStringA, ADDR SettingsIniGraphics, \
		ADDR SettingsIniGammaBypass, pax, ADDR SettingsIniPathAbs
		
		; MSAA
		invoke WritePrivateProfileStringA, ADDR SettingsIniGraphics, \
		ADDR SettingsIniMSAA, str$(SettingsGraphicsMSAA), \
		ADDR SettingsIniPathAbs
		
		; Pixelization
		.IF (SettingsGraphicsPixelization)
			lea pax, SettingsIniTrue
		.ELSE
			lea pax, SettingsIniFalse
		.ENDIF
		invoke WritePrivateProfileStringA, ADDR SettingsIniGraphics, \
		ADDR SettingsIniPixelization, pax, ADDR SettingsIniPathAbs
		
		; Posterization
		.IF (SettingsGraphicsPosterization)
			lea pax, SettingsIniTrue
		.ELSE
			lea pax, SettingsIniFalse
		.ENDIF
		invoke WritePrivateProfileStringA, ADDR SettingsIniGraphics, \
		ADDR SettingsIniPosterization, pax, ADDR SettingsIniPathAbs
		
		; Afterimage
		.IF (SettingsGraphicsAfterimage)
			lea pax, SettingsIniTrue
		.ELSE
			lea pax, SettingsIniFalse
		.ENDIF
		invoke WritePrivateProfileStringA, ADDR SettingsIniGraphics, \
		ADDR SettingsIniAfterimage, pax, ADDR SettingsIniPathAbs
		
		; Particles
		.IF (SettingsGraphicsParticles)
			lea pax, SettingsIniTrue
		.ELSE
			lea pax, SettingsIniFalse
		.ENDIF
		invoke WritePrivateProfileStringA, ADDR SettingsIniGraphics, \
		ADDR SettingsIniParticles, pax, ADDR SettingsIniPathAbs
	.ENDIF
	ret
Settings_Save ENDP

Settings_SaveBindings PROC EXPORT
	; Keyboard/mouse
	invoke WritePrivateProfileStringA, ADDR SettingsIniControls, \
	ADDR SettingsIniIBUp, str$(IBUp), ADDR SettingsIniPathAbs
	invoke WritePrivateProfileStringA, ADDR SettingsIniControls, \
	ADDR SettingsIniIBDown, str$(IBDown), ADDR SettingsIniPathAbs
	invoke WritePrivateProfileStringA, ADDR SettingsIniControls, \
	ADDR SettingsIniIBLeft, str$(IBLeft), ADDR SettingsIniPathAbs
	invoke WritePrivateProfileStringA, ADDR SettingsIniControls, \
	ADDR SettingsIniIBRight, str$(IBRight), ADDR SettingsIniPathAbs
	invoke WritePrivateProfileStringA, ADDR SettingsIniControls, \
	ADDR SettingsIniIBLookUp, str$(IBLookUp), ADDR SettingsIniPathAbs
	invoke WritePrivateProfileStringA, ADDR SettingsIniControls, \
	ADDR SettingsIniIBLookDown, str$(IBLookDown), ADDR SettingsIniPathAbs
	invoke WritePrivateProfileStringA, ADDR SettingsIniControls, \
	ADDR SettingsIniIBLookLeft, str$(IBLookLeft), ADDR SettingsIniPathAbs
	invoke WritePrivateProfileStringA, ADDR SettingsIniControls, \
	ADDR SettingsIniIBLookRight, str$(IBLookRight), ADDR SettingsIniPathAbs
	invoke WritePrivateProfileStringA, ADDR SettingsIniControls, \
	ADDR SettingsIniIBCrouch, str$(IBCrouch), ADDR SettingsIniPathAbs
	invoke WritePrivateProfileStringA, ADDR SettingsIniControls, \
	ADDR SettingsIniIBGlyph, str$(IBGlyph), ADDR SettingsIniPathAbs
	invoke WritePrivateProfileStringA, ADDR SettingsIniControls, \
	ADDR SettingsIniIBAction, str$(IBAction), ADDR SettingsIniPathAbs
	invoke WritePrivateProfileStringA, ADDR SettingsIniControls, \
	ADDR SettingsIniIBConfirm, str$(IBConfirm), ADDR SettingsIniPathAbs
	
	; Joystick
	invoke WritePrivateProfileStringA, ADDR SettingsIniControls, \
	ADDR SettingsIniJBUp, str$(JBUp), ADDR SettingsIniPathAbs
	invoke WritePrivateProfileStringA, ADDR SettingsIniControls, \
	ADDR SettingsIniJBDown, str$(JBDown), ADDR SettingsIniPathAbs
	invoke WritePrivateProfileStringA, ADDR SettingsIniControls, \
	ADDR SettingsIniJBLeft, str$(JBLeft), ADDR SettingsIniPathAbs
	invoke WritePrivateProfileStringA, ADDR SettingsIniControls, \
	ADDR SettingsIniJBRight, str$(JBRight), ADDR SettingsIniPathAbs
	invoke WritePrivateProfileStringA, ADDR SettingsIniControls, \
	ADDR SettingsIniJBLookUp, str$(JBLookUp), ADDR SettingsIniPathAbs
	invoke WritePrivateProfileStringA, ADDR SettingsIniControls, \
	ADDR SettingsIniJBLookDown, str$(JBLookDown), ADDR SettingsIniPathAbs
	invoke WritePrivateProfileStringA, ADDR SettingsIniControls, \
	ADDR SettingsIniJBLookLeft, str$(JBLookLeft), ADDR SettingsIniPathAbs
	invoke WritePrivateProfileStringA, ADDR SettingsIniControls, \
	ADDR SettingsIniJBLookRight, str$(JBLookRight), ADDR SettingsIniPathAbs
	invoke WritePrivateProfileStringA, ADDR SettingsIniControls, \
	ADDR SettingsIniJBCrouch, str$(JBCrouch), ADDR SettingsIniPathAbs
	invoke WritePrivateProfileStringA, ADDR SettingsIniControls, \
	ADDR SettingsIniJBGlyph, str$(JBGlyph), ADDR SettingsIniPathAbs
	invoke WritePrivateProfileStringA, ADDR SettingsIniControls, \
	ADDR SettingsIniJBAction, str$(JBAction), ADDR SettingsIniPathAbs
	invoke WritePrivateProfileStringA, ADDR SettingsIniControls, \
	ADDR SettingsIniJBConfirm, str$(JBConfirm), ADDR SettingsIniPathAbs
	
	ret
Settings_SaveBindings ENDP

Settings_SetMSAA PROC
	;   Haven't found a way to set it in the middle of the game without 
	; recreating the form, reloading the assets etc.
	ret
Settings_SetMSAA ENDP

Settings_SetOption PROC EXPORT OptionPtr:BPPtr	
	mov SettingsChanged, TRUE
	print "Setting option: "
	.IF (OptionPtr == OFFSET SettingsAudioVolume)
		print "audio/volume", 13, 10
		.IF (AudioDevice)
			invoke alListenerf, AL_GAIN, SettingsAudioVolume
		.ENDIF
		
	.ELSEIF (OptionPtr == OFFSET SettingsControlsJoystick)
		print "controls/joystick", 13, 10
		.IF (FMain.Handle)
			mov al, FMain.InputFlags
			.IF (SettingsControlsJoystick)
				or al, JOYSTICK_RAW
			.ELSE
				and al, not JOYSTICK_RAW
			.ENDIF
			invoke bpSetInputFlags, OFFSET FMain, al
		.ENDIF
	.ELSEIF (OptionPtr == OFFSET SettingsControlsRawMouse)
		print "controls/raw mouse", 13, 10
		.IF (FMain.Handle)
			mov al, FMain.InputFlags
			.IF (SettingsControlsRawMouse)
				or al, MOUSE_RAW
			.ELSE
				and al, not MOUSE_RAW
			.ENDIF
			invoke bpSetInputFlags, OFFSET FMain, al
		.ENDIF
		
	.ELSEIF (OptionPtr == OFFSET SettingsGraphicsAfterimage)
		print "graphics/afterimage", 13, 10
		.IF (FMain.Handle)
			invoke FX_SetAfterimage, FX_AFTERIMAGE_AMOUNT
		.ENDIF
	.ELSEIF (OptionPtr == OFFSET SettingsGraphicsDisplay)
		print "graphics/display", 13, 10
		.IF (FMain.Handle)
			invoke bpSetDisplayDevice, ADDR FMain, SettingsGraphicsDisplay
		.ENDIF
	.ELSEIF (OptionPtr == OFFSET SettingsGraphicsMSAA)
		print "graphics/msaa", 13, 10
		call Settings_SetMSAA
	.ELSEIF (OptionPtr == OFFSET SettingsGraphicsPixelization)
		print "graphics/pixelization", 13, 10
		.IF (FMain.Handle)
			call FX_Resize
		.ENDIF
	.ELSEIF (OptionPtr == OFFSET SettingsGraphicsResolution)
		print "graphics/resolution", 13, 10
		.IF (FMain.Handle)
			mov eax, SettingsGraphicsResolution[4]
			shl eax, 2
			or eax, SettingsGraphicsResolution[0]
			.IF (FMain.WindowMode != BP_WINDOW_MODE_FULLSCREEN)
				invoke bpSetScreenSize, ADDR FMain, \
				SettingsGraphicsResolution[0], SettingsGraphicsResolution[4]
			.ELSE
				invoke Vector2Copy, ADDR FMain.WindowSize, \
				ADDR SettingsGraphicsResolution
				invoke bpScreenToWindowSize, ADDR FMain, \
				ADDR FMain.WindowSize
			.ENDIF
		.ENDIF
	.ELSEIF (OptionPtr == OFFSET SettingsGraphicsVSync)
		print "graphics/vsync", 13, 10
		.IF (wglSwapIntervalEXT) && (FMain.GraphicsContext)
			.IF (SettingsGraphicsVSync)
				push -1	; -1 for adaptive, should test
			.ELSE
				push 0
			.ENDIF
			call wglSwapIntervalEXT
		.ENDIF
	.ELSEIF (OptionPtr == OFFSET SettingsGraphicsWindowMode)
		print "graphics/window mode", 13, 10
		.IF (FMain.Handle)
			invoke bpSetWindowMode, ADDR FMain, SettingsGraphicsWindowMode
		.ENDIF
		
	.ELSEIF (OptionPtr == OFFSET SettingsMiscLanguage)
		print "misc/language", 13, 10
		invoke RtlMoveMemory, \
		OFFSET SettingsMiscLanguage + LANGOFFSET,
		OFFSET SettingsMiscLanguage,SIZEOF SettingsMiscLanguage - LANGOFFSET
		invoke RtlMoveMemory, OFFSET SettingsMiscLanguage,
		OFFSET SettingsLangPath, LANGOFFSET
		print OFFSET SettingsMiscLanguage, 13, 10
		.IF (FMain.Handle)
			call FreeStrings
			invoke LoadStrings, OFFSET SettingsMiscLanguage
			invoke glDeleteTextures, 255, OFFSET bpDefaultFont
			invoke bpLoadFont, StrLangFontPath, OFFSET bpDefaultFont
		.ENDIF
	.ENDIF
	ret
Settings_SetOption ENDP
