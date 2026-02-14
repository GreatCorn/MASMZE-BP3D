BPMesh? TEXTEQU <BPMesh <?, ?, ?, ?, ?, ?>>

ENUM	LOADING_TEXT, \
		LOADING_ANIMATIONS, \
		LOADING_FONTS, \
		LOADING_MODELS, \
		LOADING_TEXTURES, \
		LOADING_SOUNDS, \
		LOADING_FINISHED, \
		LOADING_WAIT

.DATA
; ----- ANIMATIONS -----
AnimCamEnter		BPAnimTrack <>
AnimCamExit			BPAnimTrack <>
AnimCamWalk			BPAnimTrack <>
AnimKubaleMove		BPAnimTrack <>	
AnimWmblykCrawl		BPAnimTrack <>
AnimWmblykDead		BPAnimTrack <>
AnimWmblykStrangle	BPAnimTrack <>
AnimWmblykWalk		BPAnimTrack <>

; ----- FONTS -----
FntKeys		DWORD 256 dup (0)
FntPS		DWORD 256 dup (0)
FntXB		DWORD 256 dup (0)

Loading		BPBool FALSE
LoadState	DWORD 0

.DATA?

; ----- MODELS -----
MdlBorderFloor		DWORD ?
MdlBorderWall		DWORD ?
MdlCheckFloor		DWORD ?
MdlCheckRoof		DWORD ?
MdlCheckWalls		DWORD ?
MdlCityConcrete		DWORD ?
MdlCityFacade		DWORD ?
MdlCityTerrain		DWORD ?
MdlCompassArrow		DWORD ?
MdlCompassWorld		DWORD ?
MdlCrevice			DWORD ?
MdlCube				DWORD ?
MdlDoor				DWORD ?
MdlDoorFrame		DWORD ?
MdlDoorFrameLock	DWORD ?
MdlDoorwayM			DWORD ?
MdlGlyphs			DWORD ?
MdlHbd				DWORD ?
MdlHbdS				DWORD ?
MdlKey				DWORD ?
MdlKoluplykDig		DWORD ?, ?, ?, ?
MdlKoluplykShop		DWORD ?, ?
MdlLamp				DWORD ?
MdlMotrya			DWORD ?, ?, ?, ?
MdlNeqaotor			DWORD ?
MdlOutskirtsBunker	DWORD ?
MdlOutskirtsRoad	DWORD ?
MdlOutskirtsTerrain	DWORD ?
MdlOutskirtsTrees	DWORD ?
MdlPadlock			DWORD ?
MdlParticle			DWORD ?
MdlPipe				DWORD ?
MdlPlane			DWORD ?
MdlPlaneC			DWORD ?
MdlPlaneR			DWORD ?
MdlPlanks			DWORD ?
MdlRubble			DWORD ?
MdlRubbleFacade		DWORD ?
MdlShop				DWORD ?
MdlSigil			DWORD ?, ?
MdlSigns			DWORD ?
MdlSky				DWORD ?
MdlStairsM			DWORD ?
MdlTaburetka		DWORD ?
MdlTerrain			DWORD ?
MdlTorlagg			DWORD ?
MdlTrack			DWORD ?
MdlTrackTurn		DWORD ?
MdlTram				DWORD ?
MdlTramD			DWORD ?, ?, ?, ?
MdlTramDG			DWORD ?, ?, ?, ?
MdlTramG			DWORD ?
MdlUpFloor			DWORD ?
MdlUpRoof			DWORD ?
MdlUpWalls			DWORD ?
MdlVasT				DWORD ?, ?, ?
MdlVebraExit		DWORD ?, ?, ?, ?, ?, ?
MdlVebraLook		DWORD ?, ?
MdlVirdyaBack		DWORD ?, ?, ?, ?, ?, ?
MdlVirdyaBody		DWORD ?
MdlVirdyaH			DWORD ?, ?
MdlVirdyaHead		DWORD ?
MdlVirdyaRest		DWORD ?
MdlVirdyaWalk		DWORD ?, ?, ?, ?, ?, ?, ?, ?
; Vertex animations create abominations
MdlVirdyaWave		DWORD ?, ?, ?, ?, ?, ?, ?, ?, ?
MdlWall				DWORD ?
MdlWallArch			DWORD ?
MdlWallClerestory	DWORD ?
MdlWallColumn		DWORD ?
MdlWallSlant		DWORD ?
MdlWallSlit			DWORD ?
MdlWallTrench		DWORD ?
MdlWallTunnel		DWORD ?
MdlWallWainscot		DWORD ?
MdlWbAttack			DWORD ?, ?, ?
MdlWbbk				DWORD ?
MdlWbIdle			DWORD ?, ?
MdlWbWalk			DWORD ?, ?, ?
MdlWires			DWORD ?
MdlWmblykBody		DWORD ?
MdlWmblykBodyG		DWORD ?
MdlWmblykHead		DWORD ?

MeshKubale			BPMesh?
MeshWmblyk			BPMesh?

ScreenQuad	DWORD ?

; ----- TEXTURES -----
TexAmbient			DWORD ?
TexBricks			DWORD ?
TexCompass			DWORD ?
TexCompassWorld		DWORD ?
TexConcrete			DWORD ?
TexConcreteRoof		DWORD ?
TexCroa				DWORD ?
TexCursor			DWORD ?
TexDiamond			DWORD ?
TexDirt				DWORD ?
TexDoor				DWORD ?
TexDoorBlur			DWORD ?
TexDust				DWORD ?
TexEBD				DWORD ?, ?, ?
TexEBDShadow		DWORD ?
TexFacade			DWORD ?
TexFloor			DWORD ?
TexFloorLinoleum	DWORD ?
TexFloorParquet		DWORD ?
TexGamma			DWORD ?
TexGlyph			DWORD 7 DUP(?)
TexGlyphs			DWORD ?
TexHbd				DWORD ?
TexKey				DWORD ?
TexKoluplyk			DWORD ?
TexKubale			DWORD ?
TexKubaleV			DWORD 9 DUP(?)
TexLamp				DWORD ?
TexLight			DWORD ?
TexMap				DWORD ?
TexMetal			DWORD ?
TexMetalFloor		DWORD ?
TexMetalRoof		DWORD ?
TexMotrya			DWORD ?
TexNoise			DWORD ?
TexPaper			DWORD ?
TexPipe				DWORD ?
TexPlanks			DWORD ?
TexPlaster			DWORD ?
TexRain				DWORD ?
TexRoof				DWORD ?
TexSigns			DWORD ?
TexShadow			DWORD ?
TexSky				DWORD ?
TexTaburetka		DWORD ?
TexTileBig			DWORD ?
TexTilefloor		DWORD ?
TexTone				DWORD ?
TexTram				DWORD ?
TexTree				DWORD ?
TexTutorial			DWORD ?
TexTutorialJ		DWORD ?
TexUIArrow			DWORD ?
TexUICircle			DWORD ?
TexVas				DWORD ?
TexVebra			DWORD ?
TexVignette			DWORD ?
TexVignetteRed		DWORD ?

