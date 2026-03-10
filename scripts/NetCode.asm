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
	
	call Net_LobbyInit
	
	invoke CreateThread, NULL, 0, OFFSET Net_ProcessLoop, NetSock, 0, NULL
	ret
Net_Connect ENDP

Net_FormPlrPopup PROC EXPORT UNamePtr:BPPtr, Connected:BPBool
	LOCAL strPtr:BPPtr
	.IF (Connected)
		bpMPM strPtr, StrMenuJoined
	.ELSE
		bpMPM strPtr, StrMenuLeft
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
	mov pcx, Buffer
	
	.IF (BYTE PTR [pcx] == NET_PLAYERS_REQUEST)
		;print "NET_PLAYERS_REQUEST", 13, 10
		.IF (NetHosting)
			; Get first free player slot and fill new player struct
			xor pax, pax
			.WHILE (pax < SIZEOF NetPlayers)
				.IF (NetPlayers[pax].PlayerID == -1)
					push pax
					inc pcx
					invoke RtlMoveMemory, ADDR NetPlayers[pax], pcx, \
					SIZEOF NetPlayer
					pop pax
					
					mov pcx, pax
					shr pcx, NetPlayerShift
					
					; Fill new player struct with accurate values
					mov NetPlayers[pax].PlayerID, ecx
					mov ecx, Sock
					mov NetPlayers[pax].SockOnServ, ecx
					.BREAK
				.ENDIF
				add pax, SIZEOF NetPlayer
			.ENDW
			
			invoke Net_FormPlrPopup, ADDR NetPlayers[pax].Username, TRUE
			
			invoke Net_FormSend, NET_PLAYERS_RESPONSE, Sock
		.ENDIF
	.ELSEIF (BYTE PTR [pcx] == NET_PLAYERS_RESPONSE)
		;IFDEF MODE_DEBUG
		;push pcx
		;print "NET_PLAYERS_RESPONSE", 13, 10
		;pop pcx
		;ENDIF
		
		.IF (NetPlayerID == -1)
			bpMEM32 NetPlayerID, DWORD PTR [pcx+1]
			bpMEM32 NetMagic, DWORD PTR [pcx+5]
			
			IFDEF MODE_DEBUG
			push pcx
			print "Connected, player ID: "
			print str$(NetPlayerID), 13, 10
			pop pcx
			ENDIF
		.ENDIF
		add pcx, 9
		invoke RtlMoveMemory, ADDR NetPlayers, pcx, SIZEOF NetPlayers
	.ELSEIF (BYTE PTR [pcx] == NET_PLAYER_VOLATILE)
		;IFDEF MODE_DEBUG
		;push pcx
		;print "NET_PLAYER_VOLATILE", 13, 10
		;pop pcx
		;ENDIF
		
		inc pcx
		mov eax, DWORD PTR [pcx]
		shl pax, NetPlayerVShift
		invoke RtlMoveMemory, ADDR NetPlayersV[pax],pcx,SIZEOF NetPlayerVolatile
	.ELSEIF (BYTE PTR [pcx] == NET_PLAYERS_VOLATILE)
		;IFDEF MODE_DEBUG
		;push pcx
		;print "NET_PLAYERS_VOLATILE", 13, 10
		;pop pcx
		;ENDIF
		
		inc pcx
		invoke RtlMoveMemory, ADDR NetPlayersV, pcx, SIZEOF NetPlayersV
	.ENDIF
	ret
Net_FormRespond ENDP

