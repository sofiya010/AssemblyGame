INCLUDE Irvine32.inc

.data

row word 0
col word 0

space byte " ", 0

strScore BYTE "Your score is: ",0
score BYTE 0

xPos BYTE 20
yPos BYTE 20

xCoinPos BYTE ?
yCoinPos BYTE ?

inputChar BYTE ?

.code
main PROC
	
	call getScreenSize ; Get the screen size

	call setFloor  ; create Floor


	;call DrawPlayer

	;call CreateRandomCoin
	;call DrawCoin

	;call Randomize

	gameLoop:

		; getting points:
			mov bl,xPos
		cmp bl,xCoinPos
		jne notCollecting
		mov bl,yPos
		cmp bl,yCoinPos
		jne notCollecting
		; player is intersecting coin:
		inc score
		call CreateRandomCoin
		call DrawCoin
		notCollecting:

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

		; gravity logic:
		gravity:
		cmp yPos,27
		jg onGround
		; make player fall:
		call UpdatePlayer
		inc yPos
		call DrawPlayer
		mov eax,80
		call Delay
		jmp gravity
		onGround:

		; get user key input:
		call ReadChar
		mov inputChar,al

		; exit game if user types 'x':
		cmp inputChar,"x"
		je exitGame

		cmp inputChar,"w"
		je moveUp

		cmp inputChar,"s"
		je moveDown

		cmp inputChar,"a"
		je moveLeft

		cmp inputChar,"d"
		je moveRight

		moveUp:
		; allow player to jump:
		mov ecx,1
		jumpLoop:
			call UpdatePlayer
			dec yPos
			call DrawPlayer
			mov eax,70
			call Delay
		loop jumpLoop
		jmp gameLoop

		moveDown:
		call UpdatePlayer
		inc yPos
		call DrawPlayer
		jmp gameLoop

		moveLeft:
		call UpdatePlayer
		dec xPos
		call DrawPlayer
		jmp gameLoop

		moveRight:
		call UpdatePlayer
		inc xPos
		call DrawPlayer
		jmp gameLoop

	jmp gameLoop

	exitGame:
	exit
main ENDP

getScreenSize PROC
	call GetMaxXY
	mov row, ax
	mov col, dx
	ret
getScreenSize endp

setFloor proc
	mov eax, 0
	call setTextColor
	
	mov cl, 1
tile:
	call Crlf

 	inc cl
	cmp cl, byte ptr row
	jne tile
	
	
	mov eax, blue * 16
	call setTextColor
	mov dh, byte ptr row
	call Gotoxy
	mov cl, 0

til2:
	
	mov edx, offset space
	call WriteString
	inc cl
	cmp cl, byte ptr col
	jne til2
	
	mov eax, 0

	ret

setFloor endp

DrawPlayer PROC
	; draw player at (xPos,yPos):
	mov dl,xPos
	mov dh,yPos
	call Gotoxy
	mov al,"X"
	call WriteChar
	ret
DrawPlayer ENDP

UpdatePlayer PROC
	mov dl,xPos
	mov dh,yPos
	call Gotoxy
	mov al," "
	call WriteChar
	ret
UpdatePlayer ENDP

DrawCoin PROC
	mov eax,yellow (yellow * 16)
	call SetTextColor
	mov dl,xCoinPos
	mov dh,yCoinPos
	call Gotoxy
	mov al,"X"
	call WriteChar
	ret
DrawCoin ENDP

CreateRandomCoin PROC
	mov eax,55
	inc eax
	call RandomRange
	mov xCoinPos,al
	mov yCoinPos,27
	ret
CreateRandomCoin ENDP

END main