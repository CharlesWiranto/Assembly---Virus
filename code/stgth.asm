.model small
.stack 100h

.data
filename db 'virus.exe', 0  
mark db "CWGL"              

.code
main:
    mov ax, @data
    mov ds, ax
    mov es, ax

    mov ah, 3Dh		; open file
    mov al, 2  		; Read/Write access
    lea dx, filename
    int 21h
    jc error   
    mov bx, ax ; File handle

    mov ah, 42h		; point to start
    mov al, 0  
    mov cx, 0  
    mov dx, 2ah 
    int 21h
    jc error   

    mov ah, 40h		; write mark
    mov cx, 4   
    lea dx, mark
    int 21h
    jc error   

    mov ah, 3Eh		; close file
    int 21h
    jc error   

    mov ax, 4C00h
    int 21h

error:
    
    mov ax, 4C01h
    int 21h

end main
