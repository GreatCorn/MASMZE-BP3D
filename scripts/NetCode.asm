; Check NetCode.inc for header stuff

.CODE
Net_Close PROC EXPORT
	.IF (NetSock)
		.IF (NetHosting)
			push pbx
			xor pbx, pbx
			.WHILE (pbx < SIZEOF NetPlayers)
				.IF (NetPlayers[pbx].PlayerID != -1)
					invoke shutdown, NetPlayers[pbx].SockOnServ, SD_SEND
					invoke closesocket, NetPlayers[pbx].SockOnServ
				.ENDIF
				add pbx, SIZEOF NetPlayer
			.ENDW
			pop pbx
		.ENDIF
		print "Closing socket...", 13, 10
		invoke closesocket, NetSock
		mov NetSock, 0
		mov NetPlayerID, -1
		mov NetPlayersCount, 0
	.ENDIF
	;.IF (UIState >= UI_STATE_MENU_PAUSE)
	;	vinvoke PauseGame, TRUE
	;.ENDIF
	call Net_PlayersClear
	call MenuInit
	ret
Net_Close ENDP

Net_Connect PROC EXPORT lpVoid:LPVOID
	LOCAL ipAddr:DWORD, servAddr:sockaddr_in, mode:DWORD
	
	call Net_Close
	
	print "Connecting to "
	print OFFSET NetServerAddr, 13, 10
	
	invoke RtlZeroMemory, ADDR servAddr, SIZEOF sockaddr_in
	mov servAddr.sin_family, AF_INET
	mov servAddr.sin_addr.S_un.S_addr, rv(inet_addr, OFFSET NetServerAddr)
	invoke StrToInt, ADDR NetPortStr
	mov NetPort, ax
	invoke htons, NetPort
	mov servAddr.sin_port, ax
	
	mov NetSock, rv(socket, AF_INET, SOCK_STREAM, IPPROTO_TCP)
	.IF (NetSock == INVALID_SOCKET)
		print "Opening socket failed.", 13, 10
		ret
	.ENDIF
	
	invoke connect, NetSock, ADDR servAddr, SIZEOF sockaddr_in
	.IF (pax == SOCKET_ERROR)
		print "Connecting socket failed.", 13, 10
		mov UIPopupMenu, UIPP_CONNFAIL
		ret
	.ENDIF
	
	mov NetHosting, FALSE
	;.IF (UIState >= UI_STATE_MENU_PAUSE)
	;	vinvoke PauseGame, FALSE
	;.ENDIF
	
	invoke CreateThread, NULL, 0, OFFSET Net_ProcessLoop, NetSock, 0, NULL
	ret
Net_Connect ENDP

Net_FindPlrBySock PROC EXPORT SockOnServ:DWORD
	xor pax, pax
	mov pcx, SockOnServ
	.WHILE (pax < SIZEOF NetPlayers)
		.IF (NetPlayers[pax].SockOnServ == pcx)
			ret
		.ENDIF
		add pax, SIZEOF NetPlayer
	.ENDW
	mov pax, -1
	ret
Net_FindPlrBySock ENDP

Net_FormPlrPopup PROC EXPORT UNamePtr:BPPtr, Connected:BPBool
	LOCAL strPtr:BPPtr
	.IF (Connected)
		bpMPM strPtr, StrNetJoined
	.ELSE
		bpMPM strPtr, StrNetLeft
	.ENDIF
	
	invoke StrLength, UNamePtr
	push pax
	invoke RtlMoveMemory, ADDR NetPlrConnStr, \
	UNamePtr, pax
	invoke StrLength, strPtr
	inc pax
	pop pcx
	mov NetPlrConnStr[pcx], 32
	inc pcx
	invoke RtlMoveMemory, ADDR NetPlrConnStr[pcx], \
	strPtr, pax
	invoke UI_ShowTextPopup, ADDR NetPlrConnStr, UISubDur
	ret
Net_FormPlrPopup ENDP

