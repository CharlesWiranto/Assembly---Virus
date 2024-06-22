data segment
data ends
stack segment
stack ends
code segment
        assume ds:data,ss:stack,cs:code
start:
        mov ax,data
        mov ds,ax
 
        call find
 
        mov ah,4ch
        int 21h
 
    find proc
        mov cx,101
      find1:
        sub cx,1
        
 
	cmp cx,0
        je endd
 
        cmp cx,2
        jbe su
 
        mov dl,cl
      dive:
	dec dl
	mov ax,cx
	cmp dl,1
	je su
        div dl
        cmp ah,0
        je find1
        jmp dive
      su:
	mov ax,cx
	mov bl,10
	div bl;余数在ah，商在al
	mov dx,ax
	add dx,3030h;转化成十\个位对应的ASCII码
	mov ah,2
	int 21h
	mov dl,dh
	mov ah,2
	int 21h
	mov ax,0200h
	mov dl,' '
	int 21h
        jmp find1
      endd:
        ret
        find endp
code ends
end start