; Check NetCode.inc for header stuff

.CODE
Net_Close PROC EXPORT
	LOCAL Sock:DWORD
	bpMEM32 Sock, NetSock
	mov NetSock, 0
	.IF (Sock)
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
		.ELSE
			invoke Net_FindPlrByID, NetPlayerID
			invoke RtlMoveMemory, ADDR NetPlayers, ADDR NetPlayers[pax], \
			SIZEOF NetPlayer
		.ENDIF
		print "Closing socket...", 13, 10
		invoke closesocket, Sock
		mov NetPlayerID, -1
		mov NetPlayersCount, 0
		mov NetScore, 0
	.ENDIF
	;.IF (UIState >= UI_STATE_MENU_PAUSE)
	;	vinvoke PauseGame, TRUE
	;.ENDIF
	call Net_PlayersClear
	poll MenuInit
	ret
Net_Close ENDP

Net_Connect PROC EXPORT lpVoid:LPVOID
	LOCAL ipAddr:DWORD, servAddr:sockaddr_in, mode:DWORD
	
	;call Net_Close
	
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

Net_FindPlrByID PROC EXPORT PlayerID:DWORD
	xor pax, pax
	mov pcx, PlayerID
	.WHILE (pax < SIZEOF NetPlayers)
		.IF (NetPlayers[pax].PlayerID == pcx)
			ret
		.ENDIF
		add pax, SIZEOF NetPlayer
	.ENDW
	mov pax, -1
	ret