; Respond to or process received message
Net_FormRespond PROC EXPORT Sock:SOCKET, Buffer:BPPtr
	;print "Received "
	push pbx
	mov pbx, Buffer
	
	.IF (BYTE PTR [pbx] == NET_PLAYERS_REQUEST)
		;print "NET_PLAYERS_REQUEST", 13, 10
		.IF (NetHosting)
			; Get first free player slot and fill new player struct
			xor pax, pax
			.WHILE (pax < SIZEOF NetPlayers)
				.IF (NetPlayers[pax].PlayerID == -1)
					push pax
					inc pbx
					invoke RtlMoveMemory, ADDR NetPlayers[pax], pbx, \
					SIZEOF NetPlayer
					pop pax
					
					mov pcx, pax
					shr pcx, NetPlayerShift
					
					; Fill new player struct with accurate values
					mov NetPlayers[pax].PlayerID, ecx
					mov ecx, Sock
					mov NetPlayers[pax].SockOnServ, ecx
					;mov NetPlayersV[pax].Score, 0
					.BREAK
				.ENDIF
				add pax, SIZEOF NetPlayer
			.ENDW
			
			invoke Net_FormPlrPopup, ADDR NetPlayers[pax].Username, TRUE
			
			invoke Net_FormSend, NET_PLAYERS_RESPONSE, Sock
			
			.IF (MazeState == MAZE_STATE_LOBBY_FALL)
				invoke Net_FormSend, NET_MAZE_STARTING, Sock
			.ELSEIF (GameState == GAME_STATE_GAME)
				invoke Net_FormSend, NET_MAZE_ELEMENTS, 0
				invoke Net_FormSend, NET_MAZE_ENTITIES, 0
			.ENDIF
		.ENDIF
	.ELSEIF (BYTE PTR [pbx] == NET_PLAYERS_RESPONSE)
		print "NET_PLAYERS_RESPONSE", 13, 10
		
		.IF (NetPlayerID == -1)
			bpMEM32 NetPlayerID, DWORD PTR [pbx+1]
			bpMEM32 NetMagic, DWORD PTR [pbx+5]
			bpMEM32 GameState, DWORD PTR [pbx+9]
			bpMEM32 MazeLayer, DWORD PTR [pbx+13]
			
			; Count players
			mov NetPlayersCount, 0
			xor pax, pax
			.WHILE (pax < SIZEOF NetPlayers)
				ASSUME pbx:PTR NetPlayer
				.IF (DWORD PTR [pbx+pax+17].PlayerID != -1)
					inc NetPlayersCount
				.ENDIF
				ASSUME pbx:nothing
				add pax, SIZEOF NetPlayer
			.ENDW
			
			IFDEF MODE_DEBUG
			print "Connected, player ID: "
			print str$(NetPlayerID), 13, 10
			ENDIF
			
			SWITCH GameState
				CASE GAME_STATE_LOBBY
					call Net_LobbyInit
				CASE GAME_STATE_GAME
					call Net_GameInit
			ENDSW
		.ELSE	; Someone joined or left
			mov eax, DWORD PTR [pbx+1]
			; Because I'm an idiot, compare NetPlayers
			.IF (eax)
				xor pcx, pcx
				.WHILE (pcx < SIZEOF NetPlayers)
					mov edx, NetPlayers[pcx].PlayerID
					.IF (edx == -1) && (DWORD PTR [pbx+pcx+17] != edx)
						mov pax, pbx
						add pax, pcx
						add pax, 17
						ASSUME pax:PTR NetPlayer
						invoke Net_FormPlrPopup, ADDR [pax].Username,\
						TRUE
						ASSUME pax:nothing
						inc NetPlayersCount
						.BREAK
					.ENDIF
					add pcx, SIZEOF NetPlayer
				.ENDW
			.ELSE
				xor pcx, pcx
				.WHILE (pcx < SIZEOF NetPlayers)
					mov edx, DWORD PTR [pbx+pcx+17]
					.IF (edx == -1) && (NetPlayers[pcx].PlayerID != edx)
						invoke Net_FormPlrPopup, ADDR NetPlayers[pcx].Username,\
						FALSE
						dec NetPlayersCount
						.BREAK
					.ENDIF
					add pcx, SIZEOF NetPlayer
				.ENDW
			.ENDIF
		.ENDIF
		add pbx, 17
		invoke RtlMoveMemory, ADDR NetPlayers, pbx, SIZEOF NetPlayers
	.ELSEIF (BYTE PTR [pbx] == NET_PLAYER_VOLATILE)		
		inc pbx
		invoke Net_FindPlrBySock, Sock
		.IF (pax != -1)
			invoke RtlMoveMemory, ADDR NetPlayersV[pax], pbx, \
			SIZEOF NetPlayerVolatile
		.ENDIF
	.ELSEIF (BYTE PTR [pbx] == NET_PLAYERS_VOLATILE)
		;IFDEF MODE_DEBUG
		;push pcx
		;print "NET_PLAYERS_VOLATILE", 13, 10
		;pop pcx
		;ENDIF
		
		inc pbx
		invoke RtlMoveMemory, ADDR NetPlayersV, pbx, SIZEOF NetPlayersV
	.ELSEIF (BYTE PTR [pbx] == NET_START_GAME)
		mov MazeState, MAZE_STATE_LOBBY_CREAK
	.ELSEIF (BYTE PTR [pbx] == NET_START_GAME_REQUEST)
		invoke Net_FormSend, NET_START_GAME, 0
	.ELSEIF (BYTE PTR [pbx] == NET_RESTART)
		print "NET_RESTART", 13, 10
		call Maze_Exit
		call Net_LobbyInit
	.ELSEIF (BYTE PTR [pbx] == NET_MAZE_STARTING)
		print "NET_MAZE_STARTING", 13, 10
		mov MazeState, MAZE_STATE_LOBBY_CREAK
		invoke Maze_ProcessState
		bpMEM32 MazeStateTimer, REAL4 PTR [pbx+1]
		fld f(4)
		fsub MazeStateTimer
		fstp REAL4 PTR [pbx+1]
		invoke alSourcef, SndCreak, AL_SEC_OFFSET, REAL4 PTR [pbx+1]
	.ELSEIF (BYTE PTR [pbx] == NET_MAZE_PROGRESS)
		mov PollProc, OFFSET Plr_Progress
	.ELSEIF (BYTE PTR [pbx] == NET_MAZE_ELEMENTS)
		print "NET_MAZE_ELEMENTS", 13, 10
		
		ASSUME pbx:PTR NetMazeElements
		
		.IF (NetUnformed)	; Just joined, load in only
			dec MazeLayer
			call Maze_Progress
		.ELSE				; Trigger appropriate events
			; Items
			mov al, [pbx].MazeItems
			.IF (MazeItems != al)
				; MAZE_ITEM_GLYPHS
				mov al, [pbx].MazeItems
				and al, MAZE_ITEM_GLYPHS
				mov ah, MazeItems
				and ah, MAZE_ITEM_GLYPHS
				.IF (al != ah)
					invoke Maze_CollectItem, MAZE_ITEM_GLYPHS, 0
				.ENDIF
				
				; MAZE_ITEM_MAP
				
				; MAZE_ITEM_KEY
				mov al, [pbx].MazeItems
				and al, MAZE_ITEM_KEY
				mov ah, MazeItems
				and ah, MAZE_ITEM_KEY
				.IF (al != ah)
					invoke Maze_CollectItem, MAZE_ITEM_KEY, 0
				.ENDIF
			.ENDIF
			
			; Glyphs
			mov eax, [pbx].PlrGlyphs
			.IF (PlrGlyphs != eax)
				mov pax, [pbx].PlrGlyphsInMaze
				dec pax
				mov pcx, 12
				mul pcx
				
				invoke Plr_PlaceGlyph, ADDR [pbx].PlrGlyphPos[pax], 0, 0
			.ENDIF
		.ENDIF
		
		bpMEM32 PlrGlyphs, [pbx].PlrGlyphs
		bpMEM32 PlrGlyphsInMaze, [pbx].PlrGlyphsInMaze
		invoke RtlMoveMemory, ADDR PlrGlyphPos, ADDR [pbx].PlrGlyphPos, \
		SIZEOF PlrGlyphPos
		invoke RtlMoveMemory, ADDR PlrGlyphRot, ADDR [pbx].PlrGlyphRot, \
		SIZEOF PlrGlyphRot
		
		
		mbm MazeItems, [pbx].MazeItems
		mbm MazeLocked, [pbx].MazeLocked
		mbm MazeShop, [pbx].MazeShop
		mbm MazeSlam, [pbx].MazeSlam
		mbm MazeTeleport, [pbx].MazeTeleport
		
		print "Received all elements", 13, 10
		
		ASSUME pbx:nothing
		
		.IF (NetHosting)
			invoke Net_FormSend, NET_MAZE_ELEMENTS, Sock
		.ENDIF
	.ELSEIF (BYTE PTR [pbx] == NET_MAZE_ENTITIES)
		print "NET_MAZE_ENTITIES", 13, 10
		
		ASSUME pbx:PTR NetMazeEntities
		
		.IF (NetUnformed)	; Just joined, load in only
			mov NetUnformed, FALSE
			.IF ([pbx].Wmblyk)
				invoke Wmblyk_Spawn, [pbx].Wmblyk
			.ENDIF
		.ELSE				; Trigger appropriate events
			; Vebra
			mov al, Vebra
			.IF ([pbx].Vebra != al) && ([pbx].Vebra == VEBRA_GOING)
				invoke bpAnimPlay, ADDR VebraAnimPlr, ADDR AnimVebraGo
			.ENDIF
		.ENDIF
		
		mbm Kubale, [pbx].Kubale
		mbm Vebra, [pbx].Vebra
		mbm Wmblyk, [pbx].Wmblyk
		.IF (PlrState != PLAYER_STATE_STRANGLE)
			invoke Vector3Copy, ADDR WmblykPos, ADDR [pbx].WmblykPos
			bpMEM32 WmblykRot, [pbx].WmblykRot
		.ENDIF
		bpMEM32 WmblykStateVal, [pbx].WmblykStateVal
		bpMEM32 WmblykStrPlr, [pbx].WmblykStrPlr
		
		ASSUME pbx:nothing
		
		.IF (NetHosting)
			invoke Net_FormSend, NET_MAZE_ENTITIES, Sock
		.ENDIF
	.ELSEIF (BYTE PTR [pbx] == NET_LEADERBOARD)
		print "NET_LEADERBOARD", 13, 10
		invoke RtlMoveMemory, ADDR NetLeaderboard, ADDR [pbx+1], NET_MAX_PLAYERS
		bpMEM32 NetPlayersAlive, DWORD PTR [pbx+1+NET_MAX_PLAYERS]
		
		.IF (NetHosting)
			invoke Net_FormSend, NET_LEADERBOARD, Sock
		.ENDIF
	.ENDIF
	pop pbx
	ret
