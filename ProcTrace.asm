; Barebones debug procedure rdtsc tracer through custom prologue & epilogue
; Specify files to trace their procedures, or define PROC_TRACE_ALL
;TraceFiles TEXTEQU <!<\
;						main.asm,\
;					!>>
IFDEF PROC_TRACE
	option prologue:PROCP
	option epilogue:PROCE
ENDIF

PROCP MACRO procname, flag, parmbytes, localbytes, reglist, userparms
	LOCAL addbytes, newlocal, trace
	; enter
	newlocal = localbytes + 8
	
	IF newlocal or parmbytes
		push ebp
		mov ebp,esp
	ENDIF
	IF newlocal
		IF (flag AND 16) EQ 0
			addbytes = 0 - newlocal	; replicate weird MASM behavior
			add esp, addbytes		; sub esp, newlocal
		ENDIF
	ENDIF
	; USES registers
	IFNB <reglist>
		FOR r, reglist
			push r
		ENDM
	ENDIF
	
	IFDEF PROC_TRACE_ALL
		trace = 1
	ELSE
		trace = 0
		%FOR fn, TraceFiles
			IFIDNI @FileCur, <fn>
				trace = 1
			ENDIF
		ENDM
	ENDIF
	
	IF trace
		push eax
		push edx
		rdtsc
		mov DWORD PTR [ebp-8], eax
		mov DWORD PTR [ebp-12], edx
		pop edx
		pop eax
	ENDIF
	
	EXITM %newlocal
ENDM
PROCE MACRO procname, flag, parmbytes, localbytes, reglist, userparms
	LOCAL newlocal, procsym, procstr, trace
	
	IFDEF PROC_TRACE_ALL
		trace = 1
	ELSE
		trace = 0
		%FOR fn, TraceFiles
			IFIDNI @FileCur, <fn>
				trace = 1
			ENDIF
		ENDM
	ENDIF
	IF trace
		push eax
		push edx
		rdtsc
		sub eax, DWORD PTR [ebp-8]
		sub edx, DWORD PTR [ebp-12]
		procsym CATSTR <procname>,<NameStr>
		procstr CATSTR <">,<procname>,<">
		%IFNDEF procsym
			.DATA
			procsym DB procstr, 0
			.CODE
		ENDIF
		pushad
		print OFFSET procsym, 9
		popad
		pushad
		print str$(eax), 13, 10
		popad
		pop edx
		pop eax
	ENDIF
	
	newlocal = localbytes + 8
	; USES registers
	IFNB <reglist>
		FOR r, reglist
			pop r
		ENDM
	ENDIF
	; leave
	IF newlocal or parmbytes
		leave
	ENDIF
	IF (flag AND 16)
		ret
	ELSE
		ret parmbytes
	ENDIF
ENDM
