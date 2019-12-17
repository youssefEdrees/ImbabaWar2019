include mymacros.inc
;include mymacros2.inc

.model compact

.stack 64
.data
intromessage db 10,13,10,13,10,13,10,13,10,13,9,'     EMBABA WAR  ','$' ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mes db 10,13,10,13,9,9,'main menu','$'
;infomessage1 db 10,13,9,9,'Info menu',10,13,'Player1: UP:W',9,'Down:S',9,'Right:D',9,'fire:f','$'
;infomessage2 db 'Player2: UP:uparrow',9,'Down:downarrow',9,'Right:rightarrow',9,'Left:leftarrow',9,'fire:l','$'
fitmess db 10,13,10,13,10,13,9,'   start play press ','$'
secmess db 10,13,10,13,10,13,10,13,9,'   start chat press ','$'
;guidemess db 10,13,10,13,10,13,10,13,9,'   Game INFO press ','$'
name_request_message db 10,13,10,13,10,13,9,'   please enter your name ',10,9,9,'$'

play_req_mes db ' ,you recived playing request press y to accept $'

connection_waiting_mes db ' waiting for the other player to connect $'

play_req_mes_wait db  ' ,waiting for other player answer $'
player1 dw 70 , 100
player2 dw 250 , 100

player1Score db 0
player2Score db 0

player_name db  26        ;MAX NUMBER OF CHARACTERS ALLOWED (25).
            db  ?         ;NUMBER OF CHARACTERS ENTERED BY USER.
my_name     db  26 dup('$') ;CHARACTERS ENTERED BY USER.

other_player_name db 'player 2 $' ;CHARACTERS ENTERED BY USER.


               
playerstep equ 4
playerheight equ 15

bulletHitAmountHealthbar equ 1

player1bullets dw 0
player1bulletx dw 200 dup(0)
player1bullety dw 200 dup(0)

player2bullets dw 0
player2bulletx dw 200 dup(0)
player2bullety dw 200 dup(0)


laser_bar_recover_delay equ 33
barrier_bar_recover_delay equ 33

laser_on_delay equ 255

laserthickness equ 3
laserlength equ 150

firsthealthbar  dw 10 , 10 , 35
secondhealthbar dw 170 , 10 , 35

connection_set db 0 
leftPlayer db 0  ; for multible devices

received_VALUE db 0 
send_VALUE db 0 

;**********************
firstlaserrecoverdelay db laser_bar_recover_delay
firstlaser_on_delay   db 1
firstlaserbar   dw 70 , 13 , 20
secondlaserrecoverdelay db laser_bar_recover_delay
secondlaser_on_delay   db 1
secondlaserbar   dw 230 , 13 , 20
;**********************
firstbarrierrecoverdelay db barrier_bar_recover_delay
firstbarrierbar  dw 115 , 13 , 35
secondbarrierrecoverdelay db barrier_bar_recover_delay
secondbarrierbar dw 275 , 13 , 35

;---width and len
widthG equ  15
lenG   equ  20
widthB equ  2
lenB   equ  5 

;-----temp memory
yGamerTop dw 0
yGamerBottom dw 0

yBulletTop dw 0
yBulletBottom dw 0
lenBetweenGB dw 0 


temp1 dw ?
temp2 dw ?
.code         
main proc far  


mov ax,@data
mov ds,ax


;--------------------------- set up serial stuff-------------------------
;Set Divisor Latch Access Bit
mov dx,3fbh 			; Line Control Register
mov al,10000000b		;Set Divisor Latch Access Bit
out dx,al				;Out it
;Set LSB byte of the Baud Rate Divisor Latch register.
mov dx,3f8h			
mov al,0ch			
out dx,al
;Set MSB byte of the Baud Rate Divisor Latch register.
mov dx,3f9h
mov al,00h
out dx,al
;Set port configuration
mov dx,3fbh
mov al,00011011b
out dx,al
;------------------------------------------------------------------------






;********video mode********
mov ax,13h
int 10h
;*********intro message****************;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; intromenu intromessage				   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MOV     CX, 1fH						   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MOV     DX, 8253H					   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MOV     AH, 86H						   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INT     15H							   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;********clear screen******************;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   clear_screen





reset_cursor

;-------- get name -------------
    showmessage name_request_message
    mov ah, 0Ah ;SERVICE TO CAPTURE STRING FROM KEYBOARD.
    mov dx, offset player_name
    int 21h 