Net_FindPlrByID ENDP

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
	
	; Validate message
	.IF (BYTE PTR [pbx] != NET_PLAYERS_REQUEST) && (NetHosting)
		xor pax, pax
		.WHILE (pax < SIZEOF NetPlayers)
			mov pcx, Sock
			.IF (NetPlayers[pax].SockOnServ == pcx)
				jmp netFormRespondValidate
			.ENDIF
			add pax, SIZEOF NetPlayer
		.ENDW
		
		pop pbx
		ret
	.ENDIF
	
	netFormRespondValidate:
	
	.IF (BYTE PTR [pbx] == NET_PLAYERS_REQUEST)
		print "NET_PLAYERS_REQUEST", 13, 10
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
				invoke Net_FormSend, NET_MAZE_CHANGES, 0
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
		mov MazeLayer, 0
		add NetMagic, 6D2B79F5h
		poll Maze_Exit
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
		poll Plr_Progress
	.ELSEIF (BYTE PTR [pbx] == NET_MAZE_ELEMENTS)
		print "NET_MAZE_ELEMENTS", 13, 10
		
		ASSUME pbx:PTR NetMazeElements
		
		.IF (NetUnformed)	; Just joined, load in only
			dec MazeLayer
			call Maze_Progress
		.ELSE				; Trigger appropriate events
			; Checkpoint
			mov al, [pbx].MazeCheck
			.IF (MazeCheck != al) && (al == MAZE_CHECK_OPEN)
				call Maze_SpawnCheck
			.ENDIF
			
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
			
			; Key jape
			.IF ([pbx].MazeLocked == MAZE_LOCK_LOCKED_JAPE) && \
			([pbx].MazeKeyPos.Y) && !(MazeKeyPos.Y)
				invoke SndSetPos, SndKeyJape, ADDR MazeKeyPos
				invoke alSourcePlay, SndKeyJape
			.ENDIF
			
			; Glyphs
			mov eax, [pbx].PlrGlyphs
			.IF (PlrGlyphs != eax)
				.IF ([pbx].PlrGlyphsInMaze)
					mov pax, [pbx].PlrGlyphsInMaze
					dec pax
					mov pcx, 12
					mul pcx
				
					invoke Plr_PlaceGlyph, ADDR [pbx].PlrGlyphPos[pax], 0, 0
				.ENDIF
			.ENDIF
				
			; Shop
			mov al, [pbx].MazeShop
			.IF (MazeShop == 1) && (al == 2)
				call Maze_CloseShop
			.ENDIF
		.ENDIF
		
		bpMEM32 PlrGlyphs, [pbx].PlrGlyphs
		bpMEM32 PlrGlyphsInMaze, [pbx].PlrGlyphsInMaze
		invoke RtlMoveMemory, ADDR PlrGlyphPos, ADDR [pbx].PlrGlyphPos, \
		SIZEOF PlrGlyphPos
		invoke RtlMoveMemory, ADDR PlrGlyphRot, ADDR [pbx].PlrGlyphRot, \
		SIZEOF PlrGlyphRot
		
		
		mbm MazeCheck, [pbx].MazeCheck
		mbm MazeElevator, [pbx].MazeElevator
		mbm MazeItems, [pbx].MazeItems
		invoke Vector3Copy, ADDR MazeKeyPos, ADDR [pbx].MazeKeyPos
		mbm MazeLocked, [pbx].MazeLocked
		mbm MazePowerup, [pbx].MazePowerup
		mbm MazeShop, [pbx].MazeShop
		mbm MazeSlam, [pbx].MazeSlam
		mbm MazeTeleport, [pbx].MazeTeleport
		
		ASSUME pbx:nothing
		
		.IF (NetHosting)
			invoke Net_FormSend, NET_MAZE_ELEMENTS, Sock
		.ENDIF
	.ELSEIF (BYTE PTR [pbx] == NET_MAZE_ENTITIES)
		print "NET_MAZE_ENTITIES", 13, 10
		
		ASSUME pbx:PTR NetMazeEntities
		
		.IF (NetUnformed)	; Just joined, load in only
			mov NetUnformed, FALSE
			.IF ([pbx].HBD)
				invoke HBD_Spawn, [pbx].HBD
			.ENDIF
			.IF ([pbx].Kubale)
				invoke Kubale_Spawn, [pbx].Kubale
				.IF ([pbx].Kubale == KUBALE_EVENT)
					.IF ([pbx].KubaleRot & FLT_NEG)
						invoke alSourcePlay, SndKubaleAppear
						mov eax, [pbx].KubaleRot
						and eax, not FLT_NEG
						invoke alSourcef, SndKubaleAppear, AL_SEC_OFFSET, eax
					.ENDIF
				.ENDIF
			.ENDIF
			.IF ([pbx].Wmblyk) && ([pbx].Wmblyk != WMBLYK_STEALTH_WAIT) && \
			([pbx].Wmblyk != WMBLYK_STEALTH_APPEAR)
				invoke Wmblyk_Spawn, [pbx].Wmblyk
			.ENDIF
		.ELSE				; Trigger appropriate events
			; Kubale (may fail the regular way for some reason)
			mov al, Kubale
			.IF ([pbx].Kubale != al) 
				invoke Kubale_Spawn, [pbx].Kubale
			.ENDIF
			; Vebra
			mov al, Vebra
			.IF ([pbx].Vebra != al) && ([pbx].Vebra == VEBRA_GOING)
				invoke bpAnimPlay, ADDR VebraAnimPlr, ADDR AnimVebraGo
			.ENDIF
		.ENDIF
		
		mbm HBD, [pbx].HBD
		invoke Vector2Copy, ADDR HBDCell, ADDR [pbx].HBDCell
		invoke Vector32DSet, ADDR HBDPosT, [pbx].HBDPos.X, [pbx].HBDPos.Y
		bpMEM32 HBDRot[4], [pbx].HBDRot
		bpMEM32 HBDTimer, [pbx].HBDTimer
		
		invoke Vector3Copy, ADDR HDLCloseT, ADDR [pbx].HDLCloseT
		invoke Vector3Copy, ADDR HDLPos, ADDR [pbx].HDLPos
		bpMEM32 HDLRot, [pbx].HDLRot
		bpMEM32 HDLSpeed, [pbx].HDLSpeed
		bpMPM HDLStackPtr, [pbx].HDLStackPtr
		bpMEM32 HDLState, [pbx].HDLState
		invoke Vector3Copy, ADDR HDLTarget, ADDR [pbx].HDLTarget
		bpMEM32 HDLTimer, [pbx].HDLTimer
		mov al, [pbx].HDL
		.IF (al != HDL) && (al == HDL_RUSH)
			invoke HDL_Solve, ADDR HDLTarget
		.ENDIF
		mbm HDL, [pbx].HDL
		
		
		mbm Kubale, [pbx].Kubale
		bpMEM32 KubaleRot, [pbx].KubaleRot
		invoke Vector3Copy, ADDR KubalePos, ADDR [pbx].KubalePos
		
		mbm Vebra, [pbx].Vebra
		
		mbm Virdya, [pbx].Virdya
		bpMEM32 VirdyaBlinkTimer, [pbx].VirdyaBlinkTimer
		invoke Vector3Copy, ADDR VirdyaLookPos, ADDR [pbx].VirdyaLookPos
		invoke Vector3Copy, ADDR VirdyaPos, ADDR [pbx].VirdyaPos
		bpMEM32 VirdyaRot, [pbx].VirdyaRot
		bpMEM32 VirdyaSpeed, [pbx].VirdyaSpeed
		bpMEM32 VirdyaStrafe, [pbx].VirdyaStrafe
		
		.IF ([pbx].Wmblyk != WMBLYK_STEALTH_WAIT) && \
		([pbx].Wmblyk != WMBLYK_STEALTH_APPEAR)
			mbm Wmblyk, [pbx].Wmblyk
			.IF (PlrState != PLAYER_STATE_STRANGLE)
				invoke Vector3Copy, ADDR WmblykPos, ADDR [pbx].WmblykPos
				bpMEM32 WmblykRot, [pbx].WmblykRot
			.ENDIF
			bpMEM32 WmblykStateVal, [pbx].WmblykStateVal
			bpMEM32 WmblykStrPlr, [pbx].WmblykStrPlr
		.ENDIF
		
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
	.ELSEIF (BYTE PTR [pbx] == NET_MAZE_CHANGES)
		bpMPM MazeChangesPtr, BPPtr PTR [pbx+1]
		invoke RtlMoveMemory, ADDR MazeChanges, ADDR [pbx+1+SIZEOF BPPtr], \
		SIZEOF MazeChanges
		
		.IF (NetUnformed)	; Just joined, load in only
			call Maze_ApplyChanges
		.ELSEIF (MazeChangesPtr)
			mov pax, MazeChangesPtr
			sub pax, SIZEOF MazeChange
			mov pcx, MazeChanges[pax].CellOffset
			add pcx, Maze
			mov dl, MazeChanges[pax].CellVal
			
			; Sledgehammer compare
			.IF !((BYTE PTR [pcx] & MAZE_CELL_PASSLEFT) && \
			(dl & MAZE_CELL_PASSLEFT))
				push MAZE_CELL_PASSLEFT
			.ELSE
				push MAZE_CELL_PASSTOP
			.ENDIF
			mov BYTE PTR [pcx], dl
			
			
			; Sledgehammer act
			invoke bp2DArrayGetPosition, MazeChanges[pax].CellOffset, \
			MazeSize[0], 1
			
			pop pcx
			
			shl edx, 1
			.IF (pcx == MAZE_CELL_PASSTOP)
				inc edx
			.ENDIF
			mov MazePartDust.Position.X, edx
			shl eax, 1
			.IF (pcx == MAZE_CELL_PASSLEFT)
				inc eax
			.ENDIF
			mov MazePartDust.Position.Z, eax
			invoke Vector32DF, ADDR MazePartDust.Position
			
			invoke Plr_Sledgehammer, ADDR MazePartDust.Position
		.ENDIF
		
		.IF (NetHosting)
			invoke Net_FormSend, NET_MAZE_CHANGES, Sock
		.ENDIF
	.ELSEIF (BYTE PTR [pbx] == NET_GAME_STATES)
		print "NET_GAME_STATES", 13, 10
		ASSUME pbx:PTR NetGameStates
		
		.IF !(NetUnformed)	; Triggers
			mov al, [pbx].FreezeTime
			.IF (al != FreezeTime)
				invoke Plr_FreezeTime, al, 0
			.ENDIF
		.ENDIF
		
		mbm FreezeTime, [pbx].FreezeTime
		
		.IF (NetHosting)
			invoke Net_FormSend, NET_GAME_STATES, Sock
		.ENDIF
	.ELSEIF (BYTE PTR [pbx] == NET_SOUND)
		print "NET_SOUND", 13, 10
		
		invoke SndSetPos, DWORD PTR [pbx+1], ADDR [pbx+5]
		invoke alSourcePlay, DWORD PTR [pbx+1]
		
		.IF (NetHosting)
			invoke Net_FormSend, NET_GAME_STATES, Sock
		.ENDIF
	.ENDIF
	pop pbx
	ret