TexVirdyaBlink		DWORD ?
TexVirdyaDown		DWORD ?
TexVirdyaN			DWORD ?
TexVirdyaNeut		DWORD ?
TexVirdyaUp			DWORD ?

TexWall				DWORD ?
TexWallPainted		DWORD ?
TexWB				DWORD ?
TexWBBK				DWORD ?
TexWBBKP			DWORD ?
TexWBBK1			DWORD ?
TexWhitewall		DWORD ?

TexWmblykHappy		DWORD ?
TexWmblykNeutral	DWORD ?
TexWmblykJumpscare	DWORD ?
TexWmblykStr		DWORD ?, ?, ?, ?, ?, ?, ?
TexWmblykWait		DWORD ?, ?, ?

; ----- SOUNDS -----
SndSectionStart	BYTE ?
SndAlarm		DWORD ?
SndAmb			DWORD ?
SndAmbT			DWORD ?
SndAmbW			DWORD ?, ?, ?, ?
SndCheckpoint	DWORD ?
SndCrumble		DWORD ?
SndDeath		DWORD ?
SndDig			DWORD ?
SndDistress		DWORD ?
SndDoorClose	DWORD ?
SndDrip			DWORD ?
SndEBD			DWORD ?
SndEBDA			DWORD ?
SndExit			DWORD ?
SndExit1		DWORD ?
SndExplosion	DWORD ?
SndHbd			DWORD ?
SndHbdO			DWORD ?
SndHurt			DWORD ?
SndImpact		DWORD ?
SndIntro		DWORD ?
SndKey			DWORD ?
SndKubale		DWORD ?
SndKubaleAppear	DWORD ?
SndKubaleV		DWORD ?
SndMistake		DWORD ?
SndMus			DWORD ?, ?, ?, ?, ?
SndRand			DWORD ?, ?, ?, ?, ?, ?
SndSave			DWORD ?
SndScribble		DWORD ?
SndSiren		DWORD ?
SndSlam			DWORD ?
SndSplash		DWORD ?
SndStep			DWORD ?, ?, ?, ?
SndTram			DWORD ?
SndTramAnn		DWORD ?, ?, ?
SndTramClose	DWORD ?
SndTramOpen		DWORD ?
SndVirdya		DWORD ?
SndWBAlarm		DWORD ?
SndWBAttack		DWORD ?
SndWBIdle		DWORD ?, ?
SndWBStep		DWORD ?, ?, ?, ?
SndWBBK			DWORD ?
SndWhisper		DWORD ?
SndWmblyk		DWORD ?
SndWmblykB		DWORD ?
SndWmblykStr	DWORD ?
SndWmblykStrM	DWORD ?
SndSectionEnd	BYTE ?

; ----- STRINGS -----
SV	MACRO StrID:REQ
	StrID	BPPtr ?
ENDM
StrLayerNumPtr	BPPtr ?
include Strings.inc

.CODE

FreeStrings PROC EXPORT
	print "Freeing strings", 9
	mov pbx, OFFSET StrLanguageID		; First string
	.WHILE (pbx < OFFSET StrSectionEnd)	; String section end
		mov pax, pbx
		sub pax, OFFSET StrLanguageID
		invoke bpFree, bpDefHeap, 0, BPPtr PTR [pbx]
		add pbx, SIZEOF BPPtr
	.ENDW
	print "...done!", 13, 10
	ret
FreeStrings ENDP