; Form and send message
Net_FormSend PROC EXPORT MsgType:BYTE, Sock:SOCKET
	LOCAL buf[NET_BUFFER_SIZE]:BYTE, globalMsg:BPBool
	
	mov globalMsg, FALSE
	;print "Sending "
	mov al, MsgType
	mov buf[0], al
	.IF (al == NET_PLAYERS_REQUEST)
		invoke RtlMoveMemory, ADDR buf[1], ADDR NetPlayers[0], SIZEOF NetPlayer
	.ELSEIF (al == NET_PLAYERS_RESPONSE)
		;print "NET_PLAYERS_RESPONSE"
		; Get first free player slot
		xor pax, pax
		mov ecx, Sock
		.WHILE (pax < SIZEOF NetPlayers)
			.IF (NetPlayers[pax].SockOnServ == ecx)
				.BREAK
			.ENDIF
			add pax, SIZEOF NetPlayer
		.ENDW
		shr pax, NetPlayerShift
		mov DWORD PTR buf[1], eax
		bpMEM32 DWORD PTR buf[5], NetMagic
		invoke RtlMoveMemory, ADDR buf+9, ADDR NetPlayers, SIZEOF NetPlayers
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
	.ENDIF
	.IF (globalMsg)
		;print " GLOBAL"
		mov pcx, SIZEOF NetPlayer	; NetPlayers[0] is host
		.WHILE (pcx < SIZEOF NetPlayers)
			mov pax, Sock
			mov pdx, NetSock
			.IF (NetPlayers[pcx].PlayerID != -1) \	; Don't send to non-players
			&& (NetPlayers[pcx].SockOnServ != pax) ;\; Don't send to target yet
			;&& (NetPlayers[pcx].SockOnServ != pdx)	; Don't send to yourself
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
	; Sock may not yet be on NetPlayers list so special treatment
	.IF (Sock)
		;print " TO "
		;print str$(Sock), 13, 10
		invoke send, Sock, ADDR buf, NET_BUFFER_SIZE, 0
	.ENDIF
	ret
Net_FormSend ENDP

Net_GetClosestPlr PROC EXPORT PosPtr:BPPtr, ExcludeID:DWORD
	LOCAL closest:BPPtr, dist:REAL4, lastDist:REAL4
	
	mov closest, 0
	mov lastDist, FLT_INF
	push pbx
	xor pbx, pbx
	.WHILE (pbx < SIZEOF NetPlayersVL)
		mov eax, ExcludeID
		.IF (NetPlayersV[pbx].PlayerID != eax) \
		&& (NetPlayersV[pbx].PlayerID != -1)
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

Net_LobbyInit PROC EXPORT
	mov UITextPopupStr, 0
	
	mov GameState, GAME_STATE_LOBBY
	mov PlrCanControl, TRUE
	mov MazeCheck, MAZE_CHECK_SAVED
	
	mov PlrState, PLAYER_STATE_GAME
	
	mov UIFade, UI_FADE_IN
	mov UIFadeCallback, 0
	mov UIFadeVal, FLT_1

	invoke Vector3Set, ADDR MazeCheckPos, 0, 0, 0
	invoke Vector3Set, ADDR MazeDoorPos, f(1), CamHeight, f(5)
	invoke Plr_Teleport, f(1), f(4)
	
	mov PollProc, OFFSET GameInit
	ret
Net_LobbyInit ENDP

Net_PlayerRemove PROC EXPORT SockOnServ:DWORD
	xor pax, pax
	mov pcx, SockOnServ
	.WHILE (pax < SIZEOF NetPlayers)
		.IF (NetPlayers[pax].SockOnServ == pcx)
			mov NetPlayers[pax].PlayerID, -1
			;shr pax, NetPlayerShift
			;shl pax, NetPlayerVShift
			mov NetPlayersV[pax].PlayerID, -1
			.BREAK
		.ENDIF
		add pax, SIZEOF NetPlayer
	.ENDW
	invoke Net_FormPlrPopup, ADDR NetPlayers[pax].Username, FALSE
	dec NetPlayersCount
	
	invoke Net_FormSend, NET_PLAYERS_RESPONSE, 0
	ret
Net_PlayerRemove ENDP

Net_PlayersClear PROC EXPORT
	xor pax, pax
	.WHILE (pax < SIZEOF NetPlayers)
		mov NetPlayers[pax].PlayerID, -1
		mov NetPlayersV[pax].PlayerID, -1
		add pax, SIZEOF NetPlayer
	.ENDW
	ret
