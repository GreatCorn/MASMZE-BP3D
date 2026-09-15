.CODE

; Clear HeapStack object (set length to PTR)
HSClear PROC hStack:BPPtr
	mov pax, hStack
	mov BPPtr PTR [pax], SIZEOF BPPtr
	ret
HSClear ENDP

; Create HeapStack object with dwCount positions
HSCreate PROC dwCount:DWORD
	mov pax, dwCount
	add pax, 1
	shl pax, 2
	
	invoke bpMalloc, bpDefHeap, 0, pax
	mov BPPtr PTR [pax], SIZEOF BPPtr
	ret
HSCreate ENDP

; Free HeapStack object
HSFree PROC hStack:BPPtr
	invoke bpFree, bpDefHeap, 0, hStack
	ret
HSFree ENDP

; Pop from HeapStack object into pax
HSPop PROC hStack:BPPtr
	mov pax, hStack
	sub BPPtr PTR [pax], SIZEOF BPPtr
	mov pcx, BPPtr PTR [pax]
	mov pax, BPPtr PTR [pax+pcx]
	ret
HSPop ENDP

; Push hValue to HeapStack
HSPush PROC hStack:BPPtr, hValue:BPPtr
	mov pax, hStack
	mov pcx, BPPtr PTR [pax]
	push hValue
	pop BPPtr PTR [pax+pcx]
	add BPPtr PTR [pax], SIZEOF BPPtr
	ret
HSPush ENDP
