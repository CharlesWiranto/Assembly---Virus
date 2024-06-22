data segment
    msg db "hello, world!",13,10,'$'
data ends

stack segment
    dw 8 dup (0)
stack ends

code segment
    assume cs: code, ds: data, es: data, ss: stack
main proc far
start:
    mov ax, data
    mov ds, ax
    mov es, ax
    
    mov ah, 9
    mov dx, offset msg
    int 21h
    
    mov ax, 4c00h
    int 21h
main endp
code ends

end start