Net_PlayersClear ENDP

Net_PopulateVolatile PROC EXPORT NPVPtr:BPPtr
	mov pcx, NPVPtr
	ASSUME pcx:PTR NetPlayerVolatile

	bpMEM32 [pcx].PlayerID, NetPlayerID
	bpMEM32 [pcx].MazeLayer, MazeLayer
	bpMEM32 [pcx].NetState, PlrState
	invoke RtlMoveMemory, ADDR [pcx].Position, ADDR CamPosL, 12
	mov pcx, NPVPtr
	invoke RtlMoveMemory, ADDR [pcx].Rotation, ADDR CamRotL, 8
	
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


Net_Draw PROC EXPORT
	; Draw players
	push pbx
	xor pbx, pbx
	ASSUME pbx:PTR NetPlayerVolatile
	.WHILE (pbx < SIZEOF NetPlayersV)
		mov eax, NetPlayerID
		mov ecx, MazeLayer
		.IF (NetPlayersV[pbx].PlayerID != eax) \
		&& (NetPlayersV[pbx].PlayerID != -1) \
		&& (NetPlayersV[pbx].MazeLayer == ecx)
			call glPushMatrix
			invoke glTranslate32Dfv, ADDR NetPlayersVL[pbx].Position
			
			call glPushMatrix
			push bpFontWidth
			push bpFontHeight
			bpMEM32 bpFontWidth, 2
			bpMEM32 bpFontHeight, 1
			invoke glScalef, f(0.5), f(0.5), f(0.5)
			invoke glRotatef, CamBillboard.Y, 0, f(1), 0
			invoke glRotatef, CamBillboard.X, f(1), 0, 0
			invoke glDisable, GL_CULL_FACE
			invoke bpRenderText, ADDR NetPlayers[pbx].Username, 0, -24, \
			BP_ALIGN_CENTER, 0
			invoke glEnable, GL_CULL_FACE
			pop bpFontHeight
			pop bpFontWidth
			call glPopMatrix
			
			invoke glEnable, GL_ALPHA_TEST
			invoke glEnable, GL_STENCIL_TEST
			invoke glStencilFunc, GL_ALWAYS, 1, 0FFh
			invoke glStencilMask, 0FFh
			invoke glClear, GL_STENCIL_BUFFER_BIT
			call glPushMatrix
			invoke glTranslatef, 0, CamHeight, 0
			invoke glScalef, f(0.4), f(0.4), f(0.4)
			invoke glRotatef, CamBillboard.Y, 0, f(1), 0
			invoke glRotatef, CamBillboard.X, f(1), 0, 0
			invoke glBindTexture, GL_TEXTURE_2D, TexPlrHead
			invoke glCallList, MdlParticle
			call glPopMatrix
			invoke glDisable, GL_ALPHA_TEST
			
			invoke glStencilFunc, GL_NOTEQUAL, 1, 0FFh
			invoke glStencilMask, 0
			invoke glRotatefr, NetPlayersVL[pbx].Rotation.Y, 0, f(1), 0
			invoke glBindTexture, GL_TEXTURE_2D, TexPlrBody
			invoke glCallList, MdlPlrBody
			invoke glDisable, GL_STENCIL_TEST
			
			invoke glEnable, GL_BLEND
			invoke glBlendFunc, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA
			invoke glTranslatef, 0, CamHeight, 0
			.IF (NetPlayersVL[pbx].BlinkTimer & FLT_NEG)
				mov eax, TexPlrBlink
			.ELSE
				mov eax, NetPlayersVL[pbx].FaceTex
			.ENDIF
			invoke glBindTexture, GL_TEXTURE_2D, eax
			invoke glRotatefr, NetPlayersVL[pbx].Rotation.X, f(1), 0, 0
			invoke glCallList, MdlPlrAcc
			invoke glDisable, GL_BLEND
			
			call glPopMatrix
		.ENDIF
		add pbx, SIZEOF NetPlayerVolatile
	.ENDW
	ASSUME pbx:nothing
	pop pbx
	ret
