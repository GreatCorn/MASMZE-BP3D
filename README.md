# MASMZE-BP3D

MASMZE-BP3D is a recreation of the earlier game project <a href="https://github.com/GreatCorn/MASMZE-3D">MASMZE-3D</a>, using the <a href="https://github.com/GreatCorn/BoilPlate3D">BoilPlate3D</a> framework to optimize code structuring, improve compatibility, and enhance flexibility.

A recreation here means a complete rewrite from scratch in accordance with the new core framework. It focuses on stabilizing the existing game elements, properly structuring the code for readability (though I still have failed in this regard), and adding some small new features along the way to try and make more of a game out of the "tech"-"demo" that was MASMZE-3D.

For now, the main changes from the base game include:

- Bugfixes. This includes fixing the instability of the mouselook, interpolation, collision, DPI-awareness, etc.
- Improved compatibility over different operating systems (runs natively on Windows 2000, ReactOS, through Wine on Linux, FreeBSD, Android (Winlator))
- Some visual effects that the fixed-function pipeline OpenGL would allow, particles, interpolated vertex animation, MSAA, optional VSync
- Multiplayer mode (works cross-platform and through port forwarding)
- More visual and auditory variety
- More proper input and settings implementation 
- Custom translation support

## Compiling

Compilation prerequisites are:

- A MASM-compatible x86 assembler and linker. This includes the assemblers (MASM, <a href="https://www.terraspace.co.uk/uasm.html">UASM</a>, <a href="https://github.com/nidud/asmc">ASMC</a>) and linkers (MSVC LINK.exe, JWLink) that BoilPlate3D itself supports. Different configurations are available through makeit.bat command-line arguments. Does not support x86_64
- Windows include and lib files: MASMZE-BP3D, like BoilPlate3D, is configured to compile with both MASM32 and <a href="https://www.terraspace.co.uk/uasm.html#p7">WinInc</a> headers (though MASM won't like them)
- BoilPlate3D source at ..\BoilPlate3D\src\ relative to main.asm. MASMZE-BP3D is configured to use the framework from source
- The required headers for OpenAL and stb_vorbis are included (the project is configured for OpenAL Soft specifically via symbolic soft_oal links), so not necessary for compilation, but for running the built project there must be soft_oal.dll (<a href="https://openal-soft.org/openal-binaries/">listing of binaries</a>, I recommend version 13.0, as it removed the popping issue and is the last version supported by Win2k) and stb_vorbis.dll withing the same directory as the executable
- To target Windows 2000 and earlier, uncomment BP_COMPATIBILITY_W9X preprocessor definition (main.asm:5). This will lose raw input support and DPI awareness

To compile the project, either run makeit.bat or compile and link manually with any of the supported tools. Note that makeit.bat expects the chosen tools to be in the PATH variable or otherwise accessible by name. It also expects the include and lib files to be in C:\masm32\ for MASM32 or C:\WinInc\ for WinInc (the drive letter can be changed with the /d [drive] argument).

***

The game's code, not including the external libraries, is licensed under the <a href=https://github.com/GreatCorn/MASMZE-BP3D/blob/main/LICENSE.txt>MIT License</a>. The game's assets are licensed under a <a href=https://github.com/GreatCorn/MASMZE-BP3D/blob/main/assets/LICENSE.txt>Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.

© Yevhenii Ionenko (aka GreatCorn), 2023-2026

https://greatcorn.github.io/me/
