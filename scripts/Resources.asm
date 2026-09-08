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
ANIM_INTERPOLATION	EQU BP_INTERPOLATE_LINEAR_S 
AnimCamEnter		BPAnimTrack <>
AnimCamExit			BPAnimTrack <>
AnimCamWalk			BPAnimTrack <>
AnimHBDBlink		BPAnimTrack <>
AnimKoluplykDig		BPAnimTrack <>	
AnimKoluplykShop	BPAnimTrack <>	
AnimKubaleMove		BPAnimTrack <>	
AnimMotryaIdle		BPAnimTrack <>
AnimMotryaLook		BPAnimTrack <>
AnimMotryaSave		BPAnimTrack <>
AnimMotryaSit		BPAnimTrack <>
AnimPlrCrouch		BPAnimTrack <>
AnimPlrCrouchWalk	BPAnimTrack <>
AnimPlrDead			BPAnimTrack <>
AnimPlrIdle			BPAnimTrack <>
AnimPlrStretch		BPAnimTrack <>
AnimPlrWalk			BPAnimTrack <>
AnimVasFloat		BPAnimTrack <>
AnimVebraGo			BPAnimTrack <>
AnimVebraSit		BPAnimTrack <>
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

StrDeadL		DB 85, 79, 103, 46, 46, 93, 100, 83, 96, 60, 0
StrTipL			DB 90, 93, 90, 60, 46, 90, 91, 79, 93, 60, 0

.DATA?

; ----- MODELS -----
MdlArchRect			DWORD ?
MdlArchRound		DWORD ?
MdlArchWood			DWORD ?
MdlBorderFloor		DWORD ?
MdlBorderWall		DWORD ?
MdlButton			DWORD ?
MdlCheckFloor		DWORD ?
MdlCheckRails		DWORD ?
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
MdlDoorLift			DWORD ?
MdlDoorwayM			DWORD ?
MdlFshnada			DWORD ?
MdlGlyphs			DWORD ?
MdlKey				DWORD ?
MdlLamp				DWORD ?
MdlLightPost		DWORD ?
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
MdlPlaneG			DWORD ?
MdlPlaneR			DWORD ?
MdlPlaneRBroken		DWORD ?
MdlPlanks			DWORD ?
MdlPlrAcc			DWORD ?
MdlPlrScarfStatic	DWORD ?
MdlPodiumFloor		DWORD ?
MdlPodiumTiles		DWORD ?
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
MdlVasPlane			DWORD ?
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
MdlWallHedge		DWORD ?
MdlWallSlant		DWORD ?
MdlWallSlit			DWORD ?
MdlWallTrench		DWORD ?
MdlWallTunnel		DWORD ?
MdlWallWainscot		DWORD ?
MdlWbAttack			DWORD ?, ?, ?
MdlWbbk				DWORD ?
MdlWbIdle			DWORD ?, ?
MdlWbWalk			DWORD ?, ?, ?
MdlWindow			DWORD ?
MdlWires			DWORD ?
MdlWmblykBody		DWORD ?
MdlWmblykBodyG		DWORD ?
MdlWmblykHead		DWORD ?

MeshHBD				BPMesh?
MeshKoluplyk		BPMesh?
MeshKubale			BPMesh?
MeshMotrya			BPMesh?
MeshPlr				BPMesh?
MeshPlrScarf		BPMesh?	; Non-volatile
MeshVas				BPMesh?
MeshVebra			BPMesh?
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
TexDoorLift			DWORD ?
TexDugGlyph			DWORD ?
TexDust				DWORD ?
TexEBD				DWORD ?, ?, ?
TexEBDShadow		DWORD ?
TexFacade			DWORD ?
TexFloor			DWORD ?
TexFloorLinoleum	DWORD ?
TexFloorParquet		DWORD ?
TexFshnada			DWORD ?
TexGamma			DWORD ?
TexGlyph			DWORD 7 DUP(?)
TexGlyphs			DWORD ?
TexHBD				DWORD ?
TexHedge			DWORD ?
TexIcon				DWORD ?
TexKey				DWORD ?
TexKoluplyk			DWORD ?
TexKubale			DWORD ?
TexKubaleV			DWORD 9 DUP(?)
TexLamp				DWORD ?
TexLight			DWORD ?
TexLightPost		DWORD ?
TexLoad				DWORD ?, ?, ?
TexLogo				DWORD ?, ?
TexMap				DWORD ?
TexMetal			DWORD ?
TexMetalFloor		DWORD ?
TexMetalRoof		DWORD ?
TexMotrya			DWORD ?
TexMud				DWORD ?
TexMudDug			DWORD ?
TexNoise			DWORD ?
TexPaper			DWORD ?
TexPipe				DWORD ?
TexPlanks			DWORD ?
TexPlaster			DWORD ?

TexPlrBlink			DWORD ?
TexPlrBody			DWORD ?
TexPlrDead			DWORD ?
TexPlrHead			DWORD ?
; Player face customization comes as Neutral, Look Left, Look Right
TexPlrFace1			DWORD ?, ?, ?, ?
TexPlrFace2			DWORD ?, ?, ?, ?
TexPlrFace3			DWORD ?, ?, ?, ?
TexPlrFace4			DWORD ?, ?, ?, ?
TexPlrFace5			DWORD ?, ?, ?, ?
TexPlrFace6			DWORD ?, ?, ?, ?
TexPlrWounded		DWORD ?

