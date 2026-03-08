; Net message codes (1-byte header)
ENUML
	;	Request player ID and list
	;	Player: NetPlayer (without PlayerID and SockOnServ)
	E NET_PLAYERS_REQUEST
	
	;	Respond with player ID and list
	;	PlayerID: DWORD
	;	Magic: DWORD
	;	Players: NetPlayers[NET_MAX_PLAYERS]
	E NET_PLAYERS_RESPONSE
	
	;	Send player volatile info
	;	PlayerVolatile: NetPlayerVolatile
	E NET_PLAYER_VOLATILE
	
	;	Send all players volatile info
	;	PlayerVolatile: NetPlayerVolatile[NET_MAX_PLAYERS]
	E NET_PLAYERS_VOLATILE
	
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

; 32-byte struct, shift value is 5
NetPlayerVolatile STRUCT
	PlayerID	DWORD -1
	MazeLayer	DWORD 0
	NetState	DWORD 0
	Position	Vector3 <>
	Rotation	Vector2 <>
NetPlayerVolatile ENDS
NetPlayerVShift	EQU 5

Net_Close PROTO
Net_Connect PROTO :LPVOID
Net_FormRespond PROTO :SOCKET, :BPPtr
Net_FormSend PROTO :BYTE, :SOCKET
Net_Host PROTO
Net_PlayerRemove PROTO :DWORD
Net_PlayersClear PROTO
Net_PopulateVolatile PROTO :BPPtr
Net_ProcessLoop PROTO :LPVOID

.DATA
NetPort			SWORD 5001
NetPortStr		DB "5001", 0, 0
NetServerAddr	DB "127.0.0.1", 7 dup (0)
NetSock			SOCKET 0
NetHosting		BPBool FALSE

NetMagic		DWORD 0
NetPlayers		NetPlayer NET_MAX_PLAYERS dup (<>)
NetPlayersV		NetPlayerVolatile NET_MAX_PLAYERS dup (<>)
NetPlayersVL	NetPlayerVolatile NET_MAX_PLAYERS dup (<>)	; Local interpolated
NetPlayersCount DWORD 0
NetPlayerID		DWORD -1

NetVolatileTimer	REAL4 0.0, 0.064	; Send volatile info timer, interval