ENUM	LOADING_TEXT, \
		LOADING_MODELS, \
		LOADING_TEXTURES, \
		LOADING_SOUNDS, \
		LOADING_FINISHED

.DATA
; ----- FONTS -----
FntKeys		DWORD 255 dup (0)
FntPS		DWORD 255 dup (0)
FntXB		DWORD 255 dup (0)

Loading		BPBool FALSE
LoadState	BPEnum 0

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
MdlKubale			DWORD ?, ?, ?, ?
MdlLamp				DWORD ?
MdlMotrya			DWORD ?, ?, ?, ?
MdlNeqaotor			DWORD ?
MdlOutskirtsBunker	DWORD ?
MdlOutskirtsRoad	DWORD ?
MdlOutskirtsTerrain	DWORD ?
MdlOutskirtsTrees	DWORD ?
MdlPadlock			DWORD ?
MdlPipe				DWORD ?
MdlPlane			DWORD ?
MdlPlaneC			DWORD ?
MdlPlaneH			DWORD ?
MdlPlaneM			DWORD ?
MdlPlaneR			DWORD ?
MdlPlanks			DWORD ?
MdlRubble			DWORD ?
MdlRubbleFacade		DWORD ?
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
MdlWallB			DWORD ?
MdlWallD			DWORD ?
MdlWallH			DWORD ?
MdlWallM			DWORD ?
MdlWallS			DWORD ?
MdlWallT			DWORD ?
MdlWallT2			DWORD ?
MdlWallTR			DWORD ?
MdlWallW			DWORD ?
MdlWbAttack			DWORD ?, ?, ?
MdlWbbk				DWORD ?
MdlWbIdle			DWORD ?, ?
MdlWbWalk			DWORD ?, ?, ?
MdlWires			DWORD ?
MdlWmblykBody		DWORD ?
MdlWmblykBodyG		DWORD ?
MdlWmblykCrawl		DWORD ?, ?
MdlWmblykDead		DWORD ?
MdlWmblykHead		DWORD ?
MdlWmblykStr		DWORD ?, ?, ?
MdlWmblykStrL		DWORD ?, ?, ?
MdlWmblykStrW		DWORD ?, ?, ?
MdlWmblykTram		DWORD ?
MdlWmblykWalk		DWORD ?, ?, ?, ?

ScreenQuad	DWORD ?

; ----- TEXTURES -----
TexBricks		DWORD ?
TexCompass		DWORD ?
TexCompassWorld	DWORD ?
TexConcrete		DWORD ?
TexConcreteRoof	DWORD ?
TexCroa			DWORD ?
TexCursor		DWORD ?
TexDiamond		DWORD ?
TexDirt			DWORD ?
TexDoor			DWORD ?
TexDoorblur		DWORD ?
TexEBD			DWORD ?, ?, ?
TexEBDShadow	DWORD ?
TexFacade		DWORD ?
TexFloor		DWORD ?
TexGamma		DWORD ?
TexGlyph		DWORD 7 DUP(?)
TexGlyphs		DWORD ?
TexHbd			DWORD ?
TexKey			DWORD ?
TexKoluplyk		DWORD ?
TexKubale		DWORD ?
TexKubaleV		DWORD 9 DUP(?)
TexLamp			DWORD ?
TexLight		DWORD ?
TexMap			DWORD ?
TexMetal		DWORD ?
TexMetalFloor	DWORD ?
TexMetalRoof	DWORD ?
TexMotrya		DWORD ?
TexNoise		DWORD ?
TexPaper		DWORD ?
TexPipe			DWORD ?
TexPlanks		DWORD ?
TexPlaster		DWORD ?
TexRain			DWORD ?
TexRoof			DWORD ?
TexSigns		DWORD ?
TexShadow		DWORD ?
TexSky			DWORD ?
TexTaburetka	DWORD ?
TexTileBig		DWORD ?
TexTilefloor	DWORD ?
TexTone			DWORD ?
TexTram			DWORD ?
TexTree			DWORD ?
TexTutorial		DWORD ?
TexTutorialJ	DWORD ?
TexUIArrow		DWORD ?
TexUICircle		DWORD ?
TexVas			DWORD ?
TexVebra		DWORD ?
TexVignette		DWORD ?
TexVignetteRed	DWORD ?

TexVirdyaBlink	DWORD ?
TexVirdyaDown	DWORD ?
TexVirdyaN		DWORD ?
TexVirdyaNeut	DWORD ?
TexVirdyaUp		DWORD ?

TexWall			DWORD ?
TexWB			DWORD ?
TexWBBK			DWORD ?
TexWBBKP		DWORD ?
TexWBBK1		DWORD ?
TexWhitewall	DWORD ?

TexWmblykHappy		DWORD ?
TexWmblykNeutral	DWORD ?
TexWmblykJumpscare	DWORD ?
TexWmblykStr		DWORD ?
TexWmblykL1			DWORD ?
TexWmblykL2			DWORD ?
TexWmblykL3			DWORD ?
TexWmblykW1			DWORD ?
TexWmblykW2			DWORD ?

; ----- SOUNDS -----
SndSectionStart	BYTE ?
SndAlarm		DWORD ?
SndAmb			DWORD ?
SndAmbT			DWORD ?
SndAmbW			DWORD ?, ?, ?, ?
SndCheckpoint	DWORD ?
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
include Strings.inc

