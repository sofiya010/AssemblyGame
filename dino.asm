;; Include main inc file
include physics.inc
include init.inc
include draw.inc
include Irvine32.inc


.data

;; size of the command window
row word ?
col word ?

;; position of bottom of player
xPos BYTE ?
yPos BYTE ?

;; score variabes
strScore BYTE "Your score is: ",0
score BYTE 0

;; position of a cactus
xPosCacti BYTE 40
yPosCacti word 0

; Cactus X positions array
cactiXPos BYTE 10, 30, 50, 70, 90  ; Add more positions as needed
numCacti BYTE 5   ; The number of cacti

; block obstacles to jump over
xBlockPos BYTE ?
yBlockPos BYTE ?

inputChar BYTE ?

.code
; start main
main PROC

call createEnv


;call setFloor ; create Floor
;call drawCactus


;call DrawPlayer

;call CreateRandomCoin
;call DrawCoin

;call Randomize

gameLoop:

; getting points:
; mov bl,xPos
;cmp bl,xCoinPos
;jne notCollecting
;mov bl,yPos
;cmp bl,yCoinPos
;jne notCollecting

; player is intersecting coin: we dont need this in geodash, but useful to see how "touch" works
;inc score
;call CreateRandomCoin
;call DrawCoin
;notCollecting:

mov eax,white (black * 16)
call SetTextColor

; draw score:
mov dl,0
mov dh,0
call Gotoxy
mov edx,OFFSET strScore
call WriteString
mov al,score
call WriteInt

 call Gravity row

onGround:

; get user key input:
call ReadChar
mov inputChar,al

; exit game if user types 'x':
cmp inputChar,"x"
je exitGame

cmp inputChar,"w"
je moveUp


moveUp:
; allow player to jump:
mov ecx,2 
jumpLoop:
call UpdatePlayer xPos, yPos, -1
;;dec yPos
;;call DrawPlayer
mov eax,70
call Delay
loop jumpLoop
jmp gameLoop

moveDown:
call UpdatePlayer
inc yPos
call DrawPlayer
jmp gameLoop

jmp gameLoop

exitGame:
exit
main ENDP

drawStars PROC
; Generate random white stars in the sky above the floor
mov ecx, 50 ; Number of stars to display
starLoop:
call RandomRange
mov dl, al ; Random X position (across the whole screen)

call RandomRange
and al, 10 ; Keep stars in the top 10 rows (not in the floor area)
mov dh, al

mov eax, white + (black * 16) ; White foreground, black background
call setTextColor
call Gotoxy
mov al, 42 ; ASCII for '*'
call WriteChar

loop starLoop
ret
drawStars ENDP


END main