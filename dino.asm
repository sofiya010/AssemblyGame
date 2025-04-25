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
lastTime DWORD 0       ; Stores the last recorded time


strEnd byte "Your final score was: ",0
;; position of a cactus
xPosCacti byte 40
yPosCacti byte 0
dir BYTE 0

; Cactus X positions array

cacti byte 10 dup(0)
numCacti BYTE 0   ; The number of shown cacti

cactiXPos BYTE 10, 30, 50, 70, 90  ; Add more positions as needed


; block obstacles to jump over
xBlockPos BYTE ?
yBlockPos BYTE ?

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
	jne fin

	;; if it did...
	

	mov bl, byte ptr col
	mov esi, offset cacti
	mov ecx, 0
	mov cl, numCacti
	add esi, ecx
	
	mov [esi], bl
	inc numCacti

	fin:
		ret
createCacti ENDP


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
			je fin
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
	
	;; draw cactus
	;;invoke DrawCactus, xPosCacti, yPosCacti



	;; start game loop
	gameLoop:
		inc score
		mResetColor
		mCursor 15,0
		mov eax, score
		call WriteInt
		
		mov eax, 100
		call Delay

		call createCacti

		invoke UpdateCactus, offset cacti, yPosCacti, numCacti
		call decCacti
		
		
		;mov xPosCacti, al
		;cmp xPosCacti, 0
		;jle resetCacti

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
		

			jmp gameLoop

		ascend:
			mResetColor
			invoke Jump, xPos, yPos, row, offset cacti, yPosCacti, numCacti
			mov yPos, al
			
			jmp gameLoop

		fall: 
			invoke UpdateCactus, offset cacti, yPosCacti, numCacti
			
			mResetColor
			
			invoke Gravity, row, xPos, yPos
			mov yPos, al
			
			cmp al, yFloor
			jne gameLoop

			call checkHit
			cmp dl, 1
			je isHit

			jmp gameLoop

		duck:
			jmp gameLoop

		resetCacti:
			mov bl, byte ptr col
			mov xPosCacti, bl
			jmp gameLoop

		isHit:
			call Clrscr
			mResetColor
			mov ax, col
			mov bl, 2
			div bl
			sub ax, 8
			mov dx, ax
			mov ax, row
			div bl
			mCursor dl, al
			mov edx, offset strEnd
			call WriteString
			mov eax, score
			call WriteInt
			jmp exitGame



	exitGame:
		mov eax, 5000
		call Delay
		;mov eax, 5
		exit
main ENDP




END main