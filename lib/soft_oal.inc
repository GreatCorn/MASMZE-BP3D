;--- include file created by h2incx v0.99.20 (copyright 2005-2009 japheth)
;--- source file: D:\Miscellaneous\openal-soft-1.7.411\include\AL\al.h, last modified: 2/9/2008 4:31
;--- cmdline used for creation:  -k c al.h

OPENAL	EQU	<>
ALAPI	EQU	<AL_API>
ALAPIENTRY	EQU	<AL_APIENTRY>
AL_INVALID	EQU	- 1
AL_ILLEGAL_ENUM	EQU	<AL_INVALID_ENUM>
AL_ILLEGAL_COMMAND	EQU	<AL_INVALID_OPERATION>
AL_VERSION_1_0	EQU	<>
AL_VERSION_1_1	EQU	<>
ALboolean typedef SBYTE
ALchar typedef SBYTE
ALbyte typedef SBYTE
ALubyte typedef BYTE
ALshort typedef SWORD
ALushort typedef WORD
ALint typedef DWORD
ALuint typedef DWORD
ALsizei typedef DWORD
ALenum typedef DWORD
ALfloat typedef REAL4
ALdouble typedef REAL8
ALvoid typedef 
AL_NONE	EQU	0
AL_FALSE	EQU	0
AL_TRUE	EQU	1
AL_SOURCE_RELATIVE	EQU	202h
AL_CONE_INNER_ANGLE	EQU	1001h
AL_CONE_OUTER_ANGLE	EQU	1002h
AL_PITCH	EQU	1003h
AL_POSITION	EQU	1004h
AL_DIRECTION	EQU	1005h
AL_VELOCITY	EQU	1006h
AL_LOOPING	EQU	1007h
AL_BUFFER	EQU	1009h
AL_GAIN	EQU	100Ah
AL_MIN_GAIN	EQU	100Dh
AL_MAX_GAIN	EQU	100Eh
AL_ORIENTATION	EQU	100Fh
AL_SOURCE_STATE	EQU	1010h
AL_INITIAL	EQU	1011h
AL_PLAYING	EQU	1012h
AL_PAUSED	EQU	1013h
AL_STOPPED	EQU	1014h
AL_BUFFERS_QUEUED	EQU	1015h
AL_BUFFERS_PROCESSED	EQU	1016h
AL_SEC_OFFSET	EQU	1024h
AL_SAMPLE_OFFSET	EQU	1025h
AL_BYTE_OFFSET	EQU	1026h
AL_SOURCE_TYPE	EQU	1027h
AL_STATIC	EQU	1028h
AL_STREAMING	EQU	1029h
AL_UNDETERMINED	EQU	1030h
AL_FORMAT_MONO8	EQU	1100h
AL_FORMAT_MONO16	EQU	1101h
AL_FORMAT_STEREO8	EQU	1102h
AL_FORMAT_STEREO16	EQU	1103h
AL_REFERENCE_DISTANCE	EQU	1020h
AL_ROLLOFF_FACTOR	EQU	1021h
AL_CONE_OUTER_GAIN	EQU	1022h
AL_MAX_DISTANCE	EQU	1023h
AL_FREQUENCY	EQU	2001h
AL_BITS	EQU	2002h
AL_CHANNELS	EQU	2003h
AL_SIZE	EQU	2004h
AL_UNUSED	EQU	2010h
AL_PENDING	EQU	2011h
AL_PROCESSED	EQU	2012h
AL_NO_ERROR	EQU	<AL_FALSE>
AL_INVALID_NAME	EQU	0A001h
AL_INVALID_ENUM	EQU	0A002h
AL_INVALID_VALUE	EQU	0A003h
AL_INVALID_OPERATION	EQU	0A004h
AL_OUT_OF_MEMORY	EQU	0A005h
AL_VENDOR	EQU	0B001h
AL_VERSION	EQU	0B002h
AL_RENDERER	EQU	0B003h
AL_EXTENSIONS	EQU	0B004h
AL_DOPPLER_FACTOR	EQU	0C000h
AL_DOPPLER_VELOCITY	EQU	0C001h
AL_SPEED_OF_SOUND	EQU	0C003h
AL_DISTANCE_MODEL	EQU	0D000h
AL_INVERSE_DISTANCE	EQU	0D001h
AL_INVERSE_DISTANCE_CLAMPED	EQU	0D002h
AL_LINEAR_DISTANCE	EQU	0D003h
AL_LINEAR_DISTANCE_CLAMPED	EQU	0D004h
AL_EXPONENT_DISTANCE	EQU	0D005h
AL_EXPONENT_DISTANCE_CLAMPED	EQU	0D006h
alEnable proto c :ALenum
alDisable proto c :ALenum
alIsEnabled proto c :ALenum
alGetString proto c :ALenum
alGetBooleanv proto c :ALenum, :ptr ALboolean
alGetIntegerv proto c :ALenum, :ptr ALint
alGetFloatv proto c :ALenum, :ptr ALfloat
alGetDoublev proto c :ALenum, :ptr ALdouble
alGetBoolean proto c :ALenum
alGetInteger proto c :ALenum
alGetFloat proto c :ALenum
alGetDouble proto c :ALenum
alGetError proto c 
alIsExtensionPresent proto c :ptr ALchar
alGetProcAddress proto c :ptr ALchar
alGetEnumValue proto c :ptr ALchar
alListenerf proto c :ALenum, :ALfloat
alListener3f proto c :ALenum, :ALfloat, :ALfloat, :ALfloat
alListenerfv proto c :ALenum, :ptr ALfloat
alListeneri proto c :ALenum, :ALint
alListener3i proto c :ALenum, :ALint, :ALint, :ALint
alListeneriv proto c :ALenum, :ptr ALint
alGetListenerf proto c :ALenum, :ptr ALfloat
alGetListener3f proto c :ALenum, :ptr ALfloat, :ptr ALfloat, :ptr ALfloat
alGetListenerfv proto c :ALenum, :ptr ALfloat
alGetListeneri proto c :ALenum, :ptr ALint
alGetListener3i proto c :ALenum, :ptr ALint, :ptr ALint, :ptr ALint
alGetListeneriv proto c :ALenum, :ptr ALint
alGenSources proto c :ALsizei, :ptr ALuint
alDeleteSources proto c :ALsizei, :ptr ALuint
alIsSource proto c :ALuint
alSourcef proto c :ALuint, :ALenum, :ALfloat
alSource3f proto c :ALuint, :ALenum, :ALfloat, :ALfloat, :ALfloat
alSourcefv proto c :ALuint, :ALenum, :ptr ALfloat
alSourcei proto c :ALuint, :ALenum, :ALint
alSource3i proto c :ALuint, :ALenum, :ALint, :ALint, :ALint
alSourceiv proto c :ALuint, :ALenum, :ptr ALint
alGetSourcef proto c :ALuint, :ALenum, :ptr ALfloat
alGetSource3f proto c :ALuint, :ALenum, :ptr ALfloat, :ptr ALfloat, :ptr ALfloat
alGetSourcefv proto c :ALuint, :ALenum, :ptr ALfloat
alGetSourcei proto c :ALuint, :ALenum, :ptr ALint
alGetSource3i proto c :ALuint, :ALenum, :ptr ALint, :ptr ALint, :ptr ALint
alGetSourceiv proto c :ALuint, :ALenum, :ptr ALint
alSourcePlayv proto c :ALsizei, :ptr ALuint
alSourceStopv proto c :ALsizei, :ptr ALuint
alSourceRewindv proto c :ALsizei, :ptr ALuint
alSourcePausev proto c :ALsizei, :ptr ALuint
alSourcePlay proto c :ALuint
alSourceStop proto c :ALuint
alSourceRewind proto c :ALuint
alSourcePause proto c :ALuint
alSourceQueueBuffers proto c :ALuint, :ALsizei, :ptr ALuint
alSourceUnqueueBuffers proto c :ALuint, :ALsizei, :ptr ALuint
alGenBuffers proto c :ALsizei, :ptr ALuint
alDeleteBuffers proto c :ALsizei, :ptr ALuint
alIsBuffer proto c :ALuint
alBufferData proto c :ALuint, :ALenum, :ptr ALvoid, :ALsizei, :ALsizei
alBufferf proto c :ALuint, :ALenum, :ALfloat
alBuffer3f proto c :ALuint, :ALenum, :ALfloat, :ALfloat, :ALfloat
alBufferfv proto c :ALuint, :ALenum, :ptr ALfloat
alBufferi proto c :ALuint, :ALenum, :ALint
alBuffer3i proto c :ALuint, :ALenum, :ALint, :ALint, :ALint
alBufferiv proto c :ALuint, :ALenum, :ptr ALint
alGetBufferf proto c :ALuint, :ALenum, :ptr ALfloat
alGetBuffer3f proto c :ALuint, :ALenum, :ptr ALfloat, :ptr ALfloat, :ptr ALfloat
alGetBufferfv proto c :ALuint, :ALenum, :ptr ALfloat
alGetBufferi proto c :ALuint, :ALenum, :ptr ALint
alGetBuffer3i proto c :ALuint, :ALenum, :ptr ALint, :ptr ALint, :ptr ALint
alGetBufferiv proto c :ALuint, :ALenum, :ptr ALint
alDopplerFactor proto c :ALfloat
alDopplerVelocity proto c :ALfloat
alSpeedOfSound proto c :ALfloat
alDistanceModel proto c :ALenum
proto_LPALENABLE typedef proto c :ALenum
LPALENABLE typedef ptr proto_LPALENABLE
proto_LPALDISABLE typedef proto c :ALenum
LPALDISABLE typedef ptr proto_LPALDISABLE
proto_LPALISENABLED typedef proto c :ALenum
LPALISENABLED typedef ptr proto_LPALISENABLED
proto_LPALGETSTRING typedef proto c :ALenum
LPALGETSTRING typedef ptr proto_LPALGETSTRING
proto_LPALGETBOOLEANV typedef proto c :ALenum,:ptr ALboolean
LPALGETBOOLEANV typedef ptr proto_LPALGETBOOLEANV
proto_LPALGETINTEGERV typedef proto c :ALenum,:ptr ALint
LPALGETINTEGERV typedef ptr proto_LPALGETINTEGERV
proto_LPALGETFLOATV typedef proto c :ALenum,:ptr ALfloat
LPALGETFLOATV typedef ptr proto_LPALGETFLOATV
proto_LPALGETDOUBLEV typedef proto c :ALenum,:ptr ALdouble
LPALGETDOUBLEV typedef ptr proto_LPALGETDOUBLEV
proto_LPALGETBOOLEAN typedef proto c :ALenum
LPALGETBOOLEAN typedef ptr proto_LPALGETBOOLEAN
proto_LPALGETINTEGER typedef proto c :ALenum
LPALGETINTEGER typedef ptr proto_LPALGETINTEGER
proto_LPALGETFLOAT typedef proto c :ALenum
LPALGETFLOAT typedef ptr proto_LPALGETFLOAT
proto_LPALGETDOUBLE typedef proto c :ALenum
LPALGETDOUBLE typedef ptr proto_LPALGETDOUBLE
proto_LPALGETERROR typedef proto c 
LPALGETERROR typedef ptr proto_LPALGETERROR
proto_LPALISEXTENSIONPRESENT typedef proto c :ptr ALchar
LPALISEXTENSIONPRESENT typedef ptr proto_LPALISEXTENSIONPRESENT
proto_LPALGETPROCADDRESS typedef proto c :ptr ALchar
LPALGETPROCADDRESS typedef ptr proto_LPALGETPROCADDRESS
proto_LPALGETENUMVALUE typedef proto c :ptr ALchar
LPALGETENUMVALUE typedef ptr proto_LPALGETENUMVALUE
proto_LPALLISTENERF typedef proto c :ALenum,:ALfloat
LPALLISTENERF typedef ptr proto_LPALLISTENERF
proto_LPALLISTENER3F typedef proto c :ALenum,:ALfloat,:ALfloat,:ALfloat
LPALLISTENER3F typedef ptr proto_LPALLISTENER3F
proto_LPALLISTENERFV typedef proto c :ALenum,:ptr ALfloat
LPALLISTENERFV typedef ptr proto_LPALLISTENERFV
proto_LPALLISTENERI typedef proto c :ALenum,:ALint
LPALLISTENERI typedef ptr proto_LPALLISTENERI
proto_LPALLISTENER3I typedef proto c :ALenum,:ALint,:ALint,:ALint
LPALLISTENER3I typedef ptr proto_LPALLISTENER3I
proto_LPALLISTENERIV typedef proto c :ALenum,:ptr ALint
LPALLISTENERIV typedef ptr proto_LPALLISTENERIV
proto_LPALGETLISTENERF typedef proto c :ALenum,:ptr ALfloat
LPALGETLISTENERF typedef ptr proto_LPALGETLISTENERF
proto_LPALGETLISTENER3F typedef proto c :ALenum,:ptr ALfloat,:ptr ALfloat,:ptr ALfloat
LPALGETLISTENER3F typedef ptr proto_LPALGETLISTENER3F
proto_LPALGETLISTENERFV typedef proto c :ALenum,:ptr ALfloat
LPALGETLISTENERFV typedef ptr proto_LPALGETLISTENERFV
proto_LPALGETLISTENERI typedef proto c :ALenum,:ptr ALint
LPALGETLISTENERI typedef ptr proto_LPALGETLISTENERI
proto_LPALGETLISTENER3I typedef proto c :ALenum,:ptr ALint,:ptr ALint,:ptr ALint
LPALGETLISTENER3I typedef ptr proto_LPALGETLISTENER3I
proto_LPALGETLISTENERIV typedef proto c :ALenum,:ptr ALint
LPALGETLISTENERIV typedef ptr proto_LPALGETLISTENERIV
proto_LPALGENSOURCES typedef proto c :ALsizei,:ptr ALuint
LPALGENSOURCES typedef ptr proto_LPALGENSOURCES
proto_LPALDELETESOURCES typedef proto c :ALsizei,:ptr ALuint
LPALDELETESOURCES typedef ptr proto_LPALDELETESOURCES
proto_LPALISSOURCE typedef proto c :ALuint
LPALISSOURCE typedef ptr proto_LPALISSOURCE
proto_LPALSOURCEF typedef proto c :ALuint,:ALenum,:ALfloat
LPALSOURCEF typedef ptr proto_LPALSOURCEF
proto_LPALSOURCE3F typedef proto c :ALuint,:ALenum,:ALfloat,:ALfloat,:ALfloat
LPALSOURCE3F typedef ptr proto_LPALSOURCE3F
proto_LPALSOURCEFV typedef proto c :ALuint,:ALenum,:ptr ALfloat
LPALSOURCEFV typedef ptr proto_LPALSOURCEFV
proto_LPALSOURCEI typedef proto c :ALuint,:ALenum,:ALint
LPALSOURCEI typedef ptr proto_LPALSOURCEI
proto_LPALSOURCE3I typedef proto c :ALuint,:ALenum,:ALint,:ALint,:ALint
LPALSOURCE3I typedef ptr proto_LPALSOURCE3I
proto_LPALSOURCEIV typedef proto c :ALuint,:ALenum,:ptr ALint
LPALSOURCEIV typedef ptr proto_LPALSOURCEIV
proto_LPALGETSOURCEF typedef proto c :ALuint,:ALenum,:ptr ALfloat
LPALGETSOURCEF typedef ptr proto_LPALGETSOURCEF
proto_LPALGETSOURCE3F typedef proto c :ALuint,:ALenum,:ptr ALfloat,:ptr ALfloat,:ptr ALfloat
LPALGETSOURCE3F typedef ptr proto_LPALGETSOURCE3F
proto_LPALGETSOURCEFV typedef proto c :ALuint,:ALenum,:ptr ALfloat
LPALGETSOURCEFV typedef ptr proto_LPALGETSOURCEFV
proto_LPALGETSOURCEI typedef proto c :ALuint,:ALenum,:ptr ALint
LPALGETSOURCEI typedef ptr proto_LPALGETSOURCEI
proto_LPALGETSOURCE3I typedef proto c :ALuint,:ALenum,:ptr ALint,:ptr ALint,:ptr ALint
LPALGETSOURCE3I typedef ptr proto_LPALGETSOURCE3I
proto_LPALGETSOURCEIV typedef proto c :ALuint,:ALenum,:ptr ALint
LPALGETSOURCEIV typedef ptr proto_LPALGETSOURCEIV
proto_LPALSOURCEPLAYV typedef proto c :ALsizei,:ptr ALuint
LPALSOURCEPLAYV typedef ptr proto_LPALSOURCEPLAYV
proto_LPALSOURCESTOPV typedef proto c :ALsizei,:ptr ALuint
LPALSOURCESTOPV typedef ptr proto_LPALSOURCESTOPV
proto_LPALSOURCEREWINDV typedef proto c :ALsizei,:ptr ALuint
LPALSOURCEREWINDV typedef ptr proto_LPALSOURCEREWINDV
proto_LPALSOURCEPAUSEV typedef proto c :ALsizei,:ptr ALuint
LPALSOURCEPAUSEV typedef ptr proto_LPALSOURCEPAUSEV
proto_LPALSOURCEPLAY typedef proto c :ALuint
LPALSOURCEPLAY typedef ptr proto_LPALSOURCEPLAY
proto_LPALSOURCESTOP typedef proto c :ALuint
LPALSOURCESTOP typedef ptr proto_LPALSOURCESTOP
proto_LPALSOURCEREWIND typedef proto c :ALuint
LPALSOURCEREWIND typedef ptr proto_LPALSOURCEREWIND
proto_LPALSOURCEPAUSE typedef proto c :ALuint
LPALSOURCEPAUSE typedef ptr proto_LPALSOURCEPAUSE
proto_LPALSOURCEQUEUEBUFFERS typedef proto c :ALuint,:ALsizei,:ptr ALuint
LPALSOURCEQUEUEBUFFERS typedef ptr proto_LPALSOURCEQUEUEBUFFERS
proto_LPALSOURCEUNQUEUEBUFFERS typedef proto c :ALuint,:ALsizei,:ptr ALuint
LPALSOURCEUNQUEUEBUFFERS typedef ptr proto_LPALSOURCEUNQUEUEBUFFERS
proto_LPALGENBUFFERS typedef proto c :ALsizei,:ptr ALuint
LPALGENBUFFERS typedef ptr proto_LPALGENBUFFERS
proto_LPALDELETEBUFFERS typedef proto c :ALsizei,:ptr ALuint
LPALDELETEBUFFERS typedef ptr proto_LPALDELETEBUFFERS
proto_LPALISBUFFER typedef proto c :ALuint
LPALISBUFFER typedef ptr proto_LPALISBUFFER
proto_LPALBUFFERDATA typedef proto c :ALuint,:ALenum,:ptr ALvoid,:ALsizei,:ALsizei
LPALBUFFERDATA typedef ptr proto_LPALBUFFERDATA
proto_LPALBUFFERF typedef proto c :ALuint,:ALenum,:ALfloat
LPALBUFFERF typedef ptr proto_LPALBUFFERF
proto_LPALBUFFER3F typedef proto c :ALuint,:ALenum,:ALfloat,:ALfloat,:ALfloat
LPALBUFFER3F typedef ptr proto_LPALBUFFER3F
proto_LPALBUFFERFV typedef proto c :ALuint,:ALenum,:ptr ALfloat
LPALBUFFERFV typedef ptr proto_LPALBUFFERFV
proto_LPALBUFFERI typedef proto c :ALuint,:ALenum,:ALint
LPALBUFFERI typedef ptr proto_LPALBUFFERI
proto_LPALBUFFER3I typedef proto c :ALuint,:ALenum,:ALint,:ALint,:ALint
LPALBUFFER3I typedef ptr proto_LPALBUFFER3I
proto_LPALBUFFERIV typedef proto c :ALuint,:ALenum,:ptr ALint
LPALBUFFERIV typedef ptr proto_LPALBUFFERIV
proto_LPALGETBUFFERF typedef proto c :ALuint,:ALenum,:ptr ALfloat
LPALGETBUFFERF typedef ptr proto_LPALGETBUFFERF
proto_LPALGETBUFFER3F typedef proto c :ALuint,:ALenum,:ptr ALfloat,:ptr ALfloat,:ptr ALfloat
LPALGETBUFFER3F typedef ptr proto_LPALGETBUFFER3F
proto_LPALGETBUFFERFV typedef proto c :ALuint,:ALenum,:ptr ALfloat
LPALGETBUFFERFV typedef ptr proto_LPALGETBUFFERFV
proto_LPALGETBUFFERI typedef proto c :ALuint,:ALenum,:ptr ALint
LPALGETBUFFERI typedef ptr proto_LPALGETBUFFERI
proto_LPALGETBUFFER3I typedef proto c :ALuint,:ALenum,:ptr ALint,:ptr ALint,:ptr ALint
LPALGETBUFFER3I typedef ptr proto_LPALGETBUFFER3I
proto_LPALGETBUFFERIV typedef proto c :ALuint,:ALenum,:ptr ALint
LPALGETBUFFERIV typedef ptr proto_LPALGETBUFFERIV
proto_LPALDOPPLERFACTOR typedef proto c :ALfloat
LPALDOPPLERFACTOR typedef ptr proto_LPALDOPPLERFACTOR
proto_LPALDOPPLERVELOCITY typedef proto c :ALfloat
LPALDOPPLERVELOCITY typedef ptr proto_LPALDOPPLERVELOCITY
proto_LPALSPEEDOFSOUND typedef proto c :ALfloat
LPALSPEEDOFSOUND typedef ptr proto_LPALSPEEDOFSOUND
proto_LPALDISTANCEMODEL typedef proto c :ALenum
LPALDISTANCEMODEL typedef ptr proto_LPALDISTANCEMODEL