LoadResources PROC EXPORT
	mov Loading, TRUE
	
	.IF (LoadState == LOADING_TEXT)
		; ----- TEXT ESSENTIALS -----
		print "Loading text...", 9
		; Load language strings
		vinvoke LoadStrings, OFFSET SettingsMiscLanguage
		
		invoke bpLoadFont, StrLangFontPath, OFFSET bpDefaultFont	; Main
		mov bpTextNL, '#'
		print "...done!", 13, 10
	.ELSEIF (LoadState == LOADING_ANIMATIONS)
		print "Loading animations...", 9		
		LoadBPA OFFSET AnimCamEnter,		"assets\anim\camEnter.bpa"
		LoadBPA OFFSET AnimCamExit,			"assets\anim\camExit.bpa"
		LoadBPA OFFSET AnimCamWalk,			"assets\anim\camWalk.bpa"
		mov AnimCamWalk.Looping, TRUE
		
		LoadBPA OFFSET AnimKubaleMove,		"assets\anim\kubaleMove.bpa"
		mov AnimKubaleMove.Looping, TRUE
		
		LoadBPA OFFSET AnimWmblykCrawl,		"assets\anim\wmblykCrawl.bpa"
		mov AnimWmblykCrawl.Looping, TRUE
		LoadBPA OFFSET AnimWmblykDead,		"assets\anim\wmblykDead.bpa"
		LoadBPA OFFSET AnimWmblykStrangle,	"assets\anim\wmblykStrangle.bpa"
		
		LoadBPA OFFSET AnimWmblykWalk,		"assets\anim\wmblykWalk.bpa"
		mov AnimWmblykWalk.Looping, TRUE
		
		print "...done!", 13, 10
	.ELSEIF (LoadState == LOADING_FONTS)
		; ----- FONTS -----
		print "Loading fonts...", 9
		LoadFont "font\input\", OFFSET FntKeys	; Direct mapping to keys/axes
		;mov bpTextureFiltering, TRUE
		LoadFont "font\input\ps\", OFFSET FntPS
		LoadFont "font\input\xb\", OFFSET FntXB
		;mov bpTextureFiltering, FALSE
		print "...done!", 13, 10
	.ELSEIF (LoadState == LOADING_MODELS)
		; ----- MODELS -----
		print "Loading models...", 9
		LoadBPL OFFSET MdlBorderFloor, 		"assets\models\borderFloor.bpl"
		LoadBPL OFFSET MdlBorderWall, 		"assets\models\borderWall.bpl"
		LoadBPL OFFSET MdlCheckFloor, 		"assets\models\checkFloor.bpl"
		LoadBPL OFFSET MdlCheckRoof, 		"assets\models\checkRoof.bpl"
		LoadBPL OFFSET MdlCheckWalls, 		"assets\models\checkWalls.bpl"
		LoadBPL OFFSET MdlCityConcrete, 	"assets\models\cityConcrete.bpl"
		LoadBPL OFFSET MdlCityFacade, 		"assets\models\cityFacade.bpl"
		LoadBPL OFFSET MdlCityTerrain, 		"assets\models\cityTerrain.bpl"
		LoadBPL OFFSET MdlCompassArrow, 	"assets\models\compassArrow.bpl"
		LoadBPL OFFSET MdlCompassWorld, 	"assets\models\compassWorld.bpl"
		LoadBPL OFFSET MdlCrevice, 			"assets\models\crevice.bpl"
		LoadBPL OFFSET MdlCube, 			"assets\models\cube.bpl"
		LoadBPL OFFSET MdlDoor, 			"assets\models\door.bpl"
		LoadBPL OFFSET MdlDoorFrame, 		"assets\models\doorFrame.bpl"
		LoadBPL OFFSET MdlDoorFrameLock, 	"assets\models\doorFrameLock.bpl"
		LoadBPL OFFSET MdlDoorwayM, 		"assets\models\doorwayM.bpl"
		LoadBPL OFFSET MdlGlyphs, 			"assets\models\glyphs.bpl"
		LoadBPL OFFSET MdlHbd, 				"assets\models\hbd.bpl"
		LoadBPL OFFSET MdlHbdS, 			"assets\models\hbdS.bpl"
		LoadBPL OFFSET MdlKey, 				"assets\models\key.bpl"
		LoadBPL OFFSET MdlKoluplykDig[0],	"assets\models\koluplykDig1.bpl"
		LoadBPL OFFSET MdlKoluplykDig[4], 	"assets\models\koluplykDig2.bpl"
		LoadBPL OFFSET MdlKoluplykDig[8],	"assets\models\koluplykDig3.bpl"
		LoadBPL OFFSET MdlKoluplykDig[12],	"assets\models\koluplykDig4.bpl"
		LoadBPL OFFSET MdlKoluplykShop[0],	"assets\models\koluplykShop1.bpl"
		LoadBPL OFFSET MdlKoluplykShop[4],	"assets\models\koluplykShop2.bpl"
		LoadBPL OFFSET MdlLamp,				"assets\models\lamp.bpl"
		LoadBPL OFFSET MdlMotrya[0],		"assets\models\motrya1.bpl"
		LoadBPL OFFSET MdlMotrya[4],		"assets\models\motrya2.bpl"
		LoadBPL OFFSET MdlMotrya[8],		"assets\models\motrya3.bpl"
		LoadBPL OFFSET MdlMotrya[12],		"assets\models\motrya4.bpl"
		LoadBPL OFFSET MdlNeqaotor,			"assets\models\neqaotor.bpl"
		LoadBPL OFFSET MdlOutskirtsBunker,	"assets\models\outskirtsBunker.bpl"
		LoadBPL OFFSET MdlOutskirtsRoad,	"assets\models\outskirtsRoad.bpl"
		LoadBPL OFFSET MdlOutskirtsTerrain,	"assets\models\outskirtsTerrain.bpl"
		LoadBPL OFFSET MdlOutskirtsTrees,	"assets\models\outskirtsTrees.bpl"
		LoadBPL OFFSET MdlPadlock,			"assets\models\padlock.bpl"
		LoadBPL OFFSET MdlParticle,			"assets\models\particle.bpl"
		LoadBPL OFFSET MdlPipe,				"assets\models\pipe.bpl"
		LoadBPL OFFSET MdlPlane,			"assets\models\plane.bpl"
		LoadBPL OFFSET MdlPlaneC,			"assets\models\planeC.bpl"
		LoadBPL OFFSET MdlPlaneR,			"assets\models\planeR.bpl"
		LoadBPL OFFSET MdlPlanks,			"assets\models\planks.bpl"
		LoadBPL OFFSET MdlRubble,			"assets\models\rubble.bpl"
		LoadBPL OFFSET MdlRubbleFacade,		"assets\models\rubbleFacade.bpl"
		LoadBPL OFFSET MdlShop,				"assets\models\shop.bpl"
		LoadBPL OFFSET MdlSigil[0],			"assets\models\sigil1.bpl"
		LoadBPL OFFSET MdlSigil[4],			"assets\models\sigil2.bpl"
		LoadBPL OFFSET MdlSigns,			"assets\models\signs.bpl"
		LoadBPL OFFSET MdlSky,				"assets\models\sky.bpl"
		LoadBPL OFFSET MdlStairsM,			"assets\models\stairsM.bpl"
		LoadBPL OFFSET MdlTaburetka,		"assets\models\taburetka.bpl"
		LoadBPL OFFSET MdlTerrain,			"assets\models\terrain.bpl"
		LoadBPL OFFSET MdlTorlagg,			"assets\models\torlagg.bpl"
		LoadBPL OFFSET MdlTrack,			"assets\models\track.bpl"
		LoadBPL OFFSET MdlTrackTurn,		"assets\models\trackTurn.bpl"
		LoadBPL OFFSET MdlTram,				"assets\models\tram.bpl"
		LoadBPL OFFSET MdlTramD[0],			"assets\models\tramD1.bpl"
		LoadBPL OFFSET MdlTramD[4],			"assets\models\tramD2.bpl"
		LoadBPL OFFSET MdlTramD[8],			"assets\models\tramD3.bpl"
		LoadBPL OFFSET MdlTramD[12],		"assets\models\tramD4.bpl"
		LoadBPL OFFSET MdlTramDG[0],		"assets\models\tramDG1.bpl"
		LoadBPL OFFSET MdlTramDG[4],		"assets\models\tramDG2.bpl"
		LoadBPL OFFSET MdlTramDG[8],		"assets\models\tramDG3.bpl"
		LoadBPL OFFSET MdlTramDG[12],		"assets\models\tramDG4.bpl"
		LoadBPL OFFSET MdlTramG,			"assets\models\tramG.bpl"
		LoadBPL OFFSET MdlUpFloor,			"assets\models\upFloor.bpl"
		LoadBPL OFFSET MdlUpRoof,			"assets\models\upRoof.bpl"
		LoadBPL OFFSET MdlUpWalls,			"assets\models\upWalls.bpl"
		LoadBPL OFFSET MdlVasT[0],			"assets\models\vasT1.bpl"
		LoadBPL OFFSET MdlVasT[4],			"assets\models\vasT2.bpl"
		LoadBPL OFFSET MdlVasT[8],			"assets\models\vasT3.bpl"
		LoadBPL OFFSET MdlVebraExit[0],		"assets\models\vebraExit1.bpl"
		LoadBPL OFFSET MdlVebraExit[4],		"assets\models\vebraExit2.bpl"
		LoadBPL OFFSET MdlVebraExit[8],		"assets\models\vebraExit3.bpl"
		LoadBPL OFFSET MdlVebraExit[12],	"assets\models\vebraExit4.bpl"
		LoadBPL OFFSET MdlVebraExit[16],	"assets\models\vebraExit5.bpl"
		LoadBPL OFFSET MdlVebraExit[20],	"assets\models\vebraExit6.bpl"
		LoadBPL OFFSET MdlVebraLook[0],		"assets\models\vebraLook1.bpl"
		LoadBPL OFFSET MdlVebraLook[4],		"assets\models\vebraLook2.bpl"
		LoadBPL OFFSET MdlVirdyaBack[0],	"assets\models\virdyaBack1.bpl"
		LoadBPL OFFSET MdlVirdyaBack[4],	"assets\models\virdyaBack2.bpl"
		LoadBPL OFFSET MdlVirdyaBack[8],	"assets\models\virdyaBack3.bpl"
		LoadBPL OFFSET MdlVirdyaBack[12],	"assets\models\virdyaBack4.bpl"
		LoadBPL OFFSET MdlVirdyaBack[16],	"assets\models\virdyaBack5.bpl"
		LoadBPL OFFSET MdlVirdyaBack[20],	"assets\models\virdyaBack6.bpl"
		LoadBPL OFFSET MdlVirdyaBody,		"assets\models\virdyaBody.bpl"
		LoadBPL OFFSET MdlVirdyaH[0],		"assets\models\virdyaH1.bpl"
		LoadBPL OFFSET MdlVirdyaH[4],		"assets\models\virdyaH2.bpl"
		LoadBPL OFFSET MdlVirdyaHead,		"assets\models\virdyaHead.bpl"
		LoadBPL OFFSET MdlVirdyaRest,		"assets\models\virdyaRest.bpl"
		LoadBPL OFFSET MdlVirdyaWalk[0],	"assets\models\virdyaWalk1.bpl"
		LoadBPL OFFSET MdlVirdyaWalk[4],	"assets\models\virdyaWalk2.bpl"
		LoadBPL OFFSET MdlVirdyaWalk[8],	"assets\models\virdyaWalk3.bpl"
		LoadBPL OFFSET MdlVirdyaWalk[12],	"assets\models\virdyaWalk4.bpl"
		LoadBPL OFFSET MdlVirdyaWalk[16],	"assets\models\virdyaWalk5.bpl"
		LoadBPL OFFSET MdlVirdyaWalk[20],	"assets\models\virdyaWalk6.bpl"
		LoadBPL OFFSET MdlVirdyaWalk[24],	"assets\models\virdyaWalk7.bpl"
		LoadBPL OFFSET MdlVirdyaWalk[28],	"assets\models\virdyaWalk8.bpl"
		LoadBPL OFFSET MdlVirdyaWave[0],	"assets\models\virdyaWave1.bpl"
		LoadBPL OFFSET MdlVirdyaWave[4],	"assets\models\virdyaWave2.bpl"
		LoadBPL OFFSET MdlVirdyaWave[8],	"assets\models\virdyaWave3.bpl"
		LoadBPL OFFSET MdlVirdyaWave[12],	"assets\models\virdyaWave4.bpl"
		LoadBPL OFFSET MdlVirdyaWave[16],	"assets\models\virdyaWave5.bpl"
		LoadBPL OFFSET MdlVirdyaWave[20],	"assets\models\virdyaWave4.bpl"	; Still lazy
		LoadBPL OFFSET MdlVirdyaWave[24],	"assets\models\virdyaWave5.bpl"
		LoadBPL OFFSET MdlVirdyaWave[28],	"assets\models\virdyaWave4.bpl"
		LoadBPL OFFSET MdlVirdyaWave[32],	"assets\models\virdyaWave2.bpl"
		LoadBPL OFFSET MdlWall,				"assets\models\wall.bpl"
		LoadBPL OFFSET MdlWallArch,			"assets\models\wallArch.bpl"
		LoadBPL OFFSET MdlWallClerestory,	"assets\models\wallClerestory.bpl"
		LoadBPL OFFSET MdlWallColumn,		"assets\models\wallColumn.bpl"
		LoadBPL OFFSET MdlWallSlit,			"assets\models\wallSlit.bpl"
		LoadBPL OFFSET MdlWallSlant,		"assets\models\wallSlant.bpl"
		LoadBPL OFFSET MdlWallTrench,		"assets\models\wallTrench.bpl"
		LoadBPL OFFSET MdlWallTunnel,		"assets\models\wallTunnel.bpl"
		LoadBPL OFFSET MdlWallWainscot,		"assets\models\wallWainscot.bpl"
		LoadBPL OFFSET MdlWbAttack[0],		"assets\models\wbAttack1.bpl"
		LoadBPL OFFSET MdlWbAttack[4],		"assets\models\wbAttack2.bpl"
		LoadBPL OFFSET MdlWbAttack[8],		"assets\models\wbAttack3.bpl"
		LoadBPL OFFSET MdlWbbk,				"assets\models\wbbk.bpl"
		LoadBPL OFFSET MdlWbIdle[0],		"assets\models\wbIdle1.bpl"
		LoadBPL OFFSET MdlWbIdle[4],		"assets\models\wbIdle2.bpl"
		LoadBPL OFFSET MdlWbWalk[0],		"assets\models\wbWalk1.bpl"
		LoadBPL OFFSET MdlWbWalk[4],		"assets\models\wbWalk2.bpl"
		LoadBPL OFFSET MdlWbWalk[8],		"assets\models\wbWalk3.bpl"
		LoadBPL OFFSET MdlWires,			"assets\models\wires.bpl"
		LoadBPL OFFSET MdlWmblykBody,		"assets\models\wmblykBody.bpl"
		LoadBPL OFFSET MdlWmblykBodyG,		"assets\models\wmblykBodyG.bpl"
		LoadBPL OFFSET MdlWmblykHead,		"assets\models\wmblykHead.bpl"
		
		LoadBPM OFFSET MeshKubale,			"assets\models\kubale.bpm"
		LoadBPM OFFSET MeshWmblyk,			"assets\models\wmblyk.bpm"

		mov ScreenQuad, rv(glGenLists, 1)
		invoke glNewList, ScreenQuad, GL_COMPILE
			invoke glBegin, GL_QUADS
				invoke glTexCoord2i, 0, 0
				invoke glVertex2i, 0, 1
				invoke glTexCoord2i, 1, 0
				invoke glVertex2i, 1, 1
				invoke glTexCoord2i, 1, 1
				invoke glVertex2i, 1, 0
				invoke glTexCoord2i, 0, 1
				invoke glVertex2i, 0, 0
			call glEnd
		call glEndList
		print "...done!", 13, 10
	.ELSEIF (LoadState == LOADING_TEXTURES)
		; ----- TEXTURES -----
		print "Loading textures...", 9
		LoadBPT OFFSET TexAmbient,		"assets\textures\ambient.bpt"
		LoadBPT OFFSET TexBricks,		"assets\textures\bricks.bpt"
		LoadBPT OFFSET TexCompass,		"assets\textures\compass.bpt"
		LoadBPT OFFSET TexCompassWorld,	"assets\textures\compassWorld.bpt"
		LoadBPT OFFSET TexConcrete,		"assets\textures\concrete.bpt"
		LoadBPT OFFSET TexConcreteRoof,	"assets\textures\concreteRoof.bpt"
		LoadBPT OFFSET TexCroa,			"assets\textures\croa.bpt"
		LoadBPT OFFSET TexCursor,		"assets\textures\cursor.bpt"
		LoadBPT OFFSET TexDiamond,		"assets\textures\diamond.bpt"
		LoadBPT OFFSET TexDirt,			"assets\textures\dirt.bpt"
		LoadBPT OFFSET TexDoor,			"assets\textures\door.bpt"
		LoadBPT OFFSET TexDoorBlur,		"assets\textures\doorBlur.bpt"
		LoadBPT OFFSET TexDust,			"assets\textures\dust.bpt"
		LoadBPT OFFSET TexEBD[0],		"assets\textures\EBD1.bpt"
		LoadBPT OFFSET TexEBD[4],		"assets\textures\EBD2.bpt"
		LoadBPT OFFSET TexEBD[8],		"assets\textures\EBD3.bpt"
		LoadBPT OFFSET TexEBDShadow,	"assets\textures\EBDShadow.bpt"
		LoadBPT OFFSET TexFacade,		"assets\textures\facade.bpt"
		LoadBPT OFFSET TexFloor,		"assets\textures\floor.bpt"
		LoadBPT OFFSET TexFloorLinoleum,"assets\textures\floorLinoleum.bpt"
		LoadBPT OFFSET TexFloorParquet,	"assets\textures\floorParquet.bpt"
		LoadBPT OFFSET TexGamma,		"assets\textures\gamma.bpt"
		LoadBPT OFFSET TexGlyph[0],		"assets\textures\glyph1.bpt"
		LoadBPT OFFSET TexGlyph[4],		"assets\textures\glyph2.bpt"
		LoadBPT OFFSET TexGlyph[8],		"assets\textures\glyph3.bpt"
		LoadBPT OFFSET TexGlyph[12],	"assets\textures\glyph4.bpt"
		LoadBPT OFFSET TexGlyph[16],	"assets\textures\glyph5.bpt"
		LoadBPT OFFSET TexGlyph[20],	"assets\textures\glyph6.bpt"
		LoadBPT OFFSET TexGlyph[24],	"assets\textures\glyph7.bpt"
		LoadBPT OFFSET TexHbd,			"assets\textures\hbd.bpt"
		LoadBPT OFFSET TexKey,			"assets\textures\key.bpt"
		LoadBPT OFFSET TexKoluplyk,		"assets\textures\koluplyk.bpt"
		LoadBPT OFFSET TexKubale,		"assets\textures\kubale.bpt"
		LoadBPT OFFSET TexKubaleV[0],	"assets\textures\kubaleV1.bpt"
		LoadBPT OFFSET TexKubaleV[4],	"assets\textures\kubaleV2.bpt"
		LoadBPT OFFSET TexKubaleV[8],	"assets\textures\kubaleV3.bpt"
		LoadBPT OFFSET TexKubaleV[12],	"assets\textures\kubaleV4.bpt"
		LoadBPT OFFSET TexKubaleV[16],	"assets\textures\kubaleV5.bpt"
		LoadBPT OFFSET TexKubaleV[20],	"assets\textures\kubaleV6.bpt"
		LoadBPT OFFSET TexKubaleV[24],	"assets\textures\kubaleV7.bpt"
		LoadBPT OFFSET TexKubaleV[24],	"assets\textures\kubaleV8.bpt"
		LoadBPT OFFSET TexKubaleV[24],	"assets\textures\kubaleV8.bpt"
		LoadBPT OFFSET TexKubaleV[28],	"assets\textures\kubaleV9.bpt"
		LoadBPT OFFSET TexLamp,			"assets\textures\lamp.bpt"
		LoadBPT OFFSET TexLight,		"assets\textures\light.bpt"
		LoadBPT OFFSET TexMap,			"assets\textures\map.bpt"
		LoadBPT OFFSET TexMetal,		"assets\textures\metal.bpt"
		LoadBPT OFFSET TexMetalFloor,	"assets\textures\metalFloor.bpt"
		LoadBPT OFFSET TexMetalRoof,	"assets\textures\metalRoof.bpt"
		LoadBPT OFFSET TexMotrya,		"assets\textures\motrya.bpt"
		LoadBPT OFFSET TexNoise,		"assets\textures\noise.bpt"
		LoadBPT OFFSET TexPaper,		"assets\textures\paper.bpt"
		LoadBPT OFFSET TexPipe,			"assets\textures\pipe.bpt"
		LoadBPT OFFSET TexPlanks,		"assets\textures\planks.bpt"
		LoadBPT OFFSET TexPlaster,		"assets\textures\plaster.bpt"
		LoadBPT OFFSET TexRain,			"assets\textures\rain.bpt"
		LoadBPT OFFSET TexRoof,			"assets\textures\roof.bpt"
		LoadBPT OFFSET TexShadow,		"assets\textures\shadow.bpt"
		LoadBPT OFFSET TexSigns,		"assets\textures\signs.bpt"
		mov bpTextureFiltering, TRUE
		LoadBPT OFFSET TexSky,			"assets\textures\sky.bpt"
		mov bpTextureFiltering, FALSE
		invoke glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP
		LoadBPT OFFSET TexTaburetka,	"assets\textures\taburetka.bpt"
		LoadBPT OFFSET TexTileBig,		"assets\textures\tileBig.bpt"
		LoadBPT OFFSET TexTilefloor,	"assets\textures\tilefloor.bpt"
		LoadBPT OFFSET TexTone,			"assets\textures\tone.bpt"
		LoadBPT OFFSET TexTree,			"assets\textures\tree.bpt"
		LoadBPT OFFSET TexTutorial,		"assets\textures\tutorial.bpt"
		LoadBPT OFFSET TexTutorialJ,	"assets\textures\tutorialJ.bpt"
		LoadBPT OFFSET TexUIArrow,		"assets\textures\uiArrow.bpt"
		LoadBPT OFFSET TexUICircle,		"assets\textures\uiCircle.bpt"
		LoadBPT OFFSET TexVas,			"assets\textures\vas.bpt"
		LoadBPT OFFSET TexVebra,		"assets\textures\vebra.bpt"
		mov bpTextureFiltering, TRUE
		LoadBPT OFFSET TexVignette,		"assets\textures\vignette.bpt"
		mov bpTextureFiltering, FALSE
		LoadBPT OFFSET TexVignetteRed,	"assets\textures\vignetteRed.bpt"
		LoadBPT OFFSET TexVirdyaBlink,	"assets\textures\virdyaBlink.bpt"
		LoadBPT OFFSET TexVirdyaDown,	"assets\textures\virdyaDown.bpt"
		LoadBPT OFFSET TexVirdyaN,		"assets\textures\virdyaN.bpt"
		LoadBPT OFFSET TexVirdyaNeut,	"assets\textures\virdyaNeut.bpt"
		LoadBPT OFFSET TexVirdyaUp,		"assets\textures\virdyaUp.bpt"
		LoadBPT OFFSET TexWall,			"assets\textures\wall.bpt"
		LoadBPT OFFSET TexWallPainted,	"assets\textures\wallPainted.bpt"
		LoadBPT OFFSET TexWB,			"assets\textures\WB.bpt"
		LoadBPT OFFSET TexWBBK,			"assets\textures\WBBK.bpt"
		LoadBPT OFFSET TexWBBK1,		"assets\textures\WBBK1.bpt"
		LoadBPT OFFSET TexWBBKP,		"assets\textures\WBBKP.bpt"
		LoadBPT OFFSET TexWhitewall,	"assets\textures\whitewall.bpt"
		LoadBPT OFFSET TexWmblykJumpscare,"assets\textures\wmblykJumpscare.bpt"
		LoadBPT OFFSET TexWmblykNeutral,"assets\textures\wmblykNeutral.bpt"
		LoadBPT OFFSET TexWmblykStr[0],	"assets\textures\wmblykHappy.bpt"
		LoadBPT OFFSET TexWmblykStr[4],	"assets\textures\wmblykW2.bpt"
		LoadBPT OFFSET TexWmblykStr[8],	"assets\textures\wmblykW1.bpt"
		LoadBPT OFFSET TexWmblykStr[12],"assets\textures\wmblykStr.bpt"
		LoadBPT OFFSET TexWmblykStr[16],"assets\textures\wmblykL1.bpt"
		LoadBPT OFFSET TexWmblykStr[20],"assets\textures\wmblykL2.bpt"
		LoadBPT OFFSET TexWmblykWait[0],"assets\textures\wmblykWait1.bpt"
		LoadBPT OFFSET TexWmblykWait[4],"assets\textures\wmblykWait2.bpt"
		LoadBPT OFFSET TexWmblykWait[8],"assets\textures\wmblykWait3.bpt"
		print "...done!", 13, 10
	.ELSEIF (LoadState == LOADING_SOUNDS)
		; ----- SOUNDS -----
		print "Loading sounds...", 9
		LoadBPS OFFSET SndAlarm,		"assets\sounds\alarm.bps"
		invoke alSourcei, SndAlarm, AL_LOOPING, AL_TRUE
		LoadBPS OFFSET SndAmb,			"assets\sounds\amb.bps"
		invoke alSourcei, SndAmb, AL_LOOPING, AL_TRUE
		LoadBPS OFFSET SndAmbT,			"assets\sounds\ambT.bps"
		invoke alSourcei, SndAmbT, AL_LOOPING, AL_TRUE
		LoadBPS OFFSET SndAmbW[0],		"assets\sounds\ambW1.bps"
		LoadBPS OFFSET SndAmbW[4],		"assets\sounds\ambW2.bps"
		LoadBPS OFFSET SndAmbW[8],		"assets\sounds\ambW3.bps"
		LoadBPS OFFSET SndAmbW[12],		"assets\sounds\ambW4.bps"
		LoadBPS OFFSET SndCheckpoint,	"assets\sounds\checkpoint.bps"
		LoadBPS OFFSET SndCrumble,		"assets\sounds\crumble.bps"
		LoadBPS OFFSET SndDeath,		"assets\sounds\death.bps"
		LoadBPS OFFSET SndDig,			"assets\sounds\dig.bps"
		LoadBPS OFFSET SndDistress,		"assets\sounds\distress.bps"
		LoadBPS OFFSET SndDoorClose,	"assets\sounds\doorClose.bps"
		LoadBPS OFFSET SndDrip,			"assets\sounds\drip.bps"
		invoke alSourcei, SndDrip, AL_LOOPING, AL_TRUE
		invoke alSourcef, SndDrip, AL_ROLLOFF_FACTOR, f(2)
		LoadBPS OFFSET SndEBD,			"assets\sounds\ebd.bps"
		invoke alSourcei, SndEBD, AL_LOOPING, AL_TRUE
		invoke alSourcef, SndEBD, AL_ROLLOFF_FACTOR, f(4)
		LoadBPS OFFSET SndEBDA,			"assets\sounds\ebdA.bps"
		invoke alSourcei, SndEBDA, AL_LOOPING, AL_TRUE
		LoadBPS OFFSET SndExit,			"assets\sounds\exit.bps"
		LoadBPS OFFSET SndExit1,		"assets\sounds\exit1.bps"
		LoadBPS OFFSET SndExplosion,	"assets\sounds\explosion.bps"
		LoadBPS OFFSET SndHbd,			"assets\sounds\hbd.bps"
		invoke alSourcei, SndHbd, AL_LOOPING, AL_TRUE
		invoke alSourcef, SndHbd, AL_ROLLOFF_FACTOR, f(3)
		LoadBPS OFFSET SndHbdO,			"assets\sounds\hbdO.bps"
		LoadBPS OFFSET SndHurt,			"assets\sounds\hurt.bps"
		LoadBPS OFFSET SndImpact,		"assets\sounds\impact.bps"
		LoadBPS OFFSET SndIntro,		"assets\sounds\intro.bps"
		LoadBPS OFFSET SndKey,			"assets\sounds\key.bps"
		LoadBPS OFFSET SndKubale,			"assets\sounds\kubale.bps"
		invoke alSourcei, SndKubale, AL_LOOPING, AL_TRUE
		LoadBPS OFFSET SndKubaleAppear,	"assets\sounds\kubaleAppear.bps"
		LoadBPS OFFSET SndKubaleV,		"assets\sounds\kubaleV.bps"
		invoke alSourcef, SndKubaleV, AL_GAIN, 0
		invoke alSourcei, SndKubaleV, AL_LOOPING, AL_TRUE
		LoadBPS OFFSET SndMistake,		"assets\sounds\mistake.bps"
		LoadBPS OFFSET SndMus[0],		"assets\sounds\mus1.bps"
		invoke alSourcef, SndMus[0], AL_GAIN, f(0.5)
		LoadBPS OFFSET SndMus[4],		"assets\sounds\mus2.bps"
		invoke alSourcef, SndMus[4], AL_GAIN, f(0.5)
		LoadBPS OFFSET SndMus[8],		"assets\sounds\mus3.bps"
		invoke alSourcef, SndMus[8], AL_GAIN, 0
		invoke alSourcei, SndMus[8], AL_LOOPING, AL_TRUE
		LoadBPS OFFSET SndMus[12],		"assets\sounds\mus4.bps"
		invoke alSourcef, SndMus[12], AL_GAIN, 0
		invoke alSourcei, SndMus[12], AL_LOOPING, AL_TRUE
		LoadBPS OFFSET SndMus[16],		"assets\sounds\mus5.bps"
		invoke alSourcef, SndMus[16], AL_GAIN, f(0.5)
		LoadBPS OFFSET SndRand[0],		"assets\sounds\rand1.bps"
		LoadBPS OFFSET SndRand[4],		"assets\sounds\rand2.bps"
		LoadBPS OFFSET SndRand[8],		"assets\sounds\rand3.bps"
		LoadBPS OFFSET SndRand[12],		"assets\sounds\rand4.bps"
		LoadBPS OFFSET SndRand[16],		"assets\sounds\rand5.bps"
		LoadBPS OFFSET SndRand[20],		"assets\sounds\rand6.bps"
		LoadBPS OFFSET SndSave,			"assets\sounds\save.bps"
		LoadBPS OFFSET SndScribble,		"assets\sounds\scribble.bps"
		LoadBPS OFFSET SndSiren,		"assets\sounds\siren.bps"
		invoke alSourcef, SndSiren, AL_GAIN, 0
		invoke alSourcei, SndSiren, AL_LOOPING, AL_TRUE
		LoadBPS OFFSET SndSlam,			"assets\sounds\slam.bps"
		LoadBPS OFFSET SndSplash,		"assets\sounds\splash.bps"
		LoadBPS OFFSET SndStep[0],		"assets\sounds\step1.bps"
		LoadBPS OFFSET SndStep[4],		"assets\sounds\step2.bps"
		LoadBPS OFFSET SndStep[8],		"assets\sounds\step3.bps"
		LoadBPS OFFSET SndStep[12],		"assets\sounds\step4.bps"
		LoadBPS OFFSET SndTram,			"assets\sounds\tram.bps"
		invoke alSourcei, SndTram, AL_LOOPING, AL_TRUE
		invoke alSourcef, SndTram, AL_ROLLOFF_FACTOR, f(1.5)
		LoadBPS OFFSET SndTramAnn[0],	"assets\sounds\tramAnn1.bps"
		invoke alSourcef, SndTramAnn[0], AL_ROLLOFF_FACTOR, f(3)
		LoadBPS OFFSET SndTramAnn[4],	"assets\sounds\tramAnn2.bps"
		invoke alSourcef, SndTramAnn[4], AL_ROLLOFF_FACTOR, f(3)
		LoadBPS OFFSET SndTramAnn[8],	"assets\sounds\tramAnn3.bps"
		invoke alSourcef, SndTramAnn[8], AL_ROLLOFF_FACTOR, f(3)
		LoadBPS OFFSET SndTramClose,	"assets\sounds\tramClose.bps"
		invoke alSourcef, SndTramClose, AL_ROLLOFF_FACTOR, f(1.5)
		LoadBPS OFFSET SndTramOpen,		"assets\sounds\tramOpen.bps"
		invoke alSourcef, SndTramOpen, AL_ROLLOFF_FACTOR, f(1.5)
		LoadBPS OFFSET SndVirdya,		"assets\sounds\virdya.bps"
		invoke alSourcef, SndVirdya, AL_GAIN, 0
		invoke alSourcei, SndVirdya, AL_LOOPING, AL_TRUE
		LoadBPS OFFSET SndWBAlarm,		"assets\sounds\wbAlarm.bps"
		invoke alSourcef, SndWBAlarm, AL_ROLLOFF_FACTOR, f(1.5)
		LoadBPS OFFSET SndWBAttack,		"assets\sounds\wbAttack.bps"
		LoadBPS OFFSET SndWBBK,			"assets\sounds\wbbk.bps"
		invoke alSourcei, SndWBBK, AL_LOOPING, AL_TRUE
		invoke alSourcef, SndWBBK, AL_ROLLOFF_FACTOR, f(10)
		LoadBPS OFFSET SndWBIdle[0],	"assets\sounds\wbIdle1.bps"
		invoke alSourcef, SndWBIdle[0], AL_ROLLOFF_FACTOR, f(4)
		LoadBPS OFFSET SndWBIdle[4],	"assets\sounds\wbIdle2.bps"
		invoke alSourcef, SndWBIdle[4], AL_ROLLOFF_FACTOR, f(4)
		LoadBPS OFFSET SndWBStep[0],	"assets\sounds\wbStep1.bps"
		invoke alSourcef, SndWBStep[0], AL_ROLLOFF_FACTOR, f(3)
		LoadBPS OFFSET SndWBStep[4],	"assets\sounds\wbStep2.bps"
		invoke alSourcef, SndWBStep[4], AL_ROLLOFF_FACTOR, f(3)
		LoadBPS OFFSET SndWBStep[8],	"assets\sounds\wbStep3.bps"
		invoke alSourcef, SndWBStep[8], AL_ROLLOFF_FACTOR, f(3)
		LoadBPS OFFSET SndWBStep[12],	"assets\sounds\wbStep4.bps"
		invoke alSourcef, SndWBStep[12], AL_ROLLOFF_FACTOR, f(3)
		LoadBPS OFFSET SndWhisper,		"assets\sounds\whisper.bps"
		invoke alSourcei, SndWhisper, AL_LOOPING, AL_TRUE
		invoke alSourcef, SndWhisper, AL_ROLLOFF_FACTOR, f(2)
		LoadBPS OFFSET SndWmblyk,		"assets\sounds\wmblyk.bps"
		LoadBPS OFFSET SndWmblykB,		"assets\sounds\wmblykB.bps"
		invoke alSourcei, SndWmblykB, AL_LOOPING, AL_TRUE
		invoke alSourcef, SndWmblykB, AL_ROLLOFF_FACTOR, f(4)
		LoadBPS OFFSET SndWmblykStr,	"assets\sounds\wmblykStr.bps"
		LoadBPS OFFSET SndWmblykStrM,	"assets\sounds\wmblykStrM.bps"
		invoke alSourcef, SndWmblykStrM, AL_GAIN, 0
		invoke alSourcei, SndWmblykStrM, AL_LOOPING, AL_TRUE
		print "...done!", 13, 10
	.ELSEIF (LoadState == LOADING_FINISHED)
		; Environment defaults
		bpMEM32 MazeCurFloor,	TexFloor
		bpMEM32 MazeCurRoof,	TexRoof
		bpMEM32 MazeCurWall,	TexWall
		bpMEM32 MazeCurWallMDL, MdlWall
		
		mov Loading, FALSE
		mov LoadState, LOADING_FINISHED
		ret
	.ENDIF
	.IF (LoadState != LOADING_WAIT)
		inc LoadState
	.ENDIF
	ret
