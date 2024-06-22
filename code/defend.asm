assume cs:codesg
codesg segment
start: 
    mov ax, cs
    mov ds, ax
    mov si, offset newint21start

    mov ax, 0
    mov es, ax
    mov di, 210h
    
    mov cx, offset  newint21end - offset newint21start

    cld
    rep movsb				;ds:[si]->es:[di]

    mov ax, 0
    mov es, ax

    cmp word ptr es:[0200h],0
    jnz end1

    mov bx ,word ptr es:[21h * 4] 	; int 21h
    mov word ptr es:[80h * 4], bx	; int 80h
    mov bx ,word ptr es:[21h * 4 + 2]	; int 21h
    mov word ptr es:[80h * 4 + 2],bx	; int 80h

    mov word ptr es:[21h * 4], 210h	; modified int 21h
    mov word ptr es:[21h * 4 + 2],0

end1:
    mov ax, 4c00h

    int 80h 

newint21start:
    jmp realStart
    string1 db "Virus detected!",13,10,'$'
    string2 db "Virus has been killed!",'$'
    head db 70h dup(0) 
    zr db 00h
realStart:
    sti
    push ax 
    push bx 
    push cx 
    push dx 
    push ds
    push es
    push bp 

    cmp word ptr ds:[bp+2],5743H ; CW 
    je virus
normal:
    pop bp
    pop es  
    pop ds  
    pop dx  
    pop cx  
    pop bx  
    pop ax 
    int 80h
    push ax 
    push bx 
    push cx 
    push dx 
    push ds
    push es
    push bp
    jmp exit 
virus:
    mov dx,bp 
    cmp dx,0
    jz orignal_virus

    add dx,031Bh  		; name position
    jmp kill   
orignal_virus:   
    add dx,4			; "VIRUS.EXE" string position

    pop bp
    pop es  
    pop ds  
    pop dx  
    pop cx  
    pop bx  
    pop ax 

    mov ax, cs
    mov ds, ax

    mov dx, offset string1 - offset newint21start + 210h
    mov ah,09h 
    int 80h 

    mov ax, 4c00h
    int 80h
kill:
    push si   

    mov ax,3d02h
    int 80h

    xchg ax,bx

    mov ax,4200h
    xor cx,cx
    xor dx,dx
    add dx, 70h
    int 80h

    mov ax,cs 
    mov ds,ax

    mov ah,3fh
    mov cx,70h 
    mov dx,offset head - offset newint21start + 210h
    mov si,dx
    int 80h 

    ;mov word ptr [si + 2ah], 0000h

    ;mov ax,word ptr [si + 2eh] 
    ;mov word ptr [si + 14h],ax

    ;mov ax,word ptr [si + 28h] 
    ;mov word ptr [si + 16h],ax

infectedExe:

    mov ax,4200h  
    xor cx,cx
    xor dx,dx
    int 80h

    ; write 70h head

    mov ah, 40h
    mov dx, si
    mov cx, 70h    
    int 80h   

    mov ax, 4200h
    xor cx, cx
    mov dx, 70h
    int 80h

    mov cx, 70h
    zeros:
	push cx
	mov ah, 40h
	mov cx, 1
	mov dx, offset zr - offset newint21start + 210h
	int 80h
	pop cx
	loop zeros

    xor dx, dx
    mov ax, [si + 4h]

    mov cx, 200h
    mul cx
    
    mov cx, [si + 2h]
    add ax, cx
    adc dx, 0

    sub ax, 200h
    sbb dx, 0

    ; now it is size
    mov cx, dx
    mov dx, ax
    mov ax, 4200h
    int 80h

    ; truncate
    mov ah, 40h
    xor cx, cx
    int 80h

    mov ah, 3eh
    int 80h

    pop si  

printmes:
    
    mov dx, offset string1 - offset newint21start + 210h
    mov ah,09h 
    int 80h 

    add dx,offset string2 - offset string1
    mov ah,09h 
    int 80h

    mov ax,4c00h 
    int 80h  
exit:
    pop bp
    pop es  
    pop ds  
    pop dx  
    pop cx  
    pop bx  
    pop ax
    cli  
    iret
newint21end:nop

codesg ends

end start