TexRain				DWORD ?
TexRaindrop			DWORD ?
TexRainsplash		DWORD ?
TexRoof				DWORD ?
TexRustPanel		DWORD ?
TexSigns			DWORD ?
TexShadow			DWORD ?
TexSheet			DWORD ?
TexSky				DWORD ?
TexSmoke			DWORD ?
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
TexVasPlane			DWORD ?
TexVebra			DWORD ?
TexVignette			DWORD ?
TexVignetteRed		DWORD ?

TexVirdyaBlink		DWORD ?
TexVirdyaDown		DWORD ?
TexVirdyaN			DWORD ?
TexVirdyaNeut		DWORD ?
TexVirdyaUp			DWORD ?

TexWalkway			DWORD ?
TexWalkwaySmall		DWORD ?
TexWall				DWORD ?
TexWallpaper		DWORD ?
TexWallPainted		DWORD ?
TexWB				DWORD ?
TexWBBK				DWORD ?
TexWBBKP			DWORD ?
TexWBBK1			DWORD ?
TexWhitewall		DWORD ?

TexWmblykHappy		DWORD ?
TexWmblykL			DWORD ?
TexWmblykNeutral	DWORD ?
TexWmblykJumpscare	DWORD ?
TexWmblykStr		DWORD ?, ?, ?, ?, ?, ?, ?
TexWmblykWait		DWORD ?, ?, ?

; ----- SOUNDS -----
SndSectionStart	BYTE ?

SndAlarm		DWORD ?
SndAmbHeavy		DWORD ?, ?, ?
SndAmbPlain		DWORD ?, ?, ?
SndAmbW			DWORD ?, ?, ?, ?
SndBreak		DWORD ?
SndCheckpoint	DWORD ?
SndCreak		DWORD ?
SndCrumble		DWORD ?
SndDeath		DWORD ?
SndDig			DWORD ?
SndDistress		DWORD ?
SndDoorClose	DWORD ?
SndEBD			DWORD ?
SndEBDA			DWORD ?
SndElevator		DWORD ?
SndExit			DWORD ?
SndExit1		DWORD ?
SndExit2		DWORD ?
SndExplosion	DWORD ?
SndHBD			DWORD ?
SndHBDO			DWORD ?
SndHurt			DWORD ?
SndImpact		DWORD ?
SndIntro		DWORD ?
SndKey			DWORD ?
SndKeyJape		DWORD ?
SndKubale		DWORD ?
SndKubaleAppear	DWORD ?
SndKubaleV		DWORD ?
SndMistake		DWORD ?
SndRain			DWORD ?
SndRand			DWORD ?, ?, ?, ?, ?, ?, ?, ?, ?
SndSave			DWORD ?
SndScribble		DWORD ?
SndSiren		DWORD ?
SndSlam			DWORD ?
SndSplash		DWORD ?
SndStep			DWORD ?, ?, ?, ?
SndStepDirt		DWORD ?, ?, ?, ?
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
SndWmblyk		DWORD ?
SndWmblykB		DWORD ?
SndWmblykSpin	DWORD ?
SndWmblykStr	DWORD ?
SndWmblykStrM	DWORD ?


SndAmb			DWORD ?, ?, ?
SndAmbT			DWORD ?
SndMus			DWORD ?, ?, ?, ?, ?, ?
SndOver			DWORD ?
SndSurvive		DWORD ?

SndSectionEnd	BYTE ?