LoadResources ENDP

LoadStrings PROC EXPORT FilePath:BPPtr
	LOCAL buffer:BPPtr, dwFileSize:DWORD, strLen:DWORD, realStrLen:DWORD
	LOCAL lf:BPBool, strAddr:BPPtr
	
	print "Loading strings from "
	print FilePath, "...", 9
	
	mov strAddr, OFFSET StrLanguageID
	
	invoke bpLoadFile, FilePath, ADDR dwFileSize
	.IF (!pax)
		ret
	.ENDIF
	mov buffer, pax
	mov pax, dwFileSize
	add pax, buffer
	mov dwFileSize, pax
	
	mov pbx, buffer
	mov strLen, 0
	mov realStrLen, 0
	.WHILE (pbx <= dwFileSize)
		mov lf, FALSE
		.IF (BYTE PTR [pbx] == 13)
			.IF (BYTE PTR [pbx+1] == 10)
				mov lf, TRUE
				inc strLen
				inc pbx
			.ENDIF
		.ELSEIF (BYTE PTR [pbx] == 10) || (pbx == dwFileSize)
			mov lf, TRUE
		.ENDIF
		.IF (lf)
			.IF (!realStrLen)
				inc pbx
				.CONTINUE
			.ENDIF
			mov pcx, realStrLen
			inc pcx
			invoke bpMalloc, bpDefHeap, 0, pcx
			mov pcx, strAddr
			
			mov BPPtr PTR [pcx], pax
			add strAddr, SIZEOF BPPtr
			
			mov pcx, realStrLen
			mov BYTE PTR [pax+pcx], 0
			push pbx
			sub pbx, strLen
			.WHILE (pcx > 0)
				dec pcx
				mov dl, BYTE PTR [pbx+pcx]
				mov BYTE PTR [pax+pcx], dl
			.ENDW
			pop pbx
			mov strLen, 0
			mov realStrLen, 0
			
			.IF (strAddr == OFFSET StrSectionEnd)
				.BREAK
			.ENDIF
		.ELSE
			inc strLen
			inc realStrLen
		.ENDIF
		inc pbx
	.ENDW
	.IF (strAddr != OFFSET StrSectionEnd)
		print "INSUFFICIENT STRINGS IN "
		print FilePath, 13, 10
		mov pbx, strAddr
		.WHILE (pbx < OFFSET StrSectionEnd)
			invoke bpMalloc, bpDefHeap, HEAP_ZERO_MEMORY, 1
			mov BPPtr PTR [pbx], pax
			add pbx, SIZEOF BPPtr
		.ENDW
	.ENDIF
	
	vinvoke StrLength, StrLayerNumber
	sub pax, 3
	add pax, StrLayerNumber
	mov StrLayerNumPtr, pax
	
    invoke bpFree, rv(GetProcessHeap), 0, buffer
	print "...done!", 13, 10
	ret
