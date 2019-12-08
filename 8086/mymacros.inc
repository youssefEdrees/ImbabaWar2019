;-----------------macros------
showmessage macro mymessage
            mov ah,9h
            mov dx,offset mymessage
            int 21h
endm showmessage              
;------------draw rect-----------
drawrect macro x,y,l,w,c		;drawRect ax , cx , bx , 20 , 02h ;1st prog bar health green
    local l1,l2
    push ax
    push bx
    push dx
    

    mov bx , x
    add bx , l
    mov al , c
    mov cx , x
    mov dx , y
    mov ah , 0ch
    
    l1: int 10h
        add dx , w
        int 10h
        sub dx , w
        inc cx
        cmp cx , bx
        jnz l1
    
    mov bx , y
    add bx , w
    
    l2: int 10h
        sub cx , l
        int 10h
        add cx , l
        inc dx
        cmp dx , bx
        jbe l2
	
	
        pop dx
        pop bx
        pop ax
endm    drawrect
;------------draw solid rect-----------
drawsolidrect macro x,y,l,w,c
    local l1,l2
    push ax
    push bx
    push dx
    push di	
    mov dx , y
    mov cx , x
    mov al , c
    mov bx , x
    add bx , l
    mov di , y
    add di , w
    l2: mov ah,0ch
	int 10h
        inc cx
        cmp cx , bx
        jbe l2
    l1: inc dx
        mov cx , x
        cmp dx , di
        jbe l2
    pop di
    pop dx
    pop bx
    pop ax
endm    drawsolidrect
;----------main menu--------------
mainmenu macro mymessage,fitmess,secmess
showmessage mymessage
showmessage fitmess
mov ah,9          ;display
mov bh,0          ;page 0
mov al,50h        ;letter p
mov cx,1h         ;1 times
mov bl,048h        ;green (p) on white(f) background
int 10h 
showmessage secmess
mov ah,9          ;display
mov bh,0          ;page 0
mov al,43h        ;letter c
mov cx,1h         ;1 times
mov bl,028h        ;red (c) on white(f) background
int 10h

endm    mainmenu
;---------inc prog bar----------
IncProgbar macro
local toend , tofull 
push ax
push cx
mov cx , 35
mov ax , 1
add [si+4] , ax
cmp [si+4] , cx
jae tofull
sub cx , [si+4]
mov ax , [si]
add ax , [si+4]
mov temp1 , ax
mov temp2 , cx
pop cx
pop ax
drawsolidrect [si] , [si+2] , [si+4] , 20 , 02h
drawsolidrect temp1 , [si+2] , temp2 , 20 , 04h
jmp toend
tofull:
pop cx
pop ax
drawsolidrect [si] , [si+2] , [si+4] , 20 , 02h 






toend:															
endm    IncProgbar
;---------dec prog bar----------
decProgbar macro
local toend , dead
push ax
push cx
mov cx , 0
mov ax , 1
sub [si+4] , ax
cmp [si+4] , cx
jbe dead
sub cx , [si+4]
mov ax , [si]
add ax , [si+4]
mov temp1 , ax
mov temp2 , cx
pop cx
pop ax
drawsolidrect [si] , [si+2] , [si+4] , 20 , 02h
drawsolidrect temp1 , [si+2] , temp2 , 20 , 04h
jmp toend
dead:
pop cx
pop ax
drawsolidrect [si] , [si+2] , [si+4] , 20 , 04h 






toend:															
endm    decProgbar


;------------------------------


drawbullets2 MACRO
	    local loopbullets1,loopbullets2,empty,empty2,didnt_go_out
            ;--------- draw player 1 bullets -------------
            push ax
            push bx
            push dx
            push di
            push cx

            mov di,0 ;counter for loop
            
            mov bx,offset player1bullets
            mov ax,[bx]                   ;number of bullets
	    

	    cmp ax,0
	    je empty

	    mov bx,offset player1bulletx
loopbullets1:            
            mov bx,offset player1bulletx
	    ;move player 1 bullets by one            
	    mov dx,[bx+di]
	    add dx,1
	    mov [bx+di],dx

            mov bx,offset player1bullety
           
            mov si,[bx+di]
	    drawrect dx,si,5,2,03h
            cmp dx,150
            jb didnt_go_out
	     
	    deletebullet1 di		

	    didnt_go_out:
            add di,2
            cmp di,ax
            jne loopbullets1
            
            empty:
	    cmp ax,0
            je empty2
            ;--------- draw player 2 bullets -------------
            
            mov di,0 ;counter for loop
            
            mov bx,offset player2bullets
            mov ax,player2bullets                       ;number of bullets
	    mov bx,offset player2bulletx
	    
            cmp ax,0
	    je empty2
loopbullets2:            
            mov bx,offset player2bulletx
            mov dx,[bx+di]
		
	    ;move player 2 bullets by one            
	    mov dx,[bx+di]
	    sub dx,1
	    mov [bx+di] , dx            
		
            mov bx,offset player2bullety	    
	    mov si,[bx+di]

            drawrect dx,si,5,2,03h
            
            add di,2
            cmp di,ax
            jne loopbullets2 
            
	    empty2: 
          
            pop cx
            pop di
            pop dx
            pop bx
            pop ax
            

       endm


deletebullet1 MACRO 
push ax
push bx
push si 
;-------------------------swap x position----------------------
mov bx,offset player1bulletx

mov si,player1bullets
mov dx,[bx+si-2] ;get last bullet in the array
mov [bx+di],dx ;put the last bullet instead of the deleted one
;-------------------------swap y position----------------------
mov bx,offset player1bullety
mov dx,[bx+si-2] ;get last bullet in the array
mov [bx+di],dx ;put the last bullet instead of the deleted one
;-------------------------decrement bullet count-------------------------


mov si,player1bullets
sub si,2
mov bx,offset player1bullets
mov [bx],si


pop si
pop bx
pop ax

endm
;------------------------------------ delete bullet 2 ------------------------------------

deletebullet2 MACRO 
push ax
push bx
push si 
;-------------------------swap x position----------------------
mov bx,offset player2bulletx

mov si,player2bullets
mov dx,[bx+si-2] ;get last bullet in the array
mov [bx+di],dx ;put the last bullet instead of the deleted one
;-------------------------swap y position----------------------
mov bx,offset player2bullety
mov dx,[bx+si-2] ;get last bullet in the array
mov [bx+di],dx ;put the last bullet instead of the deleted one
;-------------------------decrement bullet count-------------------------


mov si,player2bullets
sub si,2
mov bx,offset player2bullets
mov [bx],si

pop si
pop bx
pop ax

endm

;---------------------------------------------

pushall macro

push ax
push bx
push cx
push dx
push di
push si


endm


popall macro

pop si
pop di
pop dx
pop cx
pop bx
pop ax

endm