Net_FormRespond ENDP

; Form and send message
Net_FormSend PROC EXPORT MsgType:BYTE, Sock:SOCKET
	LOCAL buf[NET_BUFFER_SIZE]:BYTE, globalMsg:BPBool, exclude:BPBool
	
	mov exclude, FALSE
	mov globalMsg, FALSE
	;print "Sending "
	mov al, MsgType
	mov buf[0], al
	.IF (al == NET_PLAYERS_REQUEST)
		invoke RtlMoveMemory, ADDR buf[1], ADDR NetPlayers[0], SIZEOF NetPlayer
	.ELSEIF (al == NET_PLAYERS_RESPONSE)
		;print "NET_PLAYERS_RESPONSE"
		; Get the socket's player slot
		xor pax, pax
		.IF (Sock)
			mov ecx, Sock
			.WHILE (pax < SIZEOF NetPlayers)
				.IF (NetPlayers[pax].SockOnServ == ecx)
					.BREAK
				.ENDIF
				add pax, SIZEOF NetPlayer
			.ENDW
			shr pax, NetPlayerShift
		.ENDIF
		mov DWORD PTR buf[1], eax	; PlayerID
		bpMEM32 DWORD PTR buf[5], NetMagic
		bpMEM32 DWORD PTR buf[9], GameState
		bpMEM32 DWORD PTR buf[13], MazeLayer
		invoke RtlMoveMemory, ADDR buf+17, ADDR NetPlayers, SIZEOF NetPlayers
		inc NetPlayersCount
		
		mov globalMsg, TRUE
	.ELSEIF (al == NET_PLAYER_VOLATILE)
		;print "NET_PLAYER_VOLATILE"
		; Populate NetPlayerVolatile struct and send
		invoke Net_PopulateVolatile, ADDR buf+1
	.ELSEIF (al == NET_PLAYERS_VOLATILE)
		;print "NET_PLAYERS_VOLATILE"
		; Populate own NetPlayerVolatile struct and send all
		invoke Net_PopulateVolatile, OFFSET NetPlayersV[0]
		invoke RtlMoveMemory, ADDR buf+1, ADDR NetPlayersV, SIZEOF NetPlayersV
		
		mov globalMsg, TRUE
	.ELSEIF (al == NET_START_GAME)
		mov MazeState, MAZE_STATE_LOBBY_CREAK
		
		mov globalMsg, TRUE
	.ELSEIF (al == NET_RESTART)
		call Maze_Exit
		call Net_LobbyInit
		
		mov globalMsg, TRUE
	.ELSEIF (al == NET_MAZE_STARTING)
		bpMEM32 REAL4 PTR buf[1], MazeStateTimer
	.ELSEIF (al == NET_MAZE_PROGRESS)
		mov globalMsg, TRUE
	.ELSEIF (al == NET_MAZE_ELEMENTS)
		ASSUME pbx:PTR NetMazeElements
		push pbx
		lea pbx, buf
		
		bpMEM32 [pbx].PlrGlyphs, PlrGlyphs
		bpMEM32 [pbx].PlrGlyphsInMaze, PlrGlyphsInMaze
		invoke RtlMoveMemory, ADDR [pbx].PlrGlyphPos, ADDR PlrGlyphPos, \
		SIZEOF PlrGlyphPos
		invoke RtlMoveMemory, ADDR [pbx].PlrGlyphRot, ADDR PlrGlyphRot, \
		SIZEOF PlrGlyphRot
		mbm [pbx].MazeItems, MazeItems
		mbm [pbx].MazeLocked, MazeLocked
		mbm [pbx].MazeShop, MazeShop
		mbm [pbx].MazeSlam, MazeSlam
		mbm [pbx].MazeTeleport, MazeTeleport
		
		pop pbx
		ASSUME pbx:nothing
		
		.IF (NetHosting)
			mov exclude, TRUE
			mov globalMsg, TRUE
		.ENDIF
	.ELSEIF (al == NET_MAZE_ENTITIES)
		ASSUME pbx:PTR NetMazeEntities
		push pbx
		lea pbx, buf
		
		mbm [pbx].Kubale, Kubale
		mbm [pbx].Vebra, Vebra
		mbm [pbx].Wmblyk, Wmblyk
		invoke Vector3Copy, ADDR [pbx].WmblykPos, ADDR WmblykPos
		bpMEM32 [pbx].WmblykRot, WmblykRot
		bpMEM32 [pbx].WmblykStateVal, WmblykStateVal
		bpMEM32 [pbx].WmblykStrPlr, WmblykStrPlr
		
		pop pbx
		ASSUME pbx:nothing
		
		.IF (NetHosting)
			mov exclude, TRUE
			mov globalMsg, TRUE
		.ENDIF
	.ELSEIF (al == NET_LEADERBOARD)
		invoke RtlMoveMemory, ADDR buf[1], ADDR NetLeaderboard, NET_MAX_PLAYERS
		bpMEM32 DWORD PTR buf[1+NET_MAX_PLAYERS], NetPlayersAlive
		.IF (NetHosting)
			mov exclude, TRUE
			mov globalMsg, TRUE
		.ENDIF
	.ENDIF
	.IF (globalMsg)
		;print " GLOBAL"
		mov pcx, SIZEOF NetPlayer	; NetPlayers[0] is host
		.WHILE (pcx < SIZEOF NetPlayers)
			mov pax, Sock
			mov pdx, NetSock
			.IF (NetPlayers[pcx].PlayerID != -1) \	; Don't send to non-players
			&& (NetPlayers[pcx].SockOnServ != pax) ;\; Don't send to target yet
			;&& (NetPlayers[pcx].SockOnServ != pdx)	; Not needed, start from 1
				;IFDEF MODE_DEBUG
				;push pcx
				;print str$(NetPlayers[pcx].SockOnServ), 9
				;pop pcx
				;ENDIF
				
				push pcx
				invoke send, NetPlayers[pcx].SockOnServ, ADDR buf, \
				NET_BUFFER_SIZE, 0
				pop pcx
			.ENDIF
			add pcx, SIZEOF NetPlayer
		.ENDW
	.ENDIF
	mov pax, NetSock
	; Sock may not yet be on NetPlayers list so special treatment (or exclude)
	.IF (Sock) && !(exclude)
		invoke send, Sock, ADDR buf, NET_BUFFER_SIZE, 0
	.ENDIF
	ret