.CODE
LoadStrings PROTO :BPPtr

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
		; Load language strings
		vinvoke LoadStrings, OFFSET SettingsMiscLanguage
		
		; ----- FONTS -----
		invoke bpLoadFont, StrLangFontPath, OFFSET bpDefaultFont	; Main
		mov bpTextNL, '#'
		LoadFont "font\input\", OFFSET FntKeys	; Direct mapping to keys/axes
		LoadFont "font\input\ps\", OFFSET FntPS
		LoadFont "font\input\xb\", OFFSET FntXB
	.ELSEIF (LoadState == LOADING_MODELS)
		; ----- MODELS -----
		print "Loading models...", 9
		LoadBPL ADDR MdlBorderFloor, 		"assets\models\borderFloor.bpl"
		LoadBPL ADDR MdlBorderWall, 		"assets\models\borderWall.bpl"
		LoadBPL ADDR MdlCheckFloor, 		"assets\models\checkFloor.bpl"
		LoadBPL ADDR MdlCheckRoof, 			"assets\models\checkRoof.bpl"
		LoadBPL ADDR MdlCheckWalls, 		"assets\models\checkWalls.bpl"
		LoadBPL ADDR MdlCityConcrete, 		"assets\models\cityConcrete.bpl"
		LoadBPL ADDR MdlCityFacade, 		"assets\models\cityFacade.bpl"
		LoadBPL ADDR MdlCityTerrain, 		"assets\models\cityTerrain.bpl"
		LoadBPL ADDR MdlCompassArrow, 		"assets\models\compassArrow.bpl"
		LoadBPL ADDR MdlCompassWorld, 		"assets\models\compassWorld.bpl"
		LoadBPL ADDR MdlCrevice, 			"assets\models\crevice.bpl"
		LoadBPL ADDR MdlCube, 				"assets\models\cube.bpl"
		LoadBPL ADDR MdlDoor, 				"assets\models\door.bpl"
		LoadBPL ADDR MdlDoorFrame, 			"assets\models\doorFrame.bpl"
		LoadBPL ADDR MdlDoorFrameLock, 		"assets\models\doorFrameLock.bpl"
		LoadBPL ADDR MdlDoorwayM, 			"assets\models\doorwayM.bpl"
		LoadBPL ADDR MdlGlyphs, 			"assets\models\glyphs.bpl"
		LoadBPL ADDR MdlHbd, 				"assets\models\hbd.bpl"
		LoadBPL ADDR MdlHbdS, 				"assets\models\hbdS.bpl"
		LoadBPL ADDR MdlKey, 				"assets\models\key.bpl"
		LoadBPL ADDR MdlKoluplykDig[0],		"assets\models\koluplykDig1.bpl"
		LoadBPL ADDR MdlKoluplykDig[4], 	"assets\models\koluplykDig2.bpl"
		LoadBPL ADDR MdlKoluplykDig[8],		"assets\models\koluplykDig3.bpl"
		LoadBPL ADDR MdlKoluplykDig[12],	"assets\models\koluplykDig4.bpl"
		LoadBPL ADDR MdlKoluplykShop[0],	"assets\models\koluplykShop1.bpl"
		LoadBPL ADDR MdlKoluplykShop[4],	"assets\models\koluplykShop2.bpl"
		LoadBPL ADDR MdlKubale[0],			"assets\models\kubale1.bpl"
		LoadBPL ADDR MdlKubale[4],			"assets\models\kubale2.bpl"
		LoadBPL ADDR MdlKubale[8],			"assets\models\kubale3.bpl"
		LoadBPL ADDR MdlKubale[12],			"assets\models\kubale4.bpl"
		LoadBPL ADDR MdlLamp,				"assets\models\lamp.bpl"
		LoadBPL ADDR MdlMotrya[0],			"assets\models\motrya1.bpl"
		LoadBPL ADDR MdlMotrya[4],			"assets\models\motrya2.bpl"
		LoadBPL ADDR MdlMotrya[8],			"assets\models\motrya3.bpl"
		LoadBPL ADDR MdlMotrya[12],			"assets\models\motrya4.bpl"
		LoadBPL ADDR MdlNeqaotor,			"assets\models\neqaotor.bpl"
		LoadBPL ADDR MdlOutskirtsBunker,	"assets\models\outskirtsBunker.bpl"
		LoadBPL ADDR MdlOutskirtsRoad,		"assets\models\outskirtsRoad.bpl"
		LoadBPL ADDR MdlOutskirtsTerrain,	"assets\models\outskirtsTerrain.bpl"
		LoadBPL ADDR MdlOutskirtsTrees,		"assets\models\outskirtsTrees.bpl"
		LoadBPL ADDR MdlPadlock,			"assets\models\padlock.bpl"
		LoadBPL ADDR MdlPipe,				"assets\models\pipe.bpl"
		LoadBPL ADDR MdlPlane,				"assets\models\plane.bpl"
		LoadBPL ADDR MdlPlaneC,				"assets\models\planeC.bpl"
		LoadBPL ADDR MdlPlaneH,				"assets\models\planeH.bpl"
		LoadBPL ADDR MdlPlaneM,				"assets\models\planeM.bpl"
		LoadBPL ADDR MdlPlaneR,				"assets\models\planeR.bpl"
		LoadBPL ADDR MdlPlanks,				"assets\models\planks.bpl"
		LoadBPL ADDR MdlRubble,				"assets\models\rubble.bpl"
		LoadBPL ADDR MdlRubbleFacade,		"assets\models\rubbleFacade.bpl"
		LoadBPL ADDR MdlSigil[0],			"assets\models\sigil1.bpl"
		LoadBPL ADDR MdlSigil[4],			"assets\models\sigil2.bpl"
		LoadBPL ADDR MdlSigns,				"assets\models\signs.bpl"
		LoadBPL ADDR MdlSky,				"assets\models\sky.bpl"
		LoadBPL ADDR MdlStairsM,			"assets\models\stairsM.bpl"
		LoadBPL ADDR MdlTaburetka,			"assets\models\taburetka.bpl"
		LoadBPL ADDR MdlTerrain,			"assets\models\terrain.bpl"
		LoadBPL ADDR MdlTorlagg,			"assets\models\torlagg.bpl"
		LoadBPL ADDR MdlTrack,				"assets\models\track.bpl"
		LoadBPL ADDR MdlTrackTurn,			"assets\models\trackTurn.bpl"
		LoadBPL ADDR MdlTram,				"assets\models\tram.bpl"
		LoadBPL ADDR MdlTramD[0],			"assets\models\tramD1.bpl"
		LoadBPL ADDR MdlTramD[4],			"assets\models\tramD2.bpl"
		LoadBPL ADDR MdlTramD[8],			"assets\models\tramD3.bpl"
		LoadBPL ADDR MdlTramD[12],			"assets\models\tramD4.bpl"
		LoadBPL ADDR MdlTramDG[0],			"assets\models\tramDG1.bpl"
		LoadBPL ADDR MdlTramDG[4],			"assets\models\tramDG2.bpl"
		LoadBPL ADDR MdlTramDG[8],			"assets\models\tramDG3.bpl"
		LoadBPL ADDR MdlTramDG[12],			"assets\models\tramDG4.bpl"
		LoadBPL ADDR MdlTramG,				"assets\models\tramG.bpl"
		LoadBPL ADDR MdlUpFloor,			"assets\models\upFloor.bpl"
		LoadBPL ADDR MdlUpRoof,				"assets\models\upRoof.bpl"
		LoadBPL ADDR MdlUpWalls,			"assets\models\upWalls.bpl"
		LoadBPL ADDR MdlVasT[0],			"assets\models\vasT1.bpl"
		LoadBPL ADDR MdlVasT[4],			"assets\models\vasT2.bpl"
		LoadBPL ADDR MdlVasT[8],			"assets\models\vasT3.bpl"
		LoadBPL ADDR MdlVebraExit[0],		"assets\models\vebraExit1.bpl"
		LoadBPL ADDR MdlVebraExit[4],		"assets\models\vebraExit2.bpl"
		LoadBPL ADDR MdlVebraExit[8],		"assets\models\vebraExit3.bpl"
		LoadBPL ADDR MdlVebraExit[12],		"assets\models\vebraExit4.bpl"
		LoadBPL ADDR MdlVebraExit[16],		"assets\models\vebraExit5.bpl"
		LoadBPL ADDR MdlVebraExit[20],		"assets\models\vebraExit6.bpl"
		LoadBPL ADDR MdlVebraLook[0],		"assets\models\vebraLook1.bpl"
		LoadBPL ADDR MdlVebraLook[4],		"assets\models\vebraLook2.bpl"
		LoadBPL ADDR MdlVirdyaBack[0],		"assets\models\virdyaBack1.bpl"
		LoadBPL ADDR MdlVirdyaBack[4],		"assets\models\virdyaBack2.bpl"
		LoadBPL ADDR MdlVirdyaBack[8],		"assets\models\virdyaBack3.bpl"
		LoadBPL ADDR MdlVirdyaBack[12],		"assets\models\virdyaBack4.bpl"
		LoadBPL ADDR MdlVirdyaBack[16],		"assets\models\virdyaBack5.bpl"
		LoadBPL ADDR MdlVirdyaBack[20],		"assets\models\virdyaBack6.bpl"
		LoadBPL ADDR MdlVirdyaBody,			"assets\models\virdyaBody.bpl"
		LoadBPL ADDR MdlVirdyaH[0],			"assets\models\virdyaH1.bpl"
		LoadBPL ADDR MdlVirdyaH[4],			"assets\models\virdyaH2.bpl"
		LoadBPL ADDR MdlVirdyaHead,			"assets\models\virdyaHead.bpl"
		LoadBPL ADDR MdlVirdyaRest,			"assets\models\virdyaRest.bpl"
		LoadBPL ADDR MdlVirdyaWalk[0],		"assets\models\virdyaWalk1.bpl"
		LoadBPL ADDR MdlVirdyaWalk[4],		"assets\models\virdyaWalk2.bpl"
		LoadBPL ADDR MdlVirdyaWalk[8],		"assets\models\virdyaWalk3.bpl"
		LoadBPL ADDR MdlVirdyaWalk[12],		"assets\models\virdyaWalk4.bpl"
		LoadBPL ADDR MdlVirdyaWalk[16],		"assets\models\virdyaWalk5.bpl"
		LoadBPL ADDR MdlVirdyaWalk[20],		"assets\models\virdyaWalk6.bpl"
		LoadBPL ADDR MdlVirdyaWalk[24],		"assets\models\virdyaWalk7.bpl"
		LoadBPL ADDR MdlVirdyaWalk[28],		"assets\models\virdyaWalk8.bpl"
		LoadBPL ADDR MdlVirdyaWave[0],		"assets\models\virdyaWave1.bpl"
		LoadBPL ADDR MdlVirdyaWave[4],		"assets\models\virdyaWave2.bpl"
		LoadBPL ADDR MdlVirdyaWave[8],		"assets\models\virdyaWave3.bpl"
		LoadBPL ADDR MdlVirdyaWave[12],		"assets\models\virdyaWave4.bpl"
		LoadBPL ADDR MdlVirdyaWave[16],		"assets\models\virdyaWave5.bpl"
		LoadBPL ADDR MdlVirdyaWave[20],		"assets\models\virdyaWave4.bpl"	; Still lazy
		LoadBPL ADDR MdlVirdyaWave[24],		"assets\models\virdyaWave5.bpl"
		LoadBPL ADDR MdlVirdyaWave[28],		"assets\models\virdyaWave4.bpl"
		LoadBPL ADDR MdlVirdyaWave[32],		"assets\models\virdyaWave2.bpl"
		LoadBPL ADDR MdlWall,				"assets\models\wall.bpl"
		LoadBPL ADDR MdlWallB,				"assets\models\wallB.bpl"
		LoadBPL ADDR MdlWallD,				"assets\models\wallD.bpl"
		LoadBPL ADDR MdlWallH,				"assets\models\wallH.bpl"
		LoadBPL ADDR MdlWallM,				"assets\models\wallM.bpl"
		LoadBPL ADDR MdlWallS,				"assets\models\wallS.bpl"
		LoadBPL ADDR MdlWallT,				"assets\models\wallT.bpl"
		LoadBPL ADDR MdlWallT2,				"assets\models\wallT2.bpl"
		LoadBPL ADDR MdlWallTR,				"assets\models\wallTR.bpl"
		LoadBPL ADDR MdlWallW,				"assets\models\wallW.bpl"
		LoadBPL ADDR MdlWbAttack[0],		"assets\models\wbAttack1.bpl"
		LoadBPL ADDR MdlWbAttack[4],		"assets\models\wbAttack2.bpl"
		LoadBPL ADDR MdlWbAttack[8],		"assets\models\wbAttack3.bpl"
		LoadBPL ADDR MdlWbbk,				"assets\models\wbbk.bpl"
		LoadBPL ADDR MdlWbIdle[0],			"assets\models\wbIdle1.bpl"
		LoadBPL ADDR MdlWbIdle[4],			"assets\models\wbIdle2.bpl"
		LoadBPL ADDR MdlWbWalk[0],			"assets\models\wbWalk1.bpl"
		LoadBPL ADDR MdlWbWalk[4],			"assets\models\wbWalk2.bpl"
		LoadBPL ADDR MdlWbWalk[8],			"assets\models\wbWalk3.bpl"
		LoadBPL ADDR MdlWires,				"assets\models\wires.bpl"
		LoadBPL ADDR MdlWmblykBody,			"assets\models\wmblykBody.bpl"
		LoadBPL ADDR MdlWmblykBodyG,		"assets\models\wmblykBodyG.bpl"
		LoadBPL ADDR MdlWmblykCrawl[0],		"assets\models\wmblykCrawl1.bpl"
		LoadBPL ADDR MdlWmblykCrawl[4],		"assets\models\wmblykCrawl2.bpl"
		LoadBPL ADDR MdlWmblykDead,			"assets\models\wmblykDead.bpl"
		LoadBPL ADDR MdlWmblykHead,			"assets\models\wmblykHead.bpl"
		LoadBPL ADDR MdlWmblykStr[0],		"assets\models\wmblykStr0.bpl"
		LoadBPL ADDR MdlWmblykStr[4],		"assets\models\wmblykStr1.bpl"
		LoadBPL ADDR MdlWmblykStr[8],		"assets\models\wmblykStr2.bpl"
		LoadBPL ADDR MdlWmblykStrL[0],		"assets\models\wmblykStrL0.bpl"
		LoadBPL ADDR MdlWmblykStrL[4],		"assets\models\wmblykStrL1.bpl"
		LoadBPL ADDR MdlWmblykStrL[8],		"assets\models\wmblykStrL2.bpl"
		LoadBPL ADDR MdlWmblykStrW[0],		"assets\models\wmblykStrW0.bpl"
		LoadBPL ADDR MdlWmblykStrW[4],		"assets\models\wmblykStrW1.bpl"
		LoadBPL ADDR MdlWmblykStrW[8],		"assets\models\wmblykStrW2.bpl"
		LoadBPL ADDR MdlWmblykTram,			"assets\models\wmblykTram.bpl"
		LoadBPL ADDR MdlWmblykWalk[0],		"assets\models\wmblykWalk1.bpl"
		LoadBPL ADDR MdlWmblykWalk[4],		"assets\models\wmblykWalk2.bpl"
		LoadBPL ADDR MdlWmblykWalk[8],		"assets\models\wmblykWalk3.bpl"
		LoadBPL ADDR MdlWmblykWalk[12],		"assets\models\wmblykWalk4.bpl"

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
		LoadBPT ADDR TexBricks,			"assets\textures\bricks.bpt"
		LoadBPT ADDR TexCompass,		"assets\textures\compass.bpt"
		LoadBPT ADDR TexCompassWorld,	"assets\textures\compassWorld.bpt"
		LoadBPT ADDR TexConcrete,		"assets\textures\concrete.bpt"
		LoadBPT ADDR TexConcreteRoof,	"assets\textures\concreteRoof.bpt"
		LoadBPT ADDR TexCroa,			"assets\textures\croa.bpt"
		LoadBPT ADDR TexCursor,			"assets\textures\cursor.bpt"
		LoadBPT ADDR TexDiamond,		"assets\textures\diamond.bpt"
		LoadBPT ADDR TexDirt,			"assets\textures\dirt.bpt"
		LoadBPT ADDR TexDoor,			"assets\textures\door.bpt"
		LoadBPT ADDR TexDoorblur,		"assets\textures\doorBlur.bpt"
		LoadBPT ADDR TexEBD[0],			"assets\textures\EBD1.bpt"
		LoadBPT ADDR TexEBD[4],			"assets\textures\EBD2.bpt"
		LoadBPT ADDR TexEBD[8],			"assets\textures\EBD3.bpt"
		LoadBPT ADDR TexEBDShadow,		"assets\textures\EBDShadow.bpt"
		LoadBPT ADDR TexFacade,			"assets\textures\facade.bpt"
		LoadBPT ADDR TexFloor,			"assets\textures\floor.bpt"
		LoadBPT ADDR TexGamma,			"assets\textures\gamma.bpt"
		LoadBPT ADDR TexGlyph[0],		"assets\textures\glyph1.bpt"
		LoadBPT ADDR TexGlyph[4],		"assets\textures\glyph2.bpt"
		LoadBPT ADDR TexGlyph[8],		"assets\textures\glyph3.bpt"
		LoadBPT ADDR TexGlyph[12],		"assets\textures\glyph4.bpt"
		LoadBPT ADDR TexGlyph[16],		"assets\textures\glyph5.bpt"
		LoadBPT ADDR TexGlyph[20],		"assets\textures\glyph6.bpt"
		LoadBPT ADDR TexGlyph[24],		"assets\textures\glyph7.bpt"
		LoadBPT ADDR TexHbd,			"assets\textures\hbd.bpt"
		LoadBPT ADDR TexKey,			"assets\textures\key.bpt"
		LoadBPT ADDR TexKoluplyk,		"assets\textures\koluplyk.bpt"
		LoadBPT ADDR TexKubale,			"assets\textures\kubale.bpt"
		LoadBPT ADDR TexKubaleV[0],		"assets\textures\kubaleV1.bpt"
		LoadBPT ADDR TexKubaleV[4],		"assets\textures\kubaleV2.bpt"
		LoadBPT ADDR TexKubaleV[8],		"assets\textures\kubaleV3.bpt"
		LoadBPT ADDR TexKubaleV[12],	"assets\textures\kubaleV4.bpt"
		LoadBPT ADDR TexKubaleV[16],	"assets\textures\kubaleV5.bpt"
		LoadBPT ADDR TexKubaleV[20],	"assets\textures\kubaleV6.bpt"
		LoadBPT ADDR TexKubaleV[24],	"assets\textures\kubaleV7.bpt"
		LoadBPT ADDR TexKubaleV[24],	"assets\textures\kubaleV8.bpt"
		LoadBPT ADDR TexKubaleV[24],	"assets\textures\kubaleV8.bpt"
		LoadBPT ADDR TexKubaleV[28],	"assets\textures\kubaleV9.bpt"
		LoadBPT ADDR TexLamp,			"assets\textures\lamp.bpt"
		LoadBPT ADDR TexLight,			"assets\textures\light.bpt"
		LoadBPT ADDR TexMap,			"assets\textures\map.bpt"
		LoadBPT ADDR TexMetal,			"assets\textures\metal.bpt"
		LoadBPT ADDR TexMetalFloor,		"assets\textures\metalFloor.bpt"
		LoadBPT ADDR TexMetalRoof,		"assets\textures\metalRoof.bpt"
		LoadBPT ADDR TexMotrya,			"assets\textures\motrya.bpt"
		LoadBPT ADDR TexNoise,			"assets\textures\noise.bpt"
		LoadBPT ADDR TexPaper,			"assets\textures\paper.bpt"
		LoadBPT ADDR TexPipe,			"assets\textures\pipe.bpt"
		LoadBPT ADDR TexPlanks,			"assets\textures\planks.bpt"
		LoadBPT ADDR TexPlaster,		"assets\textures\plaster.bpt"
		LoadBPT ADDR TexRain,			"assets\textures\rain.bpt"
		LoadBPT ADDR TexRoof,			"assets\textures\roof.bpt"
		LoadBPT ADDR TexShadow,			"assets\textures\shadow.bpt"
		LoadBPT ADDR TexSigns,			"assets\textures\signs.bpt"
		LoadBPT ADDR TexSky,			"assets\textures\sky.bpt"
		invoke glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR
		invoke glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR
		invoke glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP
		LoadBPT ADDR TexTaburetka,		"assets\textures\taburetka.bpt"
		LoadBPT ADDR TexTileBig,		"assets\textures\tileBig.bpt"
		LoadBPT ADDR TexTilefloor,		"assets\textures\tilefloor.bpt"
		LoadBPT ADDR TexTone,			"assets\textures\tone.bpt"
		LoadBPT ADDR TexTutorial,		"assets\textures\tutorial.bpt"
		LoadBPT ADDR TexTutorialJ,		"assets\textures\tutorialJ.bpt"
		LoadBPT ADDR TexUIArrow,		"assets\textures\uiArrow.bpt"
		LoadBPT ADDR TexUICircle,		"assets\textures\uiCircle.bpt"
		LoadBPT ADDR TexVas,			"assets\textures\vas.bpt"
		LoadBPT ADDR TexVebra,			"assets\textures\vebra.bpt"
		LoadBPT ADDR TexVignette,		"assets\textures\vignette.bpt"
		invoke glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR
		invoke glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR
		LoadBPT ADDR TexVignetteRed,	"assets\textures\vignetteRed.bpt"
		LoadBPT ADDR TexVirdyaBlink,	"assets\textures\virdyaBlink.bpt"
		LoadBPT ADDR TexVirdyaDown,		"assets\textures\virdyaDown.bpt"
		LoadBPT ADDR TexVirdyaN,		"assets\textures\virdyaN.bpt"
		LoadBPT ADDR TexVirdyaNeut,		"assets\textures\virdyaNeut.bpt"
		LoadBPT ADDR TexVirdyaUp,		"assets\textures\virdyaUp.bpt"
		LoadBPT ADDR TexWall,			"assets\textures\wall.bpt"
		LoadBPT ADDR TexWB,				"assets\textures\WB.bpt"
		LoadBPT ADDR TexWBBK,			"assets\textures\WBBK.bpt"
		LoadBPT ADDR TexWBBK1,			"assets\textures\WBBK1.bpt"
		LoadBPT ADDR TexWBBKP,			"assets\textures\WBBKP.bpt"
		LoadBPT ADDR TexWhitewall,		"assets\textures\whitewall.bpt"
		LoadBPT ADDR TexWmblykHappy,	"assets\textures\wmblykHappy.bpt"
		LoadBPT ADDR TexWmblykJumpscare,"assets\textures\wmblykJumpscare.bpt"
		LoadBPT ADDR TexWmblykL1,		"assets\textures\wmblykL1.bpt"
		LoadBPT ADDR TexWmblykL2,		"assets\textures\wmblykL2.bpt"
		LoadBPT ADDR TexWmblykL3,		"assets\textures\wmblykL3.bpt"
		LoadBPT ADDR TexWmblykNeutral,	"assets\textures\wmblykNeutral.bpt"
		LoadBPT ADDR TexWmblykStr,		"assets\textures\wmblykStr.bpt"
		LoadBPT ADDR TexWmblykW1,		"assets\textures\wmblykW1.bpt"
		LoadBPT ADDR TexWmblykW2,		"assets\textures\wmblykW2.bpt"
		print "...done!", 13, 10
	.ELSEIF (LoadState == LOADING_SOUNDS)
		; ----- SOUNDS -----
		print "Loading sounds...", 9
		LoadBPS ADDR SndAlarm,			"assets\sounds\alarm.bps"
		invoke alSourcei, SndAlarm, AL_LOOPING, AL_TRUE
		LoadBPS ADDR SndAmb,			"assets\sounds\amb.bps"
		invoke alSourcei, SndAmb, AL_LOOPING, AL_TRUE
		LoadBPS ADDR SndAmbT,			"assets\sounds\ambT.bps"
		invoke alSourcei, SndAmbT, AL_LOOPING, AL_TRUE
		LoadBPS ADDR SndAmbW[0],		"assets\sounds\ambW1.bps"
		LoadBPS ADDR SndAmbW[4],		"assets\sounds\ambW2.bps"
		LoadBPS ADDR SndAmbW[8],		"assets\sounds\ambW3.bps"
		LoadBPS ADDR SndAmbW[12],		"assets\sounds\ambW4.bps"
		LoadBPS ADDR SndCheckpoint,		"assets\sounds\checkpoint.bps"
		LoadBPS ADDR SndDeath,			"assets\sounds\death.bps"
		LoadBPS ADDR SndDig,			"assets\sounds\dig.bps"
		LoadBPS ADDR SndDistress,		"assets\sounds\distress.bps"
		LoadBPS ADDR SndDoorClose,		"assets\sounds\doorClose.bps"
		LoadBPS ADDR SndDrip,			"assets\sounds\drip.bps"
		invoke alSourcei, SndDrip, AL_LOOPING, AL_TRUE
		invoke alSourcef, SndDrip, AL_ROLLOFF_FACTOR, f(2)
		LoadBPS ADDR SndEBD,			"assets\sounds\ebd.bps"
		invoke alSourcei, SndEBD, AL_LOOPING, AL_TRUE
		invoke alSourcef, SndEBD, AL_ROLLOFF_FACTOR, f(4)
		LoadBPS ADDR SndEBDA,			"assets\sounds\ebdA.bps"
		invoke alSourcei, SndEBDA, AL_LOOPING, AL_TRUE
		LoadBPS ADDR SndExit,			"assets\sounds\exit.bps"
		LoadBPS ADDR SndExit1,			"assets\sounds\exit1.bps"
		LoadBPS ADDR SndExplosion,		"assets\sounds\explosion.bps"
		LoadBPS ADDR SndHbd,			"assets\sounds\hbd.bps"
		invoke alSourcei, SndHbd, AL_LOOPING, AL_TRUE
		invoke alSourcef, SndHbd, AL_ROLLOFF_FACTOR, f(3)
		LoadBPS ADDR SndHbdO,			"assets\sounds\hbdO.bps"
		LoadBPS ADDR SndHurt,			"assets\sounds\hurt.bps"
		LoadBPS ADDR SndImpact,			"assets\sounds\impact.bps"
		LoadBPS ADDR SndIntro,			"assets\sounds\intro.bps"
		LoadBPS ADDR SndKey,			"assets\sounds\key.bps"
		LoadBPS ADDR SndKubale,			"assets\sounds\kubale.bps"
		invoke alSourcef, SndKubale, AL_GAIN, 0
		invoke alSourcei, SndKubale, AL_LOOPING, AL_TRUE
		LoadBPS ADDR SndKubaleAppear,	"assets\sounds\kubaleAppear.bps"
		LoadBPS ADDR SndKubaleV,		"assets\sounds\kubaleV.bps"
		invoke alSourcef, SndKubaleV, AL_GAIN, 0
		invoke alSourcei, SndKubaleV, AL_LOOPING, AL_TRUE
		LoadBPS ADDR SndMistake,		"assets\sounds\mistake.bps"
		LoadBPS ADDR SndMus[0],			"assets\sounds\mus1.bps"
		invoke alSourcef, SndMus[0], AL_GAIN, f(0.5)
		LoadBPS ADDR SndMus[4],			"assets\sounds\mus2.bps"
		invoke alSourcef, SndMus[4], AL_GAIN, f(0.5)
		LoadBPS ADDR SndMus[8],			"assets\sounds\mus3.bps"
		invoke alSourcef, SndMus[8], AL_GAIN, 0
		invoke alSourcei, SndMus[8], AL_LOOPING, AL_TRUE
		LoadBPS ADDR SndMus[12],		"assets\sounds\mus4.bps"
		invoke alSourcef, SndMus[12], AL_GAIN, 0
		invoke alSourcei, SndMus[12], AL_LOOPING, AL_TRUE
		LoadBPS ADDR SndMus[16],		"assets\sounds\mus5.bps"
		invoke alSourcef, SndMus[16], AL_GAIN, f(0.5)
		LoadBPS ADDR SndRand[0],		"assets\sounds\rand1.bps"
		LoadBPS ADDR SndRand[4],		"assets\sounds\rand2.bps"
		LoadBPS ADDR SndRand[8],		"assets\sounds\rand3.bps"
		LoadBPS ADDR SndRand[12],		"assets\sounds\rand4.bps"
		LoadBPS ADDR SndRand[16],		"assets\sounds\rand5.bps"
		LoadBPS ADDR SndRand[20],		"assets\sounds\rand6.bps"
		LoadBPS ADDR SndSave,			"assets\sounds\save.bps"
		LoadBPS ADDR SndScribble,		"assets\sounds\scribble.bps"
		LoadBPS ADDR SndSiren,			"assets\sounds\siren.bps"
		invoke alSourcef, SndSiren, AL_GAIN, 0
		invoke alSourcei, SndSiren, AL_LOOPING, AL_TRUE
		LoadBPS ADDR SndSlam,			"assets\sounds\slam.bps"
		invoke alSource3f, SndSlam, AL_POSITION, f(1), f(1), 0
		LoadBPS ADDR SndSplash,			"assets\sounds\splash.bps"
		LoadBPS ADDR SndStep[0],		"assets\sounds\step1.bps"
		LoadBPS ADDR SndStep[4],		"assets\sounds\step2.bps"
		LoadBPS ADDR SndStep[8],		"assets\sounds\step3.bps"
		LoadBPS ADDR SndStep[12],		"assets\sounds\step4.bps"
		LoadBPS ADDR SndTram,			"assets\sounds\tram.bps"
		invoke alSourcei, SndTram, AL_LOOPING, AL_TRUE
		invoke alSourcef, SndTram, AL_ROLLOFF_FACTOR, f(1.5)
		LoadBPS ADDR SndTramAnn[0],		"assets\sounds\tramAnn1.bps"
		invoke alSourcef, SndTramAnn[0], AL_ROLLOFF_FACTOR, f(3)
		LoadBPS ADDR SndTramAnn[4],		"assets\sounds\tramAnn2.bps"
		invoke alSourcef, SndTramAnn[4], AL_ROLLOFF_FACTOR, f(3)
		LoadBPS ADDR SndTramAnn[8],		"assets\sounds\tramAnn3.bps"
		invoke alSourcef, SndTramAnn[8], AL_ROLLOFF_FACTOR, f(3)
		LoadBPS ADDR SndTramClose,		"assets\sounds\tramClose.bps"
		invoke alSourcef, SndTramClose, AL_ROLLOFF_FACTOR, f(1.5)
		LoadBPS ADDR SndTramOpen,		"assets\sounds\tramOpen.bps"
		invoke alSourcef, SndTramOpen, AL_ROLLOFF_FACTOR, f(1.5)
		LoadBPS ADDR SndVirdya,			"assets\sounds\virdya.bps"
		invoke alSourcef, SndVirdya, AL_GAIN, 0
		invoke alSourcei, SndVirdya, AL_LOOPING, AL_TRUE
		LoadBPS ADDR SndWBAlarm,		"assets\sounds\wbAlarm.bps"
		invoke alSourcef, SndWBAlarm, AL_ROLLOFF_FACTOR, f(1.5)
		LoadBPS ADDR SndWBAttack,		"assets\sounds\wbAttack.bps"
		LoadBPS ADDR SndWBBK,			"assets\sounds\wbbk.bps"
		invoke alSourcei, SndWBBK, AL_LOOPING, AL_TRUE
		invoke alSourcef, SndWBBK, AL_ROLLOFF_FACTOR, f(10)
		LoadBPS ADDR SndWBIdle[0],		"assets\sounds\wbIdle1.bps"
		invoke alSourcef, SndWBIdle[0], AL_ROLLOFF_FACTOR, f(4)
		LoadBPS ADDR SndWBIdle[4],		"assets\sounds\wbIdle2.bps"
		invoke alSourcef, SndWBIdle[4], AL_ROLLOFF_FACTOR, f(4)
		LoadBPS ADDR SndWBStep[0],		"assets\sounds\wbStep1.bps"
		invoke alSourcef, SndWBStep[0], AL_ROLLOFF_FACTOR, f(3)
		LoadBPS ADDR SndWBStep[4],		"assets\sounds\wbStep2.bps"
		invoke alSourcef, SndWBStep[4], AL_ROLLOFF_FACTOR, f(3)
		LoadBPS ADDR SndWBStep[8],		"assets\sounds\wbStep3.bps"
		invoke alSourcef, SndWBStep[8], AL_ROLLOFF_FACTOR, f(3)
		LoadBPS ADDR SndWBStep[12],		"assets\sounds\wbStep4.bps"
		invoke alSourcef, SndWBStep[12], AL_ROLLOFF_FACTOR, f(3)
		LoadBPS ADDR SndWhisper,		"assets\sounds\whisper.bps"
		invoke alSourcei, SndWhisper, AL_LOOPING, AL_TRUE
		invoke alSourcef, SndWhisper, AL_ROLLOFF_FACTOR, f(2)
		LoadBPS ADDR SndWmblyk,			"assets\sounds\wmblyk.bps"
		LoadBPS ADDR SndWmblykB,		"assets\sounds\wmblykB.bps"
		invoke alSourcei, SndWmblykB, AL_LOOPING, AL_TRUE
		invoke alSourcef, SndWmblykB, AL_ROLLOFF_FACTOR, f(4)
		LoadBPS ADDR SndWmblykStr,		"assets\sounds\wmblykStr.bps"
		LoadBPS ADDR SndWmblykStrM,		"assets\sounds\wmblykStrM.bps"
		invoke alSourcef, SndWmblykStrM, AL_GAIN, 0
		invoke alSourcei, SndWmblykStrM, AL_LOOPING, AL_TRUE
		print "...done!", 13, 10
	.ELSEIF (LoadState == LOADING_FINISHED)
		bpMEM32 MazeCurFloor,	TexFloor
		bpMEM32 MazeCurRoof,	TexRoof
		bpMEM32 MazeCurWall,	TexWall
		bpMEM32 MazeCurWallMDL, MdlWall
		
		mov Loading, FALSE
		mov LoadState, LOADING_FINISHED
		ret
	.ENDIF
	inc LoadState
	ret