;---------------------------------
clear_screen
;----------- establish connection----------
mov al, '*' ;any body there signal
mov send_VALUE,al
call send_data_proc

showmessage connection_waiting_mes

no_signal_yet:



call receive_data_proc
mov al,'-' ; empty sign
cmp received_VALUE,al
jne data_received 
jmp no_signal_yet

data_received:
mov al, '&' 
cmp received_VALUE,al
je dont_say_yes

mov al, '&'      ;yes signal
mov send_VALUE,al
call send_data_proc

dont_say_yes:

;----------- establish connection----------
game_over:
call reset_game ; reset health bar & bullets 


;********main menu mode********
clear_screen
;mainmenu mes,fitmess,secmess

mainmenu_loop :
;clear_screen

reset_cursor
;-------key pressed--------

mainmenu mes,fitmess,secmess

    mov ah,1
    int 16h
    
    jnz exist1
    jmp far ptr receive
    exist1:
    mov ah,0
    int 16h
    mov send_VALUE,al
    call send_data_proc 

    cmp al , 'p'
    je a_play_request
    jmp far ptr receive
    a_play_request:
 ;   call request_sent_proc
     req_sent_mac

    
    

    







receive:

call receive_data_proc

mov al,received_VALUE
cmp al , '-'
jne not_empty1
jmp far ptr mainmenu_loop

not_empty1:
cmp al , 'p'
jne not_a_play_request1

req_rec_mac



not_a_play_request1:

jmp mainmenu_loop

;********clear screen******************

clear_screen

;*******************

;*******************
;mov ax , 8h
;mov bx , 5010h              ;i forgot but one of this trio is v.v.i
;mov dx , 03h

;*******************

;drawrect 159 , 0 , 1 , 200 , 06h ;pitch division


mov dx,0  ;i am using DX , BX for the delay in fire rate so DON'T CHANGE THEM IN YOUR CODE
mov bx,0  ;

mov cx,0

game_loop: ; yamany

drawsolidrect 0 , 0 , 158 , 3 , 0h ; don't touch
drawsolidrect 161 , 0 , 158 , 3 , 0h ; don't touch

mov bx,offset firsthealthbar
add bx,4
mov ax,[bx]
cmp ax,5
jae not_game_over

mov bh ,player2Score ;inc player 2 score
inc bh
mov player2Score , bh

jmp far ptr game_over
not_game_over:

mov bx,offset secondhealthbar
add bx,4
mov ax,[bx]

cmp ax,5
jae not_game_over2

mov bh ,player1Score ;inc player 1 score
inc bh
mov player1Score , bh

jmp far ptr game_over
not_game_over2:


;cmp cx,0ff0h 
;jb skip


;drawsolidrect

;mov si , offset firstlaserbar
;incprogbar
;mov si , offset secondlaserbar
;incprogbar
;mov si , offset firstlaserbar
;decprogbar
mov si , offset firsthealthbar
drawprogbar 10, 02h, 04h
mov si , offset secondhealthbar
drawprogbar 10, 02h, 04h

mov si , offset firstlaserbar
drawprogbar 5, 1110b, 04h
mov si , offset secondlaserbar
drawprogbar 5, 1110b, 04h

mov si , offset firstbarrierbar
drawprogbar 5, 1000b, 04h
mov si , offset secondbarrierbar
drawprogbar 5, 1000b, 04h

call firstlaserrecoverdelay_proc

call secondlaserrecoverdelay_proc

call firstbarrierrecoverdelay_proc

call secondbarrierrecoverdelay_proc


call drawfirstlaser
call drawsecondlaser

; call a3del_elgamer

mov di , offset player1
drawrect [di] , [di+2] , 20 , playerheight , 05h ;1st player
;
;movplayer1
;drawrect 159 , 0 , 1 , 200 , 06h

mov di , offset player2
drawrect [di], [di+2] , 20 , playerheight , 05h ;2nd player

;mov ah,1
;int 16h
;jz ending

;MOV     CX, 0H
;MOV     DX, 6000H
;MOV     AH, 86H
;INT     15H

;movplayer2


;ending:


;drawrect 70 , 100 , 20 , 15 , 05h ;1st player

; call movplayer1