Net_FormSend ENDP

; For players joining when a game is in progress
Net_GameInit PROC EXPORT
	call GameInit
	invoke alSourceStop, SndMus[20]
	invoke alSourcePlay, SndAmb
	call Net_LeaderboardClear
	mov PlrState, PLAYER_STATE_SPECTATE
	ret
Net_GameInit ENDP

;   Get closest player to PosPtr and return their NetPlayersV offset in pax and
; the dNET_VISIBLE_GLOBAListance in ecx
Net_GetClosestPlr PROC EXPORT PosPtr:BPPtr, ExcludeID:DWORD
	LOCAL closest:BPPtr, dist:REAL4, lastDist:REAL4
	
	mov closest, 0
	mov lastDist, FLT_INF
	push pbx
	xor pbx, pbx
	.WHILE (pbx < SIZEOF NetPlayersVL)
		mov eax, ExcludeID
		.IF (NetPlayers[pbx].PlayerID != eax) \
		&& (NetPlayers[pbx].PlayerID != -1) \
		&& (NetPlayersVL[pbx].Visible & NET_VISIBLE_GLOBAL)
			mov dist, \
			rv(Vector32DDistanceSqr, PosPtr, ADDR NetPlayersV[pbx].Position)
			fcmp dist, lastDist
			.IF (Carry?)
				bpMEM32 lastDist, dist
				mov closest, pbx
			.ENDIF
		.ENDIF
		add pbx, SIZEOF NetPlayerLocal
	.ENDW
	pop pbx
	mov ecx, lastDist
	mov pax, closest
	ret
Net_GetClosestPlr ENDP

Net_Host PROC EXPORT 
	LOCAL localAddr:sockaddr_in, fSock:sockaddr_in, fLen:DWORD, msg:SOCKET
	
	call Net_Close
	
	print "Hosting server...", 13, 10
	
	mov localAddr.sin_family, AF_INET
	IFDEF BP_WININC
		mov localAddr.sin_addr.s_addr, INADDR_ANY
	ELSE
		mov localAddr.sin_addr.S_un.S_addr, INADDR_ANY	; dumbfuk
	ENDIF
	invoke StrToInt, ADDR NetPortStr
	mov NetPort, ax
	invoke htons, NetPort
	mov localAddr.sin_port, ax
	
	mov NetSock, rv(socket, AF_INET, SOCK_STREAM, 0)
	.IF (NetSock == INVALID_SOCKET)
		print "Opening socket failed.", 13, 10
		ret
	.ENDIF
	
	invoke bind, NetSock, ADDR localAddr, SIZEOF sockaddr_in
	.IF (pax == SOCKET_ERROR)
		call WSAGetLastError
		print str$(pax), 9
		print "Binding socket failed.", 13, 10
		mov UIPopupMenu, UIPP_CONNFAIL
		ret
	.ENDIF
	
	invoke listen, NetSock, 5
	.IF (pax == SOCKET_ERROR)
		print "Listening failed.", 13, 10
		mov UIPopupMenu, UIPP_CONNFAIL
		ret
	.ENDIF
	
	mov NetHosting, TRUE
	;.IF (UIState >= UI_STATE_MENU_PAUSE)
	;	vinvoke PauseGame, FALSE
	;.ENDIF
	
	print "Hosted, player socket: "
	print str$(NetSock), 13, 10
	
	; Add yourself as first player
	mov NetPlayers[0].PlayerID, 0
	;mov NetPlayers[0].IsHost, TRUE
	bpMEM32 NetPlayers[0].SockOnServ, NetSock
	inc NetPlayersCount
	mov NetPlayerID, 0
	bpMEM32 NetMagic, nRandSeed
	
	call Net_LobbyInit
	
	.WHILE (NetSock)
		.IF (NetPlayersCount > NET_MAX_PLAYERS)
			invoke Sleep, 32
			.CONTINUE
		.ENDIF
		mov fLen, SIZEOF sockaddr_in
		mov msg, rv(accept, NetSock, ADDR fSock, ADDR fLen)
		print "Player connected. ID:"
		print str$(msg), 13, 10
		.IF (msg == INVALID_SOCKET)
			print "Accept error.", 13, 10
		.ENDIF
		
		invoke CreateThread, NULL, 0, OFFSET Net_ProcessLoop, msg, 0, NULL
	.ENDW
	ret
Net_Host ENDP

Net_LeaderboardAppend PROC EXPORT PlayerID:DWORD
	xor pax, pax
	.WHILE (pax < SIZEOF NetLeaderboard)
		.IF (NetLeaderboard[pax] == -1)
			mov ecx, PlayerID
			mov NetLeaderboard[pax], cl
			.BREAK
		.ENDIF
		inc pax
	.ENDW
	ret
Net_LeaderboardAppend ENDP

Net_LeaderboardCheck PROC EXPORT PlayerID:DWORD
	xor pax, pax
	mov ecx, PlayerID
	.WHILE (pax < SIZEOF NetLeaderboard)
		.IF (NetLeaderboard[pax] == cl)
			ret
		.ENDIF
		inc pax
	.ENDW
	mov pax, -1
	ret
Net_LeaderboardCheck ENDP

Net_LeaderboardClear PROC EXPORT
	xor pax, pax
	.WHILE (pax < SIZEOF NetLeaderboard)
		mov NetLeaderboard[pax], -1
		inc pax
	.ENDW
	ret
Net_LeaderboardClear ENDP