.DATA
SndGain	REAL4 (OFFSET SndSectionEnd - (OFFSET SndSectionStart+1))/4 DUP (1.0)

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
	LOCAL pVal:BPPtr
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
		
		LoadBPA OFFSET AnimHBDBlink,		"assets\anim\hbdBlink.bpa"
		
		LoadBPA OFFSET AnimKoluplykDig,		"assets\anim\koluplykDig.bpa"
		LoadBPA OFFSET AnimKoluplykShop,	"assets\anim\koluplykShop.bpa"
		mov AnimKoluplykShop.Looping, TRUE
		
		LoadBPA OFFSET AnimKubaleMove,		"assets\anim\kubaleMove.bpa"
		mov AnimKubaleMove.Looping, TRUE
		
		LoadBPA OFFSET AnimMotryaIdle,		"assets\anim\motryaIdle.bpa"
		mov AnimMotryaIdle.Looping, TRUE
		LoadBPA OFFSET AnimMotryaLook,		"assets\anim\motryaLook.bpa"
		mov AnimMotryaLook.Looping, TRUE
		LoadBPA OFFSET AnimMotryaSave,		"assets\anim\motryaSave.bpa"
		LoadBPA OFFSET AnimMotryaSit,		"assets\anim\motryaSit.bpa"
		mov AnimMotryaSit.Looping, TRUE
		
		LoadBPA OFFSET AnimPlrCrouch,		"assets\anim\plrCrouch.bpa"
		mov AnimPlrCrouch.Looping, TRUE
		LoadBPA OFFSET AnimPlrCrouchWalk,	"assets\anim\plrCrouchWalk.bpa"
		mov AnimPlrCrouchWalk.Looping, TRUE
		LoadBPA OFFSET AnimPlrDead,			"assets\anim\plrDead.bpa"
		LoadBPA OFFSET AnimPlrIdle,			"assets\anim\plrIdle.bpa"
		mov AnimPlrIdle.Looping, TRUE
		LoadBPA OFFSET AnimPlrStretch,		"assets\anim\plrStretch.bpa"
		LoadBPA OFFSET AnimPlrWalk,			"assets\anim\plrWalk.bpa"
		mov AnimPlrWalk.Looping, TRUE
		
		LoadBPA OFFSET AnimVasFloat,	"assets\anim\vasFloat.bpa"
		mov AnimVasFloat.Looping, TRUE
		
		LoadBPA OFFSET AnimVebraGo,		"assets\anim\vebraGo.bpa"
		LoadBPA OFFSET AnimVebraSit,	"assets\anim\vebraSit.bpa"
		
		LoadBPA OFFSET AnimWmblykCrawl,		"assets\anim\wmblykCrawl.bpa"
		mov AnimWmblykCrawl.Looping, TRUE
		LoadBPA OFFSET AnimWmblykDead,		"assets\anim\wmblykDead.bpa"
		mov AnimWmblykDead.Looping, TRUE
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
		LoadBPL OFFSET MdlArchRect, 		"assets\models\archRect.bpl"
		LoadBPL OFFSET MdlArchRound, 		"assets\models\archRound.bpl"
		LoadBPL OFFSET MdlArchWood, 		"assets\models\archWood.bpl"
		LoadBPL OFFSET MdlBorderFloor, 		"assets\models\borderFloor.bpl"
		LoadBPL OFFSET MdlBorderWall, 		"assets\models\borderWall.bpl"
		LoadBPL OFFSET MdlButton, 			"assets\models\button.bpl"
		LoadBPL OFFSET MdlCheckFloor, 		"assets\models\checkFloor.bpl"
		LoadBPL OFFSET MdlCheckRails, 		"assets\models\checkRails.bpl"
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
		LoadBPL OFFSET MdlDoorLift, 		"assets\models\doorLift.bpl"
		LoadBPL OFFSET MdlDoorwayM, 		"assets\models\doorwayM.bpl"
		LoadBPL OFFSET MdlFshnada, 			"assets\models\fshnada.bpl"
		LoadBPL OFFSET MdlGlyphs, 			"assets\models\glyphs.bpl"
		LoadBPL OFFSET MdlKey, 				"assets\models\key.bpl"
		LoadBPL OFFSET MdlLamp,				"assets\models\lamp.bpl"
		LoadBPL OFFSET MdlLightPost,		"assets\models\lightPost.bpl"
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
		LoadBPL OFFSET MdlPlaneG,			"assets\models\planeG.bpl"
		LoadBPL OFFSET MdlPlaneR,			"assets\models\planeR.bpl"
		LoadBPL OFFSET MdlPlaneRBroken,		"assets\models\planeRBroken.bpl"
		LoadBPL OFFSET MdlPlanks,			"assets\models\planks.bpl"
		LoadBPL OFFSET MdlPlrAcc,			"assets\models\plrAcc.bpl"
		LoadBPL OFFSET MdlPlrScarfStatic,	"assets\models\plrScarfStatic.bpl"
		LoadBPL OFFSET MdlPodiumFloor,		"assets\models\podiumFloor.bpl"
		LoadBPL OFFSET MdlPodiumTiles,		"assets\models\podiumTiles.bpl"
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
		LoadBPL OFFSET MdlVasPlane,			"assets\models\vasPlane.bpl"
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
		LoadBPL OFFSET MdlWallHedge,		"assets\models\wallHedge.bpl"
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
		LoadBPL OFFSET MdlWindow,			"assets\models\window.bpl"
		LoadBPL OFFSET MdlWires,			"assets\models\wires.bpl"
		LoadBPL OFFSET MdlWmblykBody,		"assets\models\wmblykBody.bpl"
		LoadBPL OFFSET MdlWmblykBodyG,		"assets\models\wmblykBodyG.bpl"
		LoadBPL OFFSET MdlWmblykHead,		"assets\models\wmblykHead.bpl"
		
		LoadBPM OFFSET MeshHBD,				"assets\models\hbd.bpm"
		LoadBPM OFFSET MeshKoluplyk,		"assets\models\koluplyk.bpm"
		LoadBPM OFFSET MeshKubale,			"assets\models\kubale.bpm"
		LoadBPM OFFSET MeshMotrya,			"assets\models\motrya.bpm"
		LoadBPM OFFSET MeshPlrScarf,		"assets\models\plrScarf.bpm"
		LoadBPM OFFSET MeshVas,				"assets\models\vas.bpm"
		LoadBPM OFFSET MeshVebra,			"assets\models\vebra.bpm"
		LoadBPM OFFSET MeshWmblyk,			"assets\models\wmblyk.bpm"
		
		; Load separate player models
		push pbx
		xor pbx, pbx
		.WHILE (pbx < NET_MAX_PLAYERS)
			mov pax, pbx
			mov pcx, SIZEOF BPMesh
			mul pcx
			mov pVal, pax
			lea pax, NetPlayersMesh[pax]
			push pax
			LoadBPM pax, "assets\models\plr.bpm"
			
			mov pax, pbx
			mov pcx, SIZEOF BPAnimPlayer
			mul pcx
			mov NetPlayersAnim[pax].FrameType, BPA_FRAME_VERTEX
			pop NetPlayersAnim[pax].Mesh
			
			invoke bpMalloc, bpDefHeap, 0, MeshPlrScarf.V3Size
			mov pcx, pbx
			shl pcx, BPPtrShift
			push pcx
			mov NetPlayersScarf[pcx], pax
			invoke RtlMoveMemory, pax, MeshPlrScarf.Vertices,MeshPlrScarf.V3Size
			
			invoke bpMalloc, bpDefHeap, HEAP_ZERO_MEMORY, MeshPlrScarf.V3Size
			pop pcx
			mov NetPlayersScVel[pcx], pax
			
			inc pbx
		.ENDW
		
		; Get the vertex offset to which attach the head
		xor pbx, pbx
		mov pax, NetPlayersMesh[0].Vertices
		.WHILE (pbx < NetPlayersMesh[0].V3Size)
			.IF (REAL4 PTR [pax+pbx+4] == FLT_1) && \
			((REAL4 PTR [pax+pbx] == 0) || (REAL4 PTR [pax+pbx] == FLT_NEG))
				mov MeshPlrHeadPtr, pbx
				print "Found anchor point vertex", 13, 10
				.BREAK
			.ENDIF
			add pbx, SIZEOF Vector3
		.ENDW
		pop pbx

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
		LoadBPT OFFSET TexDoorLift,		"assets\textures\doorLift.bpt"
		LoadBPT OFFSET TexDugGlyph,		"assets\textures\dugGlyph.bpt"
		LoadBPT OFFSET TexDust,			"assets\textures\dust.bpt"
		LoadBPT OFFSET TexEBD[0],		"assets\textures\EBD1.bpt"
		LoadBPT OFFSET TexEBD[4],		"assets\textures\EBD2.bpt"
		LoadBPT OFFSET TexEBD[8],		"assets\textures\EBD3.bpt"
		LoadBPT OFFSET TexEBDShadow,	"assets\textures\EBDShadow.bpt"
		LoadBPT OFFSET TexFacade,		"assets\textures\facade.bpt"
		LoadBPT OFFSET TexFloor,		"assets\textures\floor.bpt"
		LoadBPT OFFSET TexFloorLinoleum,"assets\textures\floorLinoleum.bpt"
		LoadBPT OFFSET TexFloorParquet,	"assets\textures\floorParquet.bpt"
		LoadBPT OFFSET TexFshnada,		"assets\textures\fshnada.bpt"
		LoadBPT OFFSET TexGamma,		"assets\textures\gamma.bpt"
		mov bpTextureClamp, TRUE
		LoadBPT OFFSET TexGlyph[0],		"assets\textures\glyph1.bpt"
		LoadBPT OFFSET TexGlyph[4],		"assets\textures\glyph2.bpt"
		LoadBPT OFFSET TexGlyph[8],		"assets\textures\glyph3.bpt"
		LoadBPT OFFSET TexGlyph[12],	"assets\textures\glyph4.bpt"
		LoadBPT OFFSET TexGlyph[16],	"assets\textures\glyph5.bpt"
		LoadBPT OFFSET TexGlyph[20],	"assets\textures\glyph6.bpt"
		LoadBPT OFFSET TexGlyph[24],	"assets\textures\glyph7.bpt"
		mov bpTextureClamp, FALSE
		LoadBPT OFFSET TexGlyphs,		"assets\textures\glyphs.bpt"
		LoadBPT OFFSET TexHBD,			"assets\textures\hbd.bpt"
		LoadBPT OFFSET TexHedge,		"assets\textures\hedge.bpt"
		LoadBPT OFFSET TexIcon,			"assets\textures\icon.bpt"
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
		mov bpTextureFiltering, TRUE
		LoadBPT OFFSET TexLight,		"assets\textures\light.bpt"
		mov bpTextureFiltering, FALSE
		LoadBPT OFFSET TexLightPost,	"assets\textures\lightPost.bpt"
		LoadBPT OFFSET TexLoad[0],		"assets\textures\loadKubale.bpt"
		LoadBPT OFFSET TexLoad[4],		"assets\textures\loadVebra.bpt"
		LoadBPT OFFSET TexLoad[8],		"assets\textures\loadWmblyk.bpt"
		LoadBPT OFFSET TexLogo[0],		"assets\textures\logo1.bpt"
		LoadBPT OFFSET TexLogo[4],		"assets\textures\logo2.bpt"
		LoadBPT OFFSET TexMap,			"assets\textures\map.bpt"
		LoadBPT OFFSET TexMetal,		"assets\textures\metal.bpt"
		LoadBPT OFFSET TexMetalFloor,	"assets\textures\metalFloor.bpt"
		LoadBPT OFFSET TexMetalRoof,	"assets\textures\metalRoof.bpt"
		LoadBPT OFFSET TexMotrya,		"assets\textures\motrya.bpt"
		LoadBPT OFFSET TexMud,			"assets\textures\mud.bpt"
		LoadBPT OFFSET TexMudDug,		"assets\textures\mudDug.bpt"
		LoadBPT OFFSET TexNoise,		"assets\textures\noise.bpt"
		LoadBPT OFFSET TexPaper,		"assets\textures\paper.bpt"
		LoadBPT OFFSET TexPipe,			"assets\textures\pipe.bpt"
		LoadBPT OFFSET TexPlanks,		"assets\textures\planks.bpt"
		LoadBPT OFFSET TexPlaster,		"assets\textures\plaster.bpt"
		LoadBPT OFFSET TexPlrBody,		"assets\textures\plrBody.bpt"
		LoadBPT OFFSET TexPlrBlink,		"assets\textures\plrBlink.bpt"
		LoadBPT OFFSET TexPlrDead,		"assets\textures\plrDead.bpt"
		LoadBPT OFFSET TexPlrHead,		"assets\textures\plrHead.bpt"
		LoadBPT OFFSET TexPlrFace1[0],	"assets\textures\plrNeut.bpt"
		LoadBPT OFFSET TexPlrFace1[4],	"assets\textures\plrLeft.bpt"
		LoadBPT OFFSET TexPlrFace1[8],	"assets\textures\plrRight.bpt"
		LoadBPT OFFSET TexPlrFace1[12],	"assets\textures\plrSquish.bpt"
		LoadBPT OFFSET TexPlrFace2[0],	"assets\textures\plrTNeut.bpt"
		LoadBPT OFFSET TexPlrFace2[4],	"assets\textures\plrTLeft.bpt"
		LoadBPT OFFSET TexPlrFace2[8],	"assets\textures\plrTRight.bpt"
		LoadBPT OFFSET TexPlrFace2[12],	"assets\textures\plrTSquish.bpt"
		LoadBPT OFFSET TexPlrFace3[0],	"assets\textures\plrCNeut.bpt"
		LoadBPT OFFSET TexPlrFace3[4],	"assets\textures\plrCLeft.bpt"
		LoadBPT OFFSET TexPlrFace3[8],	"assets\textures\plrCRight.bpt"
		LoadBPT OFFSET TexPlrFace3[12],	"assets\textures\plrCSquish.bpt"
		LoadBPT OFFSET TexPlrFace4[0],	"assets\textures\plrNNeut.bpt"
		LoadBPT OFFSET TexPlrFace4[4],	"assets\textures\plrNLeft.bpt"
		LoadBPT OFFSET TexPlrFace4[8],	"assets\textures\plrNRight.bpt"
		LoadBPT OFFSET TexPlrFace4[12],	"assets\textures\plrNSquish.bpt"	
		LoadBPT OFFSET TexPlrFace5[0],	"assets\textures\plrFNeut.bpt"
		LoadBPT OFFSET TexPlrFace5[4],	"assets\textures\plrFLeft.bpt"
		LoadBPT OFFSET TexPlrFace5[8],	"assets\textures\plrFRight.bpt"
		LoadBPT OFFSET TexPlrFace5[12],	"assets\textures\plrFSquish.bpt"
		LoadBPT OFFSET TexPlrFace6[0],	"assets\textures\plrRNeut.bpt"
		LoadBPT OFFSET TexPlrFace6[4],	"assets\textures\plrRLeft.bpt"
		LoadBPT OFFSET TexPlrFace6[8],	"assets\textures\plrRRight.bpt"
		LoadBPT OFFSET TexPlrFace6[12],	"assets\textures\plrRSquish.bpt"
		LoadBPT OFFSET TexPlrWounded,	"assets\textures\plrWounded.bpt"
		LoadBPT OFFSET TexRain,			"assets\textures\rain.bpt"
		;mov bpTextureFiltering, TRUE
		LoadBPT OFFSET TexRaindrop,		"assets\textures\raindrop.bpt"
		LoadBPT OFFSET TexRainsplash,	"assets\textures\rainsplash.bpt"
		;mov bpTextureFiltering, FALSE
		LoadBPT OFFSET TexRoof,			"assets\textures\roof.bpt"
		LoadBPT OFFSET TexRustPanel,	"assets\textures\rustPanel.bpt"
		LoadBPT OFFSET TexShadow,		"assets\textures\shadow.bpt"
		LoadBPT OFFSET TexSheet,		"assets\textures\sheet.bpt"
		LoadBPT OFFSET TexSigns,		"assets\textures\signs.bpt"
		mov bpTextureFiltering, TRUE
		LoadBPT OFFSET TexSky,			"assets\textures\sky.bpt"
		mov bpTextureFiltering, FALSE
		invoke glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP
		LoadBPT OFFSET TexSmoke,		"assets\textures\smoke.bpt"
		LoadBPT OFFSET TexTaburetka,	"assets\textures\taburetka.bpt"
		LoadBPT OFFSET TexTileBig,		"assets\textures\tileBig.bpt"
		LoadBPT OFFSET TexTilefloor,	"assets\textures\tilefloor.bpt"
		mov bpTextureClamp, TRUE
		LoadBPT OFFSET TexTone,			"assets\textures\tone.bpt"
		mov bpTextureClamp, FALSE
		LoadBPT OFFSET TexTree,			"assets\textures\tree.bpt"
		LoadBPT OFFSET TexTutorial,		"assets\textures\tutorial.bpt"
		LoadBPT OFFSET TexTutorialJ,	"assets\textures\tutorialJ.bpt"
		LoadBPT OFFSET TexUIArrow,		"assets\textures\uiArrow.bpt"
		LoadBPT OFFSET TexUICircle,		"assets\textures\uiCircle.bpt"
		LoadBPT OFFSET TexVas,			"assets\textures\vas.bpt"
		LoadBPT OFFSET TexVasPlane,		"assets\textures\vasPlane.bpt"
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
		LoadBPT OFFSET TexWalkway,		"assets\textures\walkway.bpt"
		LoadBPT OFFSET TexWalkwaySmall,	"assets\textures\walkwaySmall.bpt"
		LoadBPT OFFSET TexWall,			"assets\textures\wall.bpt"
		LoadBPT OFFSET TexWallpaper,	"assets\textures\wallpaper.bpt"
		LoadBPT OFFSET TexWallPainted,	"assets\textures\wallPainted.bpt"
		LoadBPT OFFSET TexWB,			"assets\textures\WB.bpt"
		LoadBPT OFFSET TexWBBK,			"assets\textures\WBBK.bpt"
		LoadBPT OFFSET TexWBBK1,		"assets\textures\WBBK1.bpt"
		LoadBPT OFFSET TexWBBKP,		"assets\textures\WBBKP.bpt"
		LoadBPT OFFSET TexWhitewall,	"assets\textures\whitewall.bpt"
		LoadBPT OFFSET TexWmblykJumpscare,"assets\textures\wmblykJumpscare.bpt"
		mov bpTextureClamp, TRUE
		LoadBPT OFFSET TexWmblykL,		"assets\textures\wmblykL3.bpt"
		mov bpTextureClamp, FALSE
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
		
		;invoke glGenTextures, 1, ADDR TexIcon
		;invoke glBindTexture, GL_TEXTURE_2D, TexIcon
		;invoke glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST
		;invoke glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST
		;invoke glTexImage2D, GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_BGRA, GL_UNSIGNED_BYTE, pixelData)
		
		print "...done!", 13, 10
	.ELSEIF (LoadState == LOADING_SOUNDS)
		; ----- SOUNDS -----
		print "Loading sounds...", 9
		LoadBPS OFFSET SndAlarm,		"assets\sounds\alarm.bps"
		invoke alSourcei, SndAlarm, AL_LOOPING, AL_TRUE
		LoadBPS OFFSET SndAmb[0],		"assets\sounds\amb1.bps"
		invoke alSourcei, SndAmb[0], AL_LOOPING, AL_TRUE
		LoadBPS OFFSET SndAmb[4],		"assets\sounds\amb2.bps"
		invoke alSourcei, SndAmb[4], AL_LOOPING, AL_TRUE
		LoadBPS OFFSET SndAmb[8],		"assets\sounds\amb3.bps"
		invoke alSourcei, SndAmb[8], AL_LOOPING, AL_TRUE
		LoadBPS OFFSET SndAmbHeavy[0],	"assets\sounds\ambHeavy1.bps"
		invoke alSourcei, SndAmbHeavy[0], AL_LOOPING, AL_TRUE
		;invoke alSourcef, SndAmbHeavy[0], AL_ROLLOFF_FACTOR, f(2)
		LoadBPS OFFSET SndAmbHeavy[4],	"assets\sounds\ambHeavy2.bps"
		invoke alSourcei, SndAmbHeavy[4], AL_LOOPING, AL_TRUE
		;invoke alSourcef, SndAmbHeavy[4], AL_ROLLOFF_FACTOR, f(2)
		LoadBPS OFFSET SndAmbHeavy[8],	"assets\sounds\ambHeavy3.bps"
		invoke alSourcei, SndAmbHeavy[8], AL_LOOPING, AL_TRUE
		invoke alSourcef, SndAmbHeavy[8], AL_ROLLOFF_FACTOR, f(2)
		LoadBPS OFFSET SndAmbPlain[0],	"assets\sounds\ambPlain1.bps"
		invoke alSourcei, SndAmbPlain[0], AL_LOOPING, AL_TRUE
		invoke alSourcef, SndAmbPlain[0], AL_ROLLOFF_FACTOR, f(2)
		LoadBPS OFFSET SndAmbPlain[4],	"assets\sounds\ambPlain2.bps"
		invoke alSourcei, SndAmbPlain[4], AL_LOOPING, AL_TRUE
		invoke alSourcef, SndAmbPlain[4], AL_ROLLOFF_FACTOR, f(2)
		LoadBPS OFFSET SndAmbPlain[8],	"assets\sounds\ambPlain3.bps"
		invoke alSourcei, SndAmbPlain[8], AL_LOOPING, AL_TRUE
		invoke alSourcef, SndAmbPlain[8], AL_ROLLOFF_FACTOR, f(2)
		LoadBPS OFFSET SndAmbT,			"assets\sounds\ambT.bps"
		invoke alSourcei, SndAmbT, AL_LOOPING, AL_TRUE
		LoadBPS OFFSET SndAmbW[0],		"assets\sounds\ambW1.bps"
		LoadBPS OFFSET SndAmbW[4],		"assets\sounds\ambW2.bps"
		LoadBPS OFFSET SndAmbW[8],		"assets\sounds\ambW3.bps"
		LoadBPS OFFSET SndAmbW[12],		"assets\sounds\ambW4.bps"
		LoadBPS OFFSET SndBreak,		"assets\sounds\break.bps"
		invoke alSourcef, SndBreak, AL_ROLLOFF_FACTOR, f(0.6)
		LoadBPS OFFSET SndCheckpoint,	"assets\sounds\checkpoint.bps"
		LoadBPS OFFSET SndCreak,		"assets\sounds\creak.bps"
		LoadBPS OFFSET SndCrumble,		"assets\sounds\crumble.bps"
		LoadBPS OFFSET SndDeath,		"assets\sounds\death.bps"
		LoadBPS OFFSET SndDig,			"assets\sounds\dig.bps"
		LoadBPS OFFSET SndDistress,		"assets\sounds\distress.bps"
		LoadBPS OFFSET SndDoorClose,	"assets\sounds\doorClose.bps"
		LoadBPS OFFSET SndEBD,			"assets\sounds\ebd.bps"
		invoke alSourcei, SndEBD, AL_LOOPING, AL_TRUE
		invoke alSourcef, SndEBD, AL_ROLLOFF_FACTOR, f(4)
		LoadBPS OFFSET SndEBDA,			"assets\sounds\ebdA.bps"
		invoke alSourcei, SndEBDA, AL_LOOPING, AL_TRUE
		LoadBPS OFFSET SndElevator,		"assets\sounds\elevator.bps"
		LoadBPS OFFSET SndExit,			"assets\sounds\exit.bps"
		LoadBPS OFFSET SndExit1,		"assets\sounds\exit1.bps"
		LoadBPS OFFSET SndExit2,		"assets\sounds\exit2.bps"
		LoadBPS OFFSET SndExplosion,	"assets\sounds\explosion.bps"
		LoadBPS OFFSET SndHBD,			"assets\sounds\hbd.bps"
		invoke alSourcei, SndHBD, AL_LOOPING, AL_TRUE
		invoke alSourcef, SndHBD, AL_ROLLOFF_FACTOR, f(3)
		LoadBPS OFFSET SndHBDO,			"assets\sounds\hbdO.bps"
		LoadBPS OFFSET SndHurt,			"assets\sounds\hurt.bps"
		LoadBPS OFFSET SndImpact,		"assets\sounds\impact.bps"
		LoadBPS OFFSET SndIntro,		"assets\sounds\intro.bps"
		LoadBPS OFFSET SndKey,			"assets\sounds\key.bps"
		LoadBPS OFFSET SndKeyJape,		"assets\sounds\keyJape.bps"
		LoadBPS OFFSET SndKubale,		"assets\sounds\kubale.bps"
		invoke alSourcei, SndKubale, AL_LOOPING, AL_TRUE
		invoke alSourcef, SndKubale, AL_ROLLOFF_FACTOR, f(2)
		LoadBPS OFFSET SndKubaleAppear,	"assets\sounds\kubaleAppear.bps"
		LoadBPS OFFSET SndKubaleV,		"assets\sounds\kubaleV.bps"
		invoke SndSetGain, ADDR SndKubaleV, 0
		invoke alSourcei, SndKubaleV, AL_LOOPING, AL_TRUE
		LoadBPS OFFSET SndMistake,		"assets\sounds\mistake.bps"
		LoadBPS OFFSET SndMus[0],		"assets\sounds\mus1.bps"
		invoke SndSetGain, ADDR SndMus[0], f(0.5)
		LoadBPS OFFSET SndMus[4],		"assets\sounds\mus2.bps"
		invoke SndSetGain, ADDR SndMus[4], f(0.5)
		.IF (rv(nRand, 2))
			LoadBPS OFFSET SndMus[8],	"assets\sounds\mus3.bps"
		.ELSE
			LoadBPS OFFSET SndMus[8],	"assets\sounds\mus3Bach.bps"
		.ENDIF
		invoke SndSetGain, ADDR SndMus[8], 0
		invoke alSourcei, SndMus[8], AL_LOOPING, AL_TRUE
		LoadBPS OFFSET SndMus[12],		"assets\sounds\mus4.bps"
		invoke SndSetGain, ADDR SndMus[12], 0
		invoke alSourcei, SndMus[12], AL_LOOPING, AL_TRUE
		LoadBPS OFFSET SndMus[16],		"assets\sounds\mus5.bps"
		invoke SndSetGain, ADDR SndMus[16], f(0.5)
		LoadBPS OFFSET SndMus[20],		"assets\sounds\mus6.bps"
		invoke SndSetGain, ADDR SndMus[20], f(0.5)
		LoadBPS OFFSET SndOver,			"assets\sounds\over.bps"
		LoadBPS OFFSET SndRain,			"assets\sounds\rain.bps"
		invoke alSourcei, SndRain, AL_LOOPING, AL_TRUE
		invoke SndSetGain, ADDR SndRain, f(0.4)
		LoadBPS OFFSET SndRand[0],		"assets\sounds\rand1.bps"
		LoadBPS OFFSET SndRand[4],		"assets\sounds\rand2.bps"
		LoadBPS OFFSET SndRand[8],		"assets\sounds\rand3.bps"
		LoadBPS OFFSET SndRand[12],		"assets\sounds\rand4.bps"
		LoadBPS OFFSET SndRand[16],		"assets\sounds\rand5.bps"
		LoadBPS OFFSET SndRand[20],		"assets\sounds\rand6.bps"
		LoadBPS OFFSET SndRand[24],		"assets\sounds\rand7.bps"
		LoadBPS OFFSET SndRand[28],		"assets\sounds\rand8.bps"
		LoadBPS OFFSET SndRand[32],		"assets\sounds\rand9.bps"
		LoadBPS OFFSET SndSave,			"assets\sounds\save.bps"
		LoadBPS OFFSET SndScribble,		"assets\sounds\scribble.bps"
		LoadBPS OFFSET SndSiren,		"assets\sounds\siren.bps"
		invoke SndSetGain, ADDR SndSiren, 0
		invoke alSourcei, SndSiren, AL_LOOPING, AL_TRUE
		LoadBPS OFFSET SndSlam,			"assets\sounds\slam.bps"
		LoadBPS OFFSET SndSplash,		"assets\sounds\splash.bps"
		LoadBPS OFFSET SndStep[0],		"assets\sounds\step1.bps"
		LoadBPS OFFSET SndStep[4],		"assets\sounds\step2.bps"
		LoadBPS OFFSET SndStep[8],		"assets\sounds\step3.bps"
		LoadBPS OFFSET SndStep[12],		"assets\sounds\step4.bps"
		LoadBPS OFFSET SndStepDirt[0],	"assets\sounds\stepDirt1.bps"
		LoadBPS OFFSET SndStepDirt[4],	"assets\sounds\stepDirt2.bps"
		LoadBPS OFFSET SndStepDirt[8],	"assets\sounds\stepDirt3.bps"
		LoadBPS OFFSET SndStepDirt[12],	"assets\sounds\stepDirt4.bps"
		LoadBPS OFFSET SndSurvive,		"assets\sounds\survive.bps"
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
		invoke SndSetGain, ADDR SndVirdya, 0
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
		LoadBPS OFFSET SndWmblyk,		"assets\sounds\wmblyk.bps"
		LoadBPS OFFSET SndWmblykB,		"assets\sounds\wmblykB.bps"
		invoke alSourcei, SndWmblykB, AL_LOOPING, AL_TRUE
		invoke alSourcef, SndWmblykB, AL_ROLLOFF_FACTOR, f(4)
		LoadBPS OFFSET SndWmblykSpin,	"assets\sounds\wmblykSpin.bps"
		invoke alSourcef, SndWmblykSpin, AL_ROLLOFF_FACTOR, f(4)
		LoadBPS OFFSET SndWmblykStr,	"assets\sounds\wmblykStr.bps"
		LoadBPS OFFSET SndWmblykStrM,	"assets\sounds\wmblykStrM.bps"
		invoke SndSetGain, ADDR SndWmblykStrM, 0
		invoke alSourcei, SndWmblykStrM, AL_LOOPING, AL_TRUE
		print "...done!", 13, 10
	.ELSEIF (LoadState == LOADING_FINISHED)
		; Environment defaults		
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


