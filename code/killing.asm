; this kill.exe should be marked as CW in 2Ah and GL in 2Ch

code segment
    assume cs: code
start: 
    jmp short begin
    fNAME db "KILL.EXE"
    by db "by Charlie",0
begin:
    mov ax, cs
    mov ds, ax
    
    call kill

    mov ax, 4c00h
    int 21h

kill proc near
    mov ah, 9
    lea dx, string		; message killing
    int 21h

    mov ah, 1ah
    lea dx, dta			; set data transfer address to dta
    int 21h

    mov ah, 4eh			; find first file
    lea dx, filename
    xor cx, cx			; read only
    int 21h

    jnc killing
    ret

killing proc near
    mov ax, 3d02h			; open file
    lea dx, dta				; filename extracted address
    add dx, 1eh			; 
    int 21h

    mov bx, ax				; file handle
    jnc readfile
    lea di, nextfile
    jmp di

readfile:
    mov ax, 4200h			; point to the start of file
    xor cx, cx
    xor dx, dx
    int 21h

    mov ah, 3fh				; copy header file
    lea dx, head
    mov si, dx				; head memory
    mov cx, 140h				; length
    int 21h

    					; check if file is exe and infected
    lea di, MZs
    mov ax, [di]
    cmp word ptr [si], ax
    je checkMark
    lea di, nextfile
    jmp di				; not exe
    
checkMark:
    lea di, markVirus
    mov ax, [di]
    cmp word ptr [si + 2ah], ax
    je checkDefendVirus
    lea di, nextfile
    jmp di				; not infected
    
    ; killing infected and exe file

checkDefendVirus:
    lea di, markDfnVirus
    mov ax, [di]
    cmp word ptr [si + 6ch], ax
    jne checkOriVirus

;equal means file defended
DefendVirus:
    ; just jump, don't do anything
    lea di, nextfile
    jmp di
    int 21h

checkOriVirus:
    lea di, markOriVirus
    mov ax, [di]
    cmp word ptr [si + 2ch], ax
    jne infectedExe
    
OriVirus:
    mov ah, 9
    lea dx, virusexeDetected
    int 21h

    ; delete virus exe file
    ; and continue find next file
    mov ah, 41h 			; delete
    lea dx, dta
    add dx, 1eh
    int 21h
    lea di, nextfile
    jmp di

infectedExe:
    mov ah, 9
    lea dx, virusDetected
    int 21h

    lea di, dta + 1eh
    printingName:
	mov ah, 2
	xor dx, dx
	mov dl, [di]
	int 21h
	inc di
	mov ah, [di]
	cmp ah, '.'
	jne printingName

    lea dx, format
    mov ah, 9
    int 21h

    mov ah, 9
    lea dx, enter
    int 21h

    mov ax, 4200h			; point to the start file
    xor cx, cx
    xor dx, dx
    int 21h

    mov ah, 40h				; revive 30h header
    mov cx, 70h				; 70 bytes
    lea dx, head			; copy real head to head
    add dx, 70h				; true address of ori head
    int 21h

    mov ax, 4200h
    xor cx, cx
    mov dx, 70h				; point to offset 70h to zeroing
    int 21h

    mov ah, 40h				; delete all modified data,  write instruction
    mov cx, 70h				; length
    lea dx, zeroing
    int 21h

    ; jump to virus start
    ; zeroing?? or adjust the size??
    ; or the size auto change back???
    ; let's see

; wrong!!!

; calculate ori file size
    lea di, head
    
    mov ax, [di + 74h]
    mov cx, 200h
    mul cx
    
    mov cx, [di + 72h]
    add ax, cx
    adc dx, 0

; dx:ax now is size of infected file, need to be substract with 200h
    sub ax, 200h
    sbb dx, 0

; now it is size
    mov cx, dx
    mov dx, ax		; offset from start in order to point end of file
    mov ax, 4200h 	; pointer from start
    int 21h

    mov ah, 40h
    xor cx, cx
    int 21h

; !wrong below
;    lea di, head
;    mov ax, 4200h
;    xor cx, cx
;    mov dx, [di + 14h] ; move pointer to the start of virus
;    add dx, 200h 
;    int 21h

;    mov ah, 40h
;    xor cx, cx		; cx = 0, truncate
;    int 21h

killing endp

nextfile:
    mov ah, 3eh			; close file
    int 21h

    mov ah, 4fh 		; next file
    int 21h

    jc returning
    lea di, killing
    jmp di
returning:
    ret
kill endp

data:
string db "Killing virus!",13,10,"$"
MZs db "MZ"
markVirus db "CW"
markDfnVirus db "DF"
markOriVirus db "GL"
filename db "*.exe",0
virusDetected db "Virus detected in file : $"
virusexeDetected db "virus.exe detected! Deleting!",13,10,'$'
format db ".exe",13,10,'$'
enter db 13,10,'$'
dta db 02bh dup (0)
head db 140h dup (0)		; based on virus header, ori header in 2eh ~ 2eh + 30h
zeroing db 70h dup (0)		; 140h - 70h

code ends
end start