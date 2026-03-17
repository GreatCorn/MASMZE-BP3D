; Net message codes (1-byte header)
ENUML
	;	Request player ID and list
	;	Player:	NetPlayer (without PlayerID and SockOnServ)
	E NET_PLAYERS_REQUEST
	
	;	Respond with player ID and list
	;	PlayerID:	DWORD
	;	Magic:		DWORD
	;	GameState:	DWORD
	;	Players:	NetPlayers[NET_MAX_PLAYERS] (256)
	E NET_PLAYERS_RESPONSE
	
	;	Send player volatile info
	;	PlayerVolatile:	NetPlayerVolatile
	E NET_PLAYER_VOLATILE
	
	;	Send all players volatile info
	;	PlayerVolatile:	NetPlayerVolatile[NET_MAX_PLAYERS]
	E NET_PLAYERS_VOLATILE
	
	;	Start game (play beginning animation)
	E NET_START_GAME
	
	;	Start game request (from client to server to all clients)
	E NET_START_GAME_REQUEST
	
	;	Maze lobby state for players just joining
	;	MazeStateTimer:		REAL4
	E NET_MAZE_STARTING
	
	;	Report all volatile maze elements and their volatile attributes (useful
	; for players joining in the middle of the round which generate the same
	; elements, the state of which could have been changed throughout the round)
	;	See NetMazeElements STRUCT
	E NET_MAZE_ELEMENTS
	
	;	Report all volatile entity states and their state-defining attributes
	;	See NetMazeEntities struct
	E NET_MAZE_ENTITIES
	
NetMazeElements STRUCT
	NetMsgType		BYTE ?
	
	PlrGlyphs		DWORD ?
	PlrGlyphsInMaze	DWORD ?
	PlrGlyphPos		Vector3 7 DUP (<?,?,?>)
	PlrGlyphRot		REAL4 7 DUP (?)
	MazeItems		BYTE ?
	MazeLocked		BYTE ?
	MazeShop		BYTE ?
	MazeSlam		BYTE ?
	MazeTeleport	BYTE ?
NetMazeElements ENDS

NetMazeEntities STRUCT
	NetMsgType		BYTE ?
	
	Kubale			BYTE ?
NetMazeEntities ENDS
	
NPS_WOUNDED EQU 1
	
NET_BUFFER_SIZE	EQU 320
NET_MAX_PLAYERS	EQU 8

; 32-byte struct, shift value is 5
NetPlayer STRUCT
	PlayerID	DWORD -1
	SockOnServ	DWORD 0
	Skin		BYTE 0
	IsHost		BYTE 0
	Dummy		BYTE 0
	Username	BYTE 21 dup (0)
NetPlayer ENDS
NetPlayerShift	EQU 5

NET_VISIBLE_LOCAL	EQU 1
NET_VISIBLE_GLOBAL	EQU 2

NetPlayerLocal STRUCT
	BlinkTimer	REAL4 0.0
	FaceTex		WORD 0
	Visible		WORD 0
	BodyRot		REAL4 0.0
	Position	Vector3 <>
	Rotation	Vector2 <>
NetPlayerLocal ENDS

; 32-byte struct, shift value is 5
NetPlayerVolatile STRUCT
	Score		DWORD 0
	PlrState	WORD 0
	NetState	WORD 0
	BodyRot		REAL4 0.0
	Position	Vector3 <>
	Rotation	Vector2 <>
NetPlayerVolatile ENDS
NetPlayerVShift	EQU 5

Net_Close PROTO
Net_Connect PROTO :LPVOID
Net_FormRespond PROTO :SOCKET, :BPPtr
Net_FormSend PROTO :BYTE, :SOCKET
Net_Host PROTO
Net_LeaderboardClear PROTO
Net_LeaderboardAppend PROTO :DWORD
Net_PlayerRemove PROTO :DWORD
Net_PlayersClear PROTO
Net_PopulateVolatile PROTO :BPPtr
Net_ProcessLoop PROTO :LPVOID
Net_ScoreAdd PROTO :SDWORD

.CONST
MeshPlrHeadOff	Vector3 <0.0, 0.2, -0.04>

.DATA
NetPort			SWORD 5001
NetPortStr		DB "5001", 0, 0
NetServerAddr	DB "127.0.0.1", 7 dup (0)
NetSock			SOCKET 0
NetHosting		BPBool FALSE

NetMagic		DWORD 0
NetPlayers		NetPlayer NET_MAX_PLAYERS dup (<>)
NetPlayersV		NetPlayerVolatile NET_MAX_PLAYERS dup (<>)
NetPlayersVL	NetPlayerLocal NET_MAX_PLAYERS dup (<>)	; Local interpolated
NetPlayersCount DWORD 0
NetPlayerID		DWORD -1
NetUnformed		BPBool TRUE

NetPlayersAnim	BPAnimPlayer NET_MAX_PLAYERS dup (<>)
NetPlayersMesh	BPMesh NET_MAX_PLAYERS dup (<>)
NetPlayersScarf	BPPtr NET_MAX_PLAYERS dup (0)
NetPlayersScVel	BPPtr NET_MAX_PLAYERS dup (0)
NetPlayersPosP	Vector2 NET_MAX_PLAYERS dup (<>)
NetPlayersAlive	DWORD 0
NetLeaderboard	BYTE NET_MAX_PLAYERS dup (-1)

NetPlrConnStr	BYTE 128 DUP (0)
NetFinishStr	BYTE 128 DUP (0)
NetScoreStr		BYTE 64 DUP (0)

NetUIScoreL	REAL4 0.0

NetVolatileTimer	REAL4 0.0, 0.064	; Send volatile info timer, interval

NetSpectateID	DWORD 0

.DATA?
MeshPlrHeadPtr		BPPtr ?