LoadStrings ENDP

;   Non-terminating manual int to string conversion macro (for settings UI)
IntToStr PROC EXPORT StrA:BPPtr, Val:SDWORD
	LOCAL Val1:DWORD, Ngtv:BYTE
	
	mov Ngtv, 0
	push ebx
	xor ebx, ebx
	bpMEM32 Val1, Val
	.IF (Val < 0)
		inc Ngtv
		mov eax, Val1
		sub eax, Val1
		sub eax, Val1
		mov Val1, eax
	.ENDIF
	.WHILE TRUE
		xor edx, edx
		mov eax, Val1
		mov ecx, 10
		div ecx
		mov Val1, eax
		add dl, 48
		
		push edx
		.IF (ebx)
			mov eax, StrA
			add eax, 1
			invoke RtlMoveMemory, eax, StrA, ebx
		.ENDIF
		pop edx
		mov eax, StrA
		mov BYTE PTR[eax], dl
		inc ebx
		.IF (!Val1)
			.BREAK
		.ENDIF
	.ENDW
	mov BYTE PTR[eax+ebx], 0
	.IF (Ngtv)
		mov eax, StrA
		add eax, 1
		invoke RtlMoveMemory, eax, StrA, ebx
		mov eax, StrA
		mov BYTE PTR[eax], 45
	.ENDIF
	mov eax, ebx
	pop ebx
	ret
IntToStr ENDP

StrLength PROC EXPORT StrPtr:BPPtr
	IFDEF strlen
		invoke strlen, StrPtr
	ELSE
		invoke crt_strlen, StrPtr
	ENDIF
	ret
StrLength ENDP

StrToFl PROC EXPORT StrPtr:BPPtr, FlPtr:BPPtr
	IFDEF atof	; WinInc
		invoke atof, StrPtr;, pax
	ELSE		; MASM
		invoke crt_atof, StrPtr;, pax
	ENDIF
	mov pax, FlPtr
	fstp REAL4 PTR [pax]
	ret
StrToFl ENDP