Net_Draw ENDP

Net_Process PROC EXPORT
	LOCAL Dot:Vector3, ClPlr:BPPtr
	
	fld NetVolatileTimer[0]
	fsub deltaUnscaled
	fstp NetVolatileTimer[0]
	.IF (NetVolatileTimer & FLT_NEG)
		fld NetVolatileTimer[0]
		fadd NetVolatileTimer[4]
		fstp NetVolatileTimer[0]
		
		.IF (NetHosting)
			invoke Net_FormSend, NET_PLAYERS_VOLATILE, 0
		.ELSE
			mov ecx, NetSock
			invoke Net_FormSend, NET_PLAYER_VOLATILE, ecx
		.ENDIF
	.ENDIF
	
	push pbx
	xor pbx, pbx
	ASSUME pbx:PTR NetPlayerVolatile
	.WHILE (pbx < SIZEOF NetPlayersV)
		mov eax, NetPlayerID
		.IF (NetPlayersV[pbx].PlayerID != eax) \
		&& (NetPlayersV[pbx].PlayerID != -1)
			invoke Vector3Lerp, ADDR NetPlayersVL[pbx].Position, \
			ADDR NetPlayersV[pbx].Position, delta20
			invoke Vector2LerpAngle, ADDR NetPlayersVL[pbx].Rotation, \
			ADDR NetPlayersV[pbx].Rotation, delta20
			mov NetPlayersVL[pbx].Rotation.Y, \
			rv(flAngle, NetPlayersVL[pbx].Rotation.Y)
		
			invoke Net_GetClosestPlr, ADDR NetPlayersV[pbx].Position, \
			NetPlayersV[pbx].PlayerID
			mov ClPlr, pax
			
			mov Dot.Y, ecx
			fcmp Dot.Y, f(2)
			.IF (Carry?)
				mov pax, ClPlr
				invoke Vector32DCopy, ADDR Dot, ADDR NetPlayersV[pax].Position
				invoke Vector32DSub, ADDR Dot, ADDR NetPlayersV[pbx].Position
				;invoke Vector32DNormalize, ADDR Dot
				fld NetPlayersV[pbx].Rotation.Y
				fsincos
				fmul Dot.X
				fxch
				fmul Dot.Z
				fsub
				fstp Dot.X
				print real4$(Dot.X), 13, 10
				fcmp Dot.X, f(0.3)
				.IF (!Carry?)
					bpMEM32 NetPlayersVL[pbx].FaceTex, TexPlrLeft
				.ELSE
					fcmp Dot.X, f(-0.3)
					.IF (Carry?)
						bpMEM32 NetPlayersVL[pbx].FaceTex, TexPlrRight
					.ELSE
						bpMEM32 NetPlayersVL[pbx].FaceTex, TexPlrNeut
					.ENDIF
				.ENDIF
				
				invoke Collide_Distance, ADDR CamPos, \
				ADDR NetPlayersV[pbx].Position, f(0.3), Dot.Y
			.ELSE
				bpMEM32 NetPlayersVL[pbx].FaceTex, TexPlrNeut
			.ENDIF
			
			
			fld NetPlayersVL[pbx].BlinkTimer
			fsub deltaTime
			fstp NetPlayersVL[pbx].BlinkTimer
			fcmp NetPlayersVL[pbx].BlinkTimer, f(-0.1)
			.IF (Carry?)
				mov NetPlayersVL[pbx].BlinkTimer, rv(flRandRange, f(0.5), f(7))
			.ENDIF
		.ENDIF
		
		add pbx, SIZEOF NetPlayerVolatile
	.ENDW
	ASSUME pbx:nothing
	pop pbx
	ret
Net_Process ENDP