Net_FormRespond ENDP

; Form and send message
Net_FormSend PROC EXPORT MsgType:BYTE, Sock:SOCKET
	LOCAL buf[NET_BUFFER_SIZE]:BYTE, globalMsg:BPBool, exclude:BPBool
	
	.IF (!NetSock)
		ret
	.ENDIF
	
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
			inc NetPlayersCount
		.ENDIF
		mov DWORD PTR buf[1], eax	; PlayerID
		bpMEM32 DWORD PTR buf[5], NetMagic
		bpMEM32 DWORD PTR buf[9], GameState
		bpMEM32 DWORD PTR buf[13], MazeLayer
		invoke RtlMoveMemory, ADDR buf+17, ADDR NetPlayers, SIZEOF NetPlayers
		
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
		add NetMagic, 6D2B79F5h
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
		mbm [pbx].MazeCheck, MazeCheck
		mbm [pbx].MazeElevator, MazeElevator
		mbm [pbx].MazeItems, MazeItems
		invoke Vector3Copy, ADDR [pbx].MazeKeyPos, ADDR MazeKeyPos
		mbm [pbx].MazeLocked, MazeLocked
		mbm [pbx].MazePowerup, MazePowerup
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
		
		mbm [pbx].HBD, HBD
		invoke Vector2Copy, ADDR [pbx].HBDCell, ADDR HBDCell
		invoke Vector2Set, ADDR [pbx].HBDPos, HBDPosT.X, HBDPosT.Z
		bpMEM32 [pbx].HBDRot, HBDRot[4]
		bpMEM32 [pbx].HBDTimer, HBDTimer
		
		mbm [pbx].HDL, HDL
		invoke Vector3Copy, ADDR [pbx].HDLCloseT, ADDR HDLCloseT
		invoke Vector3Copy, ADDR [pbx].HDLPos, ADDR HDLPos
		bpMEM32 [pbx].HDLRot, HDLRot
		bpMEM32 [pbx].HDLSpeed, HDLSpeed
		bpMPM [pbx].HDLStackPtr, HDLStackPtr
		bpMEM32 [pbx].HDLState, HDLState
		invoke Vector3Copy, ADDR [pbx].HDLTarget, ADDR HDLTarget
		bpMEM32 [pbx].HDLTimer, HDLTimer
		
		mbm [pbx].Kubale, Kubale
		bpMEM32 [pbx].KubaleRot, KubaleRot
		invoke Vector3Copy, ADDR [pbx].KubalePos, ADDR KubalePos
		
		mbm [pbx].Vebra, Vebra
		
		mbm [pbx].Virdya, Virdya
		bpMEM32 [pbx].VirdyaBlinkTimer, VirdyaBlinkTimer
		invoke Vector3Copy, ADDR [pbx].VirdyaLookPos, ADDR VirdyaLookPos
		invoke Vector3Copy, ADDR [pbx].VirdyaPos, ADDR VirdyaPos
		bpMEM32 [pbx].VirdyaRot, VirdyaRot
		bpMEM32 [pbx].VirdyaSpeed, VirdyaSpeed
		bpMEM32 [pbx].VirdyaStrafe, VirdyaStrafe
		
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
	.ELSEIF (al == NET_MAZE_CHANGES)
		bpMPM BPPtr PTR buf[1], MazeChangesPtr
		invoke RtlMoveMemory, ADDR buf[1+SIZEOF BPPtr], ADDR MazeChanges, \
		SIZEOF MazeChanges
		.IF (NetHosting)
			mov exclude, TRUE
			mov globalMsg, TRUE
		.ENDIF
	.ELSEIF (al == NET_GAME_STATES)
		ASSUME pbx:PTR NetGameStates
		push pbx
		lea pbx, buf
		
		mbm [pbx].FreezeTime, FreezeTime
		
		pop pbx
		ASSUME pbx:nothing
		
		.IF (NetHosting)
			mov exclude, TRUE
			mov globalMsg, TRUE
		.ENDIF
	.ELSEIF (al == NET_SOUND)
		bpMEM32 DWORD PTR buf[1], NetSound
		invoke Vector32DCopy, ADDR buf[5], ADDR NetSoundPos
		
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
	call Plr_Reset
	call GameInit
	invoke alSourceStop, SndMus[20]
	call Net_LeaderboardClear
	mov PlrState, PLAYER_STATE_SPECTATE
	invoke Vector3Set, ADDR CamRot, PIQuarter, PIQuarter, 0
	ret