ChrIsAlpha PROC EXPORT Chr:BYTE
	.IF ((Chr >= 65) && (Chr <= 90)) || ((Chr >= 97) && (Chr <= 122))
		mov pax, TRUE
		ret
	.ENDIF
	xor pax, pax
	ret
ChrIsAlpha ENDP

DampedSpring PROC EXPORT Velocity:BPPtr, Val:REAL4, ValTarget:REAL4, \
Stiffness:REAL4, Damping:REAL4, T:REAL4
	fld ValTarget
	fsub Val
	fmul Stiffness
	mov pax, Velocity
	fld REAL4 PTR [pax]
	fmul Damping
	fsub
	fmul T
	fadd REAL4 PTR [pax]
	fstp REAL4 PTR [pax]
	ret
DampedSpring ENDP

DampedSpringAngle PROC EXPORT Velocity:BPPtr, Val:REAL4, ValTarget:REAL4, \
Stiffness:REAL4, Damping:REAL4, T:REAL4
	fld ValTarget
	fsub Val
	fstp Val
	invoke flAngle, Val
	mov Val, eax
	fld Val
	fmul Stiffness
	mov pax, Velocity
	fld REAL4 PTR [pax]
	fmul Damping
	fsub
	fmul T
	fadd REAL4 PTR [pax]
	fstp REAL4 PTR [pax]
	ret
