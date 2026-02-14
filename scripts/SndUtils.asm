.DATA
IFDEF AUDIO_OPENAL
AudioDevice		ALCdevice 0		; OpenAL audio device
AudioContext	ALCcontext 0	; OpenAL audio context
ENDIF

.CODE

SndPlaying PROTO :DWORD

; FreeAudio frees loaded audio data from memory
FreeAudio PROC EXPORT AudioSource:BPPtr
	LOCAL bufSID:ALint
	
	mov pcx, AudioSource
	IFDEF AUDIO_OPENAL
	invoke alGetSourcei, ALuint PTR [pcx], AL_BUFFER, ADDR bufSID
	invoke alDeleteSources, 1, AudioSource
	invoke alDeleteBuffers, 1, ADDR bufSID
	ENDIF
	ret
FreeAudio ENDP

FreeAudioSystem PROC EXPORT
	IFDEF AUDIO_OPENAL
	invoke alcMakeContextCurrent, 0
	invoke alcDestroyContext, ADDR AudioContext
	invoke alcCloseDevice, ADDR AudioDevice
	ENDIF
	ret
FreeAudioSystem ENDP

; InitAudio opens a device and creates a context
InitAudioSystem PROC EXPORT
	IFDEF AUDIO_OPENAL
	mov AudioDevice, rv(alcOpenDevice, NULL)
	mov AudioContext, rv(alcCreateContext, AudioDevice, NULL)
	invoke alcMakeContextCurrent, AudioContext
	ENDIF
	ret
InitAudioSystem ENDP

; LoadAudio loads an OGG Vorbis audio at FilePath into AudioPTR
LoadAudio PROC EXPORT AudioPtr:BPPtr, FilePath:BPPtr
	LOCAL channels:DWORD, sample:DWORD, decoded:BPPtr, fileLen:DWORD
	LOCAL buffer:DWORD, format:SDWORD, bufferSize:DWORD
	
	invoke stb_vorbis_decode_filename, FilePath, ADDR channels, ADDR sample, \
	ADDR decoded
	mov fileLen, eax
	shl eax, 1
	mov ecx, channels
	mul ecx
	mov bufferSize, eax
	
	
	IFDEF BP_IMPORTERS_VERBOSE
		pushad
		print FilePath, 9
		popad
		pushad
		print str$(eax), 9
		popad
		print "file size:", 32
		print str$(fileLen), 13, 10
	ENDIF
	
	IFDEF AUDIO_OPENAL
	invoke alGenBuffers, 1, ADDR buffer
	.IF channels == 2
		mov format, AL_FORMAT_STEREO16
	.ELSE
		mov format, AL_FORMAT_MONO16
	.ENDIF
	invoke alBufferData, buffer, format, decoded, bufferSize, sample
	invoke alGenSources, 1, AudioPtr
	mov eax, AudioPtr
	invoke alSourcei, ALuint PTR [eax], AL_BUFFER, buffer
	ENDIF
	ret
LoadAudio ENDP

LoadBPS MACRO SoundPtr:REQ, FilePath:REQ
	invoke LoadAudio, SoundPtr, s(FilePath)
ENDM

PauseSounds PROC EXPORT Paused:BPBool
	lea pbx, SndSectionStart
	inc pbx
	.WHILE (pbx < OFFSET SndSectionEnd)
		invoke SndPlaying, DWORD PTR [pbx]
		.IF (Paused)
			.IF (eax == AL_PLAYING)
				invoke alSourcePause, DWORD PTR [pbx]
			.ELSEIF (eax == AL_PAUSED)
				invoke alSourceStop, DWORD PTR [pbx]
			.ENDIF
		.ELSEIF !(Paused) && (eax == AL_PAUSED)
			invoke alSourcePlay, DWORD PTR [pbx]
		.ENDIF
		add pbx, 4
	.ENDW
	ret
PauseSounds ENDP

PlayRandomSnd PROC EXPORT SndPtr:BPPtr, Count:BPPtr
	invoke nRand, Count
	mov pcx, SndPtr
	push DWORD PTR [pcx+pax*4]
	invoke alSourcePlay, DWORD PTR [pcx+pax*4]
	pop eax
	ret
PlayRandomSnd ENDP

MulSoundPitch PROC EXPORT Factor:REAL4
	LOCAL pitch:REAL4
	; Persistent
	lea pbx, SndSectionStart
	inc pbx
	.WHILE (pbx < OFFSET SndSectionEnd)
		invoke alGetSourcef, DWORD PTR [pbx], AL_PITCH, ADDR pitch
		fld pitch
		fmul Factor
		fstp pitch
		invoke alSourcef, DWORD PTR [pbx], AL_PITCH, pitch
		add pbx, 4
	.ENDW
	ret
MulSoundPitch ENDP

SndFade PROC EXPORT ALSound:DWORD, TargetGain:REAL4, T:REAL4
	LOCAL gainVal:REAL4
	
	.IF (rv(SndPlaying, ALSound) == AL_PLAYING)
		invoke alGetSourcef, ALSound, AL_GAIN, ADDR gainVal
		mov gainVal, rv(flLerp, gainVal, TargetGain, T)
		invoke alSourcef, ALSound, AL_GAIN, gainVal
		
		.IF (TargetGain == 0)
			fcmp gainVal, f(0.01)
			.IF (Carry?)
				invoke alSourceStop, ALSound
			.ENDIF
		.ENDIF
	.ENDIF
	ret
SndFade ENDP

SndPlaying PROC EXPORT ALSound:DWORD
	LOCAL playVal:DWORD
	
	invoke alGetSourcei, ALSound, AL_SOURCE_STATE, ADDR playVal
	mov eax, playVal
	ret
SndPlaying ENDP

SndSetPos PROC EXPORT ALSound:DWORD, PosPtr:BPPtr
	mov pax, PosPtr
	mov ecx, CamPosL.Y	; vinvoke messes something up in UASM
	invoke alSource3f, ALSound, AL_POSITION, REAL4 PTR [pax], ecx, \
	REAL4 PTR [pax+8]
	ret
SndSetPos ENDP