Net_GameInit ENDP

;   Get closest player to PosPtr and return their NetPlayersV offset in pax and
; the distance in ecx
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
	
	;call Net_Close
	
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
	call Plr_Reset

	mov UITextPopupStr, 0
	
	.IF (rv(SndPlaying, SndMus[20]) != AL_PLAYING)
		invoke SndSetGain, ADDR SndMus[20], f(0.75)
		invoke alSourcePlay, SndMus[20]
	.ENDIF
	
	mov GameState, GAME_STATE_LOBBY
	mov PlrCanControl, TRUE
	mov MazeCheck, MAZE_CHECK_SAVED
	mov MazeState, MAZE_STATE_GAME
	
	.IF (NetHosting)
		mov MazeLayer, 0
	.ENDIF
	
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
	.IF (BPSPtr PTR pax != -1)
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
	.IF (PlrCrouch)
		or [pcx].NetState, NPS_CROUCH
	.ENDIF
	.IF (PlrItems & MAZE_ITEM_COMPASS)
		or [pcx].NetState, NPS_COMPASS
	.ENDIF
	.IF (PlrItems & MAZE_ITEM_MAP)
		or [pcx].NetState, NPS_MAP
	.ENDIF
	.IF (PlrPowerup)
		movzx ax, PlrPowerup
		shl ax, NPS_POWERUP_SHIFT
		or [pcx].NetState, ax
	.ENDIF
	invoke RtlMoveMemory, ADDR [pcx].Position, ADDR CamPosL, 12
	;invoke Vector3Copy, ADDR [pcx].Position, ADDR CamPosL
	;bpMEM32 [pcx].Position.Y, PlrHeightOffset
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
			.IF (NetSock)
				print "Error receiving data on socket.", 13, 10
				.IF (NetHosting)
					invoke Net_PlayerRemove, lpSock
					.BREAK
				.ELSE
					call Net_Close
				.ENDIF
			.ELSE
				ret
			.ENDIF
		.ELSEIF !(pax)
			print "Connection closed.", 13, 10
			.IF (NetHosting)
				print "Player disconnected. Socket:"
				print str$(lpSock), 13, 10
				invoke Net_PlayerRemove, lpSock
			.ELSE
				print "Server disconnected.", 13, 10
				call Net_Close
				mov UIPopupMenu, UIPP_SERVDISC
			.ENDIF	
			.BREAK
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