DampedSpringAngle ENDP

;   Will return the nearest plr distance in eax, offset in ecx, accounts for
; singleplayer
GetPlrNearDist PROC EXPORT PosPtr:BPPtr
	.IF (NetSock)
		invoke Net_GetClosestPlr, PosPtr, -1
		xchg eax, ecx
	.ELSE
		vinvoke Vector32DDistanceSqr, OFFSET CamPos, PosPtr
	.ENDIF
	ret
GetPlrNearDist ENDP

GetPlrNearPos PROC EXPORT PosPtr:BPPtr
	.IF (NetSock)
		invoke Net_GetClosestPlr, PosPtr, -1
		lea pax, NetPlayersVL[pax].Position
	.ELSE
		mov pax, OFFSET CamPosL
	.ENDIF
	ret
GetPlrNearPos ENDP

IntRandRLocal PROC EXPORT Min:SDWORD, Max:SDWORD, Seed:BPPtr
	mov eax, Max
	sub eax, Min
	invoke nRandLocal, eax, Seed
	add eax, Min
	ret
IntRandRLocal ENDP

;   Non-terminating manual int to string conversion macro (for settings UI)
IntToStr PROC EXPORT StrA:BPPtr, Val:SDWORD, Terminate:BPBool
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
	.IF (Terminate)
		mov BYTE PTR[eax+ebx], 0
	.ENDIF
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