Net_LobbyInit PROC EXPORT
	mov UITextPopupStr, 0
	
	.IF (rv(SndPlaying, SndMus[20]) != AL_PLAYING)
		invoke alSourcef, SndMus[20], AL_GAIN, f(1)
		invoke alSourcePlay, SndMus[20]
	.ENDIF
	
	mov GameState, GAME_STATE_LOBBY
	mov PlrCanControl, TRUE
	mov MazeCheck, MAZE_CHECK_SAVED
	mov MazeState, MAZE_STATE_GAME
	
	mov PlrState, PLAYER_STATE_GAME
	
	mov UIFade, UI_FADE_IN
	mov UIFadeVal, FLT_1

	invoke Vector3Set, ADDR MazeCheckPos, 0, 0, 0
	invoke Vector3Set, ADDR MazeDoorPos, f(1), CamHeight, f(5)
	invoke Vector3Set, ADDR MazeCheckErasePos, 0, 0, f(-100)
	invoke Vector3Copy, ADDR MazeCheckErasePosL, ADDR MazeCheckErasePos
	invoke Plr_Teleport, f(1), f(4)
	
	mov NetUnformed, FALSE
	
	call GameInit
	ret
Net_LobbyInit ENDP

Net_PlayerRemove PROC EXPORT SockOnServ:DWORD
	invoke Net_FindPlrBySock, SockOnServ
	.IF (pax != -1)
		mov NetPlayers[pax].PlayerID, -1
		invoke Net_FormPlrPopup, ADDR NetPlayers[pax].Username, FALSE
		dec NetPlayersCount
		
		invoke Net_FormSend, NET_PLAYERS_RESPONSE, 0
	.ENDIF
	ret
Net_PlayerRemove ENDP

Net_PlayersClear PROC EXPORT
	xor pax, pax
	.WHILE (pax < SIZEOF NetPlayers)
		mov NetPlayers[pax].PlayerID, -1
		;mov NetPlayersV[pax].PlayerID, -1
		add pax, SIZEOF NetPlayer
	.ENDW
	ret
Net_PlayersClear ENDP

Net_PopulateVolatile PROC EXPORT NPVPtr:BPPtr
	LOCAL flVal:REAL4
	
	mov pcx, NPVPtr
	ASSUME pcx:PTR NetPlayerVolatile
	
	bpMEM32 [pcx].Score, NetScore
	mov eax, PlrState
	mov [pcx].PlrState, ax
	mov [pcx].NetState, 0
	fcmp PlrHealth, f(0.8)
	.IF (Carry?) || ((MazeState == MAZE_STATE_LOBBY_FALL) && (MazeCheckPos.Y))
		or [pcx].NetState, NPS_WOUNDED
	.ENDIF
	invoke RtlMoveMemory, ADDR [pcx].Position, ADDR CamPosL, 12
	mov pcx, NPVPtr
	invoke RtlMoveMemory, ADDR [pcx].Rotation, ADDR CamRotL, 8
	
	mov pcx, NPVPtr
	fcmp PlrSpeed, f(0.1)
	.IF (!Carry?)
		bpMEM32 [pcx].BodyRot, [pcx].Rotation.Y
	.ELSE
		fld [pcx].Rotation.Y
		fsub [pcx].BodyRot
		fstp flVal
		mov flVal, rv(flAngle, flVal)
		and flVal, not FLT_NEG
		fcmp flVal, f(0.75)
		.IF (!Carry?)
			fld flVal
			fsub f(0.75)
			fstp flVal
			mov [pcx].BodyRot, \
			rv(flLerpAngle, [pcx].BodyRot, [pcx].Rotation.Y, flVal)
		.ENDIF
	.ENDIF
	
	ASSUME pcx:nothing
	ret
Net_PopulateVolatile ENDP

; Process the server from a client, or a single client from the server.
Net_ProcessLoop PROC EXPORT lpSock:LPVOID
	LOCAL buf[NET_BUFFER_SIZE]:BYTE
	
	.WHILE (NetSock)
		.IF (NetHosting)	; We are the server
		.ELSE				; We are a client
			.IF (NetPlayerID == -1)	; Just connected
				; Ask for player list
				invoke Net_FormSend, NET_PLAYERS_REQUEST, lpSock
			.ENDIF
		.ENDIF
		
		; Receive message		
		invoke recv, lpSock, ADDR buf, NET_BUFFER_SIZE, 0
		.IF (pax == SOCKET_ERROR)
			print "Error receiving data on socket.", 13, 10
			call Net_Close
		.ELSEIF !(pax)
			print "Connection closed.", 13, 10
			.IF (NetHosting)
				print "Player disconnected. Socket:"
				print str$(lpSock), 13, 10
				invoke Net_PlayerRemove, lpSock
				.BREAK
			.ELSE
				print "Server disconnected.", 13, 10
				call Net_Close
				mov UIPopupMenu, UIPP_SERVDISC
			.ENDIF	
			.CONTINUE
		.ENDIF
		; Process message
		invoke Net_FormRespond, lpSock, ADDR buf
	.ENDW
	ret
Net_ProcessLoop ENDP

Net_ScoreAdd PROC EXPORT Score:SDWORD
	;mov pax, NetPlayerID
	;shl pax, NetPlayerShift
	;mov ecx, Score
	;add NetPlayersV[pax].Score, ecx
	mov eax, Score
	add NetScore, eax
	invoke UI_ShowTextPopup, ADDR NetScoreStr, UISubDur
	ret
Net_ScoreAdd ENDP

Net_SetColorByID PROC EXPORT PlayerID:DWORD, Alpha:REAL4
	LOCAL v4Val:Vector4
	
	bpMEM32 v4Val.W, Alpha
	
	SWITCH PlayerID
		CASE 0
			invoke Vector3Copy, ADDR v4Val, ADDR clWhite
		CASE 1
			invoke Vector3Set, ADDR v4Val, f(1), f(0.38), f(0.38)
		CASE 2
			invoke Vector3Set, ADDR v4Val, f(0.6), f(0.95), f(1.0)
		CASE 3
			invoke Vector3Set, ADDR v4Val, f(1), f(0.75), f(0.6)
		CASE 4
			invoke Vector3Set, ADDR v4Val, f(0.9), f(0.6), f(1.0)
		CASE 5
			invoke Vector3Set, ADDR v4Val, f(0.3), f(0.9), f(0.4)
		CASE 6
			invoke Vector3Set, ADDR v4Val, f(0.4), f(0.4), f(0.9)
		CASE 7
			invoke Vector3Set, ADDR v4Val, f(0.2), f(0.2), f(0.2)
	ENDSW
	
	;.IF (SetMat)
		;invoke glMaterialfv, GL_FRONT, GL_AMBIENT, ADDR v4Val
		;invoke glMaterialfv, GL_FRONT, GL_DIFFUSE, ADDR v4Val
		;invoke glMaterialfv, GL_FRONT, GL_EMISSION, ADDR v4Val
		;invoke glMaterialfv, GL_FRONT, GL_SPECULAR, ADDR v4Val
	;.ELSE
		invoke glColor4fv, ADDR v4Val
	;.ENDIF
	ret
Net_SetColorByID ENDP