Net_SetColorBySkin PROC EXPORT PlayerSkin:BYTE, Alpha:REAL4
	LOCAL v4Val:Vector4
	
	bpMEM32 v4Val.W, Alpha
	
	movzx eax, PlayerSkin
	and eax, 1111b
	
	SWITCH eax
		CASE 0
			invoke Vector3Copy, ADDR v4Val, ADDR clWhite
		CASE 1
			invoke Vector3Set, ADDR v4Val, f(1), f(0.38), f(0.38)
		CASE 2
			invoke Vector3Set, ADDR v4Val, f(0.6), f(0.95), f(1.0)
		CASE 3
			invoke Vector3Set, ADDR v4Val, f(1), f(0.75), f(0.6)
		CASE 4
			invoke Vector3Set, ADDR v4Val, f(1), f(0.4), f(0.7)
		CASE 5
			invoke Vector3Set, ADDR v4Val, f(0.6), f(1), f(0.8)
		CASE 6
			invoke Vector3Set, ADDR v4Val, f(0.4), f(0.4), f(0.9)
		CASE 7
			invoke Vector3Set, ADDR v4Val, f(0.4), f(0.4), f(0.4)
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
Net_SetColorBySkin ENDP


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
			mov headPos.X, 0
			
			.IF (NetPlayersV[pbx].PlrState == PLAYER_STATE_EXITING)
				fld MazeDoorPos.Z
				fadd f(1.2)
				fsub NetPlayersVL[pbx].Position.Z
				fmul f(0.6)
				fstp headPos.X
				.IF !(headPos.X & FLT_NEG)
					mov headPos.X, 0
				.ENDIF
			.ELSEIF (MazeState == MAZE_STATE_HEDGE)
				.IF (rv(Maze_OnHedgePodium, ADDR NetPlayersVL[pbx].Position))
					bpMEM32 headPos.X, f(0.1)
				.ENDIF
			.ENDIF
			invoke glTranslatef, NetPlayersVL[pbx].Position.X, headPos.X, \
			NetPlayersVL[pbx].Position.Z
			
			; Draw shadow
			call glPushMatrix
			invoke glEnable, GL_BLEND
			invoke glDisable, GL_FOG
			;invoke glDisable, GL_LIGHTING
			invoke glDepthMask, GL_FALSE
			invoke glTranslatef, f(-0.5), f(0.01), f(-0.5)
			invoke glScalef, f(0.5), FLT_1, f(0.5)
			invoke glBlendFunc, GL_DST_COLOR, GL_ZERO
			invoke glBindTexture, GL_TEXTURE_2D, TexShadow
			invoke glCallList, MdlPlane
			invoke glDisable, GL_BLEND
			invoke glEnable, GL_FOG
			;invoke glEnable, GL_LIGHTING
			call glPopMatrix
			
			; Draw username
			call glPushMatrix
			invoke glTranslatef, 0, f(1.5), 0
			invoke glScalef, f(0.0025), f(-0.0025), f(0.0025)
			invoke glRotatef, CamBillboard.Y, 0, f(1), 0
			mov eax, CamBillboard.X
			xor eax, FLT_NEG
			invoke glRotatef, eax, f(1), 0, 0
			;invoke glDisable, GL_LIGHTING
			mov UIShadow, TRUE
			invoke UI_Text, ADDR NetPlayers[pbx].Username, 0, 0, \
			BP_ALIGN_CENTER, 0
			mov UIShadow, FALSE
			;invoke glEnable, GL_LIGHTING
			invoke glDepthMask, GL_TRUE
			call glPopMatrix
			
			invoke Net_SetColorBySkin, NetPlayers[pbx].Skin, FLT_1
			
			; Draw head
			invoke glEnable, GL_ALPHA_TEST
			;invoke glStencilFunc, GL_ALWAYS, 1, 0FFh
			;invoke glStencilMask, 0FFh
			;invoke glClear, GL_STENCIL_BUFFER_BIT
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
			.IF (SettingsGraphicsInterpolation)
				mov pax, pbx
				shr pax, NetPlayerShift
				shl pax, BPPtrShift
				invoke glVertexPointer, 3, GL_FLOAT, 0, \
				NetPlayersScarf[pax]
				invoke glTexCoordPointer, 2, GL_FLOAT, 0, MeshPlrScarf.TexCoords
				invoke glNormalPointer, GL_FLOAT, 0, MeshPlrScarf.Normals
				invoke glDrawArrays, GL_TRIANGLES, 0, MeshPlrScarf.Count
			.ELSE
				call glPushMatrix
				invoke glRotatefr, NetPlayersVL[pbx].BodyRot, 0, f(1), 0
				invoke glCallList, MdlPlrScarfStatic	; Draw static scarf
				call glPopMatrix
			.ENDIF
			invoke glEnable, GL_CULL_FACE
			
			;invoke glDisable, GL_LIGHTING
			;invoke glEnable, GL_STENCIL_TEST
			;invoke glDepthMask, GL_FALSE
			invoke glScalef, f(0.33), f(0.33), f(0.33)
			invoke glRotate2fv, ADDR CamBillboard
			invoke glBindTexture, GL_TEXTURE_2D, TexPlrHead
			invoke glCallList, MdlParticle
			call glPopMatrix
			;invoke glDepthMask, GL_TRUE
			;invoke glEnable, GL_LIGHTING
			
			; Draw body
			call glPushMatrix
			;invoke glStencilFunc, GL_NOTEQUAL, 1, 0FFh
			;invoke glStencilMask, 0
			invoke glRotatefr, NetPlayersVL[pbx].BodyRot, 0, f(1), 0
			invoke glBindTexture, GL_TEXTURE_2D, TexPlrBody
			pop pax
			invoke bpDrawMesh, ADDR NetPlayersMesh[pax]
			;invoke glDisable, GL_STENCIL_TEST
			call glPopMatrix			
			invoke glDisable, GL_ALPHA_TEST
			
			;invoke Net_SetColorBySkin, 0, FLT_1
			invoke glColor4fv, ADDR clWhite
			
			invoke glTranslate3fv, ADDR headPos
			invoke glRotatefr, NetPlayersVL[pbx].Rotation.Y, 0, FLT_1, 0
			
			; Draw items
			.IF (NetPlayersV[pbx].NetState & NPS_POWERUPS)
				call glPushMatrix
				invoke glTranslatef, f(-0.12), f(-1.2), f(0.15)
				invoke glBindTexture, GL_TEXTURE_2D, TexPowerups
				movzx pax, NetPlayersV[pbx].NetState
				shr pax, NPS_POWERUP_SHIFT-2
				sub pax, 4
				invoke glCallList, MdlPowerups[pax]
				call glPopMatrix
			.ENDIF
			.IF (NetPlayersV[pbx].NetState & NPS_COMPASS) || \
			(NetPlayersV[pbx].NetState & NPS_MAP)
				mov PlrProcessCompass, TRUE
				
				call glPushMatrix
				invoke glTranslatef, 0, f(-0.4), f(0.3)
				mov ax, NetPlayersV[pbx].NetState
				mov cx, ax
				and cl, NPS_COMPASS
				and al, NPS_MAP
				invoke Plr_DrawCompassMap, FALSE, al
				call glPopMatrix
			.ENDIF
			
			; Draw face
			invoke glRotatefr, NetPlayersVL[pbx].Rotation.X, FLT_1, 0, 0
			invoke glEnable, GL_BLEND
			invoke glBlendFunc, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA
			movzx eax, NetPlayersVL[pbx].FaceTex
			invoke glBindTexture, GL_TEXTURE_2D, eax
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

