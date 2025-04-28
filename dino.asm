;; Include main inc file
include Irvine32.inc
include physics.inc
include init.inc
include draw.inc


.data

;; size of the command window
row word 0
col word 0

;; position of bottom of player
xPos BYTE 0
yPos BYTE 0

yFloor byte 0

;; score variabes
strScore BYTE "Your score is: ",0
score DWORD 0


strTaunt byte "Oh, your spine's gone. And you have no insurance? Game Over.", 0
strEnd byte "Maidens? None. Score? ",0
;; position of a cactus
yPosCacti byte 0


; Cactus X positions array

cacti byte 10 dup(0)
numCacti BYTE 0   ; The number of shown cacti

spines byte 5 dup(0)
numSpine BYTE 0   ; The number of shown cacti

inputChar BYTE ?

.code
;; funny marcos

mResetColor macro
	
	mov eax,white (black * 16)
	call SetTextColor

endm

mCursor macro xPos, yPos
    mov dl,xPos
    mov dh,yPos
    call Gotoxy
endm

mRand macro
	mov eax, 18
	call RandomRange

endm

createCacti PROC
	;; check if we have already hit
	;; maximum cacti
	mov dl, numCacti
	cmp dl, 10
	jge fin
	
	;; check if the 1/18 chance of a
	;; spawn occurred
	mRand
	cmp eax, 0
	jne daSpine

	;; if it did...
	
	;; get column
	mov bl, byte ptr col
	;; move into esi, the offset of cacti
	mov esi, offset cacti
	;; not sure why, but this is the only way to add to esi
	;; without crashing
	mov ecx, 0
	mov cl, numCacti
	add esi, ecx
	
	mov [esi], bl
	inc numCacti

	fin:
		ret
	
	daSpine:
		invoke createSpine
		ret

createCacti ENDP


createSpine PROC
	;; check if we have already hit
	;; maximum cacti
	mov dl, numSpine
	cmp dl, 10
	jge fin
	
	;; check if the 1/18 chance of a
	;; spawn occurred
	mRand
	cmp eax, 0
	jne fin

	;; if it did...
	
	;; get column
	mov bl, byte ptr col
	;; move into esi, the offset of cacti
	mov esi, offset spines
	;; not sure why, but this is the only way to add to esi
	;; without crashing
	mov ecx, 0
	mov cl, numSpine
	add esi, ecx
	
	mov [esi], bl
	inc numSpine

	fin:
		ret
		

createSpine ENDP




decCacti proc
	;; check if there are actually cacti
	mov cl, numCacti
	cmp cl, 0
	je fin ;; if not then no need to move any
	
	mov esi, offset cacti 
	mov bl, [esi]
	cmp bl, 0 ;; check if the first cacti has a value of zero
	jne decrease ;; if not, then we can just decrease the values

	;; if it does then we need to check how many values
	;; we need to shift over
	cmp cl, 1
	je res ;; if only cacti then we just dec numCacti and move on
	
	dec numCacti
	mov cl, numCacti
	mov esi, offset cacti
	;; we decrease numCacti first because we need to shift numCacti-1 cacti
	shift:
		;; move the value from the right to this one
		mov bl, [esi + 1]
		mov [esi], bl
		inc esi
		cmp cl, 0
		dec cl
		jne shift
		jmp decrease
		
	;; now we should have all cacti that will show up
	decrease:
		mov cl, numCacti
		mov esi, offset cacti
		;; decease value by one for each cacti
		dloop:
			mov bl, [esi]
			dec bl
			mov [esi], bl
			inc esi
			cmp cl, 0
			je fin ;; finish if end of array
			dec cl
			jmp dloop			
		
	res:
		dec numCacti
		jmp fin
		
	fin:
		ret

decCacti endp

checkHit proc
	;; get our array of cacti
	mov esi, offset cacti
	;; check if array has values
	mov cl, numCacti
	cmp cl, 0
	je no_fin

	;; if it does then compare value to player val
	checker:
		mov bl, byte ptr [esi] 
		cmp bl, xPos
		;; if same then ret 1 for true
		je yes_fin
		;; if not then see if end of list or repeat
		inc esi
		dec cl
		cmp cl, 0
		je no_fin
		jmp checker

	;; if hit
	yes_fin:
		mov dl, 1
		ret

	;; if not hit
	no_fin:
		mov dl, 0
		ret