;drawrect 250, 100 , 20 , 15 , 05h ;2nd player   

    push ax
    push cx
    push dx
    
    push bx
    
    
    ;-----------------------delay-----------------
    mov cx,0fffh
    l99:
    
    loop l99
    ;-----------------------delay-----------------
    ;MOV     CX, 0H
    ;MOV     DX, 6000H
    ;MOV     AH, 86H
    ;INT     15H
    ; ----------------------- clear screen -------------------------
    ;mov ax,0600h  
    ;mov bh,0
    ;mov cx,0
    ;mov dx,184fh
    ;int 10h 
    ;-----------------------------------------------------------------
    ;drawsolidrect 0 , 0 , 320 , 200 , 0h ;pitch division
    
    pop bx
    pop dx
    pop cx
    pop ax
    
    
    push ax
drawsolidrect 159 , 0 , 1 , 200 , 06h ;pitch division
pop ax
    
    
    call drawbullets
    call player2bullets_problem
    
    
    ;mov ah,1
    ;int 16h
    ;
    ;jz nothing_pressed
    ;    
    ;mov ah,07
    ;int 21h
    ;
    ;cmp al,'f'
    ;jne dontfire1
    ;
    ;cmp dx,10          ;fire rate delay 
    ;jb nothing_pressed  ;
    ;
    ;call firebullet1
    ;;skip:
    ;;cmp cx,0fff0h
    ;;jb skip2
    ;dontfire1:
    ;cmp al,'l'
    ;jne dontfire2
    ;
    ;cmp bx,10          ;fire rate 
    ;jb nothing_pressed  ;
    ;    
    ;call firebullet2
;
    ;
    ;dontfire2:
    ;
    ;
    ;nothing_pressed:
   
    
    call key_listener

    mov cx,0
    
    inc dx
    inc bx
    
    call Collesion
    ;skip2:
    ;    inc cx
jmp game_loop

hlt
main    endp

;*****************************
;Movplayer1	proc

;CHECK:  mov ah,1
;        int 16h
;        jz CHECK
;		mov si , offset player1
;		cmp ah , 48
;		jz UP
;		cmp ah , 50
;		jz down
;		cmp ah , 4d
;		jz right
;		left:mov bx , 1
;		sub [si + 2] , bx
;		drawsolidrect  [si] , [si+2] , 20 , 15 , 05h
;		jmp toend
;		UP:mov bx , 1
;		add [si + 2] , bx
;		drawsolidrect  [si] , [si+2] , 20 , 15 , 05h
;		jmp toend
;		down:mov bx , 1
;		sub [si + 2] , bx
;		drawsolidrect  [si] , [si+2] , 20 , 15 , 05h
;		jmp toend
;		right:mov bx , 1
;		add [si] , bx
;		drawsolidrect  [si] , [si+2] , 20 , 15 , 05h
;		toend:
;ret
;Movplayer1 endp
;*****************************
firebullet1 proc
            ;add x position
            push bx 
            push ax
            push si 
            
            mov bx,offset player1
            mov ax,[bx] ;x position for player 1
            
            mov bx,offset player1bulletx
            mov si,player1bullets
            
            mov [bx+si],ax
                              
            
            
            
            ;add y position
            mov bx,offset player1
            add bx,2
            mov ax,[bx] ;y position for player 1
            
            mov bx,offset player1bullety
            
            
            mov [bx+si],ax
                               ;inc number of bullets
            add si,2
            mov bx,offset player1bullets
            mov [bx],si 
    
            pop si
            pop ax
            pop bx
    
            mov dx , 0 
            
            ret
firebullet1 endp

;*****************************

firebullet2 proc
            ;add x position
            
            push bx 
            push ax
            push di 
            
            mov bx,offset player2
            mov ax,[bx] ;x position for player 2
            
            mov bx,offset player2bulletx
            mov di,player2bullets
            
            mov [bx+di],ax
                              
            
            
            
            ;add y position
            mov bx,offset player2
            mov ax,[bx+2] ;y position for player 2
            
            mov bx,offset player2bullety
            
            
            mov [bx+di],ax
                               ;inc number of bullets
            add di,2
            mov bx,offset player2bullets
            mov [bx],di 
    
    
            pop di
            pop ax
            pop bx
            
            mov bx , 0
            ret
firebullet2 endp 

;*****************************  



drawbullets proc
    
	   
            ;--------- draw player 1 bullets -------------
            pushall
            
            mov di,0 ;counter for loop
            
            mov bx,offset player1bullets
            mov ax,[bx]                   ;number of bullets
	    

	    cmp ax,0
	    jne eee
      jmp far ptr empty
      eee:
	    ;mov bx,offset player1bulletx