LoadResources ENDP

LoadStrings PROC EXPORT FilePath:BPPtr
	LOCAL buffer:BPPtr, dwFileSize:DWORD, strLen:DWORD, realStrLen:DWORD
	LOCAL lf:BPBool, strAddr:BPPtr
	
	print "Loading strings from "
	print FilePath, 13, 10
	
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
			
			pushad
			print str$(strAddr), 13, 10
			popad
			
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
			pushad
			print pax
			print " ", 13, 10
			popad
			
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
	
    invoke bpFree, rv(GetProcessHeap), 0, buffer
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

Vector32DPop MACRO A:REQ
	pop A.X
	pop A.Z
ENDM

Vector32DPush MACRO A:REQ
	push A.Z
	push A.X
ENDM

Vector32DAdd PROC EXPORT A:BPPtr, B:BPPtr
	mov pax, A
	mov pcx, B
	fld REAL4 PTR [pax]
	fadd REAL4 PTR [pcx]
	fstp REAL4 PTR [pax]
	fld REAL4 PTR [pax+8]
	fadd REAL4 PTR [pcx+8]
	fstp REAL4 PTR [pax+8]
	ret
Vector32DAdd ENDP

Vector32DAngle PROC EXPORT From:BPPtr, To:BPPtr
	LOCAL Val:REAL4
	
	mov pax, From
	mov pcx, To
	
	fld REAL4 PTR [pcx]
	fsub REAL4 PTR [pax]
	fld REAL4 PTR [pcx+8]
	fsub REAL4 PTR [pax+8]
	fpatan
	fstp Val
	
	mov eax, Val
	ret
