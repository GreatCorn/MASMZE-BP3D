.CONST
SettingsIniAudio			DB "Audio", 0
SettingsIniVolume			DB "Volume", 0

SettingsIniControls			DB "Controls", 0
SettingsIniJoystick			DB "Joystick", 0
SettingsIniJoystickSpeed	DB "JoystickSpeed", 0
SettingsIniMouseSensitivity	DB "MouseSensitivity", 0
SettingsIniRawMouse			DB "RawMouse", 0

SettingsIniGraphics			DB "Graphics", 0
SettingsIniAfterimage		DB "Afterimage", 0
SettingsIniDisplay			DB "Display", 0
SettingsIniGamma			DB "Gamma", 0
SettingsIniMSAA				DB "MSAA", 0
SettingsIniParticles		DB "Particles", 0
SettingsIniPixelization		DB "Pixelization", 0
SettingsIniPosterization	DB "Posterization", 0
SettingsIniResolutionWidth	DB "Width", 0
SettingsIniResolutionHeight	DB "Height", 0
SettingsIniVSync			DB "VSync", 0
SettingsIniWindowMode		DB "WindowMode", 0

SettingsIni2f		DB "2.0", 0
SettingsIni1f		DB "1.0", 0
SettingsIni0n5f		DB "0.5", 0
SettingsIniFalse	DB "false", 0
SettingsIniTrue		DB "true", 0

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
SettingsGraphicsMSAA			DWORD 0
SettingsGraphicsParticles		BPBool TRUE
SettingsGraphicsPixelization	BPBool TRUE
SettingsGraphicsPosterization	BPBool FALSE
SettingsGraphicsResolution		DWORD 854, 480
SettingsGraphicsVSync			BPBool TRUE
SettingsGraphicsWindowMode		BPEnum BP_WINDOW_MODE_WINDOWED
SettingsMiscMultithreading		BPBool TRUE

SettingsChanged		BPBool FALSE
SettingsIniDouble	REAL8 0.0
SettingsIniPathAbs	DB 256 DUP(0)
SettingsIniString	DB 16 DUP(0)

.DATA?
SettingsRegistry HKEY ?	; Default registry key

.CODE
Settings_SetOption PROTO :BPPtr

Settings_IsTrue PROC
	.IF (SettingsIniString[0] == 116) || (SettingsIniString[0] == 84) ; t or T
		mov pax, TRUE
	.ELSE
		xor pax, pax
	.ENDIF
	ret
Settings_IsTrue ENDP

Settings_Load PROC
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
	invoke StrToFloat, ADDR SettingsIniString, ADDR SettingsIniDouble
	fld SettingsIniDouble
	fstp SettingsAudioVolume
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
	invoke StrToFloat, ADDR SettingsIniString, ADDR SettingsIniDouble
	fld SettingsIniDouble
	fstp SettingsControlsJoystickSpeed
	
	; Mouse sensitivity
	invoke GetPrivateProfileString, ADDR SettingsIniControls, \
	ADDR SettingsIniMouseSensitivity, ADDR SettingsIni0n5f, \
	ADDR SettingsIniString, 9, ADDR SettingsIniPathAbs
	invoke StrToFloat, ADDR SettingsIniString, ADDR SettingsIniDouble
	fld SettingsIniDouble
	fstp SettingsControlsMouseSensitivity
	
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
	; Afterimage (HIDDEN)
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
	invoke StrToFloat, ADDR SettingsIniString, ADDR SettingsIniDouble
	fld SettingsIniDouble
	fstp SettingsGraphicsGamma
	
	; MSAA
	invoke GetPrivateProfileInt, ADDR SettingsIniGraphics, \
	ADDR SettingsIniMSAA, 0, ADDR SettingsIniPathAbs
	.IF (eax != SettingsGraphicsMSAA)
		mov SettingsGraphicsMSAA, eax
		invoke Settings_SetOption, OFFSET SettingsGraphicsMSAA
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
	ADDR SettingsIniPosterization,ADDR SettingsIniFalse,ADDR SettingsIniString,\
	9, ADDR SettingsIniPathAbs
	call Settings_IsTrue
	.IF (al != SettingsGraphicsPosterization)
		mov SettingsGraphicsPosterization, al
	.ENDIF
	
	; Resolution
	invoke GetPrivateProfileInt, ADDR SettingsIniGraphics, \
	ADDR SettingsIniResolutionWidth, 854, ADDR SettingsIniPathAbs
	push pax
	invoke GetPrivateProfileInt, ADDR SettingsIniGraphics, \
	ADDR SettingsIniResolutionHeight, 480, ADDR SettingsIniPathAbs
	pop pcx
	.IF (SettingsGraphicsResolution[0] != ecx) || \
	(SettingsGraphicsResolution[4] != eax)
		mov SettingsGraphicsResolution[0], ecx
		mov SettingsGraphicsResolution[4], eax
		invoke Settings_SetOption, OFFSET SettingsGraphicsResolution
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
	
	mov SettingsChanged, FALSE
	ret