loopbullets1:            
        mov bx,offset player1bulletx
	    ;move player 1 bullets by one            
	    mov dx,[bx+di]
	    call drawBulletFrame_black1

      add dx,1
	    mov [bx+di],dx

            mov bx,offset player1bullety
           
            mov si,[bx+di]
            call drawBulletFrame
            cmp dx,310
            jb didnt_go_out
            
	     
          call drawBulletFrame_black1
	        deletebullet1 		
            sub di,2
	        didnt_go_out:       
	        
	        add di,2                    
            
            
            mov ax,player1bullets
            
            cmp di,ax
            jae eee2
            jmp far ptr loopbullets1
            eee2:
            
            empty:
            ;--------- draw player 2 bullets -------------
            
            mov di,0 ;counter for loop
            
            mov bx,offset player2bullets
            mov ax,player2bullets                       ;number of bullets
	    ;mov bx,offset player2bulletx
	    
            cmp ax,0
	    jne eee3 
      jmp far ptr empty2
      eee3:
	        mov di,0
loopbullets2:            
            mov bx,offset player2bulletx
            mov dx,[bx+di]

            call drawBulletFrame_black2
		
	    ;move player 2 bullets by one            
	    mov dx,[bx+di]
	    dec dx
	    mov [bx+di] , dx            
		
            mov bx,offset player2bullety	    
	    mov si,[bx+di]

            call drawBulletFrame
            cmp dx,0
            
            jbe eee4
            jmp far ptr didnt_go_out2
	          eee4:
            
            call drawBulletFrame_black2
	         ;deletebullet2 	
            add bx,di
            mov si,bx
            mov bx,offset player2bulletx
            add bx,di
            mov dx,bx
            deleteBulletsShoubra dx,si 
            ;deletebullet2
            sub di,2
            
            didnt_go_out2:       
            
            
            add di,2
            cmp di,ax
            jae eee5
            jmp far ptr loopbullets2 
            eee5:
            
	    empty2: 
          
            popall
            
            ret
drawbullets endp

;***************************
drawBulletFrame proc
drawrect dx,si,5,2,03h
        
ret
drawBulletFrame endp


drawBulletFrame_black1 proc
  push bx 
  mov bx,offset player1bullety         
  mov si,[bx+di]
  drawrect dx,si,5,2,0h
  pop bx
ret
drawBulletFrame_black1 endp


drawBulletFrame_black2 proc
  push bx 
  mov bx,offset player2bullety         
  mov si,[bx+di]
  drawrect dx,si,5,2,0h
  pop bx
ret
drawBulletFrame_black2 endp

;***************************
player2bullets_problem proc
             pushall
             
             mov di,0 ;counter for loop
            
            mov bx,offset player2bullets
            mov ax,player2bullets                       ;number of bullets
	    ;mov bx,offset player2bulletx
	    
            cmp ax,0
	    je empty4
	        mov di,0
loopbullets4:            
            mov bx,offset player2bulletx
            mov dx,[bx+di]
		      
	    mov dx,[bx+di]
	    
		
            mov bx,offset player2bullety	    
	    mov si,[bx+di]

            cmp dx,300
            jb didnt_go_out4
	          drawrect dx,si,5,2,0h
	          deletebullet2 		
            sub di,2
            didnt_go_out4:       
            
            
            add di,2
            cmp di,ax
            jb loopbullets4 
            
	    empty4: 




            popall
            ret
player2bullets_problem endp

;***************************
   