;--- include file created by h2incx v0.99.20 (copyright 2005-2009 japheth)
;--- source file: D:\Miscellaneous\openal-soft-1.7.411\include\AL\alc.h, last modified: 7/22/2008 23:48
;--- cmdline used for creation:  -k c alc.h

ALCAPI	EQU	<ALC_API>
ALCAPIENTRY	EQU	<ALC_APIENTRY>
ALC_INVALID	EQU	0
ALC_VERSION_0_1	EQU	1
ALCdevice typedef ptr

ALCcontext typedef ptr

ALCboolean typedef SBYTE
ALCchar typedef SBYTE
ALCbyte typedef SBYTE
ALCubyte typedef BYTE
ALCshort typedef SWORD
ALCushort typedef WORD
ALCint typedef DWORD
ALCuint typedef DWORD
ALCsizei typedef DWORD
ALCenum typedef DWORD
ALCfloat typedef REAL4
ALCdouble typedef REAL8
ALCvoid typedef 
ALC_FALSE	EQU	0
ALC_TRUE	EQU	1
ALC_FREQUENCY	EQU	1007h
ALC_REFRESH	EQU	1008h
ALC_SYNC	EQU	1009h
ALC_MONO_SOURCES	EQU	1010h
ALC_STEREO_SOURCES	EQU	1011h
ALC_NO_ERROR	EQU	<ALC_FALSE>
ALC_INVALID_DEVICE	EQU	0A001h
ALC_INVALID_CONTEXT	EQU	0A002h
ALC_INVALID_ENUM	EQU	0A003h
ALC_INVALID_VALUE	EQU	0A004h
ALC_OUT_OF_MEMORY	EQU	0A005h
ALC_DEFAULT_DEVICE_SPECIFIER	EQU	1004h
ALC_DEVICE_SPECIFIER	EQU	1005h
ALC_EXTENSIONS	EQU	1006h
ALC_MAJOR_VERSION	EQU	1000h
ALC_MINOR_VERSION	EQU	1001h
ALC_ATTRIBUTES_SIZE	EQU	1002h
ALC_ALL_ATTRIBUTES	EQU	1003h
ALC_CAPTURE_DEVICE_SPECIFIER	EQU	310h
ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER	EQU	311h
ALC_CAPTURE_SAMPLES	EQU	312h
alcCreateContext proto c :ptr ALCdevice, :ptr ALCint
alcMakeContextCurrent proto c :ptr ALCcontext
alcProcessContext proto c :ptr ALCcontext
alcSuspendContext proto c :ptr ALCcontext
alcDestroyContext proto c :ptr ALCcontext
alcGetCurrentContext proto c 
alcGetContextsDevice proto c :ptr ALCcontext
alcOpenDevice proto c :ptr ALCchar
alcCloseDevice proto c :ptr ALCdevice
alcGetError proto c :ptr ALCdevice
alcIsExtensionPresent proto c :ptr ALCdevice, :ptr ALCchar
alcGetProcAddress proto c :ptr ALCdevice, :ptr ALCchar
alcGetEnumValue proto c :ptr ALCdevice, :ptr ALCchar
alcGetString proto c :ptr ALCdevice, :ALCenum
alcGetIntegerv proto c :ptr ALCdevice, :ALCenum, :ALCsizei, :ptr ALCint
alcCaptureOpenDevice proto c :ptr ALCchar, :ALCuint, :ALCenum, :ALCsizei
alcCaptureCloseDevice proto c :ptr ALCdevice
alcCaptureStart proto c :ptr ALCdevice
alcCaptureStop proto c :ptr ALCdevice
alcCaptureSamples proto c :ptr ALCdevice, :ptr ALCvoid, :ALCsizei
proto_LPALCCREATECONTEXT typedef proto c :ptr ALCdevice,:ptr ALCint
LPALCCREATECONTEXT typedef ptr proto_LPALCCREATECONTEXT
proto_LPALCMAKECONTEXTCURRENT typedef proto c :ptr ALCcontext
LPALCMAKECONTEXTCURRENT typedef ptr proto_LPALCMAKECONTEXTCURRENT
proto_LPALCPROCESSCONTEXT typedef proto c :ptr ALCcontext
LPALCPROCESSCONTEXT typedef ptr proto_LPALCPROCESSCONTEXT
proto_LPALCSUSPENDCONTEXT typedef proto c :ptr ALCcontext
LPALCSUSPENDCONTEXT typedef ptr proto_LPALCSUSPENDCONTEXT
proto_LPALCDESTROYCONTEXT typedef proto c :ptr ALCcontext
LPALCDESTROYCONTEXT typedef ptr proto_LPALCDESTROYCONTEXT
proto_LPALCGETCURRENTCONTEXT typedef proto c 
LPALCGETCURRENTCONTEXT typedef ptr proto_LPALCGETCURRENTCONTEXT
proto_LPALCGETCONTEXTSDEVICE typedef proto c :ptr ALCcontext
LPALCGETCONTEXTSDEVICE typedef ptr proto_LPALCGETCONTEXTSDEVICE
proto_LPALCOPENDEVICE typedef proto c :ptr ALCchar
LPALCOPENDEVICE typedef ptr proto_LPALCOPENDEVICE
proto_LPALCCLOSEDEVICE typedef proto c :ptr ALCdevice
LPALCCLOSEDEVICE typedef ptr proto_LPALCCLOSEDEVICE
proto_LPALCGETERROR typedef proto c :ptr ALCdevice
LPALCGETERROR typedef ptr proto_LPALCGETERROR
proto_LPALCISEXTENSIONPRESENT typedef proto c :ptr ALCdevice,:ptr ALCchar
LPALCISEXTENSIONPRESENT typedef ptr proto_LPALCISEXTENSIONPRESENT
proto_LPALCGETPROCADDRESS typedef proto c :ptr ALCdevice,:ptr ALCchar
LPALCGETPROCADDRESS typedef ptr proto_LPALCGETPROCADDRESS
proto_LPALCGETENUMVALUE typedef proto c :ptr ALCdevice,:ptr ALCchar
LPALCGETENUMVALUE typedef ptr proto_LPALCGETENUMVALUE
proto_LPALCGETSTRING typedef proto c :ptr ALCdevice,:ALCenum
LPALCGETSTRING typedef ptr proto_LPALCGETSTRING
proto_LPALCGETINTEGERV typedef proto c :ptr ALCdevice,:ALCenum,:ALCsizei,:ptr ALCint
LPALCGETINTEGERV typedef ptr proto_LPALCGETINTEGERV
proto_LPALCCAPTUREOPENDEVICE typedef proto c :ptr ALCchar,:ALCuint,:ALCenum,:ALCsizei
LPALCCAPTUREOPENDEVICE typedef ptr proto_LPALCCAPTUREOPENDEVICE
proto_LPALCCAPTURECLOSEDEVICE typedef proto c :ptr ALCdevice
LPALCCAPTURECLOSEDEVICE typedef ptr proto_LPALCCAPTURECLOSEDEVICE
proto_LPALCCAPTURESTART typedef proto c :ptr ALCdevice
LPALCCAPTURESTART typedef ptr proto_LPALCCAPTURESTART
proto_LPALCCAPTURESTOP typedef proto c :ptr ALCdevice
LPALCCAPTURESTOP typedef ptr proto_LPALCCAPTURESTOP
proto_LPALCCAPTURESAMPLES typedef proto c :ptr ALCdevice,:ptr ALCvoid,:ALCsizei
LPALCCAPTURESAMPLES typedef ptr proto_LPALCCAPTURESAMPLES