Net_Fixed PROC EXPORT
	LOCAL v3Val:Vector3
	
	; Animate players and their scarves
	push pbx
	xor pbx, pbx
	ASSUME pbx:PTR NetPlayerVolatile	
	.WHILE (pbx < SIZEOF NetPlayersV)
		.IF (NetPlayersVL[pbx].Visible & NET_VISIBLE_LOCAL)
			mov pax, pbx
			shr pax, NetPlayerShift
			mov pcx, SIZEOF BPAnimPlayer
			mul pcx
			invoke bpProcessAnimPlayer, ADDR NetPlayersAnim[pax], deltaFixed
			
			; Animate scarf
			.IF (SettingsGraphicsInterpolation)
				mov pcx, pbx
				shr pcx, NetPlayerShift
				shl pcx, BPPtrShift
				xor pdx, pdx
				.WHILE (pdx < MeshPlrScarf.V3Size)
					mov pax, pdx
					add pax, MeshPlrScarf.Vertices
					invoke Vector3Copy, ADDR v3Val, pax
					mov eax, NetPlayersVL[pbx].BodyRot
					xor eax, FLT_NEG
					invoke Rotate2DPoint, ADDR v3Val, eax
					
					fld v3Val.Y
					fmul st, st
					fdivr f(2)
					fmul deltaFixed
					fstp v3Val.Y
					
					fcmp v3Val.Y, f(1)	; Clamp
					.IF (!Carry?) || (Zero?)
						mov pax, NetPlayersScarf[pcx]
						add pax, pdx
						push v3Val.X
						pop REAL4 PTR [pax]
						push v3Val.Z
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
					push pax
					invoke DampedSpring, pax, REAL4 PTR [pcx], v3Val.X, f(0.9), f(0.7), v3Val.Y
					pop pax
					fld REAL4 PTR [pax]
					fmul v3Val.Y
					fadd REAL4 PTR [pcx]
					fstp REAL4 PTR [pcx]
					add pax, 8
					invoke DampedSpring, pax, REAL4 PTR [pcx+8], v3Val.Z, f(0.9), f(0.7), v3Val.Y
					fld REAL4 PTR [pax]
					fmul v3Val.Y
					fadd REAL4 PTR [pcx+8]
					fstp REAL4 PTR [pcx+8]
					
					pop pdx
					pop pcx
					
					add pdx, SIZEOF Vector3
				.ENDW
			.ENDIF
		.ENDIF
		
		add pbx, SIZEOF NetPlayerVolatile
	.ENDW
	ret