key_listener proc
    mov ah,1
    int 16h
    
    jnz exist
    ret
    exist:
    mov ah,0
    int 16h
    ;-----------------------check player 2 movement--------------------
    cmp al,'a'
    je yes_player2
    cmp al,'w'
    je yes_player2
    cmp al,'s'
    je yes_player2
    cmp al,'d'
    je yes_player2
    
    jmp no_player2
    yes_player2:
    movplayer2
    no_player2:
    ;-----------------------check player 1 movement--------------------
    cmp ah,48h
    je yes_player1
    cmp ah,50h
    je yes_player1
    cmp ah,4bh
    je yes_player1
    cmp ah,4dh
    je yes_player1
    
    jmp no_player1
    yes_player1:
    movplayer1
    no_player1:
    ;--------------------------check Bullets------------------------    
    cmp al,'f'
    jne dontfire1
    
    cmp dx,10          ;fire rate delay 
    jb dontfire1  ;
    
    call firebullet1
    ;skip:
    ;cmp cx,0fff0h
    ;jb skip2
    dontfire1:
    cmp al,'l'
    jne dontfire2
    
    cmp bx,10          ;fire rate 
    jb dontfire2  ;
        
    call firebullet2

    
    dontfire2:
    ;--------------------------check Laser------------------------

    cmp al, ';'
    jne dontlaser1
    
    
    call laser1

    dontlaser1:
    cmp al, 'e'
    jne dontlaser2

    call laser2
    dontlaser2:

    ;--------------------------check Barrier------------------------

    cmp al, 'k'
    jne dontbarrier1
    
    
    call barrier1

    dontbarrier1:
    cmp al, 'q'
    jne dontbarrier2

    call barrier2
    dontbarrier2:
    
    ;nothing_pressed:

    mov al,0
ret
key_listener endp
;***************************
laser1 proc 
mov si , offset secondlaserbar
decprogbar 8

mov secondlaser_on_delay, laser_on_delay
ret
laser1 endp

;***************************
laser2 proc 
mov si , offset firstlaserbar
decprogbar 8

mov firstlaser_on_delay, laser_on_delay
ret
laser2 endp

;***************************
barrier1 proc 
mov si , offset secondbarrierbar
decprogbar 8
ret
barrier1 endp

;***************************
barrier2 proc 
mov si , offset firstbarrierbar
decprogbar 8
ret
barrier2 endp

;***************************
firstlaserrecoverdelay_proc proc
push ax
mov al, 1
sub firstlaserrecoverdelay, al
cmp firstlaserrecoverdelay, al
pop ax
jbe inclaser1
jmp dont_inc_laserbar1

inclaser1: mov si , offset firstlaserbar
incprogbar 1
mov firstlaserrecoverdelay, laser_bar_recover_delay

dont_inc_laserbar1:
ret
firstlaserrecoverdelay_proc endp

;***************************
secondlaserrecoverdelay_proc proc
push ax
mov al, 1
sub secondlaserrecoverdelay, al
cmp secondlaserrecoverdelay, al
pop ax
jbe inclaser2
jmp dont_inc_laserbar2

inclaser2: mov si , offset secondlaserbar
incprogbar 1
mov secondlaserrecoverdelay, laser_bar_recover_delay

dont_inc_laserbar2:
ret
secondlaserrecoverdelay_proc endp

;***************************
firstbarrierrecoverdelay_proc proc
push ax
mov al, 1
sub firstbarrierrecoverdelay, al
cmp firstbarrierrecoverdelay, al
pop ax
jbe incbarrier1
jmp dont_inc_barrierbar1

incbarrier1: mov si , offset firstbarrierbar
incprogbar 1
mov firstbarrierrecoverdelay, barrier_bar_recover_delay

dont_inc_barrierbar1:
ret
firstbarrierrecoverdelay_proc endp

;***************************
secondbarrierrecoverdelay_proc proc
push ax
mov al, 1
sub secondbarrierrecoverdelay, al
cmp secondbarrierrecoverdelay, al
pop ax
jbe incbarrier2
jmp dont_inc_barrierbar2

incbarrier2: mov si , offset secondbarrierbar
incprogbar 1
mov secondbarrierrecoverdelay, barrier_bar_recover_delay

dont_inc_barrierbar2:
ret
secondbarrierrecoverdelay_proc endp

;***************************
drawfirstlaser proc
push ax
mov al, 1
sub firstlaser_on_delay, al
cmp firstlaser_on_delay, al
pop ax
ja drawlaser1
jmp dont_drawlaser1

drawlaser1:
mov si, offset player1
;drawsolidrect [si], [si+2], laserlength, laserthickness, 04h
ret

dont_drawlaser1:
mov firstlaser_on_delay, 1
mov si, offset player1
;drawsolidrect [si], [si+2], laserlength, laserthickness, 0h

ret
drawfirstlaser endp

;***************************
drawsecondlaser proc
push ax
mov al, 1
sub secondlaser_on_delay, al
cmp secondlaser_on_delay, al
pop ax
ja drawlaser2
jmp dont_drawlaser2

drawlaser2:
mov si, offset player2
push ax
mov ax, [si]
sub ax, 130
mov temp1, ax
pop ax
;drawsolidrect temp1, [si+2], laserlength, laserthickness, 04h