Rotate2DPoint PROC EXPORT PosPtr:BPPtr, Angle:REAL4
	LOCAL sinCos:Vector2
	
	mov pax, PosPtr
	fld Angle
	fsincos
	fstp sinCos.Y	; cos
	fstp sinCos.X	; sin
	fld REAL4 PTR [pax]
	fld st
	fmul sinCos.Y
	fld REAL4 PTR [pax+8]
	fmul sinCos.X
	fsub
	fstp REAL4 PTR [pax]
	;fld REAL4 PTR [pax]	still have it in st
	fmul sinCos.X
	fld REAL4 PTR [pax+8]
	fmul sinCos.Y
	fadd
	fstp REAL4 PTR [pax+8]
	ret
Rotate2DPoint ENDP

StrBlank PROC EXPORT StrPtr:BPPtr
	mov pax, StrPtr
	.WHILE (BYTE PTR [pax])
		.IF (BYTE PTR [pax] != 32) && (BYTE PTR [pax] != 9)
			xor pax, pax
			ret
		.ENDIF
		inc pax
	.ENDW
	mov pax, TRUE
	ret
StrBlank ENDP

StrLength PROC EXPORT StrPtr:BPPtr
	IFDEF strlen
		invoke strlen, StrPtr
	ELSE
		invoke crt_strlen, StrPtr
	ENDIF
	ret
StrLength ENDP

StrShift PROC StrPtr:BPPtr, ShiftAmount:SBYTE
	mov pax, StrPtr
	mov cl, ShiftAmount
	.WHILE (BYTE PTR [pax])
		add BYTE PTR [pax], cl
		inc pax
	.ENDW
	ret
StrShift ENDP

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

StrToInt PROC EXPORT StrPtr:BPPtr
	IFDEF atof	; WinInc
		invoke atoi, StrPtr;, pax
	ELSE		; MASM
		invoke crt_atoi, StrPtr;, pax
	ENDIF
	ret
StrToInt ENDP

Vector32DDampedSpring PROC EXPORT Velocity:BPPtr, Pos:BPPtr, PosTarget:BPPtr,
Stiffness:REAL4, Damping:REAL4, T:REAL4
	mov pcx, Pos
	mov pdx, PosTarget
	invoke DampedSpring, Velocity, REAL4 PTR [pcx], REAL4 PTR [pdx], \
	Stiffness, Damping, T
	add Velocity, 8
	invoke DampedSpring, Velocity, REAL4 PTR [pcx+8], REAL4 PTR [pdx+8], \
	Stiffness, Damping, T
	ret
Vector32DDampedSpring ENDP