;--- include file created by h2incx v0.99.20 (copyright 2005-2009 japheth)
;--- source file: D:\Miscellaneous\openal-soft-1.7.411\include\AL\alext.h, last modified: 11/7/2008 9:36
;--- cmdline used for creation:  -k c alext.h

ifndef AL_LOKI_IMA_ADPCM_format
AL_LOKI_IMA_ADPCM_format	EQU	1
AL_FORMAT_IMA_ADPCM_MONO16_EXT	EQU	10000h
AL_FORMAT_IMA_ADPCM_STEREO16_EXT	EQU	10001h
endif 
ifndef AL_LOKI_WAVE_format
AL_LOKI_WAVE_format	EQU	1
AL_FORMAT_WAVE_EXT	EQU	10002h
endif 
ifndef AL_EXT_vorbis
AL_EXT_vorbis	EQU	1
AL_FORMAT_VORBIS_EXT	EQU	10003h
endif 
ifndef AL_LOKI_quadriphonic
AL_LOKI_quadriphonic	EQU	1
AL_FORMAT_QUAD8_LOKI	EQU	10004h
AL_FORMAT_QUAD16_LOKI	EQU	10005h
endif 
ifndef AL_EXT_float32
AL_EXT_float32	EQU	1
AL_FORMAT_MONO_FLOAT32	EQU	10010h
AL_FORMAT_STEREO_FLOAT32	EQU	10011h
endif 
ifndef ALC_LOKI_audio_channel
ALC_LOKI_audio_channel	EQU	1
ALC_CHAN_MAIN_LOKI	EQU	500001h
ALC_CHAN_PCM_LOKI	EQU	500002h
ALC_CHAN_CD_LOKI	EQU	500003h
endif 
ifndef ALC_ENUMERATE_ALL_EXT
ALC_ENUMERATE_ALL_EXT	EQU	1
ALC_DEFAULT_ALL_DEVICES_SPECIFIER	EQU	1012h
ALC_ALL_DEVICES_SPECIFIER	EQU	1013h
endif 
ifndef AL_EXT_MCFORMATS
AL_EXT_MCFORMATS	EQU	1
AL_FORMAT_QUAD8	EQU	1204h
AL_FORMAT_QUAD16	EQU	1205h
AL_FORMAT_QUAD32	EQU	1206h
AL_FORMAT_REAR8	EQU	1207h
AL_FORMAT_REAR16	EQU	1208h
AL_FORMAT_REAR32	EQU	1209h
AL_FORMAT_51CHN8	EQU	120Ah
AL_FORMAT_51CHN16	EQU	120Bh
AL_FORMAT_51CHN32	EQU	120Ch
AL_FORMAT_61CHN8	EQU	120Dh
AL_FORMAT_61CHN16	EQU	120Eh
AL_FORMAT_61CHN32	EQU	120Fh
AL_FORMAT_71CHN8	EQU	1210h
AL_FORMAT_71CHN16	EQU	1211h
AL_FORMAT_71CHN32	EQU	1212h
endif 
ifndef AL_EXT_IMA4
AL_EXT_IMA4	EQU	1
AL_FORMAT_MONO_IMA4	EQU	1300h
AL_FORMAT_STEREO_IMA4	EQU	1301h
endif 
ifndef AL_EXT_buffer_sub_data
AL_EXT_buffer_sub_data	EQU	1
AL_BYTE_RW_OFFSETS_EXT	EQU	1031h
AL_SAMPLE_RW_OFFSETS_EXT	EQU	1032h
AL_SEC_RW_OFFSETS_EXT	EQU	1033h
proto_PFNALBUFFERSUBDATAEXTPROC typedef proto c :ALuint,:ALenum,:ptr ALvoid,:ALsizei,:ALsizei
PFNALBUFFERSUBDATAEXTPROC typedef ptr proto_PFNALBUFFERSUBDATAEXTPROC
endif 