ret

dont_drawlaser2:
mov secondlaser_on_delay, 2

mov si, offset player2
push ax
mov ax, [si]
sub ax, 130
mov temp1, ax
pop ax
;drawsolidrect temp1, [si+2], laserlength, laserthickness, 0h

ret
drawsecondlaser endp

Collesion proc 
    
    pushall
    
    mov cx,player1bullets
    cmp cx,0
    jne notempty
    jmp quit1
    notempty:

      mov di,offset player1bulletx
      mov si,offset player1bullety
      mov bx,offset player2 
    
    ;loop for all bullets out of gamer1
    LForRightSide:
        
        call CheckOfCollesion1
         
        add di,2
        add si,2
        sub cx,2
        cmp cx,0
    ja LForRightSide 
    quit1:
    mov cx,player2bullets
    cmp cx,0
    jne notempty2
    jmp quit2
    notempty2:
    mov di,offset player2bulletx
    mov si,offset player2bullety
    mov bx,offset player1 
    
     
     
    ;loop for all bullets out of gamer2
    LForLeftSide:
           
        call CheckOfCollesion2 
        
        add di,2
        add si,2
        sub cx,2
        cmp cx,0
    ja LForLeftSide
    
    quit2:
    popall
    ret
Collesion endp
;--------------------------
CheckOfCollesion1 proc 
   pushall 
   mov ax,[bx+2]
   mov yGamerTop,ax
   add ax,widthG  
   mov yGamerBottom,ax 
   
   mov ax,[si]
   mov yBulletTop,ax
   add ax,widthB
   mov yBulletBottom,ax
   
   mov ax,[bx]
   mov dx,[di]
   cmp ax,dx
   jae abslutelen
   sub dx,ax
   xchg dx,ax

   continue:
     mov lenBetweenGB,ax
     mov ax,widthB
     cmp lenBetweenGB,ax
      jbe continueComapring
      
     jmp outt

abslutelen:  ; abslute length
   sub ax,dx
   jmp continue    

continueComapring:
   mov ax,yBulletTop
   mov dx,yBulletBottom
   
   cmp ax,yGamerTop
     ja continueComapringg2
     je DecreaseHealth
   cmp dx,yGamerTop
     ja continueComapringg2       
     je DecreaseHealth
     jmp outt
continueComapringg2:

    cmp dx,yGamerBottom
     jbe  DecreaseHealth
     
   cmp ax,yGamerBottom
     jbe DecreaseHealth
     jmp outt   

DecreaseHealth:
    
    mov si , offset secondhealthbar
    decprogbar bulletHitAmountHealthbar
    
    mov bx,offset player1bulletx
    sub di,bx
    deletebullet1 
 
  ;debug
  ;mov cx,1
  ;mov bh,0
  ;mov ah,9
  ;mov al,44h
  ;mov bl,4
  ;int 10h

  
    
    
outt:
   
   popall
   ret
CheckOfCollesion1 endp

CheckOfCollesion2 proc

    pushall
   mov ax,[bx+2]
   mov yGamerTop,ax
   add ax,widthG  
   mov yGamerBottom,ax 
   
   mov ax,[si]
   mov yBulletTop,ax
   add ax,widthB
   mov yBulletBottom,ax
   
   mov ax,[bx]
   mov dx,[di]
   cmp ax,dx
   jae abslutelen2
   sub dx,ax
   xchg dx,ax

   continue2:
     mov lenBetweenGB,ax
     mov ax,widthG
     cmp lenBetweenGB,ax
      jbe continueComapring2
     jmp outt2

abslutelen2: ;absulte length 
   sub ax,dx
   jmp continue2    

continueComapring2:

   mov ax,yBulletTop
   mov dx,yBulletBottom
 
   cmp ax,yGamerTop
     ja continueComapring22
     je DecreaseHealth2
   cmp dx,yGamerTop
     ja continueComapring22       
     je DecreaseHealth2
     jmp outt2
continueComapring22:

    cmp dx,yGamerBottom
     jbe  DecreaseHealth2
     
   cmp ax,yGamerBottom
     jbe DecreaseHealth2
     jmp outt2   

DecreaseHealth2:
    
    push si
    mov si , offset firsthealthbar
    decprogbar bulletHitAmountHealthbar
    
    ;mov bx,player2bullets
    ;sub di,bx
    ;deletebullet2
    pop si
    deleteBulletsShoubra di,si 

  ;mov cx,1
  ;mov bh,0
  ;mov ah,9
  ;mov al,44h
  ;mov bl,4
  ;int 10h
    
    