Settings_Load ENDP

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
	NULL, ADDR MazeLevel, ADDR pcbData
	.IF (eax == ERROR_SUCCESS)	; Load temporary progress
	
	.ELSE
		invoke RegQueryValueExA, SettingsRegistry, ADDR SettingsRegLayer, 0, \
		NULL, ADDR MazeLevel, ADDR pcbData
		.IF (eax != ERROR_SUCCESS)
			print "Failed to read layer value (DWORD).", 13, 10
			print str$(MazeLevel), 13, 10
			xor pax, pax
			ret
		.ENDIF
	.ENDIF
	invoke RegCloseKey, SettingsRegistry
	mov pax, TRUE
	ret
Settings_LoadGame ENDP

Settings_Save PROC IniSection:BPPtr	
	mov SettingsChanged, FALSE
	print "Saving settings to section "
	print IniSection
	print " in "
	print ADDR SettingsIniPathAbs, 13, 10
	SWITCH IniSection
		CASE OFFSET SettingsIniAudio
			; Volume
			invoke WritePrivateProfileStringA, ADDR SettingsIniAudio, \
			ADDR SettingsIniVolume, real4$(SettingsAudioVolume), \
			ADDR SettingsIniPathAbs
			
		CASE OFFSET SettingsIniGraphics
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
			
			; MSAA
			invoke WritePrivateProfileStringA, ADDR SettingsIniGraphics, \
			ADDR SettingsIniMSAA, str$(SettingsGraphicsMSAA), \
			ADDR SettingsIniPathAbs
			
			; Gamma
			invoke WritePrivateProfileStringA, ADDR SettingsIniGraphics, \
			ADDR SettingsIniGamma, real4$(SettingsGraphicsGamma), \
			ADDR SettingsIniPathAbs
			
			; Particles
			.IF (SettingsGraphicsParticles)
				lea pax, SettingsIniTrue
			.ELSE
				lea pax, SettingsIniFalse
			.ENDIF
			invoke WritePrivateProfileStringA, ADDR SettingsIniGraphics, \
			ADDR SettingsIniParticles, pax, ADDR SettingsIniPathAbs
	ENDSW
	ret
Settings_Save ENDP

Settings_SetMSAA PROC
	;   Haven't found a way to set it in the middle of the game without 
	; recreating the form, reloading the assets etc.
	ret
Settings_SetMSAA ENDP

Settings_SetOption PROC OptionPtr:BPPtr	
	mov SettingsChanged, TRUE
	print "Setting option: "
	SWITCH OptionPtr
		CASE OFFSET SettingsAudioVolume
			print "audio/volume", 13, 10
			.IF (AudioDevice)
				invoke alListenerf, AL_GAIN, SettingsAudioVolume
			.ENDIF
		CASE OFFSET SettingsControlsJoystick
			print "controls/joystick", 13, 10
			.IF (FMain.Handle)
				and FMain.InputFlags, not BP_IF_JOYSTICK
				invoke bpSetInputFlags, ADDR FMain, FMain.InputFlags
			.ENDIF
		CASE OFFSET SettingsControlsRawMouse
			print "controls/raw mouse", 13, 10
			.IF (FMain.Handle)
				and FMain.InputFlags, not BP_IF_RAW_MOUSE
				invoke bpSetInputFlags, ADDR FMain, FMain.InputFlags
			.ENDIF
		
		CASE OFFSET SettingsGraphicsDisplay
			print "graphics/display", 13, 10
			.IF (FMain.Handle)
				invoke bpSetDisplayDevice, ADDR FMain, SettingsGraphicsDisplay
			.ENDIF
		CASE OFFSET SettingsGraphicsMSAA
			print "graphics/msaa", 13, 10
			call Settings_SetMSAA
		CASE OFFSET SettingsGraphicsResolution
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
		CASE OFFSET SettingsGraphicsVSync
			print "graphics/vsync", 13, 10
			.IF (wglSwapIntervalEXT) && (FMain.GraphicsContext)
				.IF (SettingsGraphicsVSync)
					push -1	; -1 for adaptive, should test
				.ELSE
					push 0
				.ENDIF
				call wglSwapIntervalEXT
			.ENDIF
		CASE OFFSET SettingsGraphicsWindowMode
			print "graphics/window mode", 13, 10
			.IF (FMain.Handle)
				invoke bpSetWindowMode, ADDR FMain, SettingsGraphicsWindowMode
			.ENDIF
	ENDSW
	ret
Settings_SetOption ENDP