//   Change only the numeric macros upon version progress. The string version 
// will update automatically here and in makeit.bat. Once base MASMZE-3D 1.1_hf2
// is reached, the version will roll over to 2.0 and the -BP3D suffix must be
// dropped from here and makeit.bat.

#define VER_MAJOR		0
#define VER_MINOR		9
#define VER_PATCH		0
#define VER_BUILD		0

// Automatic stuff below
#define _VER_STR(x)    #x
#define _VER_XSTR(x)   _VER_STR(x)

#define VER_STRING		"v" _VER_XSTR(VER_MAJOR) "." _VER_XSTR(VER_MINOR) "." _VER_XSTR(VER_PATCH) "-BP3D"