Net_Fixed ENDP

Net_Process PROC EXPORT
	LOCAL Dot:Vector3, ClPlr:BPPtr, Anim:BPPtr, OpenDoor:BYTE, Blink:BPBool
	
	fld NetVolatileTimer[0]
	fsub deltaUnscaled
	fstp NetVolatileTimer[0]
	.IF (NetVolatileTimer & FLT_NEG)
		fld NetVolatileTimer[0]
		fadd NetVolatileTimer[4]
		fstp NetVolatileTimer[0]
		
		.IF (NetHosting) || (NetEntitiesClient)
			mov NetEntitiesClient, FALSE
			
			; Continuously volatile entity states
			.IF (Kubale == KUBALE_ACTIVE) || (Wmblyk == WMBLYK_WALK) || \
			(HDL) || (Virdya)
				;print str$(SIZEOF NetMazeEntities), 13, 10
				invoke Net_FormSend, NET_MAZE_ENTITIES, NetSock
			.ENDIF
		.ENDIF
		
		.IF (NetHosting)
			invoke Net_FormSend, NET_PLAYERS_VOLATILE, 0
		.ELSE
			invoke Net_FormSend, NET_PLAYER_VOLATILE, NetSock
		.ENDIF
		
		mov eax, NetPlayerID
		.IF (Wmblyk == WMBLYK_STRANGLE) && (WmblykStrPlr == eax)
			invoke Net_FormSend, NET_MAZE_ENTITIES, NetSock
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
			
			mov eax, NetPlayers[pbx].PlayerID
			; Get if the player is visible at all (not a spectator)
			.IF (NetPlayersV[pbx].PlrState >= PLAYER_STATE_SPECTATE)
				mov NetPlayersVL[pbx].Visible, 0
				add pbx, SIZEOF NetPlayerVolatile
				.CONTINUE
			.ELSEIF (PlrState == PLAYER_STATE_SPECTATE) && (NetSpectateFP) && \
			(NetSpectateID == eax)
				mov NetPlayersVL[pbx].Visible, NET_VISIBLE_GLOBAL
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
				mov Blink, FALSE
				fld NetPlayersVL[pbx].BlinkTimer
				fsub deltaTime
				fstp NetPlayersVL[pbx].BlinkTimer
				fcmp NetPlayersVL[pbx].BlinkTimer, f(-0.1)
				.IF (Carry?)
					mov NetPlayersVL[pbx].BlinkTimer,rv(flRandRange,f(0.5),f(7))
					mov Blink, TRUE
				.ENDIF
			
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
					.IF (NetPlayersV[pbx].NetState & NPS_CROUCH)
						mov pax, OFFSET AnimPlrCrouchWalk
					.ELSE
						mov pax, OFFSET AnimPlrWalk
					.ENDIF
				.ELSE
					.IF (NetPlayersV[pbx].NetState & NPS_CROUCH)
						mov pax, OFFSET AnimPlrCrouch
					.ELSE
						invoke nRand, 5
						mov pdx, Anim
						mov pcx, pbx
						shr pcx, NetPlayerShift
						.IF ((Blink) && (!al) && (NetPlayersColl[pcx] != 2)) ||\
						(NetPlayersAnim[pdx].TrackPtr == OFFSET AnimPlrStretch)
							mov pax, OFFSET AnimPlrStretch
						.ELSE
							mov pax, OFFSET AnimPlrIdle
						.ENDIF
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
			
			; Collide
			xor pax, pax
			.IF (PlrState == PLAYER_STATE_GAME)
				mov Dot.Y, \
				rv(Vector32DDistanceSqr, ADDR CamPos, ADDR NetPlayersV[pbx].Position)
				invoke Collide_Distance, ADDR CamPos, \
				ADDR NetPlayersV[pbx].Position, f(0.2), Dot.Y
				mov pcx, pbx
				shr pcx, NetPlayerShift
				.IF (pax) && !(NetPlayersColl[pcx])
					mov NetPlayersColl[pcx], TRUE
				.ENDIF
			.ENDIF
			.IF (!pax)
				mov pcx, pbx
				shr pcx, NetPlayerShift
				mov NetPlayersColl[pcx], FALSE
			.ENDIF
			
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
			
			.IF !(NetPlayersVL[pbx].FaceTex)
				mov pcx, pbx
				shr pcx, NetPlayerShift
				.IF (NetPlayersVL[pbx].BlinkTimer & FLT_NEG)
					mov eax, TexPlrBlink
					mov NetPlayersVL[pbx].FaceTex, ax
					.IF (NetPlayersColl[pcx])
						mov NetPlayersColl[pcx], 2
						
					.ENDIF
				.ELSE
					movzx pax, NetPlayers[pbx].Skin
					and pax, 11110000b
					;shr pax, 4
					;mov pdx, 12
					;mul pdx
					add pax, OFFSET TexPlrFace1
					push pax
					.IF (NetPlayersColl[pcx] == 2)
						mov pax, 12
					.ELSE
						invoke Net_GetClosestPlr, \
						ADDR NetPlayersV[pbx].Position, NetPlayers[pbx].PlayerID
						mov ClPlr, pax
						
						mov Dot.Y, ecx
						fcmp Dot.Y, f(2)
						.IF (Carry?)
							mov pax, ClPlr
							invoke Vector32DCopy, ADDR Dot, \
							ADDR NetPlayersV[pax].Position
							invoke Vector32DSub, ADDR Dot, \
							ADDR NetPlayersV[pbx].Position
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
								mov pax, 4
							.ELSE
								fcmp Dot.X, f(-0.3)
								.IF (Carry?)
									mov pax, 8
								.ELSE
									xor pax, pax
								.ENDIF
							.ENDIF
						.ELSE
							xor pax, pax
						.ENDIF
					.ENDIF
					pop pcx
					mov eax, DWORD PTR [pcx+pax]
					mov NetPlayersVL[pbx].FaceTex, ax
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
	
	.IF (PlrState != PLAYER_STATE_EXITING)
		.IF (OpenDoor == 1)
			mov MazeDoorRot, rv(flLerp, MazeDoorRot, f(-104), delta2)
			fcmp MazeDoorRot, f(-100)
			.IF (Carry?)
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
		mov pbx, NetSpectateID
		shl pbx, NetPlayerShift
		invoke Vector3Copy, ADDR CamPos, ADDR NetPlayersVL[pbx].Position
		.IF (NetSpectateFP)
			invoke Vector3Copy, ADDR CamPosL, ADDR CamPos
			invoke Vector2Copy, ADDR CamRot, ADDR NetPlayersVL[pbx].Rotation
			invoke Vector2Copy, ADDR CamRotL, ADDR CamRot
		.ELSE
			invoke Vector3Sub, ADDR CamPos, ADDR CamForward
			invoke Vector3Copy, ADDR CamPosL, ADDR CamPos
		.ENDIF
	.ENDIF
	pop pbx
	ret
Net_Process ENDP