outt2:
   popall
   ret
   
CheckOfCollesion2 endp
;***************************

a3del_elgamer proc
pushall              
;-------------------------player1-----------------------
mov bx,offset player1
mov cx,4    ;x left
;call drawrect_proc
cmp cx,[bx]
jb ssps
call drawrect_proc_x

mov [bx],cx
ssps:

mov cx,130    ;x right
cmp cx,[bx]
ja ssps2
call drawrect_proc_x
mov [bx],cx
ssps2:

mov bx,offset player1
add bx,2

mov cx,20    ;y top
cmp cx,[bx]
jb ssps3
call drawrect_proc_y
mov [bx],cx
ssps3:

mov cx,180    ;y bottom
cmp cx,[bx]
ja ssps4
call drawrect_proc_y
mov [bx],cx
ssps4:


;-------------------------player2-----------------------


mov bx,offset player2
mov cx,150    ;x left
cmp cx,[bx]
jb ssps5

call drawrect_proc_x
mov [bx],cx

ssps5:

mov cx,290    ;x right
cmp cx,[bx]
ja ssps6

call drawrect_proc_x
mov [bx],cx

ssps6:

mov bx,offset player2
add bx,2

mov cx,20    ;y top
cmp cx,[bx]
jb ssps7

call drawrect_proc_y
mov [bx],cx

ssps7:

mov cx,180    ;y bottom
cmp cx,[bx]
ja ssps8

call drawrect_proc_y
mov [bx],cx

ssps8:

popall
ret
a3del_elgamer endp

drawrect_proc_x proc

pushall
drawrect  [bx] , [bx+2] , 20 , playerheight , 0h
popall
ret

drawrect_proc_x endp

;**************************************

drawrect_proc_y proc

pushall
drawrect  [bx-2] , [bx] , 20 , playerheight , 0h
popall
ret
drawrect_proc_y endp

;**************************************

send_data_proc proc 
pushall



  		mov dx , 3FDH		; Line Status Register
AGAIN:  	
      In al , dx 			;Read Line Status
  		test al , 00100000b
  		JZ AGAIN                               ;Not empty
 
;If empty put the VALUE in Transmit data register
  		mov dx , 3F8H		; Transmit data register
  		mov  al,send_VALUE
  		out dx , al

;mov ah,2
;mov dl,send_VALUE
;int 21h

popall
ret 
send_data_proc endp

;**************************************

receive_data_proc proc

;Check that Data is Ready
		mov dx , 3FDH		; Line Status Register
	  	in al , dx 
  		test al , 1
  		JZ date_ready                                    ;Not Ready
 ;If Ready read the VALUE in Receive data register
  		mov dx , 03F8H
  		in al , dx 
  		mov received_VALUE , al
      ret

      date_ready:
      mov al , '-'
      mov received_VALUE , al


      ret 
receive_data_proc endp

;**************************************
;
;request_received_proc proc far
;
;request_received_loop:
;mov ah,1
;int 16h
;
;jnz exist2
;jmp request_received_loop
;exist2:
;
;mov ah,0
;int 16h
;mov send_VALUE, al
;call send_data_proc
;
;cmp al , 'y' ; request got accepted
;jne not_accepted1
;mov al, 1
;mov leftPlayer ,al
;jmp far ptr game_loop
;
;not_accepted1:
;jmp far ptr mainmenu_loop
;
;ret
;request_received_proc endp
;
;
;;***********************************
;
;request_sent_proc proc far
;
;request_sent_loop:
;call receive_data_proc
;mov al,received_VALUE
;
;cmp al , '-' ;'-' is empty receive value char
;je request_sent_loop
;
;cmp al , 'y' ; request got accepted
;jne not_accepted
;mov al, 0
;mov leftPlayer ,al
;jmp far ptr game_loop
;
;not_accepted:
;jmp far ptr mainmenu_loop
;
;request_sent_proc endp
;
;;***************************************
;
reset_game proc
mov bx,offset firsthealthbar
add bx,4
mov ax,35
mov [bx],ax

mov bx,offset secondhealthbar
add bx,4
mov ax,35
mov [bx],ax

mov bx,0
mov player1bullets,bx ;model small problem
mov player2bullets,bx

ret
reset_game endp 

end main