Net_Draw PROC EXPORT
	LOCAL headPos:Vector3
	; Draw players
	;invoke glMaterialfv, GL_FRONT, GL_EMISSION, ADDR clGray
	invoke glDisable, GL_LIGHTING
	push pbx
	xor pbx, pbx
	ASSUME pbx:PTR NetPlayerVolatile
	.WHILE (pbx < SIZEOF NetPlayersV)
		mov eax, NetPlayerID
		.IF (NetPlayers[pbx].PlayerID != eax) \
		&& (NetPlayers[pbx].PlayerID != -1) \
		&& (NetPlayersVL[pbx].Visible & NET_VISIBLE_LOCAL)
			call glPushMatrix
			.IF (NetPlayersV[pbx].PlrState == PLAYER_STATE_EXITING)
				fld NetPlayersVL[pbx].Position.Y
				fsub CamHeight
				fmul f(0.5)
				fstp headPos.Y
				invoke glTranslatef, NetPlayersVL[pbx].Position.X, \
				headPos.Y, NetPlayersVL[pbx].Position.Z
			.ELSE
				invoke glTranslate32Dfv, ADDR NetPlayersVL[pbx].Position
			.ENDIF
			
			; Draw username
			call glPushMatrix
			invoke glTranslatef, 0, f(1.5), 0
			invoke glScalef, f(0.0025), f(-0.0025), f(0.0025)
			invoke glRotatef, CamBillboard.Y, 0, f(1), 0
			mov eax, CamBillboard.X
			xor eax, FLT_NEG
			invoke glRotatef, eax, f(1), 0, 0
			;invoke glDisable, GL_LIGHTING
			invoke glDepthMask, GL_FALSE
			mov UIShadow, TRUE
			invoke UI_Text, ADDR NetPlayers[pbx].Username, 0, 0, \
			BP_ALIGN_CENTER, 0
			mov UIShadow, FALSE
			;invoke glEnable, GL_LIGHTING
			invoke glDepthMask, GL_TRUE
			call glPopMatrix
			
			invoke Net_SetColorByID, NetPlayers[pbx].PlayerID, FLT_1
			
			; Draw head
			invoke glEnable, GL_ALPHA_TEST
			invoke glStencilFunc, GL_ALWAYS, 1, 0FFh
			invoke glStencilMask, 0FFh
			invoke glClear, GL_STENCIL_BUFFER_BIT
			call glPushMatrix
			mov pax, pbx
			shr pax, NetPlayerShift
			mov pcx, SIZEOF BPMesh
			mul pcx
			push pax
			mov pax, NetPlayersMesh[pax].Vertices
			add pax, MeshPlrHeadPtr
			; Calculate and rotate head pos (should be done in process ffs)
			invoke Vector3Copy, ADDR headPos, pax
			invoke Vector3Add, ADDR headPos, ADDR MeshPlrHeadOff
			invoke Rotate2DPoint, ADDR headPos, NetPlayersVL[pbx].BodyRot
			xor headPos.X, FLT_NEG
			invoke glTranslate3fv, ADDR headPos
			
			; Draw scarf
			invoke glDisable, GL_CULL_FACE
			invoke glBindTexture, GL_TEXTURE_2D, TexPlrBody
			.IF !(SettingsGraphicsInterpolation)
				call glPushMatrix
				invoke glRotatefr, NetPlayersVL[pbx].BodyRot, 0, f(1), 0
				invoke glCallList, MdlPlrScarfStatic	; Draw static scarf
				call glPopMatrix
			.ELSE
				mov pax, pbx
				shr pax, NetPlayerShift
				shl pax, BPPtrShift
				invoke glVertexPointer, 3, GL_FLOAT, 0, \
				NetPlayersScarf[pax]
				invoke glTexCoordPointer, 2, GL_FLOAT, 0, MeshPlrScarf.TexCoords
				invoke glNormalPointer, GL_FLOAT, 0, MeshPlrScarf.Normals
				invoke glDrawArrays, GL_TRIANGLES, 0, MeshPlrScarf.Count
			.ENDIF
			invoke glEnable, GL_CULL_FACE
			
			;invoke glDisable, GL_LIGHTING
			invoke glEnable, GL_STENCIL_TEST
			invoke glScalef, f(0.33), f(0.33), f(0.33)
			invoke glRotate2fv, ADDR CamBillboard
			invoke glBindTexture, GL_TEXTURE_2D, TexPlrHead
			invoke glCallList, MdlParticle
			call glPopMatrix
			;invoke glEnable, GL_LIGHTING
			
			; Draw body
			call glPushMatrix
			invoke glStencilFunc, GL_NOTEQUAL, 1, 0FFh
			invoke glStencilMask, 0
			invoke glRotatefr, NetPlayersVL[pbx].BodyRot, 0, f(1), 0
			invoke glBindTexture, GL_TEXTURE_2D, TexPlrBody
			pop pax
			invoke bpDrawMesh, ADDR NetPlayersMesh[pax]
			invoke glDisable, GL_STENCIL_TEST
			call glPopMatrix			
			invoke glDisable, GL_ALPHA_TEST
			
			invoke Net_SetColorByID, 0, FLT_1
			
			; Draw face
			invoke glEnable, GL_BLEND
			invoke glBlendFunc, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA
			invoke glTranslate3fv, ADDR headPos
			.IF (NetPlayersVL[pbx].BlinkTimer & FLT_NEG) \
			&& (NetPlayersV[pbx].PlrState != PLAYER_STATE_DYING) \
			&& (NetPlayersV[pbx].PlrState != PLAYER_STATE_DEAD) 
				mov eax, TexPlrBlink
			.ELSE
				movzx eax, NetPlayersVL[pbx].FaceTex
			.ENDIF
			invoke glBindTexture, GL_TEXTURE_2D, eax
			invoke glRotate2fvr, ADDR NetPlayersVL[pbx].Rotation
			invoke glCallList, MdlPlrAcc
			invoke glDisable, GL_BLEND
			
			call glPopMatrix
		.ENDIF
		add pbx, SIZEOF NetPlayerVolatile
	.ENDW
	ASSUME pbx:nothing
	pop pbx
	invoke glEnable, GL_LIGHTING
	;invoke glMaterialfv, GL_FRONT, GL_AMBIENT, ADDR clAmbient
	;invoke glMaterialfv, GL_FRONT, GL_EMISSION, ADDR clBlack
	ret
Net_Draw ENDP

