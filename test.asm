
;program to render 8bpp bmp files 320x200 res
.model small
.stack 100h
.data
    buff       db 400h  dup (?)		
	filehandle dw 0
	;filename   db 255 	dup (0)
	filename   db "min.bmp", 0
    header     db 36h   dup (0)      ; 14 + 40 = 54 (36h) bytes
    palette    db 400h  dup (0)      ;256 * 4 1024 (400h)
    line	   db 320   dup (0)   	 ;image 320 px wide
	msg 	   db "Ivyko klaida...$"
	fileErr    db "Nepavyko atidaryti failo $"

.code
start:
    mov ax, @DATA
	mov ds, ax

  ;  xor cx,cx
   ; mov cl,es:[80h] ;amount of inline inputed chars

  ;  mov si,0082h ;0082h beginning of argv
  ;  xor bx,bx
;copy:

   ; mov al,es:[si + bx]
  ;  mov ds:[filename + bx],al ;copy filename from es to variable
   ; inc bx
  ;  loop copy

  ;  mov al, 24h
  ;  mov ds:[filename + bx], al  ;add '$' at the end of string



    ;;;;;;;;;;;;;;
    ;open file
	
	mov dx, offset filename	;DS:DX -> ASCIZ filename
	mov ah, 3dh				;open file
	mov al, 0				;AL = mode
	int 21h	
	mov filehandle, ax	

   	mov ah, 09h
  	mov dx,offset filename ;what to print
  	int 21h

	jc openError
	jmp continue
openError:
	mov ah, 9
	mov dx, offset fileErr
	int 21h
	mov ax, 4c00h
	int 21h		

continue:
    mov ax, 13h             ;video mode
    int 10h
    ;;;;;;;;;;;;;;;;;
	;read bmp header
	mov ah,  3fh			;read int
	mov bx,  filehandle		;BX = file handle
	mov cx, 36h			    ;CX = number of bytes to read
	mov dx, offset header	
	int 21h

	jc error 
    ;;;;;;;;;;;;;;;;;;
	;read color palette. (read 256 (NumColors) * 4(R G B reserved) = 400h)
    mov ah, 3fh
    mov cx, 400h
    mov dx, offset palette
    int 21h
    
    jc error
    jmp load
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
error:
	mov ah, 9
	mov dx, offset msg
	int 21h
	mov ax, 4c00h
	int 21h	
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load:
	;load color palette to the vga port
	mov cx, 256
	mov di, offset palette

	mov al, 0  
	mov dx, 3c8h	; send to port 3c8 index of the first color
	out dx, al

	inc dx       ; dx == 3c9h; to actually add colors 
colors:    ;colors are saved in inverted order; blue green red
	mov al,[di + 2] ; r val
	out dx, al

	mov al, [di + 1] ; g val
	out dx, al

	mov al, [di] ; b val
	out dx, al

	add di, 4		; to skip reserved byte and go to another red val
	loop colors

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;print pixels to the screen 
	
    mov ax, 0A000h  ;in the 13h mode screen address is A000
    mov es, ax
    mov cx, 200      ;we have to print 200 lines so loop will work 200 times
print:
    push cx			;tis loop is to move lines of pixels to a video memory 

	mov ax, 320  	;set di to the actual line
	mul cx
	mov di, ax

    mov ah,3fh		
    mov cx,140h		;320 px
    mov dx,offset line
    int 21h

    cld  ; CLear Direction flag to increment si di in movsb 
    mov cx, 320
    mov si, offset line
    rep movsb ;in this "loop" byte is moved from DS:SI to ES:DI cx times
	

    pop cx
    loop print


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov ah, 3eh 			    ;close file
	mov bx, offset filehandle	;BX = file handle
	int 21h

closeProgram: 
 	mov ah, 4ch               
 	int 21h  
end start