checkHit endp



; start main
main PROC
	call Randomize
	;; initializes the game and creates the environment
	;; will add starts to createEnv later
	mResetColor
	invoke createEnv
	;; store row and col values
	mov row, ax
	mov col, bx


	;; set up our dino location
	mov bl,  byte ptr row
	mov yPos, bl
	mov yFloor, bl
	mov yPosCacti, bl
	sub yPosCacti, 2
	sub yPos, 2
	sub yFloor, 2
	mov xPos, 10

	;; draw 'dino' and write score
	mResetColor
	mCursor 0, 0
	mov edx, offset strScore
	call WriteString
	mov eax, score
	call WriteInt

	invoke DrawPlayer, byte ptr xPos, byte ptr yPos

	;draw some stars
	invoke DrawStars

	; Set text color to bright white on black
    mov eax, white + (black * 16)
    call SetTextColor

	; draw some stars 

	

	;; start game loop
	gameLoop:
		
		inc score ;; free score at beginning lol

		;; write score in top left
		mResetColor
		mCursor 15,0 ;; i know i can do by len of strScore but dont feel like it
		mov eax, score
		call WriteInt
		
		;; delay the game to make it playable
		mov eax, 110
		call Delay

		;; try to create a cacti
		call createCacti

		;; update all the cacti we have
		invoke UpdateCactus, offset cacti, yPosCacti, numCacti
		call decCacti ;; decrease location of cacti by one, already displayed above
		;; I think this has something to do with the cacti at the end 
		mov dl, yPos
		cmp yFloor, dl
		jne fall

		;; while we are on the ground
		onGround:
			
			call checkHit
			cmp dl, 1
			je isHit


			; get user key input:
 			call ReadKey
			mov inputChar,al

			
			;; check if jump
			cmp inputChar," "
			je ascend
			
			cmp inputChar,"w"
			je ascend

			;; check if duck
			cmp inputChar,"s"
			je duck

			; exit game if user types 'x':
			cmp inputChar,"x"
			je exitGame
			;; if none then continue
			jmp gameLoop

		;; we do be jumping
		ascend:
			mResetColor
			invoke Jump, xPos, yPos, row, offset cacti, yPosCacti, numCacti
			mov yPos, al
			
			jmp gameLoop

		;; we do be falling
		fall: 
			
			mResetColor
			
			;; I SHALL INVOKE GRAVITY
			invoke Gravity, row, xPos, yPos
			mov yPos, al
			
			;; move cactus again, score stays the same, maybe inc here idk
			invoke UpdateCactus, offset cacti, yPosCacti, numCacti

			mov al, yPos
			;; check if we are on the floor
			cmp al, yFloor
			je ender

			dec al

			cmp al, yFloor
			je ender
			jmp gameLoop


			;; if we are, do collision detection
			ender: 
				call checkHit
				cmp dl, 1
				je isHit

				jmp gameLoop

		;; does nothing
		duck:
			jmp gameLoop

		;; endgame logic
		isHit:
			;; clear screen

			invoke TakeSpine, xPos, yPos

			call Clrscr
			invoke Grave, word ptr yFloor, col
			mResetColor
			;; div size of terminal to get semi centered
			mov ax, col 
			mov bl, 2
			div bl
			sub ax, 10
			mov dx, ax
			mov ax, row 
			div bl
			sub dl, 20 ; just moving it a bit left, long sentence for t
			mCursor dl, al

			;; write out taunt

			mov edx, offset strTaunt
			call WriteString

			;; move cursor down one line
			inc al       ;; AL holds the row (after mCursor)
			add dl, 18
			mCursor dl, al

			;; write out ending string
			mov edx, offset strEnd
			call WriteString

			;; write out score
			mov eax, score
			call WriteInt

			jmp exitGame



	;; wait 5 seconds and end
	exitGame:
		mov eax, 5000
		call Delay
		exit
main ENDP




END main