Net_Process PROC EXPORT
	LOCAL Dot:Vector3, ClPlr:BPPtr, Anim:BPPtr, OpenDoor:BYTE
	
	fld NetVolatileTimer[0]
	fsub deltaUnscaled
	fstp NetVolatileTimer[0]
	.IF (NetVolatileTimer & FLT_NEG)
		fld NetVolatileTimer[0]
		fadd NetVolatileTimer[4]
		fstp NetVolatileTimer[0]
		
		.IF (NetHosting)
			invoke Net_FormSend, NET_PLAYERS_VOLATILE, 0
			
			; Continuously volatile entity states
			.IF (Wmblyk == WMBLYK_WALK)
				invoke Net_FormSend, NET_MAZE_ENTITIES, NetSock
			.ENDIF
		.ELSE
			invoke Net_FormSend, NET_PLAYER_VOLATILE, NetSock
		.ENDIF
	.ENDIF
	
	mov OpenDoor, 0
	
	push pbx
	xor pbx, pbx
	ASSUME pbx:PTR NetPlayerVolatile
	.WHILE (pbx < SIZEOF NetPlayersV)
		mov eax, NetPlayerID
		.IF (NetPlayers[pbx].PlayerID != eax) \
		&& (NetPlayers[pbx].PlayerID != -1)
			.IF (NetPlayersV[pbx].PlrState == PLAYER_STATE_EXITING)
				.IF !(MazeDoorRot) \
				&& (rv(SndPlaying, SndCheckpoint) != AL_PLAYING)
					invoke SndSetPos, SndCheckpoint, ADDR MazeDoorPos
					invoke alSourcePlay, SndCheckpoint
				.ENDIF
				mov OpenDoor, 1
			.ELSEIF (NetPlayersV[pbx].PlrState == PLAYER_STATE_COMPLETED)
				.IF !(OpenDoor)
					mov eax, f(-100)
					.IF (MazeDoorRot == eax) \
					&& (rv(SndPlaying, SndDoorClose) != AL_PLAYING)
						invoke SndSetPos, SndDoorClose, ADDR MazeDoorPos
						invoke alSourcePlay, SndDoorClose
					.ENDIF
					mov OpenDoor, 2
				.ENDIF
			.ENDIF
			
			; Get if the player is visible at all (not a spectator)
			.IF (NetPlayersV[pbx].PlrState >= PLAYER_STATE_SPECTATE)
				mov NetPlayersVL[pbx].Visible, 0
				add pbx, SIZEOF NetPlayerVolatile
				.CONTINUE
			.ELSE
				mov NetPlayersVL[pbx].Visible, NET_VISIBLE_LOCAL \
				or NET_VISIBLE_GLOBAL
			.ENDIF
			
			; Get the player's animation player (will be using later)
			mov pax, pbx
			shr pax, NetPlayerShift
			mov pcx, SIZEOF BPAnimPlayer
			mul pcx
			mov Anim, pax
			
			; Determine special player face texture
			mov NetPlayersVL[pbx].FaceTex, 0
			
			; If wounded
			.IF (NetPlayersV[pbx].NetState & NPS_WOUNDED)
				mov eax, TexPlrWounded
				mov NetPlayersVL[pbx].FaceTex, ax
			.ENDIF
			
			; Determine which anim to play (and set some stuff)
			; If dead (also set head pos and anim)
			.IF (NetPlayersV[pbx].PlrState == PLAYER_STATE_DYING) \
			|| (NetPlayersV[pbx].PlrState == PLAYER_STATE_DEAD)
				mov eax, TexPlrDead
				mov NetPlayersVL[pbx].FaceTex, ax
				bpMEM32 NetPlayersV[pbx].Rotation.X, PIHalfN
				mov pax, OFFSET AnimPlrDead
			.ELSE	; Not dead - animate
				mov pax, pbx
				shr pax, 2
				.IF ((MazeState == MAZE_STATE_LOBBY_FALL) && (MazeCheckPos.Y))
					mov ecx, f(3)
					mov Dot.Y, ecx
				.ELSE
					; Calculate speed
					fld NetPlayersPosP[pax].X
					fsub NetPlayersVL[pbx].Position.X
					fmul st, st
					fld NetPlayersPosP[pax].Y
					fsub NetPlayersVL[pbx].Position.Z
					fmul st, st
					fadd	; Got distance
					fsqrt
					fdiv deltaTime
					fstp Dot.Y
				.ENDIF
				
				; Set prev pos
				mov ecx, NetPlayersVL[pbx].Position.X
				mov NetPlayersPosP[pax].X, ecx
				mov ecx, NetPlayersVL[pbx].Position.Z
				mov NetPlayersPosP[pax].Y, ecx
				
				; If player is moving, play appropriate animation
				fcmp Dot.Y, f(0.1)
				.IF (!Carry?)
					fcmp NetPlayersV[pbx].Position.Y, f(1)
					.IF (Carry?)
						mov pax, OFFSET AnimPlrCrouchWalk
					.ELSE
						mov pax, OFFSET AnimPlrWalk
					.ENDIF
				.ELSE
					fcmp NetPlayersV[pbx].Position.Y, f(1)
					.IF (Carry?)
						mov pax, OFFSET AnimPlrCrouch
					.ELSE
						mov pax, OFFSET AnimPlrIdle
					.ENDIF
				.ENDIF
			.ENDIF
			mov pdx, Anim
			.IF (pax == OFFSET AnimPlrCrouchWalk) || (pax == OFFSET AnimPlrWalk)
				; If we got here, Dot.Y is movement speed
				mov ecx, Dot.Y
				mov NetPlayersAnim[pdx].Speed, ecx
			.ELSE
				mov NetPlayersAnim[pdx].Speed, FLT_1
			.ENDIF
			.IF (NetPlayersAnim[pdx].TrackPtr != pax)
				.IF (pax != OFFSET AnimPlrDead) \
				|| (NetPlayersAnim[pdx].TrackPtr)
					invoke bpAnimPlay, ADDR NetPlayersAnim[pdx], pax
				.ENDIF
			.ENDIF
			
			; Interpolate the position and rotation
			invoke Vector3Lerp, ADDR NetPlayersVL[pbx].Position, \
			ADDR NetPlayersV[pbx].Position, delta20
			invoke Vector2LerpAngle, ADDR NetPlayersVL[pbx].Rotation, \
			ADDR NetPlayersV[pbx].Rotation, delta20
			mov NetPlayersVL[pbx].Rotation.Y, \
			rv(flAngle, NetPlayersVL[pbx].Rotation.Y)
			
			mov Dot.Y, \
			rv(Vector32DDistanceSqr, ADDR CamPos,ADDR NetPlayersV[pbx].Position)
			
			invoke Collide_Distance, ADDR CamPos, \
			ADDR NetPlayersV[pbx].Position, f(0.2), Dot.Y
			
			fcmp Dot.Y, f(2)
			.IF (!Carry?)
				mov Dot.Y, rv(Plr_FrustumDot, ADDR NetPlayersVL[pbx].Position)
				fcmp Dot.Y, f(0.2)
				.IF (Carry?)
					mov NetPlayersVL[pbx].Visible, NET_VISIBLE_GLOBAL
					add pbx, SIZEOF NetPlayerVolatile
					.CONTINUE
				.ENDIF
			.ENDIF
			
			invoke flLerpAngle, NetPlayersVL[pbx].BodyRot, \
			NetPlayersV[pbx].BodyRot, delta10
			mov NetPlayersVL[pbx].BodyRot, rv(flAngle, eax)
			
			mov pax, Anim
			invoke bpProcessAnimPlayer, ADDR NetPlayersAnim[pax], deltaTime
			
			; Animate scarf
			.IF (SettingsGraphicsInterpolation)
				mov pcx, pbx
				shr pcx, NetPlayerShift
				shl pcx, BPPtrShift
				xor pdx, pdx
				.WHILE (pdx < MeshPlrScarf.V3Size)
					mov pax, pdx
					add pax, MeshPlrScarf.Vertices
					invoke Vector3Copy, ADDR Dot, pax
					mov eax, NetPlayersVL[pbx].BodyRot
					xor eax, FLT_NEG
					invoke Rotate2DPoint, ADDR Dot, eax
					
					fld Dot.Y
					fmul st, st
					fdivr f(2)
					fmul deltaTime
					fstp Dot.Y
					
					fcmp Dot.Y, f(1)
					.IF (!Carry?) || (Zero?)
						mov pax, NetPlayersScarf[pcx]
						add pax, pdx
						push Dot.X
						pop REAL4 PTR [pax]
						push Dot.Z
						pop REAL4 PTR [pax+8]
						
						add pdx, SIZEOF Vector3
						.CONTINUE
					.ENDIF
					
					push pcx
					push pdx
					mov pax, NetPlayersScVel[pcx]
					add pax, pdx
					mov pcx, NetPlayersScarf[pcx]
					add pcx, pdx
					lea pdx, Dot
					push pax
					invoke DampedSpring, pax, REAL4 PTR [pcx], Dot.X, f(0.9), f(0.7), Dot.Y
					pop pax
					fld REAL4 PTR [pax]
					fmul Dot.Y
					fadd REAL4 PTR [pcx]
					fstp REAL4 PTR [pcx]
					add pax, 8
					invoke DampedSpring, pax, REAL4 PTR [pcx+8], Dot.Z, f(0.9), f(0.7), Dot.Y
					fld REAL4 PTR [pax]
					fmul Dot.Y
					fadd REAL4 PTR [pcx+8]
					fstp REAL4 PTR [pcx+8]
					;invoke Vector32DLerp, pcx, pdx, Dot.Y
					;mov pcx, NetPlayersScarf[pcx]
					;add pcx, pdx
					;invoke Vector32DLerp, pcx, ADDR Dot, Dot.Y
					;push Dot.Y
					;push f(0.7)
					;push f(0.9)
					;lea pax, Dot
					;push pax
					;mov pax, NetPlayersScarf[pcx]
					;add pax, pdx
					;push pax
					;mov pax, NetPlayersScVel[pcx]
					;add pax, pdx
					;push pax
					;call Vector32DDampedSpring
					pop pdx
					pop pcx
					
					add pdx, SIZEOF Vector3
				.ENDW
			.ENDIF
			
			.IF !(NetPlayersVL[pbx].FaceTex)
				invoke Net_GetClosestPlr, ADDR NetPlayersV[pbx].Position, \
				NetPlayers[pbx].PlayerID
				mov ClPlr, pax
				
				mov Dot.Y, ecx
				fcmp Dot.Y, f(2)
				.IF (Carry?)
					mov pax, ClPlr
					invoke Vector32DCopy,ADDR Dot,ADDR NetPlayersV[pax].Position
					invoke Vector32DSub, ADDR Dot,ADDR NetPlayersV[pbx].Position
					;invoke Vector32DNormalize, ADDR Dot
					fld NetPlayersV[pbx].Rotation.Y
					fsincos
					fmul Dot.X
					fxch
					fmul Dot.Z
					fsub
					fstp Dot.X
					
					fcmp Dot.X, f(0.3)
					.IF (!Carry?)
						mov eax, TexPlrLeft
					.ELSE
						fcmp Dot.X, f(-0.3)
						.IF (Carry?)
							mov eax, TexPlrRight
						.ELSE
							mov eax, TexPlrNeut
						.ENDIF
					.ENDIF
				.ELSE
					mov eax, TexPlrNeut
				.ENDIF
				mov NetPlayersVL[pbx].FaceTex, ax
				
				
				fld NetPlayersVL[pbx].BlinkTimer
				fsub deltaTime
				fstp NetPlayersVL[pbx].BlinkTimer
				fcmp NetPlayersVL[pbx].BlinkTimer, f(-0.1)
				.IF (Carry?)
					mov NetPlayersVL[pbx].BlinkTimer,rv(flRandRange,f(0.5),f(7))
				.ENDIF
			.ENDIF
		.ENDIF
		
		add pbx, SIZEOF NetPlayerVolatile
	.ENDW
	ASSUME pbx:nothing
	
	; Input own values into local
	mov pbx, NetPlayerID
	shl pbx, NetPlayerShift
	.IF (PlrState >= PLAYER_STATE_SPECTATE)
		mov NetPlayersVL[pbx].Visible, 0
	.ELSE
		mov NetPlayersVL[pbx].Visible, NET_VISIBLE_LOCAL or NET_VISIBLE_GLOBAL
	.ENDIF
	invoke Vector3Copy, ADDR NetPlayersVL[pbx].Position, ADDR CamPosL
	invoke Vector2Copy, ADDR NetPlayersVL[pbx].Rotation, ADDR CamRotL
	pop pbx
	
	.IF (PlrState != PLAYER_STATE_EXITING)
		.IF (OpenDoor == 1)
			mov MazeDoorRot, rv(flLerp, MazeDoorRot, f(-104), delta2)
			fcmp MazeDoorRot, f(-100)
			.IF (Sign?)
				bpMEM32 MazeDoorRot, f(-100)
			.ENDIF
		.ELSEIF (OpenDoor == 2)
			mov MazeDoorRot, rv(flLerp, MazeDoorRot, f(4), delta2)
			.IF !(MazeDoorRot & FLT_NEG)
				mov MazeDoorRot, 0
			.ENDIF
		.ENDIF
	.ENDIF
	
	.IF (PlrState == PLAYER_STATE_SPECTATE)
		mov pax, NetSpectateID
		shl pax, NetPlayerShift
		invoke Vector3Copy, ADDR CamPos, ADDR NetPlayersVL[pax].Position
		invoke Vector3Sub, ADDR CamPos, ADDR CamForward
		invoke Vector3Copy, ADDR CamPosL, ADDR CamPos
	.ENDIF
	ret
Net_Process ENDP
