;argv and argc in Assembly
.model small
.stack 100h

.data
    endl db 0Dh,0Ah, 24h
    filename db 255 dup(0)

.code

start:
    mov dx,@data
    mov ds,dx

    xor cx,cx
    mov cl,es:[80h] ;amount of inline inputed chars

    mov si,0082h ;0082h beginning of argv
    xor bx,bx
copy:

    mov al,es:[si + bx]
    mov ds:[filename + bx],al ;copy filename from es to variable
    inc bx
    loop copy

    mov al, 24h
    mov ds:[filename + bx], al  ;add '$' at the end of string

  ;  mov ah, 09h
   ; mov dx,offset filename ;what to print
  ;  int 21h

exit:
    mov dx, offset endl
    mov ah, 09h
    int 21h


    mov ah, 4ch
    mov al, 0
    int 21h

end start