Vector32DAngle ENDP

Vector32DCopy PROC EXPORT To:BPPtr, From:BPPtr
	mov pax, From
	push REAL4 PTR [pax]
	push REAL4 PTR [pax+8]
	mov pax, To
	pop REAL4 PTR [pax+8]
	pop REAL4 PTR [pax]
	ret
Vector32DCopy ENDP

Vector32DDistanceSqr PROC EXPORT A:BPPtr, B:BPPtr
	mov pax, A
	mov pcx, B
	fld REAL4 PTR [pcx]
	fsub REAL4 PTR [pax]
	fmul st, st
	fld REAL4 PTR [pcx+8]
	fsub REAL4 PTR [pax+8]
	fmul st, st
	fadd
	;sub esp, 4
	;fstp REAL4 PTR [esp]
	;pop eax
	ret
Vector32DDistanceSqr ENDP

Vector32DF PROC EXPORT A:BPPtr
	mov pax, A
	
	fild REAL4 PTR [pax]
	fstp REAL4 PTR [pax]
	fild REAL4 PTR [pax+8]
	fstp REAL4 PTR [pax+8]
	ret
Vector32DF ENDP

Vector32DLerp PROC EXPORT A:BPPtr, B:BPPtr, T:REAL4
	mov pax, A
	mov pcx, B
	
	fld REAL4 PTR [pcx]
	fsub REAL4 PTR [pax]
	fmul T
	fadd REAL4 PTR [pax]
	fstp REAL4 PTR [pax]
	
	fld REAL4 PTR [pcx+8]
	fsub REAL4 PTR [pax+8]
	fmul T
	fadd REAL4 PTR [pax+8]
	fstp REAL4 PTR [pax+8]
	ret
Vector32DLerp ENDP

Vector32DMulF PROC EXPORT A:BPPtr, B:REAL4
	mov pax, A
	fld REAL4 PTR [pax]
	fmul B
	fstp REAL4 PTR [pax]
	fld REAL4 PTR [pax+8]
	fmul B
	fstp REAL4 PTR [pax+8]
	ret
Vector32DMulF ENDP

Vector32DSet PROC EXPORT A:BPPtr, X:REAL4, Z:REAL4
	mov pax, A
	push X
	pop REAL4 PTR [pax]
	push Z
	pop REAL4 PTR [pax+8]
	ret
Vector32DSet ENDP

Vector32DSub PROC EXPORT A:BPPtr, B:BPPtr
	mov pax, A
	mov pcx, B
	fld REAL4 PTR [pax]
	fsub REAL4 PTR [pcx]
	fstp REAL4 PTR [pax]
	fld REAL4 PTR [pax+8]
	fsub REAL4 PTR [pcx+8]
	fstp REAL4 PTR [pax+8]
	ret
Vector32DSub ENDP
